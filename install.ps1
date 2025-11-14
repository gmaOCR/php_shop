<#
PowerShell installation script for Windows (requires PowerShell 7 recommended)
Usage: Open PowerShell as Administrator and run: .\install.ps1
This script attempts to mirror the behavior of install.sh for Windows:
- Verify Docker is installed
- Check ports
- Copy .env files if missing
- Start Docker Compose
- Wait for MySQL health status
- Run composer/npm commands inside containers
#>

$ErrorActionPreference = 'Stop'

function Write-Ok($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Read-Confirm($msg) { Write-Host "$msg (y/n): " -NoNewline; $key = Read-Host; return $key -match '^[Yy]$' }

# Prérequis: Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Err "Docker n'est pas installé. Installez Docker Desktop for Windows: https://docs.docker.com/desktop/"
    exit 1
}

# Compose: prefer docker compose (v2)
$dockerComposeCmd = 'docker compose'
try {
    docker compose version > $null 2>&1
} catch {
    if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
        Write-Err "Docker Compose introuvable (ni 'docker compose' ni 'docker-compose')."
        exit 1
    } else {
        $dockerComposeCmd = 'docker-compose'
    }
}
Write-Ok "Docker et compose OK ($dockerComposeCmd)"

# Check ports function
function Test-PortInUse([int]$port) {
    try {
        $c = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        return ($c -ne $null)
    } catch {
        # Older Windows without Get-NetTCPConnection
        $out = netstat -ano | Select-String ":$port\\s"
        return ($out -ne $null)
    }
}

foreach ($p in 80,3000,3307) {
    if (Test-PortInUse $p) {
        Write-Warn "Le port $p semble utilisé"
        if (-not (Read-Confirm "Continuer quand même ?")) { exit 1 }
    } else { Write-Ok "Port $p disponible" }
}

# Copy .env files if missing
if (-not (Test-Path .env)) { Copy-Item .env.dist .env; Write-Ok ".env créé" } else { Write-Warn ".env existe déjà" }
if (-not (Test-Path backend/.env)) { Copy-Item backend/.env.dist backend/.env; Write-Ok "backend/.env créé" } else { Write-Warn "backend/.env existe déjà" }
if (-not (Test-Path frontend/.env)) { Copy-Item frontend/.env.example frontend/.env; Write-Ok "frontend/.env créé" } else { Write-Warn "frontend/.env existe déjà" }

# Start docker compose
Write-Ok "Démarrage des services Docker..."
& $dockerComposeCmd -f docker-compose.dev.yml up -d

# Wait for MySQL service healthy
Write-Host "Attente que MySQL soit healthy (max ~60s)..."
$retry = 0
$max = 30
while ($true) {
    try {
        $inspect = docker inspect --format='{{json .State.Health.Status}}' shop_mysql_dev 2>$null
        if ($inspect -match 'healthy') { Write-Ok "MySQL prêt"; break }
    } catch {}
    Start-Sleep -Seconds 2
    $retry++
    if ($retry -gt $max) { Write-Err "MySQL n'a pas démarré après 60s"; Write-Host "Consultez les logs: docker-compose -f docker-compose.dev.yml logs mysql"; exit 1 }
}

# Run composer & doctrine & fixtures inside backend container
Write-Ok "Installation dépendances backend..."
try {
    Write-Ok "Installation dépendances backend (sans scripts)..."
    # Installer sans exécuter les scripts automatiques qui peuvent nécessiter la DB
    & docker exec shop_backend_dev composer install --no-scripts --no-interaction --prefer-dist --optimize-autoloader
    Write-Ok "Dépendances backend installées (scripts différés)"

    Write-Ok "Vérification / création utilisateur MySQL si nécessaire..."
    $rootPw = ""
    $mysqlDb = ""
    $mysqlUser = ""
    $mysqlPw = ""
    try { $rootPw = (& docker exec shop_mysql_dev printenv MYSQL_ROOT_PASSWORD) -as [string] } catch {}
    try { $mysqlDb = (& docker exec shop_mysql_dev printenv MYSQL_DATABASE) -as [string] } catch {}
    try { $mysqlUser = (& docker exec shop_mysql_dev printenv MYSQL_USER) -as [string] } catch {}
    try { $mysqlPw = (& docker exec shop_mysql_dev printenv MYSQL_PASSWORD) -as [string] } catch {}

    if (-not $rootPw) { $rootPw = 'root_password' }
    if (-not $mysqlDb) { $mysqlDb = 'shop_db' }
    if (-not $mysqlUser) { $mysqlUser = 'shop_user' }
    if (-not $mysqlPw) { $mysqlPw = 'shop_password' }

    $canConnect = $false
    try {
        & docker exec shop_mysql_dev mysql -u"$mysqlUser" -p"$mysqlPw" -e "SELECT 1;" > $null 2>&1
        $canConnect = $true
    } catch {
        $canConnect = $false
    }

    if ($canConnect) {
        Write-Ok "L'utilisateur $mysqlUser peut se connecter à MySQL"
    } else {
        Write-Warn "L'utilisateur $mysqlUser ne peut pas se connecter. Tentative de création via root..."
        try {
            & docker exec shop_mysql_dev mysql -uroot -p"$rootPw" -e "CREATE USER IF NOT EXISTS '$mysqlUser'@'%' IDENTIFIED BY '$mysqlPw'; GRANT ALL PRIVILEGES ON \`$mysqlDb\`.* TO '$mysqlUser'@'%'; FLUSH PRIVILEGES;" > $null 2>&1
            Write-Ok "Utilisateur $mysqlUser créé / privilèges accordés"
        } catch {
            Write-Err "Impossible de créer l'utilisateur via root. Vous pouvez :"; 
            Write-Host "  - vérifier le mot de passe root dans vos variables d'environnement"; 
            Write-Host "  - ou réinitialiser le volume MySQL avec: docker-compose -f docker-compose.dev.yml down -v";
        }
    }

    Write-Ok "Création DB et exécution des migrations"
    & docker exec shop_backend_dev php bin/console doctrine:database:create --if-not-exists --no-interaction
    & docker exec shop_backend_dev php bin/console doctrine:migrations:migrate --no-interaction

    Write-Ok "Chargement des fixtures"
    & docker exec shop_backend_dev php bin/console doctrine:fixtures:load --no-interaction

    Write-Ok "Exécution des scripts post-install (via composer)"
    try {
        & docker exec shop_backend_dev composer run-script post-install-cmd > $null 2>&1
        Write-Ok "Scripts post-install exécutés via Composer"
    } catch {
        Write-Warn "composer run-script post-install-cmd a échoué, tentative d'exécution manuelle des commandes symfony..."
        # Tentatives manuelles (non-critiques)
        & docker exec shop_backend_dev php bin/console cache:clear --no-interaction 2>$null || Write-Warn "cache:clear a échoué"
        & docker exec shop_backend_dev php bin/console cache:warmup --no-interaction 2>$null || Write-Warn "cache:warmup a échoué"
        & docker exec shop_backend_dev php bin/console assets:install public --no-interaction 2>$null || Write-Warn "assets:install a échoué"
        & docker exec shop_backend_dev php bin/console importmap:install --no-interaction 2>$null || Write-Warn "importmap:install a échoué"
        Write-Ok "Tentative manuelle des scripts post-install terminée (erreurs non fatales ignorées)"
    }

    # Frontend deps
    Write-Ok "Installation dépendances frontend..."
    & docker exec shop_frontend_dev npm install --silent

    Write-Ok "Installation terminée. URLs : http://localhost (frontend), http://localhost/admin (backoffice), http://localhost/api"

} catch {
    Write-Err "Erreur durant l'installation : $_"
    exit 1
}

Write-Host "Fin du script"

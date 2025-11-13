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
docker exec shop_backend_dev composer install --no-interaction --prefer-dist --optimize-autoloader
Write-Ok "Composer installé"

Write-Ok "Création DB et migrations"
docker exec shop_backend_dev php bin/console doctrine:database:create --if-not-exists --no-interaction
docker exec shop_backend_dev php bin/console doctrine:migrations:migrate --no-interaction

Write-Ok "Chargement des fixtures"
docker exec shop_backend_dev php bin/console doctrine:fixtures:load --no-interaction

# Frontend deps
Write-Ok "Installation dépendances frontend..."
docker exec shop_frontend_dev npm install --silent

Write-Ok "Installation terminée. URLs : http://localhost (frontend), http://localhost/admin (backoffice), http://localhost/api"

Write-Host "Fin du script"

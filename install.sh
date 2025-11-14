#!/bin/bash
set -e

echo "🛍️  Installation de php_shop - Mini E-Commerce Fullstack"
echo "=========================================================="
echo ""

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo "ℹ️  $1"; }

# Vérifier les prérequis
print_info "Vérification des prérequis..."

if ! command -v docker &> /dev/null; then
    print_error "Docker n'est pas installé. Installez Docker : https://docs.docker.com/get-docker/"
    exit 1
fi

# Détecter la commande docker-compose (v1) ou docker compose (v2)
DOCKER_COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
fi

if [ -z "$DOCKER_COMPOSE_CMD" ]; then
    print_error "Docker Compose n'est pas disponible (ni 'docker-compose' ni 'docker compose'). Installez Docker Compose ou utilisez Docker Desktop qui inclut 'docker compose'."
    exit 1
fi

print_success "Docker trouvé et commande compose: $DOCKER_COMPOSE_CMD"

# Vérifier utilitaires utiles (lsof/jq/netstat)
MISSING_TOOLS=()
if ! command -v lsof &> /dev/null; then
    MISSING_TOOLS+=(lsof)
fi
if ! command -v jq &> /dev/null; then
    MISSING_TOOLS+=(jq)
fi
if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    print_warning "Outils recommandés manquants: ${MISSING_TOOLS[*]}"
    print_warning "Sur mac: brew install lsof jq   | Sur Debian/Ubuntu: sudo apt install lsof jq"
fi

# Vérifier les ports
print_info "Vérification des ports disponibles..."

check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        print_warning "Le port $port est déjà utilisé"
        read -p "Continuer quand même ? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Port $port disponible"
    fi
}

check_port 80
check_port 3000
check_port 3307

# Copier les fichiers d'environnement depuis les templates .dist
print_info "Configuration des fichiers d'environnement..."

if [ ! -f .env ]; then
    cp .env.dist .env
    print_success ".env créé depuis .env.dist"
else
    print_warning ".env existe déjà, conservation des valeurs locales"
fi

if [ ! -f backend/.env ]; then
    cp backend/.env.dist backend/.env
    print_success "backend/.env créé depuis backend/.env.dist"
else
    print_warning "backend/.env existe déjà, conservation des valeurs locales"
fi

if [ ! -f frontend/.env ]; then
    cp frontend/.env.dist frontend/.env
    print_success "frontend/.env créé depuis frontend/.env.dist"
else
    print_warning "frontend/.env existe déjà, conservation des valeurs locales"
fi

# Démarrer les services Docker
print_info "Démarrage des services Docker (MySQL, Backend, Frontend, Nginx)..."
docker-compose -f docker-compose.dev.yml up -d

# Attendre MySQL avec health check robuste
print_info "Attente du démarrage de MySQL (avec health check)..."
RETRY=0
MAX_RETRY=30
until docker inspect --format='{{json .State.Health.Status}}' shop_mysql_dev 2>/dev/null | grep -q '"healthy"'; do
    RETRY=$((RETRY+1))
    if [ $RETRY -gt $MAX_RETRY ]; then
        print_error "MySQL n'a pas démarré après 60 secondes"
        print_info "Vérifiez les logs : docker-compose -f docker-compose.dev.yml logs mysql"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""
print_success "MySQL est prêt !"

# Installer les dépendances backend (sans exécuter les scripts Composer maintenant)
print_info "Installation des dépendances backend (composer install --no-scripts)..."
# Workaround: avoid OCI runtime exec failure when the host current directory
# is a mount point shared with the container. Some runtimes refuse to exec
# if the client's cwd is outside the container mount namespace.
# We temporarily change to /tmp on the host before calling docker exec.
OLD_PWD="$(pwd)"
cd /tmp || true
# IMPORTANT: use --no-scripts to éviter le cache:clear automatique qui exige la DB
docker exec shop_backend_dev composer install --no-scripts --no-interaction --prefer-dist --optimize-autoloader
print_success "Dépendances backend installées (scripts différés)"
cd "$OLD_PWD" || true

# Créer la base de données
print_info "Création de la base de données..."
## Avant de créer la BDD, vérifier que l'utilisateur MySQL configuré existe et peut se connecter.
print_info "Vérification de l'utilisateur MySQL et création si nécessaire..."
OLD_PWD="$(pwd)"
cd /tmp || true

# Récupérer les variables depuis le conteneur MySQL si elles existent, sinon utiliser des valeurs par défaut
ROOT_PW="$(docker exec shop_mysql_dev printenv MYSQL_ROOT_PASSWORD 2>/dev/null || true)"
MYSQL_DB="$(docker exec shop_mysql_dev printenv MYSQL_DATABASE 2>/dev/null || true)"
MYSQL_USER_ENV="$(docker exec shop_mysql_dev printenv MYSQL_USER 2>/dev/null || true)"
MYSQL_PW_ENV="$(docker exec shop_mysql_dev printenv MYSQL_PASSWORD 2>/dev/null || true)"

ROOT_PW="${ROOT_PW:-root_password}"
MYSQL_DB="${MYSQL_DB:-shop_db}"
MYSQL_USER_ENV="${MYSQL_USER_ENV:-shop_user}"
MYSQL_PW_ENV="${MYSQL_PW_ENV:-shop_password}"

print_info "Test de connexion MySQL en tant que ${MYSQL_USER_ENV}..."
if docker exec shop_mysql_dev mysql -u"${MYSQL_USER_ENV}" -p"${MYSQL_PW_ENV}" -e "SELECT 1;" >/dev/null 2>&1; then
    print_success "L'utilisateur ${MYSQL_USER_ENV} peut se connecter à MySQL"
else
    print_warning "L'utilisateur ${MYSQL_USER_ENV} ne peut pas se connecter. Tentative de création via root..."
    # Tenter de créer l'utilisateur et lui donner les privilèges requis (non destructif)
    if docker exec shop_mysql_dev mysql -uroot -p"${ROOT_PW}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER_ENV}'@'%' IDENTIFIED BY '${MYSQL_PW_ENV}'; GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO '${MYSQL_USER_ENV}'@'%'; FLUSH PRIVILEGES;" >/dev/null 2>&1; then
        print_success "Utilisateur ${MYSQL_USER_ENV} créé / privilèges accordés"
    else
        print_error "Impossible de créer l'utilisateur via root. Vous pouvez:"
        echo "  - vérifier le mot de passe root dans vos variables d'environnement" 
        echo "  - ou réinitialiser le volume MySQL avec: docker-compose -f docker-compose.dev.yml down -v"
        # ne pas quitter immédiatement — la commande suivante (doctrine:database:create) échouera si la création n'a pas fonctionné
    fi
fi

docker exec shop_backend_dev php bin/console doctrine:database:create --if-not-exists --no-interaction
print_success "Base de données créée"
cd "$OLD_PWD" || true

# Exécuter les migrations
print_info "Exécution des migrations..."
OLD_PWD="$(pwd)"
cd /tmp || true
docker exec shop_backend_dev php bin/console doctrine:migrations:migrate --no-interaction
print_success "Migrations exécutées"
cd "$OLD_PWD" || true

# Charger les fixtures
print_info "Chargement des fixtures (5 catégories + 20 produits)..."
OLD_PWD="$(pwd)"
cd /tmp || true
docker exec shop_backend_dev php bin/console doctrine:fixtures:load --no-interaction
print_success "Fixtures chargées"
cd "$OLD_PWD" || true

# Maintenant que la base et les données existent, exécuter les scripts Composer
# qui avaient été différés (cache:clear, assets:install, importmap:install, ...).
print_info "Exécution des scripts post-install (cache, assets, importmap)..."
OLD_PWD="$(pwd)"
cd /tmp || true
if docker exec shop_backend_dev composer run-script post-install-cmd >/dev/null 2>&1; then
    print_success "Scripts post-install exécutés via Composer"
else
    print_warning "composer run-script post-install-cmd a échoué, tentative d'exécution manuelle des commandes symfony..."
    # Nettoyer le répertoire assets existant pour éviter "Directory not empty"
    docker exec shop_backend_dev rm -rf public/bundles 2>/dev/null || true
    # Tentatives manuelles (non-critiques) — ignorer les erreurs individuelles
    docker exec shop_backend_dev php bin/console cache:clear --no-interaction || true
    docker exec shop_backend_dev php bin/console cache:warmup --no-interaction || true
    # Assets install avec retry en --force si échec
    if ! docker exec shop_backend_dev php bin/console assets:install public --no-interaction 2>/dev/null; then
        echo "⚠️  Réessai assets:install avec --force..."
        docker exec shop_backend_dev php bin/console assets:install public --no-interaction --force || true
    fi
    docker exec shop_backend_dev php bin/console importmap:install --no-interaction || true
    print_success "Tentative manuelle des scripts post-install terminée (erreurs non fatales ignorées)"
fi
cd "$OLD_PWD" || true

# Installer les dépendances frontend (optionnel, déjà fait au build)
print_info "Vérification des dépendances frontend..."
OLD_PWD="$(pwd)"
cd /tmp || true
docker exec shop_frontend_dev npm install --silent
print_success "Dépendances frontend à jour"
cd "$OLD_PWD" || true

# Résumé final
echo ""
echo "=========================================================="
print_success "Installation terminée avec succès ! 🎉"
echo "=========================================================="
echo ""
echo "📍 URLs d'accès :"
echo "   🎨 Frontend:    http://localhost"
echo "   🔐 Backoffice:  http://localhost/admin"
echo "   🔌 API:         http://localhost/api"
echo ""
echo "🔑 Identifiants backoffice :"
echo "   Utilisateur: admin"
echo "   Mot de passe: admin"
echo ""
echo "📊 Données chargées :"
echo "   - 5 catégories (Électronique, Vêtements, Alimentation, Maison & Jardin, Sports & Loisirs)"
echo "   - 20 produits avec descriptions Faker"
echo ""
echo "🧪 Lancer les tests :"
echo "   Backend:  docker exec shop_backend_dev php bin/phpunit"
echo "   Frontend: docker exec shop_frontend_dev npm test"
echo ""
echo "🛑 Arrêter l'environnement :"
echo "   docker-compose -f docker-compose.dev.yml down"
echo ""
echo "⚠️  Réinitialiser complètement (détruit les données) :"
echo "   docker-compose -f docker-compose.dev.yml down -v"
echo ""

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

# Copier les fichiers d'environnement
print_info "Configuration des fichiers d'environnement..."

if [ ! -f .env ]; then
    cp .env.dist .env
    print_success ".env créé"
else
    print_warning ".env existe déjà, conservation"
fi

if [ ! -f backend/.env ]; then
    cp backend/.env.dist backend/.env
    print_success "backend/.env créé"
else
    print_warning "backend/.env existe déjà, conservation"
fi

if [ ! -f frontend/.env ]; then
    cp frontend/.env.example frontend/.env
    print_success "frontend/.env créé"
else
    print_warning "frontend/.env existe déjà, conservation"
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

# Installer les dépendances backend
print_info "Installation des dépendances backend (composer install)..."
docker exec shop_backend_dev composer install --no-interaction --prefer-dist --optimize-autoloader
print_success "Dépendances backend installées"

# Créer la base de données
print_info "Création de la base de données..."
docker exec shop_backend_dev php bin/console doctrine:database:create --if-not-exists --no-interaction
print_success "Base de données créée"

# Exécuter les migrations
print_info "Exécution des migrations..."
docker exec shop_backend_dev php bin/console doctrine:migrations:migrate --no-interaction
print_success "Migrations exécutées"

# Charger les fixtures
print_info "Chargement des fixtures (5 catégories + 20 produits)..."
docker exec shop_backend_dev php bin/console doctrine:fixtures:load --no-interaction
print_success "Fixtures chargées"

# Installer les dépendances frontend (optionnel, déjà fait au build)
print_info "Vérification des dépendances frontend..."
docker exec shop_frontend_dev npm install --silent
print_success "Dépendances frontend à jour"

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

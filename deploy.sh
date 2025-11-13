#!/bin/bash

# Script de déploiement pour l'environnement de production
# Utilisation: ./deploy.sh [dev|prod]

set -e

ENV=${1:-prod}
COMPOSE_FILE="docker-compose.yml"

if [ "$ENV" = "dev" ]; then
    COMPOSE_FILE="docker-compose.dev.yml"
fi

echo "🚀 Déploiement en mode $ENV..."

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    cp .env.dist .env
    echo "✅ Fichier .env créé à partir de .env.dist"
    echo "⚠️  Pensez à modifier les mots de passe dans .env !"
fi

# Arrêter les services existants
echo "🛑 Arrêt des services existants..."
docker-compose -f $COMPOSE_FILE down

# Construire et démarrer les services
echo "🏗️  Construction des images..."
docker-compose -f $COMPOSE_FILE build --no-cache

echo "🚀 Démarrage des services..."
docker-compose -f $COMPOSE_FILE up -d

# Attendre que MySQL soit prêt
echo "⏳ Attente de MySQL..."
sleep 30

# Exécuter les migrations et fixtures dans le conteneur backend
echo "📦 Exécution des migrations..."
docker-compose -f $COMPOSE_FILE exec -T backend php bin/console doctrine:migrations:migrate --no-interaction

echo "📝 Chargement des fixtures..."
docker-compose -f $COMPOSE_FILE exec -T backend php bin/console doctrine:fixtures:load --no-interaction

# Nettoyer le cache de production
echo "🧹 Nettoyage du cache..."
docker-compose -f $COMPOSE_FILE exec -T backend php bin/console cache:clear

echo "✅ Déploiement terminé !"
echo ""
echo "📊 Services disponibles :"
echo "  - Backend API: http://localhost:8080"
echo "  - Frontend: http://localhost:3000"
echo "  - Admin: http://localhost:8080/admin"
echo "  - MySQL: localhost:3307"
echo ""
echo "📋 Commandes utiles :"
echo "  - Logs: docker-compose -f $COMPOSE_FILE logs -f"
echo "  - Arrêt: docker-compose -f $COMPOSE_FILE down"
echo "  - Redémarrage: docker-compose -f $COMPOSE_FILE restart"
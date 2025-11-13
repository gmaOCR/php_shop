#!/bin/bash

# Script pour démarrer le serveur PHP avec le bon routeur
# Usage: ./start-server.sh

cd "$(dirname "$0")"

# Arrêter les serveurs existants
pkill -f "php -S 127.0.0.1:8000" 2>/dev/null

echo "🔄 Vérification des assets EasyAdmin..."
php bin/console assets:install public --no-interaction

echo "🚀 Démarrage du serveur sur http://127.0.0.1:8000"
echo "📝 Logs disponibles dans /tmp/backend-server.log"
echo "🛑 Pour arrêter: pkill -f 'php -S 127.0.0.1:8000'"
echo ""
echo "✅ Serveur démarré avec succès!"
echo "   - Frontend: http://localhost:5173"
echo "   - Backend API: http://127.0.0.1:8000/api"
echo "   - Admin (EasyAdmin): http://127.0.0.1:8000/admin"
echo "   - Login: http://127.0.0.1:8000/login (admin/admin)"
echo ""

# Démarrer le serveur avec le routeur Symfony
nohup php -S 127.0.0.1:8000 -t public .htrouter.php > /tmp/backend-server.log 2>&1 &
SERVER_PID=$!

echo "🎯 PID du serveur: $SERVER_PID"
echo ""
echo "Appuyez sur Ctrl+C pour quitter ce script (le serveur continuera en arrière-plan)"

# Attendre pour voir les premiers logs
sleep 2
tail -5 /tmp/backend-server.log

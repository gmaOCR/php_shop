# 🛍️ Shop - Mini E-Commerce Fullstack

Application e-commerce fullstack moderne avec backend Symfony 6.4 + EasyAdmin et frontend React 18 + Vite.

## 🏗️ Architecture

- **Backend**: Symfony 6.4, MySQL 8, EasyAdmin, ApiPlatform
- **Frontend**: React 18, Vite, React Router, Axios, SASS
- **DevOps**: Docker Compose, Nginx reverse proxy
- **Tests**: PHPUnit (backend) + Vitest (frontend)

## 📋 Prérequis

- Docker et Docker Compose
- Git
- **Ports libres** : 80 (nginx), 3000 (frontend dev), 3307 (MySQL externe)

**C'est tout !** Docker gère PHP 8.2, Composer, Node.js, MySQL et Nginx.

⚠️ **Avant de commencer** : Assurez-vous que les ports 80, 3000 et 3307 ne sont pas utilisés par d'autres services.

## 🚀 Installation rapide (depuis git clone)

### 1. Cloner le projet

```bash
git clone https://github.com/gmaOCR/php_shop.git
cd php_shop
```

### 2. Démarrer l'environnement complet

```bash
# Copier les fichiers d'environnement
cp .env.dist .env
cp backend/.env.dist backend/.env
cp frontend/.env.example frontend/.env

# ⚠️ Note importante sur les variables d'environnement :
# - backend/.env contient DATABASE_URL pour usage local (hors Docker)
# - docker-compose.dev.yml OVERRIDE cette variable via environment:
# - Les containers utilisent les variables Docker, pas backend/.env

# Démarrer tous les services (MySQL, Backend, Frontend, Nginx)
docker-compose -f docker-compose.dev.yml up -d

# ⚠️ Si vous avez déjà lancé le projet et changé les credentials MySQL :
# Vous devrez supprimer le volume pour réinitialiser MySQL (DÉTRUIT LES DONNÉES) :
# docker-compose -f docker-compose.dev.yml down -v
# puis relancer : docker-compose -f docker-compose.dev.yml up -d

# Attendre que MySQL soit prêt avec health check (recommandé)
echo "Attente du démarrage de MySQL..."
until docker inspect --format='{{json .State.Health.Status}}' shop_mysql_dev | grep -q '"healthy"'; do
  echo -n "."
  sleep 2
done
echo " MySQL prêt !"

# Alternative simple (moins robuste) : sleep 15

# Installer les dépendances backend et créer la base
docker exec shop_backend_dev composer install
docker exec shop_backend_dev php bin/console doctrine:database:create --if-not-exists
docker exec shop_backend_dev php bin/console doctrine:migrations:migrate --no-interaction
docker exec shop_backend_dev php bin/console doctrine:fixtures:load --no-interaction

# Installer les dépendances frontend (déjà fait au build mais au cas où)
docker exec shop_frontend_dev npm install
```

### 3. C'est prêt ! 🎉

Accédez à l'application :
- 🎨 **Frontend**: http://localhost
- 🔐 **Admin EasyAdmin**: http://localhost/admin
- 🔌 **API**: http://localhost/api

**Identifiants backoffice** :
- Utilisateur: `admin`
- Mot de passe: `admin`

## 📦 Scripts reproductibles (conformité instructions)

### Backend

```bash
# Installation des dépendances
cd backend
composer install

# Configuration
cp .env.dist .env
# Éditer .env et configurer DATABASE_URL si nécessaire

# Création de la base et migrations
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction

# Charger les fixtures (données de test avec Faker)
php bin/console doctrine:fixtures:load --no-interaction
```

### Frontend

```bash
# Installation des dépendances
cd frontend
npm install

# Configuration
cp .env.example .env

# Démarrage du serveur de développement
npm run dev

# Lancer les tests
npm test
```

## 🎯 Commandes Docker utiles

```bash
# Démarrer l'environnement
docker-compose -f docker-compose.dev.yml up -d

# Arrêter l'environnement (conserve les données)
docker-compose -f docker-compose.dev.yml down

# Arrêter et SUPPRIMER les volumes (⚠️ DÉTRUIT LES DONNÉES MySQL)
docker-compose -f docker-compose.dev.yml down -v

# Voir les logs en temps réel
docker-compose -f docker-compose.dev.yml logs -f

# Voir les logs d'un service spécifique
docker-compose -f docker-compose.dev.yml logs -f backend

# Vérifier l'état de santé de MySQL
docker inspect --format='{{json .State.Health}}' shop_mysql_dev | jq

# Accéder au container backend
docker exec -it shop_backend_dev bash

# Accéder au container frontend  
docker exec -it shop_frontend_dev sh

# Recréer l'environnement (nettoie tout et rebuild)
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d --build
```

## 🧪 Lancer les tests

### Tests backend (PHPUnit)

```bash
# Dans le container backend
docker exec shop_backend_dev php bin/phpunit

# Avec coverage (si xdebug activé)
docker exec shop_backend_dev php bin/phpunit --coverage-text

# Tests spécifiques
docker exec shop_backend_dev php bin/phpunit tests/Entity/ProductTest.php
```

### Tests frontend (Vitest)

```bash
# Dans le container frontend
docker exec shop_frontend_dev npm test

# Mode watch (relance automatique)
docker exec shop_frontend_dev npm run test:watch

# Avec UI interactive
docker exec shop_frontend_dev npm run test:ui
```

### Résultats attendus

- **Backend** : 2 test files, 11 assertions (ProductCrudTest, ApiProductTest)
- **Frontend** : 2 test files, 9 tests (ProductCard 6/6, CategoryList 3/3)
docker-compose -f docker-compose.dev.yml up -d --build
```

## 🧪 Tests

### Backend (PHPUnit)

\`\`\`bash
cd backend
php bin/phpunit
\`\`\`

### Frontend (Vitest + RTL)

\`\`\`bash
cd frontend
npm test
\`\`\`

## 🏁 CI/CD

Les tests automatisés s'exécutent via GitHub Actions sur chaque push/PR (voir `.github/workflows/ci.yml`)

**Pipeline** :
1. **Backend Tests** : PHPUnit avec MySQL en service
2. **Frontend Tests** : Vitest + Build production
3. **Docker Build** : Validation des images Docker
4. **Fake Deploy** : Simulation de déploiement (branches main/master uniquement)

Le pipeline génère également des artifacts (build frontend) et un résumé de déploiement.

## 📦 Données de test

Les fixtures créent automatiquement:
- 5 catégories (Électronique, Vêtements, Alimentation, Livres, Sport)
- 20 produits avec descriptions Faker
- Produits répartis dans les catégories
- Prix aléatoires entre 10€ et 1000€
- Statuts online/offline aléatoires

## 🔒 Sécurité

- Authentification admin par firewall Symfony (ROLE_ADMIN)
- API publique GET-only (lecture seule)
- Validation des données côté serveur (constraints Doctrine)
- CORS configuré pour localhost
- Pas de secrets dans le repo (voir .env.dist)

## 📁 Structure du projet

\`\`\`
php_shop/
├── backend/          # Application Symfony
│   ├── src/
│   │   ├── Entity/          # Category, Product
│   │   ├── Repository/
│   │   ├── Controller/
│   │   │   ├── Admin/       # EasyAdmin controllers
│   │   │   └── Api/         # Custom API controllers
│   │   └── DataFixtures/
│   ├── migrations/
│   ├── tests/
│   └── config/
├── frontend/         # Application React
│   ├── src/
│   │   ├── api/            # Client Axios
│   │   ├── components/     # CategoryList, ProductCard
│   │   ├── pages/          # Categories, ProductsByCategory, ProductDetail
│   │   ├── tests/          # Tests Vitest
│   │   └── styles/
│   └── public/
├── docker-compose.yml
└── .github/workflows/ci.yml
\`\`\`

## 📝 Notes de développement

- **PSR-12** respecté pour PHP
- **ESLint** + **Prettier** pour React
- Commits atomiques avec préfixes conventionnels (feat:, fix:, chore:)
- Tests unitaires et fonctionnels
- Responsive design (mobile-friendly)

### Scripts utiles

**Backend**:
- `./start-server.sh` - Démarre le serveur avec assets installés
- `php bin/console cache:clear` - Vider le cache
- `php bin/console debug:router` - Lister les routes
- `php bin/console doctrine:fixtures:load` - Recharger les fixtures

**Frontend**:
- `npm run dev` - Serveur de développement
- `npm run build` - Build production
- `npm run preview` - Prévisualiser le build
- `npm run lint` - Linter ESLint

## 📚 Documentation supplémentaire

- `SECURITY_PRODUCTION.md` - Guide de sécurité pour la production
- `GIT_SECURITY_HISTORY.md` - Info sur l'historique Git et les secrets
- `.github/instructions/shop.instructions.md` - Instructions détaillées du projet

---

**Livrable**: Repo Git fonctionnel avec backend, frontend, fixtures, tests, CI/CD et documentation complète.

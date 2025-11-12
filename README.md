# Test technique — Mini catalogue de produits

Application fullstack (Symfony 6 + React 18) développée pour PROXIMITY.

## 🏗️ Architecture

- **Backend**: Symfony 6.4, MySQL 8, EasyAdmin, ApiPlatform
- **Frontend**: React 18, Vite, React Router, Axios, SASS
- **DevOps**: Docker Compose, GitHub Actions CI

## 📋 Prérequis

- PHP >= 8.2 avec extensions: pdo_mysql, mbstring, xml, intl, zip
- Composer
- Node.js >= 18 et npm
- Docker et Docker Compose

## 🚀 Installation

### 1. Cloner le projet

\`\`\`bash
git clone <repository-url>
cd php_shop
\`\`\`

### 2. Démarrer MySQL avec Docker

\`\`\`bash
docker-compose up -d
\`\`\`

### 3. Configurer le backend

\`\`\`bash
cd backend
composer install
cp .env.dist .env
# Vérifier que DATABASE_URL est correct dans .env
php bin/console doctrine:migrations:migrate --no-interaction
php bin/console doctrine:fixtures:load --no-interaction
\`\`\`

### 4. Configurer le frontend

\`\`\`bash
cd frontend
npm install
\`\`\`

## 🎯 Démarrage

### Backend (terminal 1)

\`\`\`bash
cd backend
php -S localhost:8000 -t public
\`\`\`

Ou avec Symfony CLI:
\`\`\`bash
symfony server:start
\`\`\`

### Frontend (terminal 2)

\`\`\`bash
cd frontend
npm run dev
\`\`\`

Le frontend sera accessible sur http://localhost:5173

## 🔐 Accès au backoffice

URL: http://localhost:8000/admin

Identifiants:
- **Utilisateur**: admin
- **Mot de passe**: admin

## 📡 API Endpoints

- \`GET /api/categories\` — Liste des catégories
- \`GET /api/categories/{id}/products\` — Produits par catégorie (paginé)
- \`GET /api/products\` — Tous les produits (paginé, filtrable)
- \`GET /api/products/{id}\` — Détail d'un produit

Documentation API complète: http://localhost:8000/api (interface ApiPlatform)

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

Les tests automatisés s'exécutent via GitHub Actions sur chaque push/PR (voir \`.github/workflows/ci.yml\`)

## 📦 Données de test

Les fixtures créent automatiquement:
- 5 catégories
- 20 produits avec descriptions Faker

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

---

**Livrable**: Repo Git fonctionnel avec backend, frontend, fixtures, tests et documentation complète.

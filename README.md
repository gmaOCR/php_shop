# 🛍️ Shop - Mini E-Commerce Fullstack

Application e-commerce fullstack moderne avec backend Symfony 6.4 + EasyAdmin et frontend React 18 + Vite.

[![CI](https://github.com/gmaOCR/php_shop/workflows/CI/badge.svg)](https://github.com/gmaOCR/php_shop/actions)

## 🏗️ Architecture

- **Backend**: Symfony 6.4, MySQL 8, EasyAdmin, ApiPlatform
- **Frontend**: React 18, Vite, React Router, Axios, SASS
- **DevOps**: Docker Compose, GitHub Actions CI
- **Tests**: PHPUnit (backend) + Vitest (frontend)

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

# IMPORTANT: Configurer le mot de passe admin
php bin/console security:hash-password YourSecurePassword
# Copier le hash généré dans .env: ADMIN_PASSWORD_HASH='$2y$13$...'

# Créer la base et charger les données
php bin/console doctrine:database:create --if-not-exists
php bin/console doctrine:migrations:migrate --no-interaction
php bin/console doctrine:fixtures:load --no-interaction
\`\`\`

### 4. Configurer le frontend

\`\`\`bash
cd frontend
npm install
cp .env.example .env
\`\`\`

## 🎯 Démarrage

### Backend (terminal 1)

```bash
cd backend
# Méthode recommandée avec Symfony CLI:
symfony server:start

# OU avec le script fourni:
./start-dev-server.sh

# OU manuellement avec PHP (déconseillé):
cd public
php -S 127.0.0.1:8000
```

**Note**: 
- **Symfony CLI est fortement recommandé** pour éviter les problèmes de double chargement
- Utiliser `127.0.0.1` au lieu de `localhost` pour éviter les problèmes CORS
- Voir `backend/TROUBLESHOOTING.md` pour les détails sur le problème "Cannot redeclare class"

### Frontend (terminal 2)

\`\`\`bash
cd frontend
npm run dev
\`\`\`

Le frontend sera accessible sur http://localhost:5173

### URLs d'accès

- 🎨 **Frontend**: http://localhost:5173
- 🔌 **API**: http://127.0.0.1:8000/api
- 📚 **API Docs**: http://127.0.0.1:8000/api (interface ApiPlatform)
- 🔐 **Admin EasyAdmin**: http://127.0.0.1:8000/admin

## 🔐 Accès au backoffice

URL: http://127.0.0.1:8000/admin

Identifiants par défaut (à changer en production!):
- **Utilisateur**: admin
- **Mot de passe**: celui configuré dans `.env` (par défaut: `admin`)

**⚠️ IMPORTANT - Sécurité Production**:
- Lire le guide complet : `SECURITY_PRODUCTION.md`
- Migrer vers une entité User en base de données
- Changer le mot de passe par défaut
- Ne jamais commiter `.env` avec des secrets

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

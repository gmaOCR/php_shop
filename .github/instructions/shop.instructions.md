# INSTRUCTIONS POUR COPILOT / DÉVELOPPEUR

Langue: Français

Objectif: produire un mini-produit complet (backend Symfony 6+, MySQL, EasyAdmin, ApiPlatform; frontend React ≥17) — backoffice CRUD produit/catégorie, API lecture-only publique, front catalogue & détail.

Règles générales
- Reste simple et sécurisé.
- Respecte les scripts reproductibles (composer install, bin/console doctrine:migrations:migrate, npm/yarn install + npm/yarn dev).
- Ne commite jamais de secrets. Ajouter `.env.dist` et documenter les variables nécessaires.

Contrat minimal (inputs/outputs)
- Inputs : base de données MySQL (DATABASE_URL), php >= 8.2, node >= 16.
- Outputs : repo Git fonctionnel avec backend et frontend séparés, fixtures, documentation API, tests unitaires, CI basique.

Données et entités
- Category
  - id (int)
  - name (string)

- Product
  - id (int)
  - name (string)
  - description (text)
  - price (decimal 10,2)
  - status (enum/string: online|offline)
  - category (ManyToOne → Category)

API (lecture publique)
- GET /api/categories → liste des catégories (id, name)
- GET /api/categories/{id}/products → liste des produits d'une catégorie (paged)
- GET /api/products → liste de tous les produits (paged + filtres optionnels: status, category)
- GET /api/products/{id} → détail produit

Backoffice (admin)
- Utiliser EasyAdmin (recommandé) pour fournir :
  - Liste, création, édition, suppression de Category
  - Liste, création, édition, suppression de Product
- Restreindre l'accès au backoffice par authentification (ROLE_ADMIN). Une authentification simple (user/password en mémoire ou provider basé sur doctrine) suffit pour le test.

Tech stack & paquets conseillés
- Backend: Symfony 6.x, Doctrine ORM, MakerBundle, EasyAdmin, ApiPlatform (pour auto-génération d'API), DoctrineFixturesBundle, NelmioCorsBundle (config CORS), symfony/security-bundle
- Frontend: React 17+, Vite ou Create React App, react-router, axios/fetch, React Testing Library + Jest, SASS/SCSS
- DevOps: Docker + docker-compose pour DB + services (optionnel mais fortement apprécié)

Sécurité (essentiels, simple & conforme)
- Ne pas commiter de `.env` contenant des secrets. Fournir `.env.dist` avec exemples.
- Protéger le backoffice avec un firewall Symfony : authentification + rôle ROLE_ADMIN.
- Valider et sanitizer les données côté serveur (constraints sur l'entité : NotBlank, Length, Positive pour price).
- Pour l'API publique en lecture seule : limiter méthodes HTTP (GET seulement), config CORS minimale (origins list), désactiver les endpoints de modification publics.
- Configurer le Content Security Policy si possible sur front (simple recommandation dans docs).
- Utiliser les types scalaires stricts et déclarations dans PHP 8.2.

Tests demandés
- Backend (PHPUnit) :
  - Tests unitaires pour l'entité Product (validation constraints).
  - Tests fonctionnels pour l'API (WebTestCase) : vérifier GET /api/products et /api/products/{id} répond 200 et schéma minimal.
  - Fixtures (DoctrineFixturesBundle) + loader avec Faker pour 20 products et 5 categories.
- Frontend (Jest + React Testing Library) :
  - Test composant CategoryList : affiche des catégories passées en props.
  - Test composant ProductCard : affiche nom, prix et état.
- E2E (optionnel) : Cypress test basique : afficher la page catalogue et voir 1 produit.

CI (GitHub Actions minimal)
- job: install PHP deps, run phpunit
- job: install node deps, run frontend tests

Docker (optionnel mais demandé)
- Fournir `docker-compose.yml` comprenant :
  - mysql: image mysql:8, vars root password, database
  - php service (optionnel) ou instructions pour utiliser l'environnement local

Structure recommandée du repo
- /backend (Symfony app)
  - composer.json
  - .env.dist
  - src/Entity/Category.php
  - src/Entity/Product.php
  - src/Repository/...
  - migrations/
  - config/packages/easy_admin.yaml
  - config/packages/api_platform.yaml
  - tests/ (PHPUnit)
  - fixtures/
- /frontend (React app)
  - package.json
  - src/
    - App.jsx
    - pages/Categories.jsx
    - pages/ProductsByCategory.jsx
    - pages/ProductDetail.jsx
    - components/CategoryList.jsx
    - components/ProductCard.jsx
  - src/styles/main.scss

Scripts & commandes (dev)
- Backend (dans /backend):
  - composer install
  - cp .env.dist .env
  - bin/console doctrine:database:create --if-not-exists
  - bin/console doctrine:migrations:migrate
  - bin/console doctrine:fixtures:load --no-interaction
  - symfony server:start (optionnel)
- Frontend (dans /frontend):
  - npm install
  - npm run dev
  - npm run test

Exemples de tests (à créer)
- tests/Entity/ProductTest.php (PHPUnit) :
  - assertion que la validation échoue si name vide, price négatif.
- tests/Controller/ApiProductTest.php (WebTestCase) :
  - testIndexProducts(): requête GET /api/products → 200, JSON contient items

Bonnes pratiques de code et revue
- Respecter la PSR-12 pour PHP.
- Utiliser l'auto-formatter (php-cs-fixer) et eslint + prettier pour frontend.
- Petits commits atomiques + messages clairs (feat:, fix:, chore:).

Edge cases à couvrir
- Produit sans catégorie (interdire si business l'exige, sinon afficher 'Sans catégorie').
- Prix à 0 ou négatif (validation Positive).
- Recherche/tri sur catalogue vide (retourner liste vide avec code 200).

Documentation API
- Rédiger un petit README_API.md ou utiliser la doc d'ApiPlatform (openapi). Inclure exemples de réponses JSON.

Vérification / Critères d'acceptation
- Le reviewer peut lancer les commandes listées et voir :
  - backend démarré (ou migrations appliquées)
  - fixtures chargées
  - frontend démarré et consommant l'API (au moins en local)
  - tests unitaires e2e unit passent en CI

Priorité de livraison (MVP simple)
1. Entités + migrations + fixtures
2. API publique GET endpoints (ApiPlatform ou controllers)
3. EasyAdmin backoffice CRUD (protégé)
4. Front React : pages catalogue & detail
5. Tests unitaires et fonctionnels
6. Docker + CI + documentation

Exemple de tâches que Copilot peut générer (issue templates)
- Create Product entity + migration
- Create Category entity + migration
- Configure ApiPlatform resources for Product/Category
- Add fixtures using Faker
- Install & configure EasyAdmin for Product/Category
- Build React pages and components and wire to API
- Add PHPUnit tests for API and entities
- Add Jest tests for components

Remarques finales
- Rester minimal et livré propre : privilégier code lisible et sécurisé plutôt que features secondaires.
- Si l'on manque de temps, livrer backend complet + fixtures + API docs, et un frontend minimal list/detail.

Bonne implémentation — tu peux commencer par créer l'arborescence `/backend` et `/frontend` et compléter étape par étape selon la priorité ci-dessus.

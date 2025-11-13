# Guide de Test Docker - Shop Application

## ✅ **Environnement Développement - TEST RÉUSSI**

### **Services Déployés**
- ✅ MySQL 8.0 (port 3307)
- ✅ Backend PHP-FPM + Symfony (via Nginx port 8080)
- ✅ Frontend React + Vite (port 3000)
- ✅ Nginx reverse proxy (port 8080)

### **Tests Effectués**

#### 1. **API Backend**
```bash
curl http://localhost:8080/api/products
```
**Résultat** : ✅ 20 produits chargés avec fixtures, API Platform fonctionne

```bash
curl http://localhost:8080/api/categories
```
**Résultat** : ✅ 5 catégories disponibles

#### 2. **Frontend React**
```bash
curl http://localhost:3000
```
**Résultat** : ✅ Application React servie avec Vite en mode dev

#### 3. **Base de Données**
```bash
docker-compose -f docker-compose.dev.yml exec mysql mysql -u shop_user -pshoppass123 -e "SHOW DATABASES;"
```
**Résultat** : ✅ Base `shop_db` créée avec tables

---

## 🚀 **Tests Manuels Recommandés**

### **A. Tester l'API Backend**

#### 1. Liste des produits
```bash
curl -s http://localhost:8080/api/products | jq '.member[0]'
```
**Attendu** : JSON avec détails du premier produit

#### 2. Produit spécifique
```bash
curl -s http://localhost:8080/api/products/1 | jq
```
**Attendu** : Détails complets du produit ID 1

#### 3. Produits d'une catégorie
```bash
curl -s http://localhost:8080/api/categories/1/products | jq '.member | length'
```
**Attendu** : Nombre de produits dans la catégorie 1

#### 4. Filtrage par statut
```bash
curl -s "http://localhost:8080/api/products?status=online" | jq '.totalItems'
```
**Attendu** : Nombre de produits en ligne

### **B. Tester le Frontend React**

#### 1. Page d'accueil
```bash
# Ouvrir dans le navigateur
http://localhost:3000
```
**Attendu** : Interface React chargée

#### 2. Vérifier le hot reload
```bash
# Modifier un fichier dans frontend/src/
# Le navigateur doit se recharger automatiquement
```

### **C. Tester le Backoffice Admin**

#### 1. Accès à l'admin
```bash
# Ouvrir dans le navigateur
http://localhost:8080/admin
```
**Attendu** : Page de connexion ou dashboard EasyAdmin

#### 2. Connexion (si authentification configurée)
- Email: admin@example.com
- Mot de passe: admin123

### **D. Tester la Base de Données**

#### 1. Connexion directe
```bash
docker-compose -f docker-compose.dev.yml exec mysql \
  mysql -u shop_user -pshoppass123 shop_db \
  -e "SELECT COUNT(*) as total FROM product;"
```
**Attendu** : 20 produits

#### 2. Vérifier les catégories
```bash
docker-compose -f docker-compose.dev.yml exec mysql \
  mysql -u shop_user -pshoppass123 shop_db \
  -e "SELECT * FROM category;"
```
**Attendu** : 5 catégories

---

## 🏭 **Test de l'Environnement Production**

### **1. Arrêter l'environnement dev**
```bash
docker-compose -f docker-compose.dev.yml down
```

### **2. Construire et démarrer la production**
```bash
# Construction des images
docker-compose build --no-cache

# Démarrage des services
docker-compose up -d

# Attendre que MySQL soit prêt
sleep 30

# Copier vendor dans le conteneur backend
docker cp backend/vendor shop_backend:/var/www/html/

# Exécuter les migrations
docker-compose exec backend php bin/console doctrine:migrations:migrate --no-interaction

# Charger les fixtures
docker-compose exec backend php bin/console doctrine:fixtures:load --no-interaction

# Corriger les permissions
docker-compose exec backend chown -R www-data:www-data /var/www/html/var
```

### **3. Tests API Production**
```bash
# Tester l'API
curl -s http://localhost:8080/api/products | jq '.totalItems'

# Tester une catégorie
curl -s http://localhost:8080/api/categories/1 | jq '.name'
```

### **4. Tests Frontend Production**
```bash
# Ouvrir dans le navigateur
http://localhost:3000
```
**Attendu** : Application React buildée et servie par Nginx

---

## 📊 **Vérification de l'État des Services**

### **Voir tous les conteneurs**
```bash
docker ps --filter "name=shop_"
```

### **Logs en temps réel**
```bash
# Tous les services
docker-compose -f docker-compose.dev.yml logs -f

# Service spécifique
docker-compose -f docker-compose.dev.yml logs -f backend
docker-compose -f docker-compose.dev.yml logs -f frontend
docker-compose -f docker-compose.dev.yml logs -f nginx
docker-compose -f docker-compose.dev.yml logs -f mysql
```

### **Vérifier la santé de MySQL**
```bash
docker inspect shop_mysql_dev | jq '.[0].State.Health'
```

---

## 🔧 **Commandes de Dépannage**

### **Redémarrer un service**
```bash
docker-compose -f docker-compose.dev.yml restart backend
```

### **Accéder à un conteneur**
```bash
# Backend
docker-compose -f docker-compose.dev.yml exec backend sh

# MySQL
docker-compose -f docker-compose.dev.yml exec mysql bash

# Frontend
docker-compose -f docker-compose.dev.yml exec frontend sh
```

### **Nettoyer complètement**
```bash
# Arrêter et supprimer volumes
docker-compose -f docker-compose.dev.yml down -v

# Supprimer les images
docker-compose -f docker-compose.dev.yml down --rmi all

# Tout nettoyer
docker system prune -a --volumes
```

---

## 📋 **Checklist de Validation**

### Développement
- [x] MySQL démarre et est healthy
- [x] Backend PHP-FPM démarre
- [x] Nginx sert les requêtes backend
- [x] Frontend Vite démarre avec hot reload
- [x] Migrations exécutées avec succès
- [x] Fixtures chargées (20 produits, 5 catégories)
- [x] API `/api/products` répond avec JSON
- [x] API `/api/categories` répond avec JSON
- [x] Frontend accessible sur port 3000
- [x] Admin accessible sur port 8080/admin

### Production (À tester)
- [ ] Images Docker construites
- [ ] Services démarrés en mode production
- [ ] API fonctionne en mode prod
- [ ] Frontend build servi par Nginx
- [ ] Performances optimisées (gzip, cache)
- [ ] Headers de sécurité actifs
- [ ] Pas de mode debug activé

---

## 🎯 **Tests d'Intégration Avancés**

### **1. Test de charge basique**
```bash
# Installer Apache Bench si nécessaire
# sudo apt-get install apache2-utils

ab -n 100 -c 10 http://localhost:8080/api/products
```

### **2. Test des filtres API**
```bash
# Par catégorie
curl "http://localhost:8080/api/products?category=1"

# Par statut
curl "http://localhost:8080/api/products?status=online"

# Combiné
curl "http://localhost:8080/api/products?status=online&category=2"
```

### **3. Test de pagination**
```bash
# Page 1
curl "http://localhost:8080/api/products?page=1"

# Page 2
curl "http://localhost:8080/api/products?page=2"
```

---

## ✅ **Résumé des URLs de Test**

| Service | URL | Description |
|---------|-----|-------------|
| API Products | http://localhost:8080/api/products | Liste des produits |
| API Categories | http://localhost:8080/api/categories | Liste des catégories |
| API Product Detail | http://localhost:8080/api/products/{id} | Détail d'un produit |
| API Category Products | http://localhost:8080/api/categories/{id}/products | Produits d'une catégorie |
| Frontend | http://localhost:3000 | Application React |
| Admin | http://localhost:8080/admin | Backoffice EasyAdmin |
| MySQL | localhost:3307 | Base de données (user: shop_user, pass: shoppass123) |

---

## 🚨 **Problèmes Connus et Solutions**

### **Problème : Port déjà utilisé**
```bash
# Changer les ports dans docker-compose.yml
ports:
  - "8081:80"  # au lieu de 8080
```

### **Problème : Permissions var/cache**
```bash
docker-compose exec backend chown -R www-data:www-data /var/www/html/var
```

### **Problème : vendor manquant**
```bash
# En dev
docker cp backend/vendor shop_backend_dev:/var/www/html/

# En prod
docker cp backend/vendor shop_backend:/var/www/html/
```

### **Problème : Base de données non créée**
```bash
docker-compose exec backend php bin/console doctrine:database:create
docker-compose exec backend php bin/console doctrine:migrations:migrate --no-interaction
```
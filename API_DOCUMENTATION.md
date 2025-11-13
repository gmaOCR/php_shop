# 📚 Documentation API

## Vue d'ensemble

API REST en lecture seule (GET) pour accéder aux catégories et produits. L'API utilise ApiPlatform avec le format JSON-LD.

**Base URL** : `http://127.0.0.1:8000/api`

## Authentification

❌ **Aucune authentification requise** - L'API est publique en lecture seule.

## Format des réponses

Toutes les réponses utilisent le format JSON-LD d'ApiPlatform avec la clé `member` pour les collections.

## Endpoints

### 1. Liste des catégories

Récupère toutes les catégories disponibles.

```http
GET /api/categories
```

**Réponse** :

```json
{
  "@context": "/api/contexts/Category",
  "@id": "/api/categories",
  "@type": "hydra:Collection",
  "member": [
    {
      "@id": "/api/categories/1",
      "@type": "Category",
      "id": 1,
      "name": "Électronique"
    },
    {
      "@id": "/api/categories/2",
      "@type": "Category",
      "id": 2,
      "name": "Vêtements"
    }
  ],
  "hydra:totalItems": 5
}
```

**Exemple cURL** :

```bash
curl http://127.0.0.1:8000/api/categories
```

---

### 2. Détail d'une catégorie

Récupère les informations d'une catégorie spécifique.

```http
GET /api/categories/{id}
```

**Paramètres** :
- `id` (integer, requis) : Identifiant de la catégorie

**Réponse** :

```json
{
  "@context": "/api/contexts/Category",
  "@id": "/api/categories/1",
  "@type": "Category",
  "id": 1,
  "name": "Électronique"
}
```

**Exemple cURL** :

```bash
curl http://127.0.0.1:8000/api/categories/1
```

---

### 3. Produits d'une catégorie

Récupère tous les produits d'une catégorie spécifique (paginés).

```http
GET /api/categories/{id}/products
```

**Paramètres** :
- `id` (integer, requis) : Identifiant de la catégorie

**Query Parameters** :
- `page` (integer, optionnel) : Numéro de page (défaut: 1)
- `itemsPerPage` (integer, optionnel) : Nombre d'items par page (défaut: 10, max: 30)

**Réponse** :

```json
{
  "@context": "/api/contexts/Product",
  "@id": "/api/categories/1/products",
  "@type": "hydra:Collection",
  "member": [
    {
      "@id": "/api/products/1",
      "@type": "Product",
      "id": 1,
      "name": "Smartphone XZ Pro",
      "description": "Dernier modèle avec appareil photo 108MP et écran AMOLED",
      "price": "699.99",
      "status": "online",
      "category": {
        "@id": "/api/categories/1",
        "id": 1,
        "name": "Électronique"
      }
    }
  ],
  "hydra:totalItems": 5,
  "hydra:view": {
    "@id": "/api/categories/1/products?page=1",
    "@type": "hydra:PartialCollectionView",
    "hydra:first": "/api/categories/1/products?page=1",
    "hydra:last": "/api/categories/1/products?page=1",
    "hydra:next": "/api/categories/1/products?page=2"
  }
}
```

**Exemple cURL** :

```bash
# Première page
curl "http://127.0.0.1:8000/api/categories/1/products"

# Deuxième page avec 20 items
curl "http://127.0.0.1:8000/api/categories/1/products?page=2&itemsPerPage=20"
```

---

### 4. Liste de tous les produits

Récupère tous les produits avec pagination et filtres optionnels.

```http
GET /api/products
```

**Query Parameters** :
- `page` (integer, optionnel) : Numéro de page (défaut: 1)
- `itemsPerPage` (integer, optionnel) : Nombre d'items par page (défaut: 10, max: 30)
- `status` (string, optionnel) : Filtrer par statut (`online` ou `offline`)
- `category` (integer, optionnel) : Filtrer par ID de catégorie

**Réponse** :

```json
{
  "@context": "/api/contexts/Product",
  "@id": "/api/products",
  "@type": "hydra:Collection",
  "member": [
    {
      "@id": "/api/products/1",
      "@type": "Product",
      "id": 1,
      "name": "Smartphone XZ Pro",
      "description": "Dernier modèle avec appareil photo 108MP",
      "price": "699.99",
      "status": "online",
      "category": {
        "@id": "/api/categories/1",
        "id": 1,
        "name": "Électronique"
      }
    }
  ],
  "hydra:totalItems": 20,
  "hydra:view": {
    "@id": "/api/products?page=1",
    "@type": "hydra:PartialCollectionView",
    "hydra:first": "/api/products?page=1",
    "hydra:last": "/api/products?page=2",
    "hydra:next": "/api/products?page=2"
  }
}
```

**Exemples cURL** :

```bash
# Tous les produits
curl "http://127.0.0.1:8000/api/products"

# Produits en ligne uniquement
curl "http://127.0.0.1:8000/api/products?status=online"

# Produits de la catégorie 1
curl "http://127.0.0.1:8000/api/products?category=1"

# Combinaison de filtres
curl "http://127.0.0.1:8000/api/products?status=online&category=1&page=1&itemsPerPage=20"
```

---

### 5. Détail d'un produit

Récupère les informations complètes d'un produit spécifique.

```http
GET /api/products/{id}
```

**Paramètres** :
- `id` (integer, requis) : Identifiant du produit

**Réponse** :

```json
{
  "@context": "/api/contexts/Product",
  "@id": "/api/products/1",
  "@type": "Product",
  "id": 1,
  "name": "Smartphone XZ Pro",
  "description": "Dernier modèle avec appareil photo 108MP, écran AMOLED 6.7\", 12GB RAM, 256GB stockage. Livré avec chargeur rapide 65W.",
  "price": "699.99",
  "status": "online",
  "category": {
    "@id": "/api/categories/1",
    "id": 1,
    "name": "Électronique"
  }
}
```

**Exemple cURL** :

```bash
curl http://127.0.0.1:8000/api/products/1
```

---

## Codes de statut HTTP

- `200 OK` : Requête réussie
- `404 Not Found` : Ressource introuvable
- `405 Method Not Allowed` : Méthode HTTP non autorisée (POST, PUT, DELETE non supportés)

## Limites et contraintes

### Pagination

- **Par défaut** : 10 items par page
- **Maximum** : 30 items par page
- Utilisez les liens `hydra:next`, `hydra:previous`, `hydra:first`, `hydra:last` pour naviguer

### Filtres

Les filtres disponibles :

| Endpoint | Filtres supportés |
|----------|-------------------|
| `/api/products` | `status` (exact), `category` (exact) |
| `/api/categories/{id}/products` | Aucun (filtre implicite par catégorie) |

### Méthodes HTTP

- ✅ **GET** : Autorisé (lecture seule)
- ❌ **POST, PUT, PATCH, DELETE** : Non autorisés (API publique en lecture seule)

## Modèles de données

### Category

```typescript
{
  id: number;           // Identifiant unique
  name: string;         // Nom de la catégorie (2-255 caractères)
}
```

### Product

```typescript
{
  id: number;           // Identifiant unique
  name: string;         // Nom du produit (2-255 caractères)
  description: string;  // Description détaillée
  price: string;        // Prix en euros (format décimal: "699.99")
  status: string;       // Statut: "online" | "offline"
  category: {           // Catégorie associée
    id: number;
    name: string;
  }
}
```

## CORS

L'API accepte les requêtes cross-origin depuis :
- `http://localhost:*`
- `http://127.0.0.1:*`

En production, configurez `CORS_ALLOW_ORIGIN` dans `.env`.

## Interface Swagger

ApiPlatform génère automatiquement une interface Swagger interactive :

**URL** : http://127.0.0.1:8000/api

Vous pouvez tester directement les endpoints depuis cette interface.

## Exemples d'intégration

### JavaScript (Fetch)

```javascript
// Récupérer toutes les catégories
fetch('http://127.0.0.1:8000/api/categories')
  .then(response => response.json())
  .then(data => {
    const categories = data.member || data['hydra:member'] || [];
    console.log(categories);
  });

// Récupérer un produit
fetch('http://127.0.0.1:8000/api/products/1')
  .then(response => response.json())
  .then(product => console.log(product));
```

### JavaScript (Axios)

```javascript
import axios from 'axios';

const API_BASE_URL = 'http://127.0.0.1:8000/api';

// Récupérer les produits filtrés
const getProducts = async (filters = {}) => {
  const response = await axios.get(`${API_BASE_URL}/products`, {
    params: filters
  });
  return response.data.member || response.data['hydra:member'] || [];
};

// Utilisation
const products = await getProducts({ status: 'online', page: 1 });
```

### PHP (Guzzle)

```php
use GuzzleHttp\Client;

$client = new Client(['base_uri' => 'http://127.0.0.1:8000/api']);

// Récupérer les catégories
$response = $client->get('/categories');
$data = json_decode($response->getBody(), true);
$categories = $data['member'] ?? [];

// Récupérer un produit
$response = $client->get('/products/1');
$product = json_decode($response->getBody(), true);
```

### Python (Requests)

```python
import requests

API_BASE_URL = 'http://127.0.0.1:8000/api'

# Récupérer toutes les catégories
response = requests.get(f'{API_BASE_URL}/categories')
data = response.json()
categories = data.get('member', [])

# Récupérer les produits filtrés
params = {'status': 'online', 'category': 1}
response = requests.get(f'{API_BASE_URL}/products', params=params)
products = response.json().get('member', [])
```

## Support

Pour toute question sur l'API, consultez :
- Interface Swagger : http://127.0.0.1:8000/api
- Documentation ApiPlatform : https://api-platform.com/docs/
- Code source : `backend/src/Entity/` pour voir les modèles

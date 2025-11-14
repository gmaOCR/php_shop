import axios from 'axios';

// Détermine l'URL de base de l'API :
// - utilise VITE_API_BASE_URL si défini (déploiement ou .env)
// - sinon, construit une URL relative au origin courant (utile quand le frontend
//   est servi par le même host/nginx que l'API)
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL
  || (typeof window !== 'undefined' ? `${window.location.origin}/api` : 'http://127.0.0.1:8000/api');

/**
 * Client HTTP Axios configuré pour API Platform (JSON-LD/Hydra)
 * Low-level : utilisez-le pour des requêtes personnalisées
 */
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000, // 10s timeout global
  headers: {
    'Content-Type': 'application/ld+json',
    'Accept': 'application/ld+json',
  },
});

// Interceptor de réponse : gestion centralisée des erreurs
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      // Erreur HTTP (4xx, 5xx)
      console.error(`API Error [${error.response.status}]:`, error.response.data);
    } else if (error.request) {
      // Pas de réponse du serveur
      console.error('API Error: No response from server', error.request);
    } else {
      // Erreur de configuration
      console.error('API Error:', error.message);
    }
    return Promise.reject(error);
  }
);

/**
 * Normalise la réponse API Platform (supporte 'member' et 'hydra:member')
 * @private
 */
const normalizeCollection = (data) => {
  const items = data.member || data['hydra:member'] || [];
  const totalItems = data.totalItems || data['hydra:totalItems'] || 0;
  return { items, totalItems };
};

/**
 * Récupère toutes les catégories
 * @returns {Promise<Array>} Liste des catégories
 */
export const getCategories = async () => {
  const response = await apiClient.get('/categories');
  const { items } = normalizeCollection(response.data);
  return items;
};

/**
 * Récupère les produits d'une catégorie spécifique (paginé côté serveur)
 * @param {number} categoryId - ID de la catégorie
 * @param {number} page - Numéro de page (défaut: 1)
 * @returns {Promise<Object>} { items, totalItems, page }
 */
export const getCategoryProducts = async (categoryId, page = 1) => {
  const response = await apiClient.get(`/categories/${categoryId}/products`, {
    params: { page }
  });
  const { items, totalItems } = normalizeCollection(response.data);
  return { items, totalItems, page };
};

/**
 * Récupère les produits avec filtres et pagination
 * @param {Object} params - Paramètres de filtrage (category, status, etc.)
 * @param {Object} options - Options de fetch
 * @param {boolean} options.fetchAll - Si true, agrège toutes les pages (défaut: true pour compatibilité)
 * @param {number} options.page - Numéro de page (ignoré si fetchAll=true)
 * @param {number} options.maxPages - Nombre max de pages à charger si fetchAll=true (défaut: 10)
 * @returns {Promise<Object>} Si fetchAll=false: { items, totalItems, page, itemsPerPage }
 *                             Si fetchAll=true: { items, totalItems }
 */
export const getProducts = async (params = {}, options = {}) => {
  const { 
    fetchAll = true,  // Par défaut true pour compatibilité avec le code existant
    page = 1, 
    maxPages = 10 
  } = options;

  // Convertit automatiquement un paramètre `category` numérique en IRI
  // utilisé par API Platform (ex: 1 -> /api/categories/1)
  const safeParams = { ...params };
  if (safeParams.category && !String(safeParams.category).startsWith('/')) {
    // si on reçoit un ID numérique ou chaîne numérique, on le convertit
    const asNumber = Number(safeParams.category);
    if (!Number.isNaN(asNumber)) {
      safeParams.category = `/api/categories/${asNumber}`;
    }
  }

  if (!fetchAll) {
    // Mode pagination serveur : retourne une seule page
    const response = await apiClient.get('/products', { 
      params: { ...safeParams, page } 
    });
    const { items, totalItems } = normalizeCollection(response.data);
    const itemsPerPage = items.length;
    return { items, totalItems, page, itemsPerPage };
  }

  // Mode fetchAll : agrège toutes les pages (avec limite de sécurité)
  let allProducts = [];
  let currentPage = 1;
  let hasMore = true;

  while (hasMore && currentPage <= maxPages) {
    const response = await apiClient.get('/products', { 
      params: { ...safeParams, page: currentPage } 
    });
    
    const { items, totalItems } = normalizeCollection(response.data);
    allProducts = [...allProducts, ...items];
    
    if (allProducts.length >= totalItems || items.length === 0) {
      hasMore = false;
    } else {
      currentPage++;
    }
  }

  return { 
    items: allProducts,
    totalItems: allProducts.length,
    // Rétro-compatibilité avec ancien code
    member: allProducts,
    'hydra:member': allProducts
  };
};

/**
 * Récupère un produit par son ID
 * @param {number} id - ID du produit
 * @returns {Promise<Object>} Produit
 */
export const getProduct = async (id) => {
  const response = await apiClient.get(`/products/${id}`);
  return response.data;
};

/**
 * Client bas-niveau exporté pour usages avancés
 * ATTENTION : Les opérations POST/PUT/DELETE nécessitent une authentification côté serveur
 */
export default apiClient;

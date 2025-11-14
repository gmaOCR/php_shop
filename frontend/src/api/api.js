import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000/api';

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/ld+json',
    'Accept': 'application/ld+json',
  },
});

export const getCategories = async () => {
  const response = await apiClient.get('/categories');
  return response.data.member || response.data['hydra:member'] || [];
};

export const getCategoryProducts = async (categoryId, page = 1) => {
  const response = await apiClient.get(`/categories/${categoryId}/products?page=${page}`);
  return response.data;
};

export const getProducts = async (params = {}) => {
  // Charger toutes les pages si l'API est paginée
  let allProducts = [];
  let page = 1;
  let hasMore = true;
  
  while (hasMore) {
    const response = await apiClient.get('/products', { 
      params: { ...params, page } 
    });
    
    const products = response.data.member || response.data['hydra:member'] || [];
    allProducts = [...allProducts, ...products];
    
    // Vérifier s'il y a une page suivante
    const totalItems = response.data.totalItems || response.data['hydra:totalItems'] || 0;
    
    if (allProducts.length >= totalItems || products.length === 0) {
      hasMore = false;
    } else {
      page++;
    }
  }
  
  return { 
    member: allProducts,
    'hydra:member': allProducts,
    totalItems: allProducts.length 
  };
};

export const getProduct = async (id) => {
  const response = await apiClient.get(`/products/${id}`);
  return response.data;
};

export default apiClient;

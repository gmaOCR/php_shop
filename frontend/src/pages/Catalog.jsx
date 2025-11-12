import { useEffect, useState } from 'react';
import ProductCard from '../components/ProductCard';
import { getProducts, getCategories } from '../api/api';
import './Catalog.scss';

const Catalog = () => {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  // Filtres
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedStatus, setSelectedStatus] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  
  // Tri
  const [sortBy, setSortBy] = useState('id');
  const [sortOrder, setSortOrder] = useState('desc');

  // Pagination
  const [page, setPage] = useState(1);
  const itemsPerPage = 12;

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const cats = await getCategories();
        setCategories(cats);
      } catch (err) {
        console.error('Erreur chargement catégories:', err);
      }
    };
    fetchCategories();
  }, []);

  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      try {
        const params = {};
        if (selectedCategory) params.category = selectedCategory;
        if (selectedStatus) params.status = selectedStatus;
        
        const data = await getProducts(params);
        let productsList = data.member || data['hydra:member'] || [];
        
        // Recherche côté client
        if (searchTerm) {
          productsList = productsList.filter(p => 
            p.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            p.description.toLowerCase().includes(searchTerm.toLowerCase())
          );
        }
        
        // Tri
        productsList = [...productsList].sort((a, b) => {
          let aVal = a[sortBy];
          let bVal = b[sortBy];
          
          // Gérer le tri par catégorie
          if (sortBy === 'category') {
            aVal = a.category?.name || '';
            bVal = b.category?.name || '';
          }
          
          const modifier = sortOrder === 'asc' ? 1 : -1;
          
          if (typeof aVal === 'string') {
            return aVal.localeCompare(bVal) * modifier;
          }
          return (aVal - bVal) * modifier;
        });
        
        setProducts(productsList);
      } catch (err) {
        setError('Erreur lors du chargement des produits');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, [selectedCategory, selectedStatus, searchTerm, sortBy, sortOrder]);

  // Pagination
  const indexOfLastProduct = page * itemsPerPage;
  const indexOfFirstProduct = indexOfLastProduct - itemsPerPage;
  const currentProducts = products.slice(indexOfFirstProduct, indexOfLastProduct);
  const totalPages = Math.ceil(products.length / itemsPerPage);

  const resetFilters = () => {
    setSelectedCategory('');
    setSelectedStatus('');
    setSearchTerm('');
    setPage(1);
  };

  if (loading && products.length === 0) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="catalog">
      <h1>Catalogue Produits</h1>
      
      <div className="filters-bar">
        <div className="filter-group">
          <label>
            <span>🔍 Recherche</span>
            <input
              type="text"
              placeholder="Nom ou description..."
              value={searchTerm}
              onChange={(e) => { setSearchTerm(e.target.value); setPage(1); }}
            />
          </label>
        </div>

        <div className="filter-group">
          <label>
            <span>📁 Catégorie</span>
            <select value={selectedCategory} onChange={(e) => { setSelectedCategory(e.target.value); setPage(1); }}>
              <option value="">Toutes</option>
              {categories.map(cat => (
                <option key={cat.id} value={cat.id}>{cat.name}</option>
              ))}
            </select>
          </label>
        </div>

        <div className="filter-group">
          <label>
            <span>⚡ État</span>
            <select value={selectedStatus} onChange={(e) => { setSelectedStatus(e.target.value); setPage(1); }}>
              <option value="">Tous</option>
              <option value="online">En ligne</option>
              <option value="offline">Hors ligne</option>
            </select>
          </label>
        </div>

        <div className="filter-group">
          <label>
            <span>↕️ Trier par</span>
            <select value={sortBy} onChange={(e) => setSortBy(e.target.value)}>
              <option value="id">ID</option>
              <option value="name">Nom</option>
              <option value="price">Prix</option>
              <option value="category">Catégorie</option>
            </select>
          </label>
        </div>

        <div className="filter-group">
          <label>
            <span>🔄 Ordre</span>
            <select value={sortOrder} onChange={(e) => setSortOrder(e.target.value)}>
              <option value="asc">↑ Croissant</option>
              <option value="desc">↓ Décroissant</option>
            </select>
          </label>
        </div>

        <button className="btn-reset" onClick={resetFilters}>
          ✖ Réinitialiser
        </button>
      </div>

      <div className="results-info">
        <p>{products.length} produit(s) trouvé(s)</p>
      </div>

      <div className="products-grid">
        {currentProducts.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      {currentProducts.length === 0 && (
        <p className="no-products">Aucun produit ne correspond aux critères</p>
      )}

      {totalPages > 1 && (
        <div className="pagination">
          <button 
            onClick={() => setPage(p => Math.max(1, p - 1))}
            disabled={page === 1}
          >
            ← Précédent
          </button>
          <span className="page-info">
            Page {page} sur {totalPages}
          </span>
          <button 
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
          >
            Suivant →
          </button>
        </div>
      )}
    </div>
  );
};

export default Catalog;

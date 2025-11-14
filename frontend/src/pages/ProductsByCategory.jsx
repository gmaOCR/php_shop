import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import ProductCard from '../components/ProductCard';
import { getCategoryProducts } from '../api/api';
import './ProductsByCategory.scss';

const ProductsByCategory = () => {
  const { categoryId } = useParams();
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [page, setPage] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const [sortBy, setSortBy] = useState('id');
  const [sortOrder, setSortOrder] = useState('desc');

  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      try {
  const data = await getCategoryProducts(categoryId, page);
  // Supporte plusieurs formes de retour :
  // - API Platform JSON-LD: data['hydra:member']
  // - notre helper getCategoryProducts: data.items
  // - backward-compat: data.member
  let productsList = data.items || data['hydra:member'] || data.member || [];
        
        // Tri côté client
        productsList = [...productsList].sort((a, b) => {
          const aVal = a[sortBy];
          const bVal = b[sortBy];
          const modifier = sortOrder === 'asc' ? 1 : -1;
          
          if (typeof aVal === 'string') {
            return aVal.localeCompare(bVal) * modifier;
          }
          return (aVal - bVal) * modifier;
        });
        
        setProducts(productsList);
  setTotalItems(data['hydra:totalItems'] || data.totalItems || data.totalItems || productsList.length);
      } catch (err) {
        setError('Erreur lors du chargement des produits');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, [categoryId, page, sortBy, sortOrder]);

  if (loading) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="products-by-category">
      <h1>Produits de la catégorie</h1>
      <p className="total-count">{totalItems} produit(s) trouvé(s)</p>
      
      {/* Contrôles de tri */}
      <div className="sort-controls">
        <label>
          Trier par :
          <select value={sortBy} onChange={(e) => setSortBy(e.target.value)}>
            <option value="id">ID</option>
            <option value="name">Nom</option>
            <option value="price">Prix</option>
          </select>
        </label>
        <label>
          Ordre :
          <select value={sortOrder} onChange={(e) => setSortOrder(e.target.value)}>
            <option value="asc">Croissant</option>
            <option value="desc">Décroissant</option>
          </select>
        </label>
      </div>
      
      <div className="products-grid">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>

      {products.length === 0 && (
        <p className="no-products">Aucun produit dans cette catégorie</p>
      )}

      <div className="pagination">
        {page > 1 && (
          <button onClick={() => setPage(page - 1)}>Page précédente</button>
        )}
        <span>Page {page}</span>
        {products.length === 10 && (
          <button onClick={() => setPage(page + 1)}>Page suivante</button>
        )}
      </div>
    </div>
  );
};

export default ProductsByCategory;

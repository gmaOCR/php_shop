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

  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      try {
        const data = await getCategoryProducts(categoryId, page);
        setProducts(data['hydra:member']);
        setTotalItems(data['hydra:totalItems']);
      } catch (err) {
        setError('Erreur lors du chargement des produits');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, [categoryId, page]);

  if (loading) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="products-by-category">
      <h1>Produits de la catégorie</h1>
      <p className="total-count">{totalItems} produit(s) trouvé(s)</p>
      
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

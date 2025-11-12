import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getProduct } from '../api/api';
import './ProductDetail.scss';

const ProductDetail = () => {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        const data = await getProduct(id);
        setProduct(data);
      } catch (err) {
        setError('Erreur lors du chargement du produit');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchProduct();
  }, [id]);

  if (loading) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;
  if (!product) return <div className="error">Produit non trouvé</div>;

  const statusLabel = product.status === 'online' ? 'En ligne' : 'Hors ligne';
  const statusClass = product.status === 'online' ? 'status-online' : 'status-offline';

  return (
    <div className="product-detail">
      <Link to="/" className="back-link">← Retour au catalogue</Link>
      
      <div className="product-content">
        <div className="product-header">
          <h1>{product.name}</h1>
          <span className={`status ${statusClass}`}>{statusLabel}</span>
        </div>

        {product.category && (
          <div className="category-info">
            <span className="label">Catégorie:</span>
            <Link to={`/categories/${product.category.id}/products`} className="category-link">
              {product.category.name}
            </Link>
          </div>
        )}

        <div className="description">
          <h2>Description</h2>
          <p>{product.description}</p>
        </div>

        <div className="price-section">
          <span className="price-label">Prix:</span>
          <span className="price">{parseFloat(product.price).toFixed(2)} €</span>
        </div>
      </div>
    </div>
  );
};

export default ProductDetail;

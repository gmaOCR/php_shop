import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import './ProductCard.scss';

const ProductCard = ({ product }) => {
  const statusLabel = product.status === 'online' ? 'En ligne' : 'Hors ligne';
  const statusClass = product.status === 'online' ? 'status-online' : 'status-offline';

  return (
    <Link to={`/products/${product.id}`} className="product-card">
      <div className="product-info">
        <h3>{product.name}</h3>
        <p className="description">{product.description.substring(0, 100)}...</p>
        <div className="product-footer">
          <span className="price">{parseFloat(product.price).toFixed(2)} €</span>
          <span className={`status ${statusClass}`}>{statusLabel}</span>
        </div>
        {product.category && (
          <span className="category-badge">{product.category.name}</span>
        )}
      </div>
    </Link>
  );
};

ProductCard.propTypes = {
  product: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    description: PropTypes.string.isRequired,
    price: PropTypes.string.isRequired,
    status: PropTypes.string.isRequired,
    category: PropTypes.shape({
      id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
    }),
  }).isRequired,
};

export default ProductCard;

import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import './CategoryList.scss';

const CategoryList = ({ categories }) => {
  return (
    <div className="category-list">
      <h2>Catégories</h2>
      <div className="categories-grid">
        {categories.map((category) => (
          <Link 
            key={category.id} 
            to={`/categories/${category.id}/products`}
            className="category-card"
          >
            <h3>{category.name}</h3>
          </Link>
        ))}
      </div>
    </div>
  );
};

CategoryList.propTypes = {
  categories: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
    })
  ).isRequired,
};

export default CategoryList;

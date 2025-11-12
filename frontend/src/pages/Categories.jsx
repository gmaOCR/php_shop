import { useEffect, useState } from 'react';
import CategoryList from '../components/CategoryList';
import { getCategories } from '../api/api';
import './Categories.scss';

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const data = await getCategories();
        setCategories(data);
      } catch (err) {
        setError('Erreur lors du chargement des catégories');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchCategories();
  }, []);

  if (loading) return <div className="loading">Chargement...</div>;
  if (error) return <div className="error">{error}</div>;

  return (
    <div className="categories-page">
      <h1>Catalogue de produits</h1>
      <CategoryList categories={categories} />
    </div>
  );
};

export default Categories;

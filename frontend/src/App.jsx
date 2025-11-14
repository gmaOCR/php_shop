import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Categories from './pages/Categories';
import ProductsByCategory from './pages/ProductsByCategory';
import ProductDetail from './pages/ProductDetail';
import Catalog from './pages/Catalog';
import './App.scss';

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <h1>🛍️ Shop Catalogue</h1>
          <nav className="app-nav">
            <Link to="/">Catégories</Link>
            <Link to="/catalog">Catalogue complet</Link>
          </nav>
        </header>
        <main className="app-main">
          <Routes>
            <Route path="/" element={<Categories />} />
            <Route path="/catalog" element={<Catalog />} />
            <Route path="/categories/:categoryId/products" element={<ProductsByCategory />} />
            <Route path="/products/:id" element={<ProductDetail />} />
          </Routes>
        </main>
        <footer className="app-footer">
          <p>&copy; 2025 Shop - Test Technique PROX-I</p>
        </footer>
      </div>
    </Router>
  );
}

export default App;

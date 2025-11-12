import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Categories from './pages/Categories';
import ProductsByCategory from './pages/ProductsByCategory';
import ProductDetail from './pages/ProductDetail';
import './App.scss';

function App() {
  return (
    <Router>
      <div className="app">
        <header className="app-header">
          <h1>🛍️ Shop Catalogue</h1>
        </header>
        <main className="app-main">
          <Routes>
            <Route path="/" element={<Categories />} />
            <Route path="/categories/:categoryId/products" element={<ProductsByCategory />} />
            <Route path="/products/:id" element={<ProductDetail />} />
          </Routes>
        </main>
        <footer className="app-footer">
          <p>&copy; 2025 Shop - Test Technique PROXIMITY</p>
        </footer>
      </div>
    </Router>
  );
}

export default App;

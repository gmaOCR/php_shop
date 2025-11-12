import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import ProductCard from '../components/ProductCard';

describe('ProductCard', () => {
  const mockProduct = {
    id: 1,
    name: 'Test Product',
    description: 'Ceci est une description de test pour le produit',
    price: '99.99',
    status: 'online',
    category: {
      id: 1,
      name: 'Électronique',
    },
  };

  it('affiche le nom du produit', () => {
    render(
      <BrowserRouter>
        <ProductCard product={mockProduct} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('Test Product')).toBeInTheDocument();
  });

  it('affiche le prix formaté', () => {
    render(
      <BrowserRouter>
        <ProductCard product={mockProduct} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('99.99 €')).toBeInTheDocument();
  });

  it('affiche le statut "En ligne" pour un produit online', () => {
    render(
      <BrowserRouter>
        <ProductCard product={mockProduct} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('En ligne')).toBeInTheDocument();
  });

  it('affiche le statut "Hors ligne" pour un produit offline', () => {
    const offlineProduct = { ...mockProduct, status: 'offline' };
    
    render(
      <BrowserRouter>
        <ProductCard product={offlineProduct} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('Hors ligne')).toBeInTheDocument();
  });

  it('affiche la catégorie du produit', () => {
    render(
      <BrowserRouter>
        <ProductCard product={mockProduct} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('Électronique')).toBeInTheDocument();
  });

  it('crée un lien vers la page de détail du produit', () => {
    render(
      <BrowserRouter>
        <ProductCard product={mockProduct} />
      </BrowserRouter>
    );
    
    const link = screen.getByRole('link');
    expect(link).toHaveAttribute('href', '/products/1');
  });
});

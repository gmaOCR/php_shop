import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import CategoryList from '../components/CategoryList';

describe('CategoryList', () => {
  const mockCategories = [
    { id: 1, name: 'Électronique' },
    { id: 2, name: 'Vêtements' },
    { id: 3, name: 'Alimentation' },
  ];

  it('affiche le titre "Catégories"', () => {
    render(
      <BrowserRouter>
        <CategoryList categories={mockCategories} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('Catégories')).toBeInTheDocument();
  });

  it('affiche toutes les catégories passées en props', () => {
    render(
      <BrowserRouter>
        <CategoryList categories={mockCategories} />
      </BrowserRouter>
    );
    
    expect(screen.getByText('Électronique')).toBeInTheDocument();
    expect(screen.getByText('Vêtements')).toBeInTheDocument();
    expect(screen.getByText('Alimentation')).toBeInTheDocument();
  });

  it('crée des liens vers les pages de produits par catégorie', () => {
    render(
      <BrowserRouter>
        <CategoryList categories={mockCategories} />
      </BrowserRouter>
    );
    
    const links = screen.getAllByRole('link');
    expect(links).toHaveLength(3);
    expect(links[0]).toHaveAttribute('href', '/categories/1/products');
  });
});

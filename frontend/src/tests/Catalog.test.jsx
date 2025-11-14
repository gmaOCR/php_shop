import React from 'react';
import '@testing-library/jest-dom';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { vi, describe, it, afterEach, expect } from 'vitest';

// Mock du module API
vi.mock('../api/api', () => ({
  getProducts: vi.fn(),
  getCategories: vi.fn(),
}));

import Catalog from '../pages/Catalog';
import { getProducts, getCategories } from '../api/api';

describe('Catalogue par catégorie', () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  it("affiche les produits lorsqu'on sélectionne une catégorie", async () => {
    // données simulées
    getCategories.mockResolvedValueOnce([
      { id: 1, name: 'Électronique' },
      { id: 2, name: 'Vêtements' },
    ]);

    const allProducts = [
      { id: 1, name: 'Phone X', description: 'Un téléphone', price: '100.00', status: 'online', category: { id: 1, name: 'Électronique' } },
      { id: 2, name: 'T-Shirt', description: 'Un tee', price: '20.00', status: 'online', category: { id: 2, name: 'Vêtements' } },
    ];

    // getProducts renvoie tout par défaut, et renvoie filtré quand params.category est converti en IRI
    getProducts.mockImplementation((params) => {
      const cat = params && params.category;
      if (cat === '/api/categories/1' || cat === 1 || cat === '1') {
        return Promise.resolve({ items: allProducts.filter(p => p.category.id === 1) });
      }
      return Promise.resolve({ items: allProducts });
    });

    render(
      <MemoryRouter>
        <Catalog />
      </MemoryRouter>
    );

  // attendre que les catégories et produits initiaux soient chargés
  // le texte "Électronique" apparaît à la fois comme option et comme badge,
  // on vérifie donc qu'il existe au moins une occurrence
  await waitFor(() => expect(screen.getAllByText('Électronique').length).toBeGreaterThan(0));
  await waitFor(() => expect(screen.getByText('Phone X')).toBeInTheDocument());
  await waitFor(() => expect(screen.getByText('T-Shirt')).toBeInTheDocument());

    // sélectionner la catégorie 'Électronique' (id=1)
    const select = screen.getByLabelText(/Catégorie/i);
    await userEvent.selectOptions(select, '1');

    // vérifier que seul le produit de la catégorie s'affiche
    await waitFor(() => expect(screen.getByText('Phone X')).toBeInTheDocument());
    await waitFor(() => expect(screen.queryByText('T-Shirt')).not.toBeInTheDocument());
  });
});

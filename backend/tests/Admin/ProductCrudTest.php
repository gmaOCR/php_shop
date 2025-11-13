<?php

declare(strict_types=1);

namespace App\Tests\Admin;

use App\Entity\Category;
use App\Entity\Product;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class ProductCrudTest extends WebTestCase
{
    private EntityManagerInterface $entityManager;

    protected function setUp(): void
    {
        parent::setUp();
        $kernel = self::bootKernel();
        $this->entityManager = $kernel->getContainer()
            ->get('doctrine')
            ->getManager();
    }

    public function testProductPriceIsStoredCorrectly(): void
    {
        // Créer une catégorie de test
        $category = new Category();
        $category->setName('Test Category');
        $this->entityManager->persist($category);

        // Créer un produit avec un prix de 25.99 euros
        $product = new Product();
        $product->setName('Test Product Price');
        $product->setDescription('Product to test price storage');
        $product->setPrice('25.99'); // 25.99 euros
        $product->setStatus(Product::STATUS_ONLINE);
        $product->setCategory($category);

        $this->entityManager->persist($product);
        $this->entityManager->flush();

        // Récupérer le produit depuis la base
        $this->entityManager->clear(); // Clear pour forcer un fetch depuis la DB
        $savedProduct = $this->entityManager
            ->getRepository(Product::class)
            ->find($product->getId());

        // Vérifier que le prix est bien stocké en euros (pas en centimes)
        $this->assertNotNull($savedProduct);
        $this->assertEquals('25.99', $savedProduct->getPrice(), 
            'Le prix doit être stocké tel quel en euros, pas multiplié par 100'
        );

        // Nettoyer (récupérer la catégorie depuis la DB aussi)
        $savedCategory = $this->entityManager
            ->getRepository(Category::class)
            ->find($category->getId());
        
        $this->entityManager->remove($savedProduct);
        $this->entityManager->flush();
        
        if ($savedCategory) {
            $this->entityManager->remove($savedCategory);
            $this->entityManager->flush();
        }
    }

    public function testProductPriceValidation(): void
    {
        $category = new Category();
        $category->setName('Test Category');
        $this->entityManager->persist($category);

        // Tester différents formats de prix
        $testCases = [
            ['10.50', true, 'Prix valide avec 2 décimales'],
            ['100.00', true, 'Prix valide entier avec décimales'],
            ['0.99', true, 'Prix valide inférieur à 1 euro'],
        ];

        foreach ($testCases as [$price, $shouldBeValid, $description]) {
            $product = new Product();
            $product->setName('Test Product - ' . $description);
            $product->setDescription('Testing price: ' . $price);
            $product->setPrice($price);
            $product->setStatus(Product::STATUS_ONLINE);
            $product->setCategory($category);

            $this->entityManager->persist($product);
            $this->entityManager->flush();

            $savedProduct = $this->entityManager
                ->getRepository(Product::class)
                ->find($product->getId());

            $this->assertNotNull($savedProduct);
            $this->assertEquals($price, $savedProduct->getPrice(), 
                "Le prix doit être stocké correctement: {$description}"
            );

            // Vérifier que le prix en float est raisonnable
            $priceFloat = (float) $savedProduct->getPrice();
            $this->assertLessThan(100000, $priceFloat, 
                "Le prix ne doit pas être en centimes: {$description}"
            );

            $this->entityManager->remove($savedProduct);
        }

        $this->entityManager->remove($category);
        $this->entityManager->flush();
    }
}

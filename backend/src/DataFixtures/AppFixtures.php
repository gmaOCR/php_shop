<?php

declare(strict_types=1);

namespace App\DataFixtures;

use App\Entity\Category;
use App\Entity\Product;
use Doctrine\Bundle\FixturesBundle\Fixture;
use Doctrine\Persistence\ObjectManager;
use Faker\Factory;

class AppFixtures extends Fixture
{
    public function load(ObjectManager $manager): void
    {
        $faker = Factory::create('fr_FR');

        // Créer 5 catégories
        $categories = [];
        $categoryNames = ['Électronique', 'Vêtements', 'Alimentation', 'Maison & Jardin', 'Sports & Loisirs'];
        
        foreach ($categoryNames as $categoryName) {
            $category = new Category();
            $category->setName($categoryName);
            $manager->persist($category);
            $categories[] = $category;
        }

        // Créer 20 produits
        for ($i = 0; $i < 20; $i++) {
            $product = new Product();
            $product->setName($faker->words(3, true));
            $product->setDescription($faker->paragraph(3));
            $product->setPrice((string) $faker->randomFloat(2, 5, 500));
            $product->setStatus($faker->randomElement([Product::STATUS_ONLINE, Product::STATUS_OFFLINE]));
            $product->setCategory($faker->randomElement($categories));
            
            $manager->persist($product);
        }

        $manager->flush();
    }
}

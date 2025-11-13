<?php

declare(strict_types=1);

namespace App\Tests\Api;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

class ApiProductTest extends WebTestCase
{
    public function testIndexProducts(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/products');

        $this->assertResponseIsSuccessful();
        $this->assertResponseHeaderSame('content-type', 'application/ld+json; charset=utf-8');

        $data = json_decode($client->getResponse()->getContent(), true);
        $this->assertArrayHasKey('member', $data);
        $this->assertIsArray($data['member']);
    }

    public function testGetProduct(): void
    {
        $client = static::createClient();
        
        // First get all products
        $client->request('GET', '/api/products');
        $data = json_decode($client->getResponse()->getContent(), true);
        
        if (isset($data['member']) && count($data['member']) > 0) {
            $productId = $data['member'][0]['id'];
            
            $client->request('GET', "/api/products/{$productId}");
            
            $this->assertResponseIsSuccessful();
            $productData = json_decode($client->getResponse()->getContent(), true);
            
            $this->assertArrayHasKey('id', $productData);
            $this->assertArrayHasKey('name', $productData);
            $this->assertArrayHasKey('price', $productData);
            $this->assertArrayHasKey('status', $productData);
        } else {
            $this->markTestSkipped('No products in database');
        }
    }

    public function testGetCategories(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/categories');

        $this->assertResponseIsSuccessful();
        $data = json_decode($client->getResponse()->getContent(), true);
        
        $this->assertArrayHasKey('member', $data);
        $this->assertIsArray($data['member']);
    }

    public function testProductPriceFormat(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/products');

        $this->assertResponseIsSuccessful();
        $data = json_decode($client->getResponse()->getContent(), true);

        if (isset($data['member']) && count($data['member']) > 0) {
            foreach ($data['member'] as $product) {
                $this->assertArrayHasKey('price', $product);
                
                // Le prix doit être une chaîne au format décimal avec 2 décimales
                $this->assertIsString($product['price']);
                $this->assertMatchesRegularExpression('/^\d+\.\d{2}$/', $product['price'], 
                    "Le prix '{$product['price']}' du produit '{$product['name']}' doit être au format XX.XX"
                );
                
                // Le prix doit être raisonnable (entre 0.01 et 99999.99)
                $priceValue = (float) $product['price'];
                $this->assertGreaterThan(0, $priceValue, 
                    "Le prix du produit '{$product['name']}' doit être positif"
                );
                $this->assertLessThan(100000, $priceValue,
                    "Le prix du produit '{$product['name']}' semble trop élevé (possible erreur d'unité)"
                );
            }
        } else {
            $this->markTestSkipped('No products in database');
        }
    }
}

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
        $this->assertArrayHasKey('hydra:member', $data);
        $this->assertIsArray($data['hydra:member']);
    }

    public function testGetProduct(): void
    {
        $client = static::createClient();
        
        // First get all products
        $client->request('GET', '/api/products');
        $data = json_decode($client->getResponse()->getContent(), true);
        
        if (count($data['hydra:member']) > 0) {
            $productId = $data['hydra:member'][0]['id'];
            
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
        
        $this->assertArrayHasKey('hydra:member', $data);
        $this->assertIsArray($data['hydra:member']);
    }
}

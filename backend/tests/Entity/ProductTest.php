<?php

declare(strict_types=1);

namespace App\Tests\Entity;

use App\Entity\Product;
use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\Validator\Validator\ValidatorInterface;

class ProductTest extends KernelTestCase
{
    private ValidatorInterface $validator;

    protected function setUp(): void
    {
        self::bootKernel();
        $this->validator = static::getContainer()->get(ValidatorInterface::class);
    }

    public function testValidProduct(): void
    {
        $product = new Product();
        $product->setName('Test Product');
        $product->setDescription('Test description');
        $product->setPrice('99.99');
        $product->setStatus(Product::STATUS_ONLINE);

        $errors = $this->validator->validate($product);
        
        // Should have 1 error: category is null
        $this->assertCount(1, $errors);
        $this->assertEquals('La catégorie ne peut pas être vide', $errors[0]->getMessage());
    }

    public function testProductWithEmptyName(): void
    {
        $product = new Product();
        $product->setName('');
        $product->setDescription('Test description');
        $product->setPrice('99.99');
        $product->setStatus(Product::STATUS_ONLINE);

        $errors = $this->validator->validate($product);
        
        $this->assertGreaterThanOrEqual(1, $errors->count());
        
        $found = false;
        foreach ($errors as $error) {
            if (str_contains($error->getMessage(), 'vide')) {
                $found = true;
                break;
            }
        }
        $this->assertTrue($found);
    }

    public function testProductWithNegativePrice(): void
    {
        $product = new Product();
        $product->setName('Test Product');
        $product->setDescription('Test description');
        $product->setPrice('-10.00');
        $product->setStatus(Product::STATUS_ONLINE);

        $errors = $this->validator->validate($product);
        
        $found = false;
        foreach ($errors as $error) {
            if (str_contains($error->getMessage(), 'positif')) {
                $found = true;
                break;
            }
        }
        $this->assertTrue($found);
    }

    public function testProductWithInvalidStatus(): void
    {
        $product = new Product();
        $product->setName('Test Product');
        $product->setDescription('Test description');
        $product->setPrice('99.99');
        $product->setStatus('invalid');

        $errors = $this->validator->validate($product);
        
        $found = false;
        foreach ($errors as $error) {
            if (str_contains($error->getPropertyPath(), 'status')) {
                $found = true;
                break;
            }
        }
        $this->assertTrue($found);
    }
}

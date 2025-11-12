<?php

declare(strict_types=1);

namespace App\Controller\Api;

use App\Repository\ProductRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Serializer\SerializerInterface;

#[AsController]
#[Route('/api', name: 'api_')]
class CategoryProductsController extends AbstractController
{
    public function __construct(
        private readonly ProductRepository $productRepository,
        private readonly SerializerInterface $serializer,
    ) {
    }

    #[Route('/categories/{id}/products', name: 'category_products', methods: ['GET'])]
    public function __invoke(int $id, Request $request): JsonResponse
    {
        $page = max(1, (int) $request->query->get('page', 1));
        $itemsPerPage = 10;

        $allProducts = $this->productRepository->findByCategory($id);
        $totalItems = count($allProducts);
        $products = array_slice($allProducts, ($page - 1) * $itemsPerPage, $itemsPerPage);

        $data = [
            'hydra:member' => json_decode(
                $this->serializer->serialize($products, 'json', ['groups' => 'product:read']),
                true
            ),
            'hydra:totalItems' => $totalItems,
            'hydra:view' => [
                '@id' => sprintf('/api/categories/%d/products?page=%d', $id, $page),
                '@type' => 'hydra:PartialCollectionView',
                'hydra:first' => sprintf('/api/categories/%d/products?page=1', $id),
                'hydra:last' => sprintf('/api/categories/%d/products?page=%d', $id, (int) ceil($totalItems / $itemsPerPage)),
            ],
        ];

        if ($page > 1) {
            $data['hydra:view']['hydra:previous'] = sprintf('/api/categories/%d/products?page=%d', $id, $page - 1);
        }

        if ($page < ceil($totalItems / $itemsPerPage)) {
            $data['hydra:view']['hydra:next'] = sprintf('/api/categories/%d/products?page=%d', $id, $page + 1);
        }

        return new JsonResponse($data);
    }
}

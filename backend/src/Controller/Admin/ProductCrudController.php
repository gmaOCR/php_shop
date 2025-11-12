<?php

declare(strict_types=1);

namespace App\Controller\Admin;

use App\Entity\Product;
use EasyCorp\Bundle\EasyAdminBundle\Config\Crud;
use EasyCorp\Bundle\EasyAdminBundle\Config\Filters;
use EasyCorp\Bundle\EasyAdminBundle\Controller\AbstractCrudController;
use EasyCorp\Bundle\EasyAdminBundle\Field\AssociationField;
use EasyCorp\Bundle\EasyAdminBundle\Field\ChoiceField;
use EasyCorp\Bundle\EasyAdminBundle\Field\IdField;
use EasyCorp\Bundle\EasyAdminBundle\Field\MoneyField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextareaField;
use EasyCorp\Bundle\EasyAdminBundle\Field\TextField;
use EasyCorp\Bundle\EasyAdminBundle\Filter\EntityFilter;
use EasyCorp\Bundle\EasyAdminBundle\Filter\ChoiceFilter;
use EasyCorp\Bundle\EasyAdminBundle\Filter\NumericFilter;

class ProductCrudController extends AbstractCrudController
{
    public static function getEntityFqcn(): string
    {
        return Product::class;
    }

    public function configureCrud(Crud $crud): Crud
    {
        return $crud
            ->setEntityLabelInSingular('Produit')
            ->setEntityLabelInPlural('Produits')
            ->setSearchFields(['name', 'description'])
            ->setDefaultSort(['id' => 'DESC'])
            ->setPaginatorPageSize(20);
    }

    public function configureFilters(Filters $filters): Filters
    {
        return $filters
            ->add(EntityFilter::new('category', 'Catégorie'))
            ->add(ChoiceFilter::new('status', 'État')->setChoices([
                'En ligne' => Product::STATUS_ONLINE,
                'Hors ligne' => Product::STATUS_OFFLINE,
            ]))
            ->add(NumericFilter::new('price', 'Prix'));
    }

    public function configureFields(string $pageName): iterable
    {
        return [
            IdField::new('id')->hideOnForm(),
            TextField::new('name', 'Nom'),
            TextareaField::new('description', 'Description')->hideOnIndex(),
            MoneyField::new('price', 'Prix')->setCurrency('EUR'),
            ChoiceField::new('status', 'État')
                ->setChoices([
                    'En ligne' => Product::STATUS_ONLINE,
                    'Hors ligne' => Product::STATUS_OFFLINE,
                ])
                ->renderAsBadges([
                    Product::STATUS_ONLINE => 'success',
                    Product::STATUS_OFFLINE => 'danger',
                ]),
            AssociationField::new('category', 'Catégorie'),
        ];
    }
}

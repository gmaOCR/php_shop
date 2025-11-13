-- Script d'initialisation MySQL pour l'environnement de production
-- Ce script s'exécute automatiquement lors du premier démarrage du conteneur MySQL

-- Créer la base de données si elle n'existe pas (au cas où)
CREATE DATABASE IF NOT EXISTS shop_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Créer l'utilisateur si nécessaire (au cas où)
CREATE USER IF NOT EXISTS 'shop_user'@'%' IDENTIFIED BY 'shop_password';
GRANT ALL PRIVILEGES ON shop_db.* TO 'shop_user'@'%';
FLUSH PRIVILEGES;

-- Message de confirmation
SELECT 'Base de données shop_db initialisée avec succès' as status;
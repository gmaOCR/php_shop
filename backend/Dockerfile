# Dockerfile pour le backend Symfony (Production)
FROM php:8.2-fpm-alpine

# Installer les extensions PHP nécessaires
RUN apk add --no-cache \
    icu-dev \
    libzip-dev \
    mysql-dev \
    && docker-php-ext-install \
    pdo_mysql \
    intl \
    zip \
    opcache

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers composer
COPY backend/composer.json backend/composer.lock* ./

# Installer les dépendances PHP (si composer.lock existe)
RUN if [ -f composer.lock ]; then \
        composer install --no-dev --optimize-autoloader --no-interaction; \
    else \
        composer install --no-dev --optimize-autoloader --no-interaction; \
    fi

# Copier le code source
COPY backend/ .

# Définir les permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Créer les répertoires nécessaires
RUN mkdir -p /var/lib/php/sessions var/cache var/log \
    && chown -R www-data:www-data /var/lib/php/sessions var/cache var/log

# Exposer le port 9000 pour PHP-FPM
EXPOSE 9000

# Commande par défaut
CMD ["php-fpm"]
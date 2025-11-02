# 1. Utiliser une image PHP/Apache officielle
FROM php:8.1-apache

# 2. Installer les outils et extensions PHP dont BookStack a besoin
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libgd-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip

# 3. Installer Composer (le "chef de chantier" PHP)
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# 4. Configurer Apache pour pointer vers le bon dossier
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN a2enmod rewrite

# 5. Copier le code de BookStack dans le conteneur
WORKDIR /var/www/html
COPY . .

# 6. Installer les dépendances de BookStack
RUN composer install --no-dev --no-interaction

# 7. Définir les permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# 8. Lancer le serveur !
CMD ["apache2-foreground"]

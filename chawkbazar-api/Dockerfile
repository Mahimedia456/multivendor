# ---- PHP 8.3 with required extensions ----
FROM php:8.3-cli

# System deps for extensions (gd/exif/bcmath/intl + pgsql)
RUN apt-get update && apt-get install -y \
    git unzip \
    libpq-dev \
    libicu-dev \
    libzip-dev \
    libjpeg-dev libpng-dev libfreetype6-dev \
 && docker-php-ext-configure intl \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j$(nproc) intl pdo pdo_pgsql zip gd bcmath exif \
 && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Workdir
WORKDIR /var/www/html

# Copy app BEFORE composer so "path" repos (packages/marvel) are visible
COPY . .

# Install PHP deps (no dev) - optimize autoload
RUN composer install --no-dev -o --no-interaction

# Ensure writable dirs
RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data storage bootstrap/cache

# Add entrypoint to run migrations etc on container start
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000
CMD ["/entrypoint.sh"]

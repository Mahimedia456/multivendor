# ---- Base PHP image (CLI) with needed extensions ----
FROM php:8.3-cli

# System deps (git, unzip, pgsql headers, intl deps, etc.)
RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libicu-dev libzip-dev libonig-dev libpng-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) intl pdo pdo_pgsql zip \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Workdir
WORKDIR /var/www/html

# Copy app (composer.json/lock first for layer caching)
COPY composer.json composer.lock ./
RUN composer install --no-dev -o --no-interaction

# Copy rest of the app
COPY . .

# Laravel permissions (storage, cache)
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

# Port Laravel will serve on
EXPOSE 8000

# Default command: run Laravel’s dev server binding to $PORT provided by Render
# (Render injects PORT env var, but we default to 8000 for local/docker run)
CMD php artisan serve --host=0.0.0.0 --port=${PORT:-8000}

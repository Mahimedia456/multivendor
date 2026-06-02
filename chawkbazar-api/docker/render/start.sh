#!/usr/bin/env bash
set -e

# Render provides PORT automatically for web services.
# Apache needs to listen on that port.
: "${PORT:=10000}"

echo "Using PORT=$PORT"

sed -i "s/Listen 80/Listen ${PORT}/g" /etc/apache2/ports.conf

# Make sure required Laravel folders exist
mkdir -p storage/framework/cache/data
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p storage/logs
mkdir -p bootstrap/cache

chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Laravel optimization
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

apache2-foreground
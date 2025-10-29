#!/usr/bin/env bash
set -e

echo ">> Laravel bootstrapping…"

# Clear old caches (safe if none exist)
php artisan config:clear || true
php artisan cache:clear || true

# Generate app key only if not provided via env
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "" ]; then
  echo ">> APP_KEY not set in env; generating one inside container…"
  php artisan key:generate --force || true
else
  echo ">> APP_KEY provided via env."
fi

# Storage symlink (idempotent)
php artisan storage:link || true

# DB migrate + seed (idempotent; won't drop data)
php artisan migrate --force || true
php artisan db:seed --force || true

# Project-specific demo/data installer (idempotent in this project)
php artisan marvel:install --force || true

echo ">> Starting HTTP server…"
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8000}

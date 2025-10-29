#!/usr/bin/env bash
set -e

echo ">> Laravel bootstrapping…"

php artisan config:clear || true
php artisan cache:clear || true

# 1) APP_KEY
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "" ]; then
  echo ">> APP_KEY not set in env; generating one…"
  php artisan key:generate --force || true
else
  echo ">> APP_KEY provided via env."
fi

# 2) Storage symlink (idempotent)
php artisan storage:link || true

# 3) Migrate
php artisan migrate --force || true

# 4) Decide whether to seed/install
SEED_FLAG="storage/app/.seeded"
FORCE_DEMO="${FORCE_DEMO:-false}"

needs_seed() {
  # returns 0 (true) if products table is empty OR flag not present
  if [ ! -f "$SEED_FLAG" ]; then
    return 0
  fi
  # Try to count products; if it fails, we seed again
  COUNT=$(php -r '
  require "vendor/autoload.php";
  $app = require "bootstrap/app.php";
  $kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
  $kernel->bootstrap();
  try { echo \DB::table("products")->count(); } catch (\Throwable $e) { echo "ERR"; }
  ' || echo "ERR")
  if [ "$COUNT" = "ERR" ] || [ "$COUNT" = "" ] || [ "$COUNT" -eq 0 ] 2>/dev/null; then
    return 0
  fi
  return 1
}

if [ "$FORCE_DEMO" = "true" ]; then
  echo ">> FORCE_DEMO=true → seeding demo data…"
  php artisan migrate:fresh --force || true
  php artisan db:seed --force || true
  php artisan marvel:install --force || true
  mkdir -p "$(dirname "$SEED_FLAG")" && echo "$(date)" > "$SEED_FLAG"
else
  if needs_seed; then
    echo ">> No demo data found → seeding demo data…"
    php artisan db:seed --force || true
    php artisan marvel:install --force || true
    mkdir -p "$(dirname "$SEED_FLAG")" && echo "$(date)" > "$SEED_FLAG"
  else
    echo ">> Demo data already present. Skipping seed/install."
  fi
fi

echo ">> Starting HTTP server…"
exec php artisan serve --host=0.0.0.0 --port=${PORT:-8000}

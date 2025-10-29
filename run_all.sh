#!/bin/bash
# =========================================================
# 🚀 Start ChawkBazar (API + Admin + Shop) Locally
# =========================================================
# Prereqs: Docker Desktop running, pnpm installed

ROOT_DIR="/Users/mahimedia/Documents/chawkbazar-laravel"
API_DIR="$ROOT_DIR/chawkbazar-api"
ADMIN_DIR="$ROOT_DIR/admin/rest"
SHOP_DIR="$ROOT_DIR/shop"

echo "🔹 Checking Docker..."
if ! docker info >/dev/null 2>&1; then
  echo "❌ Docker not running. Please start Docker Desktop first."
  exit 1
fi

echo "🔹 Starting Laravel API via Sail..."
cd "$API_DIR"
./vendor/bin/sail up -d
./vendor/bin/sail artisan migrate --seed --force
./vendor/bin/sail artisan storage:link

echo "✅ API running at http://localhost"
echo "------------------------------------------------------"

# Start Admin frontend
echo "🔹 Starting Admin Dashboard on port 3002..."
cd "$ADMIN_DIR"
pnpm install --frozen-lockfile >/dev/null 2>&1
pnpm run dev &
sleep 2

# Start Shop frontend
echo "🔹 Starting Shop Frontend on port 3003..."
cd "$SHOP_DIR"
pnpm install --frozen-lockfile >/dev/null 2>&1
pnpm run dev &
sleep 2

echo "------------------------------------------------------"
echo "✅ All services running:"
echo "   🌐 API:    http://localhost"
echo "   🧭 Admin:  http://localhost:3002"
echo "   🛍️  Shop:   http://localhost:3003"
echo "------------------------------------------------------"
wait

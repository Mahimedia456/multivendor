# =========================================================
# Start ChawkBazar Multivendor Locally on Windows PowerShell
# API + Admin + Shop
# =========================================================

$ErrorActionPreference = "Stop"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$API_DIR = Join-Path $ROOT_DIR "chawkbazar-api"
$ADMIN_DIR = Join-Path $ROOT_DIR "admin\rest"
$SHOP_DIR = Join-Path $ROOT_DIR "shop"

function Stop-WithMessage($message) {
    Write-Host ""
    Write-Host $message -ForegroundColor Red
    Write-Host ""
    exit 1
}

function Ensure-Line($file, $key, $value) {
    if (!(Test-Path $file)) {
        New-Item -Path $file -ItemType File | Out-Null
    }

    $content = Get-Content $file -Raw

    if ($content -match "(?m)^$key=") {
        $content = $content -replace "(?m)^$key=.*$", "$key=$value"
        Set-Content $file $content
    } else {
        Add-Content $file "`n$key=$value"
    }
}

Write-Host "Checking Docker..." -ForegroundColor Cyan

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage "Docker is not running. Please start Docker Desktop first."
}

# =========================================================
# Laravel API
# =========================================================

Write-Host "Starting Laravel API..." -ForegroundColor Cyan

if (!(Test-Path $API_DIR)) {
    Stop-WithMessage "API folder not found: $API_DIR"
}

Set-Location $API_DIR

if (!(Test-Path ".env")) {
    Copy-Item ".env.example" ".env" -Force
}

# Required for Laravel Sail Dockerfile build
Ensure-Line ".env" "WWWGROUP" "1000"
Ensure-Line ".env" "WWWUSER" "1337"

# Optional but safer for local Sail
Ensure-Line ".env" "APP_URL" "http://localhost"
Ensure-Line ".env" "DB_HOST" "mysql"
Ensure-Line ".env" "DB_PORT" "3306"

if (!(Test-Path "vendor")) {
    Write-Host "Vendor folder missing. Installing Composer dependencies safely..." -ForegroundColor Yellow

    docker build -t redq/php81-composer .

    docker run --rm `
      -e COMPOSER_MEMORY_LIMIT=-1 `
      -v "$($PWD.Path):/app" `
      -w /app `
      redq/php81-composer:latest `
      sh -lc "rm -rf /tmp/chawk-build && mkdir -p /tmp/chawk-build && cp -a /app/. /tmp/chawk-build/ && cd /tmp/chawk-build && rm -rf vendor composer.lock && composer update -W --prefer-dist --no-cache --no-progress && rm -rf /app/vendor /app/composer.lock && cp -a vendor composer.lock /app/"

    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "Composer install failed. Send the Composer error."
    }
}

if (!(Test-Path "docker-compose.yml")) {
    Write-Host "docker-compose.yml missing. Installing Laravel Sail..." -ForegroundColor Yellow

    docker run --rm `
      -v "$($PWD.Path):/app" `
      -w /app `
      redq/php81-composer:latest `
      php artisan sail:install --with=mysql

    if ($LASTEXITCODE -ne 0) {
        Stop-WithMessage "Laravel Sail install failed. Send the error."
    }
}

Write-Host "Stopping old API containers..." -ForegroundColor Yellow
docker compose down

Write-Host "Building API containers..." -ForegroundColor Yellow
docker compose build --no-cache

if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage "Docker Compose build failed. Send the build error."
}

Write-Host "Starting API containers..." -ForegroundColor Yellow
docker compose up -d

if ($LASTEXITCODE -ne 0) {
    Stop-WithMessage "Docker Compose up failed. Send the error."
}

Write-Host "Waiting for containers..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "Detecting Laravel service..." -ForegroundColor Cyan

$services = docker compose ps --services
$runningServices = docker compose ps --services --filter "status=running"

Write-Host "All services:" -ForegroundColor DarkGray
$services | ForEach-Object { Write-Host " - $_" -ForegroundColor DarkGray }

Write-Host "Running services:" -ForegroundColor DarkGray
$runningServices | ForEach-Object { Write-Host " - $_" -ForegroundColor DarkGray }

$laravelService = $null

if ($runningServices -contains "laravel.test") {
    $laravelService = "laravel.test"
} elseif ($runningServices -contains "app") {
    $laravelService = "app"
} elseif ($runningServices -contains "api") {
    $laravelService = "api"
} else {
    foreach ($svc in $runningServices) {
        if ($svc -ne "mysql" -and $svc -ne "redis" -and $svc -ne "meilisearch" -and $svc -ne "mailpit" -and $svc -ne "selenium") {
            $laravelService = $svc
            break
        }
    }
}

if (!$laravelService) {
    docker compose ps
    Stop-WithMessage "No running Laravel app service found. Check Docker Desktop containers and send docker compose ps output."
}

Write-Host "Using Laravel service: $laravelService" -ForegroundColor Green

Write-Host "Running Laravel setup commands..." -ForegroundColor Cyan

docker compose exec $laravelService php artisan key:generate --force

docker compose exec $laravelService php artisan migrate --seed --force

docker compose exec $laravelService php artisan storage:link

docker compose exec $laravelService php artisan marvel:install

Write-Host "API should be running at http://localhost" -ForegroundColor Green

# =========================================================
# Admin
# =========================================================

Write-Host "Starting Admin Dashboard on port 3002..." -ForegroundColor Cyan

if (!(Test-Path $ADMIN_DIR)) {
    Stop-WithMessage "Admin folder not found: $ADMIN_DIR"
}

Set-Location $ADMIN_DIR

if (!(Test-Path ".env")) {
    Copy-Item ".env.template" ".env" -Force
}

if (!(Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "pnpm not found. Installing pnpm globally..." -ForegroundColor Yellow
    npm install -g pnpm
}

pnpm install

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$ADMIN_DIR'; pnpm run dev"

# =========================================================
# Shop
# =========================================================

Write-Host "Starting Shop Frontend on port 3003..." -ForegroundColor Cyan

if (!(Test-Path $SHOP_DIR)) {
    Stop-WithMessage "Shop folder not found: $SHOP_DIR"
}

Set-Location $SHOP_DIR

if (!(Test-Path ".env")) {
    Copy-Item ".env.template" ".env" -Force
}

pnpm install

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$SHOP_DIR'; pnpm run dev"

Write-Host ""
Write-Host "All services started:" -ForegroundColor Green
Write-Host "API:   http://localhost"
Write-Host "Admin: http://localhost:3002"
Write-Host "Shop:  http://localhost:3003"
Write-Host ""
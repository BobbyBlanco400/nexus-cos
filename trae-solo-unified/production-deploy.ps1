#!/usr/bin/env pwsh
# NEXUS COS Production Deployment Script
# For deployment to nexuscos.online

Write-Host "Starting NEXUS COS Production Deployment..." -ForegroundColor Green

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Docker
try {
    docker --version
    Write-Host "✓ Docker is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker is not available. Please install Docker first." -ForegroundColor Red
    exit 1
}

# Check Docker Compose
try {
    docker-compose --version
    Write-Host "✓ Docker Compose is available" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker Compose is not available. Please install Docker Compose first." -ForegroundColor Red
    exit 1
}

# SSL Certificate Setup
Write-Host "Setting up SSL certificates..." -ForegroundColor Yellow

if (Test-Path "./nginx/ssl/nexuscos.crt" -and Test-Path "./nginx/ssl/nexuscos.key") {
    $certContent = Get-Content "./nginx/ssl/nexuscos.crt" -Raw
    if ($certContent -like "*placeholder*" -or $certContent -like "*BEGIN CERTIFICATE*" -and $certContent.Length -lt 500) {
        Write-Host "⚠ Placeholder SSL certificates detected!" -ForegroundColor Yellow
        Write-Host "For production deployment, you need valid SSL certificates." -ForegroundColor Yellow
        Write-Host "Options:" -ForegroundColor Cyan
        Write-Host "1. Use Let's Encrypt (recommended):" -ForegroundColor White
        Write-Host "   certbot certonly --standalone -d nexuscos.online -d www.nexuscos.online" -ForegroundColor Gray
        Write-Host "2. Purchase from a Certificate Authority" -ForegroundColor White
        Write-Host "3. Continue with self-signed certificates (not recommended for production)" -ForegroundColor White
        
        $choice = Read-Host "Continue anyway? (y/N)"
        if ($choice -ne "y" -and $choice -ne "Y") {
            Write-Host "Deployment cancelled. Please setup valid SSL certificates first." -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "✓ SSL certificates found" -ForegroundColor Green
    }
} else {
    Write-Host "✗ SSL certificates not found. Creating self-signed certificates..." -ForegroundColor Yellow
    
    # Try to create self-signed certificates
    try {
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
            -keyout "./nginx/ssl/nexuscos.key" `
            -out "./nginx/ssl/nexuscos.crt" `
            -subj "/C=US/ST=State/L=City/O=NEXUS COS/CN=nexuscos.online"
        Write-Host "✓ Self-signed certificates created" -ForegroundColor Green
    } catch {
        Write-Host "⚠ OpenSSL not available. Using placeholder certificates." -ForegroundColor Yellow
        Write-Host "Please replace with valid certificates before production use." -ForegroundColor Yellow
    }
}

# Environment Setup
Write-Host "Setting up production environment..." -ForegroundColor Yellow

# Create production environment file
$envContent = @"
NODE_ENV=production
ENVIRONMENT=production
VITE_API_URL=https://nexuscos.online/api/v1
API_URL=https://nexuscos.online/api/v2
DOMAIN=nexuscos.online
SSL_ENABLED=true
"@

Set-Content -Path ".env.production" -Value $envContent
Write-Host "✓ Production environment configured" -ForegroundColor Green

# Build and Deploy
Write-Host "Building and deploying services..." -ForegroundColor Yellow

# Stop existing services
docker-compose down --remove-orphans

# Build with production settings
docker-compose -f docker-compose.yml --env-file .env.production build --no-cache

# Start services
docker-compose -f docker-compose.yml --env-file .env.production up -d

# Wait for services to start
Write-Host "Waiting for services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 45

# Health Check
Write-Host "Performing health checks..." -ForegroundColor Yellow

$services = @(
    @{name="Frontend (HTTPS)"; url="https://nexuscos.online"},
    @{name="Admin Panel (HTTPS)"; url="https://nexuscos.online/admin"},
    @{name="Node API (HTTPS)"; url="https://nexuscos.online/api/v1"},
    @{name="Python API (HTTPS)"; url="https://nexuscos.online/api/v2"},
    @{name="TV Radio (HTTPS)"; url="https://nexuscos.online/tv"},
    @{name="COS Modules (HTTPS)"; url="https://nexuscos.online/modules"}
)

$healthyServices = 0
foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.url -TimeoutSec 15 -UseBasicParsing -SkipCertificateCheck
        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 301 -or $response.StatusCode -eq 302) {
            Write-Host "✓ $($service.name) is healthy" -ForegroundColor Green
            $healthyServices++
        } else {
            Write-Host "⚠ $($service.name) returned status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "✗ $($service.name) is not responding: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Deployment Summary
Write-Host "\n" + "="*60 -ForegroundColor Cyan
Write-Host "NEXUS COS PRODUCTION DEPLOYMENT COMPLETE" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "\nDeployment Status:" -ForegroundColor White
Write-Host "- Healthy Services: $healthyServices/$($services.Count)" -ForegroundColor $(if($healthyServices -eq $services.Count) {"Green"} else {"Yellow"})
Write-Host "- Domain: nexuscos.online" -ForegroundColor Cyan
Write-Host "- SSL: Enabled" -ForegroundColor Green

Write-Host "\nAccess URLs:" -ForegroundColor White
Write-Host "- Main Site: https://nexuscos.online" -ForegroundColor Cyan
Write-Host "- Admin Panel: https://nexuscos.online/admin" -ForegroundColor Cyan
Write-Host "- TV/Radio: https://nexuscos.online/tv" -ForegroundColor Cyan
Write-Host "- API v1: https://nexuscos.online/api/v1" -ForegroundColor Cyan
Write-Host "- API v2: https://nexuscos.online/api/v2" -ForegroundColor Cyan

Write-Host "\nManagement Commands:" -ForegroundColor White
Write-Host "- View logs: docker-compose logs -f" -ForegroundColor Gray
Write-Host "- Stop services: docker-compose down" -ForegroundColor Gray
Write-Host "- Restart: docker-compose restart" -ForegroundColor Gray
Write-Host "- Update: git pull && docker-compose up -d --build" -ForegroundColor Gray

if ($healthyServices -eq $services.Count) {
    Write-Host "\n🎉 All services are running successfully!" -ForegroundColor Green
} else {
    Write-Host "\n⚠ Some services may need attention. Check logs for details." -ForegroundColor Yellow
}

Write-Host "\nDeployment completed at $(Get-Date)" -ForegroundColor Gray
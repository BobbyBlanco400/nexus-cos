# NEXUS COS Production Deployment Script
# PowerShell script for complete production infrastructure setup

Write-Host "🚀 NEXUS COS Production Deployment Starting..." -ForegroundColor Green

# Step 1: Environment Setup
Write-Host "📋 Setting up environment variables..." -ForegroundColor Yellow
$env:COMPOSE_PROJECT_NAME = "nexus-cos"
$env:NODE_ENV = "production"
$env:DB_PASSWORD = "nexus_secure_2024"
$env:JWT_SECRET = "nexus_jwt_secret_key_2024"
$env:REDIS_PASSWORD = "redis_secure_2024"

# Step 2: SSL Certificate Generation (Self-signed for demo)
Write-Host "🔐 Generating SSL certificates..." -ForegroundColor Yellow
if (!(Test-Path "ssl")) {
    New-Item -ItemType Directory -Path "ssl"
}

# Generate self-signed certificate for localhost
$certParams = @{
    Subject = "CN=localhost"
    DnsName = @("localhost", "nexus-cos.local", "127.0.0.1")
    CertStoreLocation = "Cert:\CurrentUser\My"
    KeyAlgorithm = "RSA"
    KeyLength = 2048
    NotAfter = (Get-Date).AddYears(1)
}

try {
    $cert = New-SelfSignedCertificate @certParams
    Write-Host "✅ SSL certificate generated successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  SSL certificate generation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Docker Network Setup
Write-Host "🌐 Setting up Docker networks..." -ForegroundColor Yellow
docker network create nexus-cos-network --driver bridge --subnet=172.20.0.0/16 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker network created successfully" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Docker network already exists or creation skipped" -ForegroundColor Blue
}

# Step 4: Build All Services
Write-Host "🔨 Building all Docker services..." -ForegroundColor Yellow
docker-compose -f nexus-cos-modular-os.yml build --parallel

# Step 5: Deploy Core Infrastructure
Write-Host "🏗️  Deploying core infrastructure..." -ForegroundColor Yellow
docker-compose -f nexus-cos-modular-os.yml up -d nginx-gateway nexus-database nexus-cache service-registry

# Step 6: Deploy Backend Services
Write-Host "⚙️  Deploying backend services..." -ForegroundColor Yellow
docker-compose -f nexus-cos-modular-os.yml up -d nexus-backend-api puabo-ai-service blockchain-service

# Step 7: Deploy Frontend Applications
Write-Host "🎨 Deploying frontend applications..." -ForegroundColor Yellow
docker-compose -f nexus-cos-modular-os.yml up -d puabo-os-frontend admin-dashboard mobile-app-backend

# Step 8: Deploy Specialized Modules
Write-Host "📺 Deploying specialized modules..." -ForegroundColor Yellow
docker-compose -f nexus-cos-modular-os.yml up -d v-caster streamcore v-screen v-stage

# Step 9: Health Check
Write-Host "🔍 Performing health checks..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

$services = @(
    @{Name="Nginx Gateway"; URL="http://localhost:80"; Port=80},
    @{Name="Main Frontend"; URL="http://localhost:5173"; Port=5173},
    @{Name="Admin Panel"; URL="http://localhost:3001"; Port=3001},
    @{Name="Backend API"; URL="http://localhost:3002"; Port=3002},
    @{Name="TV/Radio Interface"; URL="http://localhost:8080"; Port=8080}
)

Write-Host "`n🌟 NEXUS COS Production Deployment Status:" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

foreach ($service in $services) {
    try {
        $response = Invoke-WebRequest -Uri $service.URL -TimeoutSec 5 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $($service.Name) - Running on port $($service.Port)" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ $($service.Name) - Not responding on port $($service.Port)" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Access Points:" -ForegroundColor Cyan
Write-Host "🌐 Main Application: http://localhost:5173" -ForegroundColor White
Write-Host "🛠️  Admin Panel: http://localhost:3001" -ForegroundColor White
Write-Host "📺 TV/Radio Interface: http://localhost:8080" -ForegroundColor White
Write-Host "🔧 API Gateway: http://localhost:80" -ForegroundColor White
Write-Host "📱 Mobile Backend: http://localhost:3002" -ForegroundColor White

Write-Host "`n🚀 NEXUS COS Production Deployment Complete!" -ForegroundColor Green
Write-Host "📊 Monitor logs with: docker-compose -f nexus-cos-modular-os.yml logs -f" -ForegroundColor Yellow
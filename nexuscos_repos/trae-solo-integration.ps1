#!/usr/bin/env pwsh
# TRAE Solo Master Integration Script
# Combines all PUABO repositories into unified deployment

Write-Host "🚀 TRAE Solo Master Integration Starting..." -ForegroundColor Cyan

# Create unified project structure
$unifiedPath = "C:\Users\wecon\Downloads\nexus-cos-main\trae-solo-unified"
New-Item -ItemType Directory -Path $unifiedPath -Force | Out-Null

Write-Host "📁 Creating unified service structure..." -ForegroundColor Yellow

# Create service directories and copy content
$services = @{
    "frontend" = "puabo-os-2025"
    "admin" = "PUABO-OS-V200\admin"
    "backend-node" = "node-auth-api"
    "backend-python" = "PUABO-OS-V200\backend"
    "tv-radio" = "puabo20.github.io"
    "cos-modules" = "puabo-cos"
}

foreach ($service in $services.Keys) {
    $servicePath = Join-Path $unifiedPath $service
    New-Item -ItemType Directory -Path $servicePath -Force | Out-Null
    
    $sourceDir = $services[$service]
    $sourcePath = Join-Path (Get-Location) $sourceDir
    
    if (Test-Path $sourcePath) {
        Write-Host "  ✅ Copying $service from $sourceDir" -ForegroundColor Green
        Copy-Item -Path "$sourcePath\*" -Destination $servicePath -Recurse -Force
    } else {
        Write-Host "  ⚠️  Source not found: $sourceDir" -ForegroundColor Red
    }
}

# Create Docker Compose file
Write-Host "🐳 Creating Docker Compose configuration..." -ForegroundColor Yellow
$dockerComposePath = Join-Path $unifiedPath "docker-compose.yml"
$dockerComposeContent = @"
version: '3.8'
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - VITE_API_URL=http://backend-node:5000
    depends_on:
      - backend-node
      - backend-python

  admin:
    build:
      context: ./admin
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    environment:
      - NODE_ENV=production
      - VITE_API_URL=http://backend-python:8000
    depends_on:
      - backend-python

  backend-node:
    build:
      context: ./backend-node
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
      - PORT=5000
    volumes:
      - ./data:/app/data

  backend-python:
    build:
      context: ./backend-python
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - ENVIRONMENT=production
      - PORT=8000
    volumes:
      - ./data:/app/data

  tv-radio:
    build:
      context: ./tv-radio
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    environment:
      - NGINX_HOST=localhost
      - NGINX_PORT=80

  cos-modules:
    build:
      context: ./cos-modules
      dockerfile: Dockerfile
    ports:
      - "9000:9000"
    environment:
      - PORT=9000

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - frontend
      - admin
      - backend-node
      - backend-python
      - tv-radio
      - cos-modules

volumes:
  data:
"@

Set-Content -Path $dockerComposePath -Value $dockerComposeContent
Write-Host "✅ Docker Compose configuration created" -ForegroundColor Green

# Create Nginx directory and configuration
Write-Host "🌐 Creating Nginx configuration..." -ForegroundColor Yellow
$nginxDir = Join-Path $unifiedPath "nginx"
New-Item -ItemType Directory -Path $nginxDir -Force | Out-Null

$nginxConfigPath = Join-Path $nginxDir "nginx.conf"
$nginxContent = @"
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }
    
    upstream admin {
        server admin:3001;
    }
    
    upstream backend_node {
        server backend-node:5000;
    }
    
    upstream backend_python {
        server backend-python:8000;
    }
    
    upstream tv_radio {
        server tv-radio:80;
    }
    
    upstream cos_modules {
        server cos-modules:9000;
    }

    server {
        listen 80;
        server_name nexuscos.online www.nexuscos.online;
        
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
        
        location /admin {
            proxy_pass http://admin;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
        
        location /api/v1 {
            proxy_pass http://backend_node;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
        
        location /api/v2 {
            proxy_pass http://backend_python;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
        
        location /tv {
            proxy_pass http://tv_radio;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
        
        location /modules {
            proxy_pass http://cos_modules;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }
}
"@

Set-Content -Path $nginxConfigPath -Value $nginxContent
Write-Host "✅ Nginx configuration created" -ForegroundColor Green

# Create TRAE Solo configuration
Write-Host "⚡ Creating TRAE Solo configuration..." -ForegroundColor Yellow
$traeSoloPath = Join-Path $unifiedPath "trae-solo.yaml"
$traeSoloContent = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: trae-solo-config
  namespace: default
data:
  services.yaml: |
    services:
      - name: nexus-cos-frontend
        type: web
        port: 3000
        replicas: 2
        health_check: /health
        
      - name: nexus-cos-admin
        type: web
        port: 3001
        replicas: 1
        health_check: /health
        
      - name: nexus-cos-backend-node
        type: api
        port: 5000
        replicas: 2
        health_check: /api/health
        
      - name: nexus-cos-backend-python
        type: api
        port: 8000
        replicas: 2
        health_check: /health
        
      - name: nexus-cos-tv-radio
        type: media
        port: 8080
        replicas: 1
        health_check: /
        
      - name: nexus-cos-modules
        type: modules
        port: 9000
        replicas: 1
        health_check: /health
        
    routing:
      domain: nexuscos.online
      ssl: true
      paths:
        - path: /
          service: nexus-cos-frontend
        - path: /admin
          service: nexus-cos-admin
        - path: /api/v1
          service: nexus-cos-backend-node
        - path: /api/v2
          service: nexus-cos-backend-python
        - path: /tv
          service: nexus-cos-tv-radio
        - path: /modules
          service: nexus-cos-modules
"@

Set-Content -Path $traeSoloPath -Value $traeSoloContent
Write-Host "✅ TRAE Solo configuration created" -ForegroundColor Green

# Create deployment script
Write-Host "📋 Creating deployment script..." -ForegroundColor Yellow
$deployScriptPath = Join-Path $unifiedPath "deploy.ps1"
$deployContent = @"
#!/usr/bin/env pwsh
# TRAE Solo Deployment Script

Write-Host "🚀 Starting TRAE Solo Deployment..." -ForegroundColor Cyan

# Build all services
Write-Host "🔨 Building services..." -ForegroundColor Yellow
docker-compose build --parallel

# Start services
Write-Host "🌟 Starting services..." -ForegroundColor Yellow
docker-compose up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "🎉 TRAE Solo Deployment Complete!" -ForegroundColor Green
Write-Host "🌐 Access your application at: http://localhost" -ForegroundColor Cyan
Write-Host "🔧 Admin panel at: http://localhost/admin" -ForegroundColor Cyan
Write-Host "📺 TV Radio at: http://localhost/tv" -ForegroundColor Cyan
"@

Set-Content -Path $deployScriptPath -Value $deployContent
Write-Host "✅ Deployment script created" -ForegroundColor Green

# Summary
Write-Host "`n🎉 TRAE Solo Integration Complete!" -ForegroundColor Green
Write-Host "📁 Unified project created at: $unifiedPath" -ForegroundColor Cyan
Write-Host "🐳 Docker Compose ready for deployment" -ForegroundColor Cyan
Write-Host "🌐 Nginx configured for production" -ForegroundColor Cyan
Write-Host "⚡ TRAE Solo configuration ready" -ForegroundColor Cyan
Write-Host "`n🚀 Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd $unifiedPath" -ForegroundColor White
Write-Host "  2. .\deploy.ps1" -ForegroundColor White
Write-Host "  3. Configure SSL certificates" -ForegroundColor White
Write-Host "  4. Deploy to production" -ForegroundColor White

Write-Host "`n✨ TRAE Solo Master Integration Complete!" -ForegroundColor Magenta
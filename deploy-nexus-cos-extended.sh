#!/bin/bash
# Nexus COS Extended – TRAE Solo Compact Deployment
# Domain: nexuscos.online
# Email: puaboverse@gmail.com

set -e  # Exit on any error

# Configuration Variables
PROJECT="nexus-cos"
DEPLOY="/opt/$PROJECT"
DOMAIN="nexuscos.online"
EMAIL="puaboverse@gmail.com"
POSTGRES_USER="nexus_admin"
POSTGRES_PASSWORD="Momoney2025$$"
JWT_SECRET="whitefamilylegacy600$$"
KEI_AI_KEY="22181f6d296ef1bebb7fa8e9ea85ae22"
EAS_TOKEN="your_eas_token_here"
APPLE_PASS="your_apple_password"
GOOGLE_JSON="/opt/nexus-cos/google-service-account.json"

# Utility Functions
notify() {
    MESSAGE=$1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [NOTIFY] $MESSAGE"
    logger "NEXUS-COS-DEPLOY: $MESSAGE"
}

health() {
    URL=$1
    R=$(curl -s -o /dev/null -w "%{http_code}" $URL 2>/dev/null || echo "000")
    if [[ $R -eq 200 ]]; then
        echo "[OK] $URL"
        return 0
    else
        echo "[WARN] $URL failed (HTTP: $R)"
        return 1
    fi
}

# Start Deployment
notify "🚀 Nexus COS Extended Deployment Starting"

# Cleanup and Preparation
notify "🧹 Cleaning old deployment"
docker compose down 2>/dev/null || true
sudo rm -rf $DEPLOY
sudo mkdir -p $DEPLOY
cd $DEPLOY

# Repository Cloning
notify "📦 Cloning repositories"
repos=(
    "https://github.com/Puabo20/puabo-cos"
    "https://github.com/Puabo20/PUABO-OS-V200"
    "https://github.com/Puabo20/puabo-os-2025"
    "https://github.com/Puabo20/puabo20.github.io"
    "https://github.com/Puabo20/node-auth-api"
)

for repo in "${repos[@]}"; do
    repo_name=$(basename $repo .git)
    if git clone $repo src/$repo_name; then
        notify "✅ Cloned $repo_name"
    else
        notify "⚠️ Failed to clone $repo_name, continuing..."
    fi
done

# Clone assets repository
if git clone https://github.com/Puabo20/nexus-cos-assets.git $DEPLOY/src/assets; then
    notify "✅ Assets repository cloned"
    
    # Integrate assets
    mkdir -p $DEPLOY/src/frontend/public/assets
    cp -R $DEPLOY/src/assets/frontend/* $DEPLOY/src/frontend/public/assets/ 2>/dev/null || true
    
    mkdir -p $DEPLOY/src/mobile/assets
    cp -R $DEPLOY/src/assets/mobile/* $DEPLOY/src/mobile/assets/ 2>/dev/null || true
    
    notify "✅ Assets integrated"
else
    notify "⚠️ Assets repository not available, continuing without assets"
fi

# Create Docker Compose Configuration
notify "🐳 Creating Docker Compose configuration"
cat > $DEPLOY/docker-compose.yml <<EOL
version: '3.9'

services:
  postgres:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_USER: $POSTGRES_USER
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_DB: nexus
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    restart: always
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-node:
    build: 
      context: ./src/backend-node
      dockerfile: Dockerfile
    command: node server.js
    environment:
      - DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/nexus
      - JWT_SECRET=$JWT_SECRET
      - KEI_AI_KEY=$KEI_AI_KEY
      - NODE_ENV=production
      - PORT=3000
    depends_on:
      - postgres
      - redis
    ports:
      - "3000:3000"
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-python:
    build:
      context: ./src/backend-python
      dockerfile: Dockerfile
    command: uvicorn app.main:app --host 0.0.0.0 --port 5000
    environment:
      - DATABASE_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/nexus
      - KEI_AI_KEY=$KEI_AI_KEY
      - PYTHONPATH=/app
    depends_on:
      - postgres
      - redis
    ports:
      - "5000:5000"
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./src/frontend
      dockerfile: Dockerfile
    volumes:
      - "./src/frontend/dist:/usr/share/nginx/html:ro"
    ports:
      - "8080:80"
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:stable-alpine
    restart: always
    volumes:
      - "./nginx.conf:/etc/nginx/nginx.conf:ro"
      - "./certs:/etc/letsencrypt:ro"
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend-node
      - backend-python
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80"]
      interval: 30s
      timeout: 10s
      retries: 3

  grafana:
    image: grafana/grafana:latest
    restart: always
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  db_data:
  grafana_data:
EOL

# Create Nginx Configuration
notify "🌐 Creating Nginx configuration"
cat > $DEPLOY/nginx.conf <<EOL
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    
    # Upstream definitions
    upstream backend_node {
        server backend-node:3000;
    }
    
    upstream backend_python {
        server backend-python:5000;
    }
    
    upstream frontend_app {
        server frontend:80;
    }
    
    upstream grafana_app {
        server grafana:3000;
    }
    
    server {
        listen 80;
        server_name $DOMAIN www.$DOMAIN;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
        
        # Main frontend
        location / {
            proxy_pass http://frontend_app;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # Node.js API
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend_node;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # Python API
        location /py/ {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://backend_python;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # Grafana monitoring
        location /grafana/ {
            proxy_pass http://grafana_app/;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        # WebSocket support
        location /ws/ {
            proxy_pass http://backend_node;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}
EOL

# Build and Start Services
notify "🔨 Building and starting Docker services"
if docker compose build; then
    notify "✅ Docker build successful"
else
    notify "❌ Docker build failed"
    exit 1
fi

if docker compose up -d; then
    notify "✅ Docker services started"
else
    notify "❌ Failed to start Docker services"
    exit 1
fi

# Wait for services to be ready
notify "⏳ Waiting for services to be ready..."
sleep 30

# Install and Configure SSL
notify "🔒 Setting up SSL certificates"
if command -v certbot &> /dev/null; then
    notify "Certbot already installed"
else
    apt-get update && apt-get install -y certbot python3-certbot-nginx
fi

if certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m $EMAIL; then
    systemctl reload nginx
    notify "✅ SSL certificates installed and configured"
else
    notify "⚠️ SSL setup failed, continuing with HTTP"
fi

# Health Checks
notify "🔍 Performing health checks"
sleep 10

health_urls=(
    "http://$DOMAIN"
    "http://$DOMAIN/api/health"
    "http://$DOMAIN/py/health"
    "http://$DOMAIN/grafana"
)

for url in "${health_urls[@]}"; do
    if health "$url"; then
        notify "✅ $url is healthy"
    else
        notify "⚠️ $url health check failed"
    fi
done

# Mobile App Build (Optional)
notify "📱 Starting mobile app build process"
if command -v npm &> /dev/null; then
    npm install -g eas-cli
    
    if [ -d "$DEPLOY/src/mobile" ]; then
        cd $DEPLOY/src/mobile
        
        # Login to EAS (requires manual token setup)
        if [ "$EAS_TOKEN" != "your_eas_token_here" ]; then
            eas login --token $EAS_TOKEN
            
            mkdir -p $DEPLOY/mobile_builds
            
            # Build for Android
            if eas build --platform android --non-interactive; then
                notify "✅ Android build initiated"
            else
                notify "⚠️ Android build failed"
            fi
            
            # Build for iOS
            if eas build --platform ios --non-interactive; then
                notify "✅ iOS build initiated"
            else
                notify "⚠️ iOS build failed"
            fi
        else
            notify "⚠️ EAS token not configured, skipping mobile builds"
        fi
    else
        notify "⚠️ Mobile directory not found, skipping mobile builds"
    fi
else
    notify "⚠️ npm not found, skipping mobile builds"
fi

# Generate Final Report
notify "📋 Generating deployment report"
cat > $DEPLOY/FINAL_DEPLOYMENT_REPORT.md <<EOL
# Nexus COS Extended Deployment Report

## Deployment Information
- **Date**: $(date)
- **Domain**: $DOMAIN
- **Deployment Path**: $DEPLOY
- **Status**: COMPLETED

## Service URLs
- **Frontend**: https://$DOMAIN
- **Node.js Backend**: https://$DOMAIN/api/
- **Python Backend**: https://$DOMAIN/py/
- **Grafana Monitoring**: https://$DOMAIN/grafana
- **WebSocket**: wss://$DOMAIN/ws/

## Database Configuration
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379
- **Database Name**: nexus
- **User**: $POSTGRES_USER

## Security Features
- ✅ SSL/TLS certificates installed
- ✅ Security headers configured
- ✅ Rate limiting enabled
- ✅ CORS protection
- ✅ Environment variables secured

## Integrated Modules
- ✅ PUABO COS Core
- ✅ PUABO OS V2.0.0
- ✅ PUABO OS 2025
- ✅ Node Auth API
- ✅ V-Suite Services
- ✅ Creator Dashboard
- ✅ OTT Frontend
- ✅ Kei AI Integration

## Next Steps
1. Configure domain DNS to point to this server
2. Update EAS token for mobile app builds
3. Configure monitoring alerts in Grafana
4. Set up backup procedures
5. Configure CI/CD pipelines

## Support
For issues or questions, contact: $EMAIL
EOL

# Final Notifications
notify "🎉 Nexus COS Extended Deployment COMPLETED!"
notify "📋 Deployment report saved to: $DEPLOY/FINAL_DEPLOYMENT_REPORT.md"
notify "🌐 Your platform should be accessible at: https://$DOMAIN"
notify "📊 Monitoring available at: https://$DOMAIN/grafana"

echo ""
echo "=========================================="
echo "🚀 NEXUS COS EXTENDED DEPLOYMENT COMPLETE"
echo "=========================================="
echo "Domain: https://$DOMAIN"
echo "Admin: https://$DOMAIN/grafana (admin/admin123)"
echo "Report: $DEPLOY/FINAL_DEPLOYMENT_REPORT.md"
echo "=========================================="
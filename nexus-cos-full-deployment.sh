#!/bin/bash

# Nexus COS Full Deployment + Verification Script
# Project: nexus-cos
# Domain: nexuscos.online
# Email: puaboverse@gmail.com

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="nexus-cos"
DOMAIN="nexuscos.online"
EMAIL="puaboverse@gmail.com"
DEPLOY_PATH="/opt/nexus-cos"
VPS_HOST="75.208.155.161"
SSH_USER="root"
SSH_PASSWORD="${SSH_PASSWORD:-}"

# Secrets (MUST be set as environment variables before running this script)
# Example: export POSTGRES_PASSWORD=your_secure_password
export POSTGRES_USER="${POSTGRES_USER:-nexus_admin}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:?POSTGRES_PASSWORD environment variable is required}"
export JWT_SECRET="${JWT_SECRET:?JWT_SECRET environment variable is required}"
export EAS_TOKEN="${EAS_TOKEN:?EAS_TOKEN environment variable is required}"
export APPLE_APP_SPECIFIC_PASSWORD="${APPLE_APP_SPECIFIC_PASSWORD:?APPLE_APP_SPECIFIC_PASSWORD environment variable is required}"
export GOOGLE_SERVICE_JSON="${GOOGLE_SERVICE_JSON:-/opt/nexus-cos/google-service-account.json}"
export SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
export EMAIL_SMTP_SERVER="${EMAIL_SMTP_SERVER:-smtp.yourprovider.com}"
export EMAIL_SMTP_PORT="${EMAIL_SMTP_PORT:-587}"
export EMAIL_USER="${EMAIL_USER:?EMAIL_USER environment variable is required}"
export EMAIL_PASSWORD="${EMAIL_PASSWORD:?EMAIL_PASSWORD environment variable is required}"
export EMAIL_TO="${EMAIL_TO:?EMAIL_TO environment variable is required}"
export KEI_AI_KEY="${KEI_AI_KEY:?KEI_AI_KEY environment variable is required}"

# Repositories to clone and merge
declare -a REPOS=(
    "https://github.com/Puabo20/puabo-cos"
    "https://github.com/Puabo20/PUABO-OS-V200"
    "https://github.com/Puabo20/puabo-os-2025"
    "https://github.com/Puabo20/puabo20.github.io"
    "https://github.com/Puabo20/node-auth-api"
    "https://github.com/BobbyBlanco400/PUABO-OS"
    "https://github.com/BobbyBlanco400/nexus-cos"
)

# Logging setup
LOG_FILE="/opt/nexus-cos/deployment.log"
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "$LOG_FILE"
}

# Print functions
print_header() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}➤ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Notification function
notify() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local full_message="[$timestamp] Nexus COS Deployment: $message"
    
    log "INFO" "$message"
    
    # Slack notification
    if [[ -n "$SLACK_WEBHOOK_URL" && "$SLACK_WEBHOOK_URL" != "your_slack_webhook_url_here" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\": \"$full_message\"}" \
            "$SLACK_WEBHOOK_URL" 2>/dev/null || true
    fi
    
    # Email notification
    if [[ -n "$EMAIL_USER" && "$EMAIL_USER" != "your_email@domain.com" ]]; then
        echo -e "Subject: Nexus COS Deployment\n\n$full_message" | \
        msmtp --host="$EMAIL_SMTP_SERVER" --port="$EMAIL_SMTP_PORT" \
              --auth=on --user="$EMAIL_USER" \
              --passwordeval="echo $EMAIL_PASSWORD" "$EMAIL_TO" 2>/dev/null || true
    fi
}

# Error handling
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Error occurred in script at line $line_number. Exit code: $exit_code"
    notify "❌ Deployment failed at line $line_number with exit code $exit_code"
    
    # Cleanup on error
    cleanup_on_error
    exit $exit_code
}

trap 'handle_error $LINENO' ERR

# Cleanup function
cleanup_on_error() {
    print_warning "Performing cleanup due to error..."
    
    # Stop any running containers
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "$DEPLOY_PATH/docker-compose.yml" down 2>/dev/null || true
    fi
    
    # Remove incomplete deployment
    if [[ -d "$DEPLOY_PATH/temp" ]]; then
        rm -rf "$DEPLOY_PATH/temp"
    fi
}

# Prerequisites check
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_deps=()
    
    # Check required commands
    local required_commands=("git" "docker" "docker-compose" "curl" "nginx")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_step "Installing missing dependencies..."
        
        # Update package list
        apt-get update
        
        # Install missing dependencies
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                "docker")
                    curl -fsSL https://get.docker.com -o get-docker.sh
                    sh get-docker.sh
                    systemctl start docker
                    systemctl enable docker
                    ;;
                "docker-compose")
                    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
                    chmod +x /usr/local/bin/docker-compose
                    ;;
                *)
                    apt-get install -y "$dep"
                    ;;
            esac
        done
    fi
    
    print_success "Prerequisites check completed"
}

# Clean old deployment
clean_old_deployment() {
    print_step "Cleaning old deployment..."
    
    # Stop existing containers
    if [[ -f "$DEPLOY_PATH/docker-compose.yml" ]]; then
        docker-compose -f "$DEPLOY_PATH/docker-compose.yml" down 2>/dev/null || true
    fi
    
    # Remove old files but preserve logs and backups
    if [[ -d "$DEPLOY_PATH" ]]; then
        find "$DEPLOY_PATH" -mindepth 1 -maxdepth 1 ! -name "logs" ! -name "backups" -exec rm -rf {} + 2>/dev/null || true
    fi
    
    # Create directory structure
    mkdir -p "$DEPLOY_PATH"/{src,logs,backups,mobile_builds,certs}
    
    notify "🧹 Cleaned old deployment directory"
    print_success "Old deployment cleaned"
}

# Clone and merge repositories
clone_and_merge_repos() {
    print_step "Cloning and merging repositories..."
    
    local temp_dir="$DEPLOY_PATH/temp"
    local merge_dir="$DEPLOY_PATH/src"
    local conflict_report="$DEPLOY_PATH/merge_report.txt"
    
    mkdir -p "$temp_dir" "$merge_dir"
    
    # Initialize conflict report
    echo "Nexus COS Repository Merge Report - $(date)" > "$conflict_report"
    echo "================================================" >> "$conflict_report"
    
    for repo in "${REPOS[@]}"; do
        local repo_name=$(basename "$repo" .git)
        local clone_path="$temp_dir/$repo_name"
        
        print_step "Cloning $repo_name..."
        
        if git clone "$repo" "$clone_path" 2>/dev/null; then
            print_success "Successfully cloned $repo_name"
            
            # Merge with deduplication (newest files win)
            if [[ -d "$clone_path" ]]; then
                # Copy files, preserving newer files
                rsync -av --update "$clone_path/" "$merge_dir/" 2>/dev/null || true
                
                # Log merge details
                echo "✅ Merged: $repo_name" >> "$conflict_report"
                find "$clone_path" -type f -name "*.js" -o -name "*.ts" -o -name "*.json" -o -name "*.py" | \
                    head -10 | sed 's/^/  - /' >> "$conflict_report"
            fi
        else
            print_warning "Failed to clone $repo_name (repository may not exist or be private)"
            echo "❌ Failed: $repo_name - Repository not accessible" >> "$conflict_report"
        fi
    done
    
    # Cleanup temp directory
    rm -rf "$temp_dir"
    
    notify "📦 Repositories cloned and merged successfully"
    print_success "Repository cloning and merging completed"
}

# Pull and integrate assets
integrate_assets() {
    print_step "Integrating assets..."
    
    local assets_dir="$DEPLOY_PATH/src/assets"
    mkdir -p "$assets_dir"
    
    # Try to clone assets repository
    if git clone "https://github.com/Puabo20/nexus-cos-assets.git" "$assets_dir" 2>/dev/null; then
        # Integrate frontend assets
        if [[ -d "$assets_dir/frontend" ]]; then
            mkdir -p "$DEPLOY_PATH/src/frontend/public/assets"
            cp -R "$assets_dir/frontend/"* "$DEPLOY_PATH/src/frontend/public/assets/" 2>/dev/null || true
        fi
        
        # Integrate mobile assets
        if [[ -d "$assets_dir/mobile" ]]; then
            mkdir -p "$DEPLOY_PATH/src/mobile/assets"
            cp -R "$assets_dir/mobile/"* "$DEPLOY_PATH/src/mobile/assets/" 2>/dev/null || true
        fi
        
        print_success "Assets integrated successfully"
    else
        print_warning "Assets repository not accessible, using default assets"
        
        # Create default assets
        mkdir -p "$DEPLOY_PATH/src/frontend/public/assets"
        mkdir -p "$DEPLOY_PATH/src/mobile/assets"
        
        # Create default favicon
        cat > "$DEPLOY_PATH/src/frontend/public/assets/favicon.svg" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" fill="#6366f1"/>
  <text x="50" y="60" text-anchor="middle" fill="white" font-size="30" font-family="Arial">N</text>
</svg>
EOF
    fi
    
    notify "✅ Assets integrated"
}

# Generate Docker Compose configuration
generate_docker_compose() {
    print_step "Generating Docker Compose configuration..."
    
    cat > "$DEPLOY_PATH/docker-compose.yml" << EOF
version: '3.9'

services:
  postgres:
    image: postgres:15
    restart: always
    environment:
      POSTGRES_USER: \${POSTGRES_USER}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
      POSTGRES_DB: nexus
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER} -d nexus"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-node:
    build: 
      context: ./src/backend
      dockerfile: Dockerfile
    restart: always
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgres://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@postgres:5432/nexus
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=\${JWT_SECRET}
      - KEI_AI_KEY=\${KEI_AI_KEY}
      - PORT=3000
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    ports:
      - "3000:3000"
    volumes:
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  backend-python:
    build:
      context: ./src/backend-python
      dockerfile: Dockerfile
    restart: always
    environment:
      - DATABASE_URL=postgres://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@postgres:5432/nexus
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    ports:
      - "5000:5000"
    volumes:
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    build:
      context: ./src/frontend
      dockerfile: Dockerfile
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./src/frontend/dist:/usr/share/nginx/html:ro
      - ./nginx/frontend.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - backend-node
      - backend-python

  nginx:
    image: nginx:stable-alpine
    restart: always
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./certs:/etc/letsencrypt:ro
      - ./logs/nginx:/var/log/nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend-node
      - backend-python
      - frontend
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  grafana:
    image: grafana/grafana:latest
    restart: always
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=\${POSTGRES_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana:/etc/grafana/provisioning
    ports:
      - "3001:3000"
    depends_on:
      - postgres

  prometheus:
    image: prom/prometheus:latest
    restart: always
    volumes:
      - ./monitoring/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'

volumes:
  db_data:
  redis_data:
  grafana_data:
  prometheus_data:

networks:
  default:
    name: nexus-cos-network
EOF

    print_success "Docker Compose configuration generated"
}

# Generate Nginx configuration
generate_nginx_config() {
    print_step "Generating Nginx configuration..."
    
    mkdir -p "$DEPLOY_PATH/nginx/conf.d"
    
    # Main nginx.conf
    cat > "$DEPLOY_PATH/nginx/nginx.conf" << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 100M;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;

    include /etc/nginx/conf.d/*.conf;
}
EOF

    # Site configuration
    cat > "$DEPLOY_PATH/nginx/conf.d/nexuscos.conf" << 'EOF'
# Upstream definitions
upstream backend_node {
    server backend-node:3000;
    keepalive 32;
}

upstream backend_python {
    server backend-python:5000;
    keepalive 32;
}

upstream frontend_app {
    server frontend:80;
    keepalive 32;
}

# HTTP to HTTPS redirect
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    
    # Let's Encrypt challenge
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect all other traffic to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozTLS:10m;
    ssl_session_tickets off;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;

    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # API routes
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://backend_node;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Python API routes
    location /py/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://backend_python/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Authentication endpoints with stricter rate limiting
    location /api/auth/ {
        limit_req zone=login burst=5 nodelay;
        proxy_pass http://backend_node;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static assets with caching
    location /assets/ {
        proxy_pass http://frontend_app;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options nosniff;
    }

    # Frontend application
    location / {
        proxy_pass http://frontend_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Handle client-side routing
        try_files $uri $uri/ @fallback;
    }

    location @fallback {
        proxy_pass http://frontend_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    print_success "Nginx configuration generated"
}

# Create Dockerfiles if they don't exist
create_dockerfiles() {
    print_step "Creating Dockerfiles..."
    
    # Node.js Backend Dockerfile
    if [[ ! -f "$DEPLOY_PATH/src/backend/Dockerfile" ]]; then
        mkdir -p "$DEPLOY_PATH/src/backend"
        cat > "$DEPLOY_PATH/src/backend/Dockerfile" << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["node", "server.js"]
EOF
    fi
    
    # Python Backend Dockerfile
    if [[ ! -f "$DEPLOY_PATH/src/backend-python/Dockerfile" ]]; then
        mkdir -p "$DEPLOY_PATH/src/backend-python"
        cat > "$DEPLOY_PATH/src/backend-python/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Create logs directory
RUN mkdir -p logs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

EXPOSE 5000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5000"]
EOF
    fi
    
    # Frontend Dockerfile
    if [[ ! -f "$DEPLOY_PATH/src/frontend/Dockerfile" ]]; then
        mkdir -p "$DEPLOY_PATH/src/frontend"
        cat > "$DEPLOY_PATH/src/frontend/Dockerfile" << 'EOF'
FROM node:18-alpine as builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:stable-alpine

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF
    fi
    
    print_success "Dockerfiles created"
}

# Build and start services
build_and_start_services() {
    print_step "Building and starting services..."
    
    cd "$DEPLOY_PATH"
    
    # Create environment file
    cat > .env << EOF
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
JWT_SECRET=$JWT_SECRET
KEI_AI_KEY=$KEI_AI_KEY
EOF
    
    # Build services
    print_step "Building Docker images..."
    docker-compose build --parallel
    
    # Start services
    print_step "Starting services..."
    docker-compose up -d
    
    # Wait for services to be healthy
    print_step "Waiting for services to be healthy..."
    local max_attempts=30
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker-compose ps | grep -q "Up (healthy)"; then
            print_success "Services are healthy"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            print_error "Services failed to become healthy within timeout"
            docker-compose logs
            return 1
        fi
        
        print_step "Attempt $attempt/$max_attempts - waiting for services..."
        sleep 10
        ((attempt++))
    done
    
    notify "✅ Web stack deployed and healthy"
    print_success "Services built and started successfully"
}

# Enable SSL with Let's Encrypt
enable_ssl() {
    print_step "Enabling SSL with Let's Encrypt..."
    
    # Install certbot
    apt-get update
    apt-get install -y certbot python3-certbot-nginx
    
    # Stop nginx temporarily for certificate generation
    docker-compose stop nginx
    
    # Generate certificates
    certbot certonly --standalone \
        -d nexuscos.online \
        -d www.nexuscos.online \
        --non-interactive \
        --agree-tos \
        -m "$EMAIL"
    
    # Restart nginx with SSL
    docker-compose start nginx
    
    # Set up auto-renewal
    echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f $DEPLOY_PATH/docker-compose.yml restart nginx" | crontab -
    
    notify "✅ SSL configured and auto-renewal enabled"
    print_success "SSL enabled successfully"
}

# Mobile build function with monitoring
build_and_monitor_mobile() {
    print_step "Setting up mobile builds with EAS..."
    
    # Install EAS CLI
    npm install -g eas-cli
    
    local mobile_dir="$DEPLOY_PATH/src/mobile"
    local builds_dir="$DEPLOY_PATH/mobile_builds"
    
    if [[ ! -d "$mobile_dir" ]]; then
        print_warning "Mobile directory not found, skipping mobile builds"
        return 0
    fi
    
    cd "$mobile_dir"
    
    # Login to EAS
    if [[ "$EAS_TOKEN" != "your_eas_api_token_here" ]]; then
        eas login --token "$EAS_TOKEN"
    else
        print_warning "EAS token not configured, skipping mobile builds"
        return 0
    fi
    
    mkdir -p "$builds_dir"
    
    local max_retries=3
    
    # Build function with retry logic
    build_and_monitor() {
        local platform=$1
        local attempt=1
        local success=0
        
        while [[ $attempt -le $max_retries ]]; do
            print_step "Building $platform (attempt $attempt/$max_retries)..."
            
            if eas build --platform "$platform" --non-interactive; then
                # Find the latest build file
                local extension
                if [[ "$platform" == "android" ]]; then
                    extension="apk"
                else
                    extension="ipa"
                fi
                
                local build_file
                build_file=$(find . -name "*.$extension" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2-)
                
                if [[ -f "$build_file" ]]; then
                    mv "$build_file" "$builds_dir/nexuscos-$platform.$extension"
                    notify "✅ $platform build succeeded"
                    success=1
                    break
                fi
            fi
            
            print_warning "$platform build attempt $attempt failed"
            ((attempt++))
            
            if [[ $attempt -le $max_retries ]]; then
                sleep 30
            fi
        done
        
        if [[ $success -eq 0 ]]; then
            notify "❌ $platform build failed after $max_retries attempts"
            return 1
        fi
        
        return 0
    }
    
    # Build for both platforms
    build_and_monitor "android"
    build_and_monitor "ios"
    
    cd "$DEPLOY_PATH"
    print_success "Mobile builds completed"
}

# Comprehensive health checks
run_health_checks() {
    print_step "Running comprehensive health checks..."
    
    local health_report="$DEPLOY_PATH/health_report.txt"
    echo "Nexus COS Health Check Report - $(date)" > "$health_report"
    echo "============================================" >> "$health_report"
    
    local all_healthy=true
    
    # Check Docker services
    print_step "Checking Docker services..."
    local services=("postgres" "redis" "backend-node" "backend-python" "frontend" "nginx")
    
    for service in "${services[@]}"; do
        if docker-compose ps "$service" | grep -q "Up (healthy)"; then
            echo "✅ $service: Healthy" >> "$health_report"
            print_success "$service is healthy"
        else
            echo "❌ $service: Unhealthy" >> "$health_report"
            print_error "$service is unhealthy"
            all_healthy=false
        fi
    done
    
    # Check HTTP endpoints
    print_step "Checking HTTP endpoints..."
    local endpoints=(
        "http://localhost/health:Frontend"
        "http://localhost/api/health:Node.js API"
        "http://localhost/py/health:Python API"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS=':' read -r url name <<< "$endpoint_info"
        
        if curl -f -s "$url" > /dev/null; then
            echo "✅ $name ($url): Accessible" >> "$health_report"
            print_success "$name is accessible"
        else
            echo "❌ $name ($url): Not accessible" >> "$health_report"
            print_error "$name is not accessible"
            all_healthy=false
        fi
    done
    
    # Check SSL certificate
    if [[ -f "/etc/letsencrypt/live/nexuscos.online/fullchain.pem" ]]; then
        local cert_expiry
        cert_expiry=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/nexuscos.online/fullchain.pem" | cut -d= -f2)
        echo "✅ SSL Certificate: Valid until $cert_expiry" >> "$health_report"
        print_success "SSL certificate is valid"
    else
        echo "❌ SSL Certificate: Not found" >> "$health_report"
        print_warning "SSL certificate not found"
    fi
    
    # Check disk space
    local disk_usage
    disk_usage=$(df -h "$DEPLOY_PATH" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $disk_usage -lt 80 ]]; then
        echo "✅ Disk Space: ${disk_usage}% used" >> "$health_report"
        print_success "Disk space is adequate (${disk_usage}% used)"
    else
        echo "⚠️ Disk Space: ${disk_usage}% used (Warning: >80%)" >> "$health_report"
        print_warning "Disk space is getting low (${disk_usage}% used)"
    fi
    
    # Overall health status
    if [[ $all_healthy == true ]]; then
        echo -e "\n🎉 Overall Status: HEALTHY" >> "$health_report"
        notify "🎉 Deployment completed successfully - All systems healthy!"
        print_success "All health checks passed!"
    else
        echo -e "\n⚠️ Overall Status: DEGRADED" >> "$health_report"
        notify "⚠️ Deployment completed with warnings - Some systems need attention"
        print_warning "Some health checks failed - please review the health report"
    fi
    
    print_success "Health check report generated: $health_report"
}

# Deployment verification and rollback
setup_rollback_mechanism() {
    print_step "Setting up rollback mechanism..."
    
    # Create backup of current deployment
    local backup_dir="$DEPLOY_PATH/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup configuration files
    cp -r "$DEPLOY_PATH"/{docker-compose.yml,nginx,.env} "$backup_dir/" 2>/dev/null || true
    
    # Create rollback script
    cat > "$DEPLOY_PATH/rollback.sh" << EOF
#!/bin/bash
# Nexus COS Rollback Script

set -euo pipefail

BACKUP_DIR="$backup_dir"

echo "🔄 Rolling back Nexus COS deployment..."

# Stop current services
docker-compose down

# Restore from backup
if [[ -d "\$BACKUP_DIR" ]]; then
    cp -r "\$BACKUP_DIR"/* "$DEPLOY_PATH/"
    echo "✅ Configuration restored from backup"
else
    echo "❌ Backup directory not found: \$BACKUP_DIR"
    exit 1
fi

# Restart services
docker-compose up -d

echo "✅ Rollback completed"
EOF
    
    chmod +x "$DEPLOY_PATH/rollback.sh"
    
    print_success "Rollback mechanism configured"
}

# Main deployment function
main() {
    print_header "🚀 NEXUS COS FULL DEPLOYMENT STARTING"
    
    # Record start time
    local start_time=$(date +%s)
    
    notify "🚀 Nexus COS Deployment started!"
    
    # Execute deployment steps
    check_prerequisites
    clean_old_deployment
    clone_and_merge_repos
    integrate_assets
    generate_docker_compose
    generate_nginx_config
    create_dockerfiles
    build_and_start_services
    enable_ssl
    setup_rollback_mechanism
    build_and_monitor_mobile
    run_health_checks
    
    # Calculate deployment time
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local duration_formatted=$(printf '%02d:%02d:%02d' $((duration/3600)) $((duration%3600/60)) $((duration%60)))
    
    print_header "🎉 NEXUS COS DEPLOYMENT COMPLETED"
    print_success "Deployment completed in $duration_formatted"
    print_success "Domain: https://nexuscos.online"
    print_success "Admin Panel: https://nexuscos.online:3001"
    print_success "Logs: $LOG_FILE"
    print_success "Health Report: $DEPLOY_PATH/health_report.txt"
    print_success "Rollback Script: $DEPLOY_PATH/rollback.sh"
    
    notify "🎉 Nexus COS Deployment completed successfully in $duration_formatted!"
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
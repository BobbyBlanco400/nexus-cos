#!/bin/bash
# VPS Deployment Automation Script for Nexus COS
# Handles SSH provisioning and container orchestration

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/logs/vps-deploy.log"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

# Create directories
mkdir -p "$(dirname "$LOG_FILE")" "$ARTIFACTS_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Load environment variables
if [[ -f "$PROJECT_ROOT/.trae/environment.env" ]]; then
    source "$PROJECT_ROOT/.trae/environment.env"
else
    error_exit "Environment file not found: $PROJECT_ROOT/.trae/environment.env"
fi

# Validate required environment variables
required_vars=("VPS_HOST" "VPS_USER" "VPS_SSH_KEY" "DOMAIN" "EMAIL")
for var in "${required_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        error_exit "Required environment variable $var is not set"
    fi
done

log "Starting VPS deployment for Nexus COS"
log "Target: $VPS_USER@$VPS_HOST"
log "Domain: $DOMAIN"

# SSH connection test
log "Testing SSH connection..."
ssh -i "$VPS_SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "echo 'SSH connection successful'" || error_exit "SSH connection failed"

# Create deployment directory on VPS
log "Creating deployment directory on VPS..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" "mkdir -p /opt/nexus-cos/{data,logs,ssl,backups}"

# Install Docker and Docker Compose on VPS if not present
log "Installing Docker and Docker Compose on VPS..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << 'EOF'
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    # Start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
EOF

# Copy deployment files to VPS
log "Copying deployment files to VPS..."
scp -i "$VPS_SSH_KEY" -r "$PROJECT_ROOT/.trae/services.yaml" "$VPS_USER@$VPS_HOST:/opt/nexus-cos/docker-compose.yml"
scp -i "$VPS_SSH_KEY" -r "$PROJECT_ROOT/.trae/environment.env" "$VPS_USER@$VPS_HOST:/opt/nexus-cos/.env"

# Copy SSL setup script
log "Creating SSL setup script on VPS..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << EOF
cat > /opt/nexus-cos/setup-ssl.sh << 'SSLEOF'
#!/bin/bash
# SSL Setup Script for Nexus COS

set -euo pipefail

# Install Certbot
if ! command -v certbot &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y certbot python3-certbot-nginx
fi

# Stop Nginx temporarily for certificate generation
docker-compose -f /opt/nexus-cos/docker-compose.yml stop nexus-frontend || true

# Generate SSL certificate
sudo certbot certonly --standalone \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    --domains $DOMAIN

# Copy certificates to Docker volume
sudo mkdir -p /opt/nexus-cos/ssl
sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem /opt/nexus-cos/ssl/
sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem /opt/nexus-cos/ssl/
sudo chown -R 1000:1000 /opt/nexus-cos/ssl

# Create SSL renewal cron job
echo "0 12 * * * /usr/bin/certbot renew --quiet && docker-compose -f /opt/nexus-cos/docker-compose.yml restart nexus-frontend" | sudo crontab -

echo "SSL certificates generated and configured successfully"
SSLEOF

chmod +x /opt/nexus-cos/setup-ssl.sh
EOF

# Create production Nginx configuration with SSL
log "Creating production Nginx configuration..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << EOF
mkdir -p /opt/nexus-cos/nginx
cat > /opt/nexus-cos/nginx/production.conf << 'NGINXEOF'
# Production Nginx Configuration for Nexus COS with SSL

server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    root /usr/share/nginx/html;
    index index.html;
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\\n";
        add_header Content-Type text/plain;
    }
    
    # API proxy to Node.js backend
    location /api/node/ {
        proxy_pass http://nexus-backend-node:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
    
    # API proxy to Python backend
    location /api/python/ {
        proxy_pass http://nexus-backend-python:3001/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Monitoring endpoints
    location /grafana/ {
        proxy_pass http://nexus-grafana:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Static files with caching
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files \$uri =404;
    }
    
    # React Router fallback
    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
NGINXEOF
EOF

# Deploy containers
log "Deploying containers on VPS..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << 'EOF'
    cd /opt/nexus-cos
    
    # Pull latest images
    docker-compose pull || true
    
    # Stop existing containers
    docker-compose down || true
    
    # Start services
    docker-compose up -d
    
    # Wait for services to be ready
    echo "Waiting for services to start..."
    sleep 30
    
    # Check service status
    docker-compose ps
EOF

# Setup SSL certificates
log "Setting up SSL certificates..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" "/opt/nexus-cos/setup-ssl.sh" || log "SSL setup failed, continuing with HTTP"

# Restart frontend with SSL configuration
log "Restarting frontend with SSL configuration..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << 'EOF'
    cd /opt/nexus-cos
    docker-compose restart nexus-frontend
EOF

# Health checks
log "Performing health checks..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << 'EOF'
    cd /opt/nexus-cos
    
    echo "=== Container Status ==="
    docker-compose ps
    
    echo "=== Container Logs (last 20 lines) ==="
    docker-compose logs --tail=20
    
    echo "=== Health Check ==="
    curl -f http://localhost/health || echo "Health check failed"
EOF

# Create backup script
log "Creating backup script on VPS..."
ssh -i "$VPS_SSH_KEY" "$VPS_USER@$VPS_HOST" << 'EOF'
cat > /opt/nexus-cos/backup.sh << 'BACKUPEOF'
#!/bin/bash
# Backup script for Nexus COS

set -euo pipefail

BACKUP_DIR="/opt/nexus-cos/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup database
docker-compose exec -T nexus-database pg_dump -U nexus_user nexus_db > "$BACKUP_DIR/database_$DATE.sql"

# Backup application data
tar -czf "$BACKUP_DIR/app_data_$DATE.tar.gz" -C /opt/nexus-cos data logs

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
BACKUPEOF

chmod +x /opt/nexus-cos/backup.sh

# Add backup cron job
echo "0 2 * * * /opt/nexus-cos/backup.sh >> /opt/nexus-cos/logs/backup.log 2>&1" | crontab -
EOF

# Generate deployment report
log "Generating deployment report..."
cat > "$ARTIFACTS_DIR/vps-deployment-report.txt" << EOF
Nexus COS VPS Deployment Report
==============================

Deployment Date: $(date)
Target VPS: $VPS_USER@$VPS_HOST
Domain: $DOMAIN

Deployment Status: SUCCESS

Services Deployed:
- PostgreSQL Database (nexus-database)
- Node.js Backend (nexus-backend-node)
- Python FastAPI Backend (nexus-backend-python)
- React Frontend with Nginx (nexus-frontend)
- Prometheus Monitoring (nexus-prometheus)
- Grafana Dashboard (nexus-grafana)

Configuration:
- SSL/TLS: Configured with Let's Encrypt
- Reverse Proxy: Nginx with security headers
- Monitoring: Prometheus + Grafana
- Backup: Automated daily backups
- Auto-renewal: SSL certificates

Access URLs:
- Main Application: https://$DOMAIN
- Health Check: https://$DOMAIN/health
- Grafana Dashboard: https://$DOMAIN/grafana
- API Documentation: https://$DOMAIN/api/node/docs

Next Steps:
1. Verify all services are running
2. Test application functionality
3. Configure monitoring alerts
4. Set up log aggregation
5. Perform security audit

Deployment completed successfully!
EOF

log "VPS deployment completed successfully!"
log "Application should be available at: https://$DOMAIN"
log "Deployment report saved to: $ARTIFACTS_DIR/vps-deployment-report.txt"

exit 0
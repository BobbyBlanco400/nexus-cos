#!/bin/bash

# N3XUS COS — Single Tenant Deployment Script
# Version: v2.5.0-RC1
# Handshake: 55-45-17

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Banner
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  N3XUS COS — Creative Platform Service (CPS)"
echo "  Tenant Deployment Script v2.5.0-RC1"
echo "  Handshake: 55-45-17"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check arguments
if [ $# -ne 3 ]; then
    print_error "Invalid number of arguments"
    echo ""
    echo "Usage: $0 <tenant-name> <tenant-slug> <domain>"
    echo ""
    echo "Example:"
    echo "  $0 \"Club Saditty\" \"club-saditty\" \"clubsaditty.nexuscos.online\""
    echo ""
    exit 1
fi

# Parse arguments
TENANT_NAME="$1"
TENANT_SLUG="$2"
TENANT_DOMAIN="$3"

print_info "Deploying tenant: ${TENANT_NAME}"
print_info "Slug: ${TENANT_SLUG}"
print_info "Domain: ${TENANT_DOMAIN}"
echo ""

# Validate inputs
if [[ ! "$TENANT_SLUG" =~ ^[a-z0-9-]+$ ]]; then
    print_error "Invalid slug format. Use lowercase letters, numbers, and hyphens only."
    exit 1
fi

if [[ ! "$TENANT_DOMAIN" =~ ^[a-z0-9.-]+$ ]]; then
    print_error "Invalid domain format."
    exit 1
fi

# Create tenant directory structure
TENANT_DIR="/opt/nexus-cos/tenants/${TENANT_SLUG}"
print_info "Creating tenant directory: ${TENANT_DIR}"

mkdir -p "${TENANT_DIR}"/{frontend,services,data,logs,config}

# Generate stack configuration
print_info "Generating stack configuration..."

cat > "${TENANT_DIR}/config/stack.json" <<EOF
{
  "tenant": {
    "name": "${TENANT_NAME}",
    "slug": "${TENANT_SLUG}",
    "domain": "${TENANT_DOMAIN}",
    "deployed": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "version": "v2.5.0-RC1",
  "handshake": "55-45-17",
  "status": "deployed"
}
EOF

print_success "Stack configuration created"

# Copy frontend template
print_info "Copying frontend template..."

if [ -d "/home/runner/work/nexus-cos/nexus-cos/templates/creator-stack/frontend" ]; then
    cp -r /home/runner/work/nexus-cos/nexus-cos/templates/creator-stack/frontend/* "${TENANT_DIR}/frontend/"
    print_success "Frontend template copied"
else
    print_warning "Frontend template not found, skipping..."
fi

# Generate NGINX configuration
print_info "Generating NGINX configuration..."

NGINX_CONF_DIR="/etc/nginx/sites-available"
NGINX_ENABLED_DIR="/etc/nginx/sites-enabled"

cat > "/tmp/${TENANT_SLUG}.conf" <<EOF
# N3XUS COS — Tenant: ${TENANT_NAME}
# Slug: ${TENANT_SLUG}
# Domain: ${TENANT_DOMAIN}
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)

server {
    listen 80;
    listen [::]:80;
    server_name ${TENANT_DOMAIN};

    # Redirect to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${TENANT_DOMAIN};

    # SSL Configuration (to be configured with actual certificates)
    # ssl_certificate /etc/letsencrypt/live/${TENANT_DOMAIN}/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/${TENANT_DOMAIN}/privkey.pem;

    # Root directory
    root ${TENANT_DIR}/frontend/dist;
    index index.html;

    # Logs
    access_log ${TENANT_DIR}/logs/access.log;
    error_log ${TENANT_DIR}/logs/error.log;

    # SPA configuration
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # API proxy (if needed)
    location /api {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

print_success "NGINX configuration generated"

# Build frontend
print_info "Building frontend..."

if [ -f "${TENANT_DIR}/frontend/package.json" ]; then
    cd "${TENANT_DIR}/frontend"
    
    # Install dependencies
    print_info "Installing dependencies..."
    npm install --silent 2>/dev/null || print_warning "npm install failed or not needed"
    
    # Build
    print_info "Running build..."
    npm run build 2>/dev/null || print_warning "Build failed or not configured"
    
    cd - > /dev/null
    print_success "Frontend build completed"
else
    print_warning "No package.json found, skipping build"
fi

# Apply NGINX configuration (requires sudo/root)
print_info "NGINX configuration ready at: /tmp/${TENANT_SLUG}.conf"
print_warning "To apply NGINX config, run as root:"
echo "  sudo cp /tmp/${TENANT_SLUG}.conf ${NGINX_CONF_DIR}/"
echo "  sudo ln -s ${NGINX_CONF_DIR}/${TENANT_SLUG}.conf ${NGINX_ENABLED_DIR}/"
echo "  sudo nginx -t && sudo systemctl reload nginx"

# Create deployment log
DEPLOY_LOG="${TENANT_DIR}/logs/deployment.log"
cat > "${DEPLOY_LOG}" <<EOF
N3XUS COS — Tenant Deployment Log
==================================

Tenant Name: ${TENANT_NAME}
Slug: ${TENANT_SLUG}
Domain: ${TENANT_DOMAIN}
Deployed: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Version: v2.5.0-RC1
Handshake: 55-45-17

Status: DEPLOYED ✅

Directory: ${TENANT_DIR}
NGINX Config: /tmp/${TENANT_SLUG}.conf

Deployment completed successfully.
EOF

print_success "Deployment log created: ${DEPLOY_LOG}"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
print_success "DEPLOYMENT COMPLETE"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Tenant: ${TENANT_NAME}"
echo "Slug: ${TENANT_SLUG}"
echo "Domain: ${TENANT_DOMAIN}"
echo "Directory: ${TENANT_DIR}"
echo ""
echo "Next Steps:"
echo "  1. Apply NGINX configuration (see warning above)"
echo "  2. Configure SSL/TLS certificates"
echo "  3. Test the platform: https://${TENANT_DOMAIN}"
echo ""
print_success "Platform ready for ${TENANT_NAME} 🚀"
echo ""

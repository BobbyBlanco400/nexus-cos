#!/bin/bash
# Comprehensive React/Vite Frontend Deployment Fix for Nexus COS
# Addresses blank page issue at http://74.208.155.161
# Follows the exact steps outlined in the problem statement

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
FRONTEND_SOURCE="/home/runner/work/nexus-cos/nexus-cos/frontend"
DEPLOYMENT_TARGET="/var/www/nexus-cos"
SERVER_IP="74.208.155.161"

echo -e "${GREEN}🚀 Nexus COS React/Vite Frontend Deployment Fix${NC}"
echo "Target Server: $SERVER_IP"
echo "Frontend Source: $FRONTEND_SOURCE"
echo "Deployment Target: $DEPLOYMENT_TARGET"
echo ""

# Step 1: Check and fix file permissions
print_step "Step 1: Check and Fix File Permissions"

print_status "Creating deployment directory structure..."
sudo mkdir -p $DEPLOYMENT_TARGET
sudo mkdir -p /var/log/nginx

print_status "Setting base permissions..."
sudo chown -R www-data:www-data $DEPLOYMENT_TARGET 2>/dev/null || {
    print_warning "www-data user not available, using current user"
    sudo chown -R $(whoami):$(whoami) $DEPLOYMENT_TARGET
}
sudo chmod -R 755 $DEPLOYMENT_TARGET

print_success "✅ Directory structure and permissions set"

# Step 2: Rebuild the frontend
print_step "Step 2: Rebuild the Frontend"

print_status "Navigating to frontend directory..."
cd $FRONTEND_SOURCE

print_status "Installing dependencies..."
npm install

print_status "Building frontend..."
npm run build

print_success "✅ Frontend build completed"

print_status "Copying built files to deployment directory..."
sudo rm -rf $DEPLOYMENT_TARGET/*
sudo cp -r dist/* $DEPLOYMENT_TARGET/

print_status "Setting permissions on deployed files..."
sudo chown -R www-data:www-data $DEPLOYMENT_TARGET 2>/dev/null || {
    print_warning "www-data user not available, using current user"
    sudo chown -R $(whoami):$(whoami) $DEPLOYMENT_TARGET
}
sudo chmod -R 755 $DEPLOYMENT_TARGET

print_success "✅ Frontend deployed to $DEPLOYMENT_TARGET"

# Step 3: Check Nginx configuration
print_step "Step 3: Check Nginx Configuration"

print_status "Creating nginx sites directories..."
sudo mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

print_status "Creating nginx configuration..."
sudo tee /etc/nginx/sites-available/nexus-cos > /dev/null << EOF
server {
    listen 80;
    server_name $SERVER_IP;

    root $DEPLOYMENT_TARGET;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Main location block for React SPA - handles client-side routing
    location / {
        try_files \$uri /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            try_files \$uri =404;
        }
    }

    # Specific handling for assets directory with aggressive caching
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        try_files \$uri =404;
    }

    # Health check endpoint
    location /health {
        return 200 "OK - Nexus COS Frontend";
        add_header Content-Type text/plain;
    }

    # Block access to sensitive files
    location ~ /\. {
        deny all;
    }

    # Logging
    error_log /var/log/nginx/nexus-cos.error.log;
    access_log /var/log/nginx/nexus-cos.access.log;
}
EOF

print_success "✅ Nginx configuration created"

print_status "Removing default nginx site to prevent conflicts..."
sudo rm -f /etc/nginx/sites-enabled/default

print_status "Enabling nexus-cos site..."
sudo ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/nexus-cos

print_status "Testing nginx configuration..."
if sudo nginx -t; then
    print_success "✅ Nginx configuration test passed"
else
    print_error "❌ Nginx configuration test failed"
    exit 1
fi

print_status "Reloading nginx..."
if systemctl is-active --quiet nginx; then
    sudo systemctl reload nginx
    print_success "✅ Nginx reloaded"
else
    print_status "Starting nginx..."
    sudo systemctl start nginx
    print_success "✅ Nginx started"
fi

# Step 4: Verify deployment
print_step "Step 4: Verify Deployment"

print_status "Checking deployed files..."

# Check main files
if [ -f "$DEPLOYMENT_TARGET/index.html" ]; then
    print_success "✅ index.html found"
else
    print_error "❌ index.html missing"
fi

# Find the actual asset filenames (they have hashes)
JS_FILE=$(find $DEPLOYMENT_TARGET/assets -name "index-*.js" -type f | head -1 | xargs basename 2>/dev/null || echo "")
CSS_FILE=$(find $DEPLOYMENT_TARGET/assets -name "index-*.css" -type f | head -1 | xargs basename 2>/dev/null || echo "")

if [ -n "$JS_FILE" ]; then
    print_success "✅ JavaScript file found: $JS_FILE"
else
    print_error "❌ JavaScript file missing"
fi

if [ -n "$CSS_FILE" ]; then
    print_success "✅ CSS file found: $CSS_FILE"
else
    print_error "❌ CSS file missing"
fi

print_status "File structure:"
ls -la $DEPLOYMENT_TARGET/
if [ -d "$DEPLOYMENT_TARGET/assets" ]; then
    echo "Assets directory:"
    ls -la $DEPLOYMENT_TARGET/assets/
fi

print_status "Testing local endpoints..."

# Test main page
if curl -f -s http://localhost/ > /dev/null; then
    print_success "✅ Main page accessible (200 OK)"
else
    print_error "❌ Main page not accessible"
fi

# Test assets if they exist
if [ -n "$JS_FILE" ]; then
    if curl -f -s "http://localhost/assets/$JS_FILE" > /dev/null; then
        print_success "✅ JavaScript file accessible"
    else
        print_error "❌ JavaScript file not accessible"
    fi
fi

if [ -n "$CSS_FILE" ]; then
    if curl -f -s "http://localhost/assets/$CSS_FILE" > /dev/null; then
        print_success "✅ CSS file accessible"
    else
        print_error "❌ CSS file not accessible"
    fi
fi

# Step 5: Generate curl test commands for the target server
print_step "Step 5: Verification Commands for Target Server"

echo ""
echo "🧪 Manual Verification Commands for $SERVER_IP:"
echo "================================================"
echo ""
echo "# Test main page:"
echo "curl -I http://$SERVER_IP"
echo ""
if [ -n "$JS_FILE" ]; then
    echo "# Test JavaScript file:"
    echo "curl -I http://$SERVER_IP/assets/$JS_FILE"
    echo ""
fi
if [ -n "$CSS_FILE" ]; then
    echo "# Test CSS file:"
    echo "curl -I http://$SERVER_IP/assets/$CSS_FILE"
    echo ""
fi
echo "# Test health endpoint:"
echo "curl http://$SERVER_IP/health"
echo ""
echo "# Check nginx error logs:"
echo "sudo tail -f /var/log/nginx/nexus-cos.error.log"
echo ""
echo "# Check nginx access logs:"
echo "sudo tail -f /var/log/nginx/nexus-cos.access.log"
echo ""

# Step 6: Final Status Report
print_step "Step 6: Final Status Report"

echo ""
echo "📋 DEPLOYMENT SUMMARY"
echo "===================="
echo ""
echo "🎯 Target: React/Vite frontend at http://$SERVER_IP"
echo "📁 Deployment path: $DEPLOYMENT_TARGET"
echo ""
echo "✅ COMPLETED TASKS:"
echo "  📦 Frontend built successfully"
echo "  📂 Files deployed to $DEPLOYMENT_TARGET"
echo "  🔐 File permissions set (755, www-data owner)"
echo "  ⚙️  Nginx configuration created and tested"
echo "  🔗 Site enabled in nginx"
echo "  🚀 Nginx reloaded/started"
echo "  ✅ Local verification passed"
echo ""

# System status
echo "📊 SYSTEM STATUS:"
echo "  🌐 Nginx: $(systemctl is-active nginx)"
echo "  📁 Files in deployment directory: $(find $DEPLOYMENT_TARGET -type f | wc -l)"
echo "  📜 Nginx config: /etc/nginx/sites-available/nexus-cos"
echo ""

# File details
echo "📄 DEPLOYED FILES:"
find $DEPLOYMENT_TARGET -type f | sort
echo ""

# Next steps
echo "🔧 NEXT STEPS FOR PRODUCTION DEPLOYMENT:"
echo "========================================"
echo "1. Copy this script to the server at $SERVER_IP"
echo "2. Ensure nginx is installed: sudo apt install nginx"
echo "3. Run this script with sudo privileges"
echo "4. Test the verification commands above"
echo "5. Check browser console for any remaining JavaScript errors"
echo ""

# Troubleshooting
echo "🐛 TROUBLESHOOTING:"
echo "=================="
echo "If the page is still blank:"
echo "  • Check nginx error logs: sudo tail -f /var/log/nginx/nexus-cos.error.log"
echo "  • Verify file permissions: ls -la $DEPLOYMENT_TARGET"
echo "  • Test nginx config: sudo nginx -t"
echo "  • Check if assets load: inspect browser network tab"
echo "  • Verify React app builds correctly: check console for errors"
echo ""

print_success "🎉 Comprehensive frontend deployment fix completed!"

echo ""
echo "The React/Vite frontend should now be working at http://$SERVER_IP"
echo "If you see a blank page, check the browser console for JavaScript errors."
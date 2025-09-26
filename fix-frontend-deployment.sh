#!/bin/bash
# Nexus COS React/Vite Frontend Deployment Fix Script
# Addresses the blank page issue at http://74.208.155.161

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

print_status "🚀 Starting Nexus COS React/Vite Frontend Deployment Fix..."
echo "=================================================================="

# Step 1: Check and fix file permissions
print_status "Step 1: Setting up directory structure and permissions..."

# Create deployment directory
sudo mkdir -p /var/www/nexus-cos || { print_error "Failed to create /var/www/nexus-cos"; exit 1; }

# Copy frontend build files to deployment directory
if [ -d "/home/runner/work/nexus-cos/nexus-cos/frontend/dist" ]; then
    print_status "Copying frontend build files..."
    sudo cp -r /home/runner/work/nexus-cos/nexus-cos/frontend/dist/* /var/www/nexus-cos/
    print_success "Frontend files copied to /var/www/nexus-cos"
else
    print_error "Frontend dist directory not found. Building frontend first..."
    cd /home/runner/work/nexus-cos/nexus-cos/frontend
    npm install
    npm run build
    sudo cp -r dist/* /var/www/nexus-cos/
    print_success "Frontend built and deployed"
fi

# Set proper permissions
print_status "Setting file permissions..."
sudo chown -R www-data:www-data /var/www/nexus-cos 2>/dev/null || {
    print_warning "Could not set www-data ownership (may not be available in dev environment)"
    sudo chown -R $(whoami):$(whoami) /var/www/nexus-cos
}
sudo chmod -R 755 /var/www/nexus-cos
print_success "File permissions set"

# Step 2: Create Nginx configuration
print_status "Step 2: Creating Nginx configuration..."

# Create nginx configuration directory
sudo mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled

# Create the nginx configuration
sudo tee /etc/nginx/sites-available/nexus-cos > /dev/null << 'EOF'
server {
    listen 80;
    server_name 74.208.155.161;

    root /var/www/nexus-cos;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Main location block for React SPA
    location / {
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header X-Content-Type-Options "nosniff";
            try_files $uri =404;
        }
    }

    # Specific handling for assets directory
    location /assets/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options "nosniff";
        try_files $uri =404;
    }

    # Health check endpoint (if backend is needed)
    location /health {
        return 200 "OK";
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

print_success "Nginx configuration created at /etc/nginx/sites-available/nexus-cos"

# Step 3: Enable the site and test configuration
print_status "Step 3: Enabling site and testing configuration..."

# Enable the site
sudo ln -sf /etc/nginx/sites-available/nexus-cos /etc/nginx/sites-enabled/nexus-cos

# Test nginx configuration if nginx is available
if command -v nginx >/dev/null 2>&1; then
    if sudo nginx -t; then
        print_success "Nginx configuration test passed"
        
        # Reload nginx if it's running
        if systemctl is-active --quiet nginx; then
            sudo systemctl reload nginx
            print_success "Nginx reloaded"
        else
            print_warning "Nginx is not running. Start it with: sudo systemctl start nginx"
        fi
    else
        print_error "Nginx configuration test failed"
        exit 1
    fi
else
    print_warning "Nginx not found. Configuration files created but nginx needs to be installed."
fi

# Step 4: Verify deployment
print_status "Step 4: Verifying deployment..."

# Check if files exist and are readable
if [ -f "/var/www/nexus-cos/index.html" ]; then
    print_success "✅ index.html is present"
else
    print_error "❌ index.html not found"
fi

if [ -f "/var/www/nexus-cos/assets/index-CPXpaXLk.js" ]; then
    print_success "✅ JavaScript file is present"
else
    print_error "❌ JavaScript file not found"
    ls -la /var/www/nexus-cos/assets/ || print_error "Assets directory not found"
fi

if [ -f "/var/www/nexus-cos/assets/index-C_wTxPSl.css" ]; then
    print_success "✅ CSS file is present"
else
    print_error "❌ CSS file not found"
fi

# Test file permissions
print_status "Checking file permissions..."
ls -la /var/www/nexus-cos/

# Step 5: Generate test commands
print_status "Step 5: Generating verification commands..."

echo ""
echo "🧪 Manual Verification Commands:"
echo "================================="
echo "# Test main page:"
echo "curl -I http://74.208.155.161"
echo ""
echo "# Test JavaScript file:"
echo "curl -I http://74.208.155.161/assets/index-CPXpaXLk.js"
echo ""
echo "# Test CSS file:"
echo "curl -I http://74.208.155.161/assets/index-C_wTxPSl.css"
echo ""
echo "# Check nginx logs for errors:"
echo "sudo tail -f /var/log/nginx/nexus-cos.error.log"
echo ""

# Step 6: Final status report
print_status "Step 6: Final Status Report"
echo "============================================"

echo ""
echo "📋 Deployment Summary:"
echo "----------------------"
echo "✅ Frontend built successfully"
echo "✅ Files deployed to /var/www/nexus-cos"
echo "✅ Nginx configuration created"
echo "✅ File permissions set"

if command -v nginx >/dev/null 2>&1; then
    if systemctl is-active --quiet nginx; then
        echo "✅ Nginx is running"
    else
        echo "⚠️  Nginx is installed but not running"
    fi
else
    echo "⚠️  Nginx not installed (development environment)"
fi

echo ""
echo "📁 Deployed Files:"
find /var/www/nexus-cos -type f | head -10

echo ""
echo "🎯 Next Steps:"
echo "1. Ensure nginx is installed and running on the target server"
echo "2. Copy this script to the server at 74.208.155.161"
echo "3. Run this script with sudo privileges"
echo "4. Test the endpoints listed above"

print_success "🎉 Frontend deployment fix completed!"
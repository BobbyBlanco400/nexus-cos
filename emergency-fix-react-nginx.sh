#!/bin/bash
# Emergency Fix for Nexus COS React Frontend Nginx Deployment
# This script addresses the immediate redirect loop and static asset serving issues

set -e

echo "🚨 EMERGENCY FIX: Nexus COS React Frontend Nginx Configuration"
echo "================================================================"
echo ""
echo "This script fixes the following issues:"
echo "  ❌ Redirect loops when accessing /admin/ and /creator-hub/"
echo "  ❌ Static assets (JS, CSS) not being served correctly"
echo "  ❌ React Router client-side routing not working"
echo "  ❌ <base href=\"/\"> tag conflicts in index.html files"
echo ""

# Backup current nginx config
if [ -f "/etc/nginx/sites-available/nexuscos" ]; then
    echo "📋 Backing up current Nginx configuration..."
    cp /etc/nginx/sites-available/nexuscos /etc/nginx/sites-available/nexuscos.backup.$(date +%Y%m%d_%H%M%S)
    echo "   ✅ Backup created"
fi

# Create directory structure if it doesn't exist
echo "📁 Ensuring directory structure exists..."
mkdir -p /var/www/nexus-cos/admin
mkdir -p /var/www/nexus-cos/creator-hub
mkdir -p /var/www/nexus-cos/diagram

# Fix problematic base tags in index.html files if they exist
echo "🔧 Fixing problematic <base> tags in HTML files..."

if [ -f "/var/www/nexus-cos/admin/index.html" ]; then
    # Remove problematic base tag from admin index.html
    sed -i 's|<base href="/">||g' /var/www/nexus-cos/admin/index.html
    sed -i 's|<base href="/"/>||g' /var/www/nexus-cos/admin/index.html
    echo "   ✅ Fixed admin/index.html"
fi

if [ -f "/var/www/nexus-cos/creator-hub/index.html" ]; then
    # Remove problematic base tag from creator-hub index.html  
    sed -i 's|<base href="/">||g' /var/www/nexus-cos/creator-hub/index.html
    sed -i 's|<base href="/"/>||g' /var/www/nexus-cos/creator-hub/index.html
    echo "   ✅ Fixed creator-hub/index.html"
fi

# Generate the corrected Nginx configuration
echo "⚙️  Generating corrected Nginx configuration..."

cat > /etc/nginx/sites-available/nexuscos << 'EOF'
# Nexus COS React Frontend - Emergency Fix Configuration
# Addresses redirect loops and static asset serving issues

server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    
    # Comment out HTTPS redirect for immediate testing
    # return 301 https://$host$request_uri;
    
    # Temporarily serve over HTTP to test functionality
    root /var/www/nexus-cos;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Default redirect to admin panel  
    location = / {
        return 301 /admin/;
    }
    
    # Admin Panel React Application - Fixed for SPA routing
    location /admin/ {
        alias /var/www/nexus-cos/admin/;
        index index.html;
        
        # Try files first, then fallback to index.html for React Router
        try_files $uri $uri/ @admin_fallback;
    }
    
    # Admin React Router fallback
    location @admin_fallback {
        # Serve index.html for any unmatched admin routes
        rewrite ^.*$ /admin/index.html last;
    }
    
    # Admin static assets with proper caching
    location /admin/static/ {
        alias /var/www/nexus-cos/admin/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Creator Hub React Application - Fixed for SPA routing  
    location /creator-hub/ {
        alias /var/www/nexus-cos/creator-hub/;
        index index.html;
        
        # Try files first, then fallback to index.html for React Router
        try_files $uri $uri/ @creator_fallback;
    }
    
    # Creator Hub React Router fallback
    location @creator_fallback {
        # Serve index.html for any unmatched creator-hub routes
        rewrite ^.*$ /creator-hub/index.html last;
    }
    
    # Creator Hub static assets with proper caching
    location /creator-hub/static/ {
        alias /var/www/nexus-cos/creator-hub/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Interactive module map
    location /diagram/ {
        alias /var/www/nexus-cos/diagram/;
        try_files $uri $uri/ =404;
    }
    
    # API endpoints (proxy to backend services)
    location /api/ {
        proxy_pass http://127.0.0.1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Health check
    location /health {
        proxy_pass http://127.0.0.1:3000/health;
        proxy_set_header Host $host;
    }
    
    # Block sensitive files
    location ~ /\. {
        deny all;
    }
    
    error_log /var/log/nginx/nexuscos.error.log;
    access_log /var/log/nginx/nexuscos.access.log;
}

# HTTPS Configuration (enable when SSL is ready)
# server {
#     listen 443 ssl http2;
#     server_name nexuscos.online www.nexuscos.online;
#     
#     ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_prefer_server_ciphers on;
#     
#     # Include same location blocks as HTTP version above
# }
EOF

echo "   ✅ Nginx configuration generated"

# Test the configuration
echo "🧪 Testing Nginx configuration..."
if nginx -t; then
    echo "   ✅ Nginx configuration is valid"
else
    echo "   ❌ Nginx configuration has errors"
    exit 1
fi

# Enable the site
echo "🔗 Enabling the site..."
ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/nexuscos

# Reload Nginx
echo "🔄 Reloading Nginx..."
if systemctl reload nginx; then
    echo "   ✅ Nginx reloaded successfully"
else
    echo "   ❌ Failed to reload Nginx"
    exit 1
fi

# Set proper file permissions
echo "🔐 Setting proper file permissions..."
chown -R www-data:www-data /var/www/nexus-cos 2>/dev/null || echo "   ⚠️  Could not set www-data ownership (may need root)"
chmod -R 755 /var/www/nexus-cos

echo ""
echo "✅ EMERGENCY FIX COMPLETE!"
echo "=========================="
echo ""
echo "🎯 Test the fixed endpoints:"
echo "   Admin Panel:    http://nexuscos.online/admin/"
echo "   Creator Hub:    http://nexuscos.online/creator-hub/"
echo "   API Health:     http://nexuscos.online/health"
echo ""
echo "🔍 Debug commands if issues persist:"
echo "   Check logs:     tail -f /var/log/nginx/nexuscos.error.log"
echo "   Test config:    nginx -t"
echo "   Curl test:      curl -L http://nexuscos.online/admin/"
echo ""
echo "🔧 Key fixes applied:"
echo "   ✅ Removed problematic <base href> tags"
echo "   ✅ Fixed React Router fallback handling"
echo "   ✅ Corrected static asset serving"
echo "   ✅ Prevented redirect loops"
echo "   ✅ Added proper location block ordering"
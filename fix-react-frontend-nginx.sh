#!/bin/bash
# Nexus COS React Frontend Nginx Configuration Generator
# This script creates the correct Nginx configuration to serve React SPAs without redirect loops

set -e

# Configuration
NGINX_CONFIG_FILE="/etc/nginx/sites-available/nexuscos"
WEBROOT="/var/www/nexus-cos"
DOMAIN="${1:-nexuscos.online}"

echo "🚀 Generating Nexus COS React Frontend Nginx Configuration..."

# Create the optimized Nginx configuration
cat > "$NGINX_CONFIG_FILE" << 'EOF'
# Nexus COS React Frontend Configuration
# Optimized for serving React SPAs with client-side routing

server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    
    # HTTP to HTTPS redirect (only if SSL is enabled)
    # return 301 https://$host$request_uri;
    
    # For now, serve over HTTP for testing
    root /var/www/nexus-cos;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Default redirect to admin panel
    location = / {
        return 301 /admin/;
    }
    
    # Admin Panel React Application
    location /admin/ {
        alias /var/www/nexus-cos/admin/build/;
        index index.html;
        
        # Handle React Router - try files, then fallback to index.html
        try_files $uri $uri/ @admin_fallback;
        
        # Cache static assets
        location ~* ^/admin/static/.+\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            alias /var/www/nexus-cos/admin/build/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Access-Control-Allow-Origin "*";
        }
    }
    
    # Admin fallback for React Router
    location @admin_fallback {
        rewrite ^/admin/(.*)$ /admin/index.html last;
    }
    
    # Creator Hub React Application  
    location /creator-hub/ {
        alias /var/www/nexus-cos/creator-hub/build/;
        index index.html;
        
        # Handle React Router - try files, then fallback to index.html
        try_files $uri $uri/ @creator_fallback;
        
        # Cache static assets
        location ~* ^/creator-hub/static/.+\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            alias /var/www/nexus-cos/creator-hub/build/static/;
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Access-Control-Allow-Origin "*";
        }
    }
    
    # Creator Hub fallback for React Router
    location @creator_fallback {
        rewrite ^/creator-hub/(.*)$ /creator-hub/index.html last;
    }
    
    # Main frontend application (optional)
    location /app/ {
        alias /var/www/nexus-cos/frontend/dist/;
        index index.html;
        try_files $uri $uri/ /app/index.html;
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
    
    # Interactive module map
    location /diagram/ {
        alias /var/www/nexus-cos/diagram/;
        try_files $uri $uri/ =404;
    }
    
    # Block access to sensitive files
    location ~ /\. {
        deny all;
    }
    
    location ~ /(README|CHANGELOG|LICENSE|COPYING) {
        deny all;
    }
    
    # Logging
    error_log /var/log/nginx/nexuscos.error.log;
    access_log /var/log/nginx/nexuscos.access.log;
}

# HTTPS configuration (uncomment when SSL is ready)
# server {
#     listen 443 ssl http2;
#     server_name nexuscos.online www.nexuscos.online;
#     
#     ssl_certificate /etc/letsencrypt/live/nexuscos.online/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/nexuscos.online/privkey.pem;
#     ssl_protocols TLSv1.2 TLSv1.3;
#     ssl_prefer_server_ciphers on;
#     
#     # Include the same location blocks as above
# }
EOF

echo "✅ Nginx configuration created at $NGINX_CONFIG_FILE"

# Create deployment structure
echo "📁 Creating deployment directory structure..."
mkdir -p /var/www/nexus-cos/admin
mkdir -p /var/www/nexus-cos/creator-hub
mkdir -p /var/www/nexus-cos/frontend/dist
mkdir -p /var/www/nexus-cos/diagram

echo "📦 Copying built React applications..."

# Copy admin build if it exists
if [ -d "/home/runner/work/nexus-cos/nexus-cos/admin/build" ]; then
    cp -r /home/runner/work/nexus-cos/nexus-cos/admin/build/* /var/www/nexus-cos/admin/
    echo "  ✅ Admin panel deployed"
else
    echo "  ⚠️  Admin build not found"
fi

# Copy creator-hub build if it exists
if [ -d "/home/runner/work/nexus-cos/nexus-cos/creator-hub/build" ]; then
    cp -r /home/runner/work/nexus-cos/nexus-cos/creator-hub/build/* /var/www/nexus-cos/creator-hub/
    echo "  ✅ Creator hub deployed"
else
    echo "  ⚠️  Creator hub build not found"
fi

# Set proper permissions
chown -R www-data:www-data /var/www/nexus-cos 2>/dev/null || echo "  ⚠️  Could not set www-data ownership (running as non-root)"
chmod -R 755 /var/www/nexus-cos

echo ""
echo "🎯 Configuration Summary:"
echo "  📍 Admin Panel:    http://$DOMAIN/admin/"
echo "  📍 Creator Hub:    http://$DOMAIN/creator-hub/"
echo "  📍 API Endpoints:  http://$DOMAIN/api/"
echo "  📍 Module Map:     http://$DOMAIN/diagram/"
echo ""
echo "🔧 Next steps:"
echo "  1. Enable the site: ln -sf /etc/nginx/sites-available/nexuscos /etc/nginx/sites-enabled/"
echo "  2. Test config: nginx -t"
echo "  3. Reload nginx: systemctl reload nginx"
echo "  4. Test endpoints: curl -L http://$DOMAIN/admin/"
echo ""
echo "✨ Nexus COS React Frontend deployment configuration complete!"
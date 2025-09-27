#!/bin/bash
# puabo_fix_nginx_ssl.sh
# Script to fix Nginx SSL for nexuscos.online
#
# Usage: sudo ./puabo_fix_nginx_ssl.sh
# Prerequisites: 
#   - SSL certificates should be present in /tmp (nexuscos.online.crt and nexuscos.online.key)
#   - nginx package should be installed 
#   - Script should be run with sudo privileges

# Variables
SSL_DIR="/etc/ssl/ionos"
WEB_ROOT="/var/www/nexuscos.online/html"
SITE_CONF="/etc/nginx/sites-available/nexuscos.online.conf"
CERT_TMP_DIR="/tmp"
DOMAIN="nexuscos.online"

# Step 1: Create directories
sudo mkdir -p "$SSL_DIR"
sudo mkdir -p "$WEB_ROOT"

# Step 2: Move SSL certs from /tmp with validation
if [ -f "$CERT_TMP_DIR/nexuscos.online.crt" ]; then
    # Validate certificate before copying
    if openssl x509 -in "$CERT_TMP_DIR/nexuscos.online.crt" -noout -checkend 0 > /dev/null 2>&1; then
        sudo cp "$CERT_TMP_DIR/nexuscos.online.crt" "$SSL_DIR/fullchain.pem"
        echo "✅ Certificate validated and copied"
    else
        echo "❌ Certificate validation failed - certificate may be expired or invalid"
        exit 1
    fi
else
    echo "❌ Certificate file not found: $CERT_TMP_DIR/nexuscos.online.crt"
    echo "Please place your certificate file at $CERT_TMP_DIR/nexuscos.online.crt"
    exit 1
fi

if [ -f "$CERT_TMP_DIR/nexuscos.online.key" ]; then
    # Validate private key before copying
    if openssl rsa -in "$CERT_TMP_DIR/nexuscos.online.key" -check -noout > /dev/null 2>&1; then
        sudo cp "$CERT_TMP_DIR/nexuscos.online.key" "$SSL_DIR/privkey.pem"
        echo "✅ Private key validated and copied"
    else
        echo "❌ Private key validation failed - key may be corrupted or invalid"
        exit 1
    fi
else
    echo "❌ Private key file not found: $CERT_TMP_DIR/nexuscos.online.key"
    echo "Please place your private key file at $CERT_TMP_DIR/nexuscos.online.key"
    exit 1
fi

# Verify certificate and key match
if ! openssl x509 -noout -modulus -in "$SSL_DIR/fullchain.pem" | openssl md5 | \
     diff - <(openssl rsa -noout -modulus -in "$SSL_DIR/privkey.pem" | openssl md5) > /dev/null 2>&1; then
    echo "❌ Certificate and private key do not match"
    exit 1
else
    echo "✅ Certificate and private key match"
fi

# Step 3: Set permissions
sudo chmod 600 "$SSL_DIR/privkey.pem"
sudo chmod 644 "$SSL_DIR/fullchain.pem"
sudo chown -R www-data:www-data "$WEB_ROOT"

# Step 4: Create Nginx site config
sudo tee "$SITE_CONF" > /dev/null <<EOL
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;

    return 301 https://\$host\$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN www.$DOMAIN;

    root $WEB_ROOT;
    index index.html index.htm;

    ssl_certificate     $SSL_DIR/fullchain.pem;
    ssl_certificate_key $SSL_DIR/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    access_log /var/log/nginx/${DOMAIN}_access.log;
    error_log /var/log/nginx/${DOMAIN}_error.log;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOL

# Step 5: Enable site
if [ ! -L "/etc/nginx/sites-enabled/nexuscos.online.conf" ]; then
    sudo ln -s "$SITE_CONF" /etc/nginx/sites-enabled/
fi

# Step 6: Test Nginx config
if sudo nginx -t; then
    echo "✅ Nginx configuration test passed"
else
    echo "❌ Nginx configuration test failed"
    exit 1
fi

# Step 7: Reload Nginx
if sudo systemctl reload nginx; then
    echo "✅ Nginx reloaded successfully"
else
    echo "❌ Failed to reload Nginx"
    exit 1
fi

# Step 8: Final validation
echo "🔍 Running final SSL configuration validation..."
sleep 2

# Check if HTTPS is accessible
if curl -k -s --connect-timeout 5 "https://localhost" > /dev/null 2>&1; then
    echo "✅ HTTPS access working"
else
    echo "⚠️  HTTPS access test failed (this may be normal if no content is served)"
fi

# Check if HTTP redirects to HTTPS
if curl -s -I --connect-timeout 5 "http://localhost" 2>/dev/null | grep -q "Location.*https"; then
    echo "✅ HTTP to HTTPS redirect working"
else
    echo "⚠️  HTTP to HTTPS redirect test failed"
fi

echo ""
echo "🎉 Nginx SSL setup completed for $DOMAIN"
echo ""
echo "📋 Next steps:"
echo "   1. Test configuration: sudo ./test_ssl_config.sh"
echo "   2. Check logs: sudo tail -f /var/log/nginx/${DOMAIN}_error.log"
echo "   3. Test in browser: https://$DOMAIN"
echo ""
echo "📁 Certificate location: $SSL_DIR/"
echo "🔧 Configuration file: $SITE_CONF"
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

# Step 2: Move SSL certs from /tmp
if [ -f "$CERT_TMP_DIR/nexuscos.online.crt" ]; then
    sudo cp "$CERT_TMP_DIR/nexuscos.online.crt" "$SSL_DIR/fullchain.pem"
fi

if [ -f "$CERT_TMP_DIR/nexuscos.online.key" ]; then
    sudo cp "$CERT_TMP_DIR/nexuscos.online.key" "$SSL_DIR/privkey.pem"
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
    ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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
sudo nginx -t

# Step 7: Reload Nginx
sudo systemctl reload nginx

echo "Nginx SSL setup completed for $DOMAIN"
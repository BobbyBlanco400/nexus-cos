#!/bin/bash
# Generate self-signed SSL certificates for n3xuscos.online

set -e

SSL_DIR="/etc/nginx/ssl"
DOMAIN="n3xuscos.online"

echo "🔐 Creating self-signed SSL certificates for $DOMAIN..."

# Create SSL directory
sudo mkdir -p $SSL_DIR

# Generate private key
sudo openssl genrsa -out $SSL_DIR/$DOMAIN.key 2048

# Generate certificate signing request
sudo openssl req -new -key $SSL_DIR/$DOMAIN.key -out $SSL_DIR/$DOMAIN.csr -subj "/C=US/ST=Test/L=Test/O=Test/CN=$DOMAIN"

# Generate self-signed certificate
sudo openssl x509 -req -days 365 -in $SSL_DIR/$DOMAIN.csr -signkey $SSL_DIR/$DOMAIN.key -out $SSL_DIR/$DOMAIN.crt

# Set proper permissions
sudo chmod 600 $SSL_DIR/$DOMAIN.key
sudo chmod 644 $SSL_DIR/$DOMAIN.crt

# Create nginx SSL parameters file
sudo tee $SSL_DIR/ssl-params.conf > /dev/null << 'EOF'
# SSL Configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;
EOF

echo "✅ Self-signed SSL certificates created at $SSL_DIR/"
echo "   Certificate: $SSL_DIR/$DOMAIN.crt"
echo "   Private Key: $SSL_DIR/$DOMAIN.key"
echo "   Parameters:  $SSL_DIR/ssl-params.conf"
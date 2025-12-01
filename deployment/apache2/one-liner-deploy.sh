#!/bin/bash
# Nexus COS - Socket.IO Apache2 One-Liner Configuration
# This script provides a safe one-liner deployment for Socket.IO

set -Eeuo pipefail

TS="$(date +%s)"
CONF="/var/www/vhosts/system/nexuscos.online/conf/vhost.conf"

# Backup existing configuration
cp "$CONF" "$CONF.bak.$TS" 2>/dev/null || true

# Create Socket.IO configuration block
SOCKETIO_CONFIG='
# Nexus COS - Socket.IO Streaming Configuration
# Added by automated deployment

# Socket.IO Streaming Service - /streaming/socket.io/
<Location /streaming/socket.io/>
    ProxyPass http://127.0.0.1:3043/socket.io/
    ProxyPassReverse http://127.0.0.1:3043/socket.io/
    
    # WebSocket support
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /streaming/socket.io/(.*) ws://127.0.0.1:3043/socket.io/$1 [P,L]
    
    # Headers
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</Location>

# Socket.IO Streaming Service - /socket.io/
<Location /socket.io/>
    ProxyPass http://127.0.0.1:3043/socket.io/ retry=0
    ProxyPassReverse http://127.0.0.1:3043/socket.io/
    
    # WebSocket support
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /socket.io/(.*) ws://127.0.0.1:3043/socket.io/$1 [P,L]
    
    # Headers
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</Location>

# Streaming Health Check
<Location /streaming/health>
    ProxyPass http://127.0.0.1:3043/streaming/health
    ProxyPassReverse http://127.0.0.1:3043/streaming/health
</Location>
'

# Check if Socket.IO config already exists
if grep -q "Socket.IO Streaming Configuration" "$CONF" 2>/dev/null; then
    echo "Socket.IO configuration already exists in vhost.conf"
    echo "Removing old configuration and adding new one..."
    # Remove old Socket.IO configuration
    sed -i '/# Nexus COS - Socket.IO Streaming Configuration/,/^$/d' "$CONF"
fi

# Append Socket.IO configuration to vhost.conf
echo "$SOCKETIO_CONFIG" >> "$CONF"

# Enable required Apache modules
a2enmod proxy proxy_http proxy_wstunnel rewrite headers >/dev/null 2>&1 || true

# Reconfigure Plesk domain
if command -v plesk >/dev/null 2>&1; then
    plesk sbin httpdmng --reconfigure-domain nexuscos.online 2>/dev/null || \
    plesk sbin httpdmng --reconfigure-all 2>/dev/null || true
fi

# Reload Apache2
systemctl reload apache2 2>/dev/null || systemctl restart apache2 2>/dev/null || true

# Test endpoints
echo "[domain-sio-streaming]"
curl -sS -D - --max-time 8 "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling&t=$TS" | head -n2

echo "[domain-sio-root]"
curl -sS -D - --max-time 8 "https://nexuscos.online/socket.io/?EIO=4&transport=polling&t=$TS" | head -n2

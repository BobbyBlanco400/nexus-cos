#!/bin/bash
# Nexus COS - Socket.IO Apache2 Configuration (Plesk-safe version)
# This script creates Socket.IO config in vhost_nginx.conf which Plesk doesn't regenerate

set -Eeuo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
VHOST_DIR="/var/www/vhosts/system/${DOMAIN}/conf"
VHOST_CONF="${VHOST_DIR}/vhost.conf"
SOCKETIO_CONF="${VHOST_DIR}/vhost_socketio.conf"
SOCKET_IO_PORT="${SOCKET_IO_PORT:-3043}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nexus COS - Socket.IO Setup (Plesk-safe)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Domain: ${YELLOW}${DOMAIN}${NC}"
echo -e "Socket.IO Config: ${YELLOW}${SOCKETIO_CONF}${NC}"
echo -e "Socket.IO Port: ${YELLOW}${SOCKET_IO_PORT}${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Backup existing configuration
backup_config() {
    local timestamp=$(date +%s)
    if [ -f "$SOCKETIO_CONF" ]; then
        echo -e "${YELLOW}Creating backup: ${SOCKETIO_CONF}.bak.${timestamp}${NC}"
        cp "$SOCKETIO_CONF" "${SOCKETIO_CONF}.bak.${timestamp}" 2>/dev/null || true
    fi
}

# Enable required Apache modules
enable_modules() {
    echo -e "${YELLOW}Enabling required Apache2 modules...${NC}"
    a2enmod proxy proxy_http proxy_wstunnel rewrite headers >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Modules enabled${NC}"
}

# Create Socket.IO configuration in separate file
create_socketio_config() {
    echo -e "${YELLOW}Creating Socket.IO configuration...${NC}"
    
    # Ensure directory exists
    mkdir -p "$VHOST_DIR"
    
    # Create Socket.IO configuration file
    cat > "$SOCKETIO_CONF" <<'EOF'
# Nexus COS - Socket.IO Streaming Configuration
# This file is included in the Apache vhost configuration
# It handles WebSocket proxying for Socket.IO

# IMPORTANT: More specific paths MUST come first in Apache

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
EOF
    
    echo -e "${GREEN}✓ Socket.IO configuration created at ${SOCKETIO_CONF}${NC}"
}

# Add include directive to vhost.conf if not already present
add_include_to_vhost() {
    echo -e "${YELLOW}Adding include directive to vhost.conf...${NC}"
    
    if [ ! -f "$VHOST_CONF" ]; then
        echo -e "${RED}✗ vhost.conf not found at $VHOST_CONF${NC}"
        return 1
    fi
    
    # Check if include already exists
    if grep -q "vhost_socketio.conf" "$VHOST_CONF"; then
        echo -e "${YELLOW}⚠ Include directive already exists in vhost.conf${NC}"
    else
        # Add include directive at the end of the file
        echo "" >> "$VHOST_CONF"
        echo "# Include Socket.IO configuration" >> "$VHOST_CONF"
        echo "Include ${SOCKETIO_CONF}" >> "$VHOST_CONF"
        echo -e "${GREEN}✓ Include directive added to vhost.conf${NC}"
    fi
}

# Test Apache configuration
test_config() {
    echo -e "${YELLOW}Testing Apache2 configuration...${NC}"
    if apachectl configtest 2>&1 | grep -q "Syntax OK"; then
        echo -e "${GREEN}✓ Configuration syntax OK${NC}"
        return 0
    else
        echo -e "${RED}✗ Configuration syntax error${NC}"
        apachectl configtest
        return 1
    fi
}

# Reload Apache
reload_apache() {
    echo -e "${YELLOW}Reloading Apache2...${NC}"
    if systemctl reload apache2 2>/dev/null; then
        echo -e "${GREEN}✓ Apache2 reloaded successfully${NC}"
    else
        echo -e "${YELLOW}⚠ Reload failed, attempting restart...${NC}"
        systemctl restart apache2 2>/dev/null || true
        if systemctl is-active --quiet apache2; then
            echo -e "${GREEN}✓ Apache2 restarted successfully${NC}"
        else
            echo -e "${RED}✗ Apache2 failed to start${NC}"
            systemctl status apache2 --no-pager || true
            return 1
        fi
    fi
}

# Test endpoints
test_endpoints() {
    echo -e "${YELLOW}Testing Socket.IO endpoints...${NC}"
    
    local timestamp=$(date +%s)
    
    echo ""
    echo -e "${BLUE}[Testing /socket.io/]${NC}"
    local response=$(curl -sS -D - --max-time 8 "https://${DOMAIN}/socket.io/?EIO=4&transport=polling&t=${timestamp}" 2>/dev/null | head -n2)
    echo "$response"
    
    if echo "$response" | grep -q "200 OK"; then
        echo -e "${GREEN}✓ /socket.io/ is working${NC}"
    else
        echo -e "${RED}✗ /socket.io/ returned non-200 status${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}[Testing /streaming/socket.io/]${NC}"
    response=$(curl -sS -D - --max-time 8 "https://${DOMAIN}/streaming/socket.io/?EIO=4&transport=polling&t=${timestamp}" 2>/dev/null | head -n2)
    echo "$response"
    
    if echo "$response" | grep -q "200 OK"; then
        echo -e "${GREEN}✓ /streaming/socket.io/ is working${NC}"
    else
        echo -e "${RED}✗ /streaming/socket.io/ returned non-200 status${NC}"
    fi
    
    echo ""
}

# Main execution
main() {
    backup_config
    enable_modules
    create_socketio_config
    add_include_to_vhost
    
    if ! test_config; then
        echo -e "${RED}Configuration test failed. Not reloading Apache.${NC}"
        exit 1
    fi
    
    reload_apache
    
    echo ""
    echo -e "${BLUE}Waiting for services to stabilize...${NC}"
    sleep 3
    
    test_endpoints
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✓ Socket.IO configuration complete${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Configuration file: ${SOCKETIO_CONF}"
    echo "Include directive added to: ${VHOST_CONF}"
    echo ""
    echo "If /streaming/socket.io/ still returns 404:"
    echo "1. Check Socket.IO service is running: pm2 status socket-io-streaming"
    echo "2. Check port 3043 is listening: netstat -tlnp | grep 3043"
    echo "3. Run diagnostic: bash deployment/apache2/diagnose-socket-io.sh"
    echo ""
}

# Run main function
main "$@"

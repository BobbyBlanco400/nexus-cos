#!/bin/bash
# Nexus COS - Apache2 Socket.IO Configuration Deployment Script
# This script configures Apache2 for Socket.IO streaming on a Plesk/VPS server

set -Eeuo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
VHOST_CONF="${VHOST_CONF:-/var/www/vhosts/system/${DOMAIN}/conf/vhost.conf}"
SOCKET_IO_PORT="${SOCKET_IO_PORT:-3043}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nexus COS - Apache2 Socket.IO Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Domain: ${YELLOW}${DOMAIN}${NC}"
echo -e "VHost Config: ${YELLOW}${VHOST_CONF}${NC}"
echo -e "Socket.IO Port: ${YELLOW}${SOCKET_IO_PORT}${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Backup existing configuration
backup_config() {
    if [ -f "$VHOST_CONF" ]; then
        local timestamp=$(date +%s)
        local backup_file="${VHOST_CONF}.bak.${timestamp}"
        echo -e "${YELLOW}Creating backup: ${backup_file}${NC}"
        cp "$VHOST_CONF" "$backup_file" 2>/dev/null || true
    fi
}

# Enable required Apache modules
enable_modules() {
    echo -e "${YELLOW}Enabling required Apache2 modules...${NC}"
    a2enmod proxy proxy_http proxy_wstunnel rewrite headers >/dev/null 2>&1 || true
    echo -e "${GREEN}✓ Modules enabled${NC}"
}

# Create Socket.IO configuration
create_config() {
    echo -e "${YELLOW}Creating Socket.IO configuration...${NC}"
    
    # Ensure directory exists
    mkdir -p "$(dirname "$VHOST_CONF")"
    
    # Write configuration
    cat > "$VHOST_CONF" <<'EOF'
# Nexus COS - Socket.IO Streaming Configuration

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
    
    echo -e "${GREEN}✓ Configuration created${NC}"
}

# Reconfigure Plesk domain (if Plesk is available)
reconfigure_plesk() {
    if command -v plesk >/dev/null 2>&1; then
        echo -e "${YELLOW}Reconfiguring Plesk domain...${NC}"
        plesk sbin httpdmng --reconfigure-domain "$DOMAIN" 2>/dev/null || \
        plesk sbin httpdmng --reconfigure-all 2>/dev/null || true
        echo -e "${GREEN}✓ Plesk reconfigured${NC}"
    else
        echo -e "${YELLOW}⚠ Plesk not found, skipping Plesk reconfiguration${NC}"
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
    create_config
    
    if ! test_config; then
        echo -e "${RED}Configuration test failed. Not applying changes.${NC}"
        exit 1
    fi
    
    reconfigure_plesk
    reload_apache
    
    echo ""
    echo -e "${BLUE}Waiting for services to stabilize...${NC}"
    sleep 3
    
    test_endpoints
    
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}✓ Apache2 Socket.IO configuration complete${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "1. Ensure Socket.IO service is running on port ${SOCKET_IO_PORT}"
    echo -e "2. Check service status: systemctl status socket-io-streaming"
    echo -e "3. Monitor logs: journalctl -u socket-io-streaming -f"
    echo ""
}

# Run main function
main "$@"

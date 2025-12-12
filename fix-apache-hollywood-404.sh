#!/bin/bash
# Fix Apache 404 error for V-Suite Hollywood
# This script configures Apache to properly proxy /v-suite/hollywood/ to the vscreen-hollywood service

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "Fix Apache 404 for V-Suite Hollywood"
echo "=========================================="
echo ""

# Configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
HTTP_PORT="${HTTP_PORT:-8882}"
APACHE_CONF="${APACHE_CONF:-/etc/apache2/conf-available/nexuscos-hollywood.conf}"
VSCREEN_PORT=8088

echo -e "${BLUE}[INFO]${NC} Domain: $DOMAIN"
echo -e "${BLUE}[INFO]${NC} Apache HTTP Port: $HTTP_PORT"
echo -e "${BLUE}[INFO]${NC} Config file: $APACHE_CONF"
echo -e "${BLUE}[INFO]${NC} vscreen-hollywood port: $VSCREEN_PORT"
echo ""

# Enable required Apache modules
echo -e "${BLUE}[INFO]${NC} Enabling required Apache modules..."
a2enmod proxy proxy_http proxy_wstunnel headers rewrite || true
echo ""

# Create Apache configuration
echo -e "${BLUE}[INFO]${NC} Creating Apache configuration..."

cat > "$APACHE_CONF" << 'APACHECONF'
# V-Suite Hollywood Apache Configuration
# Proxies /v-suite/hollywood/ to vscreen-hollywood service on port 8088

<IfModule mod_proxy.c>
    # HTTP requests - proxy to Node.js service
    <Location /v-suite/hollywood>
        ProxyPreserveHost On
        ProxyPass http://127.0.0.1:8088/
        ProxyPassReverse http://127.0.0.1:8088/
        
        # Allow all methods
        <LimitExcept GET POST PUT DELETE OPTIONS>
            Require all granted
        </LimitExcept>
        
        # CORS headers
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
    </Location>
    
    # WebSocket support - must be before the main location
    <Location /v-suite/hollywood/ws>
        ProxyPass ws://127.0.0.1:8088/ws
        ProxyPassReverse ws://127.0.0.1:8088/ws
        
        # WebSocket specific headers
        RewriteEngine On
        RewriteCond %{HTTP:Upgrade} =websocket [NC]
        RewriteRule /(.*)           ws://127.0.0.1:8088/$1 [P,L]
        RewriteCond %{HTTP:Upgrade} !=websocket [NC]
        RewriteRule /(.*)           http://127.0.0.1:8088/$1 [P,L]
        
        ProxyPreserveHost On
    </Location>
</IfModule>
APACHECONF

echo -e "${GREEN}[SUCCESS]${NC} Configuration file created"
echo ""

# Test Apache configuration
echo -e "${BLUE}[INFO]${NC} Testing Apache configuration..."
if apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}[SUCCESS]${NC} Apache configuration is valid"
else
    echo -e "${RED}[ERROR]${NC} Apache configuration has errors"
    apache2ctl configtest
    exit 1
fi
echo ""

# Enable the configuration
echo -e "${BLUE}[INFO]${NC} Enabling configuration..."
a2enconf nexuscos-hollywood || true
echo ""

# Reload Apache
echo -e "${BLUE}[INFO]${NC} Reloading Apache..."
if systemctl reload apache2 2>/dev/null || service apache2 reload 2>/dev/null || apache2ctl -k graceful 2>/dev/null; then
    echo -e "${GREEN}[SUCCESS]${NC} Apache reloaded"
else
    echo -e "${YELLOW}[WARNING]${NC} Apache reload may have failed, check manually"
fi
echo ""

# Wait a moment for Apache to reload
sleep 2

# Test the endpoint
echo -e "${BLUE}[INFO]${NC} Testing endpoint..."
PAGE_CODE=$(curl -sk -o /dev/null -w '%{http_code}' "https://${DOMAIN}/v-suite/hollywood/" 2>/dev/null || echo "000")

echo ""
echo "=========================================="
echo "Results"
echo "=========================================="
echo -e "Page: https://${DOMAIN}/v-suite/hollywood/"
echo -e "HTTP Status: $PAGE_CODE"

if [ "$PAGE_CODE" = "200" ]; then
    echo -e "${GREEN}✓ SUCCESS - Page is accessible${NC}"
elif [ "$PAGE_CODE" = "404" ]; then
    echo -e "${RED}✗ FAILED - Still getting 404${NC}"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check if vscreen-hollywood is running: pm2 list | grep vscreen"
    echo "2. Check if port 8088 is listening: netstat -tlnp | grep 8088"
    echo "3. Test direct connection: curl http://localhost:8088/"
    echo "4. Check Apache error logs: tail -f /var/log/apache2/error.log"
    echo "5. Verify Apache config is enabled: a2query -c nexuscos-hollywood"
else
    echo -e "${YELLOW}⚠ WARNING - Unexpected status code${NC}"
fi

# Test WebSocket
echo ""
echo -e "${BLUE}[INFO]${NC} Testing WebSocket handshake..."
WS_RESPONSE=$(curl -sk -D- -o /dev/null -H "Upgrade: websocket" -H "Connection: Upgrade" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" "https://${DOMAIN}/v-suite/hollywood/ws" 2>&1 | head -1)

if echo "$WS_RESPONSE" | grep -q "101"; then
    echo -e "${GREEN}✓ WebSocket handshake successful${NC}"
else
    echo -e "${YELLOW}⚠ WebSocket response: $WS_RESPONSE${NC}"
fi

echo ""
echo "=========================================="
echo "Configuration Details"
echo "=========================================="
echo "Apache config: $APACHE_CONF"
echo "vscreen-hollywood: http://127.0.0.1:$VSCREEN_PORT/"
echo "Public URL: https://${DOMAIN}/v-suite/hollywood/"
echo ""
echo "To view the configuration:"
echo "  cat $APACHE_CONF"
echo ""
echo "To check Apache status:"
echo "  systemctl status apache2"
echo ""
echo "To view Apache logs:"
echo "  tail -f /var/log/apache2/error.log"
echo "=========================================="

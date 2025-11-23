#!/bin/bash
# One-command fix for git pull and Apache 404 issues
# This script can be run directly without needing to pull first

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "Nexus COS - Quick Fix"
echo "=========================================="
echo ""

# Step 1: Fix git pull issue
echo -e "${BLUE}[STEP 1/2]${NC} Resolving git pull conflict..."
echo ""

if [ -d ".git" ]; then
    # Configure git to allow merge
    git config pull.rebase false 2>/dev/null || true
    
    # Try to pull with merge strategy
    if git pull origin copilot/fix-deployment-issues --no-rebase 2>&1; then
        echo -e "${GREEN}✓ Git pull successful${NC}"
    else
        echo -e "${YELLOW}⚠ Pull failed, trying hard reset...${NC}"
        git fetch origin
        git reset --hard origin/copilot/fix-deployment-issues
        echo -e "${GREEN}✓ Reset to latest version${NC}"
    fi
else
    echo -e "${RED}✗ Not in a git repository${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[STEP 2/2]${NC} Fixing Apache 404 error..."
echo ""

# Step 2: Fix Apache 404
DOMAIN="${DOMAIN:-nexuscos.online}"
APACHE_CONF="/etc/apache2/conf-available/nexuscos-hollywood.conf"
VSCREEN_PORT=8088

# Enable required Apache modules
echo "Enabling Apache modules..."
a2enmod proxy proxy_http proxy_wstunnel headers rewrite 2>/dev/null || true

# Create Apache configuration
echo "Creating Apache configuration..."
cat > "$APACHE_CONF" << 'APACHEEOF'
# V-Suite Hollywood Apache Configuration
<IfModule mod_proxy.c>
    # HTTP requests
    <Location /v-suite/hollywood>
        ProxyPreserveHost On
        ProxyPass http://127.0.0.1:8088/
        ProxyPassReverse http://127.0.0.1:8088/
        
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
    </Location>
    
    # WebSocket
    <Location /v-suite/hollywood/ws>
        ProxyPass ws://127.0.0.1:8088/ws
        ProxyPassReverse ws://127.0.0.1:8088/ws
        ProxyPreserveHost On
    </Location>
</IfModule>
APACHEEOF

echo -e "${GREEN}✓ Configuration created${NC}"

# Test and reload Apache
echo "Testing Apache configuration..."
if apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo -e "${GREEN}✓ Configuration valid${NC}"
    
    # Enable config
    a2enconf nexuscos-hollywood 2>/dev/null || true
    
    # Reload Apache
    systemctl reload apache2 2>/dev/null || service apache2 reload 2>/dev/null || apache2ctl -k graceful 2>/dev/null
    echo -e "${GREEN}✓ Apache reloaded${NC}"
else
    echo -e "${RED}✗ Configuration error${NC}"
    apache2ctl configtest
    exit 1
fi

# Wait for reload
sleep 2

# Test the endpoint
echo ""
echo "Testing endpoint..."
PAGE_CODE=$(curl -sk -o /dev/null -w '%{http_code}' "https://${DOMAIN}/v-suite/hollywood/" 2>/dev/null || echo "000")

echo ""
echo "=========================================="
echo "Results"
echo "=========================================="
echo "URL: https://${DOMAIN}/v-suite/hollywood/"
echo "Status: $PAGE_CODE"
echo ""

if [ "$PAGE_CODE" = "200" ]; then
    echo -e "${GREEN}✓ SUCCESS - 404 error fixed!${NC}"
elif [ "$PAGE_CODE" = "404" ]; then
    echo -e "${YELLOW}⚠ Still 404 - Check if vscreen-hollywood is running:${NC}"
    echo "  pm2 list | grep vscreen"
    echo "  curl http://localhost:8088/"
else
    echo -e "${YELLOW}⚠ Status $PAGE_CODE${NC}"
fi

echo ""
echo "=========================================="
echo "All fixes applied!"
echo "=========================================="

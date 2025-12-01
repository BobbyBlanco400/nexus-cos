#!/bin/bash
# Diagnose and fix vscreen-hollywood 404 issue
# This script checks why Apache is returning 404 despite proper configuration

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo "V-Suite Hollywood 404 Diagnostic & Fix"
echo "=========================================="
echo ""

# Step 1: Check if vscreen-hollywood is running in PM2
echo -e "${BLUE}[1/6]${NC} Checking PM2 status..."
if pm2 describe vscreen-hollywood > /dev/null 2>&1; then
    STATUS=$(pm2 describe vscreen-hollywood | grep "status" | head -1 | awk '{print $4}')
    echo -e "  vscreen-hollywood PM2 status: ${YELLOW}$STATUS${NC}"
    
    if [ "$STATUS" != "online" ]; then
        echo -e "  ${YELLOW}⚠ Service is not online, restarting...${NC}"
        pm2 restart vscreen-hollywood || pm2 start /var/www/nexuscos.online/nexus-cos-app/nexus-cos/services/vscreen-hollywood/server.js --name vscreen-hollywood
        sleep 3
    fi
else
    echo -e "  ${YELLOW}⚠ vscreen-hollywood not in PM2, starting it...${NC}"
    cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos/services/vscreen-hollywood
    pm2 start server.js --name vscreen-hollywood
    cd - > /dev/null
    sleep 3
fi

# Step 2: Test direct connection to port 8088
echo ""
echo -e "${BLUE}[2/6]${NC} Testing direct connection to port 8088..."
if curl -s http://localhost:8088/ > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ Service responding on port 8088${NC}"
    RESPONSE=$(curl -s http://localhost:8088/ | head -c 100)
    echo -e "  Response: ${RESPONSE}..."
else
    echo -e "  ${RED}✗ Service NOT responding on port 8088${NC}"
    echo -e "  ${YELLOW}Checking if port is in use...${NC}"
    netstat -tlnp | grep 8088 || echo "  Port 8088 is not listening"
    
    echo -e "  ${YELLOW}Checking PM2 logs...${NC}"
    pm2 logs vscreen-hollywood --lines 10 --nostream || true
fi

# Step 3: Check Apache configuration
echo ""
echo -e "${BLUE}[3/6]${NC} Checking Apache configuration..."
if [ -f /etc/apache2/conf-available/nexuscos-hollywood.conf ]; then
    echo -e "  ${GREEN}✓ Configuration file exists${NC}"
    echo -e "  Content preview:"
    head -15 /etc/apache2/conf-available/nexuscos-hollywood.conf | sed 's/^/    /'
else
    echo -e "  ${RED}✗ Configuration file missing${NC}"
fi

# Step 4: Check if configuration is enabled
echo ""
echo -e "${BLUE}[4/6]${NC} Checking if configuration is enabled..."
if a2query -c nexuscos-hollywood 2>/dev/null | grep -q "enabled"; then
    echo -e "  ${GREEN}✓ Configuration is enabled${NC}"
else
    echo -e "  ${YELLOW}⚠ Configuration not enabled, enabling...${NC}"
    a2enconf nexuscos-hollywood
    systemctl reload apache2 2>/dev/null || service apache2 reload 2>/dev/null
fi

# Step 5: Check Apache virtual host configuration
echo ""
echo -e "${BLUE}[5/6]${NC} Checking Apache virtual host..."
echo -e "  Checking for SSL virtual host with v-suite/hollywood..."
if grep -r "v-suite/hollywood" /etc/apache2/sites-enabled/ 2>/dev/null; then
    echo -e "  ${YELLOW}⚠ Found existing v-suite/hollywood configuration in sites-enabled${NC}"
    echo -e "  ${YELLOW}This might conflict with conf-available config${NC}"
else
    echo -e "  ${GREEN}✓ No conflicting configuration in sites-enabled${NC}"
fi

# Step 6: Test the endpoint
echo ""
echo -e "${BLUE}[6/6]${NC} Testing endpoint..."
STATUS_CODE=$(curl -sk -o /dev/null -w '%{http_code}' https://nexuscos.online/v-suite/hollywood/ 2>/dev/null || echo "000")

echo ""
echo "=========================================="
echo "Final Test Results"
echo "=========================================="
echo "URL: https://nexuscos.online/v-suite/hollywood/"
echo "Status Code: $STATUS_CODE"
echo ""

if [ "$STATUS_CODE" = "200" ]; then
    echo -e "${GREEN}✓✓✓ SUCCESS! 404 is FIXED! ✓✓✓${NC}"
elif [ "$STATUS_CODE" = "404" ]; then
    echo -e "${RED}✗ Still 404${NC}"
    echo ""
    echo "Possible causes:"
    echo "1. Apache virtual host config might be overriding conf-available config"
    echo "2. ProxyPass might need to be in the virtual host directly"
    echo "3. Service might be running but not accessible"
    echo ""
    echo "Next steps:"
    echo "1. Check main Apache config: ls -la /etc/apache2/sites-enabled/"
    echo "2. Check Apache error log: tail -50 /var/log/apache2/error.log"
    echo "3. Try adding config directly to virtual host instead of conf-available"
else
    echo -e "${YELLOW}⚠ Unexpected status: $STATUS_CODE${NC}"
fi

echo ""
echo "=========================================="
echo "Diagnostic Info"
echo "=========================================="
echo "PM2 vscreen-hollywood status:"
pm2 describe vscreen-hollywood 2>/dev/null | grep -E "status|restarts|uptime" || echo "  Not in PM2"
echo ""
echo "Port 8088 status:"
netstat -tlnp | grep 8088 || echo "  Not listening"
echo ""
echo "Apache configuration:"
a2query -c nexuscos-hollywood 2>/dev/null || echo "  Not enabled"
echo "=========================================="

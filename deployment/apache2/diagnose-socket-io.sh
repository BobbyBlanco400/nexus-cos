#!/bin/bash
# Nexus COS - Socket.IO Diagnostic Script
# This script helps diagnose why /streaming/socket.io/ returns 404

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CONF="/var/www/vhosts/system/nexuscos.online/conf/vhost.conf"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Socket.IO Diagnostic Report${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. Check if Socket.IO service is running
echo -e "${YELLOW}1. Checking Socket.IO service status...${NC}"
if pm2 list | grep -q "socket-io-streaming.*online"; then
    echo -e "${GREEN}✓ Socket.IO service is running${NC}"
    pm2 list | grep socket-io-streaming
else
    echo -e "${RED}✗ Socket.IO service is NOT running${NC}"
    echo "Start it with: pm2 start ecosystem.platform.config.js --only socket-io-streaming"
fi
echo ""

# 2. Check if port 3043 is listening
echo -e "${YELLOW}2. Checking if port 3043 is listening...${NC}"
if netstat -tlnp 2>/dev/null | grep -q ":3043"; then
    echo -e "${GREEN}✓ Port 3043 is listening${NC}"
    netstat -tlnp | grep ":3043"
else
    echo -e "${RED}✗ Port 3043 is NOT listening${NC}"
fi
echo ""

# 3. Test service directly
echo -e "${YELLOW}3. Testing Socket.IO service directly (localhost)...${NC}"
echo "Testing: http://localhost:3043/health"
curl -sS http://localhost:3043/health 2>/dev/null && echo "" || echo -e "${RED}✗ Failed to connect${NC}"
echo ""
echo "Testing: http://localhost:3043/socket.io/?EIO=4&transport=polling"
curl -sS "http://localhost:3043/socket.io/?EIO=4&transport=polling" 2>/dev/null | head -c 100 && echo "" || echo -e "${RED}✗ Failed${NC}"
echo ""

# 4. Check vhost.conf for Socket.IO configuration
echo -e "${YELLOW}4. Checking vhost.conf for Socket.IO configuration...${NC}"
if [ -f "$CONF" ]; then
    if grep -q "Socket.IO Streaming Configuration" "$CONF"; then
        echo -e "${GREEN}✓ Socket.IO configuration found in vhost.conf${NC}"
        echo ""
        echo "Socket.IO configuration in vhost.conf:"
        echo "========================================"
        grep -A 30 "Socket.IO Streaming Configuration" "$CONF" | head -50
        echo "========================================"
    else
        echo -e "${RED}✗ Socket.IO configuration NOT found in vhost.conf${NC}"
        echo "Run: sudo bash deployment/apache2/deploy-socket-io.sh"
    fi
else
    echo -e "${RED}✗ vhost.conf file not found at $CONF${NC}"
fi
echo ""

# 5. Check for conflicting Location blocks
echo -e "${YELLOW}5. Checking for conflicting Location blocks...${NC}"
if [ -f "$CONF" ]; then
    echo "All Location blocks in vhost.conf:"
    echo "========================================"
    grep -n "^[[:space:]]*<Location" "$CONF" | head -20
    echo "========================================"
fi
echo ""

# 6. Check Apache modules
echo -e "${YELLOW}6. Checking Apache modules...${NC}"
for mod in proxy proxy_http proxy_wstunnel rewrite headers; do
    if apache2ctl -M 2>/dev/null | grep -q "${mod}_module"; then
        echo -e "${GREEN}✓ ${mod} module enabled${NC}"
    else
        echo -e "${RED}✗ ${mod} module NOT enabled${NC}"
    fi
done
echo ""

# 7. Test endpoints via HTTPS
echo -e "${YELLOW}7. Testing endpoints via HTTPS...${NC}"
TS=$(date +%s)

echo "Testing: https://nexuscos.online/socket.io/?EIO=4&transport=polling"
curl -sS -D - --max-time 8 "https://nexuscos.online/socket.io/?EIO=4&transport=polling&t=$TS" 2>/dev/null | head -n2
echo ""

echo "Testing: https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling"
curl -sS -D - --max-time 8 "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling&t=$TS" 2>/dev/null | head -n2
echo ""

echo "Testing: https://nexuscos.online/streaming/health"
curl -sS -D - --max-time 8 "https://nexuscos.online/streaming/health" 2>/dev/null | head -n2
echo ""

# 8. Check Apache error logs for recent errors
echo -e "${YELLOW}8. Recent Apache errors (last 10 lines)...${NC}"
if [ -f "/var/log/apache2/error.log" ]; then
    tail -10 /var/log/apache2/error.log 2>/dev/null || echo "Could not read Apache error log"
else
    echo "Apache error log not found"
fi
echo ""

# 9. Check if there are multiple vhost files
echo -e "${YELLOW}9. Checking for other Apache configuration files...${NC}"
if [ -d "/var/www/vhosts/system/nexuscos.online/conf" ]; then
    echo "Apache config files for nexuscos.online:"
    ls -la /var/www/vhosts/system/nexuscos.online/conf/*.conf 2>/dev/null || echo "No .conf files found"
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Diagnostic Report Complete${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "If /streaming/socket.io/ still returns 404:"
echo "1. Check if there are conflicting Location blocks above"
echo "2. Verify Socket.IO configuration is at the END of vhost.conf"
echo "3. Check Apache error logs for proxy errors"
echo "4. Try restarting Apache: systemctl restart apache2"
echo ""

#!/bin/bash
# Quick Deployment Validation Script
# Run this after fix-deployment-issues.sh to verify everything is working

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Quick Deployment Validation"
echo "=========================================="
echo ""

# Function to test endpoint
test_endpoint() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name... "
    if response=$(curl -s --max-time 3 "$url" 2>/dev/null); then
        if echo "$response" | grep -q "ok\|healthy\|running\|status"; then
            echo -e "${GREEN}✓ OK${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Responding but unexpected format${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Check PM2 services
echo -e "${BLUE}[1] Checking PM2 Services...${NC}"
if command -v pm2 &> /dev/null; then
    ONLINE=$(pm2 jlist 2>/dev/null | grep -o '"status":"online"' | wc -l)
    ERRORED=$(pm2 jlist 2>/dev/null | grep -o '"status":"errored"' | wc -l)
    echo "  - Online: $ONLINE services"
    echo "  - Errored: $ERRORED services"
    
    if [ "$ERRORED" -eq 0 ]; then
        echo -e "  ${GREEN}✓ No errored services${NC}"
    else
        echo -e "  ${RED}✗ $ERRORED service(s) need attention${NC}"
    fi
else
    echo -e "  ${RED}✗ PM2 not installed${NC}"
fi
echo ""

# Check PostgreSQL
echo -e "${BLUE}[2] Checking PostgreSQL...${NC}"
if docker ps | grep -q nexus-postgres; then
    echo -e "  ${GREEN}✓ Container running${NC}"
    if docker exec nexus-postgres pg_isready -U nexuscos &>/dev/null; then
        echo -e "  ${GREEN}✓ Database accepting connections${NC}"
    else
        echo -e "  ${RED}✗ Database not ready${NC}"
    fi
else
    echo -e "  ${RED}✗ Container not running${NC}"
fi
echo ""

# Check service endpoints
echo -e "${BLUE}[3] Checking Service Endpoints...${NC}"
test_endpoint "http://localhost:3001/health" "Backend API (3001)"
test_endpoint "http://localhost:3013/health" "PuaboMusicChain (3013)"
test_endpoint "http://localhost:8088/health" "V-Screen Hollywood (8088)"
echo ""

# Check ports
echo -e "${BLUE}[4] Checking Port Availability...${NC}"
for port in 3001 3013 5432 8088; do
    echo -n "  Port $port... "
    if nc -z localhost $port 2>/dev/null || lsof -i :$port &>/dev/null; then
        echo -e "${GREEN}✓ LISTENING${NC}"
    else
        echo -e "${RED}✗ NOT LISTENING${NC}"
    fi
done
echo ""

# System resources
echo -e "${BLUE}[5] System Resources...${NC}"
DISK=$(df -h . | tail -1 | awk '{print $5}')
echo "  - Disk Usage: $DISK"

if command -v free &> /dev/null; then
    MEM=$(free | grep Mem | awk '{printf "%.0f%%", $3/$2 * 100.0}')
    echo "  - Memory Usage: $MEM"
fi
echo ""

# Final verdict
echo "=========================================="
echo -e "${BLUE}Summary:${NC}"
echo "  Run 'pm2 list' to see all services"
echo "  Run 'pm2 logs <service>' to view logs"
echo "  Run './production-audit.sh' for detailed audit"
echo ""

# Quick links
echo -e "${BLUE}Quick Commands:${NC}"
echo "  - View all services: pm2 list"
echo "  - View logs: pm2 logs"
echo "  - Restart all: pm2 restart all"
echo "  - Stop all: pm2 stop all"
echo "  - Check DB: docker exec nexus-postgres pg_isready -U nexuscos"
echo "=========================================="

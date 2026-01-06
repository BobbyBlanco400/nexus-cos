#!/bin/bash
# PM2 Environment Variable Verification Script
# This script helps diagnose database connectivity issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo "PM2 Environment Verification Script"
echo "======================================"
echo ""

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}❌ PM2 is not installed${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Step 1: PM2 Process Status${NC}"
echo "-----------------------------------"
pm2 list
echo ""

# Get the first process ID for detailed inspection
FIRST_PROCESS=$(pm2 jlist | jq -r '.[0].name' 2>/dev/null || echo "backend-api")

echo -e "${BLUE}📋 Step 2: Environment Variables for '$FIRST_PROCESS'${NC}"
echo "-----------------------------------"
pm2 describe "$FIRST_PROCESS" 2>/dev/null | grep -A 20 "env:" || echo "Could not retrieve environment variables"
echo ""

echo -e "${BLUE}📋 Step 3: Database Connection Variables${NC}"
echo "-----------------------------------"
pm2 describe "$FIRST_PROCESS" 2>/dev/null | grep "DB_" || echo "No DB_ variables found"
echo ""

echo -e "${BLUE}📋 Step 4: Health Endpoint Check${NC}"
echo "-----------------------------------"
HEALTH_URL="https://n3xuscos.online/health"
echo "Checking: $HEALTH_URL"
HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" 2>/dev/null || echo '{"error": "Could not reach health endpoint"}')
echo "$HEALTH_RESPONSE" | jq . 2>/dev/null || echo "$HEALTH_RESPONSE"
echo ""

# Check if DB is up
DB_STATUS=$(echo "$HEALTH_RESPONSE" | jq -r '.db' 2>/dev/null || echo "unknown")
if [ "$DB_STATUS" = "up" ]; then
    echo -e "${GREEN}✅ Database Status: UP${NC}"
elif [ "$DB_STATUS" = "down" ]; then
    echo -e "${RED}❌ Database Status: DOWN${NC}"
    DB_ERROR=$(echo "$HEALTH_RESPONSE" | jq -r '.dbError' 2>/dev/null || echo "No error message")
    echo -e "${RED}   Error: $DB_ERROR${NC}"
else
    echo -e "${YELLOW}⚠️  Database Status: UNKNOWN${NC}"
fi
echo ""

echo -e "${BLUE}📋 Step 5: PostgreSQL Service Status${NC}"
echo "-----------------------------------"
if systemctl is-active --quiet postgresql 2>/dev/null; then
    echo -e "${GREEN}✅ PostgreSQL service is running${NC}"
    systemctl status postgresql --no-pager -l | head -n 5
elif systemctl is-active --quiet postgresql@* 2>/dev/null; then
    echo -e "${GREEN}✅ PostgreSQL service is running${NC}"
    systemctl status 'postgresql@*' --no-pager -l | head -n 5
else
    echo -e "${RED}❌ PostgreSQL service is not running${NC}"
    echo "   Try: sudo systemctl start postgresql"
fi
echo ""

echo -e "${BLUE}📋 Step 6: Docker Containers (if using Docker)${NC}"
echo "-----------------------------------"
if command -v docker &> /dev/null; then
    DOCKER_POSTGRES=$(docker ps --filter "name=nexus-cos-postgres" --format "{{.Names}}" 2>/dev/null || echo "")
    if [ -n "$DOCKER_POSTGRES" ]; then
        echo -e "${GREEN}✅ Docker PostgreSQL container is running: $DOCKER_POSTGRES${NC}"
        docker ps --filter "name=nexus-cos-postgres"
    else
        echo -e "${YELLOW}⚠️  No Docker PostgreSQL container found${NC}"
        echo "   If you're using Docker, start it with:"
        echo "   docker-compose -f docker-compose.pf.yml up -d nexus-cos-postgres"
    fi
else
    echo -e "${YELLOW}⚠️  Docker is not installed or not in PATH${NC}"
fi
echo ""

echo -e "${BLUE}📋 Step 7: Recent PM2 Logs (Last 30 lines)${NC}"
echo "-----------------------------------"
pm2 logs "$FIRST_PROCESS" --lines 30 --nostream --err 2>/dev/null | tail -n 15 || echo "Could not retrieve logs"
echo ""

echo -e "${BLUE}📋 Step 8: Ecosystem Config Check${NC}"
echo "-----------------------------------"
if [ -f "ecosystem.config.js" ]; then
    echo -e "${GREEN}✅ ecosystem.config.js exists${NC}"
    echo "First service DB configuration:"
    grep -A 10 "env: {" ecosystem.config.js | head -n 15 || echo "Could not parse config"
else
    echo -e "${RED}❌ ecosystem.config.js not found${NC}"
fi
echo ""

echo "======================================"
echo "DIAGNOSTIC SUMMARY"
echo "======================================"
echo ""

# Summary checks
ISSUES=0

# Check PM2
if pm2 list &> /dev/null; then
    echo -e "${GREEN}✅ PM2 is running${NC}"
else
    echo -e "${RED}❌ PM2 has issues${NC}"
    ISSUES=$((ISSUES + 1))
fi

# Check health endpoint
if [ "$DB_STATUS" = "up" ]; then
    echo -e "${GREEN}✅ Database connection is working${NC}"
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! You are ready for beta launch!${NC}"
elif [ "$DB_STATUS" = "down" ]; then
    echo -e "${RED}❌ Database connection is NOT working${NC}"
    ISSUES=$((ISSUES + 1))
    echo ""
    echo -e "${YELLOW}📋 Next Steps to Fix:${NC}"
    echo ""
    
    # Analyze the error
    if echo "$DB_ERROR" | grep -qi "ECONNREFUSED"; then
        echo "  1. PostgreSQL is not running or not listening on the configured port"
        echo "     → Start PostgreSQL: sudo systemctl start postgresql"
        echo "     → Or start Docker container: docker-compose up -d nexus-cos-postgres"
    elif echo "$DB_ERROR" | grep -qi "EAI_AGAIN"; then
        echo "  1. DB_HOST cannot be resolved (DNS/hostname issue)"
        echo "     → Check ecosystem.config.js has correct DB_HOST"
        echo "     → Current DB_HOST setting:"
        grep "DB_HOST" ecosystem.config.js | head -n 1
        echo "     → Should be 'localhost' or 'nexus-cos-postgres' or valid IP"
    elif echo "$DB_ERROR" | grep -qi "authentication failed"; then
        echo "  1. Database credentials are incorrect"
        echo "     → Check DB_USER and DB_PASSWORD in ecosystem.config.js"
        echo "     → Match them with your PostgreSQL setup"
    else
        echo "  1. Check the DB error message above for details"
        echo "  2. Verify DB_HOST, DB_USER, DB_PASSWORD in ecosystem.config.js"
        echo "  3. Ensure PostgreSQL is running and accessible"
    fi
    echo ""
    echo "  After fixing, restart PM2:"
    echo "     pm2 restart all"
else
    echo -e "${YELLOW}⚠️  Could not determine database status${NC}"
    ISSUES=$((ISSUES + 1))
fi

echo ""
if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! System is healthy.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Found $ISSUES issue(s) - follow the steps above to resolve${NC}"
    exit 1
fi

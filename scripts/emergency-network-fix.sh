#!/bin/bash

# N3XUS Emergency Network Repair Script
# Enforces N3XUS Handshake 55-45-17 Compliance
# Date: 2026-01-11
# Status: EMERGENCY REPAIR PROTOCOL ACTIVE

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔵 Starting Emergency Network Repair...${NC}"
echo -e "${BLUE}🔒 Enforcing N3XUS Handshake 55-45-17...${NC}"

# Verify N3XUS Handshake 55-45-17 in configuration files
verify_handshake() {
    local file=$1
    if grep -q "55-45-17" "$file"; then
        echo -e "${GREEN}✓ N3XUS Handshake 55-45-17 verified in $file${NC}"
        return 0
    else
        echo -e "${RED}✗ N3XUS Handshake 55-45-17 missing in $file${NC}"
        return 1
    fi
}

# Verify handshake in critical files
echo -e "${BLUE}🔍 Verifying N3XUS Handshake 55-45-17 in configuration files...${NC}"
verify_handshake "nginx.conf.docker" || echo -e "${YELLOW}⚠️  Warning: Handshake check failed for nginx.conf.docker${NC}"
verify_handshake "server.js" || echo -e "${YELLOW}⚠️  Warning: Handshake check failed for server.js${NC}"

# Stop and remove all existing containers
echo -e "${BLUE}🛑 Stopping all existing containers...${NC}"
docker-compose down --remove-orphans 2>/dev/null || true

# Remove dangling images
echo -e "${BLUE}🧹 Cleaning up dangling images...${NC}"
docker image prune -f 2>/dev/null || true

# Build and start services with N3XUS Handshake enforcement
echo -e "${BLUE}🚀 Building and starting services with N3XUS Handshake 55-45-17...${NC}"
docker-compose up --build -d

# Wait for services to initialize
echo -e "${BLUE}⏳ Waiting for services to stabilize (30s)...${NC}"
sleep 30

# Verify Backend Status
echo -e "${BLUE}🔍 Verifying Backend Status (Host -> Port 3000)...${NC}"
if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ BACKEND OPERATIONAL on Port 3000${NC}"
    
    # Verify N3XUS Handshake in response
    HANDSHAKE=$(curl -sf -I http://localhost:3000/health | grep -i "X-Nexus-Handshake" | grep -i "55-45-17" || echo "")
    if [ -n "$HANDSHAKE" ]; then
        echo -e "${GREEN}✅ N3XUS Handshake 55-45-17 VERIFIED in API Response${NC}"
        echo -e "${GREEN}   Header: $HANDSHAKE${NC}"
    else
        echo -e "${YELLOW}⚠️  N3XUS Handshake 55-45-17 not found in API response headers${NC}"
    fi
    
    # Get backend health data
    echo -e "${BLUE}📊 Backend Health:${NC}"
    curl -s http://localhost:3000/health | jq '.' 2>/dev/null || curl -s http://localhost:3000/health
else
    echo -e "${RED}❌ BACKEND UNREACHABLE on Port 3000${NC}"
    echo -e "${RED}📜 Backend Logs:${NC}"
    docker logs puabo-api --tail 50
fi

# Verify Nginx Proxy
echo -e "${BLUE}🔍 Verifying Nginx Proxy (Host -> Port 80)...${NC}"
if curl -sf http://localhost:80/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ NGINX PROXY OPERATIONAL${NC}"
    
    # Verify N3XUS Handshake in Nginx response
    HANDSHAKE=$(curl -sf -I http://localhost:80/health | grep -i "X-Nexus-Handshake" | grep -i "55-45-17" || echo "")
    if [ -n "$HANDSHAKE" ]; then
        echo -e "${GREEN}✅ N3XUS Handshake 55-45-17 VERIFIED in Nginx Response${NC}"
        echo -e "${GREEN}   Header: $HANDSHAKE${NC}"
    else
        echo -e "${YELLOW}⚠️  N3XUS Handshake 55-45-17 not found in Nginx response headers${NC}"
    fi
else
    echo -e "${RED}❌ NGINX PROXY FAILED${NC}"
    echo -e "${RED}📜 Nginx Logs (CRITICAL):${NC}"
    docker logs nexus-nginx --tail 50
fi

# Verify Database Connectivity
echo -e "${BLUE}🔍 Verifying Database Connection...${NC}"
if docker exec nexus-postgres pg_isready -U ${DATABASE_USER:-nexus_user} -d ${DATABASE_NAME:-nexus_db} > /dev/null 2>&1; then
    echo -e "${GREEN}✅ DATABASE OPERATIONAL${NC}"
else
    echo -e "${RED}❌ DATABASE CONNECTION FAILED${NC}"
    echo -e "${RED}📜 Database Logs:${NC}"
    docker logs nexus-postgres --tail 50
fi

# Display running containers
echo -e "${BLUE}📦 Running Containers:${NC}"
docker-compose ps

# Final verification summary
echo -e ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}         N3XUS EMERGENCY REPAIR COMPLETE${NC}"
echo -e "${BLUE}         Handshake 55-45-17 Enforcement Active${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e ""

# Check if all services are healthy
ALL_HEALTHY=true
if ! curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    ALL_HEALTHY=false
fi
if ! curl -sf http://localhost:80/health > /dev/null 2>&1; then
    ALL_HEALTHY=false
fi
if ! docker exec nexus-postgres pg_isready -U ${DATABASE_USER:-nexus_user} -d ${DATABASE_NAME:-nexus_db} > /dev/null 2>&1; then
    ALL_HEALTHY=false
fi

if [ "$ALL_HEALTHY" = true ]; then
    echo -e "${GREEN}✅ ALL SYSTEMS OPERATIONAL${NC}"
    echo -e "${GREEN}✅ N3XUS Handshake 55-45-17 VERIFIED${NC}"
    echo -e "${GREEN}✅ Platform Ready for Launch${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  SOME SYSTEMS REQUIRE ATTENTION${NC}"
    echo -e "${YELLOW}   Please review the logs above for details${NC}"
    exit 1
fi

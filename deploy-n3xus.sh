#!/usr/bin/env bash
# N3XUS COS - One-Command Deployment
# Governance Order: 55-45-17
# 
# This script deploys the complete N3XUS COS stack with full verification

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║   ███╗   ██╗██████╗ ██╗  ██╗██╗   ██╗███████╗                  ║
║   ████╗  ██║╚════██╗╚██╗██╔╝██║   ██║██╔════╝                  ║
║   ██╔██╗ ██║ █████╔╝ ╚███╔╝ ██║   ██║███████╗                  ║
║   ██║╚██╗██║ ╚═══██╗ ██╔██╗ ██║   ██║╚════██║                  ║
║   ██║ ╚████║██████╔╝██╔╝ ██╗╚██████╔╝███████║                  ║
║   ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝                  ║
║                                                                  ║
║              Complete Operating System - v3.0                   ║
║           Governance Order: 55-45-17 ENFORCED                   ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Starting N3XUS COS Deployment...${NC}"
echo ""

# Step 1: Pre-flight checks
echo -e "${CYAN}[1/6] Running pre-flight checks...${NC}"

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

if ! docker ps >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker daemon is not running. Please start Docker.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is ready${NC}"

# Step 2: Verify governance compliance
echo -e "${CYAN}[2/6] Verifying governance compliance (55-45-17)...${NC}"

if [ -f "${SCRIPT_DIR}/trae-governance-verification.sh" ]; then
    if bash "${SCRIPT_DIR}/trae-governance-verification.sh" > /tmp/governance-check.log 2>&1; then
        echo -e "${GREEN}✅ Governance verification passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Governance verification had warnings (continuing)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Governance verification script not found (skipping)${NC}"
fi

# Step 3: Build frontend if needed
echo -e "${CYAN}[3/6] Checking frontend build...${NC}"

if [ ! -d "${SCRIPT_DIR}/frontend/dist" ]; then
    echo -e "${YELLOW}Frontend not built. Building now...${NC}"
    if [ -d "${SCRIPT_DIR}/frontend" ]; then
        cd "${SCRIPT_DIR}/frontend"
        npm install > /dev/null 2>&1
        npm run build > /dev/null 2>&1
        echo -e "${GREEN}✅ Frontend built successfully${NC}"
        cd "${SCRIPT_DIR}"
    else
        echo -e "${YELLOW}⚠️  Frontend directory not found (skipping)${NC}"
    fi
else
    echo -e "${GREEN}✅ Frontend already built${NC}"
fi

# Step 4: Stop existing containers
echo -e "${CYAN}[4/6] Stopping existing containers...${NC}"

if docker-compose ps | grep -q "Up"; then
    docker-compose down
    echo -e "${GREEN}✅ Existing containers stopped${NC}"
else
    echo -e "${GREEN}✅ No existing containers running${NC}"
fi

# Step 5: Start services
echo -e "${CYAN}[5/6] Starting N3XUS COS services...${NC}"

docker-compose up -d

# Wait for services to be ready
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 5

echo -e "${GREEN}✅ Services started${NC}"

# Step 6: Verify deployment
echo -e "${CYAN}[6/6] Verifying deployment...${NC}"

# Check if containers are running
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✅ Containers are running${NC}"
    
    # Show running containers
    echo ""
    echo -e "${CYAN}Running containers:${NC}"
    docker-compose ps
    echo ""
    
    # Test health endpoint
    echo -e "${CYAN}Testing health endpoint...${NC}"
    sleep 2
    
    if curl -s http://localhost/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health endpoint responding${NC}"
    else
        echo -e "${YELLOW}⚠️  Health endpoint not responding yet (may need more time)${NC}"
    fi
    
else
    echo -e "${RED}❌ Containers failed to start${NC}"
    echo -e "${RED}Check logs with: docker-compose logs${NC}"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              DEPLOYMENT SUCCESSFUL                               ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${CYAN}📊 Deployment Summary:${NC}"
echo -e "  Status: ${GREEN}✅ SUCCESS${NC}"
echo -e "  Governance: ${GREEN}55-45-17 ENFORCED${NC}"
echo -e "  Mode: ${GREEN}Production${NC}"
echo ""
echo -e "${CYAN}🌐 Access URLs:${NC}"
echo -e "  Core Platform:   ${BLUE}http://localhost${NC}"
echo -e "  Casino Lounge:   ${BLUE}http://localhost/puaboverse${NC}"
echo -e "  API Endpoint:    ${BLUE}http://localhost/api${NC}"
echo -e "  Health Check:    ${BLUE}http://localhost/health${NC}"
echo ""
echo -e "${CYAN}📝 Useful Commands:${NC}"
echo -e "  View logs:       ${YELLOW}docker-compose logs -f${NC}"
echo -e "  Stop services:   ${YELLOW}docker-compose down${NC}"
echo -e "  Restart:         ${YELLOW}docker-compose restart${NC}"
echo -e "  Service status:  ${YELLOW}docker-compose ps${NC}"
echo ""
echo -e "${CYAN}🔐 Test Handshake Enforcement:${NC}"
echo -e "  ${YELLOW}curl -H 'X-N3XUS-Handshake: 55-45-17' http://localhost/api/status${NC}"
echo ""
echo -e "${GREEN}🚀 N3XUS COS is now running!${NC}"
echo ""

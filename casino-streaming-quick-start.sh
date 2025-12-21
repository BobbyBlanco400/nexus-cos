#!/bin/bash

################################################################################
# Nexus COS - Casino V5 & Streaming Quick Start
# 
# This script provides a quick way to deploy Casino V5 and Streaming modules
# in development or production environments.
#
# Usage: ./casino-streaming-quick-start.sh [environment]
#   environment: dev (default) or prod
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

ENV=${1:-dev}

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Casino V5 & Streaming Module - Quick Start                     ║${NC}"
echo -e "${BLUE}║   Environment: ${ENV}                                                    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Warning: Docker not found. Install docker first.${NC}"
    exit 1
fi

# Determine compose command
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    echo -e "${YELLOW}Warning: Neither docker-compose nor docker compose found.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Using compose command: ${COMPOSE_CMD}"
echo ""

# Step 1: Verify directory structure
echo -e "${BLUE}[1/5]${NC} Verifying directory structure..."
CASINO_DIR="modules/casino-nexus/frontend/public"
STREAMING_DIR="modules/puabo-ott-tv-streaming/frontend/public"

if [ ! -d "$CASINO_DIR" ]; then
    echo -e "${YELLOW}Creating casino directory structure...${NC}"
    mkdir -p "$CASINO_DIR"
fi

if [ ! -d "$STREAMING_DIR" ]; then
    echo -e "${YELLOW}Creating streaming directory structure...${NC}"
    mkdir -p "$STREAMING_DIR"
fi

echo -e "${GREEN}✓${NC} Directory structure verified"
echo ""

# Step 2: Copy frontend files
echo -e "${BLUE}[2/5]${NC} Deploying frontend files..."

if [ -f "modules/casino-nexus/frontend/index.html" ]; then
    cp modules/casino-nexus/frontend/index.html "$CASINO_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Casino frontend deployed"
else
    echo -e "${YELLOW}! Casino index.html not found${NC}"
fi

if [ -f "modules/puabo-ott-tv-streaming/frontend/index.html" ]; then
    cp modules/puabo-ott-tv-streaming/frontend/index.html "$STREAMING_DIR/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Streaming frontend deployed"
else
    echo -e "${YELLOW}! Streaming index.html not found${NC}"
fi

echo ""

# Step 3: Start services
echo -e "${BLUE}[3/5]${NC} Starting services..."

if [ "$ENV" = "prod" ]; then
    echo -e "${YELLOW}Starting in production mode...${NC}"
    $COMPOSE_CMD -f docker-compose.yml up -d
else
    echo -e "${YELLOW}Starting in development mode...${NC}"
    $COMPOSE_CMD up -d
fi

echo -e "${GREEN}✓${NC} Services started"
echo ""

# Step 4: Wait for services to be ready
echo -e "${BLUE}[4/5]${NC} Waiting for services to be ready..."
sleep 5

# Check if services are running
if docker ps | grep -q nexus-nginx; then
    echo -e "${GREEN}✓${NC} Nginx is running"
else
    echo -e "${YELLOW}! Nginx not running${NC}"
fi

if docker ps | grep -q puabo-api; then
    echo -e "${GREEN}✓${NC} API is running"
else
    echo -e "${YELLOW}! API not running${NC}"
fi

echo ""

# Step 5: Verify deployment
echo -e "${BLUE}[5/5]${NC} Verifying deployment..."

# Check if files are accessible in container
if docker exec nexus-nginx test -f /usr/share/nginx/html/casino/index.html 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Casino V5 is accessible in container"
else
    echo -e "${YELLOW}! Casino V5 not found in container${NC}"
fi

if docker exec nexus-nginx test -f /usr/share/nginx/html/streaming/index.html 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Streaming is accessible in container"
else
    echo -e "${YELLOW}! Streaming not found in container${NC}"
fi

echo ""

# Display access information
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         DEPLOYMENT COMPLETE                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Access your services:${NC}"
echo ""
echo -e "  🎰 Casino V5:      http://localhost/casino"
echo -e "  📺 Streaming:      http://localhost/streaming"
echo -e "  🔌 API:            http://localhost:3000"
echo -e "  🏠 Main Platform:  http://localhost/"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo ""
echo -e "  View logs:         ${COMPOSE_CMD} logs -f"
echo -e "  Stop services:     ${COMPOSE_CMD} down"
echo -e "  Restart services:  ${COMPOSE_CMD} restart"
echo -e "  Check status:      ${COMPOSE_CMD} ps"
echo ""
echo -e "${BLUE}For production deployment, see:${NC}"
echo -e "  ./CASINO_V5_STREAMING_FIX_GUIDE.md"
echo ""

exit 0

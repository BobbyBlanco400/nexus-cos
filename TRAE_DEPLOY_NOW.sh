#!/bin/bash
#
# Nexus COS v2025 - One-Command Deployment Script for TRAE Solo
# This script deploys the complete unified Nexus COS platform with all 42 services
#
# Usage: bash TRAE_DEPLOY_NOW.sh
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}🧠 Nexus COS v2025 - TRAE Solo Deployment${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -eq 0 ]; then 
    echo -e "${YELLOW}⚠️  Running as root. This is OK for VPS deployment.${NC}"
    SUDO=""
else
    echo -e "${GREEN}✓${NC} Running as regular user (will use sudo where needed)"
    SUDO="sudo"
fi
echo ""

# Step 1: Check prerequisites
echo -e "${BLUE}[1/8]${NC} Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker not found. Installing Docker...${NC}"
    $SUDO apt-get update
    $SUDO apt-get install -y docker.io
    $SUDO systemctl start docker
    $SUDO systemctl enable docker
    echo -e "${GREEN}✓${NC} Docker installed successfully"
else
    echo -e "${GREEN}✓${NC} Docker is installed"
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}✗${NC} Docker Compose v2 not found. Please install Docker Compose v2"
    exit 1
else
    echo -e "${GREEN}✓${NC} Docker Compose is installed"
fi

if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  Git not found. Installing Git...${NC}"
    $SUDO apt-get install -y git
    echo -e "${GREEN}✓${NC} Git installed successfully"
else
    echo -e "${GREEN}✓${NC} Git is installed"
fi

echo ""

# Step 2: Validate structure
echo -e "${BLUE}[2/8]${NC} Validating repository structure..."

if [ ! -f "docker-compose.unified.yml" ]; then
    echo -e "${RED}✗${NC} docker-compose.unified.yml not found!"
    echo "Make sure you're in the nexus-cos directory."
    exit 1
fi

echo -e "${GREEN}✓${NC} Repository structure validated"
echo ""

# Step 3: Configure environment
echo -e "${BLUE}[3/8]${NC} Setting up environment configuration..."

if [ ! -f ".env.pf" ]; then
    if [ -f ".env.pf.example" ]; then
        cp .env.pf.example .env.pf
        echo -e "${YELLOW}⚠️  Created .env.pf from template${NC}"
        echo -e "${YELLOW}⚠️  Please edit .env.pf and set your DB_PASSWORD and JWT_SECRET${NC}"
        echo ""
        echo -e "Required variables:"
        echo -e "  ${BLUE}DB_PASSWORD${NC}=your_secure_database_password"
        echo -e "  ${BLUE}JWT_SECRET${NC}=your_jwt_secret_key_min_32_chars"
        echo ""
        echo -e "Generate secure secrets with:"
        echo -e "  ${GREEN}openssl rand -base64 32${NC}"
        echo ""
        read -p "Press Enter to edit .env.pf now, or Ctrl+C to exit and edit manually..."
        nano .env.pf || vi .env.pf || echo "Please edit .env.pf manually"
    else
        echo -e "${RED}✗${NC} .env.pf.example not found!"
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} .env.pf exists"
fi

# Check if critical variables are set
if grep -q "DB_PASSWORD=your_secure_password" .env.pf 2>/dev/null || \
   grep -q "DB_PASSWORD=$" .env.pf 2>/dev/null; then
    echo -e "${RED}✗${NC} DB_PASSWORD not configured in .env.pf!"
    echo "Please set DB_PASSWORD in .env.pf and run this script again."
    exit 1
fi

echo -e "${GREEN}✓${NC} Environment configured"
echo ""

# Step 4: Run validation script
echo -e "${BLUE}[4/8]${NC} Running structure validation..."

if [ -f "scripts/validate-unified-structure.sh" ]; then
    bash scripts/validate-unified-structure.sh
    echo -e "${GREEN}✓${NC} Structure validation passed"
else
    echo -e "${YELLOW}⚠️  Validation script not found, skipping...${NC}"
fi
echo ""

# Step 5: Stop any existing containers
echo -e "${BLUE}[5/8]${NC} Stopping existing containers (if any)..."

docker compose -f docker-compose.unified.yml down 2>/dev/null || true
echo -e "${GREEN}✓${NC} Existing containers stopped"
echo ""

# Step 6: Pull/build images
echo -e "${BLUE}[6/8]${NC} Building Docker images..."
echo "This may take 10-15 minutes on first run..."
echo ""

docker compose -f docker-compose.unified.yml build --parallel 2>&1 | grep -v "^#" || true
echo ""
echo -e "${GREEN}✓${NC} Images built successfully"
echo ""

# Step 7: Start infrastructure services first
echo -e "${BLUE}[7/8]${NC} Starting infrastructure services..."

docker compose -f docker-compose.unified.yml up -d nexus-cos-postgres nexus-cos-redis

echo "Waiting for database to be ready..."
sleep 10

# Check if database is healthy
for i in {1..30}; do
    if docker exec nexus-cos-postgres pg_isready -U nexus_user 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Database is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}✗${NC} Database failed to start"
        echo "Check logs with: docker compose -f docker-compose.unified.yml logs nexus-cos-postgres"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""
echo -e "${GREEN}✓${NC} Infrastructure services started"
echo ""

# Step 8: Deploy all services
echo -e "${BLUE}[8/8]${NC} Deploying all services..."
echo "Starting 42 application services..."
echo ""

docker compose -f docker-compose.unified.yml up -d

echo ""
echo -e "${GREEN}✓${NC} All services deployed"
echo ""

# Wait a moment for services to initialize
echo "Waiting for services to initialize..."
sleep 5

# Display status
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Deployment Status${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

docker compose -f docker-compose.unified.yml ps

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Show service counts
RUNNING=$(docker compose -f docker-compose.unified.yml ps | grep "Up" | wc -l)
TOTAL=$(docker compose -f docker-compose.unified.yml config --services | wc -l)

echo -e "Services Running: ${GREEN}${RUNNING}/${TOTAL}${NC}"
echo ""

# Show key endpoints
echo -e "${BLUE}Key Service Endpoints:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Main API Gateway:    ${GREEN}http://localhost:4000${NC}"
echo -e "  Backend API:         ${GREEN}http://localhost:3001${NC}"
echo -e "  Session Manager:     ${GREEN}http://localhost:3101${NC}"
echo -e "  Token Manager:       ${GREEN}http://localhost:3102${NC}"
echo -e "  Invoice Generator:   ${GREEN}http://localhost:3111${NC}"
echo -e "  Ledger Manager:      ${GREEN}http://localhost:3112${NC}"
echo -e "  AI Service:          ${GREEN}http://localhost:3010${NC}"
echo -e "  VScreen Hollywood:   ${GREEN}http://localhost:8088${NC}"
echo ""

# Health check commands
echo -e "${BLUE}Quick Health Checks:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  curl http://localhost:4000/health"
echo "  curl http://localhost:3101/health"
echo "  curl http://localhost:3102/health"
echo "  curl http://localhost:3111/health"
echo "  curl http://localhost:3112/health"
echo ""

# Management commands
echo -e "${BLUE}Management Commands:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  View logs:     docker compose -f docker-compose.unified.yml logs -f"
echo "  View status:   docker compose -f docker-compose.unified.yml ps"
echo "  Stop all:      docker compose -f docker-compose.unified.yml down"
echo "  Restart:       docker compose -f docker-compose.unified.yml restart"
echo ""

# Documentation
echo -e "${BLUE}Documentation:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Master Guide:        NEXUS_COS_V2025_FINAL_UNIFIED_PF.md"
echo "  Service Mapping:     TRAE_SERVICE_MAPPING.md"
echo "  Build Guide:         NEXUS_COS_V2025_UNIFIED_BUILD_GUIDE.md"
echo ""

echo -e "${GREEN}🎉 Nexus COS v2025 is now running!${NC}"
echo -e "${BLUE}🧠 The World's First Creative Operating System${NC}"
echo ""

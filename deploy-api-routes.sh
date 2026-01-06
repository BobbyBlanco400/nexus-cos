#!/bin/bash
# Quick deployment script for API routes update
# Run this on the VPS to deploy the API routes changes

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Nexus COS API Routes Update${NC}"
echo "============================================"
echo ""

# Step 1: Pull changes
echo -e "${YELLOW}Step 1: Pulling latest changes...${NC}"
cd /opt/nexus-cos
git pull origin main
echo -e "${GREEN}✓ Changes pulled${NC}"
echo ""

# Step 2: Restart PM2
echo -e "${YELLOW}Step 2: Restarting PM2...${NC}"
pm2 restart nexuscos-app
sleep 3
echo -e "${GREEN}✓ PM2 restarted${NC}"
echo ""

# Step 3: Verify deployment
echo -e "${YELLOW}Step 3: Verifying deployment...${NC}"
echo ""

# Test health endpoint
echo -n "Testing /health... "
if curl -sf https://n3xuscos.online/health > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "❌ Failed"
fi

# Test /api endpoint
echo -n "Testing /api... "
if curl -sf https://n3xuscos.online/api > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "❌ Failed"
fi

# Test /api/auth endpoint
echo -n "Testing /api/auth... "
if curl -sf https://n3xuscos.online/api/auth > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "❌ Failed"
fi

# Test /api/system/status endpoint
echo -n "Testing /api/system/status... "
if curl -sf https://n3xuscos.online/api/system/status > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "❌ Failed"
fi

# Test module endpoints
echo -n "Testing /api/creator-hub/status... "
if curl -sf https://n3xuscos.online/api/creator-hub/status > /dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "❌ Failed"
fi

echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
echo "All API routes are now accessible at:"
echo "  - https://n3xuscos.online/api"
echo "  - https://n3xuscos.online/api/auth"
echo "  - https://n3xuscos.online/api/system/status"
echo "  - https://n3xuscos.online/api/services/:service/health"
echo "  - https://n3xuscos.online/api/creator-hub/status"
echo "  - https://n3xuscos.online/api/v-suite/status"
echo "  - https://n3xuscos.online/api/puaboverse/status"
echo ""
echo "Run './test-api-routes.sh https://n3xuscos.online' for detailed testing."

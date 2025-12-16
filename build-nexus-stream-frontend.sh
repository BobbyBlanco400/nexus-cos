#!/bin/bash

# Nexus Stream React Frontend Build Script
# This script builds all components in the correct order

set -e  # Exit on any error

echo "=================================================="
echo "Nexus Stream React Frontend Build"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directory - auto-detect based on script location or environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the repo
if [ -d "$SCRIPT_DIR/PixelStreamingInfrastructure/Frontend" ]; then
    BASE_DIR="$SCRIPT_DIR/PixelStreamingInfrastructure/Frontend"
    echo -e "${YELLOW}Using repository path: $BASE_DIR${NC}"
# Check if running on server (different base path)
elif [ -d "/opt/PixelStreamingInfrastructure/Frontend" ]; then
    BASE_DIR="/opt/PixelStreamingInfrastructure/Frontend"
    echo -e "${YELLOW}Using server path: $BASE_DIR${NC}"
# Fallback to nexus-cos installation
elif [ -d "/opt/nexus-cos/PixelStreamingInfrastructure/Frontend" ]; then
    BASE_DIR="/opt/nexus-cos/PixelStreamingInfrastructure/Frontend"
    echo -e "${YELLOW}Using nexus-cos installation path: $BASE_DIR${NC}"
else
    echo -e "${RED}Error: Could not find PixelStreamingInfrastructure/Frontend directory${NC}"
    exit 1
fi

echo ""

# Step 1: Build UI Library
echo -e "${YELLOW}Step 1/3: Building UI Library...${NC}"
cd "$BASE_DIR/ui-library"
if [ ! -d "node_modules" ]; then
    echo "Installing UI library dependencies..."
    npm install
fi
echo "Building UI library..."
npm run build
echo -e "${GREEN}✓ UI Library built successfully${NC}"
echo ""

# Step 2: Verify StatsPanel TypeScript fix
echo -e "${YELLOW}Step 2/3: Verifying StatsPanel TypeScript fix...${NC}"
if grep -q "(this.aggregatedStats as any).getActiveCandidatePair()" "$BASE_DIR/ui-library/src/StatsPanel.ts"; then
    echo -e "${GREEN}✓ StatsPanel.ts TypeScript fix verified${NC}"
else
    echo -e "${RED}✗ StatsPanel.ts fix not found${NC}"
    exit 1
fi
echo ""

# Step 3: Build React Frontend
echo -e "${YELLOW}Step 3/3: Building React Frontend...${NC}"
cd "$BASE_DIR/implementations/react"
if [ ! -d "node_modules" ]; then
    echo "Installing React frontend dependencies..."
    npm install
fi
echo "Building React frontend..."
npm run build
echo -e "${GREEN}✓ React Frontend built successfully${NC}"
echo ""

echo "=================================================="
echo -e "${GREEN}All builds completed successfully!${NC}"
echo "=================================================="
echo ""
echo "Output locations:"
echo "  - UI Library: $BASE_DIR/ui-library/dist"
echo "  - React Frontend: $BASE_DIR/implementations/react/dist"
echo ""
echo -e "${GREEN}You can now deploy your Nexus Stream React frontend!${NC}"

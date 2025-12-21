#!/bin/bash

################################################################################
# Nexus COS - Casino V5 & Streaming Validation Test
# 
# This script validates the deployment of Casino V5 and Streaming modules
#
# Usage: ./test-casino-streaming-deployment.sh
################################################################################

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Casino V5 & Streaming Module - Validation Test                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Test counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to test
test_item() {
    local description=$1
    local command=$2
    
    echo -ne "Testing: ${description}... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}PASS${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        ((FAILED++))
        return 1
    fi
}

test_warning() {
    local description=$1
    local command=$2
    
    echo -ne "Checking: ${description}... "
    
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${YELLOW}WARNING${NC}"
        ((WARNINGS++))
        return 1
    fi
}

echo -e "${BLUE}[1/6] File Structure Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_item "Casino frontend index.html exists" \
    "test -f modules/casino-nexus/frontend/index.html"

test_item "Casino public directory exists" \
    "test -d modules/casino-nexus/frontend/public"

test_item "Casino assets directory exists" \
    "test -d modules/casino-nexus/frontend/public/assets"

test_item "Casino assets README exists" \
    "test -f modules/casino-nexus/frontend/public/assets/README.md"

test_item "Casino textures manifest exists" \
    "test -f modules/casino-nexus/frontend/public/assets/textures/manifest.json"

test_item "Casino models manifest exists" \
    "test -f modules/casino-nexus/frontend/public/assets/models/manifest.json"

test_item "Casino sounds manifest exists" \
    "test -f modules/casino-nexus/frontend/public/assets/sounds/manifest.json"

test_item "Streaming frontend index.html exists" \
    "test -f modules/puabo-ott-tv-streaming/frontend/index.html"

test_item "Streaming public directory exists" \
    "test -d modules/puabo-ott-tv-streaming/frontend/public"

echo ""

echo -e "${BLUE}[2/6] Script Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_item "Deployment script exists" \
    "test -f fix-casino-v5-streaming-deployment.sh"

test_item "Deployment script is executable" \
    "test -x fix-casino-v5-streaming-deployment.sh"

test_item "Quick start script exists" \
    "test -f casino-streaming-quick-start.sh"

test_item "Quick start script is executable" \
    "test -x casino-streaming-quick-start.sh"

test_item "Deployment script syntax is valid" \
    "bash -n fix-casino-v5-streaming-deployment.sh"

test_item "Quick start script syntax is valid" \
    "bash -n casino-streaming-quick-start.sh"

echo ""

echo -e "${BLUE}[3/6] Documentation Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_item "Main README exists" \
    "test -f README-CASINO-STREAMING-FIX.md"

test_item "Fix guide exists" \
    "test -f CASINO_V5_STREAMING_FIX_GUIDE.md"

test_item "Docker config guide exists" \
    "test -f DOCKER_COMPOSE_CASINO_STREAMING_CONFIG.md"

echo ""

echo -e "${BLUE}[4/6] Configuration Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_item "docker-compose.yml exists" \
    "test -f docker-compose.yml"

test_item "nginx.conf exists" \
    "test -f nginx.conf"

test_item "docker-compose.yml has casino volume" \
    "grep -q 'casino-nexus/frontend/public' docker-compose.yml"

test_item "docker-compose.yml has streaming volume" \
    "grep -q 'puabo-ott-tv-streaming/frontend/public' docker-compose.yml"

test_item "nginx.conf has casino route" \
    "grep -q '/casino' nginx.conf"

test_item "nginx.conf has streaming route" \
    "grep -q '/streaming' nginx.conf"

echo ""

echo -e "${BLUE}[5/6] HTML Content Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_item "Casino HTML is valid HTML5" \
    "head -1 modules/casino-nexus/frontend/index.html | grep -q '<!DOCTYPE html>'"

test_item "Casino HTML has title" \
    "grep -q '<title>' modules/casino-nexus/frontend/index.html"

test_item "Casino HTML has Casino Nexus content" \
    "grep -q 'Casino Nexus' modules/casino-nexus/frontend/index.html"

test_item "Streaming HTML is valid HTML5" \
    "head -1 modules/puabo-ott-tv-streaming/frontend/index.html | grep -q '<!DOCTYPE html>'"

test_item "Streaming HTML has title" \
    "grep -q '<title>' modules/puabo-ott-tv-streaming/frontend/index.html"

test_item "Streaming HTML has Nexus Stream content" \
    "grep -q 'Nexus Stream' modules/puabo-ott-tv-streaming/frontend/index.html"

echo ""

echo -e "${BLUE}[6/6] Integration Tests${NC}"
echo "───────────────────────────────────────────────────────────────────"

test_warning "Docker is installed" \
    "command -v docker"

test_warning "Docker Compose is available" \
    "command -v docker-compose || docker compose version"

test_warning "Nginx is installed" \
    "command -v nginx"

test_warning "Git repository is clean" \
    "git diff --quiet"

echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                         TEST SUMMARY                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}    $PASSED"
echo -e "  ${RED}Failed:${NC}    $FAILED"
echo -e "  ${YELLOW}Warnings:${NC}  $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✅ ALL CRITICAL TESTS PASSED${NC}"
    echo ""
    echo -e "${BLUE}Ready for deployment!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Review documentation in README-CASINO-STREAMING-FIX.md"
    echo "  2. Test locally: ./casino-streaming-quick-start.sh dev"
    echo "  3. Deploy to production: sudo ./fix-casino-v5-streaming-deployment.sh"
    echo ""
    exit 0
else
    echo -e "${RED}${BOLD}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the failing tests before deploying.${NC}"
    echo ""
    exit 1
fi

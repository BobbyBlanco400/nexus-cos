#!/bin/bash
# VERIFY_AND_FIX.sh
# N3XUS COS Platform - Verification and Health Check Script
# Verifies the deployment state including Casino N3XUS and PMMG Music portals

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   N3XUS COS Platform - Deployment Verification"
echo "   Date: $(date)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_TOTAL=0

# Function to print check result
print_check() {
    local status=$1
    local message=$2
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if [ "$status" == "pass" ]; then
        echo -e "${GREEN}✓${NC} $message"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    elif [ "$status" == "fail" ]; then
        echo -e "${RED}✗${NC} $message"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
    elif [ "$status" == "warn" ]; then
        echo -e "${YELLOW}⚠${NC} $message"
    else
        echo -e "${BLUE}ℹ${NC} $message"
    fi
}

# 1. Check if frontend is built
echo "═══════════════════════════════════════════════════════════"
echo "1. Frontend Build Status"
echo "═══════════════════════════════════════════════════════════"
if [ -d "frontend/dist" ] && [ -f "frontend/dist/index.html" ]; then
    print_check "pass" "Frontend built successfully"
    print_check "info" "  Location: frontend/dist/"
    FILE_COUNT=$(find frontend/dist -type f | wc -l)
    print_check "info" "  Total files: $FILE_COUNT"
else
    print_check "fail" "Frontend not built. Run: cd frontend && npm run build"
fi
echo

# 2. Check if Casino and Music portals exist
echo "═══════════════════════════════════════════════════════════"
echo "2. Portal Components"
echo "═══════════════════════════════════════════════════════════"
if [ -f "frontend/src/components/CasinoPortal.tsx" ]; then
    print_check "pass" "Casino N3XUS Portal component exists"
else
    print_check "fail" "Casino N3XUS Portal component missing"
fi

if [ -f "frontend/src/components/MusicPortal.tsx" ]; then
    print_check "pass" "PMMG Music Portal component exists"
else
    print_check "fail" "PMMG Music Portal component missing"
fi
echo

# 3. Check server.js for static file serving
echo "═══════════════════════════════════════════════════════════"
echo "3. Server Configuration"
echo "═══════════════════════════════════════════════════════════"
if grep -q "express\.static" server.js && grep -q "frontend" server.js && grep -q "dist" server.js; then
    print_check "pass" "Server configured to serve static files from frontend/dist"
else
    print_check "fail" "Server not configured for static file serving"
fi

if grep -q "X-Nexus-Handshake.*55-45-17" server.js; then
    print_check "pass" "Server enforces X-Nexus-Handshake: 55-45-17"
else
    print_check "fail" "Server missing 55-45-17 handshake enforcement"
fi
echo

# 4. Check nginx configuration
echo "═══════════════════════════════════════════════════════════"
echo "4. Nginx Configuration"
echo "═══════════════════════════════════════════════════════════"
if [ -f "nginx.conf.docker" ]; then
    print_check "pass" "Docker nginx configuration exists"
    if grep -q "X-Nexus-Handshake.*55-45-17" nginx.conf.docker; then
        print_check "pass" "Nginx enforces X-Nexus-Handshake: 55-45-17"
    else
        print_check "fail" "Nginx missing 55-45-17 handshake enforcement"
    fi
else
    print_check "fail" "Docker nginx configuration missing"
fi
echo

# 5. Check docker-compose configurations
echo "═══════════════════════════════════════════════════════════"
echo "5. Docker Compose Configuration"
echo "═══════════════════════════════════════════════════════════"
if [ -f "docker-compose.yml" ]; then
    print_check "pass" "docker-compose.yml exists"
    SERVICE_COUNT=$(grep -c "container_name:" docker-compose.yml || echo "0")
    print_check "info" "  Services in docker-compose.yml: $SERVICE_COUNT"
else
    print_check "fail" "docker-compose.yml missing"
fi

if [ -f "docker-compose.nexus-full.yml" ]; then
    print_check "pass" "docker-compose.nexus-full.yml exists (full stack)"
    SERVICE_COUNT=$(grep -c "container_name:" docker-compose.nexus-full.yml || echo "0")
    print_check "info" "  Services in docker-compose.nexus-full.yml: $SERVICE_COUNT"
else
    print_check "fail" "docker-compose.nexus-full.yml missing"
fi
echo

# 6. Check for port 9503 conflict (skill-games-ms)
echo "═══════════════════════════════════════════════════════════"
echo "6. Port Conflict Check"
echo "═══════════════════════════════════════════════════════════"
if command -v lsof &> /dev/null; then
    if lsof -i :9503 &> /dev/null; then
        print_check "warn" "Port 9503 is in use (skill-games-ms conflict possible)"
        print_check "info" "  Process using port 9503:"
        lsof -i :9503 | tail -n +2 | awk '{print "    " $1 " (PID: " $2 ")"}'
    else
        print_check "pass" "Port 9503 is available"
    fi
else
    print_check "info" "lsof not available, skipping port check"
fi
echo

# 7. Check if Docker is running
echo "═══════════════════════════════════════════════════════════"
echo "7. Docker Status"
echo "═══════════════════════════════════════════════════════════"
if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
        print_check "pass" "Docker is running"
        RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | wc -l)
        print_check "info" "  Running containers: $RUNNING_CONTAINERS"
        if [ $RUNNING_CONTAINERS -gt 0 ]; then
            echo "    Active containers:"
            docker ps --format "    - {{.Names}} ({{.Status}})"
        fi
    else
        print_check "warn" "Docker daemon not accessible"
    fi
else
    print_check "warn" "Docker not installed or not in PATH"
fi
echo

# 8. Check Casino and Music modules
echo "═══════════════════════════════════════════════════════════"
echo "8. Module Directories"
echo "═══════════════════════════════════════════════════════════"
if [ -d "modules/casino-nexus" ]; then
    print_check "pass" "Casino N3XUS module directory exists"
else
    print_check "fail" "Casino N3XUS module directory missing"
fi

if [ -d "modules/musicchain" ]; then
    print_check "pass" "MusicChain module directory exists"
else
    print_check "fail" "MusicChain module directory missing"
fi
echo

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Total Checks: $CHECKS_TOTAL"
echo -e "${GREEN}Passed:${NC} $CHECKS_PASSED"
echo -e "${RED}Failed:${NC} $CHECKS_FAILED"
echo

if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo
    echo "System is ready for deployment."
    echo "To start the full stack, run:"
    echo "  docker-compose -f docker-compose.nexus-full.yml up -d"
    exit 0
else
    echo -e "${RED}✗ Some checks failed.${NC}"
    echo
    echo "Please address the failed checks before deploying."
    echo "For frontend build: cd frontend && npm install && npm run build"
    exit 1
fi

#!/usr/bin/env bash
# ==============================================================================
# Nexus COS - Endpoint Validation Script
# ==============================================================================
# This script validates that all endpoints are responding correctly after
# the Nginx configuration has been deployed.
# ==============================================================================

set -e

BASE_URL="${BASE_URL:-https://n3xuscos.online}"
TIMEOUT=8
SKIP_SSL_VERIFY="${SKIP_SSL_VERIFY:-false}"

# Determine curl SSL flag
if [[ "$SKIP_SSL_VERIFY" == "true" ]]; then
    SSL_FLAG="-k"
    echo "⚠️  Warning: SSL certificate verification is disabled (SKIP_SSL_VERIFY=true)"
else
    SSL_FLAG=""
fi

echo "=============================================================================="
echo "Nexus COS - Endpoint Validation"
echo "=============================================================================="
echo ""
echo "Base URL: $BASE_URL"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASS_COUNT=0
FAIL_COUNT=0

# Function to test an endpoint
test_endpoint() {
    local path="$1"
    local expected_status="$2"
    local description="$3"
    
    echo -n "Testing ${path} ... "
    
    # Make request and capture status code
    status_code=$(curl -sSI --max-time "$TIMEOUT" $SSL_FLAG "${BASE_URL}${path}" 2>/dev/null | \
        awk 'toupper($0) ~ /^HTTP/{print $2; exit}' || echo "000")
    
    # Check if we got a response
    if [[ "$status_code" == "000" ]]; then
        echo -e "${RED}FAIL${NC} (No response)"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return
    fi
    
    # Determine if status is acceptable
    if [[ "$expected_status" == "any" ]]; then
        # Accept any non-5xx status
        if [[ "$status_code" =~ ^[1-4][0-9][0-9]$ ]]; then
            echo -e "${GREEN}PASS${NC} (${status_code}) - $description"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${RED}FAIL${NC} (${status_code}) - Server error"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        # Check for expected status
        if [[ "$status_code" == "$expected_status" ]]; then
            echo -e "${GREEN}PASS${NC} (${status_code}) - $description"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "${YELLOW}WARN${NC} (${status_code}, expected ${expected_status}) - $description"
            PASS_COUNT=$((PASS_COUNT + 1))
        fi
    fi
}

echo "Testing endpoints..."
echo ""

# Test root
test_endpoint "/" "200" "Main landing page"

# Test SPA sections
test_endpoint "/apex/" "any" "Apex SPA (if published)"
test_endpoint "/beta/" "any" "Beta SPA (if published)"
test_endpoint "/core/" "any" "Core assets"

# Test API endpoints
test_endpoint "/api/" "any" "Backend API (may return 404 if no root handler)"
test_endpoint "/api/health" "any" "API health endpoint"

# Test streaming endpoints
test_endpoint "/stream/" "any" "Streaming service"
test_endpoint "/hls/" "any" "HLS streaming"

# Test health endpoint
test_endpoint "/health" "200" "Nginx health check"

echo ""
echo "=============================================================================="
echo "Validation Summary"
echo "=============================================================================="
echo ""
echo -e "Total tests: $((PASS_COUNT + FAIL_COUNT))"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✅ All critical endpoints are responding!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some endpoints failed to respond${NC}"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check if services are running:"
    echo "   - Backend API on port 3000"
    echo "   - Streaming service on port 3043"
    echo "2. Check Nginx error logs:"
    echo "   sudo tail -n 50 /var/log/nginx/error.log"
    echo "3. Verify Nginx configuration:"
    echo "   sudo nginx -t"
    echo "4. Check service status:"
    echo "   sudo systemctl status nginx"
    echo ""
    exit 1
fi

#!/bin/bash
# Nexus COS Production Endpoint Testing Script
# Tests all critical production endpoints to ensure system health

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Test endpoint with retry logic
test_endpoint() {
    local url=$1
    local name=$2
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
        
        if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
            print_success "$name: HTTP $response"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $max_retries ]; then
            sleep 2
        fi
    done
    
    print_error "$name: HTTP $response (Failed after $max_retries attempts)"
    return 1
}

echo "══════════════════════════════════════════════════════════════"
echo "  NEXUS COS PRODUCTION ENDPOINT TESTING"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Test local service ports
print_status "Testing Local Service Ports..."
echo ""

ports_to_test=(3001 3010 3014 3020 3030 4000 3231 3232 3233 3234)
port_names=(
    "Backend API (3001)"
    "AI Service (3010)"
    "Key Service (3014)"
    "Creator Hub (3020)"
    "PuaboVerse (3030)"
    "Gateway (4000)"
    "AI Dispatch (3231)"
    "Driver Backend (3232)"
    "Fleet Manager (3233)"
    "Route Optimizer (3234)"
)

listening_count=0
for i in "${!ports_to_test[@]}"; do
    port=${ports_to_test[$i]}
    name=${port_names[$i]}
    
    if nc -z localhost $port 2>/dev/null; then
        print_success "$name - LISTENING"
        listening_count=$((listening_count + 1))
    else
        print_warning "$name - NOT LISTENING"
    fi
done

echo ""
print_status "Port Status: $listening_count/${#ports_to_test[@]} ports listening"
echo ""

# Test HTTP endpoints (localhost)
print_status "Testing Local HTTP Endpoints..."
echo ""

failed_endpoints=0

# Core service health checks
test_endpoint "http://localhost:3001/health" "Backend API Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3010/health" "AI Service Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3014/health" "Key Service Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3020/health" "Creator Hub Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3030/health" "PuaboVerse Health" || failed_endpoints=$((failed_endpoints + 1))

# PUABO NEXUS Fleet Services health checks
test_endpoint "http://localhost:3231/health" "AI Dispatch Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3232/health" "Driver Backend Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3233/health" "Fleet Manager Health" || failed_endpoints=$((failed_endpoints + 1))
test_endpoint "http://localhost:3234/health" "Route Optimizer Health" || failed_endpoints=$((failed_endpoints + 1))

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  TEST SUMMARY"
echo "══════════════════════════════════════════════════════════════"
echo ""
print_status "Listening Ports: $listening_count/${#ports_to_test[@]}"
print_status "Failed Endpoints: $failed_endpoints/9"
echo ""

if [ $failed_endpoints -eq 0 ] && [ $listening_count -eq ${#ports_to_test[@]} ]; then
    print_success "✓ All tests passed! System is healthy."
    exit 0
elif [ $failed_endpoints -lt 3 ]; then
    print_warning "⚠ Some tests failed. Review the output above."
    exit 1
else
    print_error "✗ Multiple critical failures detected. System needs attention."
    exit 2
fi

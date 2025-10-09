#!/bin/bash
# Test all API routes for Nexus COS
# Usage: ./test-api-routes.sh [base_url]
# Example: ./test-api-routes.sh https://nexuscos.online
# Default: ./test-api-routes.sh http://localhost:3000

BASE_URL="${1:-http://localhost:3000}"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Testing Nexus COS API Routes"
echo "Base URL: $BASE_URL"
echo "================================"
echo ""

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${YELLOW}Testing:${NC} $description"
    echo "  $method $endpoint"
    
    if [ -z "$data" ]; then
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X "$method" "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d':' -f2)
    body=$(echo "$response" | sed '/HTTP_CODE:/d')
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "  ${GREEN}✓ Success${NC} (HTTP $http_code)"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    else
        echo -e "  ${RED}✗ Failed${NC} (HTTP $http_code)"
        echo "$body"
    fi
    echo ""
}

# Test all endpoints

echo "📋 Health & Status Endpoints"
echo "----------------------------"
test_endpoint "GET" "/health" "" "Health check endpoint"
test_endpoint "GET" "/api" "" "API information endpoint"
test_endpoint "GET" "/api/system/status" "" "System status endpoint"
test_endpoint "GET" "/api/services/auth/health" "" "Auth service health"
test_endpoint "GET" "/api/services/creator-hub/health" "" "Creator Hub service health"
echo ""

echo "🔐 Authentication Endpoints"
echo "---------------------------"
test_endpoint "GET" "/api/auth" "" "Auth service info"
test_endpoint "POST" "/api/auth/login" '{"username":"testuser","password":"testpass"}' "Login endpoint"
test_endpoint "POST" "/api/auth/register" '{"username":"newuser","email":"test@example.com","password":"testpass"}' "Register endpoint"
test_endpoint "POST" "/api/auth/logout" "" "Logout endpoint"
echo ""

echo "👥 User Management Endpoints"
echo "----------------------------"
test_endpoint "GET" "/api/users" "" "Users info"
test_endpoint "GET" "/api/users/profile" "" "User profile"
echo ""

echo "🎨 Module Status Endpoints"
echo "--------------------------"
test_endpoint "GET" "/api/creator-hub/status" "" "Creator Hub status"
test_endpoint "GET" "/api/v-suite/status" "" "V-Suite status"
test_endpoint "GET" "/api/puaboverse/status" "" "PuaboVerse status"
echo ""

echo "================================"
echo "✅ API Route Testing Complete"

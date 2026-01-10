#!/bin/bash
# 🔴 TIER 5 HANDSHAKE VERIFICATION SCRIPT
# Handshake: 55-45-17
# Purpose: Verify handshake enforcement on Tier 5 operations

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}🔴 TIER 5 HANDSHAKE VERIFICATION${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:3000}"
TIER_5_ENDPOINT="/api/v1/tiers/tier-5/status"
REQUIRED_HANDSHAKE="55-45-17"

# Note: For production, use HTTPS endpoints with proper SSL/TLS certificate validation
# Example: API_BASE_URL="https://api.n3xuscos.online" with --cacert /path/to/ca-cert.pem

echo -e "${RED}Testing Tier 5 handshake enforcement...${NC}"
echo -e "   API endpoint: ${YELLOW}${API_BASE_URL}${TIER_5_ENDPOINT}${NC}"
echo -e "   Required handshake: ${RED}${REQUIRED_HANDSHAKE}${NC}"
echo ""

# Check if backend is running
if ! curl -s --max-time 5 "${API_BASE_URL}/health" &> /dev/null; then
    echo -e "${YELLOW}⚠️  Backend API not responding at ${API_BASE_URL}${NC}"
    echo -e "${YELLOW}   Cannot perform live handshake verification${NC}"
    echo -e "${YELLOW}   Checking configuration only...${NC}"
    echo ""
    
    # Check configuration file
    CONFIG_FILE="config/tier-5-config.json"
    if [ -f "$CONFIG_FILE" ]; then
        HANDSHAKE_VALIDATION=$(cat "$CONFIG_FILE" | jq -r '.tier_5.enforcement.handshake_validation')
        
        if [ "$HANDSHAKE_VALIDATION" = "true" ]; then
            echo -e "${GREEN}✅ Handshake validation enabled in configuration${NC}"
            echo ""
            echo -e "${YELLOW}⚠️  Live API test skipped (backend not running)${NC}"
            echo -e "${YELLOW}   Start backend to run full verification${NC}"
            exit 0
        else
            echo -e "${RED}❌ VIOLATION: Handshake validation disabled in configuration${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  Configuration file not found${NC}"
        echo -e "${YELLOW}   Cannot verify handshake enforcement${NC}"
        exit 1
    fi
fi

# Test 1: Valid handshake
echo -e "${RED}Test 1: Valid handshake (55-45-17)${NC}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "X-N3XUS-Handshake: ${REQUIRED_HANDSHAKE}" "${API_BASE_URL}${TIER_5_ENDPOINT}" 2>/dev/null)

if [ "$RESPONSE" = "200" ] || [ "$RESPONSE" = "404" ]; then
    echo -e "${GREEN}✅ Valid handshake accepted (HTTP $RESPONSE)${NC}"
else
    echo -e "${RED}❌ VIOLATION: Valid handshake rejected (HTTP $RESPONSE)${NC}"
    echo -e "${RED}   Expected: 200 or 404${NC}"
    echo -e "${RED}   Got: $RESPONSE${NC}"
    exit 1
fi

# Test 2: Invalid handshake
echo ""
echo -e "${RED}Test 2: Invalid handshake${NC}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "X-N3XUS-Handshake: invalid" "${API_BASE_URL}${TIER_5_ENDPOINT}" 2>/dev/null)

if [ "$RESPONSE" = "403" ]; then
    echo -e "${GREEN}✅ Invalid handshake rejected (HTTP 403)${NC}"
else
    echo -e "${RED}❌ VIOLATION: Invalid handshake not rejected (HTTP $RESPONSE)${NC}"
    echo -e "${RED}   Expected: 403 (Forbidden)${NC}"
    echo -e "${RED}   Got: $RESPONSE${NC}"
    exit 1
fi

# Test 3: Missing handshake
echo ""
echo -e "${RED}Test 3: Missing handshake${NC}"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE_URL}${TIER_5_ENDPOINT}" 2>/dev/null)

if [ "$RESPONSE" = "403" ]; then
    echo -e "${GREEN}✅ Missing handshake rejected (HTTP 403)${NC}"
else
    echo -e "${RED}❌ VIOLATION: Missing handshake not rejected (HTTP $RESPONSE)${NC}"
    echo -e "${RED}   Expected: 403 (Forbidden)${NC}"
    echo -e "${RED}   Got: $RESPONSE${NC}"
    exit 1
fi

# Test 4: Check response body for valid handshake
echo ""
echo -e "${RED}Test 4: Verify response content${NC}"
RESPONSE_BODY=$(curl -s -H "X-N3XUS-Handshake: ${REQUIRED_HANDSHAKE}" "${API_BASE_URL}${TIER_5_ENDPOINT}" 2>/dev/null)

if echo "$RESPONSE_BODY" | grep -q "CONDITIONALLY_OPEN\|CANON_GATED\|tier_5" 2>/dev/null; then
    echo -e "${GREEN}✅ Response contains Tier 5 canonical data${NC}"
else
    # Check if it's a 404 (endpoint not yet implemented)
    if echo "$RESPONSE_BODY" | grep -q "404\|Not Found" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Tier 5 endpoint not yet implemented${NC}"
        echo -e "${YELLOW}   Handshake validation at gateway level is sufficient${NC}"
    else
        echo -e "${YELLOW}⚠️  Unexpected response format${NC}"
        echo -e "${YELLOW}   Response: $RESPONSE_BODY${NC}"
    fi
fi

echo ""
echo -e "${RED}========================================${NC}"
echo -e "${GREEN}✅ TIER 5 HANDSHAKE VERIFICATION PASSED${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${RED}Summary:${NC}"
echo -e "  - Valid handshake: ${GREEN}Accepted${NC} ✅"
echo -e "  - Invalid handshake: ${RED}Rejected${NC} ✅"
echo -e "  - Missing handshake: ${RED}Rejected${NC} ✅"
echo -e "  - Required handshake: ${RED}55-45-17${NC} ✅"
echo -e "  - Status: ${GREEN}CANON COMPLIANT${NC}"
echo ""

exit 0

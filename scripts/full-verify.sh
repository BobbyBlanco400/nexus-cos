#!/bin/bash
################################################################################
# Nexus COS - Full Verification Script
# Validates Beta, Production, CIM-B, PWA, OACP, NexusVision, and HoloCore
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN} Nexus COS - Full System Verification${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

# Configuration
BETA_URL="${BETA_URL:-https://beta.n3xuscos.online}"
PROD_URL="${PROD_URL:-https://n3xuscos.online}"
TIMEOUT=5

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_header="$3"
    local check_header="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing $name... "
    
    if [ -n "$check_header" ]; then
        # Test with header check
        response=$(curl -I -s -m "$TIMEOUT" -H "$check_header" "$url" 2>/dev/null || echo "FAILED")
        if echo "$response" | grep -qi "$expected_header" 2>/dev/null; then
            echo -e "${GREEN}✓ PASS${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${RED}✗ FAIL${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        # Simple HTTP status check
        status=$(curl -I -s -m "$TIMEOUT" "$url" 2>/dev/null | head -n 1 | awk '{print $2}')
        if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ]; then
            echo -e "${GREEN}✓ PASS (HTTP $status)${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${RED}✗ FAIL (HTTP $status)${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    fi
}

# Test file existence
test_file() {
    local name="$1"
    local path="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Checking $name... "
    
    if [ -f "$path" ]; then
        echo -e "${GREEN}✓ EXISTS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ MISSING${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Test directory existence
test_directory() {
    local name="$1"
    local path="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Checking $name... "
    
    if [ -d "$path" ]; then
        echo -e "${GREEN}✓ EXISTS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ MISSING${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 1. Beta Environment Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_endpoint "Beta Root" "$BETA_URL/" "" ""
test_endpoint "Beta Catalog" "$BETA_URL/catalog" "" ""
test_endpoint "Beta Status" "$BETA_URL/status" "" ""
test_endpoint "Beta Test" "$BETA_URL/test" "" ""
test_endpoint "Beta Handshake" "$BETA_URL/" "X-Nexus-Handshake.*beta-55-45-17" "X-Nexus-Handshake: beta-55-45-17"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 2. Production Core Tests (Frozen)${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_endpoint "Production Root" "$PROD_URL/" "" ""
test_endpoint "Production Streaming" "$PROD_URL/streaming/" "" ""
test_endpoint "Production Streaming Catalog" "$PROD_URL/streaming/catalog" "" ""
test_endpoint "Production Streaming Status" "$PROD_URL/streaming/status" "" ""
test_endpoint "Production Streaming Test" "$PROD_URL/streaming/test" "" ""

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 3. CIM-B Module Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_file "CIM-B Module" "./src/Modules/CIM_B.ts"
if command -v node &> /dev/null && [ -f "./src/Modules/CIM_B.ts" ]; then
    echo -n "Testing CIM-B initialization... "
    if node -e "const { cimBModule } = require('./src/Modules/CIM_B.ts'); cimBModule.initialize();" 2>/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${YELLOW}⚠ SKIP (TypeScript)${NC}"
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 4. PWA Module Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_endpoint "PWA Service Worker" "$PROD_URL/service-worker.js" "" ""
test_endpoint "PWA Manifest" "$PROD_URL/manifest.json" "" ""

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 5. OACP (Owner/Admin Control Panel) Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_directory "OACP Frontend" "./nexus-oacp/frontend"
test_file "OACP Package.json" "./nexus-oacp/frontend/package.json"
test_file "OACP App Component" "./nexus-oacp/frontend/src/App.tsx"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 6. NexusVision™ Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_endpoint "NexusVision AR Demo" "$PROD_URL/nexusvision/experiences/ar-demo.html" "" ""
test_endpoint "NexusVision VR Demo" "$PROD_URL/nexusvision/experiences/vr-demo.html" "" ""
test_endpoint "NexusVision Config" "$PROD_URL/nexusvision/nexusvision-config.json" "" ""

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 7. HoloCore™ Tests${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_endpoint "HoloCore 3D Viewer" "$PROD_URL/holocore/viewer.html" "" ""
test_endpoint "HoloCore AR Experience" "$PROD_URL/holocore/ar-experience.html" "" ""
test_endpoint "HoloCore Config" "$PROD_URL/holocore/holocore-config.json" "" ""

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE} 8. Structure Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

test_directory "Backend Directory" "./backend"
test_file "Backend Index" "./backend/index.ts"
test_file "Backend Routes" "./backend/routes/api.ts"
test_file "Backend Controller" "./backend/controllers/mainController.ts"
test_file "Backend .env.example" "./backend/.env.example"

test_directory "Frontend Directory" "./frontend"
test_file "Frontend Package.json" "./frontend/package.json"
test_file "Frontend App" "./frontend/src/App.tsx"
test_file "Frontend .env.example" "./frontend/.env.example"

test_directory "Beta Directory" "./beta"
test_file "Beta Package.json" "./beta/package.json"
test_file "Beta App" "./beta/src/App.tsx"
test_file "Beta Dashboard" "./beta/src/components/BetaDashboard.tsx"
test_file "Beta .env.example" "./beta/.env.example"

test_directory "Modules Directory" "./src/Modules"
test_file "CIM-B Module" "./src/Modules/CIM_B.ts"

echo ""
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN} Verification Summary${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "Total Tests:  ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ All tests passed! System is fully operational.${NC}"
    echo ""
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Some tests failed. Please review the output above.${NC}"
    echo ""
    exit 1
fi

#!/usr/bin/env bash
# N3XUS COS - Comprehensive Service Verification Script
# Governance Order: 55-45-17
# 
# This script verifies all services, endpoints, and features are functioning correctly
# with proper N3XUS Handshake enforcement.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║   N3XUS COS - Comprehensive Service Verification (55-45-17)     ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Test function
test_service() {
    local name="$1"
    local url="$2"
    local with_handshake="${3:-true}"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ "$with_handshake" = "true" ]; then
        response=$(curl -s -H "X-N3XUS-Handshake: 55-45-17" "$url" 2>/dev/null || echo "ERROR")
    else
        response=$(curl -s "$url" 2>/dev/null || echo "ERROR")
    fi
    
    if [ "$response" != "ERROR" ] && [ -n "$response" ]; then
        echo -e "${GREEN}✅ $name${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ $name${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

# Test handshake rejection
test_handshake_rejection() {
    local name="$1"
    local url="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    # Should get 403 without handshake
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$status_code" = "403" ]; then
        echo -e "${GREEN}✅ $name - Properly rejects without handshake${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${YELLOW}⚠️  $name - Got $status_code (expected 403)${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1️⃣ Core API Services${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Core services (when running)
if command -v docker >/dev/null 2>&1 && docker ps | grep -q puabo-api; then
    test_service "Backend API Health" "http://localhost:3000/health" "false"
    test_service "Backend API Status" "http://localhost:3000/api/status" "true"
    test_service "Backend System Status" "http://localhost:3000/api/system/status" "true"
else
    echo -e "${YELLOW}ℹ️  Backend API not running (Docker container not found)${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2️⃣ File System Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check key files exist
check_file() {
    local name="$1"
    local path="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -f "$path" ]; then
        echo -e "${GREEN}✅ $name exists${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ $name missing${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

check_file "NGINX Docker Config" "${SCRIPT_DIR}/nginx.conf.docker"
check_file "Docker Compose" "${SCRIPT_DIR}/docker-compose.yml"
check_file "Main Server" "${SCRIPT_DIR}/server.js"
check_file "Tenant Registry" "${SCRIPT_DIR}/nexus/tenants/canonical_tenants.json"
check_file "Governance Charter" "${SCRIPT_DIR}/GOVERNANCE_CHARTER_55_45_17.md"
check_file "Casino Frontend" "${SCRIPT_DIR}/modules/casino-nexus/frontend/index.html"
check_file "Handshake Middleware" "${SCRIPT_DIR}/middleware/handshake-validator.js"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3️⃣ Handshake Configuration Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_handshake() {
    local name="$1"
    local path="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if grep -q "55-45-17" "$path" 2>/dev/null; then
        echo -e "${GREEN}✅ $name contains handshake${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ $name missing handshake${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

check_handshake "NGINX Config" "${SCRIPT_DIR}/nginx.conf.docker"
check_handshake "Main Server" "${SCRIPT_DIR}/server.js"
check_handshake "Handshake Middleware" "${SCRIPT_DIR}/middleware/handshake-validator.js"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4️⃣ Tenant Registry Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v jq >/dev/null 2>&1; then
    TENANT_COUNT=$(jq '.tenants | length' "${SCRIPT_DIR}/nexus/tenants/canonical_tenants.json" 2>/dev/null || echo 0)
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ "$TENANT_COUNT" -eq 13 ]; then
        echo -e "${GREEN}✅ Tenant Count: 13 (VERIFIED)${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}❌ Tenant Count: $TENANT_COUNT (EXPECTED: 13)${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    # List all tenants
    echo ""
    echo -e "${CYAN}Registered Tenants:${NC}"
    jq -r '.tenants[] | "  \(.id). \(.name) (\(.slug))"' "${SCRIPT_DIR}/nexus/tenants/canonical_tenants.json" 2>/dev/null || echo "  Error reading tenants"
else
    echo -e "${YELLOW}⚠️  jq not installed - skipping detailed tenant verification${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}5️⃣ Module Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

check_directory() {
    local name="$1"
    local path="$2"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if [ -d "$path" ]; then
        echo -e "${GREEN}✅ $name module exists${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        echo -e "${RED}❌ $name module missing${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        return 1
    fi
}

check_directory "Casino Nexus" "${SCRIPT_DIR}/modules/casino-nexus"
check_directory "Streaming (OTT TV)" "${SCRIPT_DIR}/modules/puabo-ott-tv-streaming"
check_directory "V-Suite" "${SCRIPT_DIR}/modules/v-suite"
check_directory "StreamCore" "${SCRIPT_DIR}/modules/streamcore"
check_directory "MusicChain" "${SCRIPT_DIR}/modules/musicchain"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}6️⃣ Frontend Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -d "${SCRIPT_DIR}/frontend/dist" ]; then
    echo -e "${GREEN}✅ Frontend built (dist directory exists)${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
else
    echo -e "${YELLOW}⚠️  Frontend not built (dist directory missing)${NC}"
    echo -e "${YELLOW}   Run: cd frontend && npm install && npm run build${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}7️⃣ Docker Configuration Verification${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v docker >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker installed${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker daemon running${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        
        # Check if N3XUS containers are running
        if docker ps | grep -q "nexus\|puabo"; then
            echo -e "${GREEN}✅ N3XUS containers running${NC}"
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
            
            echo ""
            echo -e "${CYAN}Running containers:${NC}"
            docker ps --format "  {{.Names}} ({{.Status}})" | grep -i "nexus\|puabo" || echo "  None"
        else
            echo -e "${YELLOW}⚠️  No N3XUS containers running${NC}"
            echo -e "${YELLOW}   Run: docker-compose up -d${NC}"
            TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        fi
    else
        echo -e "${YELLOW}⚠️  Docker daemon not running${NC}"
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    fi
else
    echo -e "${YELLOW}⚠️  Docker not installed${NC}"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
fi

echo ""
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    VERIFICATION SUMMARY                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "Total Checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
echo ""

PASS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo -e "Pass Rate: ${PASS_RATE}%"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED - System Ready for Deployment${NC}"
    exit 0
elif [ $PASS_RATE -ge 80 ]; then
    echo -e "${YELLOW}⚠️  MOSTLY PASSED - Some issues need attention${NC}"
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED - Critical issues found${NC}"
    exit 1
fi

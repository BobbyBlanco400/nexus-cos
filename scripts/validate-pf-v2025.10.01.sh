#!/bin/bash

# ==============================================================================
# Nexus COS - PF v2025.10.01 Validation Script
# ==============================================================================
# Purpose: Validate PF v2025.10.01 configuration and deployment readiness
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║         NEXUS COS - PF v2025.10.01 VALIDATION                  ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_check() {
    echo -e "${CYAN}▶${NC} $1"
}

print_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((FAILED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}  ⚠${NC} $1"
    ((WARNING_CHECKS++))
}

print_info() {
    echo -e "${BLUE}  ℹ${NC} $1"
}

# ==============================================================================
# Main Validation
# ==============================================================================

print_header

# Section 1: PF Configuration Files
print_section "1. PF Configuration Files"

print_check "Checking nexus-cos-pf-v2025.10.01.yaml exists"
if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    print_pass "PF YAML configuration found"
else
    print_fail "nexus-cos-pf-v2025.10.01.yaml not found"
fi

print_check "Checking PF_v2025.10.01.md documentation exists"
if [ -f "PF_v2025.10.01.md" ]; then
    print_pass "PF documentation found"
else
    print_fail "PF_v2025.10.01.md not found"
fi

print_check "Checking deployment script exists"
if [ -f "scripts/deploy_hybrid_fullstack_pf.sh" ]; then
    print_pass "Deployment script found"
    if [ -x "scripts/deploy_hybrid_fullstack_pf.sh" ]; then
        print_pass "Deployment script is executable"
    else
        print_fail "Deployment script is not executable"
    fi
else
    print_fail "scripts/deploy_hybrid_fullstack_pf.sh not found"
fi

print_check "Checking docker-compose.pf.yml exists"
if [ -f "docker-compose.pf.yml" ]; then
    print_pass "docker-compose.pf.yml found"
else
    print_fail "docker-compose.pf.yml not found"
fi

echo ""

# Section 2: PF YAML Configuration Validation
print_section "2. PF YAML Configuration"

if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    print_check "Validating PF version"
    if grep -q 'version: "2025.10.01"' nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "PF version is correct (2025.10.01)"
    else
        print_fail "PF version mismatch"
    fi
    
    print_check "Validating PF status"
    if grep -q 'status: live' nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "PF status is LIVE"
    else
        print_fail "PF status is not LIVE"
    fi
    
    print_check "Checking for PUABO NEXUS module"
    if grep -q 'name: puabo-nexus' nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "PUABO NEXUS module defined"
    else
        print_fail "PUABO NEXUS module not found"
    fi
    
    print_check "Checking PUABO NEXUS services"
    local nexus_services=(
        "puabo-nexus-ai-dispatch"
        "puabo-nexus-driver-app-backend"
        "puabo-nexus-fleet-manager"
        "puabo-nexus-route-optimizer"
    )
    
    for service in "${nexus_services[@]}"; do
        if grep -q "name: $service" nexus-cos-pf-v2025.10.01.yaml; then
            print_pass "$service defined in PF"
        else
            print_fail "$service not found in PF"
        fi
    done
    
    print_check "Checking PUABO NEXUS ports"
    if grep -q "port: 3231" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "AI Dispatch port 3231 defined"
    else
        print_fail "AI Dispatch port 3231 not found"
    fi
    
    if grep -q "port: 3232" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "Driver App Backend port 3232 defined"
    else
        print_fail "Driver App Backend port 3232 not found"
    fi
    
    if grep -q "port: 3233" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "Fleet Manager port 3233 defined"
    else
        print_fail "Fleet Manager port 3233 not found"
    fi
    
    if grep -q "port: 3234" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "Route Optimizer port 3234 defined"
    else
        print_fail "Route Optimizer port 3234 not found"
    fi
fi

echo ""

# Section 3: Docker Compose Validation
print_section "3. Docker Compose Configuration"

if [ -f "docker-compose.pf.yml" ]; then
    print_check "Checking for PUABO NEXUS services in docker-compose.pf.yml"
    
    if grep -q "puabo-nexus-ai-dispatch:" docker-compose.pf.yml; then
        print_pass "puabo-nexus-ai-dispatch service defined"
    else
        print_fail "puabo-nexus-ai-dispatch service not found"
    fi
    
    if grep -q "puabo-nexus-driver-app-backend:" docker-compose.pf.yml; then
        print_pass "puabo-nexus-driver-app-backend service defined"
    else
        print_fail "puabo-nexus-driver-app-backend service not found"
    fi
    
    if grep -q "puabo-nexus-fleet-manager:" docker-compose.pf.yml; then
        print_pass "puabo-nexus-fleet-manager service defined"
    else
        print_fail "puabo-nexus-fleet-manager service not found"
    fi
    
    if grep -q "puabo-nexus-route-optimizer:" docker-compose.pf.yml; then
        print_pass "puabo-nexus-route-optimizer service defined"
    else
        print_fail "puabo-nexus-route-optimizer service not found"
    fi
    
    print_check "Checking port mappings"
    if grep -q '"3231:3231"' docker-compose.pf.yml; then
        print_pass "Port 3231 mapped correctly"
    else
        print_fail "Port 3231 not mapped"
    fi
    
    if grep -q '"3232:3232"' docker-compose.pf.yml; then
        print_pass "Port 3232 mapped correctly"
    else
        print_fail "Port 3232 not mapped"
    fi
    
    if grep -q '"3233:3233"' docker-compose.pf.yml; then
        print_pass "Port 3233 mapped correctly"
    else
        print_fail "Port 3233 not mapped"
    fi
    
    if grep -q '"3234:3234"' docker-compose.pf.yml; then
        print_pass "Port 3234 mapped correctly"
    else
        print_fail "Port 3234 not mapped"
    fi
    
    print_check "Validating Docker Compose syntax"
    if command -v docker &> /dev/null && docker compose version &> /dev/null; then
        if docker compose -f docker-compose.pf.yml config > /dev/null 2>&1; then
            print_pass "Docker Compose syntax is valid"
        else
            print_fail "Docker Compose syntax validation failed"
        fi
    else
        print_warning "Docker not available for syntax validation"
    fi
fi

echo ""

# Section 4: Environment Configuration
print_section "4. Environment Configuration"

print_check "Checking .env.pf file"
if [ -f ".env.pf" ]; then
    print_pass ".env.pf file exists"
else
    print_warning ".env.pf file does not exist (will be created from .env.pf.example)"
fi

print_check "Checking .env.pf.example file"
if [ -f ".env.pf.example" ]; then
    print_pass ".env.pf.example file exists"
else
    print_fail ".env.pf.example file not found"
fi

echo ""

# Section 5: Module Definitions
print_section "5. Module Definitions in PF"

if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    local modules=(
        "nexus-core"
        "v-suite"
        "puabo-nexus"
        "puabo-dsp"
        "puabo-blac"
        "nexus-studio-ai"
        "club-saditty"
        "auth"
        "payment"
        "security"
    )
    
    print_check "Checking for required modules"
    for module in "${modules[@]}"; do
        if grep -q "name: $module" nexus-cos-pf-v2025.10.01.yaml; then
            print_pass "Module $module defined"
        else
            print_fail "Module $module not found"
        fi
    done
fi

echo ""

# Section 6: Infrastructure Configuration
print_section "6. Infrastructure Configuration"

if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    print_check "Checking PostgreSQL configuration"
    if grep -q "type: postgresql" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "PostgreSQL configured"
    else
        print_fail "PostgreSQL not configured"
    fi
    
    print_check "Checking Redis configuration"
    if grep -q "type: redis" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "Redis configured"
    else
        print_fail "Redis not configured"
    fi
    
    print_check "Checking centralized logging"
    if grep -q "type: centralized" nexus-cos-pf-v2025.10.01.yaml; then
        print_pass "Centralized logging configured"
    else
        print_fail "Centralized logging not configured"
    fi
fi

echo ""

# Section 7: Health Check Endpoints
print_section "7. Health Check Endpoints"

if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    print_check "Checking for health check endpoints"
    
    local health_endpoints=(
        "/api/health"
        "/puabo-nexus/dispatch/health"
        "/puabo-nexus/driver/health"
        "/puabo-nexus/fleet/health"
        "/puabo-nexus/routes/health"
    )
    
    for endpoint in "${health_endpoints[@]}"; do
        if grep -q "$endpoint" nexus-cos-pf-v2025.10.01.yaml; then
            print_pass "Health endpoint $endpoint defined"
        else
            print_fail "Health endpoint $endpoint not found"
        fi
    done
fi

echo ""

# Section 8: Documentation Validation
print_section "8. Documentation Validation"

if [ -f "PF_v2025.10.01.md" ]; then
    print_check "Checking documentation content"
    
    if grep -q "PF v2025.10.01" PF_v2025.10.01.md; then
        print_pass "Documentation title correct"
    else
        print_fail "Documentation title incorrect"
    fi
    
    if grep -q "PUABO NEXUS" PF_v2025.10.01.md; then
        print_pass "PUABO NEXUS documentation present"
    else
        print_fail "PUABO NEXUS documentation missing"
    fi
    
    if grep -q "3231" PF_v2025.10.01.md; then
        print_pass "Port 3231 documented"
    else
        print_fail "Port 3231 not documented"
    fi
    
    if grep -q "Box Truck" PF_v2025.10.01.md; then
        print_pass "Box Truck ecosystem documented"
    else
        print_fail "Box Truck ecosystem not documented"
    fi
fi

echo ""

# Summary
print_section "VALIDATION SUMMARY"

echo ""
echo -e "${GREEN}Checks Passed:${NC}    ${PASSED_CHECKS}"
echo -e "${RED}Checks Failed:${NC}    ${FAILED_CHECKS}"
echo -e "${YELLOW}Warnings:${NC}         ${WARNING_CHECKS}"
echo ""

TOTAL_CHECKS=$((PASSED_CHECKS + FAILED_CHECKS + WARNING_CHECKS))
echo -e "Total Checks:     ${TOTAL_CHECKS}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✓ PF v2025.10.01 VALIDATION PASSED${NC}"
    echo ""
    echo -e "${CYAN}Ready for deployment!${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Review and configure .env.pf with required secrets"
    echo -e "  2. Run deployment: ${YELLOW}./scripts/deploy_hybrid_fullstack_pf.sh${NC}"
    echo -e "  3. Verify health endpoints after deployment"
    echo ""
    exit 0
else
    echo -e "${RED}${BOLD}✗ PF v2025.10.01 VALIDATION FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the failed checks before proceeding with deployment.${NC}"
    echo ""
    exit 1
fi

#!/bin/bash
# Nexus COS Unified Structure Validator
# v2025 Final Unified Build

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Nexus COS Unified Structure Validator${NC}"
    echo -e "${BLUE}v2025 Final Unified Build${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}$1${NC}"
    echo "----------------------------------------"
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
}

cd "$REPO_ROOT"
print_header

# Section 1: Module Structure
print_section "1. Module Structure Validation"
TOTAL_CHECKS=$((TOTAL_CHECKS + 16))

required_modules=(
    "puabo-os-v200"
    "puabo-nexus"
    "puaboverse"
    "puabo-dsp"
    "puabo-blac"
    "puabo-studio"
    "v-suite"
    "streamcore"
    "gamecore"
    "musicchain"
    "nexus-studio-ai"
    "puabo-nuki-clothing"
    "puabo-ott-tv-streaming"
    "core-os"
    "club-saditty"
    "puabo-nuki"
)

for module in "${required_modules[@]}"; do
    if [ -d "modules/$module" ]; then
        check_pass "Module exists: $module"
    else
        check_fail "Module missing: $module"
    fi
done

# Section 2: V-Suite Components
print_section "2. V-Suite Components"
TOTAL_CHECKS=$((TOTAL_CHECKS + 4))

vsuite_components=(
    "v-screen"
    "v-caster-pro"
    "v-stage"
    "v-prompter-pro"
)

for component in "${vsuite_components[@]}"; do
    if [ -d "modules/v-suite/$component" ]; then
        check_pass "V-Suite component: $component"
    else
        check_fail "V-Suite component missing: $component"
    fi
done

# Section 3: Services Directory
print_section "3. Services & Microservices"
TOTAL_CHECKS=$((TOTAL_CHECKS + 3))

if [ -d "services" ]; then
    check_pass "Services directory exists"
    
    service_count=$(find services -maxdepth 1 -type d | tail -n +2 | wc -l)
    if [ "$service_count" -ge 30 ]; then
        check_pass "Service count: $service_count (target: 30+)"
    else
        check_warn "Service count: $service_count (expected 30+)"
    fi
    
    dockerfile_count=$(find services -maxdepth 2 -name "Dockerfile" | wc -l)
    if [ "$dockerfile_count" -ge 30 ]; then
        check_pass "Dockerfiles: $dockerfile_count"
    else
        check_warn "Dockerfiles: $dockerfile_count (some services may be missing Dockerfiles)"
    fi
else
    check_fail "Services directory not found"
    TOTAL_CHECKS=$((TOTAL_CHECKS - 2))
fi

# Section 4: Docker Configuration
print_section "4. Docker & Orchestration"
TOTAL_CHECKS=$((TOTAL_CHECKS + 5))

if [ -f "docker-compose.pf.yml" ]; then
    check_pass "docker-compose.pf.yml exists"
    
    # Check for cos-net network
    if grep -q "cos-net:" docker-compose.pf.yml; then
        check_pass "cos-net network configured"
    else
        check_fail "cos-net network not found in docker-compose.pf.yml"
    fi
    
    # Check for postgres
    if grep -q "nexus-cos-postgres:" docker-compose.pf.yml; then
        check_pass "PostgreSQL service configured"
    else
        check_fail "PostgreSQL service not configured"
    fi
    
    # Check for redis
    if grep -q "nexus-cos-redis:" docker-compose.pf.yml; then
        check_pass "Redis service configured"
    else
        check_fail "Redis service not configured"
    fi
    
    # Check for puabo-api
    if grep -q "puabo-api:" docker-compose.pf.yml; then
        check_pass "PUABO API service configured"
    else
        check_fail "PUABO API service not configured"
    fi
else
    check_fail "docker-compose.pf.yml not found"
    TOTAL_CHECKS=$((TOTAL_CHECKS - 4))
fi

# Section 5: Environment Configuration
print_section "5. Environment Configuration"
TOTAL_CHECKS=$((TOTAL_CHECKS + 3))

if [ -f ".env.pf" ]; then
    check_pass ".env.pf exists"
else
    check_warn ".env.pf not found (required for deployment)"
fi

if [ -f ".env.pf.example" ]; then
    check_pass ".env.pf.example template exists"
else
    check_warn ".env.pf.example template not found"
fi

if [ -f ".env" ]; then
    check_pass ".env exists"
else
    check_warn ".env not found"
fi

# Section 6: Database Configuration
print_section "6. Database Configuration"
TOTAL_CHECKS=$((TOTAL_CHECKS + 2))

if [ -d "database" ]; then
    check_pass "Database directory exists"
    
    if [ -f "database/schema.sql" ]; then
        check_pass "Database schema found"
    else
        check_warn "Database schema.sql not found"
    fi
else
    check_fail "Database directory not found"
    TOTAL_CHECKS=$((TOTAL_CHECKS - 1))
fi

# Section 7: Nginx Configuration
print_section "7. Nginx Configuration"
TOTAL_CHECKS=$((TOTAL_CHECKS + 2))

if [ -d "nginx" ] || [ -f "nginx.conf" ]; then
    check_pass "Nginx configuration present"
    
    if [ -f "nginx.conf" ] || [ -f "nginx/nginx.conf" ]; then
        check_pass "Nginx config file found"
    else
        check_warn "Nginx config file location unclear"
    fi
else
    check_warn "Nginx configuration not found"
    TOTAL_CHECKS=$((TOTAL_CHECKS - 1))
fi

# Section 8: Documentation
print_section "8. Documentation"
TOTAL_CHECKS=$((TOTAL_CHECKS + 5))

docs=(
    "README.md"
    "NEXUS_COS_V2025_UNIFIED_BUILD_GUIDE.md"
    "PF_BULLETPROOF_README.md"
    "docker-compose.pf.yml"
)

for doc in "${docs[@]}"; do
    if [ -f "$doc" ]; then
        check_pass "Documentation: $doc"
    else
        check_warn "Documentation missing: $doc"
    fi
done

# Check for PF v2025.10.01 spec
if [ -f "nexus-cos-pf-v2025.10.01.yaml" ]; then
    check_pass "PF v2025.10.01 specification exists"
else
    check_warn "PF v2025.10.01 specification not found"
fi

# Section 9: Scripts
print_section "9. Deployment Scripts"
TOTAL_CHECKS=$((TOTAL_CHECKS + 3))

if [ -d "scripts" ]; then
    check_pass "Scripts directory exists"
    
    script_count=$(find scripts -maxdepth 1 -name "*.sh" | wc -l)
    if [ "$script_count" -gt 0 ]; then
        check_pass "Deployment scripts found: $script_count"
    else
        check_warn "No deployment scripts found in scripts/"
    fi
    
    if [ -f "scripts/generate-dockerfiles.sh" ]; then
        check_pass "Dockerfile generator script exists"
    else
        check_warn "Dockerfile generator not found"
    fi
else
    check_warn "Scripts directory not found"
    TOTAL_CHECKS=$((TOTAL_CHECKS - 2))
fi

# Section 10: Health Check Scripts
print_section "10. Health & Validation"
TOTAL_CHECKS=$((TOTAL_CHECKS + 2))

if [ -f "pf-health-check.sh" ]; then
    check_pass "PF health check script exists"
else
    check_warn "PF health check script not found"
fi

validation_scripts=$(find . -maxdepth 1 -name "validate-*.sh" | wc -l)
if [ "$validation_scripts" -gt 0 ]; then
    check_pass "Validation scripts found: $validation_scripts"
else
    check_warn "No validation scripts found"
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Total Checks:    $TOTAL_CHECKS"
echo -e "${GREEN}Passed:          $PASSED_CHECKS${NC}"
echo -e "${YELLOW}Warnings:        $WARNING_CHECKS${NC}"
echo -e "${RED}Failed:          $FAILED_CHECKS${NC}"
echo ""

# Calculate percentage
if [ $TOTAL_CHECKS -gt 0 ]; then
    percentage=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo -e "Success Rate:    ${percentage}%"
    echo ""
    
    if [ $percentage -ge 90 ]; then
        echo -e "${GREEN}✓ Structure validation PASSED${NC}"
        echo -e "${GREEN}✓ Repository is ready for unified build deployment${NC}"
        exit 0
    elif [ $percentage -ge 70 ]; then
        echo -e "${YELLOW}⚠ Structure validation PASSED with warnings${NC}"
        echo -e "${YELLOW}  Review warnings before deployment${NC}"
        exit 0
    else
        echo -e "${RED}✗ Structure validation FAILED${NC}"
        echo -e "${RED}  Critical issues must be resolved${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ No checks performed${NC}"
    exit 1
fi

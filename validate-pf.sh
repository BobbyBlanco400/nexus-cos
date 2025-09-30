#!/bin/bash

# PUABO / Nexus COS - Pre-Flight Deployment Validation Script
# This script validates that the PF deployment matches the specifications

# Don't exit on error - we want to collect all validation results
set +e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PUABO / Nexus COS - PF Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_check() {
    echo -e "${YELLOW}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

print_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((FAILED_CHECKS++))
}

print_info() {
    echo -e "${BLUE}  ℹ${NC} $1"
}

# Section 1: File Validation
echo -e "${BLUE}1. Configuration Files${NC}"
echo ""

print_check "Checking docker-compose.pf.yml exists"
if [ -f "docker-compose.pf.yml" ]; then
    print_pass "docker-compose.pf.yml found"
else
    print_fail "docker-compose.pf.yml not found"
fi

print_check "Checking .env.pf exists"
if [ -f ".env.pf" ]; then
    print_pass ".env.pf found"
else
    print_fail ".env.pf not found"
fi

print_check "Checking database/schema.sql exists"
if [ -f "database/schema.sql" ]; then
    print_pass "database/schema.sql found"
else
    print_fail "database/schema.sql not found"
fi

print_check "Checking database/apply-migrations.sh exists"
if [ -f "database/apply-migrations.sh" ]; then
    print_pass "database/apply-migrations.sh found"
    if [ -x "database/apply-migrations.sh" ]; then
        print_pass "apply-migrations.sh is executable"
    else
        print_fail "apply-migrations.sh is not executable"
    fi
else
    print_fail "database/apply-migrations.sh not found"
fi

echo ""

# Section 2: Service Configuration Validation
echo -e "${BLUE}2. Service Configuration${NC}"
echo ""

print_check "Validating puabo-api configuration in docker-compose.pf.yml"
if grep -q "puabo-api" docker-compose.pf.yml && grep -q "4000:4000" docker-compose.pf.yml; then
    print_pass "puabo-api configured on port 4000"
else
    print_fail "puabo-api not properly configured"
fi

print_check "Validating nexus-cos-postgres configuration"
if grep -q "nexus-cos-postgres" docker-compose.pf.yml && grep -q "5432:5432" docker-compose.pf.yml; then
    print_pass "nexus-cos-postgres configured on port 5432"
    
    if grep -q "POSTGRES_DB: nexus_db" docker-compose.pf.yml; then
        print_pass "Database name: nexus_db"
    else
        print_fail "Database name not set to nexus_db"
    fi
    
    if grep -q "POSTGRES_USER: nexus_user" docker-compose.pf.yml; then
        print_pass "Database user: nexus_user"
    else
        print_fail "Database user not set to nexus_user"
    fi
else
    print_fail "nexus-cos-postgres not properly configured"
fi

print_check "Validating nexus-cos-redis configuration"
if grep -q "nexus-cos-redis" docker-compose.pf.yml && grep -q "6379:6379" docker-compose.pf.yml; then
    print_pass "nexus-cos-redis configured on port 6379"
else
    print_fail "nexus-cos-redis not properly configured"
fi

print_check "Validating nexus-cos-puaboai-sdk configuration"
if grep -q "nexus-cos-puaboai-sdk" docker-compose.pf.yml && grep -q "3002:3002" docker-compose.pf.yml; then
    print_pass "nexus-cos-puaboai-sdk configured on port 3002"
else
    print_fail "nexus-cos-puaboai-sdk not properly configured"
fi

print_check "Validating nexus-cos-pv-keys configuration"
if grep -q "nexus-cos-pv-keys" docker-compose.pf.yml && grep -q "3041:3041" docker-compose.pf.yml; then
    print_pass "nexus-cos-pv-keys configured on port 3041"
else
    print_fail "nexus-cos-pv-keys not properly configured"
fi

echo ""

# Section 3: Environment Variables Validation
echo -e "${BLUE}3. Environment Variables${NC}"
echo ""

print_check "Validating environment variables in .env.pf"
ENV_VARS=("PORT=4000" "DB_PORT=5432" "DB_NAME=nexus_db" "DB_USER=nexus_user" "REDIS_PORT=6379" "NODE_ENV=production")

for var in "${ENV_VARS[@]}"; do
    if grep -q "$var" .env.pf; then
        print_pass "$var is set"
    else
        print_fail "$var is not set"
    fi
done

echo ""

# Section 4: Service Implementation Files
echo -e "${BLUE}4. Service Implementation Files${NC}"
echo ""

print_check "Checking puaboai-sdk service files"
if [ -f "services/puaboai-sdk/server.js" ]; then
    print_pass "server.js found"
else
    print_fail "server.js not found"
fi

if [ -f "services/puaboai-sdk/package.json" ]; then
    print_pass "package.json found"
else
    print_fail "package.json not found"
fi

if [ -f "services/puaboai-sdk/Dockerfile" ]; then
    print_pass "Dockerfile found"
else
    print_fail "Dockerfile not found"
fi

print_check "Checking pv-keys service files"
if [ -f "services/pv-keys/server.js" ]; then
    print_pass "server.js found"
else
    print_fail "server.js not found"
fi

if [ -f "services/pv-keys/package.json" ]; then
    print_pass "package.json found"
else
    print_fail "package.json not found"
fi

if [ -f "services/pv-keys/Dockerfile" ]; then
    print_pass "Dockerfile found"
else
    print_fail "Dockerfile not found"
fi

echo ""

# Section 5: Database Schema Validation
echo -e "${BLUE}5. Database Schema${NC}"
echo ""

print_check "Validating database schema"
REQUIRED_TABLES=("users" "sessions" "api_keys" "audit_log")

for table in "${REQUIRED_TABLES[@]}"; do
    if grep -q "CREATE TABLE.*$table" database/schema.sql; then
        print_pass "$table table defined in schema"
    else
        print_fail "$table table not found in schema"
    fi
done

echo ""

# Section 6: Documentation
echo -e "${BLUE}6. Documentation${NC}"
echo ""

print_check "Checking documentation files"
if [ -f "PF_DEPLOYMENT_VERIFICATION.md" ]; then
    print_pass "PF_DEPLOYMENT_VERIFICATION.md found"
else
    print_fail "PF_DEPLOYMENT_VERIFICATION.md not found"
fi

if [ -f "PF_README.md" ]; then
    print_pass "PF_README.md found"
else
    print_fail "PF_README.md not found"
fi

if [ -f "deploy-pf.sh" ]; then
    print_pass "deploy-pf.sh found"
    if [ -x "deploy-pf.sh" ]; then
        print_pass "deploy-pf.sh is executable"
    else
        print_fail "deploy-pf.sh is not executable"
    fi
else
    print_fail "deploy-pf.sh not found"
fi

echo ""

# Section 7: Docker Validation (if Docker is available)
echo -e "${BLUE}7. Docker Environment${NC}"
echo ""

print_check "Checking Docker availability"
if command -v docker &> /dev/null; then
    print_pass "Docker is installed"
    print_info "Docker version: $(docker --version)"
else
    print_fail "Docker is not installed"
fi

print_check "Checking Docker Compose availability"
if command -v docker-compose &> /dev/null; then
    print_pass "Docker Compose is installed (standalone)"
    print_info "Docker Compose version: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    print_pass "Docker Compose is installed (plugin)"
    print_info "Docker Compose version: $(docker compose version)"
else
    print_fail "Docker Compose is not installed"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "Total Checks: $TOTAL_CHECKS"
echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
echo ""

PASS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
echo -e "Pass Rate: $PASS_RATE%"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ All validation checks passed!${NC}"
    echo -e "${GREEN}The PF deployment configuration is complete and ready.${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "  1. Run: ./deploy-pf.sh"
    echo -e "  2. Verify services are running"
    echo -e "  3. Test endpoints"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some validation checks failed.${NC}"
    echo -e "${YELLOW}Please review the failed checks above and fix the issues.${NC}"
    echo ""
    exit 1
fi

#!/bin/bash
###############################################################################
# Nexus COS Deployment Readiness Validation Script
# Version: 1.0.0
# Purpose: Validate that the deployment system is ready for production use
#
# This script checks:
#   1. All required files exist
#   2. Scripts have correct permissions
#   3. ecosystem.config.js is valid
#   4. No hardcoded paths exist
#   5. All services have correct DB configuration
#
# Usage:
#   ./validate-deployment-readiness.sh
#
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ERRORS=0
WARNINGS=0
PASSED=0

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  ((ERRORS++))
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

print_header "🔍 Nexus COS Deployment Readiness Validation"

echo -e "${BOLD}Checking deployment system...${NC}"
echo ""

###############################################################################
# Check 1: Required Files Exist
###############################################################################

echo -e "${CYAN}[1/7] Checking required files...${NC}"

files=(
  "ecosystem.config.js"
  "nexus-cos-production-deploy.sh"
  "nexus-start.sh"
  "PRODUCTION_DEPLOYMENT_GUIDE.md"
  "START_HERE.md"
)

for file in "${files[@]}"; do
  if [ -f "$file" ]; then
    check_pass "Found: $file"
  else
    check_fail "Missing: $file"
  fi
done

echo ""

###############################################################################
# Check 2: Script Permissions
###############################################################################

echo -e "${CYAN}[2/7] Checking script permissions...${NC}"

scripts=(
  "nexus-cos-production-deploy.sh"
  "nexus-start.sh"
)

for script in "${scripts[@]}"; do
  if [ -x "$script" ]; then
    check_pass "Executable: $script"
  else
    check_fail "Not executable: $script (run: chmod +x $script)"
  fi
done

echo ""

###############################################################################
# Check 3: Node.js and Dependencies
###############################################################################

echo -e "${CYAN}[3/7] Checking dependencies...${NC}"

if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  check_pass "Node.js installed: $NODE_VERSION"
else
  check_fail "Node.js not installed"
fi

if command -v pm2 &> /dev/null; then
  PM2_VERSION=$(pm2 --version)
  check_pass "PM2 installed: v$PM2_VERSION"
else
  check_warn "PM2 not installed (install with: npm install -g pm2)"
fi

if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version)
  check_pass "Git installed: $GIT_VERSION"
else
  check_warn "Git not installed"
fi

if command -v jq &> /dev/null; then
  check_pass "jq installed (for better JSON output)"
else
  check_warn "jq not installed (optional, install with: apt-get install jq)"
fi

if command -v curl &> /dev/null; then
  check_pass "curl installed"
else
  check_warn "curl not installed"
fi

echo ""

###############################################################################
# Check 4: Ecosystem Configuration Validation
###############################################################################

echo -e "${CYAN}[4/7] Validating ecosystem.config.js...${NC}"

if [ -f "ecosystem.config.js" ]; then
  # Check syntax
  if node -c ecosystem.config.js 2>/dev/null; then
    check_pass "Configuration syntax is valid"
  else
    check_fail "Configuration has syntax errors"
  fi
  
  # Count services
  SERVICE_COUNT=$(node -e "console.log(require('./ecosystem.config.js').apps.length)" 2>/dev/null || echo "0")
  if [ "$SERVICE_COUNT" -eq "33" ]; then
    check_pass "Found $SERVICE_COUNT services (expected: 33)"
  else
    check_warn "Found $SERVICE_COUNT services (expected: 33)"
  fi
  
  # Check for hardcoded paths
  if grep -q "cwd:" ecosystem.config.js 2>/dev/null; then
    CWD_COUNT=$(grep -c "cwd:" ecosystem.config.js 2>/dev/null)
    check_fail "Found $CWD_COUNT hardcoded 'cwd' paths"
  else
    check_pass "No hardcoded 'cwd' paths found"
  fi
  
  # Check DB configuration
  DB_LOCALHOST_COUNT=$(node -e "
    const config = require('./ecosystem.config.js');
    const count = config.apps.filter(app => app.env && app.env.DB_HOST === 'localhost').length;
    console.log(count);
  " 2>/dev/null || echo "0")
  
  if [ "$DB_LOCALHOST_COUNT" -eq "$SERVICE_COUNT" ]; then
    check_pass "All services have DB_HOST=localhost"
  else
    check_warn "$DB_LOCALHOST_COUNT/$SERVICE_COUNT services have DB_HOST=localhost"
  fi
  
  # Check all services have complete DB config
  DB_COMPLETE_COUNT=$(node -e "
    const config = require('./ecosystem.config.js');
    const count = config.apps.filter(app => 
      app.env && 
      app.env.DB_HOST && 
      app.env.DB_NAME && 
      app.env.DB_USER && 
      app.env.DB_PASSWORD
    ).length;
    console.log(count);
  " 2>/dev/null || echo "0")
  
  if [ "$DB_COMPLETE_COUNT" -eq "$SERVICE_COUNT" ]; then
    check_pass "All services have complete DB configuration"
  else
    check_fail "$DB_COMPLETE_COUNT/$SERVICE_COUNT services have complete DB configuration"
  fi
else
  check_fail "ecosystem.config.js not found"
fi

echo ""

###############################################################################
# Check 5: Documentation Completeness
###############################################################################

echo -e "${CYAN}[5/7] Checking documentation...${NC}"

docs=(
  "START_HERE.md"
  "PRODUCTION_DEPLOYMENT_GUIDE.md"
)

for doc in "${docs[@]}"; do
  if [ -f "$doc" ]; then
    WORD_COUNT=$(wc -w < "$doc")
    if [ "$WORD_COUNT" -gt 100 ]; then
      check_pass "$doc exists (${WORD_COUNT} words)"
    else
      check_warn "$doc exists but seems incomplete (${WORD_COUNT} words)"
    fi
  else
    check_fail "$doc not found"
  fi
done

echo ""

###############################################################################
# Check 6: Script Functionality
###############################################################################

echo -e "${CYAN}[6/7] Testing script functionality...${NC}"

# Test help option
if ./nexus-cos-production-deploy.sh --help > /dev/null 2>&1; then
  check_pass "nexus-cos-production-deploy.sh --help works"
else
  check_fail "nexus-cos-production-deploy.sh --help failed"
fi

# Test invalid option handling
if ! ./nexus-cos-production-deploy.sh --invalid-option > /dev/null 2>&1; then
  check_pass "Invalid option handling works"
else
  check_warn "Invalid option handling may need review"
fi

echo ""

###############################################################################
# Check 7: Git Status
###############################################################################

echo -e "${CYAN}[7/7] Checking Git repository...${NC}"

if git rev-parse --git-dir > /dev/null 2>&1; then
  check_pass "In a Git repository"
  
  # Check current branch
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  check_pass "Current branch: $CURRENT_BRANCH"
  
  # Check if there are uncommitted changes to critical files
  if git diff --quiet ecosystem.config.js 2>/dev/null; then
    check_pass "ecosystem.config.js has no uncommitted changes"
  else
    check_warn "ecosystem.config.js has uncommitted changes"
  fi
else
  check_warn "Not in a Git repository"
fi

echo ""

###############################################################################
# Summary
###############################################################################

print_header "📊 Validation Summary"

TOTAL=$((PASSED + WARNINGS + ERRORS))

echo -e "${GREEN}✓ Passed:${NC}   $PASSED"
echo -e "${YELLOW}⚠ Warnings:${NC} $WARNINGS"
echo -e "${RED}✗ Errors:${NC}   $ERRORS"
echo -e "${CYAN}─────────────${NC}"
echo -e "${BOLD}Total:${NC}     $TOTAL"
echo ""

if [ $ERRORS -eq 0 ]; then
  if [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}${BOLD}🎉 ALL CHECKS PASSED!${NC}"
    echo ""
    echo "Your deployment system is ready for production use."
    echo ""
    echo "Next steps:"
    echo "  1. Read START_HERE.md for quick start guide"
    echo "  2. Run: ./nexus-cos-production-deploy.sh"
    echo "  3. Verify: curl -s https://nexuscos.online/health | jq"
    echo ""
    exit 0
  else
    echo -e "${YELLOW}${BOLD}⚠️  ALL CHECKS PASSED WITH WARNINGS${NC}"
    echo ""
    echo "Your deployment system is ready, but some optional items need attention."
    echo "Review the warnings above and address them if needed."
    echo ""
    exit 0
  fi
else
  echo -e "${RED}${BOLD}❌ VALIDATION FAILED${NC}"
  echo ""
  echo "Please fix the errors above before deploying to production."
  echo ""
  echo "Common fixes:"
  echo "  - Install missing dependencies: npm install -g pm2"
  echo "  - Make scripts executable: chmod +x *.sh"
  echo "  - Fix ecosystem.config.js syntax errors"
  echo ""
  exit 1
fi

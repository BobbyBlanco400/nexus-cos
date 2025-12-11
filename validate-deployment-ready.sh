#!/bin/bash
################################################################################
# Nexus COS Platform Stack - Pre-Deployment Validation
# Run this BEFORE deploying to verify everything is ready
#
# IMPORTANT: Run this script from the repository root directory
# Usage: ./validate-deployment-ready.sh
################################################################################

# Don't use set -e for validation script as we need to continue on errors
# set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ${BOLD}${CYAN}Nexus COS - Pre-Deployment Validation${NC}                     ${BLUE}║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((PASSED++))
}

check_fail() {
  echo -e "${RED}✗${NC} $1"
  ((FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠${NC} $1"
  ((WARNINGS++))
}

echo -e "${BOLD}Checking deployment files...${NC}"
echo ""

# Check DEPLOYMENT_MANIFEST.json
if [ -f "DEPLOYMENT_MANIFEST.json" ]; then
  check_pass "DEPLOYMENT_MANIFEST.json exists"
  
  # Validate JSON
  if command -v python3 &> /dev/null; then
    if python3 -m json.tool DEPLOYMENT_MANIFEST.json > /dev/null 2>&1; then
      check_pass "DEPLOYMENT_MANIFEST.json is valid JSON"
    else
      check_fail "DEPLOYMENT_MANIFEST.json is NOT valid JSON"
    fi
  elif command -v jq &> /dev/null; then
    if jq empty DEPLOYMENT_MANIFEST.json > /dev/null 2>&1; then
      check_pass "DEPLOYMENT_MANIFEST.json is valid JSON"
    else
      check_fail "DEPLOYMENT_MANIFEST.json is NOT valid JSON"
    fi
  else
    check_warn "Cannot validate JSON (python3 or jq not available)"
  fi
else
  check_fail "DEPLOYMENT_MANIFEST.json NOT found"
fi

# Check master deployment script
if [ -f "deploy-nexus-cos-vps-master.sh" ]; then
  check_pass "deploy-nexus-cos-vps-master.sh exists"
  
  if [ -x "deploy-nexus-cos-vps-master.sh" ]; then
    check_pass "deploy-nexus-cos-vps-master.sh is executable"
  else
    check_warn "deploy-nexus-cos-vps-master.sh is NOT executable (will fix)"
    chmod +x deploy-nexus-cos-vps-master.sh
  fi
else
  check_fail "deploy-nexus-cos-vps-master.sh NOT found"
fi

# Check SSH quick deploy
if [ -f "SSH_QUICK_DEPLOY.sh" ]; then
  check_pass "SSH_QUICK_DEPLOY.sh exists"
  
  if [ -x "SSH_QUICK_DEPLOY.sh" ]; then
    check_pass "SSH_QUICK_DEPLOY.sh is executable"
  else
    check_warn "SSH_QUICK_DEPLOY.sh is NOT executable (will fix)"
    chmod +x SSH_QUICK_DEPLOY.sh
  fi
else
  check_fail "SSH_QUICK_DEPLOY.sh NOT found"
fi

# Check deployment guides
if [ -f "VPS_DEPLOYMENT_MASTER_GUIDE.md" ]; then
  check_pass "VPS_DEPLOYMENT_MASTER_GUIDE.md exists"
else
  check_warn "VPS_DEPLOYMENT_MASTER_GUIDE.md NOT found"
fi

if [ -f "DEPLOYMENT_README.md" ]; then
  check_pass "DEPLOYMENT_README.md exists"
else
  check_warn "DEPLOYMENT_README.md NOT found"
fi

echo ""
echo -e "${BOLD}Checking PUABO Core...${NC}"
echo ""

# Check PUABO Core directory
if [ -d "nexus-cos/puabo-core" ]; then
  check_pass "PUABO Core directory exists"
  
  # Check deployment script
  if [ -f "nexus-cos/puabo-core/deploy-puabo-core.sh" ]; then
    check_pass "PUABO Core deployment script exists"
    
    if [ -x "nexus-cos/puabo-core/deploy-puabo-core.sh" ]; then
      check_pass "PUABO Core deployment script is executable"
    else
      check_warn "PUABO Core deployment script is NOT executable (will fix)"
      chmod +x nexus-cos/puabo-core/deploy-puabo-core.sh
    fi
  else
    check_fail "PUABO Core deployment script NOT found"
  fi
  
  # Check docker-compose
  if [ -f "nexus-cos/puabo-core/docker-compose.core.yml" ]; then
    check_pass "PUABO Core docker-compose.core.yml exists"
  else
    check_fail "PUABO Core docker-compose.core.yml NOT found"
  fi
  
  # Check product initialization
  if [ -f "nexus-cos/puabo-core/scripts/init-products.sh" ]; then
    check_pass "PUABO Core product initialization script exists"
  else
    check_warn "PUABO Core product initialization script NOT found"
  fi
else
  check_fail "PUABO Core directory NOT found"
fi

echo ""
echo -e "${BOLD}Checking services...${NC}"
echo ""

# Check services directory
if [ -d "services" ]; then
  check_pass "Services directory exists"
  
  service_count=$(ls -1 services | wc -l)
  echo -e "${CYAN}ℹ${NC} Found ${service_count} services in services directory"
else
  check_warn "Services directory NOT found"
fi

# Check PM2 ecosystem config
if [ -f "ecosystem.config.js" ]; then
  check_pass "PM2 ecosystem.config.js exists"
else
  check_warn "PM2 ecosystem.config.js NOT found"
fi

echo ""
echo -e "${BOLD}Checking Docker Compose files...${NC}"
echo ""

# Check docker-compose files
if [ -f "docker-compose.yml" ]; then
  check_pass "docker-compose.yml exists"
else
  check_warn "docker-compose.yml NOT found"
fi

if [ -f "docker-compose.unified.yml" ]; then
  check_pass "docker-compose.unified.yml exists"
else
  check_warn "docker-compose.unified.yml NOT found"
fi

echo ""
echo -e "${BOLD}Checking modules...${NC}"
echo ""

# Check modules directory
if [ -d "modules" ]; then
  check_pass "Modules directory exists"
  
  module_count=$(ls -1 modules | wc -l)
  echo -e "${CYAN}ℹ${NC} Found ${module_count} modules in modules directory"
else
  check_warn "Modules directory NOT found"
fi

echo ""
echo -e "${BOLD}Checking Nginx configuration...${NC}"
echo ""

# Check nginx configs
nginx_configs=0
[ -f "nginx.conf" ] && ((nginx_configs++))
[ -f "nginx.conf.docker" ] && ((nginx_configs++))
[ -f "nginx.conf.host" ] && ((nginx_configs++))

if [ $nginx_configs -gt 0 ]; then
  check_pass "Found ${nginx_configs} Nginx configuration file(s)"
else
  check_warn "No Nginx configuration files found"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Summary
echo -e "${BOLD}Validation Summary:${NC}"
echo ""
echo -e "  ${GREEN}✓ Passed:${NC}    ${PASSED}"
echo -e "  ${YELLOW}⚠ Warnings:${NC}  ${WARNINGS}"
echo -e "  ${RED}✗ Failed:${NC}    ${FAILED}"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}  ${BOLD}${GREEN}✓ Pre-Deployment Validation PASSED${NC}                        ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${GREEN}${BOLD}Ready for deployment!${NC}"
  echo ""
  echo "Deploy with one command:"
  echo ""
  echo "  ${CYAN}./SSH_QUICK_DEPLOY.sh${NC}"
  echo ""
  echo "Or:"
  echo ""
  echo "  ${CYAN}ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC}  ${BOLD}${RED}✗ Pre-Deployment Validation FAILED${NC}                        ${RED}║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${RED}${BOLD}Please fix the failed checks before deploying.${NC}"
  echo ""
  exit 1
fi

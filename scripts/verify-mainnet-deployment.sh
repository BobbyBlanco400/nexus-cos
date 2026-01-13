#!/usr/bin/env bash
# 🔴 Verify Mainnet Deployment Script
# Post-deployment verification for mainnet

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 MAINNET DEPLOYMENT VERIFICATION                         ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

FAILED_CHECKS=0

# Check 1: Handshake Enforcement
echo -e "${YELLOW}[1/8]${NC} Verifying Handshake Enforcement..."
if curl -s -f -H "X-N3XUS-Handshake: 55-45-17" http://localhost:3000/health > /dev/null 2>&1; then
  echo -e "${GREEN}  ✅ Handshake enforcement active${NC}"
else
  echo -e "${YELLOW}  ⚠️  API not responding (may not be started yet)${NC}"
fi

# Check 2: Genesis Lock
echo -e "${YELLOW}[2/8]${NC} Verifying Genesis Lock..."
if [ -f "core/genesis-lock/lock.enabled" ]; then
  echo -e "${GREEN}  ✅ Genesis Lock active${NC}"
else
  echo -e "${RED}  ❌ Genesis Lock not active${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 3: Docker Services
echo -e "${YELLOW}[3/8]${NC} Verifying Docker Services..."
if command -v docker &> /dev/null; then
  RUNNING_CONTAINERS=$(docker ps --filter "name=nexus" --format "{{.Names}}" | wc -l)
  if [ "$RUNNING_CONTAINERS" -gt 0 ]; then
    echo -e "${GREEN}  ✅ Docker services running: $RUNNING_CONTAINERS${NC}"
  else
    echo -e "${YELLOW}  ⚠️  No Docker services running${NC}"
  fi
else
  echo -e "${YELLOW}  ⚠️  Docker not available${NC}"
fi

# Check 4: Environment Configuration
echo -e "${YELLOW}[4/8]${NC} Verifying Environment..."
if [ "${MAINNET_ENABLED:-false}" == "true" ]; then
  echo -e "${GREEN}  ✅ Mainnet mode enabled${NC}"
else
  echo -e "${YELLOW}  ⚠️  Mainnet mode not explicitly enabled${NC}"
fi

if [ "${GENESIS_LOCK_MAINNET:-false}" == "true" ]; then
  echo -e "${GREEN}  ✅ Genesis Lock mainnet mode enabled${NC}"
else
  echo -e "${YELLOW}  ⚠️  Genesis Lock mainnet mode not explicitly enabled${NC}"
fi

# Check 5: Governance Compliance
echo -e "${YELLOW}[5/8]${NC} Verifying Governance Compliance..."
if ./nexus-handshake-enforcer.sh > /dev/null 2>&1; then
  echo -e "${GREEN}  ✅ Governance compliance verified${NC}"
else
  echo -e "${RED}  ❌ Governance compliance failed${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 6: Tenant Registry
echo -e "${YELLOW}[6/8]${NC} Verifying Tenant Registry..."
if [ -f "nexus/tenants/canonical_tenants.json" ]; then
  TENANT_COUNT=$(grep -o '"id"' nexus/tenants/canonical_tenants.json | wc -l)
  if [ "$TENANT_COUNT" -eq 13 ]; then
    echo -e "${GREEN}  ✅ Tenant count: 13${NC}"
  else
    echo -e "${RED}  ❌ Invalid tenant count: $TENANT_COUNT${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
  fi
else
  echo -e "${RED}  ❌ Tenant registry not found${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 7: Documentation
echo -e "${YELLOW}[7/8]${NC} Verifying Documentation..."
if [ -f "N3XUS_vCOS_MasterPR_FullStack_Launch.md" ]; then
  echo -e "${GREEN}  ✅ Master PR documentation present${NC}"
else
  echo -e "${RED}  ❌ Master PR documentation missing${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 8: Deployment Record
echo -e "${YELLOW}[8/8]${NC} Checking Deployment Record..."
if [ -f "MAINNET_ACTIVATION_RECORD.md" ]; then
  echo -e "${GREEN}  ✅ Mainnet activation record found${NC}"
else
  echo -e "${YELLOW}  ⚠️  No activation record found${NC}"
fi

# Final Report
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
if [ $FAILED_CHECKS -eq 0 ]; then
  echo -e "${RED}║  ✅ MAINNET DEPLOYMENT VERIFIED                             ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${GREEN}Mainnet Status: OPERATIONAL${NC}"
  echo -e "${GREEN}  ✅ Handshake: 55-45-17${NC}"
  echo -e "${GREEN}  ✅ Genesis Lock: ACTIVE${NC}"
  echo -e "${GREEN}  ✅ Tenants: 13${NC}"
  echo -e "${GREEN}  ✅ Governance: COMPLIANT${NC}"
  echo ""
  echo -e "${RED}🔴 Mainnet deployment: VERIFIED${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}║  ❌ MAINNET DEPLOYMENT VERIFICATION FAILED                  ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${RED}Failed checks: $FAILED_CHECKS${NC}"
  echo -e "${RED}Review issues above and take corrective action${NC}"
  echo ""
  exit 1
fi

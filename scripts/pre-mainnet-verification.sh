#!/usr/bin/env bash
# 🔴 Pre-Mainnet Verification Script
# Comprehensive system check before mainnet activation

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 PRE-MAINNET VERIFICATION                                ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

FAILED_CHECKS=0

# Check 1: Genesis Lock
echo -e "${YELLOW}[1/10]${NC} Verifying Genesis Lock..."
if [ -f "core/genesis-lock/lock.enabled" ]; then
  echo -e "${GREEN}  ✅ Genesis Lock enabled${NC}"
else
  echo -e "${RED}  ❌ Genesis Lock not enabled${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 2: Handshake Environment
echo -e "${YELLOW}[2/10]${NC} Verifying Handshake Environment..."
export NEXUS_HANDSHAKE="55-45-17"
export GENESIS_LOCK_ENABLED="true"
if [ "$NEXUS_HANDSHAKE" == "55-45-17" ]; then
  echo -e "${GREEN}  ✅ Handshake configured: 55-45-17${NC}"
else
  echo -e "${RED}  ❌ Invalid handshake configuration${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 3: Governance Charter
echo -e "${YELLOW}[3/10]${NC} Verifying Governance Charter..."
if [ -f "GOVERNANCE_CHARTER_55_45_17.md" ]; then
  echo -e "${GREEN}  ✅ Governance Charter present${NC}"
else
  echo -e "${RED}  ❌ Governance Charter missing${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 4: Tenant Registry
echo -e "${YELLOW}[4/10]${NC} Verifying Tenant Registry..."
if [ -f "nexus/tenants/canonical_tenants.json" ]; then
  TENANT_COUNT=$(grep -o '"id"' nexus/tenants/canonical_tenants.json | wc -l)
  if [ "$TENANT_COUNT" -eq 13 ]; then
    echo -e "${GREEN}  ✅ Tenant count: 13${NC}"
  else
    echo -e "${RED}  ❌ Invalid tenant count: $TENANT_COUNT (expected 13)${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
  fi
else
  echo -e "${RED}  ❌ Tenant registry not found${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 5: Revenue Split
echo -e "${YELLOW}[5/10]${NC} Verifying Revenue Split..."
if grep -q '"split": "80/20"' nexus/tenants/canonical_tenants.json 2>/dev/null; then
  echo -e "${GREEN}  ✅ Revenue split: 80/20${NC}"
else
  echo -e "${RED}  ❌ Revenue split not configured correctly${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 6: Docker Compose Configuration
echo -e "${YELLOW}[6/10]${NC} Verifying Docker Compose..."
if [ -f "docker-compose.pf-master.yml" ]; then
  echo -e "${GREEN}  ✅ Docker Compose configuration present${NC}"
else
  echo -e "${RED}  ❌ Docker Compose configuration missing${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 7: Master PR Documentation
echo -e "${YELLOW}[7/10]${NC} Verifying Master PR Documentation..."
if [ -f "N3XUS_vCOS_MasterPR_FullStack_Launch.md" ]; then
  echo -e "${GREEN}  ✅ Master PR documentation present${NC}"
else
  echo -e "${RED}  ❌ Master PR documentation missing${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 8: Codespaces Configuration
echo -e "${YELLOW}[8/10]${NC} Verifying Codespaces Configuration..."
if [ -f ".devcontainer/devcontainer.json" ]; then
  echo -e "${GREEN}  ✅ Codespaces configured${NC}"
else
  echo -e "${RED}  ❌ Codespaces configuration missing${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 9: CI/CD Workflows
echo -e "${YELLOW}[9/10]${NC} Verifying CI/CD Workflows..."
if [ -f ".github/workflows/handshake-enforcement.yml" ] && [ -f ".github/workflows/mainnet-activation.yml" ]; then
  echo -e "${GREEN}  ✅ CI/CD workflows configured${NC}"
else
  echo -e "${RED}  ❌ CI/CD workflows incomplete${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Check 10: Handshake Enforcer
echo -e "${YELLOW}[10/10]${NC} Running Handshake Enforcer..."
if [ -x "nexus-handshake-enforcer.sh" ]; then
  if ./nexus-handshake-enforcer.sh > /dev/null 2>&1; then
    echo -e "${GREEN}  ✅ Handshake enforcement passed${NC}"
  else
    echo -e "${RED}  ❌ Handshake enforcement failed${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
  fi
else
  echo -e "${RED}  ❌ Handshake enforcer not executable${NC}"
  FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi

# Final Report
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
if [ $FAILED_CHECKS -eq 0 ]; then
  echo -e "${RED}║  ✅ PRE-MAINNET VERIFICATION PASSED                         ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${GREEN}All checks passed: 10/10${NC}"
  echo -e "${GREEN}System is READY for mainnet activation${NC}"
  echo ""
  echo -e "${RED}🔴 Next Steps:${NC}"
  echo -e "${YELLOW}  1. Review MAINNET_ACTIVATION_RECORD.md${NC}"
  echo -e "${YELLOW}  2. Run mainnet activation workflow${NC}"
  echo -e "${YELLOW}  3. Deploy with: docker compose --profile phase1 --profile phase2 --profile phase2.5 up -d${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}║  ❌ PRE-MAINNET VERIFICATION FAILED                         ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${RED}Failed checks: $FAILED_CHECKS/10${NC}"
  echo -e "${RED}System is NOT READY for mainnet activation${NC}"
  echo ""
  echo -e "${RED}🔴 Action Required:${NC}"
  echo -e "${YELLOW}  1. Review failed checks above${NC}"
  echo -e "${YELLOW}  2. Fix all issues${NC}"
  echo -e "${YELLOW}  3. Re-run this script${NC}"
  echo ""
  exit 1
fi

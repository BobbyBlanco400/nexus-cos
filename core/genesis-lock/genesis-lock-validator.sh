#!/usr/bin/env bash
# 🔴 Genesis Lock Validator
# Critical system safety mechanism - enforces handshake 55-45-17

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 GENESIS LOCK VALIDATOR                                  ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if Genesis Lock is enabled
if [ ! -f "core/genesis-lock/lock.enabled" ]; then
  echo -e "${RED}❌ GENESIS LOCK NOT ENABLED${NC}"
  echo -e "${RED}   System will SILENTLY FAIL without Genesis Lock${NC}"
  echo ""
  echo -e "${YELLOW}To enable Genesis Lock:${NC}"
  echo -e "${YELLOW}  mkdir -p core/genesis-lock${NC}"
  echo -e "${YELLOW}  touch core/genesis-lock/lock.enabled${NC}"
  echo ""
  exit 1
fi

echo -e "${GREEN}✅ Genesis Lock file found${NC}"

# Validate handshake environment variable
if [ -z "${NEXUS_HANDSHAKE:-}" ]; then
  echo -e "${RED}❌ NEXUS_HANDSHAKE not set${NC}"
  echo -e "${RED}   Expected: 55-45-17${NC}"
  echo ""
  exit 1
fi

if [ "$NEXUS_HANDSHAKE" != "55-45-17" ]; then
  echo -e "${RED}❌ INVALID HANDSHAKE: $NEXUS_HANDSHAKE${NC}"
  echo -e "${RED}   Expected: 55-45-17${NC}"
  echo ""
  exit 1
fi

echo -e "${GREEN}✅ Handshake validated: 55-45-17${NC}"

# Validate Genesis Lock enabled flag
if [ -z "${GENESIS_LOCK_ENABLED:-}" ] || [ "$GENESIS_LOCK_ENABLED" != "true" ]; then
  echo -e "${RED}❌ GENESIS_LOCK_ENABLED not set to true${NC}"
  echo ""
  exit 1
fi

echo -e "${GREEN}✅ Genesis Lock enabled in environment${NC}"

# Check critical files exist
echo ""
echo -e "${YELLOW}Validating critical files...${NC}"

CRITICAL_FILES=(
  "GOVERNANCE_CHARTER_55_45_17.md"
  "nexus-handshake-enforcer.sh"
  "nexus/tenants/canonical_tenants.json"
  "docker-compose.pf-master.yml"
)

for file in "${CRITICAL_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo -e "${GREEN}  ✅ $file${NC}"
  else
    echo -e "${RED}  ❌ $file (MISSING)${NC}"
    exit 1
  fi
done

# Validate tenant count
echo ""
echo -e "${YELLOW}Validating tenant registry...${NC}"

if [ -f "nexus/tenants/canonical_tenants.json" ]; then
  TENANT_COUNT=$(grep -o '"id"' "nexus/tenants/canonical_tenants.json" | wc -l)
  if [ "$TENANT_COUNT" -eq 13 ]; then
    echo -e "${GREEN}✅ Tenant count: $TENANT_COUNT (VALID)${NC}"
  else
    echo -e "${RED}❌ Tenant count: $TENANT_COUNT (Expected: 13)${NC}"
    exit 1
  fi
else
  echo -e "${RED}❌ Tenant registry not found${NC}"
  exit 1
fi

# Validate revenue split
if grep -q '"split": "80/20"' "nexus/tenants/canonical_tenants.json"; then
  echo -e "${GREEN}✅ Revenue split: 80/20 (LOCKED)${NC}"
else
  echo -e "${RED}❌ Revenue split not set to 80/20${NC}"
  exit 1
fi

# Final validation
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ✅ GENESIS LOCK VALIDATION COMPLETE                        ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Genesis Lock Status: ${RED}ACTIVE${NC}"
echo -e "${GREEN}Handshake: ${RED}55-45-17${NC}"
echo -e "${GREEN}Tenants: ${RED}13${NC}"
echo -e "${GREEN}Revenue Split: ${RED}80/20${NC}"
echo ""
echo -e "${RED}🔴 System safety mechanism: ENGAGED${NC}"
echo -e "${RED}🔴 Silent failure mode: ENABLED${NC}"
echo ""

exit 0

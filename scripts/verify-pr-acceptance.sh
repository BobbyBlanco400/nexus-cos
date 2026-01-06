#!/bin/bash
# verify-pr-acceptance.sh - Verify all acceptance criteria for N3XUS v-COS PR

# Note: Don't use set -e, we want to collect all failures
set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAIL_COUNT=0
PASS_COUNT=0

# Function to check a criterion
check() {
  local description=$1
  local command=$2
  
  echo -n "Checking: $description... "
  
  if eval "$command" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS_COUNT++))
  else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAIL_COUNT++))
  fi
}

echo "========================================================================"
echo "  N3XUS v-COS PR Acceptance Verification"
echo "  Handshake: 55-45-17 | Network: n3xus-net"
echo "========================================================================"
echo ""

# Phase 1: Branding Updates
echo "Phase 1: Branding Updates to N3XUS v-COS"
echo "----------------------------------------"

check "Logo in branding/ updated" \
  "grep -q 'N3XUS v-COS' branding/logo.svg"

check "Logo in admin/ updated" \
  "grep -q 'N3XUS v-COS' admin/public/assets/branding/logo.svg"

check "Logo in creator-hub/ updated" \
  "grep -q 'N3XUS v-COS' creator-hub/public/assets/branding/logo.svg"

check "Logo in frontend/ updated" \
  "grep -q 'N3XUS v-COS' frontend/public/assets/branding/logo.svg"

check "Brand Bible updated with v-COS" \
  "grep -q 'N3XUS v-COS' brand/bible/N3XUS_COS_Brand_Bible.md"

check "Brand Bible references n3xus-net" \
  "grep -q 'n3xus-net' brand/bible/N3XUS_COS_Brand_Bible.md"

echo ""

# Phase 2: Network Unification
echo "Phase 2: Network Unification under n3xus-net"
echo "--------------------------------------------"

check "n3xus-net documentation exists" \
  "test -f docs/n3xus-net/README.md"

check "n3xus-net docs comprehensive (>200 lines)" \
  "[ \$(wc -l < docs/n3xus-net/README.md) -gt 200 ]"

check "Internal hostname schema documented" \
  "grep -E '(v-stream|v-auth|v-platform|v-suite|v-content)' docs/n3xus-net/README.md"

check "Handshake protocol documented" \
  "grep -q '55-45-17' docs/n3xus-net/README.md"

check "Database services documented" \
  "grep -E '(v-postgres|v-redis|v-mongo)' docs/n3xus-net/README.md"

echo ""

# Phase 3: NGINX Gateway Alignment
echo "Phase 3: NGINX Gateway Alignment"
echo "---------------------------------"

check "nginx.conf updated with v- upstreams" \
  "grep -q 'upstream v_stream' nginx.conf"

check "nginx.conf references N3XUS v-COS" \
  "grep -q 'N3XUS v-COS' nginx.conf"

check "nginx.conf references n3xus-net" \
  "grep -q 'n3xus-net' nginx.conf"

check "nginx.conf.docker updated" \
  "grep -q 'N3XUS v-COS' nginx.conf.docker && grep -q 'upstream v_stream' nginx.conf.docker"

check "nginx.conf.host updated" \
  "grep -q 'N3XUS v-COS' nginx.conf.host && grep -q 'upstream v_stream' nginx.conf.host"

check "nginx-29-services.conf header updated" \
  "grep -q 'N3XUS v-COS' nginx-29-services.conf"

echo ""

# Phase 4: Documentation Scaffolding
echo "Phase 4: Documentation Scaffolding"
echo "-----------------------------------"

check "v-COS documentation exists" \
  "test -f docs/v-COS/README.md"

check "v-COS docs comprehensive (>300 lines)" \
  "[ \$(wc -l < docs/v-COS/README.md) -gt 300 ]"

check "v-COS docs reference v-Suite" \
  "grep -E '(V-Screen|V-Caster|V-Stage|V-Prompter|v-Suite)' docs/v-COS/README.md"

check "Sovereign Genesis documentation exists" \
  "test -f docs/Sovereign-Genesis/README.md"

check "Sovereign Genesis comprehensive (>300 lines)" \
  "[ \$(wc -l < docs/Sovereign-Genesis/README.md) -gt 300 ]"

check "Sovereign Genesis references sovereignty" \
  "grep -i 'sovereign' docs/Sovereign-Genesis/README.md"

check "v-COS directory structure created" \
  "test -d docs/v-COS"

check "n3xus-net directory structure created" \
  "test -d docs/n3xus-net"

check "Sovereign-Genesis directory structure created" \
  "test -d docs/Sovereign-Genesis"

echo ""

# Phase 5: Agent Instructions & Acceptance Criteria
echo "Phase 5: Agent Instructions & Acceptance Criteria"
echo "--------------------------------------------------"

check "Agent deployment procedures exist" \
  "test -f docs/agent-deployment-procedures.md"

check "Deployment procedures comprehensive (>300 lines)" \
  "[ \$(wc -l < docs/agent-deployment-procedures.md) -gt 300 ]"

check "Acceptance criteria document exists" \
  "test -f docs/acceptance-criteria.md"

check "Acceptance criteria comprehensive (>400 lines)" \
  "[ \$(wc -l < docs/acceptance-criteria.md) -gt 400 ]"

check "Verification script exists" \
  "test -f scripts/verify-pr-acceptance.sh"

check "Verification script is executable" \
  "test -x scripts/verify-pr-acceptance.sh"

echo ""
echo "========================================================================"
echo "  Verification Complete"
echo "========================================================================"
echo -e "  ${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "  ${RED}Failed: $FAIL_COUNT${NC}"
echo "========================================================================"

if [ $FAIL_COUNT -eq 0 ]; then
  echo -e "${GREEN}"
  echo "✓ ALL ACCEPTANCE CRITERIA MET"
  echo "✓ PR is ready for approval and merge"
  echo -e "${NC}"
  exit 0
else
  echo -e "${RED}"
  echo "✗ Some acceptance criteria not met"
  echo "✗ Please review failed checks above"
  echo -e "${NC}"
  exit 1
fi

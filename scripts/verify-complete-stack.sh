#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo "   N3XUS v-COS COMPLETE STACK VERIFICATION"
echo "   Phases 1-12 | Sovereign Fabric"
echo "=================================================="
echo "Date: $(date)"
echo "Target: Localhost (via Docker Network)"
echo "--------------------------------------------------"

TOTAL=0
PASS=0
FAIL=0

check_service() {
    local name=$1
    local port=$2
    local path=${3:-health}
    
    TOTAL=$((TOTAL + 1))
    
    # Try localhost first
    URL="http://localhost:$port/$path"
    
    # Simple curl check
    if curl -s -f -o /dev/null -m 2 "$URL"; then
        echo -e "[${GREEN}PASS${NC}] $name (Port $port)"
        PASS=$((PASS + 1))
    else
        echo -e "[${RED}FAIL${NC}] $name (Port $port) - Unreachable"
        FAIL=$((FAIL + 1))
    fi
}

echo ">>> INFRASTRUCTURE & CORE (PHASE 1-4)"
check_service "Nginx Gateway" 80 ""
check_service "v-SuperCore" 3001
check_service "Puabo AI API" 3002

echo ""
echo ">>> FEDERATION (PHASE 5-6)"
check_service "Federation Spine" 3010
check_service "Identity Registry" 3011
check_service "Federation Gateway" 3012
check_service "Attestation Svc" 3013

echo ""
echo ">>> CASINO DOMAIN (PHASE 7-8)"
check_service "Casino Core" 3020
check_service "Ledger Engine" 3021

echo ""
echo ">>> FINANCIAL CORE (PHASE 9)"
check_service "Wallet Engine" 3030
check_service "Treasury Core" 3031
check_service "Payout Engine" 3032

echo ""
echo ">>> EARNINGS & MEDIA (PHASE 10)"
check_service "Earnings Oracle" 3040
check_service "PMMG Media" 3041
check_service "Royalty Engine" 3042

echo ""
echo ">>> GOVERNANCE (PHASE 11-12)"
check_service "Governance Core" 3050
check_service "Constitution Eng" 3051

echo ""
echo ">>> COMPLIANCE LAYER"
check_service "Payment Partner" 4001
check_service "Jurisdiction" 4002
check_service "Resp. Gaming" 4003
check_service "Legal Entity" 4004
check_service "Explicit Opt-In" 4005

echo ""
echo ">>> EXTENDED SERVICES (Sample)"
check_service "Backend API" 4051
check_service "Auth Service" 4052
check_service "PuaboVerse" 4053
check_service "StreamCore" 4054
check_service "MetaTwin" 4055

echo "--------------------------------------------------"
echo "SUMMARY:"
echo "Total: $TOTAL"
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ ALL SYSTEMS OPERATIONAL${NC}"
else
    echo -e "${YELLOW}⚠️  SYSTEMS DEGRADED${NC}"
fi

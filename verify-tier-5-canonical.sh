#!/bin/bash
# 🔴 MASTER TIER 5 VERIFICATION SCRIPT
# Handshake: 55-45-17
# Purpose: Run all Tier 5 canonical verifications

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

echo ""
echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 TIER 5 CANONICAL VERIFICATION SUITE  ║${NC}"
echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}System:${NC} N3XUS v-COS"
echo -e "${BLUE}Handshake:${NC} ${RED}55-45-17${NC}"
echo -e "${BLUE}Authority:${NC} Canonical"
echo -e "${BLUE}Date:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Track overall status
FAILED=0
PASSED=0
WARNINGS=0

# Function to run verification
run_verification() {
    local script_name=$1
    local description=$2
    
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Running:${NC} $description"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [ ! -f "$script_name" ]; then
        echo -e "${RED}❌ FAILED: Script not found: $script_name${NC}"
        ((FAILED++))
        return 1
    fi
    
    if ! [ -x "$script_name" ]; then
        echo -e "${YELLOW}⚠️  Making script executable: $script_name${NC}"
        chmod +x "$script_name"
    fi
    
    if ./"$script_name"; then
        echo ""
        echo -e "${GREEN}✅ PASSED: $description${NC}"
        ((PASSED++))
        return 0
    else
        echo ""
        echo -e "${RED}❌ FAILED: $description${NC}"
        ((FAILED++))
        return 1
    fi
}

# Run all verifications
echo -e "${RED}Starting Tier 5 canonical verification suite...${NC}"
echo ""

run_verification "verify-tier-5-slots.sh" "Tier 5 Slot Constraint Verification"
echo ""

run_verification "verify-tier-5-revenue-model.sh" "Tier 5 Revenue Model (80/20) Verification"
echo ""

run_verification "verify-tier-4-to-5-pathway.sh" "Tier 4 → 5 Promotion Pathway Verification"
echo ""

run_verification "verify-tier-5-handshake.sh" "Tier 5 Handshake (55-45-17) Verification"
echo ""

# Display summary
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}║           VERIFICATION SUMMARY            ║${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Tests Passed:${NC} ${GREEN}$PASSED${NC}"
echo -e "${BLUE}Tests Failed:${NC} ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ ALL TIER 5 VERIFICATIONS PASSED       ║${NC}"
    echo -e "${GREEN}║                                            ║${NC}"
    echo -e "${GREEN}║  Status: CANON COMPLIANT                   ║${NC}"
    echo -e "${GREEN}║  Handshake: 55-45-17                       ║${NC}"
    echo -e "${GREEN}║  Authority: Canonical                      ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ TIER 5 VERIFICATION FAILURES DETECTED  ║${NC}"
    echo -e "${RED}║                                            ║${NC}"
    echo -e "${RED}║  Status: NON-COMPLIANT                     ║${NC}"
    echo -e "${RED}║  Failed Tests: $FAILED                           ║${NC}"
    echo -e "${RED}║  Action Required: Fix issues above         ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi

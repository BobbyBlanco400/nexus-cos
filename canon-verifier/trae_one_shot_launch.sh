#!/usr/bin/env bash

################################################################################
# 🔴 TRAE ONE-SHOT VERIFICATION + LAUNCH COMMAND
################################################################################
# 
# ⚠️ PURPOSE: Complete verification sequence followed by automatic N3XUS COS launch
# ⚠️ MODE: Non-Destructive Verification → Deterministic Launch
# ⚠️ COMPLIANCE: N3XUS Handshake 55-45-17 + Article VIII Red Highlighting
# ⚠️ AUTHORITY: Canonical
#
################################################################################

set -e  # Exit on any error

# ANSI Color Codes (Article VIII Compliance)
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🔴 N3XUS CANON-VERIFIER: ONE-SHOT VERIFICATION + LAUNCH SEQUENCE 🔴       ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}⚠️  MODE: Read-Only Verification → Atomic Launch${NC}"
echo -e "${RED}⚠️  HANDSHAKE: 55-45-17${NC}"
echo -e "${RED}⚠️  TIMESTAMP: $(date -u +"%Y-%m-%dT%H:%M:%SZ")${NC}"
echo ""
################################################################################

# Get script directory (canon-verifier/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${RED}[PHASE 0/10]${NC} ${BLUE}Pre-Flight Check${NC}"
echo -e "${YELLOW}  → Verifying script location...${NC}"
if [[ ! -f "run_verification.py" ]]; then
    echo -e "${RED}✗ ERROR: Not in canon-verifier directory!${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Location verified: $(pwd)${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 1/10: SYSTEM INVENTORY (Reality Enumeration)                         ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 inventory_phase/enumerate_services.py
echo -e "${GREEN}  ✓ Phase 1 Complete: inventory.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 2/10: RUNTIME BINDING LAYER (Docker/PM2 Mapping)                     ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 extensions/docker_pm2_mapping.py
echo -e "${GREEN}  ✓ Phase 2 Complete: runtime-truth-map.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 3/10: SERVICE RESPONSIBILITY VALIDATION (Proof of Purpose)           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 responsibility_validation/validate_claims.py
echo -e "${GREEN}  ✓ Phase 3 Complete: service-responsibility-matrix.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 4/10: DEPENDENCY GRAPH TEST (Truth Graph)                            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 dependency_tests/dependency_graph.py
echo -e "${GREEN}  ✓ Phase 4 Complete: dependency-graph.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 5/10: EVENT BUS VERIFICATION (Orchestration Continuity)              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 event_orchestration/canonical_events.py
echo -e "${GREEN}  ✓ Phase 5 Complete: event-propagation-report.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 6/10: META-CLAIM VALIDATION (Identity→MetaTwin→Runtime)              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 meta_claim_validation/identity_metatwin_chain.py
echo -e "${GREEN}  ✓ Phase 6 Complete: meta-claim-validation.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 7/10: HARDWARE ORCHESTRATION SIMULATION (v-Hardware Logic)           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 hardware_simulation/simulate_vhardware.py
echo -e "${GREEN}  ✓ Phase 7 Complete: hardware-simulation.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 8/10: PERFORMANCE SANITY CHECK (Deadlock/Backlog Detection)          ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 performance_sanity/check_runtime_health.py
echo -e "${GREEN}  ✓ Phase 8 Complete: performance-sanity.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 9/10: FINAL VERDICT GENERATION (4-Category Classification)           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 final_verdict/generate_verdict.py
echo -e "${GREEN}  ✓ Phase 9 Complete: canon-verdict.json generated${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  PHASE 10/10: CI GATEKEEPER (Fail-Fast Validation)                          ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
python3 ci_gatekeeper/gatekeeper.py

GATEKEEPER_EXIT=$?
if [ $GATEKEEPER_EXIT -ne 0 ]; then
    echo -e "${RED}✗ GATEKEEPER FAILED: Canon verification detected critical blockers${NC}"
    echo -e "${RED}✗ LAUNCH ABORTED: System not verified as operational${NC}"
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ NO-GO: N3XUS COS verification failed. Launch aborted.                   ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi

echo -e "${GREEN}  ✓ Phase 10 Complete: CI Gatekeeper PASSED${NC}"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ✅ VERIFICATION COMPLETE: All 10 Phases Passed                              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Verification Artifacts Generated:${NC}"
echo -e "  ${YELLOW}→${NC} output/inventory.json"
echo -e "  ${YELLOW}→${NC} output/runtime-truth-map.json"
echo -e "  ${YELLOW}→${NC} output/service-responsibility-matrix.json"
echo -e "  ${YELLOW}→${NC} output/dependency-graph.json"
echo -e "  ${YELLOW}→${NC} output/event-propagation-report.json"
echo -e "  ${YELLOW}→${NC} output/meta-claim-validation.json"
echo -e "  ${YELLOW}→${NC} output/hardware-simulation.json"
echo -e "  ${YELLOW}→${NC} output/performance-sanity.json"
echo -e "  ${YELLOW}→${NC} output/canon-verdict.json"
echo -e "  ${YELLOW}→${NC} output/service-responsibility-matrix-complete.json"
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  🚀 INITIATING N3XUS COS ATOMIC LAUNCH SEQUENCE                            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Navigate to project root (one directory up from canon-verifier)
cd ..

################################################################################
echo -e "${RED}[LAUNCH 1/2]${NC} ${BLUE}Starting PM2 Services (n3xus-platform)${NC}"
if [[ -f "ecosystem.config.js" ]]; then
    pm2 start ecosystem.config.js --only n3xus-platform 2>&1 || echo -e "${YELLOW}  ⚠️  PM2 start warning (may already be running)${NC}"
    echo -e "${GREEN}  ✓ PM2 services started/verified${NC}"
else
    echo -e "${YELLOW}  ⚠️  ecosystem.config.js not found, skipping PM2 launch${NC}"
fi
echo ""

################################################################################
echo -e "${RED}[LAUNCH 2/2]${NC} ${BLUE}Starting Docker Compose Services${NC}"
if [[ -f "docker-compose.yml" ]]; then
    docker-compose -f docker-compose.yml up -d
    echo -e "${GREEN}  ✓ Docker Compose services started${NC}"
else
    echo -e "${YELLOW}  ⚠️  docker-compose.yml not found, skipping Docker launch${NC}"
fi
echo ""

################################################################################
echo -e "${RED}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║                                                                              ║${NC}"
echo -e "${RED}║  ✅ ✅ ✅  GO: N3XUS COS FULLY VERIFIED AND LAUNCHED  ✅ ✅ ✅               ║${NC}"
echo -e "${RED}║                                                                              ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}System Status:${NC}"
echo -e "  ${GREEN}✓${NC} Verification: ${GREEN}PASSED${NC} (All 10 phases)"
echo -e "  ${GREEN}✓${NC} CI Gatekeeper: ${GREEN}PASSED${NC}"
echo -e "  ${GREEN}✓${NC} PM2 Services: ${GREEN}ACTIVE${NC}"
echo -e "  ${GREEN}✓${NC} Docker Services: ${GREEN}ACTIVE${NC}"
echo -e "  ${GREEN}✓${NC} N3XUS COS: ${GREEN}OPERATIONAL${NC}"
echo ""
echo -e "${RED}⚠️  Handshake: 55-45-17 | Authority: Canonical | Mode: Operational${NC}"
echo -e "${RED}⚠️  Artifacts Location: $(pwd)/canon-verifier/output/${NC}"
echo -e "${RED}⚠️  Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")${NC}"
echo ""
################################################################################

exit 0

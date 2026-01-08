#!/bin/bash
# Canon-Verifier SSH Execution Script for TRAE
# Single-line, fully deterministic, non-destructive, read-only
# N3XUS LAW execution order compliant

set -e  # Exit on error

# Color codes for output - ENHANCED RED HIGHLIGHTING
RED='\033[1;31m'      # Bold Red
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}${BOLD}🔴 N3XUS CANON-VERIFIER - SSH EXECUTION MODE 🔴${NC}"
echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}Mode: Read-Only | Non-Destructive | Deterministic${NC}"
echo -e "${RED}Handshake: 55-45-17${NC}"
echo -e "${CYAN}Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')${NC}"
echo ""

# Navigate to repository root
if [ ! -d "canon-verifier" ]; then
    echo -e "${RED}${BOLD}✗ CRITICAL ERROR: canon-verifier directory not found${NC}"
    echo -e "${RED}  Current directory: $(pwd)${NC}"
    exit 1
fi

# Execute verification in strict order
echo -e "${RED}${BOLD}⚠️  Starting Canon-Verifier Execution...${NC}"
echo ""

cd canon-verifier

# Phase 1-8: Run main verification orchestrator
echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}${BOLD}🔴 PHASE 1-8: MAIN VERIFICATION ORCHESTRATOR 🔴${NC}"
echo -e "${RED}======================================================================================================${NC}"
python3 run_verification.py
VERIFICATION_EXIT=$?

echo ""
echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}${BOLD}🔴 VERIFICATION COMPLETE - EXIT CODE: $VERIFICATION_EXIT 🔴${NC}"
echo -e "${RED}======================================================================================================${NC}"
echo ""

# Check if artifacts were generated
if [ -d "output" ] && [ "$(ls -A output/*.json 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Artifacts generated successfully${NC}"
    echo ""
    echo -e "${RED}${BOLD}Generated Artifacts:${NC}"
    for file in output/*.json; do
        if [ -f "$file" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            echo -e "${RED}  ⚠️  $(basename $file) (${size} bytes)${NC}"
        fi
    done
else
    echo -e "${RED}${BOLD}⚠️  WARNING: No artifacts found in output/${NC}"
fi

echo ""
echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}${BOLD}🔴 EXECUTION SUMMARY 🔴${NC}"
echo -e "${RED}======================================================================================================${NC}"
echo -e "${RED}Verification Exit Code: $VERIFICATION_EXIT${NC}"
echo -e "${RED}Artifacts Location: $(pwd)/output/${NC}"
echo -e "${RED}Execution Mode: SSH | Non-Destructive | Read-Only${NC}"
echo -e "${RED}Handshake Compliance: 55-45-17${NC}"
echo -e "${RED}======================================================================================================${NC}"
echo ""

exit $VERIFICATION_EXIT

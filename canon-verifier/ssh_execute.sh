#!/bin/bash
# Canon-Verifier SSH Execution Script for TRAE
# Single-line, fully deterministic, non-destructive, read-only
# N3XUS LAW execution order compliant

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================================================================================"
echo "N3XUS CANON-VERIFIER - SSH EXECUTION MODE"
echo "======================================================================================================"
echo "Mode: Read-Only | Non-Destructive | Deterministic"
echo "Handshake: 55-45-17"
echo "Timestamp: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo ""

# Navigate to repository root
if [ ! -d "canon-verifier" ]; then
    echo -e "${RED}✗ Error: canon-verifier directory not found${NC}"
    echo "  Current directory: $(pwd)"
    exit 1
fi

# Execute verification in strict order
echo -e "${GREEN}Starting Canon-Verifier Execution...${NC}"
echo ""

cd canon-verifier

# Phase 1-8: Run main verification orchestrator
echo "======================================================================================================"
echo "PHASE 1-8: MAIN VERIFICATION ORCHESTRATOR"
echo "======================================================================================================"
python3 run_verification.py
VERIFICATION_EXIT=$?

echo ""
echo "======================================================================================================"
echo "VERIFICATION COMPLETE - EXIT CODE: $VERIFICATION_EXIT"
echo "======================================================================================================"
echo ""

# Check if artifacts were generated
if [ -d "output" ] && [ "$(ls -A output/*.json 2>/dev/null)" ]; then
    echo -e "${GREEN}✓ Artifacts generated successfully${NC}"
    echo ""
    echo "Generated Artifacts:"
    for file in output/*.json; do
        if [ -f "$file" ]; then
            size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
            echo "  ✓ $(basename $file) (${size} bytes)"
        fi
    done
else
    echo -e "${YELLOW}⚠ Warning: No artifacts found in output/${NC}"
fi

echo ""
echo "======================================================================================================"
echo "EXECUTION SUMMARY"
echo "======================================================================================================"
echo "Verification Exit Code: $VERIFICATION_EXIT"
echo "Artifacts Location: $(pwd)/output/"
echo "Execution Mode: SSH | Non-Destructive | Read-Only"
echo "Handshake Compliance: 55-45-17"
echo "======================================================================================================"
echo ""

exit $VERIFICATION_EXIT

#!/usr/bin/env bash

################################################################################
# TRAE Pre-Flight Check Script
# Validates environment before running canon-verification
################################################################################

set -e

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  TRAE PRE-FLIGHT CHECK - N3XUS COS Canon-Verification System                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")${NC}"
echo -e "${BLUE}Handshake: 55-45-17${NC}"
echo ""

################################################################################
# Check 1: Repository Structure
################################################################################
echo -e "${BLUE}[CHECK 1/10]${NC} Repository Structure"

if [ ! -d "canon-verifier" ]; then
    echo -e "${RED}  ✗ canon-verifier directory not found${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}  ✓ canon-verifier directory exists${NC}"
fi

if [ ! -d "branding/official" ]; then
    echo -e "${YELLOW}  ⚠ branding/official directory not found (will be created)${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}  ✓ branding/official directory exists${NC}"
fi

if [ ! -d "canon-verifier/config" ]; then
    echo -e "${YELLOW}  ⚠ canon-verifier/config directory not found (will be created)${NC}"
    ((WARNINGS++))
else
    echo -e "${GREEN}  ✓ canon-verifier/config directory exists${NC}"
fi

echo ""

################################################################################
# Check 2: Required Files
################################################################################
echo -e "${BLUE}[CHECK 2/10]${NC} Required Files"

REQUIRED_FILES=(
    "canon-verifier/trae_go_nogo.py"
    "canon-verifier/run_verification.py"
    "canon-verifier/trae_one_shot_launch.sh"
    "ecosystem.config.js"
    "docker-compose.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}  ✗ Missing: $file${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}  ✓ Found: $file${NC}"
    fi
done

echo ""

################################################################################
# Check 3: Python Environment
################################################################################
echo -e "${BLUE}[CHECK 3/10]${NC} Python Environment"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}  ✓ Python 3 installed: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}  ✗ Python 3 not found${NC}"
    ((ERRORS++))
fi

# Check Python 3 modules
if python3 -c "import json" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Python json module available${NC}"
else
    echo -e "${RED}  ✗ Python json module not found${NC}"
    ((ERRORS++))
fi

if python3 -c "import subprocess" 2>/dev/null; then
    echo -e "${GREEN}  ✓ Python subprocess module available${NC}"
else
    echo -e "${RED}  ✗ Python subprocess module not found${NC}"
    ((ERRORS++))
fi

echo ""

################################################################################
# Check 4: Required System Tools
################################################################################
echo -e "${BLUE}[CHECK 4/10]${NC} Required System Tools"

if command -v jq &> /dev/null; then
    JQ_VERSION=$(jq --version)
    echo -e "${GREEN}  ✓ jq installed: $JQ_VERSION${NC}"
else
    echo -e "${YELLOW}  ⚠ jq not found (needed for atomic deployment)${NC}"
    echo -e "${YELLOW}    Install: sudo apt-get install jq${NC}"
    ((WARNINGS++))
fi

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}  ✓ Docker installed: $DOCKER_VERSION${NC}"
else
    echo -e "${YELLOW}  ⚠ Docker not found (needed for service launch)${NC}"
    ((WARNINGS++))
fi

if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}  ✓ docker-compose installed: $COMPOSE_VERSION${NC}"
else
    echo -e "${YELLOW}  ⚠ docker-compose not found (needed for service launch)${NC}"
    ((WARNINGS++))
fi

if command -v pm2 &> /dev/null; then
    PM2_VERSION=$(pm2 --version)
    echo -e "${GREEN}  ✓ PM2 installed: $PM2_VERSION${NC}"
else
    echo -e "${YELLOW}  ⚠ PM2 not found (needed for service launch)${NC}"
    echo -e "${YELLOW}    Install: npm install -g pm2${NC}"
    ((WARNINGS++))
fi

echo ""

################################################################################
# Check 5: Canonical Logo
################################################################################
echo -e "${BLUE}[CHECK 5/10]${NC} Canonical Logo"

if [ -f "branding/official/N3XUS-vCOS.svg" ]; then
    LOGO_SIZE=$(stat -c%s "branding/official/N3XUS-vCOS.svg" 2>/dev/null || stat -f%z "branding/official/N3XUS-vCOS.svg" 2>/dev/null)
    echo -e "${GREEN}  ✓ Canonical logo exists: $LOGO_SIZE bytes${NC}"
    
    # Check size bounds
    if [ "$LOGO_SIZE" -lt 1024 ]; then
        echo -e "${RED}  ✗ Logo too small (< 1KB)${NC}"
        ((ERRORS++))
    elif [ "$LOGO_SIZE" -gt 10485760 ]; then
        echo -e "${RED}  ✗ Logo too large (> 10MB)${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}  ✓ Logo size valid${NC}"
    fi
else
    echo -e "${YELLOW}  ⚠ Canonical logo not found (can be added during deployment)${NC}"
    ((WARNINGS++))
fi

echo ""

################################################################################
# Check 6: Configuration File
################################################################################
echo -e "${BLUE}[CHECK 6/10]${NC} Configuration File"

if [ -f "canon-verifier/config/canon_assets.json" ]; then
    echo -e "${GREEN}  ✓ Configuration file exists${NC}"
    
    # Validate JSON
    if jq '.' canon-verifier/config/canon_assets.json > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Configuration file is valid JSON${NC}"
        
        # Check for required keys
        if jq -e '.OfficialLogo' canon-verifier/config/canon_assets.json > /dev/null 2>&1; then
            LOGO_PATH=$(jq -r '.OfficialLogo' canon-verifier/config/canon_assets.json)
            echo -e "${GREEN}  ✓ OfficialLogo configured: $LOGO_PATH${NC}"
        else
            echo -e "${YELLOW}  ⚠ OfficialLogo not configured${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}  ✗ Configuration file has invalid JSON${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}  ⚠ Configuration file not found (will be created)${NC}"
    ((WARNINGS++))
fi

echo ""

################################################################################
# Check 7: Verification Phase Modules
################################################################################
echo -e "${BLUE}[CHECK 7/10]${NC} Verification Phase Modules"

PHASE_MODULES=(
    "canon-verifier/inventory_phase/enumerate_services.py"
    "canon-verifier/responsibility_validation/validate_claims.py"
    "canon-verifier/dependency_tests/dependency_graph.py"
    "canon-verifier/event_orchestration/canonical_events.py"
    "canon-verifier/meta_claim_validation/identity_metatwin_chain.py"
    "canon-verifier/hardware_simulation/simulate_vhardware.py"
    "canon-verifier/performance_sanity/check_runtime_health.py"
    "canon-verifier/final_verdict/generate_verdict.py"
    "canon-verifier/ci_gatekeeper/gatekeeper.py"
    "canon-verifier/extensions/docker_pm2_mapping.py"
    "canon-verifier/extensions/service_responsibility_matrix.py"
)

MISSING_MODULES=0
for module in "${PHASE_MODULES[@]}"; do
    if [ ! -f "$module" ]; then
        echo -e "${RED}  ✗ Missing: $module${NC}"
        ((MISSING_MODULES++))
    fi
done

if [ $MISSING_MODULES -eq 0 ]; then
    echo -e "${GREEN}  ✓ All ${#PHASE_MODULES[@]} phase modules found${NC}"
else
    echo -e "${RED}  ✗ Missing $MISSING_MODULES phase modules${NC}"
    ((ERRORS++))
fi

echo ""

################################################################################
# Check 8: Output Directories
################################################################################
echo -e "${BLUE}[CHECK 8/10]${NC} Output Directories"

if [ ! -d "canon-verifier/output" ]; then
    echo -e "${YELLOW}  ⚠ Output directory not found (will be created)${NC}"
    if mkdir -p canon-verifier/output 2>/dev/null; then
        echo -e "${GREEN}  ✓ Output directory created${NC}"
    else
        echo -e "${RED}  ✗ Failed to create output directory${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${GREEN}  ✓ Output directory exists${NC}"
fi

if [ ! -d "canon-verifier/logs" ]; then
    echo -e "${YELLOW}  ⚠ Logs directory not found (will be created)${NC}"
    if mkdir -p canon-verifier/logs 2>/dev/null; then
        echo -e "${GREEN}  ✓ Logs directory created${NC}"
    else
        echo -e "${RED}  ✗ Failed to create logs directory${NC}"
        ((ERRORS++))
    fi
else
    echo -e "${GREEN}  ✓ Logs directory exists${NC}"
fi

echo ""

################################################################################
# Check 9: Permissions
################################################################################
echo -e "${BLUE}[CHECK 9/10]${NC} File Permissions"

if [ -x "canon-verifier/trae_one_shot_launch.sh" ]; then
    echo -e "${GREEN}  ✓ trae_one_shot_launch.sh is executable${NC}"
else
    echo -e "${YELLOW}  ⚠ trae_one_shot_launch.sh not executable (fixing...)${NC}"
    chmod +x canon-verifier/trae_one_shot_launch.sh
    echo -e "${GREEN}  ✓ Made executable${NC}"
fi

if [ -x "vps-canon-verification-example.sh" ]; then
    echo -e "${GREEN}  ✓ vps-canon-verification-example.sh is executable${NC}"
else
    if [ -f "vps-canon-verification-example.sh" ]; then
        echo -e "${YELLOW}  ⚠ vps-canon-verification-example.sh not executable (fixing...)${NC}"
        chmod +x vps-canon-verification-example.sh
        echo -e "${GREEN}  ✓ Made executable${NC}"
    fi
fi

echo ""

################################################################################
# Check 10: Quick Verification Test
################################################################################
echo -e "${BLUE}[CHECK 10/10]${NC} Quick Verification Test"

echo -e "${YELLOW}  → Testing trae_go_nogo.py execution...${NC}"
# Create secure temporary log file
TEMP_LOG=$(mktemp -t trae_test.XXXXXX.log 2>/dev/null || mktemp /tmp/trae_test.XXXXXX.log)
if python3 canon-verifier/trae_go_nogo.py > "$TEMP_LOG" 2>&1; then
    echo -e "${GREEN}  ✓ trae_go_nogo.py executed successfully${NC}"
    
    # Check for GO verdict
    if grep -q "overall_status.*GO" canon-verifier/logs/run_*/verification_report.json 2>/dev/null; then
        echo -e "${GREEN}  ✓ GO verdict issued${NC}"
    else
        echo -e "${YELLOW}  ⚠ Verification completed with warnings${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}  ✗ trae_go_nogo.py execution failed${NC}"
    echo -e "${RED}    Check logs: $TEMP_LOG${NC}"
    ((ERRORS++))
fi

# Clean up temporary log file
rm -f "$TEMP_LOG" 2>/dev/null

echo ""

################################################################################
# Final Summary
################################################################################
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PRE-FLIGHT CHECK SUMMARY                                                    ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ ✅ ✅  ALL CHECKS PASSED  ✅ ✅ ✅${NC}"
    echo ""
    echo -e "${GREEN}System is ready for canon-verification and deployment.${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "  1. Run quick verification: ${YELLOW}python3 canon-verifier/trae_go_nogo.py${NC}"
    echo -e "  2. OR run full launch: ${YELLOW}cd canon-verifier && ./trae_one_shot_launch.sh${NC}"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  CHECKS PASSED WITH WARNINGS  ⚠️${NC}"
    echo ""
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""
    echo -e "${YELLOW}System can proceed but some features may be limited.${NC}"
    echo -e "${YELLOW}Review warnings above and install missing tools if needed.${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "  1. Fix warnings (optional)"
    echo -e "  2. Run verification: ${YELLOW}python3 canon-verifier/trae_go_nogo.py${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}❌  CHECKS FAILED  ❌${NC}"
    echo ""
    echo -e "${RED}Errors: $ERRORS${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""
    echo -e "${RED}System is not ready. Fix errors above before proceeding.${NC}"
    echo ""
    exit 1
fi

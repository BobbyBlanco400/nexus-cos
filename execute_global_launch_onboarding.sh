#!/bin/bash
# Nexus COS — Global Launch & Onboarding PF — Quick Execution Script
# TRAE SOLO CODER — ONE-LINE DEPLOYMENT

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}   Nexus COS — Global Launch & Onboarding PF                    ${NC}"
echo -e "${BLUE}   Execution Mode: Overlay-Only                                  ${NC}"
echo -e "${BLUE}   Owner: Trae SOLO Coder                                        ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed${NC}"
    exit 1
fi

# Check if overlay file exists
if [ ! -f "nexus_global_launch_onboarding.yaml" ]; then
    echo -e "${RED}Error: nexus_global_launch_onboarding.yaml not found${NC}"
    exit 1
fi

# Check if deployment script exists
if [ ! -f "deploy_global_launch_onboarding_pf.py" ]; then
    echo -e "${RED}Error: deploy_global_launch_onboarding_pf.py not found${NC}"
    exit 1
fi

# Install PyYAML if not already installed
echo -e "${YELLOW}Checking dependencies...${NC}"
python3 -c "import yaml" 2>/dev/null || {
    echo -e "${YELLOW}Installing PyYAML...${NC}"
    pip3 install PyYAML --quiet || {
        echo -e "${RED}Error: Failed to install PyYAML${NC}"
        exit 1
    }
}

echo -e "${GREEN}✓ Dependencies checked${NC}"
echo ""

# Execute deployment with all verifications
echo -e "${BLUE}Starting deployment...${NC}"
echo ""

python3 deploy_global_launch_onboarding_pf.py \
  --overlay nexus_global_launch_onboarding.yaml \
  --verify_health \
  --verify_ui \
  --verify_wallet \
  --verify_ai_dealer \
  --verify_federation_nodes \
  --verify_dual_brand

# Check exit status
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}   ✓ DEPLOYMENT SUCCESSFUL                                      ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Logs written to:${NC}"
    echo -e "  - logs/global_launch/"
    echo -e "  - logs/onboarding_audit/"
    echo -e "  - logs/investor_demo/"
    echo -e "  - logs/compliance/"
    echo ""
    echo -e "${GREEN}View latest deployment summary:${NC}"
    echo -e "  cat logs/global_launch/deployment_summary_*.json | tail -1 | python3 -m json.tool"
    echo ""
else
    echo ""
    echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}   ✗ DEPLOYMENT FAILED                                          ${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Check logs for details:${NC}"
    echo -e "  tail -f logs/global_launch/deployment_*.log"
    echo ""
    exit 1
fi

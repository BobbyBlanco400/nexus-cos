#!/bin/bash

# ===================================================================
# NEXUS COS SUPER-COMMAND
# Pull, verify, test, and deploy Nexus COS stack
# One-command deployment with full orchestration
# ===================================================================
#
# Usage: bash deploy-nexus-cos-super-command.sh
#
# This script will:
# 1. Clone the repository to /tmp/nexus-cos
# 2. Run GitHub Code Agent orchestration
# 3. Generate compliance report
# 4. Deploy via TRAE with specified modules
# 5. Conduct post-deployment audit
# 6. Rollback on failure if needed
#
# ===================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REPO_URL="${REPO_URL:-https://github.com/YourOrg/nexus-cos-stack.git}"
TARGET_DIR="/tmp/nexus-cos"
CONFIG_FILE="nexus-cos-code-agent.yml"
MODULES="backend, frontend, apis, microservices, puabo-blac-financing, analytics, ott-pipelines"

# Print banner
print_banner() {
    echo -e "${PURPLE}"
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                            ║"
    echo "║                NEXUS COS SUPER-COMMAND DEPLOYMENT                          ║"
    echo "║            Pull, Verify, Test, and Deploy - One Command                    ║"
    echo "║                                                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Print step
print_step() {
    local step=$1
    local message=$2
    echo -e "${BLUE}[Step ${step}]${NC} ${CYAN}${message}${NC}"
    echo ""
}

# Main execution
main() {
    print_banner
    
    # Step 1: Clone repository
    print_step "1/5" "Cloning repository to ${TARGET_DIR}..."
    
    if [ -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}⚠️  Directory exists. Removing old version...${NC}"
        rm -rf "$TARGET_DIR"
    fi
    
    git clone "$REPO_URL" "$TARGET_DIR"
    cd "$TARGET_DIR"
    
    echo -e "${GREEN}✅ Repository cloned successfully${NC}"
    echo ""
    
    # Step 2: Run GitHub Code Agent orchestration
    print_step "2/5" "Running GitHub Code Agent orchestration..."
    
    # Make github-code-agent executable if it exists
    if [ -f "github-code-agent" ]; then
        chmod +x github-code-agent
    fi
    
    # Run the code agent
    ./github-code-agent --config "$CONFIG_FILE" --execute-all
    
    echo -e "${GREEN}✅ GitHub Code Agent completed${NC}"
    echo ""
    
    # Step 3: Verify compliance report
    print_step "3/5" "Verifying compliance report..."
    
    REPORT=$(ls reports/compliance_report_*.pdf 2>/dev/null | tail -n 1 || echo "")
    
    if [ -f "$REPORT" ]; then
        echo -e "${GREEN}✅ Compliance report found: ${REPORT}${NC}"
        echo ""
        
        # Display report summary if it's a text file or readable
        if file "$REPORT" | grep -q "text"; then
            echo -e "${CYAN}Compliance Report Summary:${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            grep -A 5 "EXECUTIVE SUMMARY" "$REPORT" 2>/dev/null || echo "Summary not available"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
        fi
    else
        echo -e "${RED}❌ Compliance report not found. Aborting deployment.${NC}"
        exit 1
    fi
    
    # Step 4: TRAE deployment
    print_step "4/5" "Proceeding with TRAE deployment..."
    
    # Make TRAE executable if it exists
    if [ -f "TRAE" ]; then
        chmod +x TRAE
    fi
    
    # Execute TRAE deployment
    ./TRAE deploy \
        --source github \
        --repo nexus-cos-stack \
        --branch verified_release \
        --verify-compliance "$REPORT" \
        --modules "$MODULES" \
        --post-deploy-audit \
        --rollback-on-fail
    
    echo -e "${GREEN}✅ TRAE deployment completed${NC}"
    echo ""
    
    # Step 5: Final summary
    print_step "5/5" "Deployment Summary"
    
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}║                  DEPLOYMENT COMPLETED SUCCESSFULLY                         ║${NC}"
    echo -e "${GREEN}║                                                                            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Summary:${NC}"
    echo "  • Repository: ${REPO_URL}"
    echo "  • Location: ${TARGET_DIR}"
    echo "  • Compliance Report: ${REPORT}"
    echo "  • Modules Deployed: ${MODULES}"
    echo "  • Deployment Log: ${TARGET_DIR}/trae-deployment.log"
    echo ""
    
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Review deployment logs in ${TARGET_DIR}/trae-deployment.log"
    echo "  2. Monitor service health at configured endpoints"
    echo "  3. Verify application functionality"
    echo ""
    
    echo -e "${GREEN}Deployment completed successfully! 🎉${NC}"
}

# Error handler
error_handler() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                                            ║${NC}"
    echo -e "${RED}║                      DEPLOYMENT FAILED                                     ║${NC}"
    echo -e "${RED}║                                                                            ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}An error occurred during deployment.${NC}"
    echo -e "${YELLOW}Please check the logs for more information.${NC}"
    echo ""
    exit 1
}

# Set error trap
trap error_handler ERR

# Run main
main

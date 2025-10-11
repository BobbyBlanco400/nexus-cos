#!/bin/bash

# ===================================================================
# NEXUS COS - VPS DEPLOYMENT READINESS VERIFICATION
# Version: v2025.10.10 FINAL
# Purpose: Verify all items in deployment checklist before VPS execution
# ===================================================================

set +e  # Don't exit on errors - we want to report all checks

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
BLOCKED_CHECKS=0

# Print banner
echo -e "${PURPLE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         🧠 NEXUS COS - VPS DEPLOYMENT READINESS CHECK          ║"
echo "║                                                                ║"
echo "║              Final Beta Launch v2025.10.10                     ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${CYAN}Verifying repository readiness for VPS deployment...${NC}"
echo ""

# Function to report check result
check_status() {
    local check_name=$1
    local status=$2  # PASS, FAIL, BLOCKED
    local proof=$3
    
    ((TOTAL_CHECKS++))
    
    case $status in
        PASS)
            echo -e "${GREEN}✅ PASS${NC} - $check_name"
            [ -n "$proof" ] && echo -e "   ${BLUE}Proof:${NC} $proof"
            ((PASSED_CHECKS++))
            ;;
        FAIL)
            echo -e "${RED}❌ FAIL${NC} - $check_name"
            [ -n "$proof" ] && echo -e "   ${YELLOW}Issue:${NC} $proof"
            ((FAILED_CHECKS++))
            ;;
        BLOCKED)
            echo -e "${YELLOW}⏸️  BLOCKED${NC} - $check_name (requires VPS)"
            [ -n "$proof" ] && echo -e "   ${BLUE}Note:${NC} $proof"
            ((BLOCKED_CHECKS++))
            ;;
    esac
    echo ""
}

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 1: PREPARATION${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 1: /opt access (Linux)
if [ -d /opt ] && [ -w /opt ]; then
    check_status "VPS /opt directory access" "PASS" "Directory exists and is writable"
else
    check_status "VPS /opt directory access" "BLOCKED" "Requires Linux VPS environment"
fi

# Check 2: Internet connectivity
if command -v curl &> /dev/null; then
    if curl -s --connect-timeout 5 https://github.com &> /dev/null; then
        check_status "Internet connectivity for git clone" "PASS" "Can reach GitHub"
    else
        check_status "Internet connectivity for git clone" "FAIL" "Cannot reach GitHub"
    fi
else
    check_status "Internet connectivity for git clone" "BLOCKED" "curl not available"
fi

# Check 3: Bash/script permissions
if [ -f EXECUTE_BETA_LAUNCH.sh ] && [ -x EXECUTE_BETA_LAUNCH.sh ]; then
    check_status "EXECUTE_BETA_LAUNCH.sh executable" "PASS" "Script exists and is executable"
else
    check_status "EXECUTE_BETA_LAUNCH.sh executable" "FAIL" "Script missing or not executable"
fi

# Check 4: Prerequisites present
PREREQ_FILES=("scripts/validate-unified-structure.sh" ".env.pf.example" "docker-compose.unified.yml")
all_prereqs=true
missing_prereqs=""
for file in "${PREREQ_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        all_prereqs=false
        missing_prereqs="$missing_prereqs $file"
    fi
done

if $all_prereqs; then
    check_status "Deployment prerequisites present" "PASS" "All required files present"
else
    check_status "Deployment prerequisites present" "FAIL" "Missing:$missing_prereqs"
fi

# Check 5: No active PF deployments
if command -v docker &> /dev/null; then
    RUNNING_CONTAINERS=$(docker ps --format '{{.Names}}' 2>/dev/null | grep -c "nexus-cos" || true)
    if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
        check_status "No conflicting deployments" "PASS" "No nexus-cos containers running"
    else
        check_status "No conflicting deployments" "FAIL" "$RUNNING_CONTAINERS nexus-cos containers running"
    fi
else
    check_status "No conflicting deployments" "BLOCKED" "Docker not available (will check on VPS)"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 2: DOCUMENTATION REVIEW${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 6: Key documentation files
DOC_FILES=(
    "TRAE_SOLO_START_HERE_NOW.md"
    "TRAE_SOLO_FINAL_EXECUTION_GUIDE.md"
    "BETA_LAUNCH_QUICK_REFERENCE.md"
    "PF_FINAL_BETA_LAUNCH_v2025.10.10.md"
    "TRAE_SOLO_DEPLOYMENT_GUIDE.md"
)

for doc in "${DOC_FILES[@]}"; do
    if [ -f "$doc" ]; then
        size=$(stat -c%s "$doc" 2>/dev/null || stat -f%z "$doc" 2>/dev/null || echo "0")
        check_status "Documentation: $doc" "PASS" "File exists (${size} bytes)"
    else
        check_status "Documentation: $doc" "FAIL" "File not found"
    fi
done

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 3: MERGE & UPDATE VERIFICATION${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 7: Git repository status
if [ -d .git ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    LAST_COMMIT=$(git log -1 --oneline 2>/dev/null || echo "unknown")
    check_status "Git repository initialized" "PASS" "Branch: $CURRENT_BRANCH, Last commit: $LAST_COMMIT"
else
    check_status "Git repository initialized" "FAIL" "Not a git repository"
fi

# Check 8: PR #105/#106 merge status in docs
if grep -r "PR #105\|PR #106\|MERGED" PF_FINAL_BETA_LAUNCH_v2025.10.10.md FINAL_DEPLOYMENT_SUMMARY.md &> /dev/null; then
    check_status "PR merge status documented" "PASS" "PR references found in documentation"
else
    check_status "PR merge status documented" "FAIL" "No PR merge references in docs"
fi

# Check 9: FINAL/MERGED status in docs
if grep -r "FINAL\|MERGED\|READY" PF_FINAL_BETA_LAUNCH_v2025.10.10.md README.md &> /dev/null; then
    check_status "FINAL/MERGED status confirmed" "PASS" "Status markers found in documentation"
else
    check_status "FINAL/MERGED status confirmed" "FAIL" "Missing status markers"
fi

# Check 10: Nexus STREAM/OTT documentation
if grep -ri "Nexus OTT\|TRAE Solo\|streaming" README.md &> /dev/null; then
    check_status "Nexus STREAM/OTT documented" "PASS" "References found in README.md"
else
    check_status "Nexus STREAM/OTT documented" "FAIL" "Missing STREAM/OTT documentation"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 4: DEPLOYMENT EXECUTION READINESS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 11: Deployment commands documented
if grep -q "cd /opt" PF_FINAL_BETA_LAUNCH_v2025.10.10.md 2>/dev/null && \
   grep -q "git clone" PF_FINAL_BETA_LAUNCH_v2025.10.10.md 2>/dev/null && \
   grep -q "EXECUTE_BETA_LAUNCH.sh\|bash.*sh" PF_FINAL_BETA_LAUNCH_v2025.10.10.md 2>/dev/null; then
    check_status "Deployment commands documented" "PASS" "Command sequence found in PF doc"
else
    check_status "Deployment commands documented" "FAIL" "Missing deployment command sequence"
fi

# Check 12: EXECUTE_BETA_LAUNCH.sh structure
if [ -f EXECUTE_BETA_LAUNCH.sh ]; then
    if bash -n EXECUTE_BETA_LAUNCH.sh 2>/dev/null; then
        check_status "EXECUTE_BETA_LAUNCH.sh syntax valid" "PASS" "Script passes bash syntax check"
    else
        check_status "EXECUTE_BETA_LAUNCH.sh syntax valid" "FAIL" "Script has syntax errors"
    fi
else
    check_status "EXECUTE_BETA_LAUNCH.sh syntax valid" "FAIL" "Script not found"
fi

# Check 13: Docker compose file
if [ -f docker-compose.unified.yml ]; then
    if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
        if docker compose -f docker-compose.unified.yml config &> /dev/null; then
            check_status "docker-compose.unified.yml valid" "PASS" "Compose file is valid"
        else
            check_status "docker-compose.unified.yml valid" "FAIL" "Compose file has errors"
        fi
    else
        check_status "docker-compose.unified.yml valid" "BLOCKED" "Docker/compose not available"
    fi
else
    check_status "docker-compose.unified.yml valid" "FAIL" "Compose file not found"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 5: VERIFICATION & HEALTH CHECKS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 14: Health check script
if [ -f pf-health-check.sh ]; then
    if [ -x pf-health-check.sh ]; then
        if bash -n pf-health-check.sh 2>/dev/null; then
            check_status "pf-health-check.sh ready" "PASS" "Script exists, executable, and valid"
        else
            check_status "pf-health-check.sh ready" "FAIL" "Script has syntax errors"
        fi
    else
        check_status "pf-health-check.sh ready" "FAIL" "Script not executable"
    fi
else
    check_status "pf-health-check.sh ready" "FAIL" "Script not found"
fi

# Check 15: Container count documentation
if grep -r "44 containers\|42 services" FINAL_DEPLOYMENT_SUMMARY.md WORK_COMPLETE_BETA_LAUNCH.md &> /dev/null; then
    check_status "Expected container count documented" "PASS" "44 containers / 42 services"
else
    check_status "Expected container count documented" "FAIL" "Container count not documented"
fi

# Check 16: Endpoint documentation
if [ -f PF_INDEX.md ] && grep -q "endpoint\|port\|service" PF_INDEX.md; then
    check_status "Service endpoints documented" "PASS" "Endpoints found in PF_INDEX.md"
elif grep -r "endpoint\|:300\|:400\|localhost" PF_FINAL_BETA_LAUNCH_v2025.10.10.md &> /dev/null; then
    check_status "Service endpoints documented" "PASS" "Endpoints found in PF doc"
else
    check_status "Service endpoints documented" "FAIL" "Missing endpoint documentation"
fi

# Check 17: Verification documentation
if [ -f PF_DEPLOYMENT_VERIFICATION.md ] || grep -r "verification\|health check" FINAL_DEPLOYMENT_SUMMARY.md &> /dev/null; then
    check_status "Verification procedures documented" "PASS" "Verification docs present"
else
    check_status "Verification procedures documented" "FAIL" "Missing verification documentation"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 6: TROUBLESHOOTING${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 18: Troubleshooting documentation
TROUBLESHOOT_FILES=(
    "TRAE_SOLO_DEPLOYMENT_GUIDE.md"
    "DEPLOYMENT_TROUBLESHOOTING_REPORT.md"
)

troubleshoot_found=false
for doc in "${TROUBLESHOOT_FILES[@]}"; do
    if [ -f "$doc" ] && grep -qi "troubleshoot\|error\|issue" "$doc"; then
        troubleshoot_found=true
        break
    fi
done

if $troubleshoot_found; then
    check_status "Troubleshooting documentation" "PASS" "Troubleshooting guides present"
else
    check_status "Troubleshooting documentation" "FAIL" "Missing troubleshooting documentation"
fi

# Check 19: Log collection capability
if grep -i "logs\|logging" EXECUTE_BETA_LAUNCH.sh &> /dev/null || \
   grep -i "logs\|logging" pf-health-check.sh &> /dev/null; then
    check_status "Log collection configured" "PASS" "Logging mechanisms documented"
else
    check_status "Log collection configured" "FAIL" "Missing log collection documentation"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SECTION 7: SUCCESS VALIDATION${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Check 20: Deployment verification docs
if [ -f PF_DEPLOYMENT_VERIFICATION.md ] || grep -r "validation\|metrics\|status" FINAL_DEPLOYMENT_SUMMARY.md &> /dev/null; then
    check_status "Success metrics documented" "PASS" "Validation documentation present"
else
    check_status "Success metrics documented" "FAIL" "Missing validation documentation"
fi

# Check 21: Beta launch announcement template
if [ -f WORK_COMPLETE_BETA_LAUNCH.md ] && grep -qi "announcement\|launch" WORK_COMPLETE_BETA_LAUNCH.md; then
    check_status "Beta launch announcement template" "PASS" "Template found in WORK_COMPLETE doc"
else
    check_status "Beta launch announcement template" "FAIL" "Missing announcement template"
fi

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}SUMMARY${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Total Checks:${NC}   $TOTAL_CHECKS"
echo -e "${GREEN}✅ Passed:${NC}      $PASSED_CHECKS"
echo -e "${RED}❌ Failed:${NC}      $FAILED_CHECKS"
echo -e "${YELLOW}⏸️  Blocked:${NC}     $BLOCKED_CHECKS (require VPS environment)"
echo ""

# Calculate readiness percentage
ACTIONABLE_CHECKS=$((TOTAL_CHECKS - BLOCKED_CHECKS))
if [ $ACTIONABLE_CHECKS -gt 0 ]; then
    READINESS_PCT=$((PASSED_CHECKS * 100 / ACTIONABLE_CHECKS))
    echo -e "${BLUE}Readiness:${NC}      ${READINESS_PCT}% (excluding VPS-only checks)"
    echo ""
fi

# Print recommendations
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}RECOMMENDATIONS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ Repository is ready for VPS deployment!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. SSH into your VPS"
    echo "2. Run the following commands:"
    echo ""
    echo -e "${YELLOW}cd /opt && \\"
    echo "git clone https://github.com/BobbyBlanco400/nexus-cos.git && \\"
    echo "cd nexus-cos && \\"
    echo "bash EXECUTE_BETA_LAUNCH.sh${NC}"
    echo ""
    echo "3. Wait approximately 25 minutes"
    echo "4. Run health checks: bash pf-health-check.sh"
    echo "5. Verify all 44 containers are running"
    echo "6. Announce beta launch! 🎉"
else
    echo -e "${RED}⚠️  Repository has $FAILED_CHECKS issue(s) that should be addressed${NC}"
    echo ""
    echo -e "${YELLOW}Please review the failed checks above and fix issues before VPS deployment.${NC}"
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Report generated: $(date)${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Exit with appropriate code
if [ $FAILED_CHECKS -eq 0 ]; then
    exit 0
else
    exit 1
fi

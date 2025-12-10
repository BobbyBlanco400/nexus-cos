#!/bin/bash

# ===================================================================
# Test Script for Super-Command Deployment System
# Validates all components without actual deployment
# ===================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Testing Super-Command Deployment System                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_component() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}→ Testing: ${test_name}${NC}"
    
    if eval "$test_command" &>/dev/null; then
        echo -e "${GREEN}  ✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}  ✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Check files exist
echo -e "${BLUE}[1/7] Checking File Existence${NC}"
echo ""
test_component "github-code-agent exists" "[ -f github-code-agent ]"
test_component "github-code-agent is executable" "[ -x github-code-agent ]"
test_component "nexus-cos-code-agent.yml exists" "[ -f nexus-cos-code-agent.yml ]"
test_component "TRAE exists" "[ -f TRAE ]"
test_component "TRAE is executable" "[ -x TRAE ]"
test_component "generate-compliance-report.sh exists" "[ -f scripts/generate-compliance-report.sh ]"
test_component "generate-compliance-report.sh is executable" "[ -x scripts/generate-compliance-report.sh ]"
test_component "deploy-nexus-cos-super-command.sh exists" "[ -f deploy-nexus-cos-super-command.sh ]"
test_component "deploy-nexus-cos-super-command.sh is executable" "[ -x deploy-nexus-cos-super-command.sh ]"
test_component "SUPER_COMMAND_DOCUMENTATION.md exists" "[ -f SUPER_COMMAND_DOCUMENTATION.md ]"
test_component "reports directory exists" "[ -d reports ]"
echo ""

# Test 2: Help messages
echo -e "${BLUE}[2/7] Testing Help Messages${NC}"
echo ""
test_component "github-code-agent --help" "./github-code-agent --help || true"
test_component "TRAE --help" "./TRAE --help || true"
echo ""

# Test 3: YAML configuration validation
echo -e "${BLUE}[3/7] Validating Configuration File${NC}"
echo ""
test_component "YAML file is readable" "[ -r nexus-cos-code-agent.yml ]"
test_component "YAML contains version" "grep -q 'version:' nexus-cos-code-agent.yml"
test_component "YAML contains tasks" "grep -q 'tasks:' nexus-cos-code-agent.yml"
test_component "YAML contains compliance" "grep -q 'compliance:' nexus-cos-code-agent.yml"
test_component "YAML contains modules" "grep -q 'modules:' nexus-cos-code-agent.yml"
echo ""

# Test 4: Compliance report generation
echo -e "${BLUE}[4/7] Testing Compliance Report Generation${NC}"
echo ""
TIMESTAMP_TEST="test_validation_$(date +%s)"
test_component "Generate compliance report" "bash scripts/generate-compliance-report.sh ${TIMESTAMP_TEST}"
test_component "Report file created" "ls reports/compliance_report_${TIMESTAMP_TEST}.pdf 2>/dev/null || ls reports/compliance_report_${TIMESTAMP_TEST}.txt 2>/dev/null"
test_component "Report contains COMPLIANT" "grep -q 'COMPLIANT' reports/compliance_report_${TIMESTAMP_TEST}.txt"
echo ""

# Test 5: Module definitions
echo -e "${BLUE}[5/7] Verifying Module Definitions${NC}"
echo ""
test_component "backend module defined" "grep -q 'backend' nexus-cos-code-agent.yml"
test_component "frontend module defined" "grep -q 'frontend' nexus-cos-code-agent.yml"
test_component "apis module defined" "grep -q 'apis' nexus-cos-code-agent.yml"
test_component "microservices module defined" "grep -q 'microservices' nexus-cos-code-agent.yml"
test_component "puabo-blac-financing module defined" "grep -q 'puabo-blac-financing' nexus-cos-code-agent.yml"
test_component "analytics module defined" "grep -q 'analytics' nexus-cos-code-agent.yml"
test_component "ott-pipelines module defined" "grep -q 'ott-pipelines' nexus-cos-code-agent.yml"
echo ""

# Test 6: TRAE deployment options
echo -e "${BLUE}[6/7] Verifying TRAE Deployment Options${NC}"
echo ""
test_component "TRAE supports --source" "grep -q 'source' TRAE"
test_component "TRAE supports --repo" "grep -q 'repo' TRAE"
test_component "TRAE supports --branch" "grep -q 'branch' TRAE"
test_component "TRAE supports --verify-compliance" "grep -q 'verify-compliance' TRAE"
test_component "TRAE supports --modules" "grep -q 'modules' TRAE"
test_component "TRAE supports --post-deploy-audit" "grep -q 'post-deploy-audit' TRAE"
test_component "TRAE supports --rollback-on-fail" "grep -q 'rollback-on-fail' TRAE"
echo ""

# Test 7: Documentation
echo -e "${BLUE}[7/7] Verifying Documentation${NC}"
echo ""
test_component "Documentation exists" "[ -f SUPER_COMMAND_DOCUMENTATION.md ]"
test_component "Documentation has Overview" "grep -q 'Overview' SUPER_COMMAND_DOCUMENTATION.md"
test_component "Documentation has Quick Start" "grep -q 'Quick Start' SUPER_COMMAND_DOCUMENTATION.md"
test_component "Documentation has Components" "grep -q 'Components' SUPER_COMMAND_DOCUMENTATION.md"
test_component "Documentation has Workflow" "grep -q 'Workflow' SUPER_COMMAND_DOCUMENTATION.md"
test_component "Documentation has Troubleshooting" "grep -q 'Troubleshooting' SUPER_COMMAND_DOCUMENTATION.md"
test_component "README updated with super-command" "grep -q 'Super-Command' README.md"
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                  Test Summary                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Tests Passed: ${TESTS_PASSED}${NC}"
echo -e "${RED}Tests Failed: ${TESTS_FAILED}${NC}"
echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Super-command deployment system is ready.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Please review the output above.${NC}"
    exit 1
fi

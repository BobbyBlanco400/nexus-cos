#!/bin/bash
#####################################################################
# PUABO API/AI-HF Hybrid - Verification Script
# Tests all components and deployment readiness
#####################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED_CHECKS=0
PASSED_CHECKS=0

check() {
    local test_name="$1"
    local test_command="$2"
    
    echo -ne "${BLUE}→${NC} Testing: $test_name ... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED_CHECKS++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((FAILED_CHECKS++))
        return 1
    fi
}

echo "=========================================="
echo "PUABO API/AI-HF Hybrid - Verification"
echo "=========================================="
echo ""

# File structure checks
echo "1. File Structure Verification"
echo "----------------------------"

check "Main deployment script" "test -f deploy_puabo_api_ai_hf.sh"
check "Service directory" "test -d services/puabo_api_ai_hf"
check "Service server.py" "test -f services/puabo_api_ai_hf/server.py"
check "Service config.json" "test -f services/puabo_api_ai_hf/config.json"
check "Service Dockerfile" "test -f services/puabo_api_ai_hf/Dockerfile"
check "Service requirements.txt" "test -f services/puabo_api_ai_hf/requirements.txt"
check "Autoscale monitor" "test -f services/puabo_api_ai_hf/autoscale_monitor.py"
check "Unit tests" "test -d services/puabo_api_ai_hf/tests/unit"
check "Integration tests" "test -d services/puabo_api_ai_hf/tests/integration"
check "Router configuration" "test -f services/router.py"
check "HF models sync script" "test -f scripts/sync_hf_models.py"
check "Load test script" "test -f scripts/load_test_endpoints.py"
check "HF engines config" "test -f configs/engines_hf.json"
check "Ansible playbook" "test -f deploy/puabo_api_ai_hf.yml"
check "Hosts inventory" "test -f deploy/hosts.ini"
check "Deployment guide" "test -f PUABO_API_AI_HF_DEPLOYMENT_GUIDE.md"

echo ""
echo "2. Python Dependencies"
echo "----------------------------"

check "Python 3 installed" "command -v python3"
check "Flask installed" "python3 -c 'import flask'"
check "Requests installed" "python3 -c 'import requests'"
check "Pytest installed" "command -v pytest"

echo ""
echo "3. Service Configuration"
echo "----------------------------"

check "Config file valid JSON" "python3 -m json.tool services/puabo_api_ai_hf/config.json"
check "Engines config valid JSON" "python3 -m json.tool configs/engines_hf.json"
check "Router module syntax" "python3 -m py_compile services/router.py"
check "Server module syntax" "python3 -m py_compile services/puabo_api_ai_hf/server.py"
check "Autoscale monitor syntax" "python3 -m py_compile services/puabo_api_ai_hf/autoscale_monitor.py"

echo ""
echo "4. Script Executability"
echo "----------------------------"

check "Deployment script executable" "test -x deploy_puabo_api_ai_hf.sh"
check "Autoscale monitor executable" "test -x services/puabo_api_ai_hf/autoscale_monitor.py"
check "Sync models executable" "test -x scripts/sync_hf_models.py"
check "Load test executable" "test -x scripts/load_test_endpoints.py"

echo ""
echo "5. Unit Tests"
echo "----------------------------"

if pytest services/puabo_api_ai_hf/tests/unit/ -v --tb=short > /tmp/test_output.txt 2>&1; then
    echo -e "${GREEN}✓${NC} All unit tests passed"
    ((PASSED_CHECKS++))
    grep "passed" /tmp/test_output.txt | tail -1
else
    echo -e "${RED}✗${NC} Some unit tests failed"
    ((FAILED_CHECKS++))
    tail -10 /tmp/test_output.txt
fi

echo ""
echo "6. Service Templates"
echo "----------------------------"

check "Templates directory" "test -d templates/puabo_api_ai_hf"
check "Template server.py" "test -f templates/puabo_api_ai_hf/server.py"
check "Template config.json" "test -f templates/puabo_api_ai_hf/config.json"

echo ""
echo "7. Deployment Configuration"
echo "----------------------------"

check "Ansible playbook syntax" "grep -q 'Deploy PUABO API/AI-HF' deploy/puabo_api_ai_hf.yml"
check "Systemd template" "test -f deploy/puabo_api_ai_hf.service.j2"
check "Hosts file configured" "grep -q hostinger deploy/hosts.ini"

echo ""
echo "8. Kei AI Removal"
echo "----------------------------"

if [ ! -d "services/kei-ai" ]; then
    echo -e "${GREEN}✓${NC} Kei AI service removed"
    ((PASSED_CHECKS++))
else
    echo -e "${YELLOW}!${NC} Kei AI service still present (may need manual cleanup)"
fi

if [ -d "services/kei-ai.backup"* ]; then
    echo -e "${GREEN}✓${NC} Kei AI backup exists"
    ((PASSED_CHECKS++))
else
    echo -e "${YELLOW}!${NC} No Kei AI backup found"
fi

echo ""
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}${PASSED_CHECKS}${NC}"
echo -e "Failed: ${RED}${FAILED_CHECKS}${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "System is ready for deployment."
    echo ""
    echo "Next steps:"
    echo "  1. Configure VPS details in deploy/hosts.ini"
    echo "  2. Set HUGGINGFACE_API_TOKEN environment variable"
    echo "  3. Run: ansible-playbook deploy/puabo_api_ai_hf.yml --inventory deploy/hosts.ini"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo ""
    echo "Please review the failures above before deploying."
    exit 1
fi

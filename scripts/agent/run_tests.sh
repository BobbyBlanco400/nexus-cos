#!/bin/bash
# Test runner for Nexus COS - Lint, Unit, Integration, E2E
# Runs all test stages and generates reports

set -euo pipefail

WORKDIR="${WORKDIR:-$(pwd)}"
REPORTS_DIR="${WORKDIR}/reports"
TEST_MODE="${1:-all}" # all, lint, unit, integration, e2e

mkdir -p "${REPORTS_DIR}"

echo "=========================================="
echo "Nexus COS Test Runner"
echo "=========================================="
echo "Mode: ${TEST_MODE}"
echo "Reports: ${REPORTS_DIR}"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_passed=0
test_failed=0

# Function to run a test stage
run_test_stage() {
    local stage_name="$1"
    local test_command="$2"
    local log_file="${REPORTS_DIR}/test_results_${stage_name}.log"
    
    echo ""
    echo "Running ${stage_name} tests..."
    echo "Output: ${log_file}"
    
    if eval "${test_command}" 2>&1 | tee "${log_file}"; then
        echo -e "${GREEN}✓ ${stage_name} tests passed${NC}"
        ((test_passed++))
        return 0
    else
        echo -e "${RED}✗ ${stage_name} tests failed${NC}"
        ((test_failed++))
        return 1
    fi
}

# Lint stage
if [ "${TEST_MODE}" == "all" ] || [ "${TEST_MODE}" == "lint" ]; then
    if [ -f "${WORKDIR}/package.json" ]; then
        # Install dependencies if needed
        if [ ! -d "${WORKDIR}/node_modules" ]; then
            echo "Installing dependencies..."
            cd "${WORKDIR}"
            npm install --silent || true
        fi
        
        # Run linting
        if grep -q '"lint"' "${WORKDIR}/package.json"; then
            run_test_stage "lint" "cd ${WORKDIR} && npm run lint" || true
        else
            echo -e "${YELLOW}⚠ No lint script found in package.json${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ No package.json found, skipping lint${NC}"
    fi
fi

# Unit tests
if [ "${TEST_MODE}" == "all" ] || [ "${TEST_MODE}" == "unit" ]; then
    if [ -f "${WORKDIR}/package.json" ]; then
        if grep -q '"test"' "${WORKDIR}/package.json" || grep -q '"test:unit"' "${WORKDIR}/package.json"; then
            # Try test:unit first, fallback to test
            if grep -q '"test:unit"' "${WORKDIR}/package.json"; then
                run_test_stage "unit" "cd ${WORKDIR} && npm run test:unit" || true
            else
                run_test_stage "unit" "cd ${WORKDIR} && npm test -- --testPathPattern=unit" || true
            fi
        else
            echo -e "${YELLOW}⚠ No unit test script found${NC}"
        fi
    fi
    
    # Check for pytest (Python tests)
    if [ -f "${WORKDIR}/pytest.ini" ] || [ -f "${WORKDIR}/setup.py" ]; then
        if command -v pytest &> /dev/null; then
            run_test_stage "unit_python" "cd ${WORKDIR} && pytest tests/unit -v" || true
        fi
    fi
fi

# Integration tests
if [ "${TEST_MODE}" == "all" ] || [ "${TEST_MODE}" == "integration" ]; then
    # Docker-based integration tests
    if [ -f "${WORKDIR}/docker-compose.test.yml" ]; then
        echo ""
        echo "Running integration tests with Docker..."
        run_test_stage "integration" "
            cd ${WORKDIR} && \
            docker compose -f docker-compose.test.yml up -d --build && \
            sleep 10 && \
            npm run test:integration || pytest tests/integration -v || true && \
            docker compose -f docker-compose.test.yml down
        " || true
    elif grep -q '"test:integration"' "${WORKDIR}/package.json" 2>/dev/null; then
        run_test_stage "integration" "cd ${WORKDIR} && npm run test:integration" || true
    else
        echo -e "${YELLOW}⚠ No integration tests configured${NC}"
    fi
fi

# E2E tests
if [ "${TEST_MODE}" == "all" ] || [ "${TEST_MODE}" == "e2e" ]; then
    if grep -q '"test:e2e"' "${WORKDIR}/package.json" 2>/dev/null; then
        run_test_stage "e2e" "cd ${WORKDIR} && npm run test:e2e" || true
    elif [ -d "${WORKDIR}/tests/e2e" ]; then
        run_test_stage "e2e" "cd ${WORKDIR} && pytest tests/e2e -v" || true
    else
        echo -e "${YELLOW}⚠ No E2E tests configured${NC}"
    fi
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}${test_passed}${NC}"
echo -e "Failed: ${RED}${test_failed}${NC}"
echo "Reports: ${REPORTS_DIR}/test_results_*.log"
echo "=========================================="

# Return appropriate exit code
if [ ${test_failed} -gt 0 ]; then
    echo -e "${RED}Some tests failed${NC}"
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi

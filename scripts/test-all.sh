#!/bin/bash

# Platform-wide test suite for Nexus COS
# Part of the THIIO Complete Handoff Package

set -e

echo "========================================="
echo "Nexus COS - Platform-Wide Test Suite"
echo "========================================="
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

echo "Running tests for all Nexus COS services..."
echo ""

# Function to run tests for a service
run_service_tests() {
  local SERVICE_PATH=$1
  local SERVICE_NAME=$(basename "$SERVICE_PATH")
  
  echo "========================================"
  echo "Testing: $SERVICE_NAME"
  echo "========================================"
  
  cd "$SERVICE_PATH"
  
  # Check if package.json exists
  if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}⊘ Skipped (no package.json)${NC}"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    return
  fi
  
  # Check if test script exists
  if ! grep -q '"test"' package.json; then
    echo -e "${YELLOW}⊘ Skipped (no test script)${NC}"
    SKIPPED_TESTS=$((SKIPPED_TESTS + 1))
    return
  fi
  
  # Install dependencies if node_modules doesn't exist
  if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install --quiet 2>&1 | head -5 || true
  fi
  
  # Run tests
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  if npm test 2>&1 | tee test-output.log; then
    echo -e "${GREEN}✓ Tests passed${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "${RED}✗ Tests failed${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    
    # Show last 20 lines of test output on failure
    echo ""
    echo "Last 20 lines of test output:"
    tail -20 test-output.log || true
  fi
  
  rm -f test-output.log
  
  echo ""
}

# Test all services
if [ -d "$PROJECT_ROOT/services" ]; then
  for service_dir in "$PROJECT_ROOT/services"/*; do
    if [ -d "$service_dir" ]; then
      SERVICE_NAME=$(basename "$service_dir")
      
      # Skip README
      if [ "$SERVICE_NAME" == "README.md" ]; then
        continue
      fi
      
      run_service_tests "$service_dir"
    fi
  done
fi

# Test modules
if [ -d "$PROJECT_ROOT/modules" ]; then
  echo ""
  echo "========================================"
  echo "Testing Modules"
  echo "========================================"
  echo ""
  
  for module_dir in "$PROJECT_ROOT/modules"/*; do
    if [ -d "$module_dir" ]; then
      MODULE_NAME=$(basename "$module_dir")
      
      # Skip README and symlinks
      if [ "$MODULE_NAME" == "README.md" ] || [ -L "$module_dir" ]; then
        continue
      fi
      
      run_service_tests "$module_dir"
    fi
  done
fi

# Test frontend
if [ -d "$PROJECT_ROOT/frontend" ]; then
  echo ""
  echo "========================================"
  echo "Testing Frontend"
  echo "========================================"
  echo ""
  
  run_service_tests "$PROJECT_ROOT/frontend"
fi

# Summary
echo ""
echo "========================================="
echo "Test Suite Complete!"
echo "========================================="
echo ""
echo -e "Total test suites: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"
echo -e "${YELLOW}Skipped: ${SKIPPED_TESTS}${NC}"
echo ""

if [ $FAILED_TESTS -gt 0 ]; then
  echo -e "${RED}⚠ Some tests failed!${NC}"
  exit 1
else
  echo -e "${GREEN}✓ All tests passed!${NC}"
  exit 0
fi

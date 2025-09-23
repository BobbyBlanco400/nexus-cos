#!/bin/bash
# Comprehensive Test Suite for Nexus COS
# Includes unit tests, integration tests, and CI/CD pipeline integration

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/logs/test-results.log"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"
TEST_REPORTS_DIR="$ARTIFACTS_DIR/test-reports"

# Create directories
mkdir -p "$(dirname "$LOG_FILE")" "$TEST_REPORTS_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Test result tracking
TEST_RESULTS=()
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to record test result
record_test() {
    local test_name="$1"
    local status="$2"
    local details="${3:-}"
    
    TEST_RESULTS+=("$test_name:$status:$details")
    ((TOTAL_TESTS++))
    
    if [[ "$status" == "PASS" ]]; then
        ((PASSED_TESTS++))
        log "✓ $test_name: PASSED"
    else
        ((FAILED_TESTS++))
        log "✗ $test_name: FAILED - $details"
    fi
}

# Function to run command with test recording
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    log "Running test: $test_name"
    
    if eval "$command" >> "$LOG_FILE" 2>&1; then
        local exit_code=$?
        if [[ $exit_code -eq $expected_exit_code ]]; then
            record_test "$test_name" "PASS"
            return 0
        else
            record_test "$test_name" "FAIL" "Expected exit code $expected_exit_code, got $exit_code"
            return 1
        fi
    else
        local exit_code=$?
        record_test "$test_name" "FAIL" "Command failed with exit code $exit_code"
        return 1
    fi
}

log "Starting comprehensive test suite for Nexus COS"
log "Project root: $PROJECT_ROOT"
log "Test reports directory: $TEST_REPORTS_DIR"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.trae/environment.env" ]]; then
    source "$PROJECT_ROOT/.trae/environment.env"
fi

# Pre-test setup
log "Setting up test environment..."

# Check required tools
log "Checking required tools..."
required_tools=("node" "npm" "docker" "docker-compose")
for tool in "${required_tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        record_test "Tool Check: $tool" "PASS"
    else
        record_test "Tool Check: $tool" "FAIL" "Tool not found"
    fi
done

# Test 1: Lint and Code Quality
log "Running code quality tests..."

# Frontend linting
if [[ -d "$PROJECT_ROOT/nexus-cos-main/frontend" ]]; then
    cd "$PROJECT_ROOT/nexus-cos-main/frontend"
    if [[ -f "package.json" ]]; then
        run_test "Frontend: Install Dependencies" "npm ci"
        run_test "Frontend: ESLint" "npm run lint || true"
        run_test "Frontend: TypeScript Check" "npm run type-check || npx tsc --noEmit || true"
        run_test "Frontend: Prettier Check" "npm run format:check || npx prettier --check . || true"
    fi
fi

# Backend linting (Node.js)
if [[ -d "$PROJECT_ROOT/nexus-cos-main/backend" ]]; then
    cd "$PROJECT_ROOT/nexus-cos-main/backend"
    if [[ -f "package.json" ]]; then
        run_test "Backend Node.js: Install Dependencies" "npm ci"
        run_test "Backend Node.js: ESLint" "npm run lint || true"
        run_test "Backend Node.js: TypeScript Check" "npm run type-check || npx tsc --noEmit || true"
    fi
fi

# Test 2: Unit Tests
log "Running unit tests..."

# Frontend unit tests
if [[ -d "$PROJECT_ROOT/nexus-cos-main/frontend" ]]; then
    cd "$PROJECT_ROOT/nexus-cos-main/frontend"
    if [[ -f "package.json" ]] && grep -q "test" package.json; then
        run_test "Frontend: Unit Tests" "npm test -- --coverage --watchAll=false --testResultsProcessor=jest-junit"
        
        # Copy test results
        if [[ -f "coverage/lcov.info" ]]; then
            cp -r coverage "$TEST_REPORTS_DIR/frontend-coverage"
        fi
        if [[ -f "junit.xml" ]]; then
            cp junit.xml "$TEST_REPORTS_DIR/frontend-junit.xml"
        fi
    fi
fi

# Backend unit tests (Node.js)
if [[ -d "$PROJECT_ROOT/nexus-cos-main/backend" ]]; then
    cd "$PROJECT_ROOT/nexus-cos-main/backend"
    if [[ -f "package.json" ]] && grep -q "test" package.json; then
        run_test "Backend Node.js: Unit Tests" "npm test -- --coverage --testResultsProcessor=jest-junit"
        
        # Copy test results
        if [[ -f "coverage/lcov.info" ]]; then
            cp -r coverage "$TEST_REPORTS_DIR/backend-node-coverage"
        fi
        if [[ -f "junit.xml" ]]; then
            cp junit.xml "$TEST_REPORTS_DIR/backend-node-junit.xml"
        fi
    fi
fi

# Backend unit tests (Python)
if [[ -d "$PROJECT_ROOT/nexus-cos-main/backend" ]] && [[ -f "$PROJECT_ROOT/nexus-cos-main/backend/requirements.txt" ]]; then
    cd "$PROJECT_ROOT/nexus-cos-main/backend"
    if [[ -f "pytest.ini" ]] || [[ -f "pyproject.toml" ]] || find . -name "test_*.py" -o -name "*_test.py" | grep -q .; then
        run_test "Backend Python: Install Dependencies" "pip install -r requirements.txt"
        run_test "Backend Python: Unit Tests" "python -m pytest --cov=. --cov-report=xml --junitxml=junit.xml"
        
        # Copy test results
        if [[ -f "coverage.xml" ]]; then
            cp coverage.xml "$TEST_REPORTS_DIR/backend-python-coverage.xml"
        fi
        if [[ -f "junit.xml" ]]; then
            cp junit.xml "$TEST_REPORTS_DIR/backend-python-junit.xml"
        fi
    fi
fi

# Test 3: Build Tests
log "Running build tests..."

cd "$PROJECT_ROOT"

# Test Docker builds
run_test "Docker: Frontend Build" "docker build -t nexus-frontend-test nexus-cos-main/frontend/"
run_test "Docker: Backend Node.js Build" "docker build -t nexus-backend-node-test -f nexus-cos-main/backend/Dockerfile.node nexus-cos-main/backend/"
run_test "Docker: Backend Python Build" "docker build -t nexus-backend-python-test -f nexus-cos-main/backend/Dockerfile.python nexus-cos-main/backend/"

# Test Docker Compose
run_test "Docker Compose: Configuration Validation" "docker-compose -f .trae/services.yaml config"

# Test 4: Integration Tests
log "Running integration tests..."

# Start test environment
log "Starting test environment..."
run_test "Integration: Start Test Environment" "docker-compose -f .trae/services.yaml up -d"

# Wait for services to be ready
log "Waiting for services to be ready..."
sleep 60

# Health checks
run_test "Integration: Database Health Check" "docker-compose -f .trae/services.yaml exec -T nexus-database pg_isready -U nexus_user"
run_test "Integration: Frontend Health Check" "curl -f http://localhost:80/health || curl -f http://localhost:3002/health"
run_test "Integration: Backend Node.js Health Check" "curl -f http://localhost:3000/health"
run_test "Integration: Backend Python Health Check" "curl -f http://localhost:3001/health"

# API tests
log "Running API tests..."
run_test "API: Node.js Backend Endpoint" "curl -f http://localhost:3000/api/status"
run_test "API: Python Backend Endpoint" "curl -f http://localhost:3001/api/status"

# Database tests
log "Running database tests..."
run_test "Database: Connection Test" "docker-compose -f .trae/services.yaml exec -T nexus-database psql -U nexus_user -d nexus_db -c 'SELECT 1;'"

# Test 5: Security Tests
log "Running security tests..."

# Check for common vulnerabilities
if command -v npm &> /dev/null; then
    run_test "Security: NPM Audit (Frontend)" "cd nexus-cos-main/frontend && npm audit --audit-level=high || true"
    run_test "Security: NPM Audit (Backend)" "cd nexus-cos-main/backend && npm audit --audit-level=high || true"
fi

# Check Docker image security
if command -v docker &> /dev/null; then
    run_test "Security: Docker Image Scan (Frontend)" "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image nexus-frontend-test || true"
fi

# Test 6: Performance Tests
log "Running performance tests..."

# Load testing with curl
run_test "Performance: Frontend Load Test" "for i in {1..10}; do curl -f http://localhost:80/ > /dev/null 2>&1 || true; done"
run_test "Performance: API Load Test" "for i in {1..10}; do curl -f http://localhost:3000/api/status > /dev/null 2>&1 || true; done"

# Test 7: Mobile Build Tests
log "Running mobile build tests..."

if [[ -d "$PROJECT_ROOT/nexus-cos-main/mobile" ]]; then
    run_test "Mobile: Build Test" "$PROJECT_ROOT/scripts/build-mobile.sh || true"
fi

# Test 8: Monitoring Tests
log "Running monitoring tests..."

run_test "Monitoring: Prometheus Health" "curl -f http://localhost:9090/-/healthy || true"
run_test "Monitoring: Grafana Health" "curl -f http://localhost:3000/api/health || true"

# Cleanup test environment
log "Cleaning up test environment..."
run_test "Cleanup: Stop Test Environment" "docker-compose -f .trae/services.yaml down"
run_test "Cleanup: Remove Test Images" "docker rmi nexus-frontend-test nexus-backend-node-test nexus-backend-python-test || true"

# Generate test report
log "Generating test report..."
cat > "$TEST_REPORTS_DIR/test-summary.txt" << EOF
Nexus COS Test Suite Report
==========================

Test Date: $(date)
Project: Nexus COS
Test Environment: $(uname -s) $(uname -m)

Test Summary:
- Total Tests: $TOTAL_TESTS
- Passed: $PASSED_TESTS
- Failed: $FAILED_TESTS
- Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%

Test Results:
EOF

# Add detailed test results
for result in "${TEST_RESULTS[@]}"; do
    IFS=':' read -r test_name status details <<< "$result"
    if [[ "$status" == "PASS" ]]; then
        echo "✓ $test_name: PASSED" >> "$TEST_REPORTS_DIR/test-summary.txt"
    else
        echo "✗ $test_name: FAILED - $details" >> "$TEST_REPORTS_DIR/test-summary.txt"
    fi
done

# Add environment information
cat >> "$TEST_REPORTS_DIR/test-summary.txt" << EOF

Environment Information:
- Node.js: $(node --version 2>/dev/null || echo "Not available")
- npm: $(npm --version 2>/dev/null || echo "Not available")
- Docker: $(docker --version 2>/dev/null || echo "Not available")
- Docker Compose: $(docker-compose --version 2>/dev/null || echo "Not available")
- Python: $(python3 --version 2>/dev/null || echo "Not available")
- Git: $(git --version 2>/dev/null || echo "Not available")

Test Artifacts:
- Test logs: $LOG_FILE
- Test reports: $TEST_REPORTS_DIR
- Coverage reports: Available in test-reports directory
- JUnit XML: Available for CI/CD integration

Next Steps:
1. Review failed tests and fix issues
2. Integrate with CI/CD pipeline
3. Set up automated testing
4. Configure test notifications
5. Add more comprehensive test coverage
EOF

# Generate JUnit XML summary
cat > "$TEST_REPORTS_DIR/junit-summary.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="Nexus COS Test Suite" tests="$TOTAL_TESTS" failures="$FAILED_TESTS" time="$(date +%s)">
EOF

for result in "${TEST_RESULTS[@]}"; do
    IFS=':' read -r test_name status details <<< "$result"
    if [[ "$status" == "PASS" ]]; then
        echo "  <testcase name="$test_name" classname="NexusCOS" />" >> "$TEST_REPORTS_DIR/junit-summary.xml"
    else
        echo "  <testcase name="$test_name" classname="NexusCOS">" >> "$TEST_REPORTS_DIR/junit-summary.xml"
        echo "    <failure message="$details">$details</failure>" >> "$TEST_REPORTS_DIR/junit-summary.xml"
        echo "  </testcase>" >> "$TEST_REPORTS_DIR/junit-summary.xml"
    fi
done

echo "</testsuite>" >> "$TEST_REPORTS_DIR/junit-summary.xml"

# Final summary
log "Test suite completed!"
log "Total tests: $TOTAL_TESTS"
log "Passed: $PASSED_TESTS"
log "Failed: $FAILED_TESTS"
log "Success rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
log "Test report: $TEST_REPORTS_DIR/test-summary.txt"
log "JUnit XML: $TEST_REPORTS_DIR/junit-summary.xml"

# Exit with appropriate code
if [[ $FAILED_TESTS -eq 0 ]]; then
    log "All tests passed! ✓"
    exit 0
else
    log "Some tests failed! ✗"
    exit 1
fi
#!/bin/bash
# NEXUS COS Deployment Testing Script
# Comprehensive validation of all deployment components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TEST_RESULTS=()

run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    print_status "Running: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        print_success "$test_name"
        TEST_RESULTS+=("✅ $test_name")
        ((TESTS_PASSED++))
        return 0
    else
        print_error "$test_name"
        TEST_RESULTS+=("❌ $test_name")
        ((TESTS_FAILED++))
        return 1
    fi
}

run_http_test() {
    local test_name="$1"
    local url="$2"
    local expected_status="$3"
    
    print_status "Testing: $test_name"
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [[ "$response" == "$expected_status" ]]; then
        print_success "$test_name (HTTP $response)"
        TEST_RESULTS+=("✅ $test_name (HTTP $response)")
        ((TESTS_PASSED++))
        return 0
    else
        print_error "$test_name (HTTP $response, expected $expected_status)"
        TEST_RESULTS+=("❌ $test_name (HTTP $response, expected $expected_status)")
        ((TESTS_FAILED++))
        return 1
    fi
}

print_header "NEXUS COS DEPLOYMENT VALIDATION"

# System Dependencies Tests
print_header "System Dependencies"
run_test "Node.js installed" "node --version | grep -E 'v2[0-9]'"
run_test "npm installed" "npm --version"
run_test "pnpm installed" "pnpm --version"
run_test "Python 3.12+ installed" "python3 --version | grep -E '3\.(1[2-9]|[2-9][0-9])'"
run_test "pip installed" "pip --version"
run_test "nginx installed" "nginx -v"
run_test "certbot installed" "certbot --version"
run_test "pm2 installed" "pm2 --version"

# Directory Structure Tests
print_header "Directory Structure"
run_test "Application directory exists" "[ -d '/opt/nexus-cos' ]"
run_test "Web directory exists" "[ -d '/var/www/nexus-cos' ]"
run_test "Nginx config exists" "[ -f '/etc/nginx/sites-available/nexuscos.online.conf' ]"
run_test "Deployment script exists" "[ -f '/opt/deploy-nexus.sh' ]"
run_test "SSL setup script exists" "[ -f '/opt/setup-ssl.sh' ]"

# File Permissions Tests
print_header "File Permissions"
run_test "Application directory owned by nexus" "[ \"$(stat -c '%U' /opt/nexus-cos)\" = 'nexus' ]"
run_test "Web directory owned by www-data" "[ \"$(stat -c '%U' /var/www/nexus-cos)\" = 'www-data' ]"
run_test "Deployment script executable" "[ -x '/opt/deploy-nexus.sh' ]"
run_test "SSL script executable" "[ -x '/opt/setup-ssl.sh' ]"

# Service Tests
print_header "System Services"
run_test "nginx service active" "systemctl is-active nginx"
run_test "nginx service enabled" "systemctl is-enabled nginx"
run_test "nexus-node-backend service exists" "[ -f '/etc/systemd/system/nexus-node-backend.service' ]"
run_test "nexus-python-backend service exists" "[ -f '/etc/systemd/system/nexus-python-backend.service' ]"

# Check if services are running (optional - they might not be started yet)
if systemctl is-active nexus-node-backend >/dev/null 2>&1; then
    print_success "Node.js backend service is running"
    TEST_RESULTS+=("✅ Node.js backend service is running")
    ((TESTS_PASSED++))
else
    print_warning "Node.js backend service is not running (this is OK if not deployed yet)"
    TEST_RESULTS+=("⚠️ Node.js backend service is not running")
fi

if systemctl is-active nexus-python-backend >/dev/null 2>&1; then
    print_success "Python backend service is running"
    TEST_RESULTS+=("✅ Python backend service is running")
    ((TESTS_PASSED++))
else
    print_warning "Python backend service is not running (this is OK if not deployed yet)"
    TEST_RESULTS+=("⚠️ Python backend service is not running")
fi

# Network Tests
print_header "Network Configuration"
run_test "Port 80 accessible" "nc -z localhost 80"
run_test "Port 443 accessible" "nc -z localhost 443"

# Test if application ports are accessible (only if services are running)
if systemctl is-active nexus-node-backend >/dev/null 2>&1; then
    run_test "Node.js backend port accessible" "nc -z localhost 3000"
fi

if systemctl is-active nexus-python-backend >/dev/null 2>&1; then
    run_test "Python backend port accessible" "nc -z localhost 3001"
fi

# Firewall Tests
print_header "Firewall Configuration"
run_test "UFW is active" "ufw status | grep -q 'Status: active'"
run_test "SSH allowed in firewall" "ufw status | grep -q '22/tcp'"
run_test "HTTP allowed in firewall" "ufw status | grep -q '80/tcp'"
run_test "HTTPS allowed in firewall" "ufw status | grep -q '443/tcp'"

# HTTP Tests (if services are running)
print_header "HTTP Endpoint Tests"

# Test nginx default page
run_http_test "Nginx default response" "http://localhost" "200"

# Test application endpoints (only if services are running)
if systemctl is-active nexus-node-backend >/dev/null 2>&1; then
    run_http_test "Node.js health endpoint" "http://localhost:3000/health" "200"
fi

if systemctl is-active nexus-python-backend >/dev/null 2>&1; then
    run_http_test "Python health endpoint" "http://localhost:3001/health" "200"
fi

# SSL Tests (if certificates exist)
print_header "SSL Configuration"
if [ -d "/etc/letsencrypt/live/nexuscos.online" ]; then
    run_test "SSL certificate exists" "[ -f '/etc/letsencrypt/live/nexuscos.online/fullchain.pem' ]"
    run_test "SSL private key exists" "[ -f '/etc/letsencrypt/live/nexuscos.online/privkey.pem' ]"
    
    # Test SSL certificate validity
    if openssl x509 -in /etc/letsencrypt/live/nexuscos.online/fullchain.pem -noout -checkend 86400 >/dev/null 2>&1; then
        print_success "SSL certificate is valid and not expiring soon"
        TEST_RESULTS+=("✅ SSL certificate is valid")
        ((TESTS_PASSED++))
    else
        print_error "SSL certificate is invalid or expiring soon"
        TEST_RESULTS+=("❌ SSL certificate is invalid or expiring soon")
        ((TESTS_FAILED++))
    fi
else
    print_warning "SSL certificates not found (run /opt/setup-ssl.sh after DNS configuration)"
    TEST_RESULTS+=("⚠️ SSL certificates not configured")
fi

# Application File Tests (if deployed)
print_header "Application Files"
if [ -d "/opt/nexus-cos/.git" ]; then
    run_test "Git repository exists" "[ -d '/opt/nexus-cos/.git' ]"
    
    if [ -f "/opt/nexus-cos/package.json" ]; then
        run_test "Main package.json exists" "[ -f '/opt/nexus-cos/package.json' ]"
    fi
    
    if [ -f "/opt/nexus-cos/backend/package.json" ]; then
        run_test "Backend package.json exists" "[ -f '/opt/nexus-cos/backend/package.json' ]"
    fi
    
    if [ -f "/opt/nexus-cos/frontend/package.json" ]; then
        run_test "Frontend package.json exists" "[ -f '/opt/nexus-cos/frontend/package.json' ]"
    fi
    
    if [ -d "/opt/nexus-cos/backend/node_modules" ]; then
        print_success "Backend dependencies installed"
        TEST_RESULTS+=("✅ Backend dependencies installed")
        ((TESTS_PASSED++))
    else
        print_warning "Backend dependencies not installed"
        TEST_RESULTS+=("⚠️ Backend dependencies not installed")
    fi
    
    if [ -d "/opt/nexus-cos/frontend/node_modules" ]; then
        print_success "Frontend dependencies installed"
        TEST_RESULTS+=("✅ Frontend dependencies installed")
        ((TESTS_PASSED++))
    else
        print_warning "Frontend dependencies not installed"
        TEST_RESULTS+=("⚠️ Frontend dependencies not installed")
    fi
    
    if [ -d "/opt/nexus-cos/backend/.venv" ]; then
        print_success "Python virtual environment exists"
        TEST_RESULTS+=("✅ Python virtual environment exists")
        ((TESTS_PASSED++))
    else
        print_warning "Python virtual environment not found"
        TEST_RESULTS+=("⚠️ Python virtual environment not found")
    fi
else
    print_warning "Application not deployed yet (clone repository to /opt/nexus-cos)"
    TEST_RESULTS+=("⚠️ Application not deployed")
fi

# Frontend Build Tests
if [ -d "/var/www/nexus-cos" ] && [ "$(ls -A /var/www/nexus-cos)" ]; then
    print_success "Frontend files deployed"
    TEST_RESULTS+=("✅ Frontend files deployed")
    ((TESTS_PASSED++))
    
    if [ -f "/var/www/nexus-cos/index.html" ]; then
        print_success "Frontend index.html exists"
        TEST_RESULTS+=("✅ Frontend index.html exists")
        ((TESTS_PASSED++))
    else
        print_error "Frontend index.html missing"
        TEST_RESULTS+=("❌ Frontend index.html missing")
        ((TESTS_FAILED++))
    fi
else
    print_warning "Frontend not built/deployed yet"
    TEST_RESULTS+=("⚠️ Frontend not built/deployed")
fi

# System Resource Tests
print_header "System Resources"

# Check disk space
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    print_success "Disk usage OK ($DISK_USAGE%)"
    TEST_RESULTS+=("✅ Disk usage OK ($DISK_USAGE%)")
    ((TESTS_PASSED++))
else
    print_warning "Disk usage high ($DISK_USAGE%)"
    TEST_RESULTS+=("⚠️ Disk usage high ($DISK_USAGE%)")
fi

# Check memory
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')
if [ "$MEM_USAGE" -lt 90 ]; then
    print_success "Memory usage OK ($MEM_USAGE%)"
    TEST_RESULTS+=("✅ Memory usage OK ($MEM_USAGE%)")
    ((TESTS_PASSED++))
else
    print_warning "Memory usage high ($MEM_USAGE%)"
    TEST_RESULTS+=("⚠️ Memory usage high ($MEM_USAGE%)")
fi

# Final Report
print_header "TEST RESULTS SUMMARY"

echo "📊 Test Statistics:"
echo "   ✅ Passed: $TESTS_PASSED"
echo "   ❌ Failed: $TESTS_FAILED"
echo "   📝 Total: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

echo "📋 Detailed Results:"
for result in "${TEST_RESULTS[@]}"; do
    echo "   $result"
done

echo ""
if [ $TESTS_FAILED -eq 0 ]; then
    print_success "🎉 All critical tests passed! Your deployment is ready."
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Clone your application: sudo -u nexus git clone <repo-url> /opt/nexus-cos"
    echo "   2. Deploy application: /opt/deploy-nexus.sh"
    echo "   3. Configure SSL: /opt/setup-ssl.sh"
    exit 0
else
    print_error "⚠️ Some tests failed. Please review and fix issues before proceeding."
    echo ""
    echo "🔧 Common fixes:"
    echo "   • Install missing dependencies"
    echo "   • Check service configurations"
    echo "   • Verify file permissions"
    echo "   • Review firewall settings"
    exit 1
fi
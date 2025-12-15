#!/usr/bin/env bash
# ==============================================================================
# Nexus COS - Nginx Configuration Integration Test
# ==============================================================================
# This script performs comprehensive testing of the Nginx configuration files
# without requiring actual deployment to a server.
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

echo "=============================================================================="
echo "Nexus COS - Nginx Configuration Integration Test"
echo "=============================================================================="
echo ""

# Function to report test results
test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    if [[ "$result" == "pass" ]]; then
        echo -e "${GREEN}✓${NC} $test_name"
        PASS_COUNT=$((PASS_COUNT + 1))
    elif [[ "$result" == "fail" ]]; then
        echo -e "${RED}✗${NC} $test_name"
        if [[ -n "$message" ]]; then
            echo -e "  ${RED}Error: $message${NC}"
        fi
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo -e "${YELLOW}⚠${NC} $test_name"
        if [[ -n "$message" ]]; then
            echo -e "  ${YELLOW}Warning: $message${NC}"
        fi
        WARN_COUNT=$((WARN_COUNT + 1))
    fi
}

# Test 1: Check if configuration files exist
echo -e "${BLUE}Testing configuration files existence...${NC}"
echo ""

if [[ -f "$REPO_ROOT/deployment/nginx/sites-available/nexuscos.online" ]]; then
    test_result "Vanilla Nginx config exists" "pass"
else
    test_result "Vanilla Nginx config exists" "fail" "File not found: deployment/nginx/sites-available/nexuscos.online"
fi

if [[ -f "$REPO_ROOT/deployment/nginx/plesk/vhost_nginx.conf" ]]; then
    test_result "Plesk config exists" "pass"
else
    test_result "Plesk config exists" "fail" "File not found: deployment/nginx/plesk/vhost_nginx.conf"
fi

# Test 2: Check if deployment scripts exist and are executable
echo ""
echo -e "${BLUE}Testing deployment scripts...${NC}"
echo ""

for script in deploy-vanilla.sh deploy-plesk.sh validate-endpoints.sh; do
    script_path="$REPO_ROOT/deployment/nginx/scripts/$script"
    if [[ -f "$script_path" ]]; then
        if [[ -x "$script_path" ]]; then
            test_result "Script $script is executable" "pass"
        else
            test_result "Script $script is executable" "fail" "File is not executable"
        fi
    else
        test_result "Script $script exists" "fail" "File not found"
    fi
done

# Test 3: Validate bash script syntax
echo ""
echo -e "${BLUE}Testing script syntax...${NC}"
echo ""

for script in deploy-vanilla.sh deploy-plesk.sh validate-endpoints.sh; do
    script_path="$REPO_ROOT/deployment/nginx/scripts/$script"
    if [[ -f "$script_path" ]]; then
        if bash -n "$script_path" 2>/dev/null; then
            test_result "Script $script syntax valid" "pass"
        else
            test_result "Script $script syntax valid" "fail" "Syntax errors found"
        fi
    fi
done

# Test 4: Check configuration file structure
echo ""
echo -e "${BLUE}Testing nginx configuration structure...${NC}"
echo ""

VANILLA_CONFIG="$REPO_ROOT/deployment/nginx/sites-available/nexuscos.online"

# Check for required server blocks
if grep -q "listen 80;" "$VANILLA_CONFIG"; then
    test_result "HTTP server block exists" "pass"
else
    test_result "HTTP server block exists" "fail" "No 'listen 80' found"
fi

if grep -q "listen 443 ssl" "$VANILLA_CONFIG"; then
    test_result "HTTPS server block exists" "pass"
else
    test_result "HTTPS server block exists" "fail" "No 'listen 443 ssl' found"
fi

# Check for required location blocks
for location in "/api/" "/stream/" "/hls/" "/health"; do
    if grep -q "location.*$location" "$VANILLA_CONFIG"; then
        test_result "Location block for $location exists" "pass"
    else
        test_result "Location block for $location exists" "fail" "Location block not found"
    fi
done

# Test 5: Check proxy configuration
echo ""
echo -e "${BLUE}Testing proxy configuration...${NC}"
echo ""

# Check API proxy
if grep -A 10 "location.*\/api\/" "$VANILLA_CONFIG" | grep -q "proxy_pass.*127.0.0.1:3000"; then
    test_result "API proxies to port 3000" "pass"
else
    test_result "API proxies to port 3000" "fail" "Proxy configuration not found or incorrect"
fi

# Check streaming proxy
if grep -A 10 "location.*\/stream\/" "$VANILLA_CONFIG" | grep -q "proxy_pass.*127.0.0.1:3043"; then
    test_result "Streaming proxies to port 3043" "pass"
else
    test_result "Streaming proxies to port 3043" "fail" "Proxy configuration not found or incorrect"
fi

# Check WebSocket support
if grep -A 10 "location.*\/api\/" "$VANILLA_CONFIG" | grep -q "Upgrade.*http_upgrade"; then
    test_result "API has WebSocket support" "pass"
else
    test_result "API has WebSocket support" "warn" "WebSocket upgrade headers not found"
fi

if grep -A 10 "location.*\/stream\/" "$VANILLA_CONFIG" | grep -q "Upgrade.*http_upgrade"; then
    test_result "Streaming has WebSocket support" "pass"
else
    test_result "Streaming has WebSocket support" "fail" "WebSocket upgrade headers required for streaming"
fi

# Test 6: Check security headers
echo ""
echo -e "${BLUE}Testing security configuration...${NC}"
echo ""

security_headers=(
    "Strict-Transport-Security"
    "X-Content-Type-Options"
    "X-Frame-Options"
)

for header in "${security_headers[@]}"; do
    if grep -q "add_header $header" "$VANILLA_CONFIG"; then
        test_result "Security header: $header" "pass"
    else
        test_result "Security header: $header" "warn" "Recommended security header not found"
    fi
done

# Test 7: Check SSL configuration
echo ""
echo -e "${BLUE}Testing SSL configuration...${NC}"
echo ""

if grep -q "ssl_certificate.*ionos.*fullchain.pem" "$VANILLA_CONFIG"; then
    test_result "SSL certificate path configured" "pass"
else
    test_result "SSL certificate path configured" "fail" "SSL certificate path not found"
fi

if grep -q "ssl_certificate_key.*ionos.*privkey.pem" "$VANILLA_CONFIG"; then
    test_result "SSL certificate key path configured" "pass"
else
    test_result "SSL certificate key path configured" "fail" "SSL certificate key path not found"
fi

# Test 8: Check documentation
echo ""
echo -e "${BLUE}Testing documentation...${NC}"
echo ""

if [[ -f "$REPO_ROOT/deployment/nginx/README.md" ]]; then
    test_result "README.md exists" "pass"
    
    # Check if README has key sections
    if grep -q "## Deployment Instructions" "$REPO_ROOT/deployment/nginx/README.md"; then
        test_result "README has deployment instructions" "pass"
    else
        test_result "README has deployment instructions" "warn" "Deployment instructions section not found"
    fi
    
    if grep -q "## Troubleshooting" "$REPO_ROOT/deployment/nginx/README.md"; then
        test_result "README has troubleshooting section" "pass"
    else
        test_result "README has troubleshooting section" "warn" "Troubleshooting section not found"
    fi
else
    test_result "README.md exists" "fail" "README.md not found"
fi

if [[ -f "$REPO_ROOT/deployment/nginx/QUICK_REFERENCE.md" ]]; then
    test_result "QUICK_REFERENCE.md exists" "pass"
else
    test_result "QUICK_REFERENCE.md exists" "warn" "Quick reference not found"
fi

# Test 9: Check Plesk configuration
echo ""
echo -e "${BLUE}Testing Plesk configuration...${NC}"
echo ""

PLESK_CONFIG="$REPO_ROOT/deployment/nginx/plesk/vhost_nginx.conf"

if grep -q "location.*\/api\/" "$PLESK_CONFIG"; then
    test_result "Plesk config has API location" "pass"
else
    test_result "Plesk config has API location" "fail" "API location not found in Plesk config"
fi

if grep -q "location.*\/stream\/" "$PLESK_CONFIG"; then
    test_result "Plesk config has streaming location" "pass"
else
    test_result "Plesk config has streaming location" "fail" "Streaming location not found in Plesk config"
fi

# Check if Plesk uses correct paths
if grep -q "/var/www/vhosts/nexuscos.online/httpdocs" "$PLESK_CONFIG"; then
    test_result "Plesk config uses correct document root" "pass"
else
    test_result "Plesk config uses correct document root" "warn" "Plesk document root may be incorrect"
fi

# Test 10: Check for SPA routing support
echo ""
echo -e "${BLUE}Testing SPA routing configuration...${NC}"
echo ""

for spa_path in "/apex/" "/beta/"; do
    if grep -A 5 "location.*$spa_path" "$VANILLA_CONFIG" | grep -q "try_files"; then
        test_result "SPA routing for $spa_path" "pass"
    else
        test_result "SPA routing for $spa_path" "warn" "try_files directive not found"
    fi
done

# Test 11: Validate no common mistakes
echo ""
echo -e "${BLUE}Testing for common mistakes...${NC}"
echo ""

# Check for trailing slash consistency in proxy_pass
if grep "proxy_pass.*127.0.0.1:[0-9]*[^/]$" "$VANILLA_CONFIG" | grep -q "location.*\/$"; then
    test_result "No proxy_pass trailing slash mismatch" "warn" "Found location with trailing slash but proxy_pass without (may cause path issues)"
else
    test_result "No proxy_pass trailing slash mismatch" "pass"
fi

# Check for HTTPS redirect
if grep -A 3 "listen 80;" "$VANILLA_CONFIG" | grep -q "return 301.*https"; then
    test_result "HTTP to HTTPS redirect configured" "pass"
else
    test_result "HTTP to HTTPS redirect configured" "fail" "No HTTPS redirect found"
fi

# Summary
echo ""
echo "=============================================================================="
echo "Test Summary"
echo "=============================================================================="
echo ""
echo -e "Total tests: $((PASS_COUNT + FAIL_COUNT + WARN_COUNT))"
echo -e "${GREEN}Passed: $PASS_COUNT${NC}"
echo -e "${YELLOW}Warnings: $WARN_COUNT${NC}"
echo -e "${RED}Failed: $FAIL_COUNT${NC}"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    echo ""
    echo "Configuration is ready for deployment."
    echo ""
    echo "Next steps:"
    echo "  1. Review the configurations in deployment/nginx/"
    echo "  2. Choose your deployment method (vanilla or Plesk)"
    echo "  3. Run the appropriate deployment script with sudo"
    echo "  4. Validate endpoints with validate-endpoints.sh"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    echo ""
    echo "Please review the errors above and fix the configuration files."
    echo ""
    exit 1
fi

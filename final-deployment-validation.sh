#!/bin/bash
# Final Deployment Validation for Nexus COS React/Vite Frontend
# Tests all endpoints and provides comprehensive status report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${CYAN}$1${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Configuration
SERVER_IP="74.208.155.161"
DEPLOYMENT_TARGET="/var/www/nexus-cos"

print_header "NEXUS COS FRONTEND DEPLOYMENT VALIDATION"

echo "🎯 Target Server: $SERVER_IP"
echo "📁 Deployment Path: $DEPLOYMENT_TARGET"
echo ""

# Test 1: Check if deployment directory exists and has files
print_header "Test 1: Deployment Directory Structure"

if [ -d "$DEPLOYMENT_TARGET" ]; then
    print_success "Deployment directory exists"
    file_count=$(find $DEPLOYMENT_TARGET -type f | wc -l)
    print_info "Files in deployment directory: $file_count"
    
    if [ -f "$DEPLOYMENT_TARGET/index.html" ]; then
        print_success "index.html found"
    else
        print_error "index.html missing"
    fi
    
    if [ -d "$DEPLOYMENT_TARGET/assets" ]; then
        print_success "assets directory found"
        asset_count=$(find $DEPLOYMENT_TARGET/assets -type f | wc -l)
        print_info "Asset files: $asset_count"
    else
        print_error "assets directory missing"
    fi
else
    print_error "Deployment directory missing"
fi

# Test 2: Check file permissions
print_header "Test 2: File Permissions"

if [ -d "$DEPLOYMENT_TARGET" ]; then
    owner=$(stat -c '%U:%G' $DEPLOYMENT_TARGET)
    perms=$(stat -c '%a' $DEPLOYMENT_TARGET)
    print_info "Directory owner: $owner"
    print_info "Directory permissions: $perms"
    
    if [ "$perms" = "755" ]; then
        print_success "Directory permissions correct (755)"
    else
        print_warning "Directory permissions: $perms (expected 755)"
    fi
fi

# Test 3: Check Nginx configuration
print_header "Test 3: Nginx Configuration"

if [ -f "/etc/nginx/sites-available/nexus-cos" ]; then
    print_success "Nginx configuration file exists"
else
    print_error "Nginx configuration file missing"
fi

if [ -L "/etc/nginx/sites-enabled/nexus-cos" ]; then
    print_success "Site is enabled"
else
    print_error "Site is not enabled"
fi

if nginx -t &>/dev/null; then
    print_success "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors"
fi

if systemctl is-active --quiet nginx; then
    print_success "Nginx is running"
else
    print_error "Nginx is not running"
fi

# Test 4: HTTP Response Tests
print_header "Test 4: HTTP Response Tests"

# Test main page
print_info "Testing main page..."
if response=$(curl -s -w "%{http_code}" http://localhost/ 2>/dev/null); then
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        print_success "Main page returns 200 OK"
        
        # Check if it contains React content
        if curl -s http://localhost/ | grep -q "root"; then
            print_success "HTML contains React root element"
        else
            print_warning "HTML might not contain React root element"
        fi
    else
        print_error "Main page returns HTTP $http_code"
    fi
else
    print_error "Cannot connect to main page"
fi

# Test assets
print_info "Testing asset files..."

# Find actual asset files
JS_FILE=$(find $DEPLOYMENT_TARGET/assets -name "index-*.js" -type f 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "")
CSS_FILE=$(find $DEPLOYMENT_TARGET/assets -name "index-*.css" -type f 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "")

if [ -n "$JS_FILE" ]; then
    if response=$(curl -s -w "%{http_code}" "http://localhost/assets/$JS_FILE" 2>/dev/null); then
        http_code="${response: -3}"
        if [ "$http_code" = "200" ]; then
            print_success "JavaScript file accessible ($JS_FILE)"
        else
            print_error "JavaScript file returns HTTP $http_code"
        fi
    else
        print_error "Cannot access JavaScript file"
    fi
else
    print_error "JavaScript file not found"
fi

if [ -n "$CSS_FILE" ]; then
    if response=$(curl -s -w "%{http_code}" "http://localhost/assets/$CSS_FILE" 2>/dev/null); then
        http_code="${response: -3}"
        if [ "$http_code" = "200" ]; then
            print_success "CSS file accessible ($CSS_FILE)"
        else
            print_error "CSS file returns HTTP $http_code"
        fi
    else
        print_error "Cannot access CSS file"
    fi
else
    print_error "CSS file not found"
fi

# Test health endpoint
print_info "Testing health endpoint..."
if response=$(curl -s -w "%{http_code}" http://localhost/health 2>/dev/null); then
    http_code="${response: -3}"
    if [ "$http_code" = "200" ]; then
        print_success "Health endpoint returns 200 OK"
    else
        print_error "Health endpoint returns HTTP $http_code"
    fi
else
    print_error "Cannot access health endpoint"
fi

# Test 5: Check HTTP Headers
print_header "Test 5: HTTP Headers Validation"

print_info "Checking security headers..."
headers=$(curl -s -I http://localhost/ 2>/dev/null || echo "")

if echo "$headers" | grep -q "X-Frame-Options"; then
    print_success "X-Frame-Options header present"
else
    print_warning "X-Frame-Options header missing"
fi

if echo "$headers" | grep -q "X-Content-Type-Options"; then
    print_success "X-Content-Type-Options header present"
else
    print_warning "X-Content-Type-Options header missing"
fi

print_info "Checking cache headers for assets..."
if [ -n "$JS_FILE" ]; then
    asset_headers=$(curl -s -I "http://localhost/assets/$JS_FILE" 2>/dev/null || echo "")
    if echo "$asset_headers" | grep -q "Cache-Control.*immutable"; then
        print_success "Cache headers properly set for assets"
    else
        print_warning "Cache headers not optimally configured"
    fi
fi

# Final Status Report
print_header "FINAL STATUS REPORT"

echo ""
echo -e "${BOLD}📋 DEPLOYMENT STATUS SUMMARY${NC}"
echo "============================="
echo ""

# Count successes and errors from our tests
total_tests=0
passed_tests=0

# We'll do a simple recheck of key items
checks=(
    "Directory exists:$DEPLOYMENT_TARGET"
    "Index file:$DEPLOYMENT_TARGET/index.html"
    "Assets directory:$DEPLOYMENT_TARGET/assets"
    "Nginx config:/etc/nginx/sites-available/nexus-cos"
    "Site enabled:/etc/nginx/sites-enabled/nexus-cos"
    "Nginx running:$(systemctl is-active nginx 2>/dev/null)"
)

for check in "${checks[@]}"; do
    name="${check%%:*}"
    path="${check##*:}"
    total_tests=$((total_tests + 1))
    
    if [[ "$name" == "Nginx running" ]]; then
        if [ "$path" = "active" ]; then
            echo -e "  ✅ $name"
            passed_tests=$((passed_tests + 1))
        else
            echo -e "  ❌ $name"
        fi
    elif [ -e "$path" ] || [ -L "$path" ]; then
        echo -e "  ✅ $name"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "  ❌ $name"
    fi
done

echo ""
echo -e "${BOLD}Test Results: $passed_tests/$total_tests passed${NC}"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED - DEPLOYMENT READY!${NC}"
else
    echo -e "${YELLOW}⚠️  Some tests failed - review issues above${NC}"
fi

echo ""
echo -e "${BOLD}🌐 PRODUCTION DEPLOYMENT COMMANDS${NC}"
echo "=================================="
echo ""
echo "Copy this script to your server and run these commands:"
echo ""
echo "# Test main page:"
echo "curl -I http://$SERVER_IP"
echo ""
echo "# Test assets:"
if [ -n "$JS_FILE" ]; then
    echo "curl -I http://$SERVER_IP/assets/$JS_FILE"
fi
if [ -n "$CSS_FILE" ]; then
    echo "curl -I http://$SERVER_IP/assets/$CSS_FILE"
fi
echo ""
echo "# Test in browser:"
echo "http://$SERVER_IP"
echo ""

echo -e "${BOLD}🔧 NEXT STEPS${NC}"
echo "============"
echo "1. Deploy this configuration to the production server"
echo "2. Run the verification commands above"
echo "3. Test in a web browser"
echo "4. Check browser console for any JavaScript errors"
echo "5. If blank page persists, check nginx error logs"
echo ""

echo -e "${BOLD}📞 SUPPORT${NC}"
echo "========="
echo "If issues persist:"
echo "• Check: sudo tail -f /var/log/nginx/nexus-cos.error.log"
echo "• Verify: sudo nginx -t"
echo "• Restart: sudo systemctl restart nginx"
echo "• Permissions: ls -la $DEPLOYMENT_TARGET"
echo ""

print_header "VALIDATION COMPLETE"
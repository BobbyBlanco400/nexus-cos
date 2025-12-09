#!/bin/bash
# Test script for nginx configuration fixes

set -e

echo "================================================================================"
echo "Testing Nginx Configuration Fixes"
echo "================================================================================"
echo ""

# Test 1: Check pf-fix-nginx-headers-redirect.sh syntax
echo "Test 1: Validating pf-fix-nginx-headers-redirect.sh syntax..."
if bash -n scripts/pf-fix-nginx-headers-redirect.sh; then
    echo "✓ pf-fix-nginx-headers-redirect.sh syntax is valid"
else
    echo "✗ pf-fix-nginx-headers-redirect.sh has syntax errors"
    exit 1
fi
echo ""

# Test 2: Check vps-nginx-fix-one-liner.sh syntax
echo "Test 2: Validating vps-nginx-fix-one-liner.sh syntax..."
if bash -n scripts/vps-nginx-fix-one-liner.sh; then
    echo "✓ vps-nginx-fix-one-liner.sh syntax is valid"
else
    echo "✗ vps-nginx-fix-one-liner.sh has syntax errors"
    exit 1
fi
echo ""

# Test 3: Verify all deployment configs use $host in redirects
echo "Test 3: Checking redirect patterns in deployment configs..."
BAD_REDIRECTS=$(grep -r "return.*301.*https://" deployment/nginx/*.conf 2>/dev/null | grep -v "\$host" || true)
if [ -z "$BAD_REDIRECTS" ]; then
    echo "✓ All redirects use \$host variable"
else
    echo "✗ Found redirects not using \$host:"
    echo "$BAD_REDIRECTS"
    exit 1
fi
echo ""

# Test 4: Verify all $host redirects
echo "Test 4: Counting \$host redirects..."
HOST_COUNT=$(grep -r "return.*301.*https://\$host" deployment/nginx/*.conf 2>/dev/null | wc -l)
echo "✓ Found $HOST_COUNT redirect(s) using \$host"
echo ""

# Test 5: Check for backticks in deployment configs
echo "Test 5: Checking for backticks in deployment configs..."
BACKTICK_FILES=$(grep -r '`' deployment/nginx/*.conf 2>/dev/null || true)
if [ -z "$BACKTICK_FILES" ]; then
    echo "✓ No backticks found in deployment configs"
else
    echo "✗ Found backticks in deployment configs:"
    echo "$BACKTICK_FILES"
    exit 1
fi
echo ""

# Test 6: Verify scripts are executable
echo "Test 6: Checking script permissions..."
if [ -x scripts/pf-fix-nginx-headers-redirect.sh ]; then
    echo "✓ pf-fix-nginx-headers-redirect.sh is executable"
else
    echo "⚠ pf-fix-nginx-headers-redirect.sh is not executable"
fi

if [ -x scripts/vps-nginx-fix-one-liner.sh ]; then
    echo "✓ vps-nginx-fix-one-liner.sh is executable"
else
    echo "⚠ vps-nginx-fix-one-liner.sh is not executable"
fi
echo ""

# Test 7: Verify README exists
echo "Test 7: Checking documentation..."
if [ -f NGINX_FIX_README.md ]; then
    echo "✓ NGINX_FIX_README.md exists"
    LINES=$(wc -l < NGINX_FIX_README.md)
    echo "  Documentation has $LINES lines"
else
    echo "✗ NGINX_FIX_README.md not found"
    exit 1
fi
echo ""

# Test 8: Verify security headers template in pf-fix-nginx-headers-redirect.sh
echo "Test 8: Checking security headers template..."
if grep -q "Strict-Transport-Security" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "Content-Security-Policy" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "X-Content-Type-Options" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "X-Frame-Options" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "Referrer-Policy" scripts/pf-fix-nginx-headers-redirect.sh; then
    echo "✓ All security headers present in template"
else
    echo "✗ Missing security headers in template"
    exit 1
fi
echo ""

# Test 9: Verify one-liner contains all fixes
echo "Test 9: Checking one-liner completeness..."
if grep -q "remove_duplicate_configs" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "remove_stray_backticks" scripts/pf-fix-nginx-headers-redirect.sh && \
   grep -q "fix_https_redirect" scripts/pf-fix-nginx-headers-redirect.sh; then
    echo "✓ pf-fix-nginx-headers-redirect.sh contains all fix functions"
else
    echo "✗ Missing fix functions in pf-fix-nginx-headers-redirect.sh"
    exit 1
fi

if grep -q "zz-security-headers.conf" scripts/vps-nginx-fix-one-liner.sh && \
   grep -q "perl.*x60" scripts/vps-nginx-fix-one-liner.sh && \
   grep -q "pf_gateway" scripts/vps-nginx-fix-one-liner.sh; then
    echo "✓ vps-nginx-fix-one-liner.sh contains all fixes"
else
    echo "✗ Missing fixes in vps-nginx-fix-one-liner.sh"
    exit 1
fi
echo ""

# Summary
echo "================================================================================"
echo "All Tests Passed! ✓"
echo "================================================================================"
echo ""
echo "Summary of changes:"
echo "  • pf-fix-nginx-headers-redirect.sh - Enhanced with all fixes"
echo "  • vps-nginx-fix-one-liner.sh - Standalone VPS deployment script"
echo "  • $HOST_COUNT deployment configs updated to use \$host redirects"
echo "  • NGINX_FIX_README.md - Comprehensive documentation"
echo ""
echo "Next steps:"
echo "  1. Deploy to test environment"
echo "  2. Run: sudo bash scripts/pf-fix-nginx-headers-redirect.sh"
echo "  3. Verify with: curl -I https://nexuscos.online/"
echo "  4. Check redirect: curl -I http://nexuscos.online/"
echo ""

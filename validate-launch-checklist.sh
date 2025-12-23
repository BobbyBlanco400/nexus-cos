#!/bin/bash

# Nexus COS Launch Readiness Checklist - Validation Script
# This script validates that the checklist component meets all requirements

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Nexus COS Launch Readiness Checklist - Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

PASSED=0
FAILED=0

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_pass() {
    echo -e "${GREEN}✅ PASS${NC} - $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC} - $1"
    ((FAILED++))
}

check_info() {
    echo -e "${YELLOW}ℹ️  INFO${NC} - $1"
}

# Check 1: Component file exists
echo "Checking component files..."
if [ -f "admin/src/components/LaunchReadinessChecklist.tsx" ]; then
    check_pass "LaunchReadinessChecklist.tsx exists"
else
    check_fail "LaunchReadinessChecklist.tsx not found"
fi

# Check 2: CSS file exists
if [ -f "admin/src/components/LaunchReadinessChecklist.css" ]; then
    check_pass "LaunchReadinessChecklist.css exists"
else
    check_fail "LaunchReadinessChecklist.css not found"
fi

# Check 3: Documentation exists
if [ -f "LAUNCH_READINESS_CHECKLIST_README.md" ]; then
    check_pass "Documentation file exists"
else
    check_fail "Documentation file not found"
fi

echo ""
echo "Checking component structure..."

# Check 4: Component imports React
if grep -q "import React" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "React imported correctly"
else
    check_fail "React import missing"
fi

# Check 5: Component has TypeScript interfaces
if grep -q "interface ChecklistItem" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "TypeScript interfaces defined"
else
    check_fail "TypeScript interfaces missing"
fi

# Check 6: Component has localStorage persistence
if grep -q "localStorage" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "localStorage persistence implemented"
else
    check_fail "localStorage persistence missing"
fi

# Check 7: Component has export functionality
if grep -q "exportChecklist" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Export functionality implemented"
else
    check_fail "Export functionality missing"
fi

# Check 8: Component has progress tracking
if grep -q "getTotalProgress\|getCategoryProgress" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Progress tracking implemented"
else
    check_fail "Progress tracking missing"
fi

echo ""
echo "Checking checklist categories..."

# Check 9: Count categories
CATEGORY_COUNT=$(grep -c '"Platform Core & Infrastructure"\|"PMMG Nexus Recordings"\|"Rise Sacramento: VoicesOfThe916"\|"Other Platforms 1–14"\|"Licensing & IP Management"\|"Distribution & Monetization"\|"Collaboration & Communication"\|"Security & Compliance"\|"UX/UI & Accessibility"\|"Performance & Load"\|"Backups & DR"\|"Global Launch Sign-Off"' admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null || echo 0)

if [ "$CATEGORY_COUNT" -ge 12 ]; then
    check_pass "All 12 categories present (found $CATEGORY_COUNT references)"
else
    check_fail "Missing categories (found only $CATEGORY_COUNT/12)"
fi

# Check 10: Platform Core & Infrastructure items
if grep -q "Server Health.*CPU.*Memory.*Disk" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Platform Core & Infrastructure items present"
else
    check_fail "Platform Core & Infrastructure items missing"
fi

# Check 11: PMMG Nexus Recordings items
if grep -q "Multi-track recording" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "PMMG Nexus Recordings items present"
else
    check_fail "PMMG Nexus Recordings items missing"
fi

# Check 12: Rise Sacramento items
if grep -q "VoicesOfThe916\|Live streaming setup" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Rise Sacramento: VoicesOfThe916 items present"
else
    check_fail "Rise Sacramento items missing"
fi

# Check 13: Security & Compliance items
if grep -q "OAuth.*SSO.*MFA\|Vulnerability Scan" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Security & Compliance items present"
else
    check_fail "Security & Compliance items missing"
fi

# Check 14: Global Launch Sign-Off items
if grep -q "Final QA Sign-Off" admin/src/components/LaunchReadinessChecklist.tsx 2>/dev/null; then
    check_pass "Global Launch Sign-Off items present"
else
    check_fail "Global Launch Sign-Off items missing"
fi

echo ""
echo "Checking App.tsx integration..."

# Check 15: Component imported in App.tsx
if grep -q "import LaunchReadinessChecklist" admin/src/App.tsx 2>/dev/null; then
    check_pass "Component imported in App.tsx"
else
    check_fail "Component not imported in App.tsx"
fi

# Check 16: Route added
if grep -q "launch-checklist" admin/src/App.tsx 2>/dev/null; then
    check_pass "Route configured for checklist"
else
    check_fail "Route not configured"
fi

# Check 17: Navigation link added
if grep -q "Launch Readiness" admin/src/App.tsx 2>/dev/null; then
    check_pass "Navigation link added"
else
    check_fail "Navigation link missing"
fi

echo ""
echo "Checking styling..."

# Check 18: CSS has progress bar styles
if grep -q "progress-bar\|progress-fill" admin/src/components/LaunchReadinessChecklist.css 2>/dev/null; then
    check_pass "Progress bar styles present"
else
    check_fail "Progress bar styles missing"
fi

# Check 19: CSS has responsive design
if grep -q "@media.*max-width" admin/src/components/LaunchReadinessChecklist.css 2>/dev/null; then
    check_pass "Responsive design implemented"
else
    check_fail "Responsive design missing"
fi

# Check 20: CSS has checkbox styles
if grep -q "checkbox-container\|checkmark" admin/src/components/LaunchReadinessChecklist.css 2>/dev/null; then
    check_pass "Checkbox styles present"
else
    check_fail "Checkbox styles missing"
fi

echo ""
echo "Checking build..."

# Check 21: Admin build directory exists
if [ -d "admin/build" ] || [ -d "admin/dist" ]; then
    check_pass "Build output directory exists"
else
    check_info "Build output not found (run 'npm run build' in admin/)"
fi

# Check 22: Check if admin can build
echo ""
check_info "Running admin build test..."
cd admin
if npm run build > /tmp/build-test.log 2>&1; then
    check_pass "Admin builds successfully"
else
    check_fail "Admin build failed (see /tmp/build-test.log)"
fi
cd ..

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Validation Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}✅ Passed:${NC} $PASSED"
echo -e "${RED}❌ Failed:${NC} $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ ALL CHECKS PASSED! The checklist is ready for use.${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ VALIDATION FAILED! Please review the errors above.${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi

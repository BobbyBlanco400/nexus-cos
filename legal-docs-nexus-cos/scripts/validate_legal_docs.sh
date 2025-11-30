#!/bin/bash
###############################################################################
# Validate Legal Documents for Nexus COS
# Purpose: Verify existence and basic format of legal documents
# Usage: ./validate_legal_docs.sh [base_path]
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default base path
DEFAULT_BASE="/opt/nexus-cos/legal"
BASE="${1:-$DEFAULT_BASE}"

# If running from the legal-docs-nexus-cos directory, use parent of scripts dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/legal-docs-nexus-cos/scripts" ]]; then
    BASE="$(dirname "$SCRIPT_DIR")"
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Nexus COS Legal Documents Validation Script          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Base path: $BASE"
echo ""

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to print status messages
print_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Function to check if file exists and is not empty
check_file() {
    local filepath="$1"
    local description="$2"
    
    if [ -f "$filepath" ]; then
        local filesize=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null || echo "0")
        if [ "$filesize" -gt 0 ]; then
            print_pass "$description"
            return 0
        else
            print_fail "$description (file is empty)"
            return 1
        fi
    else
        print_fail "$description (file not found)"
        return 1
    fi
}

# Check base directory
echo "Checking base directory..."
if [ -d "$BASE" ]; then
    print_pass "Base directory exists"
else
    print_fail "Base directory not found: $BASE"
    exit 1
fi
echo ""

# Required files - Holding Company
echo "Validating Holding Company Documents..."
check_file "$BASE/holding_company/Nexus_Holdings_Articles_of_Incorporation.md" "Articles of Incorporation"
check_file "$BASE/holding_company/Nexus_Holdings_Bylaws.md" "Bylaws"
check_file "$BASE/holding_company/Shareholders_Agreement.md" "Shareholders Agreement"
check_file "$BASE/holding_company/Intercompany_License_Agreement.md" "Intercompany License Agreement"
check_file "$BASE/holding_company/IP_Assignment_to_Holdings.md" "IP Assignment Agreement"
echo ""

# Required files - Nexus COS Core
echo "Validating Nexus COS Core Documents..."
check_file "$BASE/nexus_cos_core/Nexus_COS_Service_Agreement.md" "Service Agreement"
check_file "$BASE/nexus_cos_core/Nexus_COS_Terms_of_Service.md" "Terms of Service"
check_file "$BASE/nexus_cos_core/Nexus_COS_Privacy_Policy.md" "Privacy Policy"
check_file "$BASE/nexus_cos_core/Acceptable_Use_Policy.md" "Acceptable Use Policy"
check_file "$BASE/nexus_cos_core/Content_Licensing_Agreement.md" "Content Licensing Agreement"
check_file "$BASE/nexus_cos_core/Creator_Agreement.md" "Creator Agreement"
check_file "$BASE/nexus_cos_core/Invention_Assignment_Employee_Contract.md" "Employee Invention Assignment"
echo ""

# Required files - Modules Legal
echo "Validating Module Legal Documents..."
check_file "$BASE/modules_legal/V_Suite_Module_Legal.md" "V-Suite Legal Terms"
check_file "$BASE/modules_legal/Nexus_STREAM_Legal.md" "Nexus STREAM Legal Terms"
check_file "$BASE/modules_legal/Nexus_OTT_Legal.md" "Nexus OTT Legal Terms"
check_file "$BASE/modules_legal/Faith_Through_Fitness_Legal.md" "Faith Through Fitness Legal Terms"
echo ""

# Required files - Compliance
echo "Validating Compliance Documents..."
check_file "$BASE/compliance/DMCA_Takedown_Procedure.md" "DMCA Takedown Procedure"
check_file "$BASE/compliance/Data_Processing_Addendum.md" "Data Processing Addendum"
check_file "$BASE/compliance/Cookie_Policy.md" "Cookie Policy"
check_file "$BASE/compliance/GDPR_Notice.md" "GDPR Notice"
echo ""

# Required files - Scripts
echo "Validating Scripts..."
check_file "$BASE/scripts/setup_legal_docs.sh" "Setup script"
check_file "$BASE/scripts/validate_legal_docs.sh" "Validation script"

# Check if scripts are executable
if [ -x "$BASE/scripts/setup_legal_docs.sh" ]; then
    print_pass "Setup script is executable"
else
    print_warning "Setup script is not executable (run: chmod +x setup_legal_docs.sh)"
fi

if [ -x "$BASE/scripts/validate_legal_docs.sh" ]; then
    print_pass "Validation script is executable"
else
    print_warning "Validation script is not executable (run: chmod +x validate_legal_docs.sh)"
fi
echo ""

# Check README
echo "Validating Documentation..."
check_file "$BASE/README.md" "README.md"
echo ""

# Check for placeholder customization
echo "Checking for placeholder customization..."
PLACEHOLDER_COUNT=$(grep -r "\[Date\]\|\[Name\]\|\[Address\]\|\[State\]" "$BASE"/*.md "$BASE"/**/*.md 2>/dev/null | wc -l)

if [ "$PLACEHOLDER_COUNT" -gt 0 ]; then
    print_warning "Found $PLACEHOLDER_COUNT placeholder tags that need customization"
    echo "           Search for [Date], [Name], [Address], [State], etc. and replace with actual values"
else
    print_pass "No placeholder tags found (documents appear customized)"
fi
echo ""

# Additional checks
echo "Performing Additional Checks..."

# Count total documents
MD_COUNT=$(find "$BASE" -name "*.md" -type f 2>/dev/null | wc -l)
DOCX_COUNT=$(find "$BASE" -name "*.docx" -type f 2>/dev/null | wc -l)

echo "  Markdown documents: $MD_COUNT"
echo "  DOCX files: $DOCX_COUNT"
echo ""

# Check directory structure
EXPECTED_DIRS=("holding_company" "nexus_cos_core" "modules_legal" "compliance" "scripts")
echo "Checking directory structure..."
for dir in "${EXPECTED_DIRS[@]}"; do
    if [ -d "$BASE/$dir" ]; then
        print_pass "Directory exists: $dir"
    else
        print_fail "Directory missing: $dir"
    fi
done
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                 Validation Summary                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${GREEN}Passed:${NC}   $PASSED"
echo -e "  ${RED}Failed:${NC}   $FAILED"
echo -e "  ${YELLOW}Warnings:${NC} $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✓ All legal documents are present and validated!${NC}"
        echo ""
        echo "Next Steps:"
        echo "  1. Customize placeholder values in documents"
        echo "  2. Review all documents for accuracy"
        echo "  3. Have legal counsel review documents"
        echo "  4. Convert .md to .docx for final legal review"
        echo "  5. Publish to website/apps as needed"
        exit 0
    else
        echo -e "${YELLOW}⚠ Validation passed with warnings.${NC}"
        echo "  Review warnings above and address as needed."
        exit 0
    fi
else
    echo -e "${RED}✗ Validation failed. Missing or empty files detected.${NC}"
    echo "  Please run setup_legal_docs.sh to install missing files."
    exit 1
fi

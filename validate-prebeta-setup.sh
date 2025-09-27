#!/bin/bash
# Nexus COS Pre-Beta Verification Setup Validator
# This script validates that the pre-beta verification system is properly configured

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           🔍 NEXUS COS PRE-BETA VERIFICATION SETUP VALIDATOR               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
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
    echo -e "${BLUE}🔍 $1${NC}"
}

print_section() {
    echo -e "\n${BLUE}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Validation functions
validate_files() {
    print_section "File Structure Validation"
    
    # Check GitHub workflow
    if [ -f ".github/workflows/nexuscos_prebeta_check.yml" ]; then
        print_success "GitHub workflow file exists"
    else
        print_error "GitHub workflow file missing: .github/workflows/nexuscos_prebeta_check.yml"
        return 1
    fi
    
    # Check Puppeteer script
    if [ -f "deployment/nginx/nexuscos_prebeta_check.js" ]; then
        print_success "Puppeteer script exists"
        if [ -x "deployment/nginx/nexuscos_prebeta_check.js" ]; then
            print_success "Puppeteer script is executable"
        else
            print_warning "Puppeteer script is not executable (will fix automatically)"
            chmod +x deployment/nginx/nexuscos_prebeta_check.js
            print_success "Fixed script permissions"
        fi
    else
        print_error "Puppeteer script missing: deployment/nginx/nexuscos_prebeta_check.js"
        return 1
    fi
    
    # Check documentation
    if [ -f "deployment/nginx/README_PREBETA_VERIFICATION.md" ]; then
        print_success "Documentation exists"
    else
        print_warning "Documentation missing (optional)"
    fi
}

validate_script_syntax() {
    print_section "Script Syntax Validation"
    
    # Validate YAML syntax
    if command -v python3 &> /dev/null; then
        if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/nexuscos_prebeta_check.yml'))" 2>/dev/null; then
            print_success "GitHub workflow YAML syntax is valid"
        else
            print_error "GitHub workflow YAML has syntax errors"
            return 1
        fi
    else
        print_warning "Python3 not available - skipping YAML validation"
    fi
    
    # Validate Node.js syntax
    if command -v node &> /dev/null; then
        if node -c deployment/nginx/nexuscos_prebeta_check.js 2>/dev/null; then
            print_success "Puppeteer script Node.js syntax is valid"
        else
            print_error "Puppeteer script has syntax errors"
            return 1
        fi
    else
        print_error "Node.js not available - cannot validate script syntax"
        return 1
    fi
}

test_script_execution() {
    print_section "Script Execution Test"
    
    # Clean up any existing test output
    rm -f /tmp/nexuscos_prebeta_pf.json
    
    # Run the script in test mode
    if node deployment/nginx/nexuscos_prebeta_check.js >/dev/null 2>&1; then
        print_success "Script executed successfully"
        
        # Check output file
        if [ -f "/tmp/nexuscos_prebeta_pf.json" ]; then
            print_success "JSON report generated successfully"
            
            # Validate JSON structure
            if command -v python3 &> /dev/null; then
                if python3 -c "import json; json.load(open('/tmp/nexuscos_prebeta_pf.json'))" 2>/dev/null; then
                    print_success "JSON report has valid syntax"
                    
                    # Check required fields
                    if python3 -c "
import json
data = json.load(open('/tmp/nexuscos_prebeta_pf.json'))
required = ['timestamp', 'version', 'platform', 'status', 'summary', 'domains', 'eventPages']
missing = [f for f in required if f not in data]
if missing:
    print('Missing fields:', missing)
    exit(1)
else:
    print('All required fields present')
                    " 2>/dev/null; then
                        print_success "JSON report has all required fields"
                    else
                        print_error "JSON report missing required fields"
                        return 1
                    fi
                else
                    print_error "JSON report has invalid syntax"
                    return 1
                fi
            else
                print_warning "Python3 not available - skipping JSON validation"
            fi
        else
            print_error "JSON report not generated"
            return 1
        fi
    else
        print_error "Script execution failed"
        return 1
    fi
}

validate_integration() {
    print_section "Integration Validation"
    
    # Check if we're in a git repository
    if [ -d ".git" ]; then
        print_success "Git repository detected"
        
        # Check if workflow is committed
        if git ls-files --error-unmatch .github/workflows/nexuscos_prebeta_check.yml >/dev/null 2>&1; then
            print_success "GitHub workflow is committed to repository"
        else
            print_warning "GitHub workflow not committed (run 'git add' and 'git commit')"
        fi
        
        if git ls-files --error-unmatch deployment/nginx/nexuscos_prebeta_check.js >/dev/null 2>&1; then
            print_success "Puppeteer script is committed to repository"
        else
            print_warning "Puppeteer script not committed (run 'git add' and 'git commit')"
        fi
    else
        print_warning "Not in a git repository"
    fi
    
    # Check Node.js version
    if command -v node &> /dev/null; then
        node_version=$(node --version | sed 's/v//')
        major_version=$(echo $node_version | cut -d. -f1)
        if [ "$major_version" -ge 18 ]; then
            print_success "Node.js version is compatible ($node_version)"
        else
            print_warning "Node.js version may be incompatible ($node_version), recommend 18+"
        fi
    fi
}

generate_summary() {
    print_section "Validation Summary"
    
    echo -e "\n${GREEN}🎉 Pre-Beta Verification Setup Validation Complete${NC}"
    echo
    echo "📋 Setup Status:"
    echo "  ✅ GitHub Workflow: .github/workflows/nexuscos_prebeta_check.yml"
    echo "  ✅ Puppeteer Script: deployment/nginx/nexuscos_prebeta_check.js"
    echo "  ✅ JSON Output: /tmp/nexuscos_prebeta_pf.json"
    echo
    echo "🚀 Ready for:"
    echo "  • Manual workflow triggers via GitHub Actions"
    echo "  • Daily automatic verification at midnight UTC"
    echo "  • TRAE SOLO integration for PF verification"
    echo "  • CI/CD pipeline integration"
    echo
    echo "📝 Next Steps:"
    echo "  1. Commit changes: git add . && git commit -m 'Add pre-beta verification'"
    echo "  2. Push to GitHub: git push"
    echo "  3. Test workflow: Go to Actions → 'Nexus COS Pre-Beta Verification' → 'Run workflow'"
    echo "  4. Monitor daily runs and artifacts"
    echo
}

# Main execution
main() {
    print_header
    
    local validation_failed=false
    
    validate_files || validation_failed=true
    validate_script_syntax || validation_failed=true
    test_script_execution || validation_failed=true
    validate_integration || validation_failed=true
    
    if [ "$validation_failed" = true ]; then
        echo -e "\n${RED}❌ Validation completed with errors. Please fix the issues above.${NC}"
        exit 1
    else
        generate_summary
        echo -e "${GREEN}✅ All validations passed successfully!${NC}"
    fi
}

# Run main function
main "$@"
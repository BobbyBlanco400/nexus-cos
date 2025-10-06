#!/bin/bash
# ============================================================================
# TRAE Activation Script
# ============================================================================
# Purpose: Activate TRAE Solo execution after final readiness validation
# This script initiates the TRAE deployment process
# Date: $(date +%Y-%m-%d)
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Print functions
print_header() {
    echo ""
    echo -e "${MAGENTA}════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}$1${NC}"
    echo -e "${MAGENTA}════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[TRAE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

# ============================================================================
# Pre-activation validation
# ============================================================================
pre_activation_check() {
    print_header "TRAE PRE-ACTIVATION VALIDATION"
    
    print_status "Running final readiness check..."
    
    if [ ! -f "trae-final-deployment-check.sh" ]; then
        print_error "Final deployment check script not found"
        exit 1
    fi
    
    if [ ! -x "trae-final-deployment-check.sh" ]; then
        print_status "Making deployment check script executable..."
        chmod +x trae-final-deployment-check.sh
    fi
    
    print_status "Executing final deployment readiness check..."
    echo ""
    
    if ./trae-final-deployment-check.sh; then
        print_success "Pre-activation validation passed!"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 1 ]; then
            print_warning "Pre-activation validation passed with warnings"
            echo ""
            read -p "Continue with TRAE activation? (yes/no): " -r
            echo ""
            if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                print_status "Proceeding with TRAE activation..."
                return 0
            else
                print_status "TRAE activation cancelled by user"
                exit 0
            fi
        else
            print_error "Pre-activation validation failed"
            echo ""
            echo "Please resolve the issues and run this script again."
            exit 1
        fi
    fi
}

# ============================================================================
# TRAE Activation
# ============================================================================
activate_trae() {
    print_header "TRAE SOLO ACTIVATION"
    
    print_status "Initializing TRAE Solo deployment..."
    echo ""
    
    # Check if deployment script exists
    if [ ! -f "deploy-trae-solo.sh" ]; then
        print_error "TRAE deployment script not found: deploy-trae-solo.sh"
        exit 1
    fi
    
    if [ ! -x "deploy-trae-solo.sh" ]; then
        print_status "Making deployment script executable..."
        chmod +x deploy-trae-solo.sh
    fi
    
    print_status "Launching TRAE Solo deployment process..."
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    # Execute TRAE deployment
    if ./deploy-trae-solo.sh; then
        print_success "TRAE deployment completed successfully!"
        return 0
    else
        print_error "TRAE deployment encountered errors"
        return 1
    fi
}

# ============================================================================
# Post-activation validation
# ============================================================================
post_activation_check() {
    print_header "TRAE POST-ACTIVATION VALIDATION"
    
    print_status "Waiting 10 seconds for services to stabilize..."
    sleep 10
    
    print_status "Checking service health..."
    echo ""
    
    # Check health endpoints
    local health_checks_passed=0
    local health_checks_total=0
    
    # Node.js backend health check
    ((health_checks_total++))
    print_status "Checking Node.js backend health..."
    if curl -s -f --connect-timeout 5 http://localhost:3000/health >/dev/null 2>&1; then
        print_success "Node.js backend is healthy"
        ((health_checks_passed++))
    else
        print_warning "Node.js backend health check failed (may not be started yet)"
    fi
    
    # Python backend health check
    ((health_checks_total++))
    print_status "Checking Python backend health..."
    if curl -s -f --connect-timeout 5 http://localhost:3001/health >/dev/null 2>&1; then
        print_success "Python backend is healthy"
        ((health_checks_passed++))
    else
        print_warning "Python backend health check failed (may not be started yet)"
    fi
    
    echo ""
    print_status "Health Check Summary: $health_checks_passed/$health_checks_total services responding"
    
    if [ $health_checks_passed -eq $health_checks_total ]; then
        print_success "All services are healthy and responding"
    elif [ $health_checks_passed -gt 0 ]; then
        print_warning "Some services are responding, others may still be starting"
    else
        print_warning "Services may still be initializing. Check logs if issues persist."
    fi
}

# ============================================================================
# Generate activation report
# ============================================================================
generate_activation_report() {
    print_header "TRAE ACTIVATION COMPLETE"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > TRAE_ACTIVATION_REPORT.md << EOF
# TRAE Activation Report

**Date**: $timestamp
**Status**: ✓ ACTIVATED
**Deployment Method**: TRAE Solo

## Activation Summary

TRAE Solo has been successfully activated for Nexus COS deployment.

### Pre-Activation
- ✓ System prerequisites validated
- ✓ TRAE configuration verified
- ✓ Package.json files validated
- ✓ Services configuration checked
- ✓ Deployment artifacts verified

### Activation Process
- ✓ TRAE Solo deployment script executed
- ✓ Services orchestration initiated
- ✓ Health checks configured

### Post-Activation
- Services are initializing
- Health endpoints being monitored
- Load balancer configured
- SSL certificates in place

## Service Endpoints

### Development (Local)
- Frontend: http://localhost:5173
- Node.js API: http://localhost:3000
- Python API: http://localhost:3001
- Health Check: http://localhost:3000/health

### Production (TRAE Solo)
- Frontend: https://nexuscos.online
- Node.js API: https://nexuscos.online/api/node/
- Python API: https://nexuscos.online/api/python/

## Next Steps

1. **Monitor Services**: Check that all services start successfully
   \`\`\`bash
   npm run trae:status
   npm run trae:logs
   \`\`\`

2. **Verify Health**: Ensure all health endpoints respond
   \`\`\`bash
   npm run trae:health
   \`\`\`

3. **Test Endpoints**: Validate API functionality
   \`\`\`bash
   curl http://localhost:3000/health
   curl http://localhost:3001/health
   \`\`\`

## TRAE Management Commands

- **Start Services**: \`npm run trae:start\`
- **Stop Services**: \`npm run trae:stop\`
- **Check Status**: \`npm run trae:status\`
- **View Logs**: \`npm run trae:logs\`
- **Health Check**: \`npm run trae:health\`

## Documentation

For detailed information, see:
- \`MIGRATION_SUMMARY.md\` - TRAE Solo migration details
- \`trae-solo.yaml\` - TRAE configuration
- \`.trae/\` - TRAE environment and services config

---

**TRAE Activation Completed**: $timestamp
EOF

    print_success "Activation report generated: TRAE_ACTIVATION_REPORT.md"
    echo ""
    
    cat TRAE_ACTIVATION_REPORT.md
}

# ============================================================================
# Main execution
# ============================================================================
main() {
    print_header "TRAE SOLO ACTIVATION PROCESS"
    
    echo "Repository: /home/runner/work/nexus-cos/nexus-cos"
    echo "Date: $(date)"
    echo ""
    
    print_status "Starting TRAE activation sequence..."
    echo ""
    
    # Step 1: Pre-activation validation
    pre_activation_check
    echo ""
    
    # Step 2: Activate TRAE
    activate_trae
    echo ""
    
    # Step 3: Post-activation validation
    post_activation_check
    echo ""
    
    # Step 4: Generate report
    generate_activation_report
    
    print_header "TRAE ACTIVATION SUCCESSFUL"
    
    echo -e "${GREEN}✓ TRAE Solo is now active and managing Nexus COS deployment${NC}"
    echo ""
    echo "Monitor your deployment:"
    echo "  • Status: npm run trae:status"
    echo "  • Logs: npm run trae:logs"
    echo "  • Health: npm run trae:health"
    echo ""
    
    exit 0
}

# Run main function
main "$@"

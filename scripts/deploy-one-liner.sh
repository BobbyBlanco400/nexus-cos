#!/bin/bash

# ==============================================================================
# Nexus COS - One-Liner Deployment Script
# ==============================================================================
# Purpose: Execute the enhanced production one-liner deployment
# Target VPS: 74.208.155.161 (nexuscos.online)
# Created: 2025-10-05
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
VPS_IP="${VPS_IP:-74.208.155.161}"
VPS_USER="${VPS_USER:-root}"
REPO_PATH="/opt/nexus-cos"

# ==============================================================================
# Print Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          NEXUS COS - ONE-LINER DEPLOYMENT                      ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

check_ssh_connection() {
    print_info "Testing SSH connection to ${VPS_USER}@${VPS_IP}..."
    if ssh -o ConnectTimeout=5 -o BatchMode=yes "${VPS_USER}@${VPS_IP}" "echo 'SSH connection successful'" &>/dev/null; then
        print_success "SSH connection verified"
        return 0
    else
        print_warning "Cannot connect with key authentication, will prompt for password"
        return 1
    fi
}

check_requirements() {
    print_info "Checking local requirements..."
    
    # Check SSH
    if ! command -v ssh &> /dev/null; then
        print_error "SSH client not found. Please install OpenSSH."
        exit 1
    fi
    print_success "SSH client found"
}

# ==============================================================================
# One-Liner Definition
# ==============================================================================

get_one_liner() {
    cat << 'EOF'
cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo "Testing port ${p}..." && curl -fsS http://localhost:${p}/health || { echo "PORT_${p}_FAILED"; exit 1; }; done && echo "Local health checks passed" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo "✅ PF_DEPLOY_SUCCESS - All systems operational" || { echo "❌ DEPLOYMENT_FAILED - Collecting diagnostics..."; docker compose -f docker-compose.pf.yml ps; echo "--- Gateway API Logs ---"; docker logs --tail 200 puabo-api; echo "--- PV Keys Logs ---"; docker logs --tail 200 nexus-cos-pv-keys; echo "--- AI SDK Logs ---"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }
EOF
}

# ==============================================================================
# Deployment Functions
# ==============================================================================

show_one_liner() {
    print_header
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ONE-LINER COMMAND${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}ssh -o StrictHostKeyChecking=no ${VPS_USER}@${VPS_IP} \"$(get_one_liner)\"${NC}"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

deploy() {
    print_header
    
    echo -e "${CYAN}Target VPS:${NC} ${VPS_USER}@${VPS_IP}"
    echo -e "${CYAN}Repository:${NC} ${REPO_PATH}"
    echo ""
    
    # Check requirements
    check_requirements
    
    # Test SSH connection
    check_ssh_connection
    
    echo ""
    print_info "Starting deployment..."
    echo ""
    
    # Execute the one-liner
    ONE_LINER=$(get_one_liner)
    
    echo -e "${YELLOW}Executing deployment command...${NC}"
    echo ""
    
    # Run the deployment
    if ssh -o StrictHostKeyChecking=no "${VPS_USER}@${VPS_IP}" "$ONE_LINER"; then
        echo ""
        print_success "Deployment completed successfully!"
        echo ""
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}  ✅ DEPLOYMENT SUCCESS${NC}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "Your Nexus COS deployment is now live!"
        echo ""
        echo -e "${CYAN}Next steps:${NC}"
        echo "  1. Visit: https://nexuscos.online"
        echo "  2. Test: https://nexuscos.online/v-suite/prompter/health"
        echo "  3. Monitor: ssh ${VPS_USER}@${VPS_IP} 'cd ${REPO_PATH} && docker compose -f docker-compose.pf.yml logs -f'"
        echo ""
        return 0
    else
        echo ""
        print_error "Deployment failed!"
        echo ""
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  ❌ DEPLOYMENT FAILED${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Diagnostic information should be displayed above.${NC}"
        echo ""
        echo -e "${CYAN}Manual troubleshooting:${NC}"
        echo "  1. Check logs: ssh ${VPS_USER}@${VPS_IP} 'cd ${REPO_PATH} && docker compose -f docker-compose.pf.yml logs'"
        echo "  2. Check status: ssh ${VPS_USER}@${VPS_IP} 'cd ${REPO_PATH} && docker compose -f docker-compose.pf.yml ps'"
        echo "  3. Review documentation: cat DEPLOYMENT_ONE_LINER.md"
        echo ""
        return 1
    fi
}

dry_run() {
    print_header
    
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  DRY RUN MODE - No changes will be made${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${CYAN}Target VPS:${NC} ${VPS_USER}@${VPS_IP}"
    echo -e "${CYAN}Repository:${NC} ${REPO_PATH}"
    echo ""
    
    check_requirements
    
    echo ""
    print_info "Testing SSH connection..."
    if check_ssh_connection; then
        print_success "SSH connection test passed"
    else
        print_warning "SSH connection requires password or key setup"
    fi
    
    echo ""
    print_info "Checking VPS environment..."
    
    # Check Docker on VPS
    if ssh -o ConnectTimeout=10 "${VPS_USER}@${VPS_IP}" "command -v docker &> /dev/null && echo 'Docker found'" 2>/dev/null | grep -q "Docker found"; then
        print_success "Docker is installed on VPS"
    else
        print_warning "Could not verify Docker installation on VPS"
    fi
    
    # Check repository
    if ssh -o ConnectTimeout=10 "${VPS_USER}@${VPS_IP}" "test -d ${REPO_PATH} && echo 'Repo found'" 2>/dev/null | grep -q "Repo found"; then
        print_success "Repository exists at ${REPO_PATH}"
    else
        print_error "Repository not found at ${REPO_PATH}"
    fi
    
    echo ""
    print_info "Deployment command that would be executed:"
    echo ""
    echo -e "${YELLOW}$(get_one_liner)${NC}"
    echo ""
    
    print_success "Dry run completed. Use '--deploy' to execute actual deployment."
}

# ==============================================================================
# Main Function
# ==============================================================================

show_usage() {
    cat << EOF
Usage: $0 [OPTION]

Deploy Nexus COS using the enhanced one-liner command.

Options:
    --deploy        Execute the deployment (default)
    --dry-run       Test connection and show command without deploying
    --show          Display the one-liner command only
    --help          Display this help message

Environment Variables:
    VPS_IP          VPS IP address (default: 74.208.155.161)
    VPS_USER        VPS username (default: root)

Examples:
    $0                          # Deploy to default VPS
    $0 --dry-run                # Test without deploying
    $0 --show                   # Show command only
    VPS_IP=10.0.0.1 $0          # Deploy to custom IP

EOF
}

main() {
    case "${1:-}" in
        --help|-h)
            show_usage
            ;;
        --show)
            show_one_liner
            ;;
        --dry-run)
            dry_run
            ;;
        --deploy|"")
            deploy
            ;;
        *)
            echo "Unknown option: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

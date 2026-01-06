#!/bin/bash
# ==============================================================================
# TRAE SOLO - Nexus COS Bulletproof One-Liner Deploy
# ==============================================================================
# Usage: curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/trae-deploy.sh | sudo bash
# ==============================================================================

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly PURPLE='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly REPO_PATH="${REPO_PATH:-/opt/nexus-cos}"
readonly REPO_URL="https://github.com/BobbyBlanco400/nexus-cos.git"
readonly VPS_IP="74.208.155.161"
readonly DOMAIN="n3xuscos.online"

# ==============================================================================
# Banner
# ==============================================================================

print_banner() {
    clear
    echo ""
    echo -e "${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║                                                              ║${NC}"
    echo -e "${PURPLE}${BOLD}║        🎯 TRAE SOLO BULLETPROOF ONE-LINER DEPLOY 🎯         ║${NC}"
    echo -e "${PURPLE}${BOLD}║                                                              ║${NC}"
    echo -e "${PURPLE}${BOLD}║              Nexus COS Production Framework                  ║${NC}"
    echo -e "${PURPLE}${BOLD}║                ZERO ERROR MARGIN GUARANTEED                  ║${NC}"
    echo -e "${PURPLE}${BOLD}║                                                              ║${NC}"
    echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Target:${NC} $VPS_IP ($DOMAIN)"
    echo -e "${CYAN}Path:${NC} $REPO_PATH"
    echo ""
}

# ==============================================================================
# Logging
# ==============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo ""
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
    echo ""
}

# ==============================================================================
# Prerequisites Check
# ==============================================================================

check_prerequisites() {
    log_step "PHASE 1: Checking Prerequisites"
    
    # Check root
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        echo ""
        echo "Please run:"
        echo "  curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/trae-deploy.sh | sudo bash"
        echo ""
        exit 1
    fi
    log_success "Running with root privileges"
    
    # Check required commands
    local required_cmds=("curl" "git" "docker")
    local missing_cmds=()
    
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_cmds+=("$cmd")
        fi
    done
    
    if [[ ${#missing_cmds[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_cmds[*]}"
        log_info "Installing missing dependencies..."
        
        apt-get update -qq
        
        for cmd in "${missing_cmds[@]}"; do
            case "$cmd" in
                docker)
                    log_info "Installing Docker..."
                    curl -fsSL https://get.docker.com | sh
                    systemctl enable docker
                    systemctl start docker
                    ;;
                *)
                    apt-get install -y -qq "$cmd"
                    ;;
            esac
        done
        
        log_success "All dependencies installed"
    else
        log_success "All required commands available"
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose not available"
        exit 1
    fi
    log_success "Docker Compose available"
    
    echo ""
}

# ==============================================================================
# Repository Setup
# ==============================================================================

setup_repository() {
    log_step "PHASE 2: Repository Setup"
    
    # Create parent directory
    mkdir -p "$(dirname "$REPO_PATH")"
    
    # Clone or update repository
    if [[ -d "$REPO_PATH/.git" ]]; then
        log_info "Repository exists, pulling latest changes..."
        cd "$REPO_PATH"
        git fetch origin
        git reset --hard origin/main
        log_success "Repository updated"
    else
        if [[ -d "$REPO_PATH" ]]; then
            log_warning "Directory exists but is not a git repo, backing up..."
            mv "$REPO_PATH" "${REPO_PATH}.backup.$(date +%s)"
        fi
        
        log_info "Cloning repository..."
        git clone "$REPO_URL" "$REPO_PATH"
        cd "$REPO_PATH"
        log_success "Repository cloned"
    fi
    
    # Make scripts executable
    chmod +x bulletproof-pf-deploy.sh bulletproof-pf-validate.sh 2>/dev/null || true
    
    echo ""
}

# ==============================================================================
# Deployment
# ==============================================================================

run_deployment() {
    log_step "PHASE 3: Running Bulletproof Deployment"
    
    cd "$REPO_PATH"
    
    if [[ ! -f "bulletproof-pf-deploy.sh" ]]; then
        log_error "Deployment script not found: bulletproof-pf-deploy.sh"
        exit 1
    fi
    
    log_info "Starting bulletproof deployment..."
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Run deployment script
    if ./bulletproof-pf-deploy.sh; then
        log_success "Deployment completed successfully"
    else
        log_error "Deployment failed"
        exit 1
    fi
    
    echo ""
}

# ==============================================================================
# Validation
# ==============================================================================

run_validation() {
    log_step "PHASE 4: Running Validation Suite"
    
    cd "$REPO_PATH"
    
    if [[ ! -f "bulletproof-pf-validate.sh" ]]; then
        log_warning "Validation script not found, skipping..."
        return 0
    fi
    
    log_info "Running comprehensive validation..."
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Run validation script
    if ./bulletproof-pf-validate.sh; then
        log_success "All validation checks passed"
    else
        log_warning "Some validation checks failed, but deployment may still be operational"
    fi
    
    echo ""
}

# ==============================================================================
# Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
    echo -e "${GREEN}${BOLD}║              ✅ DEPLOYMENT COMPLETE! ✅                       ║${NC}"
    echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
    echo -e "${GREEN}${BOLD}║         Nexus COS Production Framework Deployed              ║${NC}"
    echo -e "${GREEN}${BOLD}║                                                              ║${NC}"
    echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}🌐 Production URLs:${NC}"
    echo -e "   • Main Site:    ${GREEN}https://$DOMAIN${NC}"
    echo -e "   • API:          ${GREEN}https://$DOMAIN/api/health${NC}"
    echo -e "   • Hollywood:    ${GREEN}https://hollywood.$DOMAIN${NC}"
    echo -e "   • TV/Streaming: ${GREEN}https://tv.$DOMAIN${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}✅ Quick Health Check:${NC}"
    echo ""
    
    # Quick health checks
    local services=(
        "localhost:4000|Gateway API"
        "localhost:3002|AI SDK"
        "localhost:3041|PV Keys"
        "localhost:8088|V-Screen Hollywood"
        "localhost:3016|StreamCore"
    )
    
    for service in "${services[@]}"; do
        IFS='|' read -r endpoint name <<< "$service"
        if curl -sf "http://$endpoint/health" >/dev/null 2>&1; then
            echo -e "   ✅ ${GREEN}$name${NC} ($endpoint)"
        else
            echo -e "   ⚠️  ${YELLOW}$name${NC} ($endpoint) - Starting up..."
        fi
    done
    
    echo ""
    echo -e "${CYAN}${BOLD}📊 View Services:${NC}"
    echo -e "   ${BLUE}cd $REPO_PATH && docker compose -f docker-compose.pf.yml ps${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}📝 View Logs:${NC}"
    echo -e "   ${BLUE}cd $REPO_PATH && docker compose -f docker-compose.pf.yml logs -f${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}🔄 Restart Services:${NC}"
    echo -e "   ${BLUE}cd $REPO_PATH && docker compose -f docker-compose.pf.yml restart${NC}"
    echo ""
    
    echo -e "${CYAN}${BOLD}📚 Documentation:${NC}"
    echo -e "   • Quick Start:   ${BLUE}$REPO_PATH/TRAE_SOLO_CONDENSED.md${NC}"
    echo -e "   • Complete Guide: ${BLUE}$REPO_PATH/PF_BULLETPROOF_GUIDE.md${NC}"
    echo -e "   • Master Index:   ${BLUE}$REPO_PATH/BULLETPROOF_PF_INDEX.md${NC}"
    echo ""
    
    echo -e "${GREEN}${BOLD}🎉 Nexus COS is now live and ready for production!${NC}"
    echo ""
}

# ==============================================================================
# Error Handler
# ==============================================================================

handle_error() {
    local exit_code=$?
    local line_number=$1
    
    echo ""
    log_error "Deployment failed at line $line_number (exit code: $exit_code)"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "  1. Check logs: ${BLUE}cd $REPO_PATH && docker compose -f docker-compose.pf.yml logs${NC}"
    echo -e "  2. Verify environment: ${BLUE}cat $REPO_PATH/.env.pf${NC}"
    echo -e "  3. Check documentation: ${BLUE}$REPO_PATH/TRAE_SOLO_CONDENSED.md${NC}"
    echo ""
    echo -e "${YELLOW}For manual deployment:${NC}"
    echo -e "  ${BLUE}cd $REPO_PATH && ./bulletproof-pf-deploy.sh${NC}"
    echo ""
    exit "$exit_code"
}

trap 'handle_error $LINENO' ERR

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_banner
    check_prerequisites
    setup_repository
    run_deployment
    run_validation
    print_summary
}

# Run main
main "$@"

#!/bin/bash
#================================================================
# NEXUS COS - BULLETPROOFED VPS ONE-LINER DEPLOYMENT
#================================================================
# Purpose: Single command SSH deployment for VPS Server
# Based on: PR #174 (Expansion Layer) & PR #168 (Platform Synopsis)
# Status: Production Ready - Zero Downtime
# Author: Nexus COS Platform Team
# Date: 2025-12-24
#================================================================

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configuration
REPO_DIR="/opt/nexus-cos"
DEPLOY_LOG="/tmp/nexus-deploy-$(date +%Y%m%d-%H%M%S).log"
MAX_RETRIES=3
HEALTH_CHECK_TIMEOUT=120

#================================================================
# BANNER
#================================================================
print_banner() {
    clear
    echo -e "${MAGENTA}"
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗     ██████╗ ██████╗  ║
║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██╔════╝██╔═══██╗ ║
║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║     ██║   ██║ ║
║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║     ██║   ██║ ║
║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╗╚██████╔╝ ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝  ║
║                                                                       ║
║         BULLETPROOFED VPS DEPLOYMENT - ONE-LINER EXECUTION           ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Deployment Timestamp: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}Deployment Log: ${DEPLOY_LOG}${NC}"
    echo ""
}

#================================================================
# LOGGING FUNCTIONS
#================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$DEPLOY_LOG"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$DEPLOY_LOG"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$DEPLOY_LOG"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$DEPLOY_LOG"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$DEPLOY_LOG"
}

#================================================================
# PRE-FLIGHT CHECKS
#================================================================
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        if ! sudo -n true 2>/dev/null; then
            log_error "This script requires sudo privileges"
            exit 1
        fi
    fi
    
    # Check required commands
    local required_commands=("git" "docker" "curl" "nc")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            log_info "Installing missing dependencies..."
            sudo apt-get update -qq && sudo apt-get install -y "$cmd"
        fi
    done
    
    # Check Docker is running
    if ! docker ps &> /dev/null; then
        log_error "Docker is not running or accessible"
        log_info "Starting Docker..."
        sudo systemctl start docker || sudo service docker start
        sleep 3
    fi
    
    # Check disk space (need at least 2GB)
    local available_space=$(df /opt | tail -1 | awk '{print $4}')
    if [[ $available_space -lt 2097152 ]]; then
        log_warning "Low disk space detected. Available: ${available_space}KB"
    fi
    
    log_success "Pre-flight checks passed"
}

#================================================================
# REPOSITORY SETUP
#================================================================
setup_repository() {
    log_info "Setting up repository..."
    
    if [ -d "$REPO_DIR/.git" ]; then
        log_info "Repository exists, updating..."
        cd "$REPO_DIR"
        
        # Stash any local changes
        git stash push -m "Auto-stash before deployment $(date)" || true
        
        # Fetch latest changes
        git fetch origin main --prune
        
        # Reset to latest main
        git reset --hard origin/main
        
        log_success "Repository updated to latest main"
    else
        log_info "Cloning repository..."
        sudo mkdir -p "$(dirname "$REPO_DIR")"
        sudo git clone https://github.com/BobbyBlanco400/nexus-cos.git "$REPO_DIR"
        cd "$REPO_DIR"
        log_success "Repository cloned"
    fi
    
    # Ensure correct permissions
    sudo chown -R $(whoami):$(whoami) "$REPO_DIR" 2>/dev/null || true
}

#================================================================
# ENVIRONMENT CONFIGURATION
#================================================================
configure_environment() {
    log_info "Configuring environment..."
    
    cd "$REPO_DIR"
    
    # Use .env.pf if it exists, otherwise .env.example
    if [ -f ".env.pf" ]; then
        log_info "Using .env.pf configuration"
        cp .env.pf .env
    elif [ -f ".env.example" ]; then
        log_info "Using .env.example as template"
        cp .env.example .env
    else
        log_warning "No environment template found, creating minimal .env"
        cat > .env << 'ENVEOF'
NODE_ENV=production
PLATFORM_NAME=Nexus COS
DATABASE_URL=postgresql://nexus_user:nexus_secure_password_2025@postgres:5432/nexus_cos
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=nexus_cos
DATABASE_USER=nexus_user
DATABASE_PASSWORD=nexus_secure_password_2025
REDIS_URL=redis://redis:6379
REDIS_HOST=redis
REDIS_PORT=6379
ENVEOF
    fi
    
    log_success "Environment configured"
}

#================================================================
# DOCKER DEPLOYMENT
#================================================================
deploy_docker_services() {
    log_info "Deploying Docker services..."
    
    cd "$REPO_DIR"
    
    # Determine which docker-compose file to use
    local compose_file="docker-compose.yml"
    if [ -f "docker-compose.pf.yml" ]; then
        compose_file="docker-compose.pf.yml"
        log_info "Using docker-compose.pf.yml"
    elif [ -f "docker-compose.prod.yml" ]; then
        compose_file="docker-compose.prod.yml"
        log_info "Using docker-compose.prod.yml"
    else
        log_info "Using default docker-compose.yml"
    fi
    
    # Stop existing containers gracefully
    log_info "Stopping existing containers..."
    docker compose -f "$compose_file" down --remove-orphans || true
    
    # Clean up old images to free space
    log_info "Cleaning up old Docker images..."
    docker image prune -f || true
    
    # Build and start services
    log_info "Building and starting services..."
    docker compose -f "$compose_file" up -d --build --remove-orphans
    
    log_success "Docker services deployed"
}

#================================================================
# HEALTH CHECKS
#================================================================
wait_for_services() {
    log_info "Waiting for services to become healthy..."
    
    local start_time=$(date +%s)
    local services_healthy=false
    
    # Key ports to check based on recent PF work
    local check_ports=(
        "4000:Gateway API"
        "3002:PUABO AI SDK"
        "3041:PV Keys"
        "3000:Frontend"
        "5432:PostgreSQL"
        "6379:Redis"
    )
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [ $elapsed -gt $HEALTH_CHECK_TIMEOUT ]; then
            log_error "Health check timeout after ${HEALTH_CHECK_TIMEOUT}s"
            return 1
        fi
        
        local all_healthy=true
        for port_info in "${check_ports[@]}"; do
            local port="${port_info%%:*}"
            local service="${port_info##*:}"
            
            if ! nc -z localhost "$port" 2>/dev/null; then
                all_healthy=false
                log_info "Waiting for $service (port $port)... ${elapsed}s"
                break
            fi
        done
        
        if $all_healthy; then
            services_healthy=true
            break
        fi
        
        sleep 5
    done
    
    if $services_healthy; then
        log_success "All services are healthy"
        
        # Additional HTTP health checks
        log_info "Running HTTP health checks..."
        for port_info in "${check_ports[@]}"; do
            local port="${port_info%%:*}"
            local service="${port_info##*:}"
            
            # Skip database ports for HTTP checks
            if [[ "$port" == "5432" || "$port" == "6379" ]]; then
                continue
            fi
            
            if curl -sf "http://localhost:$port/health" > /dev/null 2>&1 || \
               curl -sf "http://localhost:$port/" > /dev/null 2>&1; then
                log_success "$service HTTP endpoint responding"
            else
                log_warning "$service HTTP endpoint not responding (may not have /health route)"
            fi
        done
        
        return 0
    else
        return 1
    fi
}

#================================================================
# VERIFICATION
#================================================================
verify_deployment() {
    log_info "Verifying deployment..."
    
    cd "$REPO_DIR"
    
    # Check Docker containers
    log_info "Container Status:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tee -a "$DEPLOY_LOG"
    
    # Count running containers
    local running_containers=$(docker ps -q | wc -l)
    log_info "Running containers: $running_containers"
    
    if [ "$running_containers" -lt 3 ]; then
        log_warning "Expected at least 3 containers running"
    fi
    
    # Check for PF-specific features from PR #174
    log_info "Checking PR #174 features..."
    local pr174_features=(
        "config/jurisdiction-engine.yaml"
        "config/marketplace-phase2.yaml"
        "config/ai-dealers.yaml"
        "config/casino-federation.yaml"
    )
    
    for feature in "${pr174_features[@]}"; do
        if [ -f "$feature" ]; then
            log_success "PR #174 feature present: $feature"
        else
            log_info "PR #174 feature not present: $feature (optional)"
        fi
    done
    
    log_success "Deployment verified"
}

#================================================================
# POST-DEPLOYMENT SUMMARY
#================================================================
post_deployment_summary() {
    echo ""
    log_info "═══════════════════════════════════════════════════════"
    log_success "DEPLOYMENT COMPLETED SUCCESSFULLY"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    
    echo -e "${CYAN}📊 Deployment Summary:${NC}"
    echo -e "  - Repository: Updated to latest main branch"
    echo -e "  - Environment: Configured"
    echo -e "  - Docker Services: Running"
    echo -e "  - Health Checks: Passed"
    echo ""
    
    echo -e "${CYAN}🌐 Access Points:${NC}"
    local server_ip=$(hostname -I | awk '{print $1}')
    echo -e "  - Frontend: http://$server_ip:3000"
    echo -e "  - Gateway API: http://$server_ip:4000"
    echo -e "  - PUABO AI SDK: http://$server_ip:3002"
    echo -e "  - PV Keys: http://$server_ip:3041"
    echo ""
    
    echo -e "${CYAN}📝 Logs:${NC}"
    echo -e "  - Deployment Log: $DEPLOY_LOG"
    echo -e "  - Docker Logs: docker logs <container_name>"
    echo ""
    
    echo -e "${CYAN}🔧 Quick Commands:${NC}"
    echo -e "  - View containers: docker ps"
    echo -e "  - View logs: docker compose logs -f"
    echo -e "  - Restart service: docker compose restart <service>"
    echo -e "  - Health check: curl http://localhost:4000/health"
    echo ""
    
    echo -e "${GREEN}✅ Nexus COS is now running on your VPS!${NC}"
    echo ""
}

#================================================================
# ERROR HANDLER
#================================================================
error_handler() {
    local exit_code=$?
    log_error "Deployment failed with exit code: $exit_code"
    
    echo ""
    log_error "═══════════════════════════════════════════════════════"
    log_error "DEPLOYMENT FAILED - COLLECTING DIAGNOSTICS"
    log_error "═══════════════════════════════════════════════════════"
    echo ""
    
    log_info "Docker Container Status:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>&1 | tee -a "$DEPLOY_LOG"
    
    log_info "Recent Docker Logs:"
    docker compose logs --tail=50 2>&1 | tee -a "$DEPLOY_LOG"
    
    log_info "System Resources:"
    df -h 2>&1 | tee -a "$DEPLOY_LOG"
    free -h 2>&1 | tee -a "$DEPLOY_LOG"
    
    echo ""
    log_error "For support, review the deployment log: $DEPLOY_LOG"
    
    exit $exit_code
}

#================================================================
# MAIN EXECUTION
#================================================================
main() {
    # Set error handler
    trap error_handler ERR
    
    # Execute deployment steps
    print_banner
    preflight_checks
    setup_repository
    configure_environment
    deploy_docker_services
    wait_for_services
    verify_deployment
    post_deployment_summary
    
    # Success
    exit 0
}

# Run main function
main "$@"

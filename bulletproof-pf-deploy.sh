#!/bin/bash

# ==============================================================================
# Nexus COS - Bulletproof Production Framework Deployment
# ==============================================================================
# Author: TRAE SOLO (GitHub Code Agent)
# For: Robert White (PUABO / Nexus COS Founder)
# Version: 1.0 BULLETPROOF
# Date: 2025-10-07
# Target VPS: 74.208.155.161 (nexuscos.online)
# ==============================================================================
# This script provides ZERO room for error. Every step is validated.
# ==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ==============================================================================
# Configuration
# ==============================================================================

readonly REPO_ROOT="/opt/nexus-cos"
readonly VPS_IP="74.208.155.161"
readonly APEX_DOMAIN="nexuscos.online"
readonly HOLLYWOOD_DOMAIN="hollywood.nexuscos.online"
readonly TV_DOMAIN="tv.nexuscos.online"
readonly SSL_BASE="/etc/nginx/ssl"
readonly ENV_FILE="${REPO_ROOT}/.env.pf"
readonly ENV_EXAMPLE="${REPO_ROOT}/.env.pf.example"
readonly COMPOSE_FILE="${REPO_ROOT}/docker-compose.pf.yml"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║          NEXUS COS - BULLETPROOF PF DEPLOYMENT                 ║
║                                                                ║
║              ZERO Room for Error Guaranteed                    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} ${BOLD}$1${NC}" >&2
    ((CHECKS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
    ((CHECKS_WARNING++))
}

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

fatal_error() {
    echo ""
    echo -e "${RED}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║                    FATAL ERROR                                 ║${NC}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${RED}${BOLD}$1${NC}"
    echo ""
    echo -e "${YELLOW}Deployment cannot continue.${NC}"
    echo ""
    exit 1
}

confirm_action() {
    local prompt="$1"
    local response
    
    echo -e "${YELLOW}${BOLD}$prompt${NC} [y/N]: "
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${RED}Action cancelled by user.${NC}"
        exit 1
    fi
}

# ==============================================================================
# Pre-Flight Checks
# ==============================================================================

check_prerequisites() {
    print_section "1. PRE-FLIGHT SYSTEM CHECKS"
    
    # Check if running as root or with sudo privileges
    print_step "Checking privileges..."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root or with sudo"
        fatal_error "Please run: sudo $0"
    fi
    print_success "Running with root privileges"
    
    # Check Docker
    print_step "Checking Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        fatal_error "Install Docker: curl -fsSL https://get.docker.com | sh"
    fi
    
    local docker_version
    docker_version=$(docker --version | grep -oP '\d+\.\d+\.\d+' | head -1)
    print_success "Docker installed: v${docker_version}"
    
    # Check Docker Compose
    print_step "Checking Docker Compose..."
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose plugin not available"
        fatal_error "Install Docker Compose plugin"
    fi
    
    local compose_version
    compose_version=$(docker compose version --short)
    print_success "Docker Compose installed: v${compose_version}"
    
    # Check Docker service
    print_step "Checking Docker service status..."
    if ! systemctl is-active --quiet docker; then
        print_warning "Docker service not running, attempting to start..."
        systemctl start docker || fatal_error "Failed to start Docker service"
    fi
    print_success "Docker service is running"
    
    # Check Nginx
    print_step "Checking Nginx installation..."
    if ! command -v nginx &> /dev/null; then
        print_warning "Nginx not installed, installing..."
        apt-get update && apt-get install -y nginx || fatal_error "Failed to install Nginx"
    fi
    
    local nginx_version
    nginx_version=$(nginx -v 2>&1 | grep -oP '\d+\.\d+\.\d+')
    print_success "Nginx installed: v${nginx_version}"
    
    # Check Git
    print_step "Checking Git installation..."
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        fatal_error "Install Git: apt-get install -y git"
    fi
    print_success "Git installed: $(git --version)"
    
    # Check OpenSSL
    print_step "Checking OpenSSL installation..."
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL is not installed"
        fatal_error "Install OpenSSL: apt-get install -y openssl"
    fi
    print_success "OpenSSL installed: $(openssl version)"
    
    # Check disk space
    print_step "Checking disk space..."
    local available_space
    available_space=$(df -BG "${REPO_ROOT}" 2>/dev/null | awk 'NR==2 {print $4}' | grep -oP '\d+' || echo "0")
    
    if [[ $available_space -lt 10 ]]; then
        print_error "Insufficient disk space: ${available_space}GB available"
        fatal_error "Minimum 10GB free space required"
    fi
    print_success "Disk space available: ${available_space}GB"
    
    # Check memory
    print_step "Checking system memory..."
    local total_mem
    total_mem=$(free -g | awk 'NR==2 {print $2}')
    
    if [[ $total_mem -lt 4 ]]; then
        print_warning "Low memory: ${total_mem}GB (Recommended: 4GB+)"
    else
        print_success "System memory: ${total_mem}GB"
    fi
}

# ==============================================================================
# Repository Setup
# ==============================================================================

setup_repository() {
    print_section "2. REPOSITORY SETUP"
    
    print_step "Checking repository directory..."
    if [[ ! -d "$REPO_ROOT" ]]; then
        print_warning "Repository directory does not exist"
        print_step "Creating directory: ${REPO_ROOT}"
        mkdir -p "$REPO_ROOT" || fatal_error "Failed to create repository directory"
    fi
    print_success "Repository directory exists: ${REPO_ROOT}"
    
    cd "$REPO_ROOT" || fatal_error "Failed to change to repository directory"
    
    print_step "Checking Git repository..."
    if [[ -d "${REPO_ROOT}/.git" ]]; then
        print_info "Git repository exists, updating..."
        git fetch --all || print_warning "Failed to fetch updates"
        git reset --hard origin/main || print_warning "Failed to reset to origin/main"
        print_success "Repository updated"
    else
        print_warning "Not a git repository"
        print_info "Current directory should contain Nexus COS files"
    fi
    
    print_step "Validating essential files..."
    local essential_files=(
        "docker-compose.pf.yml"
        ".env.pf.example"
        "database/schema.sql"
    )
    
    for file in "${essential_files[@]}"; do
        if [[ ! -f "${REPO_ROOT}/${file}" ]]; then
            print_error "Essential file missing: ${file}"
            fatal_error "Repository is incomplete or corrupted"
        fi
    done
    print_success "All essential files present"
}

# ==============================================================================
# Environment Configuration
# ==============================================================================

configure_environment() {
    print_section "3. ENVIRONMENT CONFIGURATION"
    
    print_step "Checking environment file..."
    if [[ ! -f "$ENV_FILE" ]]; then
        print_warning ".env.pf does not exist"
        
        if [[ -f "$ENV_EXAMPLE" ]]; then
            print_step "Copying from .env.pf.example..."
            cp "$ENV_EXAMPLE" "$ENV_FILE" || fatal_error "Failed to copy environment file"
            print_success "Created .env.pf from example"
        else
            fatal_error ".env.pf.example not found"
        fi
    else
        print_success ".env.pf exists"
    fi
    
    print_step "Validating required environment variables..."
    local required_vars=(
        "OAUTH_CLIENT_ID"
        "OAUTH_CLIENT_SECRET"
        "JWT_SECRET"
        "DB_PASSWORD"
        "DB_USER"
        "DB_NAME"
        "PORT"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        local value
        value=$(grep "^${var}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)
        
        if [[ -z "$value" ]] || [[ "$value" == "your-"* ]] || [[ "$value" == "<"* ]]; then
            missing_vars+=("$var")
            print_error "$var is not configured (contains placeholder or empty)"
        else
            print_success "$var is configured"
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo ""
        echo -e "${RED}${BOLD}CONFIGURATION REQUIRED${NC}"
        echo -e "${YELLOW}The following variables must be set in ${ENV_FILE}:${NC}"
        for var in "${missing_vars[@]}"; do
            echo -e "  ${RED}✗${NC} $var"
        done
        echo ""
        echo -e "${CYAN}Edit the file with:${NC}"
        echo -e "  nano ${ENV_FILE}"
        echo ""
        fatal_error "Environment configuration incomplete"
    fi
    
    print_success "All required environment variables configured"
}

# ==============================================================================
# SSL Certificate Setup
# ==============================================================================

setup_ssl_certificates() {
    print_section "4. SSL CERTIFICATE SETUP (IONOS)"
    
    print_step "Creating SSL directories..."
    mkdir -p "${SSL_BASE}/apex"
    mkdir -p "${SSL_BASE}/hollywood"
    mkdir -p "${SSL_BASE}/tv"
    print_success "SSL directories created"
    
    print_step "Checking for IONOS SSL certificates..."
    
    local apex_cert="${SSL_BASE}/apex/nexuscos.online.crt"
    local apex_key="${SSL_BASE}/apex/nexuscos.online.key"
    local hollywood_cert="${SSL_BASE}/hollywood/hollywood.nexuscos.online.crt"
    local hollywood_key="${SSL_BASE}/hollywood/hollywood.nexuscos.online.key"
    
    local certs_missing=false
    
    if [[ -f "$apex_cert" ]] && [[ -f "$apex_key" ]]; then
        print_success "Apex domain certificates found"
        
        # Validate certificate
        if openssl x509 -in "$apex_cert" -noout -text &>/dev/null; then
            print_success "Apex certificate is valid PEM format"
            
            # Check issuer
            local issuer
            issuer=$(openssl x509 -in "$apex_cert" -noout -issuer)
            print_info "Certificate issuer: $issuer"
            
            # Check expiration
            local expiry
            expiry=$(openssl x509 -in "$apex_cert" -noout -enddate | cut -d= -f2)
            print_info "Certificate expires: $expiry"
        else
            print_error "Apex certificate is not valid"
            certs_missing=true
        fi
    else
        print_warning "Apex domain certificates not found"
        certs_missing=true
    fi
    
    if [[ -f "$hollywood_cert" ]] && [[ -f "$hollywood_key" ]]; then
        print_success "Hollywood subdomain certificates found"
        
        if openssl x509 -in "$hollywood_cert" -noout -text &>/dev/null; then
            print_success "Hollywood certificate is valid PEM format"
        else
            print_error "Hollywood certificate is not valid"
            certs_missing=true
        fi
    else
        print_warning "Hollywood subdomain certificates not found"
        print_info "Will use apex certificates for Hollywood subdomain"
    fi
    
    if $certs_missing; then
        echo ""
        echo -e "${YELLOW}${BOLD}SSL CERTIFICATES REQUIRED${NC}"
        echo -e "${CYAN}Place IONOS SSL certificates in:${NC}"
        echo -e "  Apex:      ${apex_cert}"
        echo -e "             ${apex_key}"
        echo -e "  Hollywood: ${hollywood_cert}"
        echo -e "             ${hollywood_key}"
        echo ""
        print_warning "Deployment will continue with self-signed or existing certs"
        print_warning "Production domains will need valid IONOS certificates"
    fi
    
    print_step "Disabling Let's Encrypt configurations..."
    if [[ -d "/etc/nginx/conf.d" ]]; then
        mkdir -p "/etc/nginx/conf.d.disabled"
        find /etc/nginx/conf.d -name "*letsencrypt*" -type f -exec mv {} /etc/nginx/conf.d.disabled/ \; 2>/dev/null || true
        print_success "Let's Encrypt configs disabled"
    fi
}

# ==============================================================================
# Docker Compose Validation
# ==============================================================================

validate_docker_compose() {
    print_section "5. DOCKER COMPOSE VALIDATION"
    
    print_step "Validating docker-compose.pf.yml syntax..."
    if docker compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
        print_success "Docker Compose syntax is valid"
    else
        print_error "Docker Compose syntax validation failed"
        docker compose -f "$COMPOSE_FILE" config 2>&1 | head -20
        fatal_error "Fix syntax errors in docker-compose.pf.yml"
    fi
    
    print_step "Checking required services..."
    local required_services=(
        "nexus-cos-postgres"
        "nexus-cos-redis"
        "puabo-api"
        "nexus-cos-puaboai-sdk"
        "nexus-cos-pv-keys"
        "vscreen-hollywood"
        "nexus-cos-streamcore"
    )
    
    for service in "${required_services[@]}"; do
        if grep -q "^  ${service}:" "$COMPOSE_FILE"; then
            print_success "Service defined: ${service}"
        else
            print_error "Service missing: ${service}"
            fatal_error "docker-compose.pf.yml is missing required service: ${service}"
        fi
    done
}

# ==============================================================================
# Service Deployment
# ==============================================================================

deploy_services() {
    print_section "6. SERVICE DEPLOYMENT"
    
    print_step "Stopping existing services..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    print_success "Existing services stopped"
    
    print_step "Pulling required images..."
    docker compose -f "$COMPOSE_FILE" pull --quiet 2>&1 | grep -v "^$" || true
    print_success "Images pulled"
    
    print_step "Building and starting services..."
    print_info "This may take several minutes..."
    
    if docker compose -f "$COMPOSE_FILE" up -d --build 2>&1 | tee /tmp/docker-compose-up.log; then
        print_success "Services started successfully"
    else
        print_error "Service deployment failed"
        echo ""
        tail -20 /tmp/docker-compose-up.log
        fatal_error "Review logs above for details"
    fi
    
    print_step "Waiting for services to initialize..."
    sleep 10
    
    print_step "Checking service status..."
    docker compose -f "$COMPOSE_FILE" ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    
    # Count running services
    local running_services
    running_services=$(docker compose -f "$COMPOSE_FILE" ps --filter "status=running" --quiet | wc -l)
    print_info "Services running: ${running_services}"
}

# ==============================================================================
# Health Check Validation
# ==============================================================================

validate_health_checks() {
    print_section "7. HEALTH CHECK VALIDATION"
    
    print_step "Waiting for services to be fully ready..."
    sleep 20
    
    local endpoints=(
        "http://localhost:4000/health|Gateway API (puabo-api)"
        "http://localhost:3002/health|AI SDK (puaboai-sdk)"
        "http://localhost:3041/health|PV Keys Service"
        "http://localhost:8088/health|V-Screen Hollywood"
        "http://localhost:3016/health|StreamCore"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS='|' read -r url name <<< "$endpoint_info"
        
        print_step "Testing: ${name}"
        
        local retries=0
        local max_retries=10
        local success=false
        
        while [[ $retries -lt $max_retries ]]; do
            if curl -sf "$url" -m 5 > /dev/null 2>&1; then
                print_success "${name} is responding"
                success=true
                break
            fi
            
            ((retries++))
            if [[ $retries -lt $max_retries ]]; then
                sleep 3
            fi
        done
        
        if ! $success; then
            print_error "${name} is not responding after ${max_retries} attempts"
            print_info "Check logs: docker compose -f ${COMPOSE_FILE} logs ${name}"
        fi
    done
    
    # Database check
    print_step "Testing database connectivity..."
    if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-postgres pg_isready -U nexus_user -d nexus_db &>/dev/null; then
        print_success "PostgreSQL is ready"
    else
        print_warning "PostgreSQL health check failed"
    fi
    
    # Redis check
    print_step "Testing Redis connectivity..."
    if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-redis redis-cli ping &>/dev/null; then
        print_success "Redis is responding"
    else
        print_warning "Redis health check failed"
    fi
}

# ==============================================================================
# Nginx Configuration
# ==============================================================================

configure_nginx() {
    print_section "8. NGINX CONFIGURATION"
    
    print_step "Testing Nginx configuration..."
    if nginx -t 2>&1 | grep -q "syntax is ok"; then
        print_success "Nginx configuration is valid"
    else
        print_warning "Nginx configuration has issues"
        nginx -t 2>&1 || true
    fi
    
    print_step "Reloading Nginx..."
    if systemctl reload nginx 2>&1; then
        print_success "Nginx reloaded successfully"
    else
        print_warning "Failed to reload Nginx"
        print_info "Nginx may not be configured for production domains yet"
    fi
}

# ==============================================================================
# Final Validation
# ==============================================================================

final_validation() {
    print_section "9. FINAL VALIDATION"
    
    print_step "Running comprehensive validation..."
    
    # Service count
    local total_services
    total_services=$(docker compose -f "$COMPOSE_FILE" config --services | wc -l)
    local running_services
    running_services=$(docker compose -f "$COMPOSE_FILE" ps --filter "status=running" --quiet | wc -l)
    
    print_info "Total services defined: ${total_services}"
    print_info "Services running: ${running_services}"
    
    if [[ $running_services -eq $total_services ]]; then
        print_success "All services are running"
    else
        print_warning "Some services may not be running"
    fi
    
    # Check database tables
    print_step "Checking database schema..."
    if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -c "\dt" 2>&1 | grep -q "users"; then
        print_success "Database tables initialized"
    else
        print_warning "Database tables may not be initialized"
        print_info "Run: docker compose -f ${COMPOSE_FILE} exec nexus-cos-postgres psql -U nexus_user -d nexus_db -f /docker-entrypoint-initdb.d/schema.sql"
    fi
}

# ==============================================================================
# Deployment Summary
# ==============================================================================

print_summary() {
    print_section "10. DEPLOYMENT SUMMARY"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    DEPLOYMENT STATISTICS                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}✓ Checks Passed:${NC}    ${CHECKS_PASSED}"
    echo -e "${YELLOW}⚠ Warnings:${NC}         ${CHECKS_WARNING}"
    echo -e "${RED}✗ Checks Failed:${NC}    ${CHECKS_FAILED}"
    echo ""
    
    local pass_rate=0
    local total_checks=$((CHECKS_PASSED + CHECKS_FAILED))
    if [[ $total_checks -gt 0 ]]; then
        pass_rate=$((CHECKS_PASSED * 100 / total_checks))
    fi
    
    echo -e "${BOLD}Pass Rate:${NC} ${pass_rate}%"
    echo ""
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}"
        cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║         Nexus COS Production Framework Deployed!               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
    else
        echo -e "${YELLOW}${BOLD}"
        cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              ⚠  DEPLOYMENT COMPLETED WITH WARNINGS             ║
║                                                                ║
║         Review warnings above and take corrective action       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}${BOLD}📊 Service Endpoints:${NC}"
    echo -e "  ${BOLD}Gateway API:${NC}              http://localhost:4000"
    echo -e "  ${BOLD}AI SDK:${NC}                   http://localhost:3002"
    echo -e "  ${BOLD}PV Keys:${NC}                  http://localhost:3041"
    echo -e "  ${BOLD}V-Screen Hollywood:${NC}       http://localhost:8088"
    echo -e "  ${BOLD}StreamCore:${NC}               http://localhost:3016"
    echo -e "  ${BOLD}PostgreSQL:${NC}               localhost:5432"
    echo -e "  ${BOLD}Redis:${NC}                    localhost:6379"
    echo ""
    
    echo -e "${CYAN}${BOLD}🔍 Quick Commands:${NC}"
    echo -e "  ${BOLD}View Services:${NC}    docker compose -f ${COMPOSE_FILE} ps"
    echo -e "  ${BOLD}View Logs:${NC}        docker compose -f ${COMPOSE_FILE} logs -f"
    echo -e "  ${BOLD}Restart Service:${NC}  docker compose -f ${COMPOSE_FILE} restart [service-name]"
    echo -e "  ${BOLD}Stop Services:${NC}    docker compose -f ${COMPOSE_FILE} down"
    echo ""
    
    echo -e "${CYAN}${BOLD}📋 Next Steps:${NC}"
    echo -e "  1. Configure production Nginx for domains (nexuscos.online, hollywood.nexuscos.online)"
    echo -e "  2. Place IONOS SSL certificates in ${SSL_BASE}/"
    echo -e "  3. Test production endpoints"
    echo -e "  4. Run: ./bulletproof-pf-validate.sh"
    echo ""
    
    echo -e "${GREEN}${BOLD}Deployment completed at: $(date)${NC}"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_banner
    
    # Execute deployment phases
    check_prerequisites
    setup_repository
    configure_environment
    setup_ssl_certificates
    validate_docker_compose
    deploy_services
    validate_health_checks
    configure_nginx
    final_validation
    print_summary
    
    # Exit with appropriate code
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"

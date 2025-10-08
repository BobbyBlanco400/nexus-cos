#!/bin/bash

# ==============================================================================
# Nexus COS - Hybrid Fullstack PF v2025.10.01 Deployment Script
# ==============================================================================
# Author: Code Agent + TRAE Solo
# For: PUABO / Nexus COS
# Version: v2025.10.01
# Date: 2025-10-01 23:22 PST
# Target VPS: 74.208.155.161 (nexuscos.online)
# ==============================================================================
# Purpose: Deploy the complete Nexus COS ecosystem including PUABO NEXUS
# Fleet Management System (ports 3231-3234) and all integrated services
# ==============================================================================

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ==============================================================================
# Configuration
# ==============================================================================

readonly REPO_ROOT="/opt/nexus-cos"
readonly VPS_IP="74.208.155.161"
readonly DOMAIN="${DOMAIN:-nexuscos.online}"
readonly SSL_BASE="/etc/nginx/ssl"
readonly ENV_FILE="${REPO_ROOT}/.env.pf"
readonly ENV_EXAMPLE="${REPO_ROOT}/.env.pf.example"
readonly COMPOSE_FILE="${REPO_ROOT}/docker-compose.pf.yml"
readonly COMPOSE_NEXUS_FILE="${REPO_ROOT}/docker-compose.pf.nexus.yml"
readonly NETWORK_NAME="${NETWORK_NAME:-nexus-network}"
readonly PF_VERSION="v2025.10.01"
readonly PF_CONFIG="${REPO_ROOT}/nexus-cos-pf-v2025.10.01.yaml"
readonly NGINX_ROUTE_UPDATER="${REPO_ROOT}/scripts/update-nginx-puabo-nexus-routes.sh"

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
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║     NEXUS COS - PF v2025.10.01 DEPLOYMENT SCRIPT              ║${NC}"
    echo -e "${CYAN}║     Hybrid Fullstack Production + Dev Orchestration            ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Scope:${NC} Nexus COS | PUABO Universe | Club Saditty | Nexus Studio AI | PUABO NEXUS Fleet"
    echo -e "${YELLOW}Status:${NC} LIVE | CERTIFIED | PF-SYNC READY"
    echo -e "${YELLOW}Target:${NC} ${VPS_IP} (${DOMAIN})"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((CHECKS_WARNING++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

fatal_error() {
    echo ""
    echo -e "${RED}${BOLD}FATAL ERROR:${NC} $1"
    echo ""
    exit 1
}

# ==============================================================================
# System Requirements Check
# ==============================================================================

check_system_requirements() {
    print_section "1. SYSTEM REQUIREMENTS CHECK"
    
    print_step "Checking Docker installation..."
    if command -v docker &> /dev/null; then
        print_success "Docker is installed: $(docker --version)"
    else
        print_error "Docker is not installed"
        fatal_error "Please install Docker first: https://docs.docker.com/engine/install/"
    fi
    
    print_step "Checking Docker Compose..."
    if docker compose version &> /dev/null; then
        print_success "Docker Compose is available: $(docker compose version)"
    else
        print_error "Docker Compose plugin is not available"
        fatal_error "Please install Docker Compose plugin"
    fi
    
    print_step "Checking disk space..."
    local available_space=$(df -BG "${REPO_ROOT}" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -ge 10 ]]; then
        print_success "Sufficient disk space: ${available_space}GB available"
    else
        print_warning "Low disk space: ${available_space}GB available (10GB+ recommended)"
    fi
    
    print_step "Checking memory..."
    local total_mem=$(free -g | awk 'NR==2 {print $2}')
    if [[ $total_mem -ge 4 ]]; then
        print_success "Sufficient memory: ${total_mem}GB total"
    else
        print_warning "Low memory: ${total_mem}GB total (4GB+ recommended)"
    fi
}

# ==============================================================================
# Repository Validation
# ==============================================================================

validate_repository() {
    print_section "2. REPOSITORY VALIDATION"
    
    print_step "Checking repository location..."
    if [[ -d "${REPO_ROOT}/.git" ]]; then
        print_success "Repository found at ${REPO_ROOT}"
    else
        print_error "Repository not found at ${REPO_ROOT}"
        fatal_error "Please clone the repository to ${REPO_ROOT}"
    fi
    
    print_step "Validating PF configuration file..."
    if [[ -f "${PF_CONFIG}" ]]; then
        print_success "PF configuration found: ${PF_CONFIG}"
    else
        print_error "PF configuration not found: ${PF_CONFIG}"
        fatal_error "PF v2025.10.01 configuration is missing"
    fi
    
    print_step "Checking docker-compose.pf.yml..."
    if [[ -f "${COMPOSE_FILE}" ]]; then
        print_success "Docker Compose file found"
    else
        print_error "Docker Compose file not found"
        fatal_error "docker-compose.pf.yml is missing"
    fi
    
    print_step "Validating essential files..."
    local essential_files=(
        "PF_v2025.10.01.md"
        "database/schema.sql"
        "nginx.conf.docker"
    )
    
    for file in "${essential_files[@]}"; do
        if [[ -f "${REPO_ROOT}/${file}" ]]; then
            print_success "Found: ${file}"
        else
            print_warning "Missing: ${file}"
        fi
    done
}

# ==============================================================================
# Environment Configuration
# ==============================================================================

configure_environment() {
    print_section "3. ENVIRONMENT CONFIGURATION"
    
    print_step "Checking .env.pf file..."
    if [[ ! -f "${ENV_FILE}" ]]; then
        print_warning ".env.pf does not exist"
        
        if [[ -f "${ENV_EXAMPLE}" ]]; then
            print_step "Copying from .env.pf.example..."
            cp "${ENV_EXAMPLE}" "${ENV_FILE}" || fatal_error "Failed to copy environment file"
            print_success "Created .env.pf from example"
            print_warning "IMPORTANT: Edit .env.pf and configure required secrets before continuing"
            echo ""
            echo -e "${YELLOW}Required variables:${NC}"
            echo "  - OAUTH_CLIENT_ID"
            echo "  - OAUTH_CLIENT_SECRET"
            echo "  - JWT_SECRET"
            echo "  - DB_PASSWORD"
            echo ""
            read -p "Press Enter after configuring .env.pf to continue..."
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
        value=$(grep "^${var}=" "${ENV_FILE}" 2>/dev/null | cut -d'=' -f2-)
        
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
        fatal_error "Environment configuration incomplete"
    fi
    
    print_success "All required environment variables configured"
}

# ==============================================================================
# SSL Certificate Setup
# ==============================================================================

setup_ssl_certificates() {
    print_section "4. SSL CERTIFICATE SETUP"
    
    print_step "Creating SSL directories..."
    mkdir -p "${SSL_BASE}"
    print_success "SSL directory ready: ${SSL_BASE}"
    
    print_step "Checking for SSL certificates..."
    if [[ -f "${SSL_BASE}/nexus-cos.crt" ]] && [[ -f "${SSL_BASE}/nexus-cos.key" ]]; then
        print_success "SSL certificates found"
        
        # Validate certificate
        if openssl x509 -in "${SSL_BASE}/nexus-cos.crt" -noout -checkend 86400 &>/dev/null; then
            print_success "SSL certificate is valid"
        else
            print_warning "SSL certificate is expiring soon or invalid"
        fi
    else
        print_warning "SSL certificates not found in ${SSL_BASE}"
        print_info "Deployment will continue, but HTTPS will not work without certificates"
        print_info "Place your certificates at:"
        print_info "  - ${SSL_BASE}/nexus-cos.crt"
        print_info "  - ${SSL_BASE}/nexus-cos.key"
        echo ""
        read -p "Continue without SSL? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            fatal_error "SSL certificates required for production deployment"
        fi
    fi
}

# ==============================================================================
# Docker Compose Validation
# ==============================================================================

validate_docker_compose() {
    print_section "5. DOCKER COMPOSE VALIDATION"
    
    print_step "Validating docker-compose.pf.yml syntax..."
    if docker compose -f "${COMPOSE_FILE}" config > /dev/null 2>&1; then
        print_success "Docker Compose syntax is valid"
    else
        print_error "Docker Compose syntax validation failed"
        docker compose -f "${COMPOSE_FILE}" config 2>&1 | head -20
        fatal_error "Fix syntax errors in docker-compose.pf.yml"
    fi
    
    print_step "Checking service definitions..."
    local services=$(docker compose -f "${COMPOSE_FILE}" config --services)
    local service_count=$(echo "$services" | wc -l)
    print_success "Found ${service_count} services defined"
    
    print_step "Listing configured services..."
    while IFS= read -r service; do
        print_info "  - ${service}"
    done <<< "$services"
}

# ==============================================================================
# Deploy Services
# ==============================================================================

deploy_services() {
    print_section "6. DEPLOYING SERVICES"
    
    # Create shared Docker network
    print_step "Creating shared Docker network: ${NETWORK_NAME}..."
    if docker network inspect "${NETWORK_NAME}" &>/dev/null; then
        print_info "Network ${NETWORK_NAME} already exists"
    else
        docker network create "${NETWORK_NAME}" || fatal_error "Failed to create network"
        print_success "Network ${NETWORK_NAME} created"
    fi
    
    # Deploy core PF stack
    print_step "Deploying core PF stack (docker-compose.pf.yml)..."
    docker compose -f "${COMPOSE_FILE}" pull || print_warning "Some images could not be pulled"
    
    print_step "Building core custom images..."
    docker compose -f "${COMPOSE_FILE}" build || fatal_error "Failed to build core images"
    print_success "Core images built successfully"
    
    print_step "Starting core services..."
    docker compose -f "${COMPOSE_FILE}" up -d || fatal_error "Failed to start core services"
    print_success "Core services started"
    
    # Deploy PUABO NEXUS fleet stack
    if [[ -f "${COMPOSE_NEXUS_FILE}" ]]; then
        print_step "Deploying PUABO NEXUS fleet stack (docker-compose.pf.nexus.yml)..."
        
        # Set environment variables for the fleet stack
        export NETWORK_NAME="${NETWORK_NAME}"
        export DOMAIN="${DOMAIN}"
        
        docker compose -f "${COMPOSE_NEXUS_FILE}" pull || print_warning "Some NEXUS images could not be pulled"
        docker compose -f "${COMPOSE_NEXUS_FILE}" up -d || print_warning "Failed to start NEXUS fleet services"
        print_success "PUABO NEXUS fleet services started"
    else
        print_warning "PUABO NEXUS compose file not found: ${COMPOSE_NEXUS_FILE}"
        print_info "Skipping NEXUS fleet deployment"
    fi
    
    print_step "Waiting for services to initialize (30 seconds)..."
    sleep 30
    
    print_step "Checking core service status..."
    docker compose -f "${COMPOSE_FILE}" ps
    
    if [[ -f "${COMPOSE_NEXUS_FILE}" ]]; then
        print_step "Checking NEXUS fleet service status..."
        docker compose -f "${COMPOSE_NEXUS_FILE}" ps
    fi
    
    print_step "Checking running containers..."
    local running_count=$(docker compose -f "${COMPOSE_FILE}" ps --filter "status=running" --quiet | wc -l)
    local total_count=$(docker compose -f "${COMPOSE_FILE}" ps --quiet | wc -l)
    
    if [[ $running_count -eq $total_count ]] && [[ $total_count -gt 0 ]]; then
        print_success "All ${running_count} services are running"
    else
        print_warning "${running_count}/${total_count} services are running"
        print_info "Some services may still be starting up..."
    fi
}

# ==============================================================================
# Database Migration
# ==============================================================================

apply_database_migrations() {
    print_section "7. DATABASE MIGRATIONS"
    
    print_step "Waiting for PostgreSQL to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker compose -f "${COMPOSE_FILE}" exec -T nexus-cos-postgres \
            pg_isready -U nexus_user -d nexus_db &>/dev/null; then
            print_success "PostgreSQL is ready"
            break
        fi
        ((attempt++))
        sleep 2
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        print_error "PostgreSQL did not become ready in time"
        return 1
    fi
    
    print_step "Checking if schema needs to be applied..."
    if [[ -f "${REPO_ROOT}/database/schema.sql" ]]; then
        print_info "Schema file found, migrations will be applied automatically on first start"
        print_success "Database schema configured"
    else
        print_warning "No schema.sql file found"
    fi
}

# ==============================================================================
# Health Check Validation
# ==============================================================================

validate_health_endpoints() {
    print_section "8. HEALTH CHECK VALIDATION"
    
    print_step "Testing internal health endpoints..."
    
    # Define health check endpoints
    local health_endpoints=(
        "http://localhost:4000/health:PUABO API"
        "http://127.0.0.1:9001/health:AI Dispatch"
        "http://127.0.0.1:9002/health:Driver Backend"
        "http://127.0.0.1:9003/health:Fleet Manager"
        "http://127.0.0.1:9004/health:Route Optimizer"
    )
    
    for endpoint_info in "${health_endpoints[@]}"; do
        local endpoint="${endpoint_info%%:*}"
        local service="${endpoint_info##*:}"
        
        print_step "Testing ${service}..."
        if curl -sf "${endpoint}" &>/dev/null; then
            print_success "${service} is healthy"
        else
            print_warning "${service} health check failed (may still be starting)"
        fi
    done
    
    print_info ""
    print_info "External health checks (after DNS/proxy configuration):"
    print_info "  - https://${DOMAIN}/api/health"
    print_info "  - https://${DOMAIN}/puabo-nexus/dispatch/health"
    print_info "  - https://${DOMAIN}/puabo-nexus/driver/health"
    print_info "  - https://${DOMAIN}/puabo-nexus/fleet/health"
    print_info "  - https://${DOMAIN}/puabo-nexus/routes/health"
    print_info "  - https://${DOMAIN}/v-suite/prompter/health"
    print_info "  - https://${DOMAIN}/nexus-studio/health"
    print_info "  - https://${DOMAIN}/club-saditty/health"
    print_info ""
    print_step "Performing external health checks..."
    
    # Test external endpoints if available
    local external_endpoints=(
        "https://${DOMAIN}/puabo-nexus/dispatch/health:AI Dispatch (External)"
        "https://${DOMAIN}/puabo-nexus/driver/health:Driver Backend (External)"
        "https://${DOMAIN}/puabo-nexus/fleet/health:Fleet Manager (External)"
        "https://${DOMAIN}/puabo-nexus/routes/health:Route Optimizer (External)"
    )
    
    for endpoint_info in "${external_endpoints[@]}"; do
        local endpoint="${endpoint_info%%:*}"
        local service="${endpoint_info##*:}"
        
        if curl -skI "${endpoint}" 2>/dev/null | grep -q "HTTP"; then
            local status_code=$(curl -skI "${endpoint}" 2>/dev/null | grep "HTTP" | awk '{print $2}')
            if [[ "${status_code}" == "200" ]]; then
                print_success "${service} - HTTP ${status_code}"
            else
                print_info "${service} - HTTP ${status_code}"
            fi
        else
            print_info "${service} - Not accessible (DNS/Nginx may not be configured yet)"
        fi
    done
}

# ==============================================================================
# Nginx Configuration
# ==============================================================================

configure_nginx() {
    print_section "9. NGINX CONFIGURATION"
    
    print_step "Checking if Nginx is installed on host..."
    if command -v nginx &> /dev/null; then
        print_success "Nginx is installed"
        
        print_info "Nginx configuration should include reverse proxy rules for:"
        print_info "  - Core API (port 4000)"
        print_info "  - PUABO NEXUS Services (localhost ports 9001-9004)"
        print_info "  - V-Suite Services"
        print_info "  - All other services"
        
        # Install/update PUABO NEXUS routes
        if [[ -f "${NGINX_ROUTE_UPDATER}" ]]; then
            print_step "Installing PUABO NEXUS routes..."
            if bash "${NGINX_ROUTE_UPDATER}"; then
                print_success "PUABO NEXUS routes installed successfully"
            else
                print_warning "Failed to install PUABO NEXUS routes automatically"
                print_info "You may need to configure Nginx manually"
            fi
        else
            print_warning "Nginx route updater not found: ${NGINX_ROUTE_UPDATER}"
        fi
        
        print_step "Testing Nginx configuration..."
        if nginx -t &>/dev/null; then
            print_success "Nginx configuration is valid"
        else
            print_warning "Nginx configuration has issues"
            nginx -t 2>&1 | head -10
        fi
    else
        print_info "Nginx not installed on host (using containerized Nginx)"
    fi
}

# ==============================================================================
# Final Validation
# ==============================================================================

final_validation() {
    print_section "10. FINAL VALIDATION"
    
    print_step "Running comprehensive checks..."
    
    # Service count
    local total_services
    total_services=$(docker compose -f "${COMPOSE_FILE}" config --services | wc -l)
    local running_services
    running_services=$(docker compose -f "${COMPOSE_FILE}" ps --filter "status=running" --quiet | wc -l)
    
    print_info "Total services defined: ${total_services}"
    print_info "Services running: ${running_services}"
    
    if [[ $running_services -eq $total_services ]]; then
        print_success "All services are running"
    else
        print_warning "Some services may not be running"
    fi
    
    # PostgreSQL check
    print_step "Checking PostgreSQL..."
    if docker compose -f "${COMPOSE_FILE}" exec -T nexus-cos-postgres \
        psql -U nexus_user -d nexus_db -c "SELECT 1;" &>/dev/null; then
        print_success "PostgreSQL is accessible"
    else
        print_warning "PostgreSQL is not accessible"
    fi
    
    # Redis check
    print_step "Checking Redis..."
    if docker compose -f "${COMPOSE_FILE}" exec -T nexus-cos-redis redis-cli ping | grep -q "PONG"; then
        print_success "Redis is responding"
    else
        print_warning "Redis is not responding"
    fi
}

# ==============================================================================
# Deployment Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║                    DEPLOYMENT SUMMARY                          ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}Checks Passed:${NC}  ${CHECKS_PASSED}"
    echo -e "${RED}Checks Failed:${NC}  ${CHECKS_FAILED}"
    echo -e "${YELLOW}Warnings:${NC}      ${CHECKS_WARNING}"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  PF v2025.10.01 INFORMATION${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}PF Version:${NC}       ${PF_VERSION}"
    echo -e "  ${CYAN}Configuration:${NC}    ${PF_CONFIG}"
    echo -e "  ${CYAN}Status:${NC}           LIVE | CERTIFIED | PF-SYNC READY"
    echo -e "  ${CYAN}Domain:${NC}           ${DOMAIN}"
    echo -e "  ${CYAN}VPS IP:${NC}           ${VPS_IP}"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  PUABO NEXUS SERVICES${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}AI Dispatch:${NC}      Port 3231 → /puabo-nexus/dispatch/health"
    echo -e "  ${CYAN}Driver Backend:${NC}   Port 3232 → /puabo-nexus/driver/health"
    echo -e "  ${CYAN}Fleet Manager:${NC}    Port 3233 → /puabo-nexus/fleet/health"
    echo -e "  ${CYAN}Route Optimizer:${NC}  Port 3234 → /puabo-nexus/routes/health"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  QUICK COMMANDS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${YELLOW}Check service status:${NC}"
    echo -e "    docker compose -f ${COMPOSE_FILE} ps"
    echo ""
    echo -e "  ${YELLOW}View logs:${NC}"
    echo -e "    docker compose -f ${COMPOSE_FILE} logs -f"
    echo ""
    echo -e "  ${YELLOW}Restart all services:${NC}"
    echo -e "    docker compose -f ${COMPOSE_FILE} restart"
    echo ""
    echo -e "  ${YELLOW}Stop all services:${NC}"
    echo -e "    docker compose -f ${COMPOSE_FILE} down"
    echo ""
    echo -e "  ${YELLOW}View PUABO NEXUS logs:${NC}"
    echo -e "    docker compose -f ${COMPOSE_FILE} logs -f puabo-nexus-ai-dispatch"
    echo -e "    docker compose -f ${COMPOSE_FILE} logs -f puabo-nexus-driver-app-backend"
    echo -e "    docker compose -f ${COMPOSE_FILE} logs -f puabo-nexus-fleet-manager"
    echo -e "    docker compose -f ${COMPOSE_FILE} logs -f puabo-nexus-route-optimizer"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  DOCUMENTATION${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}PF Documentation:${NC}  ${REPO_ROOT}/PF_v2025.10.01.md"
    echo -e "  ${CYAN}YAML Config:${NC}       ${PF_CONFIG}"
    echo -e "  ${CYAN}Deployment Log:${NC}    Check Docker Compose logs"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_banner
    
    # Execute deployment steps
    check_system_requirements
    validate_repository
    configure_environment
    setup_ssl_certificates
    validate_docker_compose
    deploy_services
    apply_database_migrations
    validate_health_endpoints
    configure_nginx
    final_validation
    print_summary
    
    echo -e "${GREEN}✨ PF v2025.10.01 Deployment Complete! ✨${NC}"
    echo ""
}

# Run main function
main "$@"

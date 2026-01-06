#!/bin/bash

# ==============================================================================
# Nexus COS - PF Final Deployment Script
# ==============================================================================
# Purpose: Complete system check and re-deployment for Nexus COS Pre-Flight
# Target VPS: 74.208.155.161 (n3xuscos.online)
# Created: 2025-10-03T14:46Z
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
REPO_ROOT="/opt/nexus-cos"
SSL_DIR="/opt/nexus-cos/ssl"
CERT_TARGET="${SSL_DIR}/nexus-cos.crt"
KEY_TARGET="${SSL_DIR}/nexus-cos.key"
ENV_FILE="${REPO_ROOT}/.env"
ENV_PF_FILE="${REPO_ROOT}/.env.pf"
NGINX_CONF_DIR="/etc/nginx"
DOMAIN="n3xuscos.online"

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║          NEXUS COS - PF FINAL DEPLOYMENT SCRIPT                ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
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
    echo -e "${YELLOW}▶${NC} $1"
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
    echo -e "${CYAN}ℹ${NC} $1"
}

# ==============================================================================
# Pre-Deployment System Checks
# ==============================================================================

check_system_requirements() {
    print_section "1. SYSTEM REQUIREMENTS CHECK"
    
    # Check if running as root or with sudo
    if [[ $EUID -ne 0 ]]; then
        print_warning "Not running as root. Some operations may require sudo."
    else
        print_success "Running with root privileges"
    fi
    
    # Check Docker
    print_step "Checking Docker installation..."
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | sed 's/,//')
        print_success "Docker installed: ${DOCKER_VERSION}"
    else
        print_error "Docker not installed. Install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    print_step "Checking Docker Compose installation..."
    if command -v docker compose &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
        print_success "Docker Compose installed: ${COMPOSE_VERSION}"
    else
        print_error "Docker Compose not installed. Install Docker Compose first."
        exit 1
    fi
    
    # Check Docker daemon
    print_step "Checking Docker daemon..."
    if docker info &> /dev/null; then
        print_success "Docker daemon is running"
    else
        print_error "Docker daemon is not running. Start Docker first."
        exit 1
    fi
    
    # Check Nginx
    print_step "Checking Nginx installation..."
    if command -v nginx &> /dev/null; then
        NGINX_VERSION=$(nginx -v 2>&1 | cut -d'/' -f2)
        print_success "Nginx installed: ${NGINX_VERSION}"
    else
        print_warning "Nginx not installed. Will skip Nginx configuration."
    fi
    
    # Check OpenSSL
    print_step "Checking OpenSSL..."
    if command -v openssl &> /dev/null; then
        OPENSSL_VERSION=$(openssl version | cut -d' ' -f2)
        print_success "OpenSSL installed: ${OPENSSL_VERSION}"
    else
        print_warning "OpenSSL not installed. SSL validation limited."
    fi
    
    # Check disk space
    print_step "Checking disk space..."
    AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAILABLE_SPACE -gt 5 ]]; then
        print_success "Available disk space: ${AVAILABLE_SPACE}GB"
    else
        print_warning "Low disk space: ${AVAILABLE_SPACE}GB (recommend 5GB+)"
    fi
    
    # Check required ports
    print_step "Checking required ports..."
    PORTS=(80 443 4000 3002 3041 5432 6379)
    for port in "${PORTS[@]}"; do
        if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
            print_warning "Port $port is already in use"
        else
            print_success "Port $port is available"
        fi
    done
}

# ==============================================================================
# Repository and File Validation
# ==============================================================================

validate_repository() {
    print_section "2. REPOSITORY VALIDATION"
    
    # Check if we're in the correct directory
    print_step "Checking repository location..."
    if [[ ! -f "docker-compose.pf.yml" ]]; then
        print_error "Not in Nexus COS repository root. Expected docker-compose.pf.yml"
        print_info "Please run this script from: ${REPO_ROOT}"
        exit 1
    fi
    print_success "Repository root validated"
    
    # Check essential files
    print_step "Checking essential PF files..."
    REQUIRED_FILES=(
        "docker-compose.pf.yml"
        ".env.pf"
        "nginx/nginx.conf"
        "nginx/conf.d/nexus-proxy.conf"
        "validate-pf.sh"
        "deploy-pf.sh"
    )
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            print_success "Found: $file"
        else
            print_error "Missing: $file"
        fi
    done
    
    # Check service directories
    print_step "Checking service directories..."
    SERVICE_DIRS=("services/puaboai-sdk" "services/pv-keys")
    for dir in "${SERVICE_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            print_success "Found: $dir"
        else
            print_warning "Missing: $dir (may be optional)"
        fi
    done
}

# ==============================================================================
# SSH Key Authorization Setup
# ==============================================================================

setup_ssh_keys() {
    print_section "2. SSH KEY AUTHORIZATION SETUP"
    
    print_step "Checking for VPS SSH public keys..."
    
    SSH_KEYS_FOUND=false
    VPS_KEYS=("vps_key.pub" "vps_key2.pub" "vps_key3.pub")
    
    for key_file in "${VPS_KEYS[@]}"; do
        if [[ -f "${REPO_ROOT}/${key_file}" ]]; then
            print_success "Found: $key_file"
            SSH_KEYS_FOUND=true
        fi
    done
    
    if [[ "$SSH_KEYS_FOUND" = true ]]; then
        print_step "Setting up authorized_keys for non-interactive deployment..."
        
        # Ensure .ssh directory exists
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        
        # Create or update authorized_keys
        touch ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
        
        # Add keys if not already present
        for key_file in "${VPS_KEYS[@]}"; do
            if [[ -f "${REPO_ROOT}/${key_file}" ]]; then
                KEY_CONTENT=$(cat "${REPO_ROOT}/${key_file}")
                if ! grep -qF "$KEY_CONTENT" ~/.ssh/authorized_keys 2>/dev/null; then
                    echo "$KEY_CONTENT" >> ~/.ssh/authorized_keys
                    print_success "Added $key_file to authorized_keys"
                else
                    print_info "$key_file already in authorized_keys"
                fi
            fi
        done
        
        print_success "SSH key authorization configured for non-interactive deploys"
    else
        print_warning "No VPS SSH keys found in repository"
        print_info "Non-interactive deployment from Windows may require manual key setup"
        print_info "Expected files: vps_key.pub, vps_key2.pub, vps_key3.pub"
    fi
}

# ==============================================================================
# SSL Certificate Management
# ==============================================================================

manage_ssl_certificates() {
    print_section "3. SSL CERTIFICATE MANAGEMENT"
    
    # Create SSL directory if it doesn't exist
    print_step "Creating SSL directory..."
    if [[ ! -d "$SSL_DIR" ]]; then
        mkdir -p "$SSL_DIR"
        print_success "Created: $SSL_DIR"
    else
        print_success "SSL directory exists: $SSL_DIR"
    fi
    
    # Look for SSL certificates in repository
    print_step "Searching for SSL certificates in repository..."
    
    SSL_FOUND=false
    
    # Check for fullchain.crt in root
    if [[ -f "fullchain.crt" ]]; then
        print_info "Found fullchain.crt in repository root"
        cp fullchain.crt "$CERT_TARGET"
        print_success "Copied fullchain.crt to $CERT_TARGET"
        SSL_FOUND=true
    fi
    
    # Check ssl/certs/ directory
    if [[ -d "ssl/certs" ]] && [[ -n "$(find ssl/certs -name "*.crt" -type f 2>/dev/null)" ]]; then
        FIRST_CERT=$(find ssl/certs -name "*.crt" -type f 2>/dev/null | head -1)
        print_info "Found certificate in ssl/certs/: $(basename $FIRST_CERT)"
        cp "$FIRST_CERT" "$CERT_TARGET"
        print_success "Copied $(basename $FIRST_CERT) to $CERT_TARGET"
        SSL_FOUND=true
    fi
    
    # Check ssl/ directory for any .crt file
    if [[ ! "$SSL_FOUND" = true ]] && [[ -d "ssl" ]] && [[ -n "$(find ssl -maxdepth 1 -name "*.crt" -type f 2>/dev/null)" ]]; then
        FIRST_CERT=$(find ssl -maxdepth 1 -name "*.crt" -type f 2>/dev/null | head -1)
        print_info "Found certificate in ssl/: $(basename $FIRST_CERT)"
        cp "$FIRST_CERT" "$CERT_TARGET"
        print_success "Copied $(basename $FIRST_CERT) to $CERT_TARGET"
        SSL_FOUND=true
    fi
    
    # Look for private keys
    print_step "Searching for SSL private keys..."
    
    KEY_FOUND=false
    
    # Check ssl/private/ directory
    if [[ -d "ssl/private" ]] && [[ -n "$(find ssl/private -name "*.key" -type f 2>/dev/null)" ]]; then
        FIRST_KEY=$(find ssl/private -name "*.key" -type f 2>/dev/null | head -1)
        print_info "Found private key in ssl/private/: $(basename $FIRST_KEY)"
        cp "$FIRST_KEY" "$KEY_TARGET"
        print_success "Copied $(basename $FIRST_KEY) to $KEY_TARGET"
        KEY_FOUND=true
    fi
    
    # Check ssl/ directory for any .key file
    if [[ ! "$KEY_FOUND" = true ]] && [[ -d "ssl" ]] && [[ -n "$(find ssl -maxdepth 1 -name "*.key" -type f 2>/dev/null)" ]]; then
        FIRST_KEY=$(find ssl -maxdepth 1 -name "*.key" -type f 2>/dev/null | head -1)
        print_info "Found private key in ssl/: $(basename $FIRST_KEY)"
        cp "$FIRST_KEY" "$KEY_TARGET"
        print_success "Copied $(basename $FIRST_KEY) to $KEY_TARGET"
        KEY_FOUND=true
    fi
    
    # Set permissions
    if [[ -f "$CERT_TARGET" ]] && [[ -f "$KEY_TARGET" ]]; then
        print_step "Setting SSL file permissions..."
        chmod 644 "$CERT_TARGET"
        chmod 600 "$KEY_TARGET"
        print_success "Certificate permissions set to 644"
        print_success "Private key permissions set to 600"
        
        # Validate SSL certificate
        print_step "Validating SSL certificate..."
        if openssl x509 -in "$CERT_TARGET" -text -noout &> /dev/null; then
            CERT_EXPIRY=$(openssl x509 -in "$CERT_TARGET" -noout -enddate | cut -d'=' -f2)
            print_success "Certificate is valid. Expires: $CERT_EXPIRY"
            
            # Check if certificate matches domain
            CERT_CN=$(openssl x509 -in "$CERT_TARGET" -noout -subject | grep -o 'CN=[^,]*' | cut -d'=' -f2)
            print_info "Certificate CN: $CERT_CN"
        else
            print_warning "Could not validate certificate format"
        fi
    else
        print_warning "SSL certificates not found. You may need to:"
        print_info "  1. Place fullchain.crt in repository root, OR"
        print_info "  2. Place *.crt in ssl/certs/ directory, OR"
        print_info "  3. Manually copy certificates to:"
        print_info "     - $CERT_TARGET (644 permissions)"
        print_info "     - $KEY_TARGET (600 permissions)"
    fi
}

# ==============================================================================
# Environment Configuration
# ==============================================================================

configure_environment() {
    print_section "4. ENVIRONMENT CONFIGURATION"
    
    # Check if .env.pf exists
    print_step "Checking .env.pf file..."
    if [[ ! -f "$ENV_PF_FILE" ]]; then
        print_error ".env.pf file not found!"
        print_info "Expected location: $ENV_PF_FILE"
        exit 1
    fi
    print_success ".env.pf file found"
    
    # Copy .env.pf to .env if .env doesn't exist or ask to overwrite
    print_step "Configuring .env file..."
    if [[ -f "$ENV_FILE" ]]; then
        print_warning ".env file already exists"
        read -p "Overwrite with .env.pf? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$ENV_PF_FILE" "$ENV_FILE"
            print_success "Copied .env.pf to .env"
        else
            print_info "Keeping existing .env file"
        fi
    else
        cp "$ENV_PF_FILE" "$ENV_FILE"
        print_success "Copied .env.pf to .env"
    fi
    
    # Check for required secrets
    print_step "Checking required environment variables..."
    
    REQUIRED_VARS=(
        "OAUTH_CLIENT_ID"
        "OAUTH_CLIENT_SECRET"
        "JWT_SECRET"
        "DB_PASSWORD"
    )
    
    SECRETS_MISSING=false
    for var in "${REQUIRED_VARS[@]}"; do
        VALUE=$(grep "^${var}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2)
        if [[ -z "$VALUE" ]] || [[ "$VALUE" == "your-"* ]] || [[ "$VALUE" == "<"* ]]; then
            print_warning "$var is not configured (contains placeholder)"
            SECRETS_MISSING=true
        else
            print_success "$var is configured"
        fi
    done
    
    if [[ "$SECRETS_MISSING" = true ]]; then
        print_warning ""
        print_warning "⚠️  IMPORTANT: Configure the following in .env before proceeding:"
        print_info "  - OAUTH_CLIENT_ID (OAuth client ID)"
        print_info "  - OAUTH_CLIENT_SECRET (OAuth client secret)"
        print_info "  - JWT_SECRET (should be a secure random string)"
        print_info "  - DB_PASSWORD (database password)"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled. Please configure .env and try again."
            exit 1
        fi
    fi
    
    # Check frontend environment configuration
    print_step "Validating frontend environment configuration..."
    FRONTEND_ENV="${REPO_ROOT}/frontend/.env"
    
    if [[ -f "$FRONTEND_ENV" ]]; then
        print_success "Frontend .env file found"
        
        # Check for localhost URLs in production
        if grep -q "localhost" "$FRONTEND_ENV" 2>/dev/null; then
            print_error "Frontend .env contains localhost URLs!"
            print_info "Production builds must use domain URLs, not localhost"
            grep "localhost" "$FRONTEND_ENV"
            print_info ""
            print_info "Expected production URLs:"
            print_info "  VITE_API_URL=/api"
            print_info "  VITE_V_SCREEN_URL=https://n3xuscos.online/v-suite/screen"
            print_info "  VITE_V_CASTER_URL=https://n3xuscos.online/v-suite/caster"
            print_info "  VITE_V_STAGE_URL=https://n3xuscos.online/v-suite/stage"
            print_info "  VITE_V_PROMPTER_URL=https://n3xuscos.online/v-suite/prompter"
            echo ""
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_error "Deployment cancelled. Please fix frontend .env and try again."
                exit 1
            fi
        else
            # Validate that required URLs are present
            if grep -q "VITE_API_URL" "$FRONTEND_ENV" && \
               grep -q "VITE_V_SCREEN_URL" "$FRONTEND_ENV"; then
                print_success "Frontend environment properly configured for production"
                VITE_API=$(grep "^VITE_API_URL=" "$FRONTEND_ENV" | cut -d'=' -f2)
                VITE_VSCREEN=$(grep "^VITE_V_SCREEN_URL=" "$FRONTEND_ENV" | cut -d'=' -f2)
                print_info "  VITE_API_URL: $VITE_API"
                print_info "  VITE_V_SCREEN_URL: $VITE_VSCREEN"
            else
                print_warning "Frontend .env missing V-Suite streaming URLs"
                print_info "Consider adding:"
                print_info "  VITE_V_SCREEN_URL=https://n3xuscos.online/v-suite/screen"
                print_info "  VITE_V_CASTER_URL=https://n3xuscos.online/v-suite/caster"
                print_info "  VITE_V_STAGE_URL=https://n3xuscos.online/v-suite/stage"
                print_info "  VITE_V_PROMPTER_URL=https://n3xuscos.online/v-suite/prompter"
            fi
        fi
    else
        print_warning "Frontend .env file not found at: $FRONTEND_ENV"
        print_info "Frontend may not build properly without environment configuration"
    fi
}

# ==============================================================================
# Docker Service Deployment
# ==============================================================================

deploy_services() {
    print_section "5. DOCKER SERVICE DEPLOYMENT"
    
    # Stop any existing containers
    print_step "Stopping existing containers..."
    if docker compose -f docker-compose.pf.yml ps -q 2>/dev/null | grep -q .; then
        docker compose -f docker-compose.pf.yml down
        print_success "Stopped existing containers"
    else
        print_info "No running containers found"
    fi
    
    # Pull latest images
    print_step "Pulling Docker images..."
    if docker compose -f docker-compose.pf.yml pull 2>&1 | grep -q "no such service"; then
        print_warning "Some services may not have pre-built images (will build locally)"
    else
        print_success "Docker images pulled"
    fi
    
    # Build and start services
    print_step "Building and starting services..."
    if docker compose -f docker-compose.pf.yml up -d --build; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        print_info "Check logs with: docker compose -f docker-compose.pf.yml logs"
        exit 1
    fi
    
    # Wait for services to be ready
    print_step "Waiting for services to be ready..."
    sleep 10
    
    # Check service status
    print_step "Checking service status..."
    RUNNING_SERVICES=$(docker compose -f docker-compose.pf.yml ps --services --filter "status=running" 2>/dev/null | wc -l)
    TOTAL_SERVICES=$(docker compose -f docker-compose.pf.yml ps --services 2>/dev/null | wc -l)
    
    if [[ $RUNNING_SERVICES -eq $TOTAL_SERVICES ]]; then
        print_success "All services are running ($RUNNING_SERVICES/$TOTAL_SERVICES)"
    else
        print_warning "Some services may not be running ($RUNNING_SERVICES/$TOTAL_SERVICES)"
    fi
    
    # Wait for PostgreSQL
    print_step "Waiting for PostgreSQL to be ready..."
    for i in {1..30}; do
        if docker compose -f docker-compose.pf.yml exec -T nexus-cos-postgres pg_isready -U nexus_user -d nexus_db &>/dev/null; then
            print_success "PostgreSQL is ready"
            break
        fi
        if [[ $i -eq 30 ]]; then
            print_error "PostgreSQL failed to start within 60 seconds"
        fi
        sleep 2
    done
    
    # Apply database migrations
    print_step "Applying database migrations..."
    if docker compose -f docker-compose.pf.yml exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -f /docker-entrypoint-initdb.d/schema.sql &>/dev/null; then
        print_success "Database migrations applied"
    else
        print_warning "Database migrations may have already been applied"
    fi
}

# ==============================================================================
# Nginx Configuration
# ==============================================================================

configure_nginx() {
    print_section "6. NGINX CONFIGURATION"
    
    # Check if Nginx is installed
    if ! command -v nginx &> /dev/null; then
        print_warning "Nginx not installed. Skipping Nginx configuration."
        print_info "To use Nginx, install it and run this script again."
        return
    fi
    
    # Check if nginx configs exist in repository
    print_step "Checking Nginx configuration files..."
    if [[ -f "nginx/nginx.conf" ]] && [[ -f "nginx/conf.d/nexus-proxy.conf" ]]; then
        print_success "Nginx configuration files found"
    else
        print_warning "Nginx configuration files not found in repository"
        return
    fi
    
    # Offer to deploy nginx configs
    read -p "Deploy Nginx configurations to ${NGINX_CONF_DIR}? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping Nginx deployment"
        return
    fi
    
    # Backup existing configs
    print_step "Backing up existing Nginx configs..."
    BACKUP_DIR="/tmp/nginx-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    if [[ -d "${NGINX_CONF_DIR}/sites-available" ]]; then
        cp -r "${NGINX_CONF_DIR}/sites-available" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    if [[ -d "${NGINX_CONF_DIR}/conf.d" ]]; then
        cp -r "${NGINX_CONF_DIR}/conf.d" "$BACKUP_DIR/" 2>/dev/null || true
    fi
    print_success "Backup created: $BACKUP_DIR"
    
    # Deploy nginx configs
    print_step "Deploying Nginx configurations..."
    cp nginx/nginx.conf "${NGINX_CONF_DIR}/sites-available/nexus-cos.conf" 2>/dev/null || true
    cp nginx/conf.d/nexus-proxy.conf "${NGINX_CONF_DIR}/conf.d/nexus-proxy.conf" 2>/dev/null || true
    
    # Enable site
    if [[ -d "${NGINX_CONF_DIR}/sites-enabled" ]]; then
        ln -sf "${NGINX_CONF_DIR}/sites-available/nexus-cos.conf" "${NGINX_CONF_DIR}/sites-enabled/" 2>/dev/null || true
    fi
    print_success "Nginx configurations deployed"
    
    # Test nginx configuration
    print_step "Testing Nginx configuration..."
    if nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx configuration is valid"
        
        # Reload nginx
        print_step "Reloading Nginx..."
        if systemctl reload nginx 2>/dev/null; then
            print_success "Nginx reloaded successfully"
        elif service nginx reload 2>/dev/null; then
            print_success "Nginx reloaded successfully"
        else
            print_warning "Could not reload Nginx automatically. Run: sudo systemctl reload nginx"
        fi
    else
        print_error "Nginx configuration test failed"
        print_info "Check with: nginx -t"
        print_info "Restore backup from: $BACKUP_DIR"
    fi
}

# ==============================================================================
# Post-Deployment Validation
# ==============================================================================

validate_deployment() {
    print_section "7. POST-DEPLOYMENT VALIDATION"
    
    # Test health endpoints
    print_step "Testing service health endpoints..."
    
    ENDPOINTS=(
        "http://localhost:4000/health:puabo-api"
        "http://localhost:3002/health:puaboai-sdk"
        "http://localhost:3041/health:pv-keys"
    )
    
    for endpoint_info in "${ENDPOINTS[@]}"; do
        IFS=':' read -r endpoint name <<< "$endpoint_info"
        if curl -s -f -m 5 "$endpoint" > /dev/null 2>&1; then
            print_success "$name health check passed"
        else
            print_error "$name health check failed"
            print_info "  URL: $endpoint"
            print_info "  Try: curl $endpoint"
        fi
    done
    
    # Check V-Suite Streaming Services routing (if Nginx is configured)
    if command -v nginx &> /dev/null && systemctl is-active --quiet nginx 2>/dev/null; then
        print_step "Testing V-Suite streaming routes..."
        
        # Test V-Screen/Hollywood (port 8088)
        if curl -s -f -m 5 "http://localhost:8088/health" > /dev/null 2>&1; then
            print_success "V-Screen Hollywood service is running (port 8088)"
        else
            print_warning "V-Screen Hollywood not accessible on port 8088"
        fi
        
        # Test V-Prompter Pro routing
        if curl -s -f -m 5 "http://localhost/v-suite/prompter/health" > /dev/null 2>&1; then
            print_success "V-Prompter Pro local routing works"
        else
            print_warning "V-Prompter Pro local routing not accessible"
            print_info "  This is normal if Nginx is not configured for localhost"
        fi
        
        # Test production URLs if domain resolves
        if host "$DOMAIN" &> /dev/null; then
            print_step "Testing production V-Suite streaming URLs..."
            
            STREAMING_ENDPOINTS=(
                "/v-suite/screen:V-Screen (via /v-suite/screen)"
                "/v-screen:V-Screen (via /v-screen direct)"
                "/v-suite/hollywood:V-Hollywood"
                "/v-suite/prompter:V-Prompter Pro"
                "/v-suite/caster:V-Caster"
                "/v-suite/stage:V-Stage"
            )
            
            for endpoint_info in "${STREAMING_ENDPOINTS[@]}"; do
                IFS=':' read -r path name <<< "$endpoint_info"
                if curl -s -f -m 10 "https://${DOMAIN}${path}" > /dev/null 2>&1; then
                    print_success "$name is accessible"
                else
                    print_warning "$name not yet accessible"
                    print_info "  URL: https://${DOMAIN}${path}"
                fi
            done
        fi
    fi
    
    # Check database tables
    print_step "Checking database tables..."
    TABLES=$(docker compose -f docker-compose.pf.yml exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" 2>/dev/null | grep -v "^$" || echo "")
    
    if [[ -n "$TABLES" ]]; then
        TABLE_COUNT=$(echo "$TABLES" | wc -l)
        print_success "Database has $TABLE_COUNT tables"
    else
        print_warning "Could not retrieve database tables"
    fi
    
    # Check Docker logs for errors
    print_step "Checking for errors in Docker logs..."
    ERROR_COUNT=$(docker compose -f docker-compose.pf.yml logs --tail=50 2>&1 | grep -i "error" | wc -l)
    if [[ $ERROR_COUNT -eq 0 ]]; then
        print_success "No errors found in recent logs"
    else
        print_warning "Found $ERROR_COUNT error messages in logs"
        print_info "Review with: docker compose -f docker-compose.pf.yml logs"
    fi
}

# ==============================================================================
# Deployment Summary
# ==============================================================================

print_summary() {
    print_section "8. DEPLOYMENT SUMMARY"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                     DEPLOYMENT COMPLETE                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${GREEN}✓ Passed:  ${CHECKS_PASSED}${NC}"
    echo -e "${YELLOW}⚠ Warnings: ${CHECKS_WARNING}${NC}"
    echo -e "${RED}✗ Failed:  ${CHECKS_FAILED}${NC}"
    echo ""
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  Deployment completed with some issues.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  SERVICE ENDPOINTS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}Gateway API:${NC}      http://localhost:4000"
    echo -e "  ${CYAN}AI SDK:${NC}           http://localhost:3002"
    echo -e "  ${CYAN}PV Keys:${NC}          http://localhost:3041"
    echo -e "  ${CYAN}PostgreSQL:${NC}       localhost:5432"
    echo -e "  ${CYAN}Redis:${NC}            localhost:6379"
    echo -e "  ${CYAN}Streamcore:${NC}       http://localhost:3016"
    echo -e "  ${CYAN}V-Screen:${NC}         http://localhost:8088"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  V-SUITE STREAMING ROUTES${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${CYAN}V-Screen:${NC}         https://${DOMAIN}/v-suite/screen"
    echo -e "                        https://${DOMAIN}/v-screen (alternative)"
    echo -e "  ${CYAN}V-Hollywood:${NC}      https://${DOMAIN}/v-suite/hollywood"
    echo -e "  ${CYAN}V-Prompter Pro:${NC}   https://${DOMAIN}/v-suite/prompter"
    echo -e "  ${CYAN}V-Caster:${NC}         https://${DOMAIN}/v-suite/caster"
    echo -e "  ${CYAN}V-Stage:${NC}          https://${DOMAIN}/v-suite/stage"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  QUICK COMMANDS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${YELLOW}Check service status:${NC}"
    echo -e "    docker compose -f docker-compose.pf.yml ps"
    echo ""
    echo -e "  ${YELLOW}View logs:${NC}"
    echo -e "    docker compose -f docker-compose.pf.yml logs -f"
    echo ""
    echo -e "  ${YELLOW}Test health endpoints:${NC}"
    echo -e "    curl http://localhost:4000/health"
    echo -e "    curl http://localhost:3002/health"
    echo -e "    curl http://localhost:3041/health"
    echo -e "    curl http://localhost:8088/health"
    echo ""
    echo -e "  ${YELLOW}Validate streaming routes:${NC}"
    echo -e "    ./scripts/validate-streaming-routes.sh"
    echo ""
    echo -e "  ${YELLOW}Access database:${NC}"
    echo -e "    docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db"
    echo ""
    echo -e "  ${YELLOW}Stop services:${NC}"
    echo -e "    docker compose -f docker-compose.pf.yml down"
    echo ""
    
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  NEXT STEPS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  1. ✓ Services deployed and running"
    echo "  2. ⏳ Test V-Prompter Pro: https://${DOMAIN}/v-suite/prompter/health"
    echo "  3. ⏳ Monitor logs for any issues"
    echo "  4. ⏳ Configure DNS if not already done"
    echo "  5. ⏳ Test all application routes"
    echo "  6. ⏳ Set up monitoring and alerting"
    echo "  7. ⏳ Document any custom configurations"
    echo ""
    
    echo -e "${CYAN}📚 For more information, see:${NC}"
    echo -e "  - ${PWD}/docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md"
    echo -e "  - ${PWD}/PF_README.md"
    echo -e "  - ${PWD}/PF_DEPLOYMENT_CHECKLIST.md"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    # Execute deployment steps
    check_system_requirements
    validate_repository
    setup_ssh_keys
    manage_ssl_certificates
    configure_environment
    deploy_services
    configure_nginx
    validate_deployment
    print_summary
    
    echo -e "${GREEN}✨ PF Final Deployment Script Complete! ✨${NC}"
    echo ""
}

# Run main function
main "$@"

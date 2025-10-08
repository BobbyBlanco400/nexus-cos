#!/bin/bash

# ==============================================================================
# NEXUS COS PHASE 2.5 - OTT INTEGRATION + BETA TRANSITION DEPLOYMENT
# ==============================================================================
# Purpose: Deploy unified Phase 2.5 architecture with OTT, V-Suite, and Beta
# Author: TRAE SOLO (GitHub Code Agent)
# PF ID: PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5
# ==============================================================================

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(dirname "$SCRIPT_DIR")"
readonly DEPLOYMENT_DATE=$(date +%Y-%m-%d)
readonly TRANSITION_DATE="2025-11-17"

# Directories
readonly WWW_APEX="/var/www/nexuscos.online"
readonly WWW_BETA="/var/www/beta.nexuscos.online"
readonly LOG_DIR="/opt/nexus-cos/logs/phase2.5"
readonly BACKUP_DIR="/opt/nexus-cos/backups/phase2.5"
readonly NGINX_CONF_DIR="/etc/nginx/sites-available"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║       NEXUS COS PHASE 2.5 - OTT INTEGRATION DEPLOYMENT        ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║              PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5         ║${NC}"
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
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

fatal_error() {
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                     DEPLOYMENT FAILED                          ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${RED}Error: $1${NC}"
    echo ""
    exit 1
}

# ==============================================================================
# Pre-Flight Checks
# ==============================================================================

check_prerequisites() {
    print_section "1. PRE-FLIGHT CHECKS"
    
    print_step "Checking system requirements..."
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        fatal_error "Please run with sudo or as root user"
    fi
    print_success "Running as root"
    
    # Check required commands
    local required_commands=("nginx" "docker" "curl" "openssl")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            print_success "$cmd is installed"
        else
            print_error "$cmd is not installed"
            fatal_error "Required command '$cmd' is missing"
        fi
    done
    
    # Check repository location
    if [[ ! -d "/opt/nexus-cos" ]]; then
        print_error "Repository not found at /opt/nexus-cos"
        fatal_error "Please clone repository to /opt/nexus-cos first"
    fi
    print_success "Repository found at /opt/nexus-cos"
    
    # Check if Docker is running
    if systemctl is-active --quiet docker; then
        print_success "Docker service is running"
    else
        print_error "Docker service is not running"
        fatal_error "Please start Docker service first"
    fi
}

# ==============================================================================
# Directory Setup
# ==============================================================================

setup_directories() {
    print_section "2. DIRECTORY SETUP"
    
    print_step "Creating Phase 2.5 directory structure..."
    
    # Create web directories
    mkdir -p "$WWW_APEX"
    mkdir -p "$WWW_BETA"
    print_success "Web directories created"
    
    # Create log directories
    mkdir -p "$LOG_DIR/ott"
    mkdir -p "$LOG_DIR/dashboard"
    mkdir -p "$LOG_DIR/beta"
    mkdir -p "$LOG_DIR/transition"
    print_success "Log directories created"
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    print_success "Backup directory created"
    
    # Set proper permissions
    chown -R www-data:www-data "$WWW_APEX" "$WWW_BETA" || true
    chmod -R 755 "$WWW_APEX" "$WWW_BETA"
    print_success "Permissions configured"
}

# ==============================================================================
# Deploy Landing Pages
# ==============================================================================

deploy_landing_pages() {
    print_section "3. DEPLOYING LANDING PAGES"
    
    # Deploy Apex (Production) landing page
    print_step "Deploying apex landing page..."
    if [[ -f "${REPO_ROOT}/apex/index.html" ]]; then
        cp "${REPO_ROOT}/apex/index.html" "$WWW_APEX/"
        print_success "Apex landing page deployed to $WWW_APEX"
    else
        print_warning "Apex landing page not found in repository"
    fi
    
    # Deploy Beta landing page
    print_step "Deploying beta landing page..."
    if [[ -f "${REPO_ROOT}/web/beta/index.html" ]]; then
        cp "${REPO_ROOT}/web/beta/index.html" "$WWW_BETA/"
        print_success "Beta landing page deployed to $WWW_BETA"
    else
        print_warning "Beta landing page not found in repository"
    fi
}

# ==============================================================================
# Configure Nginx
# ==============================================================================

configure_nginx() {
    print_section "4. CONFIGURING NGINX"
    
    print_step "Backing up existing nginx configuration..."
    if [[ -f "$NGINX_CONF_DIR/nexuscos" ]]; then
        cp "$NGINX_CONF_DIR/nexuscos" "$BACKUP_DIR/nexuscos.conf.$(date +%Y%m%d_%H%M%S)"
        print_success "Nginx configuration backed up"
    fi
    
    print_step "Generating Phase 2.5 nginx configuration..."
    
    cat > "$NGINX_CONF_DIR/nexuscos-phase-2.5" << 'NGINX_EOF'
# ==============================================================================
# NEXUS COS PHASE 2.5 - OTT INTEGRATION + BETA TRANSITION
# PF ID: PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5
# ==============================================================================

# Production Domain - nexuscos.online
server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;
    
    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/apex/nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/apex/nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Logging
    access_log /opt/nexus-cos/logs/phase2.5/ott/access.log;
    error_log /opt/nexus-cos/logs/phase2.5/ott/error.log;
    
    # OTT Frontend - Public Streaming Interface
    location / {
        root /var/www/nexuscos.online;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # V-Suite Dashboard - Creator Control Center
    location /v-suite/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Logging for dashboard access
        access_log /opt/nexus-cos/logs/phase2.5/dashboard/access.log;
        error_log /opt/nexus-cos/logs/phase2.5/dashboard/error.log;
    }
    
    # API Gateway - Backend Services
    location /api/ {
        proxy_pass http://localhost:4000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Health Check Endpoint
    location /health/gateway {
        proxy_pass http://localhost:4000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}

# Beta Domain - beta.nexuscos.online (Active until Nov 17, 2025)
server {
    listen 80;
    server_name beta.nexuscos.online;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    # IONOS SSL Certificates
    ssl_certificate /etc/nginx/ssl/beta/beta.nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/beta/beta.nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # Logging
    access_log /opt/nexus-cos/logs/phase2.5/beta/access.log;
    error_log /opt/nexus-cos/logs/phase2.5/beta/error.log;
    
    # Beta Landing Page
    location / {
        root /var/www/beta.nexuscos.online;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Beta Health Check
    location /beta/health {
        proxy_pass http://localhost:4000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
    
    # V-Suite Prompter Health (Beta-specific)
    location /v-suite/prompter/health {
        proxy_pass http://localhost:3002/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
NGINX_EOF
    
    print_success "Nginx configuration generated"
    
    # Enable site
    print_step "Enabling Phase 2.5 configuration..."
    ln -sf "$NGINX_CONF_DIR/nexuscos-phase-2.5" /etc/nginx/sites-enabled/nexuscos
    
    # Test configuration
    print_step "Testing nginx configuration..."
    if nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration validation failed"
        fatal_error "Please check nginx configuration syntax"
    fi
    
    # Reload nginx
    print_step "Reloading nginx..."
    if systemctl reload nginx; then
        print_success "Nginx reloaded successfully"
    else
        print_error "Failed to reload nginx"
        fatal_error "Nginx reload failed"
    fi
}

# ==============================================================================
# Deploy Backend Services
# ==============================================================================

deploy_backend_services() {
    print_section "5. DEPLOYING BACKEND SERVICES"
    
    print_step "Checking for docker-compose.pf.yml..."
    if [[ ! -f "/opt/nexus-cos/docker-compose.pf.yml" ]]; then
        print_warning "docker-compose.pf.yml not found, skipping backend deployment"
        return
    fi
    
    print_step "Starting backend services..."
    cd /opt/nexus-cos
    
    if docker compose -f docker-compose.pf.yml up -d; then
        print_success "Backend services started"
    else
        print_warning "Backend services may have issues, check logs"
    fi
    
    print_step "Waiting for services to initialize..."
    sleep 10
}

# ==============================================================================
# Health Checks
# ==============================================================================

run_health_checks() {
    print_section "6. RUNNING HEALTH CHECKS"
    
    local endpoints=(
        "http://localhost:4000/health|Gateway API"
        "http://localhost:3002/health|V-Prompter Pro"
        "http://localhost:3041/health|PV Keys"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS='|' read -r url name <<< "$endpoint_info"
        print_step "Checking $name..."
        
        if curl -sf "$url" &>/dev/null; then
            print_success "$name is healthy"
        else
            print_warning "$name is not responding (may not be deployed yet)"
        fi
    done
}

# ==============================================================================
# Setup Transition Automation
# ==============================================================================

setup_transition_automation() {
    print_section "7. TRANSITION AUTOMATION SETUP"
    
    print_step "Creating beta transition cutover script..."
    
    cat > "$REPO_ROOT/scripts/beta-transition-cutover.sh" << 'CUTOVER_EOF'
#!/bin/bash
# Beta to Production Transition - Automated Cutover
# Execution Date: November 17, 2025 00:00 UTC

set -euo pipefail

BACKUP_DIR="/opt/nexus-cos/backups/beta-transition"
LOG_FILE="/opt/nexus-cos/logs/phase2.5/transition/cutover-$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

exec &> >(tee -a "$LOG_FILE")

echo "=== BETA TO PRODUCTION TRANSITION ==="
echo "Date: $(date)"
echo "======================================="

# Backup current configuration
echo "Backing up current beta configuration..."
cp /etc/nginx/sites-available/nexuscos-phase-2.5 \
   "$BACKUP_DIR/nexuscos-phase-2.5.pre-transition"

# Create post-transition configuration
echo "Creating post-transition redirect configuration..."
cat > /etc/nginx/sites-available/nexuscos-post-transition << 'EOF'
# Post-Transition Configuration (After Nov 17, 2025)

# Permanent redirect from beta to production
server {
    listen 80;
    server_name beta.nexuscos.online;
    return 301 https://nexuscos.online$request_uri;
}

server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    ssl_certificate /etc/nginx/ssl/beta/beta.nexuscos.online.crt;
    ssl_certificate_key /etc/nginx/ssl/beta/beta.nexuscos.online.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Redirect all traffic to production
    return 301 https://nexuscos.online$request_uri;
}
EOF

# Enable new configuration
ln -sf /etc/nginx/sites-available/nexuscos-post-transition /etc/nginx/sites-enabled/nexuscos

# Test configuration
echo "Testing nginx configuration..."
if nginx -t; then
    echo "✓ Configuration valid"
else
    echo "✗ Configuration invalid, rolling back..."
    ln -sf /etc/nginx/sites-available/nexuscos-phase-2.5 /etc/nginx/sites-enabled/nexuscos
    exit 1
fi

# Reload nginx
echo "Reloading nginx..."
if systemctl reload nginx; then
    echo "✓ Nginx reloaded successfully"
else
    echo "✗ Nginx reload failed, rolling back..."
    ln -sf /etc/nginx/sites-available/nexuscos-phase-2.5 /etc/nginx/sites-enabled/nexuscos
    systemctl reload nginx
    exit 1
fi

# Verify redirect
echo "Verifying redirect functionality..."
REDIRECT_TEST=$(curl -sI http://beta.nexuscos.online 2>/dev/null | grep -i "location: https://nexuscos.online")
if [[ -n "$REDIRECT_TEST" ]]; then
    echo "✓ Redirect verified successfully"
else
    echo "⚠ Redirect verification inconclusive"
fi

echo "======================================="
echo "✓ TRANSITION COMPLETE"
echo "Beta domain now redirects to production"
echo "======================================="
CUTOVER_EOF
    
    chmod +x "$REPO_ROOT/scripts/beta-transition-cutover.sh"
    print_success "Transition cutover script created"
    
    print_info "To schedule automatic cutover on Nov 17, 2025, add to root crontab:"
    print_info "0 0 17 11 2025 /opt/nexus-cos/scripts/beta-transition-cutover.sh"
}

# ==============================================================================
# Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}║              PHASE 2.5 DEPLOYMENT COMPLETE                     ║${NC}"
    echo -e "${GREEN}║                                                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Deployment Summary:${NC}"
    echo -e "  ${GREEN}✓${NC} Checks Passed: $CHECKS_PASSED"
    echo -e "  ${RED}✗${NC} Checks Failed: $CHECKS_FAILED"
    echo ""
    
    echo -e "${CYAN}System Layers:${NC}"
    echo -e "  ${GREEN}►${NC} OTT Frontend: https://nexuscos.online"
    echo -e "  ${GREEN}►${NC} V-Suite Dashboard: https://nexuscos.online/v-suite/"
    echo -e "  ${GREEN}►${NC} Beta Portal: https://beta.nexuscos.online (Until Nov 17, 2025)"
    echo ""
    
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "  1. Run validation: ./scripts/validate-phase-2.5-deployment.sh"
    echo -e "  2. Verify endpoints are accessible"
    echo -e "  3. Monitor logs in /opt/nexus-cos/logs/phase2.5/"
    echo -e "  4. Schedule transition cutover for Nov 17, 2025"
    echo ""
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ DEPLOYMENT SUCCESSFUL${NC}"
        echo ""
        return 0
    else
        echo -e "${YELLOW}⚠ DEPLOYMENT COMPLETED WITH WARNINGS${NC}"
        echo -e "  Please review errors above and address as needed."
        echo ""
        return 0
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    setup_directories
    deploy_landing_pages
    configure_nginx
    deploy_backend_services
    run_health_checks
    setup_transition_automation
    
    print_summary
}

# Run main function
main "$@"

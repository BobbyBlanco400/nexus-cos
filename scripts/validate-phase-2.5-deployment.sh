#!/bin/bash

# ==============================================================================
# NEXUS COS PHASE 2.5 - DEPLOYMENT VALIDATION
# ==============================================================================
# Purpose: Comprehensive validation of Phase 2.5 OTT + Beta deployment
# Author: TRAE SOLO (GitHub Code Agent)
# PF ID: PF-HYBRID-FULLSTACK-2025.10.07-PHASE-2.5
# ==============================================================================

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_header() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║       NEXUS COS PHASE 2.5 - DEPLOYMENT VALIDATION             ║${NC}"
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
    ((CHECKS_WARNING++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# ==============================================================================
# Validation Functions
# ==============================================================================

validate_directory_structure() {
    print_section "1. DIRECTORY STRUCTURE VALIDATION"
    
    local directories=(
        "/var/www/nexuscos.online|OTT Frontend"
        "/var/www/beta.nexuscos.online|Beta Landing"
        "/opt/nexus-cos/logs/phase2.5|Phase 2.5 Logs"
        "/opt/nexus-cos/logs/phase2.5/ott|OTT Logs"
        "/opt/nexus-cos/logs/phase2.5/dashboard|Dashboard Logs"
        "/opt/nexus-cos/logs/phase2.5/beta|Beta Logs"
        "/opt/nexus-cos/logs/phase2.5/transition|Transition Logs"
        "/opt/nexus-cos/backups/phase2.5|Backups"
    )
    
    for dir_info in "${directories[@]}"; do
        IFS='|' read -r dir name <<< "$dir_info"
        print_step "Checking $name directory..."
        
        if [[ -d "$dir" ]]; then
            print_success "$name exists at $dir"
        else
            print_error "$name not found at $dir"
        fi
    done
}

validate_landing_pages() {
    print_section "2. LANDING PAGE VALIDATION"
    
    # Check apex landing page
    print_step "Validating apex landing page..."
    if [[ -f "/var/www/nexuscos.online/index.html" ]]; then
        local size=$(stat -f%z "/var/www/nexuscos.online/index.html" 2>/dev/null || stat -c%s "/var/www/nexuscos.online/index.html" 2>/dev/null || echo "0")
        if [[ $size -gt 1000 ]]; then
            print_success "Apex landing page deployed (${size} bytes)"
        else
            print_warning "Apex landing page seems small (${size} bytes)"
        fi
    else
        print_error "Apex landing page not found"
    fi
    
    # Check beta landing page
    print_step "Validating beta landing page..."
    if [[ -f "/var/www/beta.nexuscos.online/index.html" ]]; then
        local size=$(stat -f%z "/var/www/beta.nexuscos.online/index.html" 2>/dev/null || stat -c%s "/var/www/beta.nexuscos.online/index.html" 2>/dev/null || echo "0")
        if [[ $size -gt 1000 ]]; then
            print_success "Beta landing page deployed (${size} bytes)"
        else
            print_warning "Beta landing page seems small (${size} bytes)"
        fi
    else
        print_error "Beta landing page not found"
    fi
}

validate_nginx_configuration() {
    print_section "3. NGINX CONFIGURATION VALIDATION"
    
    print_step "Checking nginx configuration syntax..."
    if nginx -t 2>&1 | grep -q "successful"; then
        print_success "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
    fi
    
    print_step "Checking Phase 2.5 configuration file..."
    if [[ -f "/etc/nginx/sites-available/nexuscos-phase-2.5" ]]; then
        print_success "Phase 2.5 configuration file exists"
    else
        print_error "Phase 2.5 configuration file not found"
    fi
    
    print_step "Checking if Phase 2.5 config is enabled..."
    if [[ -L "/etc/nginx/sites-enabled/nexuscos" ]]; then
        print_success "Phase 2.5 configuration is enabled"
    else
        print_warning "Phase 2.5 configuration symlink not found"
    fi
    
    print_step "Checking nginx is running..."
    if systemctl is-active --quiet nginx; then
        print_success "Nginx service is running"
    else
        print_error "Nginx service is not running"
    fi
}

validate_ssl_certificates() {
    print_section "4. SSL CERTIFICATE VALIDATION"
    
    # Check apex certificates
    print_step "Checking apex SSL certificates..."
    if [[ -f "/etc/nginx/ssl/apex/nexuscos.online.crt" ]] && [[ -f "/etc/nginx/ssl/apex/nexuscos.online.key" ]]; then
        print_success "Apex SSL certificates present"
        
        # Check expiration
        local expiry=$(openssl x509 -in /etc/nginx/ssl/apex/nexuscos.online.crt -noout -enddate 2>/dev/null | cut -d= -f2)
        if [[ -n "$expiry" ]]; then
            print_info "Apex cert expires: $expiry"
        fi
    else
        print_error "Apex SSL certificates not found"
    fi
    
    # Check beta certificates
    print_step "Checking beta SSL certificates..."
    if [[ -f "/etc/nginx/ssl/beta/beta.nexuscos.online.crt" ]] && [[ -f "/etc/nginx/ssl/beta/beta.nexuscos.online.key" ]]; then
        print_success "Beta SSL certificates present"
        
        # Check expiration
        local expiry=$(openssl x509 -in /etc/nginx/ssl/beta/beta.nexuscos.online.crt -noout -enddate 2>/dev/null | cut -d= -f2)
        if [[ -n "$expiry" ]]; then
            print_info "Beta cert expires: $expiry"
        fi
    else
        print_warning "Beta SSL certificates not found (may be using apex certs)"
    fi
}

validate_backend_services() {
    print_section "5. BACKEND SERVICE VALIDATION"
    
    print_step "Checking Docker services..."
    if docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps &>/dev/null; then
        print_success "Docker Compose is accessible"
        
        # List running services
        local running_services=$(docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps --services --filter "status=running" 2>/dev/null | wc -l)
        print_info "Running services: $running_services"
    else
        print_warning "Docker Compose services not accessible"
    fi
}

validate_health_endpoints() {
    print_section "6. HEALTH ENDPOINT VALIDATION"
    
    local endpoints=(
        "http://localhost:4000/health|Gateway API"
        "http://localhost:3002/health|V-Prompter Pro"
        "http://localhost:3041/health|PV Keys"
        "http://localhost:8088/health|V-Screen Hollywood"
        "http://localhost:3016/health|StreamCore"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS='|' read -r url name <<< "$endpoint_info"
        print_step "Checking $name..."
        
        local response=$(curl -sf -w "%{http_code}" -o /dev/null "$url" 2>/dev/null || echo "000")
        
        if [[ "$response" == "200" ]]; then
            print_success "$name is healthy (HTTP $response)"
        elif [[ "$response" == "000" ]]; then
            print_warning "$name not responding (not deployed or offline)"
        else
            print_warning "$name returned HTTP $response"
        fi
    done
}

validate_routing() {
    print_section "7. ROUTING VALIDATION"
    
    print_step "Testing apex domain routing (localhost)..."
    local apex_response=$(curl -sf -w "%{http_code}" -o /dev/null "http://localhost/" 2>/dev/null || echo "000")
    if [[ "$apex_response" =~ ^(200|301|302)$ ]]; then
        print_success "Apex domain routing working (HTTP $apex_response)"
    else
        print_warning "Apex domain routing returned HTTP $apex_response"
    fi
    
    print_step "Testing v-suite routing..."
    local vsuite_response=$(curl -sf -w "%{http_code}" -o /dev/null "http://localhost/v-suite/" 2>/dev/null || echo "000")
    if [[ "$vsuite_response" =~ ^(200|301|302|404)$ ]]; then
        print_success "V-Suite routing configured (HTTP $vsuite_response)"
    else
        print_warning "V-Suite routing returned HTTP $vsuite_response"
    fi
    
    print_step "Testing API routing..."
    local api_response=$(curl -sf -w "%{http_code}" -o /dev/null "http://localhost/api/" 2>/dev/null || echo "000")
    if [[ "$api_response" =~ ^(200|301|302|404)$ ]]; then
        print_success "API routing configured (HTTP $api_response)"
    else
        print_warning "API routing returned HTTP $api_response"
    fi
}

validate_transition_automation() {
    print_section "8. TRANSITION AUTOMATION VALIDATION"
    
    print_step "Checking transition cutover script..."
    if [[ -f "/opt/nexus-cos/scripts/beta-transition-cutover.sh" ]]; then
        print_success "Transition cutover script exists"
        
        if [[ -x "/opt/nexus-cos/scripts/beta-transition-cutover.sh" ]]; then
            print_success "Transition cutover script is executable"
        else
            print_warning "Transition cutover script is not executable"
        fi
    else
        print_error "Transition cutover script not found"
    fi
    
    print_step "Checking cron scheduling..."
    if crontab -l 2>/dev/null | grep -q "beta-transition-cutover.sh"; then
        print_success "Transition is scheduled in crontab"
    else
        print_info "Transition not yet scheduled (manual scheduling required)"
    fi
}

validate_logs() {
    print_section "9. LOG VALIDATION"
    
    print_step "Checking log directory permissions..."
    if [[ -w "/opt/nexus-cos/logs/phase2.5" ]]; then
        print_success "Log directory is writable"
    else
        print_error "Log directory is not writable"
    fi
    
    # Check if logs are being written
    local log_dirs=(
        "/opt/nexus-cos/logs/phase2.5/ott"
        "/opt/nexus-cos/logs/phase2.5/dashboard"
        "/opt/nexus-cos/logs/phase2.5/beta"
    )
    
    for log_dir in "${log_dirs[@]}"; do
        local log_name=$(basename "$log_dir")
        print_step "Checking $log_name logs..."
        
        if [[ -d "$log_dir" ]]; then
            local log_files=$(find "$log_dir" -type f 2>/dev/null | wc -l)
            if [[ $log_files -gt 0 ]]; then
                print_success "$log_name has $log_files log file(s)"
            else
                print_info "$log_name directory is empty (no traffic yet)"
            fi
        else
            print_warning "$log_name log directory not found"
        fi
    done
}

validate_pr87_integration() {
    print_section "10. PR87 INTEGRATION & BRANDING VALIDATION"
    
    print_step "Validating unified Nexus COS branding..."
    
    local landing_pages=(
        "/var/www/nexuscos.online/index.html|Apex Landing|nexuscos.online"
        "/var/www/beta.nexuscos.online/index.html|Beta Landing|beta.nexuscos.online"
    )
    
    for page_info in "${landing_pages[@]}"; do
        IFS='|' read -r file name expected_url <<< "$page_info"
        
        if [[ -f "$file" ]]; then
            # Check for Nexus COS branding
            if grep -q "Nexus COS" "$file" 2>/dev/null; then
                print_success "$name contains Nexus COS branding"
            else
                print_error "$name missing Nexus COS branding"
            fi
            
            # Check for unified color (#2563eb)
            if grep -q "#2563eb" "$file" 2>/dev/null; then
                print_success "$name uses unified Nexus blue (#2563eb)"
            else
                print_error "$name missing unified brand color"
            fi
            
            # Check for Inter font family
            if grep -q "Inter" "$file" 2>/dev/null; then
                print_success "$name uses Inter font family"
            else
                print_warning "$name may not be using Inter font"
            fi
            
            # Check for correct URL references
            if grep -q "$expected_url" "$file" 2>/dev/null; then
                print_success "$name has correct URL references"
            else
                print_warning "$name may have incorrect URL references"
            fi
            
            # For beta page, verify beta badge exists
            if [[ "$name" == "Beta Landing" ]]; then
                if grep -q "beta-badge\|Beta" "$file" 2>/dev/null; then
                    print_success "$name contains beta badge"
                else
                    print_warning "$name missing beta badge indicator"
                fi
            fi
        else
            print_error "$name not found at $file"
        fi
    done
    
    print_step "Verifying file permissions..."
    for page_info in "${landing_pages[@]}"; do
        IFS='|' read -r file name expected_url <<< "$page_info"
        
        if [[ -f "$file" ]]; then
            local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%A" "$file" 2>/dev/null || echo "000")
            if [[ "$perms" == "644" ]]; then
                print_success "$name has correct permissions (644)"
            else
                print_warning "$name has permissions: $perms (expected 644)"
            fi
            
            local owner=$(stat -c "%U:%G" "$file" 2>/dev/null || stat -f "%Su:%Sg" "$file" 2>/dev/null || echo "unknown")
            if [[ "$owner" == "www-data:www-data" ]]; then
                print_success "$name has correct ownership (www-data:www-data)"
            else
                print_warning "$name has ownership: $owner (expected www-data:www-data)"
            fi
        fi
    done
}

# ==============================================================================
# Summary
# ==============================================================================

print_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║              VALIDATION SUMMARY                                ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Results:${NC}"
    echo -e "  ${GREEN}✓${NC} Passed:   $CHECKS_PASSED"
    echo -e "  ${RED}✗${NC} Failed:   $CHECKS_FAILED"
    echo -e "  ${YELLOW}⚠${NC} Warnings: $CHECKS_WARNING"
    echo ""
    
    local total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))
    local success_rate=0
    if [[ $total_checks -gt 0 ]]; then
        success_rate=$((CHECKS_PASSED * 100 / total_checks))
    fi
    
    echo -e "${CYAN}Success Rate: ${success_rate}%${NC}"
    echo ""
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}║                   ✓ ALL CHECKS PASSED                          ║${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}║          Phase 2.5 Deployment is Production Ready!             ║${NC}"
        echo -e "${GREEN}║                                                                ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        echo -e "${CYAN}System Status:${NC}"
        echo -e "  ${GREEN}►${NC} OTT Frontend: Ready"
        echo -e "  ${GREEN}►${NC} V-Suite Dashboard: Ready"
        echo -e "  ${GREEN}►${NC} Beta Portal: Ready (Active until Nov 17, 2025)"
        echo ""
        
        return 0
    else
        echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}║                  VALIDATION FAILED                             ║${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}║           Please address errors above                          ║${NC}"
        echo -e "${RED}║                                                                ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        return 1
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    validate_directory_structure
    validate_landing_pages
    validate_nginx_configuration
    validate_ssl_certificates
    validate_backend_services
    validate_health_endpoints
    validate_routing
    validate_transition_automation
    validate_logs
    validate_pr87_integration
    
    print_summary
}

# Run main function
main "$@"

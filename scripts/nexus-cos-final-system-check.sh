#!/bin/bash

# ==============================================================================
# Nexus COS - Final Complete System Check & Confirmation
# ==============================================================================
# Purpose: Comprehensive validation of the entire Nexus COS Platform
#          including all services, configurations, and endpoints
# Version: PF v2025.10.01
# ==============================================================================

set -euo pipefail

# ==============================================================================
# Configuration
# ==============================================================================

readonly REPO_ROOT="${REPO_ROOT:-/opt/nexus-cos}"
readonly DOMAIN="${DOMAIN:-nexuscos.online}"
readonly VPS_IP="74.208.155.161"
readonly TIMEOUT=10

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
TOTAL_CHECKS=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}║     NEXUS COS - FINAL COMPLETE SYSTEM CHECK                   ║${NC}"
    echo -e "${CYAN}║     PF v2025.10.01 - Full Platform Validation                 ║${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Domain:${NC} ${DOMAIN}"
    echo -e "${YELLOW}VPS IP:${NC} ${VPS_IP}"
    echo -e "${YELLOW}Date:${NC} $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_subsection() {
    echo ""
    echo -e "${MAGENTA}─── $1 ───${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS_PASSED++))
    ((TOTAL_CHECKS++))
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((CHECKS_FAILED++))
    ((TOTAL_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((CHECKS_WARNING++))
    ((TOTAL_CHECKS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_command() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" &> /dev/null; then
        print_success "$name is installed"
        return 0
    else
        print_error "$name is not installed"
        return 1
    fi
}

check_file() {
    local file="$1"
    local name="$2"
    
    if [[ -f "$file" ]]; then
        print_success "$name exists: $file"
        return 0
    else
        print_error "$name not found: $file"
        return 1
    fi
}

check_url() {
    local url="$1"
    local name="$2"
    local expected_code="${3:-200}"
    
    local http_code
    http_code=$(curl -skI -m "${TIMEOUT}" -w "%{http_code}" -o /dev/null "$url" 2>/dev/null || echo "000")
    
    if [[ "$http_code" == "$expected_code" ]]; then
        print_success "$name - HTTP $http_code (${url})"
        return 0
    elif [[ "$http_code" == "000" ]]; then
        print_error "$name - Connection failed (${url})"
        return 1
    else
        print_warning "$name - HTTP $http_code (expected $expected_code) (${url})"
        return 1
    fi
}

check_internal_url() {
    local url="$1"
    local name="$2"
    
    if curl -sf -m "${TIMEOUT}" "$url" &>/dev/null; then
        print_success "$name is healthy (${url})"
        return 0
    else
        print_error "$name health check failed (${url})"
        return 1
    fi
}

# ==============================================================================
# System Requirements & Versions
# ==============================================================================

check_system_versions() {
    print_section "1. SYSTEM REQUIREMENTS & VERSIONS"
    
    print_step "Checking system versions..."
    
    check_command "docker" "Docker"
    if command -v docker &> /dev/null; then
        print_info "   Version: $(docker --version)"
    fi
    
    check_command "docker-compose" "Docker Compose (standalone)" || true
    if docker compose version &> /dev/null; then
        print_success "Docker Compose (plugin) is available"
        print_info "   Version: $(docker compose version)"
    fi
    
    check_command "nginx" "Nginx"
    if command -v nginx &> /dev/null; then
        print_info "   Version: $(nginx -v 2>&1)"
    fi
    
    check_command "curl" "curl"
    check_command "git" "Git"
    
    print_step "Checking system resources..."
    local disk_space=$(df -h "${REPO_ROOT}" 2>/dev/null | awk 'NR==2 {print $4}' || echo "unknown")
    local memory=$(free -h 2>/dev/null | awk 'NR==2 {print $2}' || echo "unknown")
    print_info "Disk space available: ${disk_space}"
    print_info "Total memory: ${memory}"
}

# ==============================================================================
# Deployment Artifacts
# ==============================================================================

check_deployment_artifacts() {
    print_section "2. DEPLOYMENT ARTIFACTS"
    
    print_subsection "Scripts"
    check_file "${REPO_ROOT}/scripts/deploy_hybrid_fullstack_pf.sh" "Main deployment script"
    check_file "${REPO_ROOT}/scripts/update-nginx-puabo-nexus-routes.sh" "Nginx route updater"
    
    print_subsection "Docker Compose Files"
    check_file "${REPO_ROOT}/docker-compose.pf.yml" "PF main compose file"
    check_file "${REPO_ROOT}/docker-compose.pf.nexus.yml" "PF NEXUS compose file"
    
    print_subsection "Nginx Configuration"
    check_file "${REPO_ROOT}/nginx/nginx.conf" "Nginx configuration"
    
    print_subsection "Environment Files"
    check_file "${REPO_ROOT}/.env.pf" "PF environment file"
    
    print_subsection "Documentation"
    check_file "${REPO_ROOT}/PF_v2025.10.01.md" "PF version documentation"
    check_file "${REPO_ROOT}/PF_v2025.10.01_HEALTH_CHECKS.md" "Health checks documentation"
}

# ==============================================================================
# Docker Stack Validation
# ==============================================================================

check_docker_stacks() {
    print_section "3. DOCKER STACK VALIDATION"
    
    print_subsection "Docker Compose Syntax Validation"
    
    if docker compose -f "${REPO_ROOT}/docker-compose.pf.yml" config &>/dev/null; then
        print_success "docker-compose.pf.yml syntax is valid"
    else
        print_error "docker-compose.pf.yml has syntax errors"
    fi
    
    if docker compose -f "${REPO_ROOT}/docker-compose.pf.nexus.yml" config &>/dev/null; then
        print_success "docker-compose.pf.nexus.yml syntax is valid"
    else
        print_error "docker-compose.pf.nexus.yml has syntax errors"
    fi
    
    print_subsection "Docker Stack Status"
    
    print_step "Checking PF main stack..."
    if docker compose -f "${REPO_ROOT}/docker-compose.pf.yml" ps &>/dev/null; then
        local running_count=$(docker compose -f "${REPO_ROOT}/docker-compose.pf.yml" ps --status running 2>/dev/null | grep -c "Up" || echo "0")
        if [[ $running_count -gt 0 ]]; then
            print_success "PF stack has $running_count running services"
        else
            print_warning "PF stack has no running services"
        fi
    else
        print_warning "PF stack status unavailable (may not be deployed)"
    fi
    
    print_step "Checking PF NEXUS stack..."
    if docker compose -f "${REPO_ROOT}/docker-compose.pf.nexus.yml" ps &>/dev/null; then
        local running_count=$(docker compose -f "${REPO_ROOT}/docker-compose.pf.nexus.yml" ps --status running 2>/dev/null | grep -c "Up" || echo "0")
        if [[ $running_count -gt 0 ]]; then
            print_success "PF NEXUS stack has $running_count running services"
        else
            print_warning "PF NEXUS stack has no running services"
        fi
    else
        print_warning "PF NEXUS stack status unavailable (may not be deployed)"
    fi
    
    print_subsection "Docker Networks"
    if docker network ls | grep -q "nexus-network\|cos-net"; then
        print_success "Docker networks are configured"
        docker network ls | grep "nexus-network\|cos-net" | while read line; do
            print_info "   $line"
        done
    else
        print_warning "Docker networks not found"
    fi
}

# ==============================================================================
# Nginx Configuration Validation
# ==============================================================================

check_nginx_config() {
    print_section "4. NGINX CONFIGURATION VALIDATION"
    
    print_step "Testing nginx configuration syntax..."
    if nginx -t &>/dev/null; then
        print_success "Nginx configuration is valid"
        nginx -t 2>&1 | grep -E "syntax|successful" | while read line; do
            print_info "   $line"
        done
    else
        print_error "Nginx configuration has errors"
        print_info "   Run 'nginx -t' for details"
    fi
    
    print_step "Checking nginx service status..."
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_success "Nginx service is active"
    elif pgrep nginx &>/dev/null; then
        print_success "Nginx process is running"
    else
        print_warning "Nginx service status unknown or not running"
    fi
}

# ==============================================================================
# SSL Certificate Validation
# ==============================================================================

check_ssl_certificate() {
    print_section "5. SSL CERTIFICATE VALIDATION"
    
    print_step "Checking SSL certificate for ${DOMAIN}..."
    
    local cert_info
    cert_info=$(echo | openssl s_client -servername "${DOMAIN}" -connect "${DOMAIN}:443" 2>/dev/null | openssl x509 -noout -subject -issuer -dates 2>/dev/null || echo "")
    
    if [[ -n "$cert_info" ]]; then
        print_success "SSL certificate retrieved for ${DOMAIN}"
        echo "$cert_info" | while read line; do
            print_info "   $line"
        done
    else
        print_warning "Could not retrieve SSL certificate for ${DOMAIN}"
    fi
    
    # Check certificate expiry
    local expiry_date
    expiry_date=$(echo | openssl s_client -servername "${DOMAIN}" -connect "${DOMAIN}:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2 || echo "")
    
    if [[ -n "$expiry_date" ]]; then
        local expiry_epoch
        expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
        local current_epoch=$(date +%s)
        local days_until_expiry=$(( (expiry_epoch - current_epoch) / 86400 ))
        
        if [[ $days_until_expiry -gt 30 ]]; then
            print_success "Certificate expires in $days_until_expiry days"
        elif [[ $days_until_expiry -gt 0 ]]; then
            print_warning "Certificate expires in $days_until_expiry days (renewal recommended)"
        else
            print_error "Certificate has expired"
        fi
    fi
}

# ==============================================================================
# Internal Health Endpoints
# ==============================================================================

check_internal_health() {
    print_section "6. INTERNAL HEALTH ENDPOINTS"
    
    print_step "Testing internal service health endpoints..."
    
    check_internal_url "http://127.0.0.1:9001/health" "AI Dispatch (port 9001)"
    check_internal_url "http://127.0.0.1:9002/health" "Driver Backend (port 9002)"
    check_internal_url "http://127.0.0.1:9003/health" "Fleet Manager (port 9003)"
    check_internal_url "http://127.0.0.1:9004/health" "Route Optimizer (port 9004)"
    
    print_info ""
    print_info "Note: Internal endpoints may be unavailable if services are running in Docker"
    print_info "      with different port mappings. Check external endpoints instead."
}

# ==============================================================================
# Preview URLs
# ==============================================================================

check_preview_urls() {
    print_section "7. PREVIEW URLS"
    
    print_step "Testing main portal URLs..."
    
    check_url "https://${DOMAIN}/" "Home Page" "200"
    check_url "https://${DOMAIN}/admin" "Admin Portal" "200"
    check_url "https://${DOMAIN}/hub" "Creator Hub" "200"
    check_url "https://${DOMAIN}/studio" "Studio" "200"
    check_url "https://${DOMAIN}/v-suite/prompter/health" "V-Suite Prompter Health" "200"
}

# ==============================================================================
# Service Health Endpoints
# ==============================================================================

check_service_health() {
    print_section "8. SERVICE HEALTH ENDPOINTS"
    
    print_subsection "Core Platform Services"
    check_url "https://${DOMAIN}/api/health" "Core API Gateway" "200"
    check_url "https://${DOMAIN}/health/gateway" "Gateway Health" "200"
    
    print_subsection "PUABO NEXUS Services"
    check_url "https://${DOMAIN}/puabo-nexus/dispatch/health" "AI Dispatch" "200"
    check_url "https://${DOMAIN}/puabo-nexus/driver/health" "Driver Backend" "200"
    check_url "https://${DOMAIN}/puabo-nexus/fleet/health" "Fleet Manager" "200"
    check_url "https://${DOMAIN}/puabo-nexus/routes/health" "Route Optimizer" "200"
    
    print_subsection "V-Suite Services"
    check_url "https://${DOMAIN}/v-suite/prompter/health" "V-Prompter Pro" "200"
    check_url "https://${DOMAIN}/v-suite/screen/health" "VScreen Hollywood" "200"
    
    print_subsection "Media & Entertainment"
    check_url "https://${DOMAIN}/nexus-studio/health" "Nexus Studio AI" "200"
    check_url "https://${DOMAIN}/club-saditty/health" "Club Saditty" "200"
    check_url "https://${DOMAIN}/puabo-dsp/health" "PUABO DSP" "200"
    check_url "https://${DOMAIN}/puabo-blac/health" "PUABO BLAC" "200"
    
    print_subsection "Authentication & Payment"
    check_url "https://${DOMAIN}/auth/health" "Nexus ID OAuth" "200"
    check_url "https://${DOMAIN}/payment/health" "Nexus Pay Gateway" "200"
}

# ==============================================================================
# Summary & Results
# ==============================================================================

print_summary() {
    print_section "SYSTEM CHECK SUMMARY"
    
    local success_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        success_rate=$((CHECKS_PASSED * 100 / TOTAL_CHECKS))
    fi
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                      RESULTS SUMMARY                           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}✓ Passed:${NC}      $CHECKS_PASSED"
    echo -e "${RED}✗ Failed:${NC}      $CHECKS_FAILED"
    echo -e "${YELLOW}⚠ Warnings:${NC}    $CHECKS_WARNING"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Total Checks:${NC}  $TOTAL_CHECKS"
    echo -e "${BOLD}Success Rate:${NC}  ${success_rate}%"
    echo ""
    
    # Overall status
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✓ SYSTEM STATUS: ALL CHECKS PASSED${NC}"
        echo ""
        echo -e "${GREEN}The Nexus COS Platform is fully operational!${NC}"
    elif [[ $CHECKS_FAILED -lt 5 ]]; then
        echo -e "${YELLOW}${BOLD}⚠ SYSTEM STATUS: MOSTLY OPERATIONAL${NC}"
        echo ""
        echo -e "${YELLOW}Some non-critical checks failed. Review the report above.${NC}"
    else
        echo -e "${RED}${BOLD}✗ SYSTEM STATUS: NEEDS ATTENTION${NC}"
        echo ""
        echo -e "${RED}Multiple checks failed. Please review and address issues.${NC}"
    fi
    echo ""
}

# ==============================================================================
# Useful Commands
# ==============================================================================

print_useful_commands() {
    print_section "USEFUL COMMANDS"
    
    echo -e "${CYAN}Re-run Systems Check:${NC}"
    echo "  nginx -t"
    echo "  docker compose -f docker-compose.pf.yml ps"
    echo "  docker compose -f docker-compose.pf.nexus.yml ps"
    echo "  curl -I https://${DOMAIN}/api/health"
    echo "  curl -I https://${DOMAIN}/puabo-nexus/fleet/health"
    echo ""
    
    echo -e "${CYAN}View Service Logs:${NC}"
    echo "  docker compose -f docker-compose.pf.yml logs -f"
    echo "  docker compose -f docker-compose.pf.nexus.yml logs -f"
    echo "  docker compose -f docker-compose.pf.yml logs -f <service-name>"
    echo ""
    
    echo -e "${CYAN}Restart Services:${NC}"
    echo "  docker compose -f docker-compose.pf.yml restart"
    echo "  docker compose -f docker-compose.pf.nexus.yml restart"
    echo "  systemctl restart nginx"
    echo ""
    
    echo -e "${CYAN}Redeploy (if needed):${NC}"
    echo "  bash ${REPO_ROOT}/scripts/deploy_hybrid_fullstack_pf.sh"
    echo ""
    
    echo -e "${CYAN}Check Specific Service Health:${NC}"
    echo "  curl -I https://${DOMAIN}/api/health"
    echo "  curl -I https://${DOMAIN}/puabo-nexus/dispatch/health"
    echo "  curl -I https://${DOMAIN}/v-suite/prompter/health"
    echo ""
}

# ==============================================================================
# Next Steps
# ==============================================================================

print_next_steps() {
    print_section "NEXT STEPS"
    
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ All systems operational!${NC}"
        echo ""
        echo "Preview URLs to visually confirm:"
        echo "  • https://${DOMAIN}/ (Home)"
        echo "  • https://${DOMAIN}/admin (Admin Portal)"
        echo "  • https://${DOMAIN}/hub (Creator Hub)"
        echo "  • https://${DOMAIN}/studio (Studio)"
        echo ""
        echo "No redeployment required at this time."
        echo ""
        echo "Your PF v2025.10.01 artifacts are present, Nginx config is valid,"
        echo "and both internal/external health checks completed successfully."
    else
        echo "Based on the checks above:"
        echo ""
        if [[ $CHECKS_FAILED -lt 5 ]]; then
            echo "1. Review failed checks above"
            echo "2. Check service logs for errors"
            echo "3. Restart affected services if needed"
        else
            echo "1. Review all failed checks carefully"
            echo "2. Check Docker service status"
            echo "3. Verify Nginx configuration"
            echo "4. Consider redeploying with: bash ${REPO_ROOT}/scripts/deploy_hybrid_fullstack_pf.sh"
        fi
        echo ""
    fi
    
    echo -e "${CYAN}For issues or questions:${NC}"
    echo "  • Check logs: docker compose logs -f"
    echo "  • Review documentation: ${REPO_ROOT}/PF_v2025.10.01.md"
    echo "  • Run health check: bash ${REPO_ROOT}/check-pf-v2025-health.sh"
    echo ""
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_banner
    
    # Run all checks
    check_system_versions
    check_deployment_artifacts
    check_docker_stacks
    check_nginx_config
    check_ssl_certificate
    check_internal_health
    check_preview_urls
    check_service_health
    
    # Print summary and recommendations
    print_summary
    print_useful_commands
    print_next_steps
    
    # Exit with appropriate code
    if [[ $CHECKS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"

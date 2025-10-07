#!/bin/bash

# ==============================================================================
# Nexus COS - Bulletproof PF Validation Script
# ==============================================================================
# Author: TRAE SOLO (GitHub Code Agent)
# Version: 1.0 BULLETPROOF
# Date: 2025-10-07
# ==============================================================================
# Comprehensive validation of deployed Nexus COS Production Framework
# ==============================================================================

set +e  # Don't exit on error - we want to collect all validation results

# ==============================================================================
# Configuration
# ==============================================================================

readonly REPO_ROOT="/opt/nexus-cos"
readonly COMPOSE_FILE="${REPO_ROOT}/docker-compose.pf.yml"
readonly ENV_FILE="${REPO_ROOT}/.env.pf"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# ==============================================================================
# Utility Functions
# ==============================================================================

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║          NEXUS COS - BULLETPROOF PF VALIDATION                 ║
║                                                                ║
║              Comprehensive System Validation                   ║
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

print_check() {
    echo -e "${YELLOW}[CHECK]${NC} $1"
    ((TOTAL_CHECKS++))
}

print_pass() {
    echo -e "${GREEN}  ✓${NC} $1"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}  ✗${NC} $1"
    ((FAILED_CHECKS++))
}

print_warn() {
    echo -e "${YELLOW}  ⚠${NC} $1"
    ((WARNING_CHECKS++))
}

print_info() {
    echo -e "${CYAN}  ℹ${NC} $1"
}

# ==============================================================================
# Validation Functions
# ==============================================================================

validate_infrastructure() {
    print_section "1. INFRASTRUCTURE VALIDATION"
    
    # Docker service
    print_check "Docker service status"
    if systemctl is-active --quiet docker; then
        print_pass "Docker service is running"
    else
        print_fail "Docker service is not running"
    fi
    
    # Docker Compose file
    print_check "Docker Compose configuration"
    if [[ -f "$COMPOSE_FILE" ]]; then
        print_pass "docker-compose.pf.yml exists"
        
        if docker compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
            print_pass "Docker Compose syntax is valid"
        else
            print_fail "Docker Compose syntax validation failed"
        fi
    else
        print_fail "docker-compose.pf.yml not found"
    fi
    
    # Environment file
    print_check "Environment configuration"
    if [[ -f "$ENV_FILE" ]]; then
        print_pass ".env.pf exists"
    else
        print_fail ".env.pf not found"
    fi
}

validate_services() {
    print_section "2. SERVICE STATUS VALIDATION"
    
    local required_services=(
        "nexus-cos-postgres:PostgreSQL Database"
        "nexus-cos-redis:Redis Cache"
        "puabo-api:Gateway API"
        "nexus-cos-puaboai-sdk:AI SDK"
        "nexus-cos-pv-keys:PV Keys Service"
        "vscreen-hollywood:V-Screen Hollywood"
        "nexus-cos-streamcore:StreamCore"
    )
    
    for service_info in "${required_services[@]}"; do
        IFS=':' read -r service_name service_desc <<< "$service_info"
        
        print_check "${service_desc} (${service_name})"
        
        if docker compose -f "$COMPOSE_FILE" ps --filter "name=${service_name}" --filter "status=running" | grep -q "$service_name"; then
            print_pass "${service_desc} is running"
        else
            print_fail "${service_desc} is not running"
        fi
    done
}

validate_health_endpoints() {
    print_section "3. HEALTH ENDPOINT VALIDATION"
    
    local endpoints=(
        "http://localhost:4000/health:Gateway API"
        "http://localhost:3002/health:AI SDK"
        "http://localhost:3041/health:PV Keys"
        "http://localhost:8088/health:V-Screen Hollywood"
        "http://localhost:3016/health:StreamCore"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        IFS=':' read -r url service_name <<< "$endpoint_info"
        
        print_check "${service_name} health endpoint"
        
        local response_code
        response_code=$(curl -s -o /dev/null -w "%{http_code}" -m 5 "$url" 2>/dev/null || echo "000")
        
        if [[ "$response_code" == "200" ]]; then
            print_pass "${service_name} responds with HTTP 200"
        elif [[ "$response_code" == "000" ]]; then
            print_fail "${service_name} is not responding (connection failed)"
        else
            print_fail "${service_name} responds with HTTP ${response_code}"
        fi
    done
}

validate_database() {
    print_section "4. DATABASE VALIDATION"
    
    print_check "PostgreSQL connectivity"
    if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-postgres pg_isready -U nexus_user -d nexus_db &>/dev/null; then
        print_pass "PostgreSQL is accepting connections"
    else
        print_fail "PostgreSQL is not accepting connections"
        return
    fi
    
    print_check "Database schema initialization"
    local tables
    tables=$(docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null | tr -d ' ')
    
    if [[ -n "$tables" ]] && [[ "$tables" -gt 0 ]]; then
        print_pass "Database has ${tables} tables"
    else
        print_warn "Database appears to have no tables"
    fi
    
    print_check "Required tables existence"
    local required_tables=("users" "sessions" "api_keys" "audit_log")
    
    for table in "${required_tables[@]}"; do
        if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -t -c "SELECT to_regclass('public.${table}')" 2>/dev/null | grep -q "$table"; then
            print_pass "Table exists: ${table}"
        else
            print_warn "Table not found: ${table}"
        fi
    done
}

validate_redis() {
    print_section "5. REDIS CACHE VALIDATION"
    
    print_check "Redis connectivity"
    if docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-redis redis-cli ping 2>/dev/null | grep -q "PONG"; then
        print_pass "Redis is responding to PING"
    else
        print_fail "Redis is not responding"
        return
    fi
    
    print_check "Redis memory info"
    local memory_info
    memory_info=$(docker compose -f "$COMPOSE_FILE" exec -T nexus-cos-redis redis-cli INFO memory 2>/dev/null | grep "used_memory_human" | cut -d: -f2 | tr -d '\r')
    
    if [[ -n "$memory_info" ]]; then
        print_info "Redis memory usage: ${memory_info}"
    fi
}

validate_networking() {
    print_section "6. NETWORKING VALIDATION"
    
    print_check "Docker networks"
    if docker network ls | grep -q "cos-net"; then
        print_pass "Network 'cos-net' exists"
    else
        print_fail "Network 'cos-net' not found"
    fi
    
    if docker network ls | grep -q "nexus-network"; then
        print_pass "Network 'nexus-network' exists"
    else
        print_fail "Network 'nexus-network' not found"
    fi
    
    print_check "Port bindings"
    local required_ports=(4000 3002 3041 8088 3016 5432 6379)
    
    for port in "${required_ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":${port} " || ss -tuln 2>/dev/null | grep -q ":${port} "; then
            print_pass "Port ${port} is bound"
        else
            print_warn "Port ${port} is not bound"
        fi
    done
}

validate_ssl() {
    print_section "7. SSL CERTIFICATE VALIDATION"
    
    local ssl_base="/etc/nginx/ssl"
    
    print_check "SSL directory structure"
    if [[ -d "${ssl_base}/apex" ]]; then
        print_pass "Apex SSL directory exists"
    else
        print_warn "Apex SSL directory not found"
    fi
    
    if [[ -d "${ssl_base}/hollywood" ]]; then
        print_pass "Hollywood SSL directory exists"
    else
        print_warn "Hollywood SSL directory not found"
    fi
    
    print_check "IONOS SSL certificates"
    local apex_cert="${ssl_base}/apex/nexuscos.online.crt"
    local apex_key="${ssl_base}/apex/nexuscos.online.key"
    
    if [[ -f "$apex_cert" ]] && [[ -f "$apex_key" ]]; then
        print_pass "Apex certificates present"
        
        if openssl x509 -in "$apex_cert" -noout -text &>/dev/null; then
            print_pass "Apex certificate is valid PEM format"
            
            local expiry
            expiry=$(openssl x509 -in "$apex_cert" -noout -enddate 2>/dev/null | cut -d= -f2)
            if [[ -n "$expiry" ]]; then
                print_info "Certificate expires: $expiry"
            fi
        else
            print_fail "Apex certificate is not valid"
        fi
    else
        print_warn "Apex certificates not found (expected for production)"
    fi
    
    print_check "Let's Encrypt disabled"
    if [[ -d "/etc/nginx/conf.d" ]]; then
        local le_configs
        le_configs=$(find /etc/nginx/conf.d -name "*letsencrypt*" 2>/dev/null | wc -l)
        
        if [[ "$le_configs" -eq 0 ]]; then
            print_pass "No Let's Encrypt configs in active directory"
        else
            print_warn "Found ${le_configs} Let's Encrypt config(s) in /etc/nginx/conf.d"
        fi
    fi
}

validate_environment() {
    print_section "8. ENVIRONMENT VARIABLE VALIDATION"
    
    if [[ ! -f "$ENV_FILE" ]]; then
        print_fail ".env.pf file not found"
        return
    fi
    
    local required_vars=(
        "OAUTH_CLIENT_ID"
        "OAUTH_CLIENT_SECRET"
        "JWT_SECRET"
        "DB_PASSWORD"
        "DB_USER"
        "DB_NAME"
        "PORT"
        "NODE_ENV"
    )
    
    for var in "${required_vars[@]}"; do
        print_check "Environment variable: ${var}"
        
        local value
        value=$(grep "^${var}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)
        
        if [[ -z "$value" ]]; then
            print_fail "${var} is not set"
        elif [[ "$value" == "your-"* ]] || [[ "$value" == "<"* ]]; then
            print_fail "${var} contains placeholder value"
        else
            print_pass "${var} is configured"
        fi
    done
}

validate_v_suite() {
    print_section "9. V-SUITE SERVICES VALIDATION"
    
    print_check "V-Screen Hollywood service"
    if docker compose -f "$COMPOSE_FILE" ps --filter "name=vscreen-hollywood" --filter "status=running" | grep -q "vscreen-hollywood"; then
        print_pass "V-Screen Hollywood is running"
        
        print_check "V-Screen Hollywood endpoint"
        if curl -sf http://localhost:8088/health -m 5 > /dev/null 2>&1; then
            print_pass "V-Screen Hollywood responds on port 8088"
        else
            print_fail "V-Screen Hollywood not responding"
        fi
    else
        print_fail "V-Screen Hollywood is not running"
    fi
    
    print_check "StreamCore service"
    if docker compose -f "$COMPOSE_FILE" ps --filter "name=nexus-cos-streamcore" --filter "status=running" | grep -q "streamcore"; then
        print_pass "StreamCore is running"
    else
        print_fail "StreamCore is not running"
    fi
    
    print_check "V-Prompter (via AI SDK)"
    print_info "V-Prompter served via AI SDK on port 3002"
    if curl -sf http://localhost:3002/health -m 5 > /dev/null 2>&1; then
        print_pass "V-Prompter endpoint accessible"
    else
        print_fail "V-Prompter endpoint not accessible"
    fi
}

validate_logs() {
    print_section "10. LOG VALIDATION"
    
    print_check "Checking for critical errors in logs"
    
    local services=("puabo-api" "nexus-cos-puaboai-sdk" "nexus-cos-pv-keys" "vscreen-hollywood" "nexus-cos-streamcore")
    local errors_found=false
    
    for service in "${services[@]}"; do
        local error_count
        error_count=$(docker compose -f "$COMPOSE_FILE" logs --tail=100 "$service" 2>/dev/null | grep -i "error\|fatal\|exception" | wc -l)
        
        if [[ "$error_count" -gt 0 ]]; then
            print_warn "${service}: Found ${error_count} error message(s) in recent logs"
            errors_found=true
        else
            print_pass "${service}: No critical errors in recent logs"
        fi
    done
    
    if $errors_found; then
        print_info "Review logs with: docker compose -f ${COMPOSE_FILE} logs -f"
    fi
}

# ==============================================================================
# Summary Report
# ==============================================================================

print_summary() {
    print_section "VALIDATION SUMMARY"
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    VALIDATION RESULTS                          ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local total=$((PASSED_CHECKS + FAILED_CHECKS + WARNING_CHECKS))
    
    echo -e "${BOLD}Total Checks:${NC}       ${total}"
    echo -e "${GREEN}✓ Passed:${NC}          ${PASSED_CHECKS}"
    echo -e "${YELLOW}⚠ Warnings:${NC}        ${WARNING_CHECKS}"
    echo -e "${RED}✗ Failed:${NC}          ${FAILED_CHECKS}"
    echo ""
    
    local pass_rate=0
    if [[ $TOTAL_CHECKS -gt 0 ]]; then
        pass_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    fi
    
    echo -e "${BOLD}Pass Rate:${NC}          ${pass_rate}%"
    echo ""
    
    if [[ $FAILED_CHECKS -eq 0 ]] && [[ $WARNING_CHECKS -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}"
        cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║           Nexus COS PF is Production Ready!                    ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        return 0
    elif [[ $FAILED_CHECKS -eq 0 ]]; then
        echo -e "${YELLOW}${BOLD}"
        cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              ✓  VALIDATION PASSED WITH WARNINGS                ║
║                                                                ║
║         Review warnings above before production use            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        return 0
    else
        echo -e "${RED}${BOLD}"
        cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                  ✗  VALIDATION FAILED                          ║
║                                                                ║
║         Critical issues must be resolved                       ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"
        
        echo ""
        echo -e "${YELLOW}${BOLD}Recommended Actions:${NC}"
        echo -e "  1. Review failed checks above"
        echo -e "  2. Check service logs: docker compose -f ${COMPOSE_FILE} logs -f"
        echo -e "  3. Verify .env.pf configuration"
        echo -e "  4. Ensure all required services are running"
        echo -e "  5. Re-run validation after fixes"
        echo ""
        
        return 1
    fi
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_banner
    
    # Execute validation phases
    validate_infrastructure
    validate_services
    validate_health_endpoints
    validate_database
    validate_redis
    validate_networking
    validate_ssl
    validate_environment
    validate_v_suite
    validate_logs
    
    # Print summary and exit
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"

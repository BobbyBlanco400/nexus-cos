#!/bin/bash
# Nexus COS Health Report Script
# Hardened health-check logic with robust error handling and clear exit codes
# Usage: 
#   Local: bash scripts/nexus_health_report.sh
#   Remote: ENV_PATH="/opt/nexus-cos/.env" /opt/nexus-cos/scripts/nexus_health_report.sh

set -u  # Exit on undefined variables
set -o pipefail  # Exit on pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN} $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# Exit codes
EXIT_SUCCESS=0
EXIT_HEALTH_FAILED=1
EXIT_DB_FAILED=2
EXIT_BOTH_FAILED=3

# Configuration - URLs with proper quoting and spacing
MAIN_URL="https://n3xuscos.online/health"
BETA_URL="https://beta.n3xuscos.online/health"

# Curl timeout settings (in seconds)
CURL_TIMEOUT=10
CURL_MAX_TIME=15

# Resolve .env path robustly
# Priority: 1. ENV_PATH env var, 2. /opt/nexus-cos/.env (server), 3. local .env
resolve_env_path() {
    local env_path=""
    
    if [[ -n "${ENV_PATH:-}" ]]; then
        # Use ENV_PATH if provided
        env_path="$ENV_PATH"
    elif [[ -f "/opt/nexus-cos/.env" ]]; then
        # Server path exists
        env_path="/opt/nexus-cos/.env"
    else
        # Fallback to local .env
        local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        local repo_root="$(cd "$script_dir/.." && pwd)"
        env_path="$repo_root/.env"
    fi
    
    echo "$env_path"
}

# Load environment variables
load_env() {
    local env_file="$1"
    
    if [[ ! -f "$env_file" ]]; then
        print_warning ".env file not found at: $env_file"
        print_warning "Using default DB settings"
        return 1
    else
        print_success "Found .env file: $env_file"
        
        # Source the .env file safely
        set -a  # Auto-export variables
        # shellcheck disable=SC1090
        source "$env_file" 2>/dev/null || true
        set +a
        
        return 0
    fi
}

# Check HTTP health endpoint with timeout
check_health_endpoint() {
    local url="$1"
    local name="$2"
    
    print_info "Checking $name: $url"
    
    # Use curl with proper timeouts and safe defaults
    local http_code
    local response
    
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout "$CURL_TIMEOUT" \
        --max-time "$CURL_MAX_TIME" \
        "$url" 2>/dev/null || echo "000")
    
    # Trim http_code to handle any extra characters
    http_code="${http_code:0:3}"
    
    if [[ "$http_code" == "200" ]]; then
        print_success "  ✓ HTTP $http_code - $name is healthy"
        
        # Get detailed response for main URL
        response=$(curl -s --connect-timeout "$CURL_TIMEOUT" \
            --max-time "$CURL_MAX_TIME" \
            "$url" 2>/dev/null || echo "{}")
        
        # Check if DB status is in response
        if echo "$response" | grep -q '"db"'; then
            local db_status
            db_status=$(echo "$response" | grep -o '"db":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
            
            if [[ "$db_status" == "up" ]]; then
                print_success "  ✓ Database status: UP"
            else
                print_warning "  ⚠ Database status: $db_status"
                
                # Check for DB error
                if echo "$response" | grep -q '"dbError"'; then
                    local db_error
                    db_error=$(echo "$response" | grep -o '"dbError":"[^"]*"' | cut -d'"' -f4 || echo "unknown")
                    print_error "  ✗ DB Error: $db_error"
                fi
            fi
        fi
        
        return 0
    elif [[ "$http_code" == "000" ]]; then
        print_error "  ✗ Connection failed - $name is unreachable"
        return 1
    else
        print_error "  ✗ HTTP $http_code - $name returned error"
        return 1
    fi
}

# Check database connectivity directly
check_db_connectivity() {
    local db_host="${DB_HOST:-localhost}"
    local db_port="${DB_PORT:-5432}"
    
    print_info "Checking direct database connectivity: $db_host:$db_port"
    
    # Check if nc (netcat) is available
    if ! command -v nc &> /dev/null; then
        print_warning "  ⚠ netcat (nc) not available, skipping direct DB check"
        return 0
    fi
    
    # Try to connect to DB with timeout
    if timeout 5 bash -c "echo > /dev/tcp/$db_host/$db_port" 2>/dev/null; then
        print_success "  ✓ Database port $db_host:$db_port is reachable"
        return 0
    else
        print_error "  ✗ Database port $db_host:$db_port - no response"
        return 1
    fi
}

# Main health report function
main() {
    print_header "Nexus COS Health Report"
    
    print_info "Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    print_info "Hostname: $(hostname 2>/dev/null || echo 'unknown')"
    print_info "Current User: $(whoami 2>/dev/null || echo 'unknown')"
    echo ""
    
    # Resolve and load environment
    print_header "Environment Configuration"
    local env_path
    env_path=$(resolve_env_path)
    
    # Print which path we're using
    if [[ -n "${ENV_PATH:-}" ]]; then
        print_info "Using ENV_PATH from environment: $env_path"
    elif [[ "$env_path" == "/opt/nexus-cos/.env" ]]; then
        print_info "Using server .env path: $env_path"
    else
        print_info "Using local .env path: $env_path"
    fi
    
    load_env "$env_path"
    echo ""
    
    # Initialize status flags
    local main_health_ok=0
    local beta_health_ok=0
    local db_direct_ok=0
    
    # Check Main Site Health
    print_header "Main Site Health Check"
    if check_health_endpoint "$MAIN_URL" "Main Site"; then
        main_health_ok=1
    fi
    echo ""
    
    # Check Beta Site Health
    print_header "Beta Site Health Check"
    if check_health_endpoint "$BETA_URL" "Beta Site"; then
        beta_health_ok=1
    fi
    echo ""
    
    # Check Database Direct Connectivity
    print_header "Database Direct Connectivity"
    if check_db_connectivity; then
        db_direct_ok=1
    fi
    echo ""
    
    # Generate Summary
    print_header "Health Report Summary"
    
    local total_checks=3
    local passed_checks=$((main_health_ok + beta_health_ok + db_direct_ok))
    local failed_checks=$((total_checks - passed_checks))
    
    print_info "Total Checks: $total_checks"
    print_success "Passed: $passed_checks"
    
    if [[ $failed_checks -gt 0 ]]; then
        print_error "Failed: $failed_checks"
    else
        print_info "Failed: $failed_checks"
    fi
    
    echo ""
    
    # Detailed status
    print_info "Status Details:"
    if [[ $main_health_ok -eq 1 ]]; then
        print_success "  ✓ Main site: HEALTHY"
    else
        print_error "  ✗ Main site: UNHEALTHY"
    fi
    
    if [[ $beta_health_ok -eq 1 ]]; then
        print_success "  ✓ Beta site: HEALTHY"
    else
        print_error "  ✗ Beta site: UNHEALTHY"
    fi
    
    if [[ $db_direct_ok -eq 1 ]]; then
        print_success "  ✓ Database: REACHABLE"
    else
        print_error "  ✗ Database: UNREACHABLE"
    fi
    
    echo ""
    
    # Determine exit code based on health status
    local health_ok=$((main_health_ok || beta_health_ok))
    
    if [[ $health_ok -eq 1 ]] && [[ $db_direct_ok -eq 1 ]]; then
        print_header "✓ Overall Status: HEALTHY"
        print_success "All systems operational"
        exit $EXIT_SUCCESS
    elif [[ $health_ok -eq 0 ]] && [[ $db_direct_ok -eq 0 ]]; then
        print_header "✗ Overall Status: CRITICAL"
        print_error "Both health endpoints and database are down"
        print_info ""
        print_info "Recommended Actions:"
        print_info "  1. Check if services are running (pm2 list, systemctl status)"
        print_info "  2. Verify database configuration in .env (DB_HOST, DB_PORT)"
        print_info "  3. Ensure PostgreSQL is running and accessible"
        print_info "  4. Check network connectivity and firewall rules"
        exit $EXIT_BOTH_FAILED
    elif [[ $health_ok -eq 0 ]]; then
        print_header "✗ Overall Status: DEGRADED"
        print_error "Health endpoints are not responding"
        print_info ""
        print_info "Recommended Actions:"
        print_info "  1. Check if web services are running (pm2 list)"
        print_info "  2. Review nginx configuration and status"
        print_info "  3. Check SSL certificates and domain configuration"
        exit $EXIT_HEALTH_FAILED
    else
        print_header "⚠ Overall Status: DEGRADED"
        print_warning "Health endpoints OK but database is unreachable"
        print_info ""
        print_info "Recommended Actions:"
        print_info "  1. Verify DB_HOST setting in .env (currently: ${DB_HOST:-localhost})"
        print_info "  2. Check if PostgreSQL is running: systemctl status postgresql"
        print_info "  3. Verify database is listening on port: ${DB_PORT:-5432}"
        print_info "  4. Update pg_hba.conf to allow connections from this host"
        exit $EXIT_DB_FAILED
    fi
}

# Run main function
main "$@"

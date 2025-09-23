#!/bin/bash

# Nexus COS Extended - Health Check and Validation Script
# Comprehensive system monitoring and validation

set -euo pipefail

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOGS_DIR="$PROJECT_DIR/logs"
REPORTS_DIR="$PROJECT_DIR/reports"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Health check configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
CHECK_INTERVAL="${CHECK_INTERVAL:-30}"
MAX_RETRIES="${MAX_RETRIES:-3}"
TIMEOUT="${TIMEOUT:-10}"
ALERT_WEBHOOK="${ALERT_WEBHOOK:-}"

# Service endpoints
declare -A SERVICE_ENDPOINTS=(
    ["frontend"]="http://localhost:3000"
    ["backend"]="http://localhost:8000"
    ["nginx"]="http://localhost:80"
    ["postgres"]="localhost:5432"
    ["redis"]="localhost:6379"
    ["prometheus"]="http://localhost:9090"
    ["grafana"]="http://localhost:3001"
)

# Expected response codes
declare -A EXPECTED_CODES=(
    ["frontend"]="200"
    ["backend"]="200"
    ["nginx"]="200"
    ["prometheus"]="200"
    ["grafana"]="200"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOGS_DIR/health-check-$TIMESTAMP.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGS_DIR/health-check-$TIMESTAMP.log"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOGS_DIR/health-check-$TIMESTAMP.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGS_DIR/health-check-$TIMESTAMP.log"
}

log_check() {
    echo -e "${PURPLE}[CHECK]${NC} $1" | tee -a "$LOGS_DIR/health-check-$TIMESTAMP.log"
}

# Print banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    NEXUS COS EXTENDED                       ║"
    echo "║                Health Check & Validation                     ║"
    echo "║                                                              ║"
    echo "║  🏥 System Health Monitoring                                ║"
    echo "║  🔍 Service Validation                                      ║"
    echo "║  📊 Performance Metrics                                     ║"
    echo "║  🚨 Alert Management                                        ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Setup directories
setup_directories() {
    mkdir -p "$LOGS_DIR"
    mkdir -p "$REPORTS_DIR"
}

# Check Docker services
check_docker_services() {
    log_check "Checking Docker services..."
    
    cd "$PROJECT_DIR"
    
    # Check if Docker is running
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        return 1
    fi
    
    # Get service status
    local services_output
    if services_output=$(docker-compose -f docker-compose.prod.yml ps 2>/dev/null); then
        log_info "Docker Compose services status:"
        echo "$services_output"
        
        # Parse service status
        local failed_services=()
        local running_services=()
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([^[:space:]]+)[[:space:]]+.*[[:space:]]+(Up|Exited|Dead)[[:space:]]+ ]]; then
                local service_name="${BASH_REMATCH[1]}"
                local status="${BASH_REMATCH[2]}"
                
                if [[ "$status" == "Up" ]]; then
                    running_services+=("$service_name")
                    log_success "✓ $service_name is running"
                else
                    failed_services+=("$service_name")
                    log_error "✗ $service_name is not running (status: $status)"
                fi
            fi
        done <<< "$services_output"
        
        # Summary
        log_info "Services summary: ${#running_services[@]} running, ${#failed_services[@]} failed"
        
        if [[ ${#failed_services[@]} -gt 0 ]]; then
            log_warning "Failed services: ${failed_services[*]}"
            return 1
        fi
    else
        log_error "Failed to get Docker Compose service status"
        return 1
    fi
    
    return 0
}

# Check HTTP endpoints
check_http_endpoints() {
    log_check "Checking HTTP endpoints..."
    
    local failed_endpoints=()
    local successful_endpoints=()
    
    for service in "${!SERVICE_ENDPOINTS[@]}"; do
        local endpoint="${SERVICE_ENDPOINTS[$service]}"
        local expected_code="${EXPECTED_CODES[$service]:-200}"
        
        # Skip non-HTTP endpoints
        if [[ ! "$endpoint" =~ ^https?:// ]]; then
            continue
        fi
        
        log_info "Checking $service at $endpoint..."
        
        local response_code
        local response_time
        
        if response_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$TIMEOUT" "$endpoint" 2>/dev/null) && \
           response_time=$(curl -s -o /dev/null -w "%{time_total}" --max-time "$TIMEOUT" "$endpoint" 2>/dev/null); then
            
            if [[ "$response_code" == "$expected_code" ]]; then
                successful_endpoints+=("$service")
                log_success "✓ $service responded with $response_code (${response_time}s)"
            else
                failed_endpoints+=("$service")
                log_warning "⚠ $service responded with $response_code, expected $expected_code"
            fi
        else
            failed_endpoints+=("$service")
            log_error "✗ $service is not responding"
        fi
    done
    
    # Summary
    log_info "HTTP endpoints summary: ${#successful_endpoints[@]} healthy, ${#failed_endpoints[@]} failed"
    
    if [[ ${#failed_endpoints[@]} -gt 0 ]]; then
        log_warning "Failed endpoints: ${failed_endpoints[*]}"
        return 1
    fi
    
    return 0
}

# Check database connectivity
check_database_connectivity() {
    log_check "Checking database connectivity..."
    
    cd "$PROJECT_DIR"
    
    # Check PostgreSQL
    if docker-compose -f docker-compose.prod.yml exec -T postgres pg_isready -U nexus_user &> /dev/null; then
        log_success "✓ PostgreSQL is accepting connections"
        
        # Check database size and connections
        local db_info
        if db_info=$(docker-compose -f docker-compose.prod.yml exec -T postgres psql -U nexus_user -d nexus_db -t -c "
            SELECT 
                pg_size_pretty(pg_database_size('nexus_db')) as db_size,
                count(*) as active_connections
            FROM pg_stat_activity 
            WHERE datname = 'nexus_db';
        " 2>/dev/null); then
            log_info "Database info: $db_info"
        fi
    else
        log_error "✗ PostgreSQL is not accepting connections"
        return 1
    fi
    
    # Check Redis
    if docker-compose -f docker-compose.prod.yml exec -T redis redis-cli ping | grep -q "PONG"; then
        log_success "✓ Redis is responding"
        
        # Check Redis info
        local redis_info
        if redis_info=$(docker-compose -f docker-compose.prod.yml exec -T redis redis-cli info memory | grep "used_memory_human" 2>/dev/null); then
            log_info "Redis memory usage: $redis_info"
        fi
    else
        log_error "✗ Redis is not responding"
        return 1
    fi
    
    return 0
}

# Check SSL certificates
check_ssl_certificates() {
    log_check "Checking SSL certificates..."
    
    local ssl_dir="/etc/nginx/ssl/$DOMAIN"
    local cert_file="$ssl_dir/fullchain.pem"
    
    if [[ -f "$cert_file" ]]; then
        # Check certificate validity
        local expiry_date
        if expiry_date=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | cut -d= -f2); then
            local expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
            local current_timestamp=$(date +%s)
            local days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
            
            if [[ $days_until_expiry -gt 30 ]]; then
                log_success "✓ SSL certificate is valid (expires in $days_until_expiry days)"
            elif [[ $days_until_expiry -gt 7 ]]; then
                log_warning "⚠ SSL certificate expires soon ($days_until_expiry days)"
            else
                log_error "✗ SSL certificate expires very soon ($days_until_expiry days)"
                return 1
            fi
        else
            log_error "✗ Failed to read SSL certificate expiry date"
            return 1
        fi
        
        # Check certificate chain
        if openssl verify -CAfile "$ssl_dir/chain.pem" "$cert_file" &> /dev/null; then
            log_success "✓ SSL certificate chain is valid"
        else
            log_warning "⚠ SSL certificate chain validation failed"
        fi
    else
        log_warning "⚠ SSL certificate not found at $cert_file"
    fi
    
    return 0
}

# Check system resources
check_system_resources() {
    log_check "Checking system resources..."
    
    # Check disk space
    local disk_usage
    if disk_usage=$(df -h "$PROJECT_DIR" | awk 'NR==2 {print $5}' | tr -d '%'); then
        if [[ $disk_usage -lt 80 ]]; then
            log_success "✓ Disk usage: ${disk_usage}%"
        elif [[ $disk_usage -lt 90 ]]; then
            log_warning "⚠ Disk usage: ${disk_usage}% (getting high)"
        else
            log_error "✗ Disk usage: ${disk_usage}% (critically high)"
            return 1
        fi
    fi
    
    # Check memory usage
    local memory_usage
    if memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}'); then
        if [[ $memory_usage -lt 80 ]]; then
            log_success "✓ Memory usage: ${memory_usage}%"
        elif [[ $memory_usage -lt 90 ]]; then
            log_warning "⚠ Memory usage: ${memory_usage}% (getting high)"
        else
            log_error "✗ Memory usage: ${memory_usage}% (critically high)"
            return 1
        fi
    fi
    
    # Check CPU load
    local cpu_load
    if cpu_load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ','); then
        local cpu_cores=$(nproc)
        local load_percentage=$(echo "$cpu_load * 100 / $cpu_cores" | bc -l 2>/dev/null | cut -d. -f1)
        
        if [[ ${load_percentage:-0} -lt 70 ]]; then
            log_success "✓ CPU load: $cpu_load (${load_percentage}%)"
        elif [[ ${load_percentage:-0} -lt 90 ]]; then
            log_warning "⚠ CPU load: $cpu_load (${load_percentage}%)"
        else
            log_error "✗ CPU load: $cpu_load (${load_percentage}%)"
            return 1
        fi
    fi
    
    return 0
}

# Check Docker container health
check_container_health() {
    log_check "Checking Docker container health..."
    
    cd "$PROJECT_DIR"
    
    local unhealthy_containers=()
    local healthy_containers=()
    
    # Get container health status
    local containers
    if containers=$(docker-compose -f docker-compose.prod.yml ps -q 2>/dev/null); then
        for container_id in $containers; do
            local container_name
            local health_status
            
            container_name=$(docker inspect --format='{{.Name}}' "$container_id" | tr -d '/')
            health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" 2>/dev/null || echo "no-healthcheck")
            
            case "$health_status" in
                "healthy")
                    healthy_containers+=("$container_name")
                    log_success "✓ $container_name is healthy"
                    ;;
                "unhealthy")
                    unhealthy_containers+=("$container_name")
                    log_error "✗ $container_name is unhealthy"
                    ;;
                "starting")
                    log_info "⏳ $container_name is starting"
                    ;;
                "no-healthcheck")
                    log_info "ℹ $container_name has no health check configured"
                    ;;
                *)
                    log_warning "⚠ $container_name has unknown health status: $health_status"
                    ;;
            esac
        done
    fi
    
    # Summary
    log_info "Container health summary: ${#healthy_containers[@]} healthy, ${#unhealthy_containers[@]} unhealthy"
    
    if [[ ${#unhealthy_containers[@]} -gt 0 ]]; then
        log_warning "Unhealthy containers: ${unhealthy_containers[*]}"
        return 1
    fi
    
    return 0
}

# Check log files for errors
check_log_files() {
    log_check "Checking log files for errors..."
    
    local error_count=0
    local warning_count=0
    
    # Check Docker logs for errors
    cd "$PROJECT_DIR"
    
    local services
    if services=$(docker-compose -f docker-compose.prod.yml ps --services 2>/dev/null); then
        for service in $services; do
            local logs
            if logs=$(docker-compose -f docker-compose.prod.yml logs --tail=100 "$service" 2>/dev/null); then
                local service_errors
                local service_warnings
                
                service_errors=$(echo "$logs" | grep -i "error\|exception\|fatal" | wc -l)
                service_warnings=$(echo "$logs" | grep -i "warning\|warn" | wc -l)
                
                error_count=$((error_count + service_errors))
                warning_count=$((warning_count + service_warnings))
                
                if [[ $service_errors -gt 0 ]]; then
                    log_warning "⚠ $service has $service_errors errors in recent logs"
                fi
                
                if [[ $service_warnings -gt 5 ]]; then
                    log_info "ℹ $service has $service_warnings warnings in recent logs"
                fi
            fi
        done
    fi
    
    log_info "Log analysis: $error_count errors, $warning_count warnings found"
    
    if [[ $error_count -gt 10 ]]; then
        log_error "High number of errors found in logs"
        return 1
    fi
    
    return 0
}

# Generate health report
generate_health_report() {
    log_info "Generating health report..."
    
    local report_file="$REPORTS_DIR/health-report-$TIMESTAMP.json"
    local overall_status="healthy"
    
    # Determine overall status based on check results
    if [[ ${#failed_checks[@]} -gt 0 ]]; then
        overall_status="unhealthy"
    elif [[ ${#warning_checks[@]} -gt 0 ]]; then
        overall_status="warning"
    fi
    
    # Create health report
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "domain": "$DOMAIN",
  "overallStatus": "$overall_status",
  "checks": {
    "dockerServices": $([ "${check_results[docker_services]}" = "0" ] && echo "true" || echo "false"),
    "httpEndpoints": $([ "${check_results[http_endpoints]}" = "0" ] && echo "true" || echo "false"),
    "databaseConnectivity": $([ "${check_results[database_connectivity]}" = "0" ] && echo "true" || echo "false"),
    "sslCertificates": $([ "${check_results[ssl_certificates]}" = "0" ] && echo "true" || echo "false"),
    "systemResources": $([ "${check_results[system_resources]}" = "0" ] && echo "true" || echo "false"),
    "containerHealth": $([ "${check_results[container_health]}" = "0" ] && echo "true" || echo "false"),
    "logFiles": $([ "${check_results[log_files]}" = "0" ] && echo "true" || echo "false")
  },
  "summary": {
    "totalChecks": ${#check_results[@]},
    "passedChecks": $(echo "${check_results[@]}" | tr ' ' '\n' | grep -c "^0$" || echo "0"),
    "failedChecks": $(echo "${check_results[@]}" | tr ' ' '\n' | grep -c -v "^0$" || echo "0")
  },
  "reportFile": "$report_file",
  "logFile": "$LOGS_DIR/health-check-$TIMESTAMP.log"
}
EOF
    
    log_success "Health report generated: $report_file"
}

# Send alert if configured
send_alert() {
    local status="$1"
    local message="$2"
    
    if [[ -n "$ALERT_WEBHOOK" ]]; then
        log_info "Sending alert notification..."
        
        local payload=$(cat << EOF
{
  "text": "Nexus COS Health Check Alert",
  "attachments": [
    {
      "color": "$([ "$status" = "error" ] && echo "danger" || echo "warning")",
      "fields": [
        {
          "title": "Status",
          "value": "$status",
          "short": true
        },
        {
          "title": "Domain",
          "value": "$DOMAIN",
          "short": true
        },
        {
          "title": "Message",
          "value": "$message",
          "short": false
        },
        {
          "title": "Timestamp",
          "value": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
          "short": true
        }
      ]
    }
  ]
}
EOF
)
        
        if curl -s -X POST -H "Content-Type: application/json" -d "$payload" "$ALERT_WEBHOOK" &> /dev/null; then
            log_success "Alert sent successfully"
        else
            log_warning "Failed to send alert"
        fi
    fi
}

# Print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --domain DOMAIN          Domain to check (default: nexuscos.online)"
    echo "  -i, --interval SECONDS       Check interval for continuous monitoring"
    echo "  -c, --continuous             Run continuous monitoring"
    echo "  -r, --retries COUNT          Maximum retries for failed checks (default: 3)"
    echo "  -t, --timeout SECONDS        Timeout for HTTP requests (default: 10)"
    echo "  -w, --webhook URL            Webhook URL for alerts"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run single health check"
    echo "  $0 -c -i 60                  # Continuous monitoring every 60 seconds"
    echo "  $0 -d myapp.com -w https://hooks.slack.com/... # Check custom domain with alerts"
}

# Parse command line arguments
parse_arguments() {
    local continuous=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -i|--interval)
                CHECK_INTERVAL="$2"
                shift 2
                ;;
            -c|--continuous)
                continuous=true
                shift
                ;;
            -r|--retries)
                MAX_RETRIES="$2"
                shift 2
                ;;
            -t|--timeout)
                TIMEOUT="$2"
                shift 2
                ;;
            -w|--webhook)
                ALERT_WEBHOOK="$2"
                shift 2
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
    
    # Set continuous monitoring if requested
    if [[ "$continuous" == "true" ]]; then
        run_continuous_monitoring
    fi
}

# Run continuous monitoring
run_continuous_monitoring() {
    log_info "Starting continuous monitoring (interval: ${CHECK_INTERVAL}s)"
    
    while true; do
        echo ""
        log_info "Running health check cycle..."
        
        run_health_checks
        
        log_info "Next check in ${CHECK_INTERVAL} seconds..."
        sleep "$CHECK_INTERVAL"
    done
}

# Run all health checks
run_health_checks() {
    # Initialize check results
    declare -A check_results
    declare -a failed_checks
    declare -a warning_checks
    
    # Run checks
    check_docker_services && check_results[docker_services]=0 || check_results[docker_services]=1
    check_http_endpoints && check_results[http_endpoints]=0 || check_results[http_endpoints]=1
    check_database_connectivity && check_results[database_connectivity]=0 || check_results[database_connectivity]=1
    check_ssl_certificates && check_results[ssl_certificates]=0 || check_results[ssl_certificates]=1
    check_system_resources && check_results[system_resources]=0 || check_results[system_resources]=1
    check_container_health && check_results[container_health]=0 || check_results[container_health]=1
    check_log_files && check_results[log_files]=0 || check_results[log_files]=1
    
    # Collect failed checks
    for check in "${!check_results[@]}"; do
        if [[ ${check_results[$check]} -ne 0 ]]; then
            failed_checks+=("$check")
        fi
    done
    
    # Generate report
    generate_health_report
    
    # Print summary
    echo ""
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_success "All health checks passed! ✅"
    else
        log_error "Health check failures detected: ${failed_checks[*]}"
        send_alert "error" "Health check failures: ${failed_checks[*]}"
    fi
}

# Main execution
main() {
    print_banner
    setup_directories
    
    log_info "Starting Nexus COS Extended health check"
    log_info "Domain: $DOMAIN"
    log_info "Timestamp: $TIMESTAMP"
    
    run_health_checks
    
    log_info "Health check completed"
}

# Parse arguments and run
parse_arguments "$@"
main
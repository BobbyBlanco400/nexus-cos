#!/bin/bash
# Comprehensive URL Health Monitoring Setup
# Monitors all URLs documented in docs/NEXUS_COS_URLS.md
# Provides continuous monitoring for both production and beta environments

set -e

echo "📊 NEXUS COS - Comprehensive URL Health Monitoring"
echo "=================================================="
echo "$(date): Starting comprehensive URL monitoring setup"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="/var/log/nexus-cos"
ALERT_THRESHOLD=5
RESPONSE_TIME_THRESHOLD=2.0
CHECK_INTERVAL=30

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR" 2>/dev/null || LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Log files
HEALTH_LOG="$LOG_DIR/url-health-monitor.log"
ALERT_LOG="$LOG_DIR/url-alerts.log"
PERFORMANCE_LOG="$LOG_DIR/url-performance.log"

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$HEALTH_LOG"
}

# Function to log alerts
log_alert() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ALERT: $1" | tee -a "$ALERT_LOG"
    echo -e "${RED}🚨 ALERT: $1${NC}"
}

# Function to log performance
log_performance() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$PERFORMANCE_LOG"
}

# Function to check URL with detailed monitoring
monitor_url() {
    local url=$1
    local description=$2
    local expected_response=$3
    local timeout=${4:-10}
    
    # Perform the check
    start_time=$(date +%s.%N)
    response=$(curl -s -w "HTTPSTATUS:%{http_code};TIME:%{time_total}" -f -m "$timeout" "$url" 2>/dev/null || echo "FAILED")
    end_time=$(date +%s.%N)
    
    if [[ "$response" == "FAILED" ]]; then
        log_alert "$description ($url) is DOWN"
        return 1
    fi
    
    # Extract HTTP status and response time
    http_status=$(echo "$response" | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    response_time=$(echo "$response" | grep -o "TIME:[0-9.]*" | cut -d: -f2)
    
    # Check HTTP status
    if [[ "$http_status" -lt 200 || "$http_status" -ge 400 ]]; then
        log_alert "$description ($url) returned HTTP $http_status"
        return 1
    fi
    
    # Check response time
    if (( $(echo "$response_time > $RESPONSE_TIME_THRESHOLD" | bc -l) )); then
        log_alert "$description ($url) is slow: ${response_time}s"
    fi
    
    # Check expected response content if provided
    if [[ -n "$expected_response" ]]; then
        content=$(echo "$response" | sed 's/HTTPSTATUS:.*;//' | sed 's/TIME:.*;//')
        if [[ "$content" != *"$expected_response"* ]]; then
            log_alert "$description ($url) unexpected response content"
            return 1
        fi
    fi
    
    # Log performance metrics
    log_performance "$description,$url,$http_status,$response_time"
    log_message "$description ($url) is healthy - HTTP $http_status, ${response_time}s"
    return 0
}

# Function to check SSL certificate
monitor_ssl() {
    local domain=$1
    local description=$2
    
    # Check SSL certificate validity
    cert_info=$(echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null)
    
    if echo "$cert_info" | grep -q "Verify return code: 0"; then
        # Get certificate expiry date
        expiry_date=$(echo "$cert_info" | openssl x509 -noout -dates 2>/dev/null | grep "notAfter" | cut -d= -f2)
        if [[ -n "$expiry_date" ]]; then
            expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
            current_timestamp=$(date +%s)
            days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
            
            if [[ $days_until_expiry -lt 30 ]]; then
                log_alert "SSL certificate for $domain expires in $days_until_expiry days"
            else
                log_message "SSL certificate for $domain is valid (expires in $days_until_expiry days)"
            fi
        fi
    else
        log_alert "SSL certificate verification failed for $domain"
        return 1
    fi
    
    return 0
}

# Function to generate monitoring report
generate_report() {
    local report_file="$LOG_DIR/health-report-$(date +%Y%m%d-%H%M).txt"
    
    echo "NEXUS COS Health Monitoring Report" > "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "==========================================" >> "$report_file"
    echo "" >> "$report_file"
    
    # Recent health logs
    echo "Recent Health Status:" >> "$report_file"
    tail -n 20 "$HEALTH_LOG" >> "$report_file" 2>/dev/null || echo "No health logs available" >> "$report_file"
    echo "" >> "$report_file"
    
    # Recent alerts
    echo "Recent Alerts:" >> "$report_file"
    tail -n 10 "$ALERT_LOG" >> "$report_file" 2>/dev/null || echo "No alerts" >> "$report_file"
    echo "" >> "$report_file"
    
    # Performance summary
    echo "Performance Summary (last 24 hours):" >> "$report_file"
    if [[ -f "$PERFORMANCE_LOG" ]]; then
        awk -F, '
        BEGIN { count=0; total_time=0; max_time=0; }
        {
            count++;
            total_time += $4;
            if ($4 > max_time) max_time = $4;
        }
        END {
            if (count > 0) {
                avg_time = total_time / count;
                printf "Total Checks: %d\n", count;
                printf "Average Response Time: %.3fs\n", avg_time;
                printf "Max Response Time: %.3fs\n", max_time;
            }
        }' "$PERFORMANCE_LOG" >> "$report_file"
    else
        echo "No performance data available" >> "$report_file"
    fi
    
    echo "Report saved to: $report_file"
}

# Main monitoring function
run_monitoring_cycle() {
    echo -e "${CYAN}🔄 Starting monitoring cycle...${NC}"
    
    # Production Environment Monitoring
    echo -e "${BLUE}Production Environment:${NC}"
    monitor_url "https://n3xuscos.online" "Production Main App"
    monitor_url "https://www.n3xuscos.online" "Production WWW"
    monitor_url "https://n3xuscos.online/health" "Production Health" "ok"
    monitor_url "https://n3xuscos.online:3000/health" "Production Backend" "ok"
    monitor_url "https://n3xuscos.online:3001/health" "Production Python Backend" "ok"
    monitor_url "https://monitoring.n3xuscos.online" "Production Monitoring"
    
    # SSL Certificate Monitoring
    monitor_ssl "n3xuscos.online" "Production SSL"
    monitor_ssl "www.n3xuscos.online" "Production WWW SSL"
    monitor_ssl "monitoring.n3xuscos.online" "Production Monitoring SSL"
    
    # Beta Environment Monitoring
    echo -e "${PURPLE}Beta Environment:${NC}"
    monitor_url "https://beta.n3xuscos.online" "Beta Main App"
    monitor_url "https://beta.n3xuscos.online/health" "Beta Health" "ok"
    monitor_url "https://beta.n3xuscos.online:3000/health" "Beta Backend" "ok"
    monitor_url "https://beta.n3xuscos.online:3001/health" "Beta Python Backend" "ok"
    monitor_url "https://beta.n3xuscos.online/api/auth/test" "Beta Auth Test"
    
    # Beta SSL Certificate Monitoring
    monitor_ssl "beta.n3xuscos.online" "Beta SSL"
    
    echo -e "${CYAN}✅ Monitoring cycle complete${NC}"
    echo ""
}

# Function to setup monitoring as a service
setup_monitoring_service() {
    echo -e "${BLUE}Setting up monitoring service...${NC}"
    
    # Create systemd service file (if running with sudo)
    if [[ $EUID -eq 0 ]]; then
        cat > /etc/systemd/system/nexus-cos-monitor.service << EOF
[Unit]
Description=NEXUS COS URL Health Monitor
After=network.target

[Service]
Type=simple
User=www-data
ExecStart=/bin/bash $(realpath "$0") --daemon
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable nexus-cos-monitor.service
        echo "Systemd service created. Start with: sudo systemctl start nexus-cos-monitor"
    else
        echo "Run with sudo to create systemd service, or use --daemon flag for foreground monitoring"
    fi
}

# Function to run in daemon mode
run_daemon() {
    log_message "NEXUS COS URL monitoring daemon started"
    echo -e "${GREEN}🚀 NEXUS COS URL monitoring daemon started${NC}"
    echo "Logs: $HEALTH_LOG"
    echo "Alerts: $ALERT_LOG"
    echo "Performance: $PERFORMANCE_LOG"
    echo ""
    
    while true; do
        run_monitoring_cycle
        
        # Generate hourly reports
        current_minute=$(date +%M)
        if [[ "$current_minute" == "00" ]]; then
            generate_report
        fi
        
        echo "Next check in $CHECK_INTERVAL seconds..."
        sleep $CHECK_INTERVAL
    done
}

# Command line argument handling
case "${1:-}" in
    --daemon)
        run_daemon
        ;;
    --setup-service)
        setup_monitoring_service
        ;;
    --report)
        generate_report
        ;;
    --single-check)
        run_monitoring_cycle
        ;;
    *)
        echo "NEXUS COS URL Health Monitoring"
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  --daemon          Run continuous monitoring"
        echo "  --setup-service   Setup systemd service (requires sudo)"
        echo "  --report          Generate current health report"
        echo "  --single-check    Run single monitoring cycle"
        echo ""
        echo "Default: Run single monitoring cycle"
        run_monitoring_cycle
        ;;
esac
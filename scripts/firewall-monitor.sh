#!/bin/bash
# Nexus COS Firewall Monitoring and Auto-Recovery
# Continuous monitoring for firewall-related connectivity issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/nexus-firewall-monitor.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check service connectivity
check_service_connectivity() {
    local service_name="$1"
    local url="$2"
    local expected_response="$3"
    
    if response=$(curl -s --connect-timeout 5 --max-time 10 "$url" 2>/dev/null); then
        if [[ "$response" == *"$expected_response"* ]]; then
            return 0
        fi
    fi
    return 1
}

# Function to validate firewall rules
validate_firewall_rules() {
    local issues=0
    
    # Check if UFW is active
    if ! ufw status | grep -q "Status: active"; then
        log "ERROR: UFW firewall is not active"
        ((issues++))
    fi
    
    # Check essential ports
    for port in 22 80 443; do
        if ! ufw status | grep -q "$port"; then
            log "ERROR: Port $port is not configured in firewall"
            ((issues++))
        fi
    done
    
    return $issues
}

# Function to auto-recover firewall configuration
auto_recover_firewall() {
    log "RECOVERY: Attempting automatic firewall recovery..."
    
    if [ -f "$SCRIPT_DIR/configure-firewall.sh" ]; then
        if bash "$SCRIPT_DIR/configure-firewall.sh" >> "$LOG_FILE" 2>&1; then
            log "SUCCESS: Firewall configuration recovered automatically"
            return 0
        else
            log "ERROR: Failed to recover firewall configuration"
            return 1
        fi
    else
        log "ERROR: Firewall configuration script not found at $SCRIPT_DIR/configure-firewall.sh"
        return 1
    fi
}

# Function to test GitHub connectivity (critical for agent operations)
test_github_connectivity() {
    if check_service_connectivity "GitHub API" "https://api.github.com" "rate_limit_url"; then
        log "INFO: GitHub API connectivity verified"
        return 0
    else
        log "WARNING: GitHub API connectivity failed"
        return 1
    fi
}

# Function to test local services
test_local_services() {
    local issues=0
    
    # Test Nginx
    if systemctl is-active --quiet nginx; then
        if check_service_connectivity "Local Nginx" "http://localhost/health" "ok"; then
            log "INFO: Nginx service accessible"
        else
            log "WARNING: Nginx service not responding correctly"
            ((issues++))
        fi
    fi
    
    # Test Node.js backend
    if systemctl is-active --quiet nexus-backend; then
        if check_service_connectivity "Node.js backend" "http://localhost:3000/health" "ok"; then
            log "INFO: Node.js backend accessible"
        else
            log "WARNING: Node.js backend not responding correctly"
            ((issues++))
        fi
    fi
    
    # Test Python backend
    if systemctl is-active --quiet nexus-python; then
        if check_service_connectivity "Python backend" "http://localhost:8000/health" "ok"; then
            log "INFO: Python backend accessible"
        else
            log "WARNING: Python backend not responding correctly"
            ((issues++))
        fi
    fi
    
    return $issues
}

# Main monitoring function
perform_health_check() {
    log "INFO: Starting firewall and connectivity health check..."
    
    local total_issues=0
    
    # Validate firewall rules
    if ! validate_firewall_rules; then
        log "WARNING: Firewall rule validation failed"
        ((total_issues++))
    fi
    
    # Test local services
    local_issues=$(test_local_services || echo $?)
    total_issues=$((total_issues + local_issues))
    
    # Test GitHub connectivity
    if ! test_github_connectivity; then
        ((total_issues++))
    fi
    
    if [ $total_issues -gt 0 ]; then
        log "WARNING: $total_issues connectivity issues detected"
        
        # Attempt auto-recovery if firewall issues detected
        if ! validate_firewall_rules; then
            auto_recover_firewall
        fi
        
        return 1
    else
        log "INFO: All connectivity checks passed"
        return 0
    fi
}

# Function to install as systemd service for continuous monitoring
install_monitoring_service() {
    log "INFO: Installing firewall monitoring service..."
    
    cat > /etc/systemd/system/nexus-firewall-monitor.service <<EOF
[Unit]
Description=Nexus COS Firewall Monitor
After=network.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/firewall-monitor.sh --check
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/nexus-firewall-monitor.timer <<EOF
[Unit]
Description=Run Nexus COS Firewall Monitor every 5 minutes
Requires=nexus-firewall-monitor.service

[Timer]
OnCalendar=*:0/5
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable nexus-firewall-monitor.timer
    systemctl start nexus-firewall-monitor.timer
    
    log "INFO: Firewall monitoring service installed and started"
}

# Main script logic
case "${1:-}" in
    --check)
        perform_health_check
        ;;
    --install)
        install_monitoring_service
        ;;
    --recover)
        auto_recover_firewall
        ;;
    *)
        echo "Usage: $0 [--check|--install|--recover]"
        echo "  --check    Perform health check"
        echo "  --install  Install monitoring service"
        echo "  --recover  Attempt firewall recovery"
        exit 1
        ;;
esac
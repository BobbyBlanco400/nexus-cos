#!/bin/bash
# Nexus COS Process Monitor and Auto-Recovery Script

LOG_FILE="/var/log/nexus-monitor.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_and_restart_service() {
    local service_name=$1
    local service_url=$2
    
    # Check if service is running
    if ! systemctl is-active --quiet "$service_name"; then
        log_message "WARNING: $service_name is not running. Attempting restart..."
        systemctl restart "$service_name"
        sleep 5
        
        if systemctl is-active --quiet "$service_name"; then
            log_message "SUCCESS: $service_name restarted successfully"
        else
            log_message "ERROR: Failed to restart $service_name"
            return 1
        fi
    fi
    
    # Check if service responds to HTTP requests
    if [ -n "$service_url" ]; then
        if ! curl -sf "$service_url" >/dev/null 2>&1; then
            log_message "WARNING: $service_name not responding at $service_url. Restarting..."
            systemctl restart "$service_name"
            sleep 5
        fi
    fi
    
    return 0
}

# Monitor function
monitor_services() {
    log_message "Starting Nexus COS service monitoring..."
    
    # Check Node.js backend
    check_and_restart_service "nexus-backend.service" "http://localhost:3000/health"
    
    # Check Python backend
    check_and_restart_service "nexus-python.service" "http://localhost:3001/health"
    
    # Check Nginx
    check_and_restart_service "nginx.service" "http://localhost"
    
    # Check SSL certificate expiry
    if command -v certbot >/dev/null 2>&1; then
        cert_days=$(certbot certificates 2>/dev/null | grep "VALID" | grep -o "[0-9]* days" | head -1 | cut -d' ' -f1)
        if [ -n "$cert_days" ] && [ "$cert_days" -lt 30 ]; then
            log_message "WARNING: SSL certificate expires in $cert_days days. Attempting renewal..."
            certbot renew --quiet || log_message "ERROR: SSL certificate renewal failed"
        fi
    fi
    
    log_message "Service monitoring completed"
}

# Install as systemd service
install_monitor() {
    log_message "Installing Nexus COS monitoring service..."
    
    # Create systemd service
    cat >/etc/systemd/system/nexus-monitor.service <<EOF
[Unit]
Description=Nexus COS Process Monitor
After=network.target

[Service]
Type=oneshot
ExecStart=/root/nexus-cos/nexus-monitor.sh monitor
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

    # Create systemd timer
    cat >/etc/systemd/system/nexus-monitor.timer <<EOF
[Unit]
Description=Run Nexus COS Monitor every 2 minutes
Requires=nexus-monitor.service

[Timer]
OnCalendar=*:0/2
Persistent=true

[Install]
WantedBy=timers.target
EOF

    systemctl daemon-reload
    systemctl enable nexus-monitor.timer
    systemctl start nexus-monitor.timer
    
    log_message "Nexus COS monitoring service installed and started"
}

# Main execution
case "${1:-}" in
    monitor)
        monitor_services
        ;;
    install)
        install_monitor
        ;;
    *)
        echo "Usage: $0 [monitor|install]"
        echo "  monitor  - Run monitoring check"
        echo "  install  - Install monitoring service"
        exit 1
        ;;
esac
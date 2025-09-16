#!/bin/bash
# Nexus COS Disaster Recovery and Rollback Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BACKUP_DIR="/root/nexus-backups"
RECOVERY_LOG="/var/log/nexus-recovery-$(date '+%Y%m%d_%H%M%S').log"

log_recovery() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RECOVERY_LOG"
}

print_status() {
    echo -e "${BLUE}[RECOVERY]${NC} $1" | tee -a "$RECOVERY_LOG"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$RECOVERY_LOG"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$RECOVERY_LOG"
}

# Create backup
create_backup() {
    print_status "Creating system backup..."
    
    mkdir -p "$BACKUP_DIR/$(date '+%Y%m%d_%H%M%S')"
    local backup_path="$BACKUP_DIR/$(date '+%Y%m%d_%H%M%S')"
    
    # Backup configurations
    cp -r /etc/nginx/sites-available "$backup_path/" 2>/dev/null || true
    cp -r /etc/systemd/system/nexus-*.service "$backup_path/" 2>/dev/null || true
    cp -r /var/www/nexus-cos "$backup_path/" 2>/dev/null || true
    
    print_success "Backup created at $backup_path"
}

# Emergency restart all services
emergency_restart() {
    print_status "Performing emergency restart of all Nexus services..."
    
    systemctl stop nexus-backend.service 2>/dev/null || true
    systemctl stop nexus-python.service 2>/dev/null || true
    systemctl stop nginx 2>/dev/null || true
    
    sleep 5
    
    systemctl start nexus-backend.service
    systemctl start nexus-python.service
    systemctl start nginx
    
    sleep 10
    
    # Verify services
    if systemctl is-active --quiet nexus-backend.service && 
       systemctl is-active --quiet nexus-python.service && 
       systemctl is-active --quiet nginx; then
        print_success "All services restarted successfully"
        return 0
    else
        print_error "Some services failed to restart"
        return 1
    fi
}

# Full recovery deployment
full_recovery() {
    print_status "Initiating full recovery deployment..."
    
    create_backup
    
    # Stop all services
    systemctl stop nexus-backend.service nexus-python.service nginx 2>/dev/null || true
    
    # Re-run deployment script
    if [ -f "/root/nexus-cos/comprehensive-production-deploy.sh" ]; then
        print_status "Running comprehensive deployment script..."
        bash /root/nexus-cos/comprehensive-production-deploy.sh
    else
        print_error "Deployment script not found"
        return 1
    fi
}

# Health check
health_check() {
    print_status "Performing comprehensive health check..."
    
    local issues=0
    
    # Check services
    for service in nexus-backend.service nexus-python.service nginx; do
        if systemctl is-active --quiet "$service"; then
            print_success "$service: RUNNING"
        else
            print_error "$service: NOT RUNNING"
            ((issues++))
        fi
    done
    
    # Check endpoints
    if curl -sf http://localhost:3000/health >/dev/null; then
        print_success "Node.js health endpoint: OK"
    else
        print_error "Node.js health endpoint: FAILED"
        ((issues++))
    fi
    
    if curl -sf http://localhost:3001/health >/dev/null; then
        print_success "Python health endpoint: OK"
    else
        print_error "Python health endpoint: FAILED"
        ((issues++))
    fi
    
    if curl -sf http://localhost >/dev/null; then
        print_success "Nginx frontend: OK"
    else
        print_error "Nginx frontend: FAILED"
        ((issues++))
    fi
    
    # Check SSL if available
    if curl -sf https://nexuscos.online >/dev/null 2>&1; then
        print_success "SSL endpoint: OK"
    else
        print_error "SSL endpoint: FAILED"
        ((issues++))
    fi
    
    if [ $issues -eq 0 ]; then
        print_success "🎉 All health checks passed!"
        return 0
    else
        print_error "❌ $issues health check(s) failed"
        return 1
    fi
}

# Show system status
show_status() {
    echo "======================================"
    echo "   NEXUS COS SYSTEM STATUS"
    echo "======================================"
    
    echo -e "\n🔧 SYSTEMD SERVICES:"
    systemctl status nexus-backend.service --no-pager -l || true
    systemctl status nexus-python.service --no-pager -l || true
    systemctl status nginx --no-pager -l || true
    
    echo -e "\n🌐 ENDPOINT CHECKS:"
    echo -n "Node.js (localhost:3000/health): "
    curl -sf http://localhost:3000/health && echo "✅ OK" || echo "❌ FAILED"
    
    echo -n "Python (localhost:3001/health): "
    curl -sf http://localhost:3001/health && echo "✅ OK" || echo "❌ FAILED"
    
    echo -n "Frontend (localhost): "
    curl -sf http://localhost >/dev/null && echo "✅ OK" || echo "❌ FAILED"
    
    echo -n "SSL (nexuscos.online): "
    curl -sf https://nexuscos.online >/dev/null 2>&1 && echo "✅ OK" || echo "❌ FAILED"
    
    echo -e "\n🔥 FIREWALL STATUS:"
    ufw status || true
    
    echo -e "\n📊 RESOURCE USAGE:"
    df -h | grep -E "Filesystem|/dev/"
    free -h
    uptime
}

# Main execution
case "${1:-}" in
    backup)
        create_backup
        ;;
    restart)
        emergency_restart
        ;;
    recover)
        full_recovery
        ;;
    health)
        health_check
        ;;
    status)
        show_status
        ;;
    *)
        echo "Nexus COS Disaster Recovery Tool"
        echo ""
        echo "Usage: $0 [backup|restart|recover|health|status]"
        echo ""
        echo "Commands:"
        echo "  backup   - Create backup of current system"
        echo "  restart  - Emergency restart all services"
        echo "  recover  - Full recovery deployment"
        echo "  health   - Comprehensive health check"
        echo "  status   - Show detailed system status"
        echo ""
        exit 1
        ;;
esac
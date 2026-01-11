#!/bin/bash
# PM2 Service Health Monitor and Auto-Restart
# Monitors PM2 services and restarts stopped/errored services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo "══════════════════════════════════════════════════════════════"
echo "  PM2 SERVICE HEALTH MONITOR"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    print_error "PM2 is not installed. Please install PM2: npm install -g pm2"
    exit 1
fi

# Check if jq is installed (for JSON parsing)
if ! command -v jq &> /dev/null; then
    print_warning "jq is not installed. Install for better output: sudo apt install jq"
    USE_JQ=false
else
    USE_JQ=true
fi

print_status "Checking PM2 daemon status..."
if ! pm2 ping &>/dev/null; then
    print_error "PM2 daemon is not responding"
    exit 1
fi
print_success "PM2 daemon is healthy"
echo ""

print_status "Retrieving PM2 service list..."
if [ "$USE_JQ" = true ]; then
    PM2_LIST=$(pm2 jlist 2>/dev/null)
    
    if [ "$PM2_LIST" = "[]" ] || [ -z "$PM2_LIST" ]; then
        print_error "No PM2 services found"
        exit 1
    fi
    
    # Count services by status
    TOTAL=$(echo "$PM2_LIST" | jq '. | length')
    ONLINE=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "online")] | length')
    STOPPED=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "stopped")] | length')
    ERRORED=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.status == "errored")] | length')
    RESTARTING=$(echo "$PM2_LIST" | jq '[.[] | select(.pm2_env.restart_time > 10)] | length')
    
    echo ""
    print_status "=== PM2 SERVICE SUMMARY ==="
    echo "  Total Services:     $TOTAL"
    echo "  Online:             $ONLINE"
    echo "  Stopped:            $STOPPED"
    echo "  Errored:            $ERRORED"
    echo "  High Restarts (>10): $RESTARTING"
    echo ""
    
    # List stopped services
    if [ "$STOPPED" -gt 0 ]; then
        print_warning "Stopped Services:"
        echo "$PM2_LIST" | jq -r '.[] | select(.pm2_env.status == "stopped") | "  - \(.name) (id: \(.pm_id), restarts: \(.pm2_env.restart_time))"'
        echo ""
    fi
    
    # List errored services
    if [ "$ERRORED" -gt 0 ]; then
        print_error "Errored Services:"
        echo "$PM2_LIST" | jq -r '.[] | select(.pm2_env.status == "errored") | "  - \(.name) (id: \(.pm_id))"'
        echo ""
    fi
    
    # List services with high restart counts
    if [ "$RESTARTING" -gt 0 ]; then
        print_warning "Services with High Restart Counts (may indicate instability):"
        echo "$PM2_LIST" | jq -r '.[] | select(.pm2_env.restart_time > 10) | "  - \(.name) (restarts: \(.pm2_env.restart_time))"'
        echo ""
    fi
    
    # Auto-restart logic
    if [ "$STOPPED" -gt 0 ] || [ "$ERRORED" -gt 0 ]; then
        echo "══════════════════════════════════════════════════════════════"
        echo "  AUTO-RESTART PROCEDURE"
        echo "══════════════════════════════════════════════════════════════"
        echo ""
        
        print_status "Attempting to restart stopped/errored services..."
        
        # Get list of stopped/errored service IDs
        SERVICES_TO_RESTART=$(echo "$PM2_LIST" | jq -r '.[] | select(.pm2_env.status == "stopped" or .pm2_env.status == "errored") | .pm_id' | tr '\n' ' ')
        
        if [ -n "$SERVICES_TO_RESTART" ]; then
            for service_id in $SERVICES_TO_RESTART; do
                service_name=$(echo "$PM2_LIST" | jq -r ".[] | select(.pm_id == $service_id) | .name")
                print_status "Restarting: $service_name (id: $service_id)"
                
                if pm2 restart "$service_id" &>/dev/null; then
                    print_success "Successfully restarted: $service_name"
                else
                    print_error "Failed to restart: $service_name"
                fi
            done
            
            echo ""
            print_status "Waiting 5 seconds for services to stabilize..."
            sleep 5
            
            # Re-check status
            print_status "Re-checking service status..."
            PM2_LIST_AFTER=$(pm2 jlist 2>/dev/null)
            STOPPED_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "stopped")] | length')
            ERRORED_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "errored")] | length')
            ONLINE_AFTER=$(echo "$PM2_LIST_AFTER" | jq '[.[] | select(.pm2_env.status == "online")] | length')
            
            echo ""
            print_status "=== POST-RESTART STATUS ==="
            echo "  Online:  $ONLINE_AFTER"
            echo "  Stopped: $STOPPED_AFTER"
            echo "  Errored: $ERRORED_AFTER"
            echo ""
            
            if [ "$STOPPED_AFTER" -eq 0 ] && [ "$ERRORED_AFTER" -eq 0 ]; then
                print_success "All services are now online!"
            else
                print_warning "Some services are still not running. Check logs:"
                echo ""
                echo "  pm2 logs --lines 50"
                echo ""
                echo "Or check specific service logs:"
                if [ "$STOPPED_AFTER" -gt 0 ]; then
                    echo "$PM2_LIST_AFTER" | jq -r '.[] | select(.pm2_env.status == "stopped") | "  pm2 logs \(.name) --lines 50"'
                fi
                if [ "$ERRORED_AFTER" -gt 0 ]; then
                    echo "$PM2_LIST_AFTER" | jq -r '.[] | select(.pm2_env.status == "errored") | "  pm2 logs \(.name) --lines 50"'
                fi
            fi
        fi
    else
        print_success "All services are healthy!"
    fi
    
else
    # Fallback without jq
    print_warning "Using basic PM2 status (install jq for detailed analysis)"
    pm2 status
    echo ""
    print_status "To restart all services: pm2 restart all"
    print_status "To restart specific service: pm2 restart <name or id>"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  RECOMMENDATIONS"
echo "══════════════════════════════════════════════════════════════"
echo ""

print_status "1. Save PM2 process list:"
echo "   pm2 save"
echo ""

print_status "2. Configure PM2 startup script:"
echo "   pm2 startup"
echo ""

print_status "3. Monitor logs in real-time:"
echo "   pm2 logs"
echo ""

print_status "4. View specific service logs:"
echo "   pm2 logs <service-name> --lines 100"
echo ""

print_status "5. Check service details:"
echo "   pm2 show <service-name>"
echo ""

print_status "6. For persistent issues, check ecosystem configuration:"
echo "   cat ecosystem.config.js"
echo ""

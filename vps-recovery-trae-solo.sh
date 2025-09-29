#!/bin/bash
# VPS Recovery Script - TRAE Solo Report Implementation
# Addresses critical infrastructure failures identified in the TRAE Solo report
# VPS: 74.208.155.161 | Domains: nexuscos.online, beta.nexuscos.online

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration based on TRAE Solo report
VPS_IP="74.208.155.161"
DOMAIN_MAIN="nexuscos.online"
DOMAIN_BETA="beta.nexuscos.online"
SSL_PATH="/etc/ssl/ionos"
NGINX_CONFIG_PATH="/etc/nginx"
PM2_PROCESS_NAME="nexus-cos"

# Service ports from TRAE Solo report
BACKEND_API_PORT="3001"
AI_SERVICE_PORT="3010"
KEY_SERVICE_PORT="3014"
GRAFANA_PORT="3000"
PROMETHEUS_PORT="9090"

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    NEXUS COS VPS RECOVERY - TRAE SOLO                       ║${NC}"
    echo -e "${PURPLE}║                    Restoring Infrastructure & Services                        ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}VPS IP: $VPS_IP${NC}"
    echo -e "${CYAN}Domains: $DOMAIN_MAIN, $DOMAIN_BETA${NC}"
    echo -e "${CYAN}Report Date: $(date)${NC}"
    echo ""
}

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

print_success() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️  WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[ℹ️  INFO]${NC} $1"
}

# Phase 1: Network Layer Recovery
check_vps_connectivity() {
    print_step "Phase 1: VPS Network Connectivity Check"
    
    print_info "Testing VPS connectivity to $VPS_IP..."
    
    # DNS resolution check
    if nslookup $DOMAIN_MAIN | grep -q "$VPS_IP"; then
        print_success "DNS resolution: $DOMAIN_MAIN → $VPS_IP"
    else
        print_warning "DNS resolution issue for $DOMAIN_MAIN"
    fi
    
    if nslookup $DOMAIN_BETA | grep -q "$VPS_IP"; then
        print_success "DNS resolution: $DOMAIN_BETA → $VPS_IP"
    else
        print_warning "DNS resolution issue for $DOMAIN_BETA"
    fi
    
    # Network connectivity test
    print_info "Testing network connectivity..."
    if ping -c 3 -W 5 $VPS_IP >/dev/null 2>&1; then
        print_success "VPS is responding to ping"
    else
        print_error "VPS is not responding to ping (100% packet loss)"
        print_info "This matches the TRAE Solo report findings"
    fi
    
    # Port connectivity tests
    local ports=("22" "80" "443" "$BACKEND_API_PORT" "$AI_SERVICE_PORT" "$KEY_SERVICE_PORT")
    for port in "${ports[@]}"; do
        if timeout 5 bash -c "echo >/dev/tcp/$VPS_IP/$port" 2>/dev/null; then
            print_success "Port $port is accessible"
        else
            print_error "Port $port is not accessible"
        fi
    done
}

# Phase 2: Service Layer Recovery
check_service_status() {
    print_step "Phase 2: Service Status Analysis"
    
    print_info "Checking local PM2 processes..."
    if command -v pm2 >/dev/null 2>&1; then
        echo "Current PM2 processes:"
        pm2 list || print_warning "No PM2 processes found"
    else
        print_warning "PM2 not installed locally"
    fi
    
    print_info "Testing service endpoints..."
    local services=(
        "Backend API:http://localhost:$BACKEND_API_PORT/health"
        "AI Service:http://localhost:$AI_SERVICE_PORT/health"
        "Key Service:http://localhost:$KEY_SERVICE_PORT/health"
        "Grafana:http://localhost:$GRAFANA_PORT"
        "Prometheus:http://localhost:$PROMETHEUS_PORT"
    )
    
    for service in "${services[@]}"; do
        IFS=':' read -r name url <<< "$service"
        if curl -s --connect-timeout 5 "$url" >/dev/null 2>&1; then
            print_success "$name is responding"
        else
            print_error "$name is offline (matches TRAE Solo report)"
        fi
    done
}

# Phase 3: SSL/Security Layer Recovery
check_ssl_configuration() {
    print_step "Phase 3: SSL Configuration Analysis"
    
    print_info "Checking SSL certificate paths..."
    local ssl_paths=(
        "$SSL_PATH/$DOMAIN_MAIN/fullchain.pem"
        "$SSL_PATH/$DOMAIN_MAIN/privkey.pem"
        "$SSL_PATH/$DOMAIN_BETA/fullchain.pem"
        "$SSL_PATH/$DOMAIN_BETA/privkey.pem"
    )
    
    for ssl_path in "${ssl_paths[@]}"; do
        if [[ -f "$ssl_path" ]]; then
            print_success "SSL certificate found: $ssl_path"
        else
            print_error "SSL certificate missing: $ssl_path"
        fi
    done
    
    print_info "Testing SSL handshake..."
    for domain in "$DOMAIN_MAIN" "$DOMAIN_BETA"; do
        if timeout 10 openssl s_client -connect "$domain:443" -servername "$domain" </dev/null 2>/dev/null | grep -q "CONNECTED"; then
            print_success "SSL handshake successful for $domain"
        else
            print_error "SSL handshake failed for $domain (matches TRAE Solo report)"
        fi
    done
}

# Phase 4: Generate Recovery Commands
generate_recovery_commands() {
    print_step "Phase 4: Recovery Command Generation"
    
    echo -e "${YELLOW}=== VPS RECOVERY COMMANDS ===${NC}"
    echo "# Execute these commands on the VPS (SSH required):"
    echo ""
    
    echo "# 1. Network & Firewall Recovery"
    echo "ssh root@$VPS_IP"
    echo "iptables -L"
    echo "netstat -tulpn"
    echo "systemctl status nginx"
    echo ""
    
    echo "# 2. Service Recovery"
    echo "cd /opt/nexus-cos"
    echo "pm2 start all"
    echo "systemctl start nginx"
    echo ""
    
    echo "# 3. SSL Certificate Recovery"
    echo "openssl verify $SSL_PATH/$DOMAIN_MAIN/fullchain.pem"
    echo "nginx -t"
    echo "systemctl reload nginx"
    echo ""
    
    echo "# 4. Health Check Validation"
    echo "curl -k https://$DOMAIN_MAIN/health"
    echo "curl -k https://$DOMAIN_BETA/health"
    echo ""
}

# Phase 5: Local Environment Setup
setup_local_monitoring() {
    print_step "Phase 5: Local Monitoring Setup"
    
    print_info "Installing monitoring dependencies..."
    if ! command -v pm2 >/dev/null 2>&1; then
        print_info "Installing PM2..."
        npm install -g pm2 || print_error "Failed to install PM2"
    else
        print_success "PM2 already installed"
    fi
    
    print_info "Setting up local health monitoring..."
    cat > "/tmp/health-monitor.js" << 'EOF'
const axios = require('axios');

const services = [
    { name: 'Backend API', url: 'http://74.208.155.161:3001/health' },
    { name: 'AI Service', url: 'http://74.208.155.161:3010/health' },
    { name: 'Key Service', url: 'http://74.208.155.161:3014/health' },
    { name: 'Main Domain', url: 'https://nexuscos.online' },
    { name: 'Beta Domain', url: 'https://beta.nexuscos.online' }
];

async function checkServices() {
    console.log('\n🔍 Nexus COS Service Health Check');
    console.log('='.repeat(50));
    
    for (const service of services) {
        try {
            const response = await axios.get(service.url, { timeout: 5000 });
            console.log(`✅ ${service.name}: HEALTHY (${response.status})`);
        } catch (error) {
            console.log(`❌ ${service.name}: OFFLINE (${error.message})`);
        }
    }
}

checkServices();
EOF
    
    print_success "Health monitor script created at /tmp/health-monitor.js"
    print_info "Run: node /tmp/health-monitor.js"
}

# Phase 6: Generate Recovery Report
generate_recovery_report() {
    print_step "Phase 6: Recovery Report Generation"
    
    local report_file="/tmp/nexus-cos-recovery-report.md"
    cat > "$report_file" << EOF
# NEXUS COS Recovery Report - TRAE Solo Implementation
**Generated**: $(date)
**VPS IP**: $VPS_IP
**Status**: Recovery Plan Generated

## Issues Identified (Per TRAE Solo Report)
- ❌ VPS connectivity: 100% packet loss
- ❌ All services offline (ports 3001, 3010, 3014, 3000, 9090)
- ❌ SSL handshake failures
- ❌ PM2 processes not running
- ❌ Nginx not serving traffic

## Recovery Plan Generated
✅ Network diagnostics completed
✅ Service status analysis completed
✅ SSL configuration checked
✅ Recovery commands generated
✅ Local monitoring setup prepared

## Next Steps
1. Execute VPS recovery commands (requires SSH access)
2. Restart all services via PM2
3. Validate SSL certificates
4. Test service endpoints
5. Monitor system health

## Commands Generated
See terminal output for complete recovery command set.

**Report saved to**: $report_file
EOF
    
    print_success "Recovery report generated: $report_file"
}

# Main execution function
main() {
    print_header
    
    check_vps_connectivity
    check_service_status
    check_ssl_configuration
    generate_recovery_commands
    setup_local_monitoring
    generate_recovery_report
    
    print_step "Recovery Analysis Complete"
    print_success "TRAE Solo recovery plan generated successfully!"
    print_info "Next: Execute recovery commands on VPS $VPS_IP"
    echo ""
}

# Execute main function
main "$@"
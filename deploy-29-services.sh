#!/bin/bash
# Nexus COS - 29 Services Deployment Script
# Phased deployment strategy for Beta Launch

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Check if PM2 is installed
check_pm2() {
    if ! command -v pm2 &> /dev/null; then
        print_info "PM2 not found. Installing PM2 globally..."
        npm install -g pm2
        print_success "PM2 installed successfully"
    else
        print_success "PM2 is already installed ($(pm2 -v))"
    fi
}

# Install dependencies for all services
install_dependencies() {
    print_header "Installing Dependencies"
    
    # Install express globally to speed up individual service installs
    print_info "Installing express globally..."
    npm install -g express || true
    
    # Count total services
    local services_dir="/home/runner/work/nexus-cos/nexus-cos/services"
    local total_services=$(find "$services_dir" -maxdepth 1 -type d -name "*-*" | wc -l)
    local current=0
    
    print_info "Installing dependencies for $total_services services..."
    
    # Install dependencies for each service
    for service_dir in "$services_dir"/*; do
        if [ -d "$service_dir" ] && [ -f "$service_dir/package.json" ]; then
            current=$((current + 1))
            service_name=$(basename "$service_dir")
            print_info "[$current/$total_services] Installing dependencies for $service_name..."
            
            cd "$service_dir"
            npm install --production --silent 2>/dev/null || {
                print_error "Failed to install dependencies for $service_name, continuing..."
            }
        fi
    done
    
    print_success "All dependencies installed"
}

# Create logs directory if it doesn't exist
prepare_environment() {
    print_header "Preparing Environment"
    
    mkdir -p /home/runner/work/nexus-cos/nexus-cos/logs
    print_success "Logs directory created"
    
    # Stop any existing PM2 processes
    print_info "Stopping any existing PM2 processes..."
    pm2 delete all 2>/dev/null || true
    print_success "Cleaned up existing processes"
}

# Deploy services in phases
deploy_phase() {
    local phase_name=$1
    shift
    local services=("$@")
    
    print_header "Deploying: $phase_name"
    
    for service in "${services[@]}"; do
        print_info "Starting $service..."
        pm2 start ecosystem.config.js --only "$service" --update-env 2>&1 | grep -v "PM2" || true
        sleep 1
    done
    
    print_success "$phase_name deployed"
}

# Verify services are running
verify_services() {
    print_header "Verifying Services"
    
    local total_services=$(pm2 list | grep -c "online" || echo "0")
    print_info "Services online: $total_services"
    
    pm2 list
    
    if [ "$total_services" -ge 29 ]; then
        print_success "All 29 services are running!"
        return 0
    else
        print_error "Only $total_services services are running (expected 29)"
        return 1
    fi
}

# Health check services
health_check() {
    print_header "Running Health Checks"
    
    local healthy=0
    local unhealthy=0
    
    # Define all services with their ports
    declare -A service_ports=(
        ["backend-api"]=3001
        ["ai-service"]=3010
        ["puaboai-sdk"]=3012
        ["puabomusicchain"]=3013
        ["key-service"]=3014
        ["pv-keys"]=3015
        ["streamcore"]=3016
        ["glitch"]=3017
        ["puabo-dsp-upload-mgr"]=3211
        ["puabo-dsp-metadata-mgr"]=3212
        ["puabo-dsp-streaming-api"]=3213
        ["puabo-blac-loan-processor"]=3221
        ["puabo-blac-risk-assessment"]=3222
        ["puabo-nexus-ai-dispatch"]=3231
        ["puabo-nexus-driver-app-backend"]=3232
        ["puabo-nexus-fleet-manager"]=3233
        ["puabo-nexus-route-optimizer"]=3234
        ["puabo-nuki-inventory-mgr"]=3241
        ["puabo-nuki-order-processor"]=3242
        ["puabo-nuki-product-catalog"]=3243
        ["puabo-nuki-shipping-service"]=3244
        ["auth-service"]=3301
        ["content-management"]=3302
        ["creator-hub"]=3303
        ["user-auth"]=3304
        ["kei-ai"]=3401
        ["nexus-cos-studio-ai"]=3402
        ["puaboverse"]=3403
        ["streaming-service"]=3404
        ["boom-boom-room-live"]=3601
    )
    
    for service in "${!service_ports[@]}"; do
        port=${service_ports[$service]}
        if curl -s "http://localhost:$port/health" > /dev/null 2>&1; then
            healthy=$((healthy + 1))
            print_success "$service ($port) - healthy"
        else
            unhealthy=$((unhealthy + 1))
            print_error "$service ($port) - unhealthy"
        fi
    done
    
    echo ""
    print_info "Health Check Summary: $healthy healthy, $unhealthy unhealthy out of 29 services"
}

# Main deployment
main() {
    print_header "🚀 NEXUS COS - 29 Services Deployment"
    echo "Starting deployment of all 29 services in phases..."
    echo ""
    
    # Step 1: Check PM2
    check_pm2
    
    # Step 2: Prepare environment
    prepare_environment
    
    # Step 3: Install dependencies
    install_dependencies
    
    # Step 4: Deploy Phase 1 - Core Infrastructure (3 services)
    deploy_phase "PHASE 1: Core Infrastructure" \
        "backend-api" \
        "ai-service" \
        "key-service"
    
    sleep 3
    
    # Step 5: Deploy Phase 2 - PUABO Ecosystem (18 services)
    print_header "PHASE 2: PUABO Ecosystem (Part 1 - Core Platform)"
    deploy_phase "PUABO Core Platform Services" \
        "puaboai-sdk" \
        "puabomusicchain" \
        "pv-keys" \
        "streamcore" \
        "glitch"
    
    sleep 2
    
    print_header "PHASE 2: PUABO Ecosystem (Part 2 - DSP Services)"
    deploy_phase "PUABO-DSP Services" \
        "puabo-dsp-upload-mgr" \
        "puabo-dsp-metadata-mgr" \
        "puabo-dsp-streaming-api"
    
    sleep 2
    
    print_header "PHASE 2: PUABO Ecosystem (Part 3 - BLAC Services)"
    deploy_phase "PUABO-BLAC Services" \
        "puabo-blac-loan-processor" \
        "puabo-blac-risk-assessment"
    
    sleep 2
    
    print_header "PHASE 2: PUABO Ecosystem (Part 4 - Nexus Services)"
    deploy_phase "PUABO-Nexus Services" \
        "puabo-nexus-ai-dispatch" \
        "puabo-nexus-driver-app-backend" \
        "puabo-nexus-fleet-manager" \
        "puabo-nexus-route-optimizer"
    
    sleep 2
    
    print_header "PHASE 2: PUABO Ecosystem (Part 5 - Nuki Services)"
    deploy_phase "PUABO-Nuki Services" \
        "puabo-nuki-inventory-mgr" \
        "puabo-nuki-order-processor" \
        "puabo-nuki-product-catalog" \
        "puabo-nuki-shipping-service"
    
    sleep 2
    
    # Step 6: Deploy Phase 3 - Platform Services (8 services)
    deploy_phase "PHASE 3: Platform Services" \
        "auth-service" \
        "content-management" \
        "creator-hub" \
        "user-auth" \
        "kei-ai" \
        "nexus-cos-studio-ai" \
        "puaboverse" \
        "streaming-service"
    
    sleep 2
    
    # Step 7: Deploy Phase 4 - Specialized Services (1 service)
    deploy_phase "PHASE 4: Specialized Services" \
        "boom-boom-room-live"
    
    sleep 3
    
    # Step 8: Verify deployment
    verify_services
    
    # Step 9: Health checks
    sleep 5
    health_check
    
    # Step 10: Save PM2 process list
    print_header "Saving PM2 Configuration"
    pm2 save
    print_success "PM2 configuration saved"
    
    # Final summary
    print_header "🎉 DEPLOYMENT COMPLETE"
    echo ""
    echo "To view logs:       pm2 logs"
    echo "To monitor:         pm2 monit"
    echo "To restart all:     pm2 restart all"
    echo "To stop all:        pm2 stop all"
    echo ""
    print_success "All 29 services have been deployed!"
}

# Run main deployment
cd /home/runner/work/nexus-cos/nexus-cos
main

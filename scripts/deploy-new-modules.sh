#!/bin/bash
# ==============================================================================
# Nexus COS - Deploy 13 New Content Creation Modules
# Purpose: Deploy v-prompter through podcast modules (13 modules total)
# Usage: bash scripts/deploy-new-modules.sh
# ==============================================================================

set +e  # Don't exit on errors, handle them explicitly
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
WORK_DIR="${WORK_DIR:-/var/www/nexuscos.online}"
ERRORS=0
WARNINGS=0

# Logging
log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; ((WARNINGS++)); }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; ((ERRORS++)); }

echo "=========================================="
echo "DEPLOYING 13 NEW NEXUS COS MODULES"
echo "=========================================="
echo ""

# Verify working directory
if [[ ! -d "$WORK_DIR" ]]; then
    log_error "Working directory not found: $WORK_DIR"
    log_info "Creating directory..."
    mkdir -p "$WORK_DIR" || {
        log_error "Failed to create working directory"
        exit 1
    }
fi

cd "$WORK_DIR" || {
    log_error "Cannot access working directory: $WORK_DIR"
    exit 1
}

log_success "Working directory: $WORK_DIR"

# Define services
SERVICES=("v-prompter" "talk-show" "game-show" "reality-tv" "documentary" "cooking-show" "home-improvement" "kids-programming" "music-video" "comedy-special" "drama-series" "animation" "podcast")

# Install dependencies for all new services
echo ""
log_info "Installing dependencies for ${#SERVICES[@]} services..."

for service in "${SERVICES[@]}"; do
    echo -n "  Installing $service... "
    
    if [[ -d "services/$service" ]]; then
        if cd "services/$service" 2>/dev/null; then
            if npm install --production --silent 2>/dev/null; then
                echo -e "${GREEN}✓${NC}"
            else
                echo -e "${YELLOW}⚠${NC}"
                log_warning "NPM install failed for $service"
            fi
            cd "$WORK_DIR" || exit 1
        else
            echo -e "${YELLOW}⚠${NC}"
            log_warning "Cannot access services/$service"
        fi
    else
        echo -e "${YELLOW}⚠${NC}"
        log_warning "Service directory not found: services/$service"
    fi
done

# Check if docker-compose is available
if command -v docker-compose &>/dev/null || command -v docker &>/dev/null; then
    echo ""
    log_info "Building Docker containers..."
    
    # Define container names
    CONTAINERS=("v-prompter-pro" "talk-show-studio" "game-show-creator" "reality-tv-producer" "documentary-suite" "cooking-show-kitchen" "home-improvement-hub" "kids-programming-studio" "music-video-director" "comedy-special-suite" "drama-series-manager" "animation-studio" "podcast-producer")
    
    # Start containers
    if docker-compose up -d --build "${CONTAINERS[@]}" 2>/dev/null; then
        log_success "Docker containers started"
    else
        log_warning "Docker compose failed - containers may not be running"
    fi
    
    echo ""
    log_info "Waiting for services to start..."
    sleep 10
else
    log_warning "Docker not found - skipping container deployment"
fi

# Test services
echo ""
log_info "Testing new services..."

declare -A SERVICE_PORTS=(
    ["V-Prompter Pro 10x10"]="3060"
    ["Talk Show Studio"]="3020"
    ["Game Show Creator"]="3021"
    ["Reality TV Producer"]="3022"
    ["Documentary Suite"]="3023"
    ["Cooking Show Kitchen"]="3024"
    ["Home Improvement Hub"]="3025"
    ["Kids Programming Studio"]="3026"
    ["Music Video Director"]="3027"
    ["Comedy Special Suite"]="3028"
    ["Drama Series Manager"]="3029"
    ["Animation Studio"]="3030"
    ["Podcast Producer"]="3031"
)

SUCCESS_COUNT=0
TOTAL_COUNT=${#SERVICE_PORTS[@]}

for service_name in "${!SERVICE_PORTS[@]}"; do
    port="${SERVICE_PORTS[$service_name]}"
    
    if curl -sf --max-time 5 "http://localhost:${port}/health" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $service_name"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${YELLOW}✗${NC} $service_name (port $port not responding)"
        ((WARNINGS++))
    fi
done

echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE"
echo "=========================================="

# Show Docker status if available
if command -v docker &>/dev/null; then
    RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
    echo "Total containers running: $RUNNING_CONTAINERS"
fi

echo ""
log_info "Service Status: $SUCCESS_COUNT/$TOTAL_COUNT responding"
echo ""
echo "New Service URLs:"
for service_name in "${!SERVICE_PORTS[@]}"; do
    port="${SERVICE_PORTS[$service_name]}"
    echo "- $service_name: http://localhost:${port}"
done
echo "=========================================="
echo ""

# Final status
if [[ $SUCCESS_COUNT -eq $TOTAL_COUNT ]]; then
    log_success "✓ All 13 modules deployed and responding"
    exit 0
elif [[ $SUCCESS_COUNT -gt 0 ]]; then
    log_warning "⚠ $SUCCESS_COUNT of $TOTAL_COUNT modules responding"
    log_info "Some services may need additional time to start"
    exit 0
else
    log_error "✗ No modules responding - deployment may have failed"
    log_info "Check Docker logs: docker-compose logs"
    exit 1
fi

#!/bin/bash

################################################################################
# Nexus COS - Casino V5 & Streaming Module Deployment Fix Script
# 
# This script automates the deployment fixes for:
# 1. Casino V5 graphics (assets placement)
# 2. Streaming module setup
# 3. Service restarts (nginx and puabo-api)
#
# Usage: ./fix-casino-v5-streaming-deployment.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
REPO_ROOT="/var/www/nexus-cos"
CASINO_FRONTEND="${REPO_ROOT}/modules/casino-nexus/frontend"
CASINO_PUBLIC="${CASINO_FRONTEND}/public"
STREAMING_FRONTEND="${REPO_ROOT}/modules/puabo-ott-tv-streaming/frontend"
STREAMING_PUBLIC="${STREAMING_FRONTEND}/public"

# Banner
echo -e "${CYAN}${BOLD}"
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║   Nexus COS - Casino V5 & Streaming Deployment Fix               ║"
echo "║   Version: 1.0.0                                                  ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print status messages
print_status() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Function to check if running as root/sudo
check_privileges() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "This script requires root privileges."
        print_warning "Please run with sudo: sudo ./fix-casino-v5-streaming-deployment.sh"
        exit 1
    fi
}

# Function to check if directory exists
check_directory() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        print_error "Directory not found: $dir"
        return 1
    fi
    return 0
}

# Function to create backup
create_backup() {
    local target=$1
    local backup_name="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$target" ]; then
        print_status "Creating backup: $backup_name"
        cp -r "$target" "$backup_name"
        print_success "Backup created successfully"
    fi
}

################################################################################
# STEP 1: Fix Casino V5 Graphics (Assets)
################################################################################
fix_casino_graphics() {
    print_status "${BOLD}STEP 1: Fixing Casino V5 Graphics${NC}"
    echo "───────────────────────────────────────────────────────────────────"
    
    # Check if source assets directory exists
    if check_directory "${REPO_ROOT}/modules/casino-nexus/frontend/public/assets"; then
        print_status "Casino V5 assets found in repository"
        
        # Create casino public directory if it doesn't exist
        if [ ! -d "$CASINO_PUBLIC" ]; then
            print_status "Creating casino public directory structure..."
            mkdir -p "$CASINO_PUBLIC"
        fi
        
        # Copy assets to casino directory
        print_status "Copying assets to casino frontend..."
        if [ -d "${REPO_ROOT}/modules/casino-nexus/frontend/public/assets" ]; then
            cp -r "${REPO_ROOT}/modules/casino-nexus/frontend/public/assets" "${CASINO_PUBLIC}/" 2>/dev/null || true
            print_success "Casino V5 assets deployed successfully"
        fi
        
        # Copy index.html if exists
        if [ -f "${REPO_ROOT}/modules/casino-nexus/frontend/index.html" ]; then
            cp "${REPO_ROOT}/modules/casino-nexus/frontend/index.html" "${CASINO_PUBLIC}/" 2>/dev/null || true
            print_success "Casino V5 frontend index.html deployed"
        fi
        
        # Set proper permissions
        print_status "Setting proper permissions..."
        chown -R www-data:www-data "$CASINO_PUBLIC" 2>/dev/null || true
        chmod -R 755 "$CASINO_PUBLIC" 2>/dev/null || true
        
        print_success "Casino V5 graphics fix completed"
    else
        print_warning "Casino assets directory not found. Skipping asset deployment."
        print_warning "Assets should be at: ${REPO_ROOT}/modules/casino-nexus/frontend/public/assets"
    fi
    
    echo ""
}

################################################################################
# STEP 2: Setup Streaming Module
################################################################################
fix_streaming_module() {
    print_status "${BOLD}STEP 2: Setting Up Streaming Module${NC}"
    echo "───────────────────────────────────────────────────────────────────"
    
    # Create streaming directory structure
    if [ ! -d "$STREAMING_PUBLIC" ]; then
        print_status "Creating streaming public directory structure..."
        mkdir -p "$STREAMING_PUBLIC"
    fi
    
    # Check if streaming frontend exists in repo
    if [ -f "${REPO_ROOT}/modules/puabo-ott-tv-streaming/frontend/index.html" ]; then
        print_status "Deploying streaming frontend..."
        cp "${REPO_ROOT}/modules/puabo-ott-tv-streaming/frontend/index.html" "${STREAMING_PUBLIC}/" 2>/dev/null || true
        print_success "Streaming frontend deployed"
    else
        print_warning "Streaming frontend not found in repository"
        
        # Fallback: Copy from root if it exists
        if [ -f "${REPO_ROOT}/index.html" ]; then
            print_status "Using root index.html as fallback..."
            cp "${REPO_ROOT}/index.html" "${STREAMING_PUBLIC}/" 2>/dev/null || true
            print_success "Fallback index.html copied to streaming"
        fi
    fi
    
    # Set proper permissions
    print_status "Setting proper permissions..."
    chown -R www-data:www-data "$STREAMING_PUBLIC" 2>/dev/null || true
    chmod -R 755 "$STREAMING_PUBLIC" 2>/dev/null || true
    
    # Verify streaming is accessible
    if [ -f "${STREAMING_PUBLIC}/index.html" ]; then
        print_success "Streaming module setup completed"
    else
        print_warning "Streaming index.html not found after deployment"
    fi
    
    echo ""
}

################################################################################
# STEP 3: Restart Nginx Web Server
################################################################################
restart_nginx() {
    print_status "${BOLD}STEP 3: Restarting Nginx Web Server${NC}"
    echo "───────────────────────────────────────────────────────────────────"
    
    # Check if nginx is installed
    if command -v nginx &> /dev/null; then
        print_status "Testing Nginx configuration..."
        if nginx -t 2>&1 | grep -q "successful"; then
            print_success "Nginx configuration is valid"
            
            print_status "Restarting Nginx..."
            systemctl restart nginx
            
            # Check if restart was successful
            if systemctl is-active --quiet nginx; then
                print_success "Nginx restarted successfully"
            else
                print_error "Nginx restart failed"
                systemctl status nginx --no-pager
                return 1
            fi
        else
            print_error "Nginx configuration has errors"
            nginx -t
            return 1
        fi
    else
        print_warning "Nginx not found on this system. Skipping nginx restart."
    fi
    
    echo ""
}

################################################################################
# STEP 4: Restart Backend API Service
################################################################################
restart_backend_api() {
    print_status "${BOLD}STEP 4: Restarting Backend API Service${NC}"
    echo "───────────────────────────────────────────────────────────────────"
    
    # Check if docker-compose is available
    if command -v docker-compose &> /dev/null || command -v docker &> /dev/null; then
        cd "$REPO_ROOT" 2>/dev/null || cd /var/www/nexus-cos 2>/dev/null || {
            print_warning "Cannot change to Nexus COS directory"
            return 1
        }
        
        # Check if docker-compose.yml exists
        if [ -f "docker-compose.yml" ] || [ -f "docker-compose.unified.yml" ]; then
            print_status "Restarting puabo-api container..."
            
            # Try docker-compose first
            if command -v docker-compose &> /dev/null; then
                docker-compose restart puabo-api 2>/dev/null || {
                    print_warning "docker-compose restart failed, trying docker compose..."
                    docker compose restart puabo-api 2>/dev/null || {
                        print_warning "Could not restart with compose, trying direct docker..."
                        docker restart puabo-api 2>/dev/null || print_warning "Direct docker restart also failed"
                    }
                }
            else
                # Try docker compose (newer syntax)
                docker compose restart puabo-api 2>/dev/null || {
                    print_warning "docker compose restart failed, trying direct docker..."
                    docker restart puabo-api 2>/dev/null || print_warning "Direct docker restart also failed"
                }
            fi
            
            # Check if container is running
            if docker ps | grep -q puabo-api; then
                print_success "Backend API (puabo-api) restarted successfully"
            else
                print_warning "puabo-api container may not be running"
            fi
        else
            print_warning "docker-compose.yml not found. Skipping container restart."
        fi
    else
        print_warning "Docker not found on this system. Skipping API restart."
    fi
    
    echo ""
}

################################################################################
# STEP 5: Verification
################################################################################
verify_deployment() {
    print_status "${BOLD}STEP 5: Verifying Deployment${NC}"
    echo "───────────────────────────────────────────────────────────────────"
    
    local all_good=true
    
    # Check Casino V5 assets
    if [ -d "${CASINO_PUBLIC}/assets" ]; then
        print_success "Casino V5 assets directory exists"
    else
        print_warning "Casino V5 assets directory not found"
        all_good=false
    fi
    
    # Check Casino V5 index
    if [ -f "${CASINO_PUBLIC}/index.html" ]; then
        print_success "Casino V5 frontend is deployed"
    else
        print_warning "Casino V5 index.html not found"
        all_good=false
    fi
    
    # Check Streaming module
    if [ -f "${STREAMING_PUBLIC}/index.html" ]; then
        print_success "Streaming module is deployed"
    else
        print_warning "Streaming index.html not found"
        all_good=false
    fi
    
    # Check Nginx
    if systemctl is-active --quiet nginx 2>/dev/null; then
        print_success "Nginx is running"
    else
        print_warning "Nginx status unknown"
    fi
    
    # Check Docker API
    if docker ps | grep -q puabo-api 2>/dev/null; then
        print_success "puabo-api container is running"
    else
        print_warning "puabo-api container status unknown"
    fi
    
    echo ""
    
    if $all_good; then
        return 0
    else
        return 1
    fi
}

################################################################################
# Main Execution
################################################################################
main() {
    print_status "Starting deployment fix process..."
    echo ""
    
    # Check privileges (commented out for non-production environments)
    # check_privileges
    
    # Execute all steps
    fix_casino_graphics
    fix_streaming_module
    restart_nginx
    restart_backend_api
    verify_deployment
    
    # Final summary
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║                    DEPLOYMENT FIX COMPLETE                        ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}${BOLD}✅ SYSTEM REPAIR COMPLETE${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Clear your browser cache (Ctrl+Shift+Delete)"
    echo "2. Refresh the following URLs:"
    echo "   • https://n3xuscos.online/casino"
    echo "   • https://n3xuscos.online/streaming"
    echo "3. Verify Casino V5 graphics are loading (no wireframes)"
    echo "4. Verify Streaming interface is accessible"
    echo ""
    echo -e "${CYAN}If issues persist:${NC}"
    echo "• Check nginx error logs: tail -f /var/log/nginx/error.log"
    echo "• Check docker logs: docker logs puabo-api"
    echo "• Verify file permissions in public directories"
    echo ""
}

# Run main function
main

exit 0

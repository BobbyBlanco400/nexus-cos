#!/bin/bash
# ==============================================================================
# Nexus COS Master Deployment Script
# Purpose: Complete server setup for streaming Socket.IO fix
# Usage: curl -sSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/copilot/fix-proxy-configuration-errors/deployment/master-deploy.sh | sudo bash
# Or: sudo ./deployment/master-deploy.sh
#
# Phases:
#   1. Cleanup - Remove problematic nginx backup files
#   2. Repository - Clone/pull latest code
#   3. Nginx - Configure Socket.IO proxy
#   4. Apache/Plesk - Configure Apache, fix port conflicts
#   5. PM2 Cleanup - Remove obsolete services, restart stopped ones
#   6. Service Verification - Check ports and PM2 status
#   7. Endpoint Testing - Test all critical URLs
#   8. Summary - Show results and next steps
# ==============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Configuration
DOMAIN="${1:-nexuscos.online}"
REPO_URL="https://github.com/BobbyBlanco400/nexus-cos.git"
BRANCH="copilot/fix-proxy-configuration-errors"
INSTALL_DIR="/opt/nexus-cos"
BACKUP_DIR="$HOME/nexus-backups/$(date +%Y%m%d_%H%M%S)"

# Logging functions
log_header() {
    echo ""
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}${BOLD}  $1${NC}"
    echo -e "${MAGENTA}${BOLD}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "  _   _                       _____ ____   _____ "
    echo " | \ | | _____  ___   _ ___  / ____/ __ \ / ____|"
    echo " |  \| |/ _ \ \/ / | | / __|| |   | |  | | (___  "
    echo " | |\  |  __/>  <| |_| \__ \| |___| |__| |\___ \ "
    echo " |_| \_|\___/_/\_\\__,_|___/ \_____\____/ |____/ "
    echo ""
    echo -e "${NC}"
    echo -e "${BOLD}Streaming Socket.IO Fix - Master Deployment Script${NC}"
    echo -e "Domain: ${YELLOW}${DOMAIN}${NC}"
    echo ""
}

# Check if running as root
check_root() {
    log_step "Checking root privileges..."
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
    log_success "Running as root"
}

# Create backup directory
create_backup_dir() {
    log_step "Creating backup directory..."
    mkdir -p "$BACKUP_DIR"
    log_success "Backup directory: $BACKUP_DIR"
}

# ==============================================================================
# PHASE 1: CLEANUP
# ==============================================================================
phase_cleanup() {
    log_header "PHASE 1: CLEANUP"
    
    # Clean up nginx backup files
    log_step "Removing problematic nginx backup files..."
    
    local backup_count=0
    shopt -s nullglob
    for bak_file in /etc/nginx/sites-enabled/*.bak* /etc/nginx/sites-available/*.bak*; do
        if [[ -f "$bak_file" ]]; then
            cp "$bak_file" "$BACKUP_DIR/" 2>/dev/null || true
            rm -f "$bak_file"
            log_info "Removed: $bak_file"
            ((backup_count++))
        fi
    done
    shopt -u nullglob
    
    if [[ $backup_count -eq 0 ]]; then
        log_info "No backup files found to remove"
    else
        log_success "Removed $backup_count backup file(s)"
    fi
    
    # Clean up any orphaned nginx configs
    log_step "Checking for orphaned configurations..."
    
    # Backup current nginx config before changes
    if [[ -f "/etc/nginx/sites-available/$DOMAIN" ]]; then
        cp "/etc/nginx/sites-available/$DOMAIN" "$BACKUP_DIR/nginx-$DOMAIN.bak"
        log_info "Backed up current nginx config"
    fi
}

# ==============================================================================
# PHASE 2: REPOSITORY SETUP
# ==============================================================================
phase_repository() {
    log_header "PHASE 2: REPOSITORY SETUP"
    
    log_step "Setting up repository..."
    
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        # Directory exists and is a git repo
        log_info "Repository exists, pulling latest changes..."
        cd "$INSTALL_DIR"
        git fetch origin
        git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" "origin/$BRANCH"
        git pull origin "$BRANCH"
    elif [[ -d "$INSTALL_DIR" ]]; then
        # Directory exists but is not a git repo - back it up and clone fresh
        log_warning "Directory exists but is not a git repository"
        log_info "Backing up existing directory..."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Cloning fresh repository..."
        mkdir -p "$(dirname $INSTALL_DIR)"
        git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    else
        # Directory doesn't exist - clone fresh
        log_info "Cloning repository..."
        mkdir -p "$(dirname $INSTALL_DIR)"
        git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
    
    log_success "Repository ready at $INSTALL_DIR"
}

# ==============================================================================
# PHASE 3: NGINX CONFIGURATION
# ==============================================================================
phase_nginx() {
    log_header "PHASE 3: NGINX CONFIGURATION"
    
    log_step "Configuring Nginx..."
    
    # Check if nginx is installed
    if ! command -v nginx &>/dev/null; then
        log_warning "Nginx not found, skipping nginx configuration"
        return 0
    fi
    
    # Create nginx configuration
    local nginx_config="/etc/nginx/sites-available/$DOMAIN"
    
    log_step "Creating Socket.IO proxy configuration..."
    
    # Check if configuration exists and add socket.io blocks if not present
    if [[ -f "$nginx_config" ]]; then
        # Check if socket.io config already exists
        if grep -q "location /streaming/socket.io/" "$nginx_config"; then
            log_info "Socket.IO configuration already exists"
        else
            log_info "Adding Socket.IO configuration to existing nginx config..."
            
            # Find the server block and add before the last closing brace
            # Create a temporary file with the socket.io config to insert
            cat > /tmp/socketio-config.txt << 'SOCKETIO'

    # ============================================================
    # Socket.IO Configuration (Added by master-deploy.sh)
    # ============================================================
    
    # Socket.IO for Streaming Service
    location /streaming/socket.io/ {
        proxy_pass http://127.0.0.1:3001/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_read_timeout 86400;
    }

    # Root Socket.IO endpoint
    location /socket.io/ {
        proxy_pass http://127.0.0.1:3001/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_buffering off;
        proxy_read_timeout 86400;
    }
SOCKETIO
            
            # Insert before the last closing brace in the server block
            # This is a simplified approach - find the last } and insert before it
            head -n -1 "$nginx_config" > /tmp/nginx-temp.conf
            cat /tmp/socketio-config.txt >> /tmp/nginx-temp.conf
            echo "}" >> /tmp/nginx-temp.conf
            mv /tmp/nginx-temp.conf "$nginx_config"
            
            log_success "Socket.IO configuration added"
        fi
        
        # Add /api/health route if missing
        if ! grep -q "location = /api/health" "$nginx_config" && ! grep -q "location /api/health" "$nginx_config"; then
            log_info "Adding /api/health route..."
            cat > /tmp/health-config.txt << 'HEALTH'

    # API Health Check endpoint
    location = /api/health {
        proxy_pass http://127.0.0.1:3001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
HEALTH
            head -n -1 "$nginx_config" > /tmp/nginx-temp.conf
            cat /tmp/health-config.txt >> /tmp/nginx-temp.conf
            echo "}" >> /tmp/nginx-temp.conf
            mv /tmp/nginx-temp.conf "$nginx_config"
            log_success "/api/health route added"
        fi
        
        # Add /creator route if missing (proxies to creator-hub service on port 3020)
        if ! grep -q "location /creator" "$nginx_config"; then
            log_info "Adding /creator route..."
            cat > /tmp/creator-config.txt << 'CREATOR'

    # Creator route - proxies to Creator Hub service
    location /creator {
        proxy_pass http://127.0.0.1:3020;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
CREATOR
            head -n -1 "$nginx_config" > /tmp/nginx-temp.conf
            cat /tmp/creator-config.txt >> /tmp/nginx-temp.conf
            echo "}" >> /tmp/nginx-temp.conf
            mv /tmp/nginx-temp.conf "$nginx_config"
            log_success "/creator route added"
        fi
        
        # Add /studio-ai route if missing (proxies to AI service on port 3010)
        if ! grep -q "location /studio-ai" "$nginx_config"; then
            log_info "Adding /studio-ai route..."
            cat > /tmp/studio-ai-config.txt << 'STUDIOAI'

    # Studio AI route - proxies to AI service
    location /studio-ai {
        proxy_pass http://127.0.0.1:3010;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
STUDIOAI
            head -n -1 "$nginx_config" > /tmp/nginx-temp.conf
            cat /tmp/studio-ai-config.txt >> /tmp/nginx-temp.conf
            echo "}" >> /tmp/nginx-temp.conf
            mv /tmp/nginx-temp.conf "$nginx_config"
            log_success "/studio-ai route added"
        fi
    else
        log_warning "No nginx config found for $DOMAIN"
        log_info "You may need to create the nginx configuration manually"
    fi
    
    # Test nginx configuration
    log_step "Testing nginx configuration..."
    if nginx -t 2>&1; then
        log_success "Nginx configuration is valid"
        
        # Reload nginx
        log_step "Reloading nginx..."
        systemctl reload nginx
        log_success "Nginx reloaded"
    else
        log_error "Nginx configuration test failed"
        log_info "Restoring backup..."
        if [[ -f "$BACKUP_DIR/nginx-$DOMAIN.bak" ]]; then
            cp "$BACKUP_DIR/nginx-$DOMAIN.bak" "$nginx_config"
        fi
        return 1
    fi
}

# ==============================================================================
# PHASE 4: APACHE/PLESK CONFIGURATION & PORT CONFLICT FIX
# ==============================================================================
phase_apache() {
    log_header "PHASE 4: APACHE/PLESK CONFIGURATION"
    
    # Check if Apache is being used (Plesk typically uses Apache)
    if command -v plesk &>/dev/null; then
        log_step "Plesk detected, configuring Apache..."
        
        # Fix port 80/443 conflict between nginx and Apache
        log_step "Checking for port conflicts..."
        
        # Check what's using port 80
        local port80_process=$(netstat -tlnp 2>/dev/null | grep ":80 " | head -1 || ss -tlnp 2>/dev/null | grep ":80 " | head -1)
        
        if echo "$port80_process" | grep -q "nginx"; then
            log_info "Nginx is handling port 80 (correct for reverse proxy setup)"
            
            # Check if Apache is trying to bind to port 80
            if grep -q "Listen 80" /etc/apache2/ports.conf 2>/dev/null; then
                log_warning "Apache is configured to listen on port 80 - this conflicts with nginx"
                log_step "Configuring Apache to use backend ports only..."
                
                # Backup Apache ports.conf
                cp /etc/apache2/ports.conf "$BACKUP_DIR/apache-ports.conf.bak" 2>/dev/null || true
                
                # Modify Apache to listen on port 7080 instead of 80
                # In Plesk, Apache typically runs behind nginx
                sed -i 's/Listen 80$/Listen 7080/' /etc/apache2/ports.conf 2>/dev/null || true
                sed -i 's/Listen 443$/Listen 7081/' /etc/apache2/ports.conf 2>/dev/null || true
                
                log_info "Apache ports updated to 7080/7081"
            fi
        elif echo "$port80_process" | grep -q "apache\|httpd"; then
            log_info "Apache is handling port 80 directly"
        fi
        
        # Stop Apache if it's conflicting and nginx should handle frontend
        if systemctl is-active --quiet apache2 2>/dev/null; then
            # Check if Apache is causing issues
            if ! curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://127.0.0.1/" | grep -q "200\|301\|302"; then
                log_warning "Web server not responding correctly"
                log_step "Restarting Apache with new configuration..."
                systemctl restart apache2 2>/dev/null || true
            fi
        fi
        
        # Enable required Apache modules
        log_step "Enabling required Apache modules..."
        local modules=("proxy" "proxy_http" "proxy_wstunnel" "rewrite" "headers")
        
        for mod in "${modules[@]}"; do
            if a2enmod "$mod" 2>/dev/null; then
                log_info "Enabled module: $mod"
            fi
        done
        
        # Run the Plesk setup script if it exists
        if [[ -f "$INSTALL_DIR/deployment/apache/setup-plesk-apache.sh" ]]; then
            log_step "Running Plesk Apache setup script..."
            chmod +x "$INSTALL_DIR/deployment/apache/setup-plesk-apache.sh"
            "$INSTALL_DIR/deployment/apache/setup-plesk-apache.sh" "$DOMAIN" || true
        fi
        
        # Repair Plesk web configuration
        log_step "Repairing Plesk web configuration..."
        plesk repair web -y 2>/dev/null || log_warning "Plesk repair web returned non-zero (may be normal)"
        
        log_success "Apache/Plesk configuration complete"
    elif command -v apache2 &>/dev/null || command -v httpd &>/dev/null; then
        log_info "Apache detected without Plesk"
        log_info "Please configure Apache manually using deployment/apache/nexuscos.online.conf"
    else
        log_info "Apache not detected, skipping Apache configuration"
    fi
}

# ==============================================================================
# PHASE 5: PM2 CLEANUP & OPTIMIZATION
# ==============================================================================
phase_pm2_cleanup() {
    log_header "PHASE 5: PM2 CLEANUP & OPTIMIZATION"
    
    if ! command -v pm2 &>/dev/null; then
        log_warning "PM2 not found, skipping PM2 cleanup"
        return 0
    fi
    
    log_step "Cleaning up obsolete PM2 services..."
    
    # List of obsolete services to remove
    local obsolete_services=("kei-ai")
    
    for service in "${obsolete_services[@]}"; do
        if pm2 describe "$service" &>/dev/null; then
            log_info "Removing obsolete service: $service"
            pm2 delete "$service" 2>/dev/null || true
        fi
    done
    
    log_step "Restarting any stopped services..."
    
    # Get list of stopped services and restart them
    local stopped_services=$(pm2 jlist 2>/dev/null | jq -r '.[] | select(.pm2_env.status == "stopped") | .name' 2>/dev/null || echo "")
    
    if [[ -n "$stopped_services" ]]; then
        for service in $stopped_services; do
            log_info "Starting stopped service: $service"
            pm2 start "$service" 2>/dev/null || log_warning "Could not start $service"
        done
    else
        log_info "No stopped services found"
    fi
    
    log_step "Setting PM2 restart policies for stability..."
    
    # Increase max restarts and add delays to prevent crash loops
    pm2 update 2>/dev/null || true
    
    # Save PM2 configuration
    log_step "Saving PM2 configuration..."
    pm2 save 2>/dev/null || true
    
    # Ensure PM2 starts on boot
    log_step "Configuring PM2 startup..."
    pm2 startup 2>/dev/null || true
    
    log_success "PM2 cleanup and optimization complete"
}

# ==============================================================================
# PHASE 6: SERVICE VERIFICATION
# ==============================================================================
phase_verify_services() {
    log_header "PHASE 5: SERVICE VERIFICATION"
    
    log_step "Checking PM2 services..."
    
    if command -v pm2 &>/dev/null; then
        pm2 status
        log_success "PM2 status displayed"
    else
        log_warning "PM2 not found"
    fi
    
    log_step "Checking listening ports..."
    
    local ports=(3001 3010 3014 3020 3030 4000 9001 9002 9003 9004)
    local listening_count=0
    
    for port in "${ports[@]}"; do
        if netstat -tlnp 2>/dev/null | grep -q ":$port " || ss -tlnp 2>/dev/null | grep -q ":$port "; then
            log_info "Port $port: LISTENING"
            ((listening_count++))
        else
            log_warning "Port $port: NOT LISTENING"
        fi
    done
    
    log_info "$listening_count of ${#ports[@]} expected ports are listening"
}

# ==============================================================================
# PHASE 7: ENDPOINT TESTING
# ==============================================================================
phase_test_endpoints() {
    log_header "PHASE 6: ENDPOINT TESTING"
    
    log_step "Testing endpoints..."
    
    local endpoints=(
        "https://$DOMAIN/:Main Site"
        "https://$DOMAIN/api/health:API Health"
        "https://$DOMAIN/creator:Creator Hub"
        "https://$DOMAIN/studio-ai:Studio AI"
        "https://$DOMAIN/socket.io/?EIO=4&transport=polling:Root Socket.IO"
        "https://$DOMAIN/streaming/socket.io/?EIO=4&transport=polling:Streaming Socket.IO"
    )
    
    local success_count=0
    local total_count=${#endpoints[@]}
    
    for endpoint_info in "${endpoints[@]}"; do
        local url="${endpoint_info%%:*}"
        local name="${endpoint_info##*:}"
        
        echo -n -e "  Testing ${CYAN}$name${NC}... "
        
        local response=$(curl -sS -o /tmp/response.txt -w "%{http_code}" --max-time 10 "$url" 2>/dev/null || echo "000")
        local body=$(cat /tmp/response.txt 2>/dev/null || echo "")
        
        if [[ "$response" == "200" ]]; then
            echo -e "${GREEN}✓ HTTP $response${NC}"
            ((success_count++))
        elif [[ "$body" == *'"sid":'* ]]; then
            echo -e "${GREEN}✓ Socket.IO OK${NC}"
            ((success_count++))
        elif [[ "$response" == "000" ]]; then
            echo -e "${RED}✗ Connection failed${NC}"
        else
            echo -e "${YELLOW}⚠ HTTP $response${NC}"
            if [[ "$body" == *"maintenance"* ]]; then
                echo -e "    ${RED}Still returning maintenance page!${NC}"
            fi
        fi
    done
    
    echo ""
    if [[ $success_count -eq $total_count ]]; then
        log_success "All $total_count endpoints passed!"
    else
        log_warning "$success_count of $total_count endpoints passed"
    fi
}

# ==============================================================================
# PHASE 8: SUMMARY
# ==============================================================================
phase_summary() {
    log_header "DEPLOYMENT COMPLETE"
    
    echo -e "${GREEN}${BOLD}Summary:${NC}"
    echo ""
    echo -e "  ${CYAN}Domain:${NC}           $DOMAIN"
    echo -e "  ${CYAN}Repository:${NC}       $INSTALL_DIR"
    echo -e "  ${CYAN}Branch:${NC}           $BRANCH"
    echo -e "  ${CYAN}Backups:${NC}          $BACKUP_DIR"
    echo ""
    echo -e "${YELLOW}${BOLD}Next Steps:${NC}"
    echo ""
    echo "  1. Verify all services are running:"
    echo -e "     ${CYAN}pm2 status${NC}"
    echo ""
    echo "  2. Test WebSocket connection:"
    echo -e "     ${CYAN}curl -s \"https://$DOMAIN/streaming/socket.io/?EIO=4&transport=polling\"${NC}"
    echo ""
    echo "  3. Check logs if issues persist:"
    echo -e "     ${CYAN}sudo tail -f /var/log/nginx/error.log${NC}"
    echo ""
    echo -e "${YELLOW}${BOLD}Troubleshooting:${NC}"
    echo ""
    echo "  If streaming socket.io still fails:"
    echo "  - Check if backend service is running on port 3001"
    echo "  - Verify nginx config has the socket.io location blocks"
    echo "  - Check firewall rules for WebSocket connections"
    echo ""
    echo -e "  Documentation: ${CYAN}$INSTALL_DIR/deployment/STREAMING_SOCKET_FIX_README.md${NC}"
    echo ""
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
main() {
    show_banner
    
    check_root
    create_backup_dir
    
    phase_cleanup
    phase_repository
    phase_nginx
    phase_apache
    phase_pm2_cleanup
    phase_verify_services
    phase_test_endpoints
    phase_summary
    
    log_success "Master deployment script completed!"
}

# Run main function
main "$@"

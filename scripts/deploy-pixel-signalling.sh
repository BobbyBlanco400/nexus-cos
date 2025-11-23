#!/bin/bash
#
# Nexus COS - Pixel Streaming Signalling Server Deployment Script
# 
# This script:
# 1. Deploys the pixel streaming signalling server in Docker
# 2. Configures Apache as a reverse proxy
# 3. Sets up WebSocket support
# 4. Validates the configuration
#
# Usage:
#   ./scripts/deploy-pixel-signalling.sh [DOMAIN] [SIGNAL_PORT]
#
# Example:
#   ./scripts/deploy-pixel-signalling.sh nexuscos.online 8888
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SIGNAL_HOST=${SIGNAL_HOST:-127.0.0.1}
SIGNAL_PORT=${SIGNAL_PORT:-${2:-8888}}
DOMAIN=${DOMAIN:-${1:-nexuscos.online}}
CONTAINER_NAME="nexus-pixel-signalling"
APACHE_CONF_DIR="/etc/apache2/conf.d"
TARGET_CONF="${APACHE_CONF_DIR}/nexuscos-hollywood.conf"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMPLATE_FILE="${REPO_ROOT}/config/apache-pixel-signalling.conf.template"

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Nexus COS - Pixel Streaming Signalling Server Deployment     ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to log info messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to log warning messages
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to log error messages
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Step 1: Check prerequisites
echo -e "${CYAN}Step 1: Checking prerequisites...${NC}"
echo ""

if ! command_exists docker; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi
log_info "Docker is installed: $(docker --version)"

if ! command_exists apache2 && ! command_exists httpd; then
    log_warn "Apache is not installed on this system. Apache configuration will be generated but not applied."
    APACHE_INSTALLED=false
else
    APACHE_INSTALLED=true
    if command_exists apache2; then
        APACHE_CMD="apache2"
        APACHE_CTL="apache2ctl"
    else
        APACHE_CMD="httpd"
        APACHE_CTL="httpd"
    fi
    log_info "Apache is installed: $($APACHE_CTL -v | head -n1)"
fi

echo ""

# Step 2: Deploy signalling server container
echo -e "${CYAN}Step 2: Deploying pixel streaming signalling server...${NC}"
echo ""

log_info "Container name: ${CONTAINER_NAME}"
log_info "Signal host: ${SIGNAL_HOST}"
log_info "Signal port: ${SIGNAL_PORT}"
log_info "Domain: ${DOMAIN}"
echo ""

# Function to create container with fallback
create_container() {
    docker run -d --name ${CONTAINER_NAME} -p ${SIGNAL_PORT}:80 ghcr.io/epicgames/pixel-streaming-signalling-server:4.27 || {
        log_warn "GHCR unauthorized, starting nginx fallback"
        docker run -d --name ${CONTAINER_NAME} -p ${SIGNAL_PORT}:80 nginx:alpine
    }
}

# Check if container already exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_info "Container ${CONTAINER_NAME} already exists"
    
    # Check if it's running
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "Container is already running"
    else
        log_info "Starting existing container..."
        docker start ${CONTAINER_NAME} || {
            log_warn "Failed to start existing container. Removing and recreating..."
            docker rm ${CONTAINER_NAME}
            create_container
        }
    fi
else
    log_info "Creating new container..."
    create_container
fi

# Verify container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_info "Container ${CONTAINER_NAME} is running"
else
    log_error "Container failed to start"
    exit 1
fi

echo ""

# Step 3: Configure Apache
echo -e "${CYAN}Step 3: Configuring Apache reverse proxy...${NC}"
echo ""

# Create Apache conf.d directory if it doesn't exist
mkdir -p ${APACHE_CONF_DIR} 2>/dev/null || {
    log_warn "Cannot create ${APACHE_CONF_DIR} - may need sudo"
    APACHE_CONF_DIR="/tmp/apache2-conf.d"
    TARGET_CONF="${APACHE_CONF_DIR}/nexuscos-hollywood.conf"
    mkdir -p ${APACHE_CONF_DIR}
    log_info "Using alternative directory: ${APACHE_CONF_DIR}"
}

# Generate Apache configuration from template or inline
if [ -f "${TEMPLATE_FILE}" ]; then
    log_info "Using template file: ${TEMPLATE_FILE}"
    # Replace variables in template
    sed -e "s/\${SIGNAL_HOST}/${SIGNAL_HOST}/g" \
        -e "s/\${SIGNAL_PORT}/${SIGNAL_PORT}/g" \
        "${TEMPLATE_FILE}" > "${TARGET_CONF}"
else
    log_warn "Template file not found, generating configuration inline"
    cat > "${TARGET_CONF}" << EOF
# Nexus COS - Pixel Streaming Signalling Server Apache Configuration
# This configuration proxies requests to the pixel streaming signalling server
# running in a Docker container on port ${SIGNAL_PORT}

<IfModule mod_proxy.c>
  # Disable forward proxy to prevent open proxy vulnerabilities
  ProxyRequests Off
  
  # Allow proxy connections to the signalling server
  ProxyPreserveHost On
  
  # Configure proxy for /v-suite/hollywood endpoint
  <Location /v-suite/hollywood>
    ProxyPass http://${SIGNAL_HOST}:${SIGNAL_PORT}/
    ProxyPassReverse http://${SIGNAL_HOST}:${SIGNAL_PORT}/
    
    # Security headers
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
  </Location>
</IfModule>

<IfModule mod_rewrite.c>
  RewriteEngine On
  
  # WebSocket support for pixel streaming
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/v-suite/hollywood/(.*)$ ws://${SIGNAL_HOST}:${SIGNAL_PORT}/\$1 [P,L]
</IfModule>
EOF
fi

log_info "Apache configuration written to: ${TARGET_CONF}"
echo ""

# Display configuration
echo -e "${CYAN}Generated Apache Configuration:${NC}"
echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
cat "${TARGET_CONF}"
echo -e "${YELLOW}────────────────────────────────────────────────────────────────${NC}"
echo ""

# Step 4: Enable Apache modules
if [ "${APACHE_INSTALLED}" = true ]; then
    echo -e "${CYAN}Step 4: Enabling required Apache modules...${NC}"
    echo ""
    
    # Enable required modules (ignore errors if already enabled)
    for module in proxy proxy_http proxy_wstunnel rewrite headers; do
        if command_exists a2enmod; then
            a2enmod ${module} 2>/dev/null || log_info "Module ${module} already enabled or not available"
        else
            log_warn "a2enmod not available - please manually enable: ${module}"
        fi
    done
    echo ""
    
    # Step 5: Validate Apache configuration
    echo -e "${CYAN}Step 5: Validating Apache configuration...${NC}"
    echo ""
    
    if ${APACHE_CTL} -t 2>&1 | grep -i "syntax ok"; then
        log_info "Apache configuration syntax is OK"
    else
        log_error "Apache configuration has syntax errors:"
        ${APACHE_CTL} -t
        echo ""
        log_warn "Please fix the errors and reload Apache manually"
        exit 1
    fi
    echo ""
    
    # Step 6: Reload Apache
    echo -e "${CYAN}Step 6: Reloading Apache...${NC}"
    echo ""
    
    if systemctl reload ${APACHE_CMD} 2>/dev/null; then
        log_info "Apache reloaded via systemctl"
    elif ${APACHE_CTL} -k graceful 2>/dev/null; then
        log_info "Apache reloaded via ${APACHE_CTL}"
    elif service ${APACHE_CMD} reload 2>/dev/null; then
        log_info "Apache reloaded via service command"
    else
        log_warn "Could not reload Apache automatically. Please reload manually."
    fi
else
    log_warn "Apache is not installed. Configuration file created but not applied."
    log_info "To apply the configuration:"
    log_info "  1. Install Apache"
    log_info "  2. Copy ${TARGET_CONF} to /etc/apache2/conf.d/"
    log_info "  3. Enable modules: proxy, proxy_http, proxy_wstunnel, rewrite, headers"
    log_info "  4. Reload Apache"
fi

echo ""

# Step 7: Test endpoints
echo -e "${CYAN}Step 7: Testing endpoints...${NC}"
echo ""

sleep 2  # Give services a moment to fully start

test_urls=(
    "https://${DOMAIN}/v-suite/hollywood/"
    "https://${DOMAIN}/v-screen/vp/health"
    "https://${DOMAIN}/v-stage/vp/health"
    "http://${SIGNAL_HOST}:${SIGNAL_PORT}/"
)

for url in "${test_urls[@]}"; do
    code=$(curl -sk -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || echo "000")
    
    if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
        echo -e "${GREEN}✓${NC} $url -> ${GREEN}$code${NC}"
    elif [ "$code" = "000" ]; then
        echo -e "${YELLOW}⚠${NC} $url -> ${YELLOW}Connection failed${NC}"
    else
        echo -e "${RED}✗${NC} $url -> ${RED}$code${NC}"
    fi
done

echo ""

# Summary
echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Deployment Summary                                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓${NC} Container: ${CONTAINER_NAME}"
echo -e "${GREEN}✓${NC} Listening: ${SIGNAL_HOST}:${SIGNAL_PORT}"
echo -e "${GREEN}✓${NC} Domain: ${DOMAIN}"
echo -e "${GREEN}✓${NC} Configuration: ${TARGET_CONF}"
echo ""
echo -e "${CYAN}Access URLs:${NC}"
echo -e "  • https://${DOMAIN}/v-suite/hollywood/"
echo -e "  • http://${SIGNAL_HOST}:${SIGNAL_PORT}/ (local)"
echo ""
echo -e "${CYAN}Container Management:${NC}"
echo -e "  • View logs:    docker logs -f ${CONTAINER_NAME}"
echo -e "  • Stop:         docker stop ${CONTAINER_NAME}"
echo -e "  • Start:        docker start ${CONTAINER_NAME}"
echo -e "  • Remove:       docker rm -f ${CONTAINER_NAME}"
echo ""
log_info "Deployment complete!"

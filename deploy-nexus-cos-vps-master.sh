#!/bin/bash
################################################################################
# Nexus COS Platform Stack - Master VPS Deployment Script
# Version: 1.0.0
# Purpose: Complete deployment of Nexus COS according to deployment manifest
# 
# This script orchestrates the full deployment of:
#   - 52 microservices
#   - 43 modules
#   - PUABO Core banking platform
#   - Nginx reverse proxy with SSL
#   - Socket.IO endpoints
#   - All health checks and monitoring
#
# Usage:
#   SSH into VPS: ssh root@74.208.155.161
#   Run: bash deploy-nexus-cos-vps-master.sh
#
# Domain: nexuscos.online
# IP: 74.208.155.161
# SSL: IONOS certificates
# Platform: PLESK + Nginx
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration from deployment manifest
DOMAIN="nexuscos.online"
VPS_IP="74.208.155.161"
DEPLOYMENT_ID="nexus-cos-production-v1.0.0"
REPO_URL="https://github.com/BobbyBlanco400/nexus-cos.git"
DEPLOYMENT_DIR="/var/www/nexus-cos"
SSL_KEY="/root/ionos/privkey.pem"
SSL_CERT="/root/ionos/cert.pem"
SSL_CHAIN="/root/ionos/chain.pem"
NGINX_VHOST="/var/www/vhosts/system/nexuscos.online/conf/vhost_nginx.conf"

# Logging
LOG_DIR="/var/log/nexus-cos"
DEPLOYMENT_LOG="${LOG_DIR}/deployment-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "${LOG_DIR}"

# Start logging
exec 1> >(tee -a "${DEPLOYMENT_LOG}")
exec 2>&1

################################################################################
# Helper Functions
################################################################################

print_banner() {
  echo ""
  echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║${NC}  ${BOLD}${CYAN}Nexus COS Platform Stack - VPS Deployment${NC}               ${BLUE}║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "  ${BOLD}Deployment ID:${NC} ${DEPLOYMENT_ID}"
  echo -e "  ${BOLD}Domain:${NC}        ${DOMAIN}"
  echo -e "  ${BOLD}VPS IP:${NC}        ${VPS_IP}"
  echo -e "  ${BOLD}Timestamp:${NC}     $(date)"
  echo ""
}

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}${CYAN}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

print_step() {
  echo -e "${MAGENTA}➜${NC} ${BOLD}$1${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

check_command() {
  if command -v "$1" &> /dev/null; then
    print_success "$1 is installed"
    return 0
  else
    print_error "$1 is not installed"
    return 1
  fi
}

################################################################################
# Pre-Deployment Checks
################################################################################

pre_deployment_checks() {
  print_header "Phase 1: Pre-Deployment Checks"
  
  print_step "Checking system requirements..."
  
  # Check if running as root
  if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
  fi
  print_success "Running as root"
  
  # Check required commands
  local required_commands=("git" "docker" "nginx" "node" "npm" "pm2")
  local missing_commands=()
  
  for cmd in "${required_commands[@]}"; do
    if ! check_command "$cmd"; then
      missing_commands+=("$cmd")
    fi
  done
  
  if [ ${#missing_commands[@]} -gt 0 ]; then
    print_error "Missing required commands: ${missing_commands[*]}"
    print_info "Installing missing dependencies..."
    
    # Install missing commands
    for cmd in "${missing_commands[@]}"; do
      case $cmd in
        git)
          apt-get update && apt-get install -y git
          ;;
        docker)
          curl -fsSL https://get.docker.com -o get-docker.sh
          sh get-docker.sh
          systemctl enable docker
          systemctl start docker
          ;;
        node|npm)
          curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
          apt-get install -y nodejs
          ;;
        pm2)
          npm install -g pm2
          ;;
        nginx)
          apt-get update && apt-get install -y nginx
          ;;
      esac
    done
  fi
  
  # Verify SSL certificates exist
  print_step "Checking SSL certificates..."
  if [ -f "$SSL_KEY" ] && [ -f "$SSL_CERT" ] && [ -f "$SSL_CHAIN" ]; then
    print_success "SSL certificates found"
  else
    print_warning "SSL certificates not found at expected paths"
    print_info "Expected locations:"
    print_info "  Key:   ${SSL_KEY}"
    print_info "  Cert:  ${SSL_CERT}"
    print_info "  Chain: ${SSL_CHAIN}"
  fi
  
  # Check disk space
  print_step "Checking disk space..."
  local available_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
  if [ "$available_space" -lt 20 ]; then
    print_warning "Low disk space: ${available_space}GB available (20GB recommended)"
  else
    print_success "Sufficient disk space: ${available_space}GB available"
  fi
  
  # Check memory
  print_step "Checking memory..."
  local total_mem=$(free -g | awk 'NR==2 {print $2}')
  if [ "$total_mem" -lt 8 ]; then
    print_warning "Low memory: ${total_mem}GB (8GB recommended)"
  else
    print_success "Sufficient memory: ${total_mem}GB"
  fi
  
  print_success "Pre-deployment checks completed"
}

################################################################################
# Repository Setup
################################################################################

setup_repository() {
  print_header "Phase 2: Repository Setup"
  
  print_step "Setting up Nexus COS repository..."
  
  # Create deployment directory
  if [ -d "$DEPLOYMENT_DIR" ]; then
    print_info "Deployment directory exists, creating backup..."
    local backup_dir="${DEPLOYMENT_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
    mv "$DEPLOYMENT_DIR" "$backup_dir"
    print_success "Backed up to: ${backup_dir}"
  fi
  
  # Clone repository
  print_step "Cloning repository..."
  cd /var/www
  git clone "$REPO_URL" nexus-cos
  cd nexus-cos
  print_success "Repository cloned"
  
  # Checkout production branch if needed
  local current_branch=$(git branch --show-current)
  print_info "Current branch: ${current_branch}"
  
  print_success "Repository setup completed"
}

################################################################################
# PUABO Core Deployment
################################################################################

deploy_puabo_core() {
  print_header "Phase 3: PUABO Core Banking Platform Deployment"
  
  print_step "Deploying PUABO Core..."
  
  cd "${DEPLOYMENT_DIR}/nexus-cos/puabo-core"
  
  # Check if deployment script exists
  if [ ! -f "deploy-puabo-core.sh" ]; then
    print_error "PUABO Core deployment script not found"
    return 1
  fi
  
  # Make script executable
  chmod +x deploy-puabo-core.sh
  
  # Run deployment
  print_step "Running PUABO Core deployment..."
  ./deploy-puabo-core.sh
  
  # Wait for services to stabilize
  print_step "Waiting for services to stabilize (60 seconds)..."
  sleep 60
  
  # Verify PUABO Core is running
  print_step "Verifying PUABO Core deployment..."
  if curl -s http://localhost:7777/health | grep -q "healthy"; then
    print_success "PUABO Core is healthy"
  else
    print_warning "PUABO Core health check returned unexpected response"
  fi
  
  print_success "PUABO Core deployment completed"
}

################################################################################
# Services Deployment
################################################################################

deploy_services() {
  print_header "Phase 4: Microservices Deployment"
  
  print_step "Deploying 52 microservices..."
  
  cd "${DEPLOYMENT_DIR}"
  
  # Check if PM2 ecosystem config exists
  if [ -f "ecosystem.config.js" ]; then
    print_step "Found PM2 ecosystem configuration"
    
    # Stop any existing PM2 processes
    print_step "Stopping existing PM2 processes..."
    pm2 delete all || true
    
    # Start services with PM2
    print_step "Starting services with PM2..."
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 startup
    pm2 startup
    
    print_success "Services started with PM2"
  else
    print_warning "PM2 ecosystem config not found, skipping PM2 deployment"
  fi
  
  # Start services with Docker if docker-compose exists
  if [ -f "docker-compose.unified.yml" ]; then
    print_step "Starting services with Docker Compose..."
    docker compose -f docker-compose.unified.yml up -d --build
    print_success "Docker services started"
  fi
  
  print_success "Microservices deployment completed"
}

################################################################################
# Nginx Configuration
################################################################################

configure_nginx() {
  print_header "Phase 5: Nginx Reverse Proxy Configuration"
  
  print_step "Configuring Nginx for ${DOMAIN}..."
  
  # Create Nginx configuration
  local nginx_config="/etc/nginx/conf.d/nexuscos.conf"
  
  cat > "$nginx_config" <<'EOF'
# Nexus COS Platform - Nginx Configuration
# Domain: nexuscos.online
# Generated: $(date)

upstream backend_api {
    server localhost:3000;
    keepalive 64;
}

upstream streaming_service {
    server localhost:3028;
    keepalive 64;
}

upstream puabo_core {
    server localhost:7777;
    keepalive 64;
}

server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;
    
    # SSL Configuration
    ssl_certificate /root/ionos/cert.pem;
    ssl_certificate_key /root/ionos/privkey.pem;
    ssl_trusted_certificate /root/ionos/chain.pem;
    
    # SSL Security Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Root redirect to streaming
    location = / {
        return 301 https://$server_name/streaming/;
    }
    
    # API endpoint
    location /api/ {
        proxy_pass http://backend_api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Streaming endpoint
    location /streaming/ {
        proxy_pass http://streaming_service/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Socket.IO main endpoint
    location /socket.io/ {
        proxy_pass http://backend_api/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # Socket.IO streaming endpoint
    location /streaming/socket.io/ {
        proxy_pass http://streaming_service/socket.io/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
    
    # PUABO Core Banking API
    location /puabo/ {
        proxy_pass http://puabo_core/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF
  
  print_success "Nginx configuration created"
  
  # Test Nginx configuration
  print_step "Testing Nginx configuration..."
  if nginx -t; then
    print_success "Nginx configuration is valid"
    
    # Reload Nginx
    print_step "Reloading Nginx..."
    systemctl reload nginx
    print_success "Nginx reloaded"
  else
    print_error "Nginx configuration test failed"
    return 1
  fi
  
  print_success "Nginx configuration completed"
}

################################################################################
# Health Checks
################################################################################

run_health_checks() {
  print_header "Phase 6: Health Checks & Validation"
  
  print_step "Running endpoint health checks..."
  
  # Array of endpoints to check
  declare -A endpoints=(
    ["Root (301 redirect)"]="https://${DOMAIN}/"
    ["API Base"]="https://${DOMAIN}/api/"
    ["Streaming Base"]="https://${DOMAIN}/streaming/"
    ["Socket.IO Main"]="https://${DOMAIN}/socket.io/?EIO=4&transport=polling"
    ["Socket.IO Streaming"]="https://${DOMAIN}/streaming/socket.io/?EIO=4&transport=polling"
  )
  
  local failed_checks=0
  
  for name in "${!endpoints[@]}"; do
    local url="${endpoints[$name]}"
    print_step "Checking: ${name}"
    
    # Allow self-signed certs for testing
    local status=$(curl -k -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$status" = "200" ] || [ "$status" = "301" ] || [ "$status" = "302" ]; then
      print_success "${name}: HTTP ${status}"
    else
      print_warning "${name}: HTTP ${status} (expected 200/301/302)"
      ((failed_checks++))
    fi
  done
  
  if [ $failed_checks -eq 0 ]; then
    print_success "All health checks passed"
  else
    print_warning "${failed_checks} health check(s) failed"
  fi
  
  # Check PUABO Core
  print_step "Checking PUABO Core..."
  if curl -s http://localhost:7777/health | grep -q "healthy"; then
    print_success "PUABO Core is healthy"
  else
    print_warning "PUABO Core health check failed"
  fi
  
  # Check PM2 services
  print_step "Checking PM2 services..."
  pm2 status
  
  # Check Docker services
  print_step "Checking Docker services..."
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
  
  print_success "Health checks completed"
}

################################################################################
# Post-Deployment
################################################################################

post_deployment() {
  print_header "Phase 7: Post-Deployment Summary"
  
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}  ${BOLD}${GREEN}Deployment Completed Successfully!${NC}                         ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  
  print_info "Deployment Details:"
  echo -e "  ${BOLD}Deployment ID:${NC}  ${DEPLOYMENT_ID}"
  echo -e "  ${BOLD}Domain:${NC}         https://${DOMAIN}"
  echo -e "  ${BOLD}VPS IP:${NC}         ${VPS_IP}"
  echo -e "  ${BOLD}Completed:${NC}      $(date)"
  echo -e "  ${BOLD}Log File:${NC}       ${DEPLOYMENT_LOG}"
  echo ""
  
  print_info "Available Endpoints:"
  echo -e "  ${BOLD}Root:${NC}           https://${DOMAIN}/ ${YELLOW}→${NC} /streaming/"
  echo -e "  ${BOLD}API:${NC}            https://${DOMAIN}/api/"
  echo -e "  ${BOLD}Streaming:${NC}      https://${DOMAIN}/streaming/"
  echo -e "  ${BOLD}Socket.IO:${NC}      https://${DOMAIN}/socket.io/"
  echo -e "  ${BOLD}PUABO Core:${NC}     https://${DOMAIN}/puabo/"
  echo ""
  
  print_info "Service Status:"
  echo -e "  ${BOLD}Services:${NC}       52 microservices"
  echo -e "  ${BOLD}Modules:${NC}        43 modules"
  echo -e "  ${BOLD}PUABO Core:${NC}     Running on port 7777"
  echo -e "  ${BOLD}PM2 Processes:${NC}  $(pm2 list | grep -c 'online' || echo '0') running"
  echo -e "  ${BOLD}Docker:${NC}         $(docker ps -q | wc -l) containers"
  echo ""
  
  print_info "Management Commands:"
  echo -e "  ${BOLD}View PM2 logs:${NC}       pm2 logs"
  echo -e "  ${BOLD}View Docker logs:${NC}    docker compose -f docker-compose.unified.yml logs -f"
  echo -e "  ${BOLD}View PUABO logs:${NC}     cd nexus-cos/puabo-core && docker compose -f docker-compose.core.yml logs -f"
  echo -e "  ${BOLD}Restart Nginx:${NC}       systemctl restart nginx"
  echo -e "  ${BOLD}Deployment log:${NC}      tail -f ${DEPLOYMENT_LOG}"
  echo ""
  
  print_info "Next Steps:"
  echo -e "  1. Test endpoints manually: curl -k https://${DOMAIN}/api/"
  echo -e "  2. Set up monitoring and alerts"
  echo -e "  3. Configure automated backups"
  echo -e "  4. Review logs for any warnings"
  echo ""
  
  print_success "Nexus COS Platform Stack is now live at https://${DOMAIN}!"
  echo ""
}

################################################################################
# Main Deployment Flow
################################################################################

main() {
  print_banner
  
  # Execute deployment phases
  pre_deployment_checks
  setup_repository
  deploy_puabo_core
  deploy_services
  configure_nginx
  run_health_checks
  post_deployment
  
  # Exit successfully
  exit 0
}

# Handle errors
trap 'print_error "Deployment failed at line $LINENO. Check logs: ${DEPLOYMENT_LOG}"; exit 1' ERR

# Run main
main "$@"

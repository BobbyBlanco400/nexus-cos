#!/bin/bash
###############################################################################
# Nexus COS Production Deployment Script with Forced PM2 Adherence
# Version: 1.0.0
# Purpose: Bulletproof PM2 deployment ensuring clean environment
#
# This script implements forced adherence to the Production Framework (PF)
# by ensuring:
#   1. Complete PM2 cache cleanup (kill + dump removal)
#   2. Fresh environment loading from ecosystem.config.js
#   3. Explicit DB configuration (localhost by default)
#   4. Health verification after deployment
#   5. Automated rollback on failure
#
# Usage:
#   ./nexus-cos-production-deploy.sh [options]
#
# Options:
#   --no-pull         Skip git pull (use current code)
#   --db-config=TYPE  Database configuration (localhost|docker|remote)
#   --skip-verify     Skip health check verification
#   --force           Force deployment even if health check fails
#
###############################################################################

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

# Default options
PULL_CODE=true
DB_CONFIG="localhost"
SKIP_VERIFY=false
FORCE_DEPLOY=false
BACKUP_DIR="/tmp/nexus-cos-backup-$(date +%Y%m%d-%H%M%S)"

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --no-pull)
      PULL_CODE=false
      shift
      ;;
    --db-config=*)
      DB_CONFIG="${arg#*=}"
      shift
      ;;
    --skip-verify)
      SKIP_VERIFY=true
      shift
      ;;
    --force)
      FORCE_DEPLOY=true
      shift
      ;;
    --help)
      head -n 25 "$0" | tail -n +2
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $arg${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

###############################################################################
# Helper Functions
###############################################################################

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

check_prerequisites() {
  print_step "Checking prerequisites..."
  
  local missing_deps=()
  
  if ! command -v node &> /dev/null; then
    missing_deps+=("node")
  fi
  
  if ! command -v pm2 &> /dev/null; then
    missing_deps+=("pm2")
  fi
  
  if ! command -v git &> /dev/null; then
    missing_deps+=("git")
  fi
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    print_error "Missing required dependencies: ${missing_deps[*]}"
    echo ""
    echo "Please install missing dependencies:"
    echo "  npm install -g pm2"
    echo "  # Install Node.js from: https://nodejs.org/"
    echo "  # Install Git from: https://git-scm.com/"
    exit 1
  fi
  
  print_success "All prerequisites met"
}

backup_current_state() {
  print_step "Backing up current PM2 state..."
  
  mkdir -p "$BACKUP_DIR"
  
  # Save PM2 dump
  if pm2 list 2>/dev/null | grep -q "online"; then
    pm2 save --force
    if [ -f ~/.pm2/dump.pm2 ]; then
      cp ~/.pm2/dump.pm2 "$BACKUP_DIR/dump.pm2.backup"
      print_success "PM2 state backed up to $BACKUP_DIR"
    fi
  else
    print_info "No running PM2 processes to backup"
  fi
  
  # Backup ecosystem config
  if [ -f ecosystem.config.js ]; then
    cp ecosystem.config.js "$BACKUP_DIR/ecosystem.config.js.backup"
    print_success "Ecosystem config backed up"
  fi
}

force_pm2_cleanup() {
  print_step "Forcing complete PM2 cache cleanup..."
  
  # Step 1: Delete all processes
  print_info "Deleting all PM2 processes..."
  pm2 delete all 2>/dev/null || print_warning "No processes to delete"
  sleep 2
  
  # Step 2: Kill PM2 daemon
  print_info "Killing PM2 daemon..."
  pm2 kill 2>/dev/null || true
  sleep 2
  
  # Step 3: Remove PM2 dump file (cached state)
  print_info "Removing PM2 dump file (cached environment)..."
  if [ -f ~/.pm2/dump.pm2 ]; then
    rm -f ~/.pm2/dump.pm2
    print_success "Removed PM2 dump file"
  else
    print_info "No PM2 dump file found"
  fi
  
  # Step 4: Clear PM2 logs
  print_info "Clearing PM2 logs..."
  pm2 flush 2>/dev/null || true
  
  print_success "PM2 cache completely cleared"
}

pull_latest_code() {
  if [ "$PULL_CODE" = true ]; then
    print_step "Pulling latest code from repository..."
    
    if git pull origin main; then
      print_success "Code updated successfully"
    else
      print_warning "Git pull failed or already up to date"
    fi
  else
    print_info "Skipping code pull (--no-pull specified)"
  fi
}

configure_database() {
  print_step "Configuring database connection..."
  
  case "$DB_CONFIG" in
    "localhost")
      print_info "Using localhost PostgreSQL configuration"
      print_success "DB_HOST: localhost"
      print_success "DB_NAME: nexuscos_db"
      print_success "DB_USER: nexuscos"
      ;;
    "docker")
      print_info "Configuring for Docker PostgreSQL..."
      # Update ecosystem.config.js for Docker
      sed -i.bak "s/DB_HOST: 'localhost'/DB_HOST: 'nexus-cos-postgres'/g" ecosystem.config.js
      sed -i "s/DB_NAME: 'nexuscos_db'/DB_NAME: 'nexus_db'/g" ecosystem.config.js
      sed -i "s/DB_USER: 'nexuscos'/DB_USER: 'nexus_user'/g" ecosystem.config.js
      print_success "Configured for Docker (nexus-cos-postgres container)"
      ;;
    "remote")
      print_info "Configuring for remote database..."
      read -p "DB_HOST: " DB_HOST_VALUE
      read -p "DB_NAME: " DB_NAME_VALUE
      read -p "DB_USER: " DB_USER_VALUE
      read -sp "DB_PASSWORD: " DB_PASSWORD_VALUE
      echo ""
      sed -i.bak "s/DB_HOST: 'localhost'/DB_HOST: '$DB_HOST_VALUE'/g" ecosystem.config.js
      sed -i "s/DB_NAME: 'nexuscos_db'/DB_NAME: '$DB_NAME_VALUE'/g" ecosystem.config.js
      sed -i "s/DB_USER: 'nexuscos'/DB_USER: '$DB_USER_VALUE'/g" ecosystem.config.js
      sed -i "s/DB_PASSWORD: 'password'/DB_PASSWORD: '$DB_PASSWORD_VALUE'/g" ecosystem.config.js
      print_success "Configured for remote database"
      ;;
    *)
      print_error "Invalid database configuration: $DB_CONFIG"
      echo "Valid options: localhost, docker, remote"
      exit 1
      ;;
  esac
}

validate_ecosystem_config() {
  print_step "Validating ecosystem configuration..."
  
  if [ ! -f ecosystem.config.js ]; then
    print_error "ecosystem.config.js not found!"
    exit 1
  fi
  
  # Check syntax
  if ! node -c ecosystem.config.js 2>/dev/null; then
    print_error "ecosystem.config.js has syntax errors!"
    exit 1
  fi
  print_success "Configuration syntax valid"
  
  # Count services
  local service_count=$(node -e "console.log(require('./ecosystem.config.js').apps.length)" 2>/dev/null)
  print_success "Found $service_count services configured"
  
  # Verify no hardcoded paths
  local cwd_count=$(grep -c "cwd:" ecosystem.config.js || echo "0")
  if [ "$cwd_count" -eq "0" ]; then
    print_success "No hardcoded paths found"
  else
    print_warning "Found $cwd_count hardcoded 'cwd' paths (may need review)"
  fi
  
  # Verify DB_HOST setting
  local db_host=$(node -e "console.log(require('./ecosystem.config.js').apps[0].env.DB_HOST)" 2>/dev/null)
  print_info "First service DB_HOST: $db_host"
}

start_pm2_services() {
  print_step "Starting PM2 services from ecosystem.config.js..."
  
  if pm2 start ecosystem.config.js --env production; then
    print_success "Services started successfully"
  else
    print_error "Failed to start services!"
    print_info "Attempting to show PM2 error logs..."
    pm2 logs --lines 50 --nostream
    exit 1
  fi
  
  # Save PM2 configuration
  print_info "Saving PM2 configuration..."
  pm2 save
  print_success "PM2 configuration saved"
}

wait_for_services() {
  print_step "Waiting for services to initialize..."
  
  local wait_time=15
  for i in $(seq $wait_time -1 1); do
    echo -ne "\r${CYAN}⏳${NC} Waiting... ${i}s remaining  "
    sleep 1
  done
  echo -e "\r${GREEN}✓${NC} Services initialized                    "
}

verify_deployment() {
  if [ "$SKIP_VERIFY" = true ]; then
    print_info "Skipping health verification (--skip-verify specified)"
    return 0
  fi
  
  print_step "Verifying deployment..."
  
  # Check PM2 status
  print_info "PM2 Process Status:"
  pm2 list
  echo ""
  
  # Count running services
  local online_count=$(pm2 jlist | grep -o '"status":"online"' | wc -l)
  local total_count=$(pm2 jlist | grep -o '"name":"' | wc -l)
  
  print_info "Services online: $online_count / $total_count"
  
  if [ "$online_count" -lt "$total_count" ]; then
    print_warning "Not all services are online!"
    if [ "$FORCE_DEPLOY" = false ]; then
      print_error "Deployment verification failed"
      echo ""
      echo "Run with --force to proceed anyway, or check PM2 logs:"
      echo "  pm2 logs"
      return 1
    else
      print_warning "Continuing with --force option"
    fi
  else
    print_success "All services are online"
  fi
  
  # Try health endpoint if available
  if command -v curl &> /dev/null; then
    print_info "Checking health endpoint..."
    
    local health_url="https://nexuscos.online/health"
    if curl -s --connect-timeout 5 "$health_url" > /dev/null 2>&1; then
      local health_response=$(curl -s --max-time 10 "$health_url")
      
      if command -v jq &> /dev/null; then
        echo "$health_response" | jq . 2>/dev/null || echo "$health_response"
        
        local db_status=$(echo "$health_response" | jq -r '.db' 2>/dev/null || echo "unknown")
        if [ "$db_status" = "up" ]; then
          print_success "Database connection verified!"
        else
          print_warning "Database status: $db_status"
          if [ "$FORCE_DEPLOY" = false ]; then
            return 1
          fi
        fi
      else
        echo "$health_response"
        print_info "Install jq for better output: apt-get install jq"
      fi
    else
      print_warning "Could not reach health endpoint at $health_url"
      print_info "This may be normal if the domain is not yet accessible"
    fi
  fi
  
  return 0
}

show_deployment_summary() {
  print_header "🎉 DEPLOYMENT COMPLETE"
  
  echo -e "${GREEN}${BOLD}Nexus COS is now running!${NC}"
  echo ""
  echo "Useful commands:"
  echo -e "  ${CYAN}pm2 list${NC}          - View all services"
  echo -e "  ${CYAN}pm2 logs${NC}          - View service logs"
  echo -e "  ${CYAN}pm2 restart all${NC}   - Restart all services"
  echo -e "  ${CYAN}pm2 stop all${NC}      - Stop all services"
  echo -e "  ${CYAN}pm2 monit${NC}         - Monitor services in real-time"
  echo ""
  echo "Health check:"
  echo -e "  ${CYAN}curl -s https://nexuscos.online/health | jq${NC}"
  echo ""
  echo "Backup location:"
  echo -e "  ${CYAN}$BACKUP_DIR${NC}"
  echo ""
  
  if [ "$DB_CONFIG" = "localhost" ]; then
    echo -e "${YELLOW}Note:${NC} Make sure PostgreSQL is running:"
    echo "  sudo systemctl status postgresql"
    echo "  sudo systemctl start postgresql"
    echo ""
  fi
}

rollback_on_failure() {
  print_header "⚠️  DEPLOYMENT FAILED - ROLLING BACK"
  
  print_step "Attempting to restore previous state..."
  
  # Restore ecosystem config if backup exists
  if [ -f "$BACKUP_DIR/ecosystem.config.js.backup" ]; then
    cp "$BACKUP_DIR/ecosystem.config.js.backup" ecosystem.config.js
    print_success "Restored ecosystem config"
  fi
  
  # Restore PM2 dump if backup exists
  if [ -f "$BACKUP_DIR/dump.pm2.backup" ]; then
    cp "$BACKUP_DIR/dump.pm2.backup" ~/.pm2/dump.pm2
    pm2 resurrect
    print_success "Restored PM2 state"
  fi
  
  print_error "Deployment failed and rollback attempted"
  print_info "Check logs with: pm2 logs"
  exit 1
}

###############################################################################
# Main Deployment Flow
###############################################################################

main() {
  print_header "🚀 Nexus COS Production Deployment"
  
  echo -e "${BOLD}Configuration:${NC}"
  echo "  Pull code: $PULL_CODE"
  echo "  DB config: $DB_CONFIG"
  echo "  Skip verify: $SKIP_VERIFY"
  echo "  Force deploy: $FORCE_DEPLOY"
  echo ""
  
  # Step 1: Prerequisites
  check_prerequisites
  
  # Step 2: Backup
  backup_current_state
  
  # Step 3: Force PM2 cleanup (CRITICAL for fixing cached environment)
  force_pm2_cleanup
  
  # Step 4: Pull latest code
  pull_latest_code
  
  # Step 5: Configure database
  configure_database
  
  # Step 6: Validate configuration
  validate_ecosystem_config
  
  # Step 7: Start services
  start_pm2_services
  
  # Step 8: Wait for initialization
  wait_for_services
  
  # Step 9: Verify deployment
  if ! verify_deployment; then
    if [ "$FORCE_DEPLOY" = false ]; then
      rollback_on_failure
    fi
  fi
  
  # Step 10: Show summary
  show_deployment_summary
}

# Trap errors and attempt rollback
trap 'rollback_on_failure' ERR

# Run main deployment
main "$@"

exit 0

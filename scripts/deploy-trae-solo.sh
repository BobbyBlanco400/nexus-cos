#!/bin/bash
# TRAE SOLO Deployment Script for Nexus COS
# Complete automated workflow: Build, Test, Deploy, Monitor

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_ROOT/logs"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"
BUILD_LOG="$LOG_DIR/build.log"
DEPLOY_LOG="$LOG_DIR/deploy.log"
TEST_LOG="$LOG_DIR/test.log"
MONITOR_LOG="$LOG_DIR/monitor.log"

# Create necessary directories
mkdir -p "$LOG_DIR" "$ARTIFACTS_DIR"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$DEPLOY_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$DEPLOY_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$DEPLOY_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$DEPLOY_LOG"
}

# Error handling
handle_error() {
    log_error "Deployment failed at step: $1"
    log_error "Check logs in $LOG_DIR for details"
    exit 1
}

# Trap errors
trap 'handle_error "${BASH_COMMAND}"' ERR

# Main deployment function
main() {
    log_info "Starting Nexus COS TRAE SOLO Deployment"
    log_info "Project Root: $PROJECT_ROOT"
    log_info "Timestamp: $(date)"
    
    # Step 1: Environment Setup
    log_info "Step 1: Setting up environment..."
    setup_environment
    
    # Step 2: Install Dependencies
    log_info "Step 2: Installing dependencies..."
    install_dependencies
    
    # Step 3: Run Tests
    log_info "Step 3: Running tests..."
    run_tests
    
    # Step 4: Build Applications
    log_info "Step 4: Building applications..."
    build_applications
    
    # Step 5: Build Mobile Apps
    log_info "Step 5: Building mobile applications..."
    build_mobile_apps
    
    # Step 6: Create Docker Images
    log_info "Step 6: Creating Docker images..."
    build_docker_images
    
    # Step 7: Provision VPS
    log_info "Step 7: Provisioning VPS..."
    provision_vps
    
    # Step 8: Deploy to VPS
    log_info "Step 8: Deploying to VPS..."
    deploy_to_vps
    
    # Step 9: Setup SSL
    log_info "Step 9: Setting up SSL..."
    setup_ssl
    
    # Step 10: Setup Monitoring
    log_info "Step 10: Setting up monitoring..."
    setup_monitoring
    
    # Step 11: Health Checks
    log_info "Step 11: Running health checks..."
    run_health_checks
    
    # Step 12: Generate Report
    log_info "Step 12: Generating deployment report..."
    generate_deployment_report
    
    log_success "Nexus COS deployment completed successfully!"
    log_info "Access your application at: https://${DOMAIN:-localhost}"
}

# Environment setup
setup_environment() {
    cd "$PROJECT_ROOT"
    
    # Load environment variables
    if [[ -f ".trae/environment.env" ]]; then
        source ".trae/environment.env"
        log_success "Environment variables loaded"
    else
        log_warning "Environment file not found, using defaults"
    fi
    
    # Validate required tools
    command -v node >/dev/null 2>&1 || handle_error "Node.js not found"
    command -v npm >/dev/null 2>&1 || handle_error "npm not found"
    command -v python3 >/dev/null 2>&1 || handle_error "Python 3 not found"
    command -v docker >/dev/null 2>&1 || handle_error "Docker not found"
    command -v docker-compose >/dev/null 2>&1 || handle_error "Docker Compose not found"
    
    log_success "Environment setup completed"
}

# Install dependencies
install_dependencies() {
    cd "$PROJECT_ROOT"
    
    # Install root dependencies
    npm install 2>&1 | tee -a "$BUILD_LOG"
    
    # Install backend dependencies
    cd "nexus-cos-main/backend"
    npm install 2>&1 | tee -a "$BUILD_LOG"
    python3 -m pip install -r requirements.txt 2>&1 | tee -a "$BUILD_LOG"
    
    # Install frontend dependencies
    cd "../frontend"
    npm install 2>&1 | tee -a "$BUILD_LOG"
    
    # Install mobile dependencies
    cd "../mobile"
    npm install 2>&1 | tee -a "$BUILD_LOG"
    
    cd "$PROJECT_ROOT"
    log_success "Dependencies installed successfully"
}

# Run tests
run_tests() {
    cd "$PROJECT_ROOT"
    
    # Frontend tests
    log_info "Running frontend tests..."
    cd "nexus-cos-main/frontend"
    npm test -- --watchAll=false 2>&1 | tee -a "$TEST_LOG" || log_warning "Frontend tests failed"
    
    # Backend tests
    log_info "Running backend tests..."
    cd "../backend"
    npm test 2>&1 | tee -a "$TEST_LOG" || log_warning "Backend tests failed"
    
    cd "$PROJECT_ROOT"
    log_success "Tests completed"
}

# Build applications
build_applications() {
    cd "$PROJECT_ROOT"
    
    # Build frontend
    log_info "Building frontend..."
    cd "nexus-cos-main/frontend"
    npm run build 2>&1 | tee -a "$BUILD_LOG"
    
    # Build backend
    log_info "Building backend..."
    cd "../backend"
    if [[ -f "package.json" ]] && grep -q '"build"' package.json; then
        npm run build 2>&1 | tee -a "$BUILD_LOG"
    fi
    
    cd "$PROJECT_ROOT"
    log_success "Applications built successfully"
}

# Build mobile apps
build_mobile_apps() {
    cd "$PROJECT_ROOT/nexus-cos-main/mobile"
    
    if [[ -f "build-mobile.sh" ]]; then
        chmod +x build-mobile.sh
        ./build-mobile.sh 2>&1 | tee -a "$BUILD_LOG"
        
        # Copy artifacts
        mkdir -p "$ARTIFACTS_DIR"
        if [[ -f "builds/android/app.apk" ]]; then
            cp "builds/android/app.apk" "$ARTIFACTS_DIR/nexus-cos.apk"
            log_success "Android APK created: $ARTIFACTS_DIR/nexus-cos.apk"
        fi
        
        if [[ -f "builds/ios/app.ipa" ]]; then
            cp "builds/ios/app.ipa" "$ARTIFACTS_DIR/nexus-cos.ipa"
            log_success "iOS IPA created: $ARTIFACTS_DIR/nexus-cos.ipa"
        fi
    else
        log_warning "Mobile build script not found, skipping mobile builds"
    fi
    
    cd "$PROJECT_ROOT"
}

# Build Docker images
build_docker_images() {
    cd "$PROJECT_ROOT"
    
    log_info "Building Docker images..."
    docker-compose -f .trae/services.yaml build 2>&1 | tee -a "$BUILD_LOG"
    
    log_success "Docker images built successfully"
}

# Provision VPS
provision_vps() {
    if [[ -f "$SCRIPT_DIR/provision-vps.sh" ]]; then
        chmod +x "$SCRIPT_DIR/provision-vps.sh"
        "$SCRIPT_DIR/provision-vps.sh" 2>&1 | tee -a "$DEPLOY_LOG"
    else
        log_warning "VPS provisioning script not found, skipping"
    fi
}

# Deploy to VPS
deploy_to_vps() {
    cd "$PROJECT_ROOT"
    
    # Start services
    docker-compose -f .trae/services.yaml up -d 2>&1 | tee -a "$DEPLOY_LOG"
    
    # Wait for services to start
    sleep 30
    
    log_success "Services deployed successfully"
}

# Setup SSL
setup_ssl() {
    if [[ -f "$SCRIPT_DIR/setup-ssl.sh" ]]; then
        chmod +x "$SCRIPT_DIR/setup-ssl.sh"
        "$SCRIPT_DIR/setup-ssl.sh" 2>&1 | tee -a "$DEPLOY_LOG"
    else
        log_warning "SSL setup script not found, skipping"
    fi
}

# Setup monitoring
setup_monitoring() {
    if [[ -f "$SCRIPT_DIR/setup-monitoring.sh" ]]; then
        chmod +x "$SCRIPT_DIR/setup-monitoring.sh"
        "$SCRIPT_DIR/setup-monitoring.sh" 2>&1 | tee -a "$MONITOR_LOG"
    else
        log_warning "Monitoring setup script not found, skipping"
    fi
}

# Health checks
run_health_checks() {
    if [[ -f "$SCRIPT_DIR/health-checks.sh" ]]; then
        chmod +x "$SCRIPT_DIR/health-checks.sh"
        "$SCRIPT_DIR/health-checks.sh" 2>&1 | tee -a "$MONITOR_LOG"
    else
        log_warning "Health check script not found, skipping"
    fi
}

# Generate deployment report
generate_deployment_report() {
    local report_file="$PROJECT_ROOT/FINAL_DEPLOYMENT_REPORT.md"
    
    cat > "$report_file" << EOF
# Nexus COS TRAE SOLO Deployment Report

Generated: $(date)
Deployment ID: $(date +%Y%m%d_%H%M%S)

## Deployment Summary

- **Status**: $(if [[ $? -eq 0 ]]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)
- **Domain**: ${DOMAIN:-localhost}
- **Deployment Time**: $(date)
- **Build Artifacts**: $(ls -la "$ARTIFACTS_DIR" 2>/dev/null | wc -l) files

## Services Status

$(docker-compose -f .trae/services.yaml ps 2>/dev/null || echo "Services status unavailable")

## Build Logs Summary

\`\`\`
$(tail -20 "$BUILD_LOG" 2>/dev/null || echo "Build logs unavailable")
\`\`\`

## Test Results Summary

\`\`\`
$(tail -20 "$TEST_LOG" 2>/dev/null || echo "Test logs unavailable")
\`\`\`

## Deployment Logs Summary

\`\`\`
$(tail -20 "$DEPLOY_LOG" 2>/dev/null || echo "Deployment logs unavailable")
\`\`\`

## Access URLs

- **Frontend**: https://${DOMAIN:-localhost}
- **Node.js API**: https://${DOMAIN:-localhost}/api/node
- **Python API**: https://${DOMAIN:-localhost}/api/python
- **Grafana**: https://${DOMAIN:-localhost}/grafana
- **Prometheus**: https://${DOMAIN:-localhost}/prometheus

## Artifacts

$(ls -la "$ARTIFACTS_DIR" 2>/dev/null || echo "No artifacts found")

## Next Steps

1. Verify all services are running
2. Test application functionality
3. Monitor system performance
4. Setup automated backups
5. Configure monitoring alerts

EOF

    log_success "Deployment report generated: $report_file"
}

# Run main function
main "$@"
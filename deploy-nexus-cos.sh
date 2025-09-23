#!/bin/bash

# Nexus COS Extended - Master Deployment Script
# Complete system deployment orchestration for production environment

set -euo pipefail

# Script metadata
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="Nexus COS Extended Master Deployment"
DEPLOYMENT_ID="nexus-$(date +%Y%m%d_%H%M%S)"

# Project configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$PROJECT_DIR/scripts"
LOGS_DIR="$PROJECT_DIR/logs"
BACKUP_DIR="$PROJECT_DIR/backups"
CONFIG_DIR="$PROJECT_DIR/config"

# Deployment configuration
DOMAIN="${DOMAIN:-nexuscos.online}"
ENVIRONMENT="${ENVIRONMENT:-production}"
DEPLOY_MODE="${DEPLOY_MODE:-full}"
SKIP_BACKUP="${SKIP_BACKUP:-false}"
SKIP_TESTS="${SKIP_TESTS:-false}"
SKIP_MOBILE="${SKIP_MOBILE:-false}"
PARALLEL_BUILDS="${PARALLEL_BUILDS:-true}"

# Service configuration
ENABLE_MONITORING="${ENABLE_MONITORING:-true}"
ENABLE_SSL="${ENABLE_SSL:-true}"
ENABLE_BACKUPS="${ENABLE_BACKUPS:-true}"
ENABLE_LOGGING="${ENABLE_LOGGING:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_deploy() {
    echo -e "${CYAN}[DEPLOY]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

log_header() {
    echo -e "${WHITE}[HEADER]${NC} $1" | tee -a "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
}

# Print deployment banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              NEXUS COS EXTENDED                             ║"
    echo "║                          Master Deployment Script                           ║"
    echo "║                                                                              ║"
    echo "║  🚀 Complete Production Deployment Orchestration                            ║"
    echo "║  🌐 Multi-Service Architecture with V-Suite Integration                     ║"
    echo "║  📱 Mobile & Web Applications                                               ║"
    echo "║  🔒 SSL/TLS Security & Monitoring                                          ║"
    echo "║                                                                              ║"
    echo "║  Version: $SCRIPT_VERSION                                                        ║"
    echo "║  Deployment ID: $DEPLOYMENT_ID                                    ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Print deployment summary
print_deployment_summary() {
    log_header "DEPLOYMENT CONFIGURATION SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Domain:              $DOMAIN"
    echo "Environment:         $ENVIRONMENT"
    echo "Deploy Mode:         $DEPLOY_MODE"
    echo "Deployment ID:       $DEPLOYMENT_ID"
    echo "Project Directory:   $PROJECT_DIR"
    echo ""
    echo "Features:"
    echo "  SSL/TLS:           $([ "$ENABLE_SSL" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo "  Monitoring:        $([ "$ENABLE_MONITORING" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo "  Backups:           $([ "$ENABLE_BACKUPS" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo "  Logging:           $([ "$ENABLE_LOGGING" = "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo ""
    echo "Options:"
    echo "  Skip Backup:       $([ "$SKIP_BACKUP" = "true" ] && echo "⚠️  Yes" || echo "✅ No")"
    echo "  Skip Tests:        $([ "$SKIP_TESTS" = "true" ] && echo "⚠️  Yes" || echo "✅ No")"
    echo "  Skip Mobile:       $([ "$SKIP_MOBILE" = "true" ] && echo "⚠️  Yes" || echo "✅ No")"
    echo "  Parallel Builds:   $([ "$PARALLEL_BUILDS" = "true" ] && echo "✅ Yes" || echo "❌ No")"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check system requirements
check_system_requirements() {
    log_step "Checking system requirements..."
    
    local requirements_met=true
    
    # Check operating system
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        log_warning "This script is optimized for Linux. Current OS: $OSTYPE"
    fi
    
    # Check if running as root for system-level operations
    if [[ $EUID -eq 0 ]]; then
        log_info "Running as root - system-level operations available"
    else
        log_warning "Not running as root - some system operations may require sudo"
    fi
    
    # Check required commands
    local required_commands=("docker" "docker-compose" "git" "curl" "jq" "openssl")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            requirements_met=false
        else
            log_info "✓ $cmd found"
        fi
    done
    
    # Check Docker daemon
    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        requirements_met=false
    else
        log_info "✓ Docker daemon is running"
    fi
    
    # Check available disk space (minimum 10GB)
    local available_space=$(df "$PROJECT_DIR" | awk 'NR==2 {print $4}')
    local min_space=10485760  # 10GB in KB
    if [[ $available_space -lt $min_space ]]; then
        log_warning "Low disk space: $(($available_space / 1024 / 1024))GB available"
    else
        log_info "✓ Sufficient disk space available"
    fi
    
    # Check memory (minimum 4GB)
    local total_memory=$(free -m | awk 'NR==2{print $2}')
    if [[ $total_memory -lt 4096 ]]; then
        log_warning "Low memory: ${total_memory}MB available (recommended: 4GB+)"
    else
        log_info "✓ Sufficient memory available"
    fi
    
    if [[ "$requirements_met" != "true" ]]; then
        log_error "System requirements not met. Please install missing dependencies."
        exit 1
    fi
    
    log_success "System requirements check completed"
}

# Setup deployment environment
setup_deployment_environment() {
    log_step "Setting up deployment environment..."
    
    # Create necessary directories
    mkdir -p "$LOGS_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$PROJECT_DIR/builds"
    mkdir -p "$PROJECT_DIR/certificates"
    
    # Set proper permissions
    chmod 755 "$LOGS_DIR" "$BACKUP_DIR" "$CONFIG_DIR"
    
    # Create deployment configuration file
    cat > "$CONFIG_DIR/deployment-$DEPLOYMENT_ID.conf" << EOF
# Nexus COS Extended Deployment Configuration
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

DEPLOYMENT_ID="$DEPLOYMENT_ID"
DOMAIN="$DOMAIN"
ENVIRONMENT="$ENVIRONMENT"
DEPLOY_MODE="$DEPLOY_MODE"
PROJECT_DIR="$PROJECT_DIR"

# Feature flags
ENABLE_MONITORING="$ENABLE_MONITORING"
ENABLE_SSL="$ENABLE_SSL"
ENABLE_BACKUPS="$ENABLE_BACKUPS"
ENABLE_LOGGING="$ENABLE_LOGGING"

# Deployment options
SKIP_BACKUP="$SKIP_BACKUP"
SKIP_TESTS="$SKIP_TESTS"
SKIP_MOBILE="$SKIP_MOBILE"
PARALLEL_BUILDS="$PARALLEL_BUILDS"
EOF
    
    log_success "Deployment environment setup completed"
}

# Create system backup
create_system_backup() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        log_info "Skipping system backup (SKIP_BACKUP=true)"
        return 0
    fi
    
    log_step "Creating system backup..."
    
    local backup_file="$BACKUP_DIR/nexus-cos-backup-$DEPLOYMENT_ID.tar.gz"
    
    # Create backup of critical files
    tar -czf "$backup_file" \
        --exclude="$LOGS_DIR" \
        --exclude="$BACKUP_DIR" \
        --exclude="node_modules" \
        --exclude=".git" \
        --exclude="builds" \
        "$PROJECT_DIR" 2>/dev/null || true
    
    if [[ -f "$backup_file" ]]; then
        local backup_size=$(du -h "$backup_file" | cut -f1)
        log_success "System backup created: $backup_file ($backup_size)"
    else
        log_warning "Failed to create system backup"
    fi
}

# Validate project structure
validate_project_structure() {
    log_step "Validating project structure..."
    
    local required_files=(
        "docker-compose.yml"
        "docker-compose.prod.yml"
        "frontend/package.json"
        "mobile/package.json"
        "backend/package.json"
    )
    
    local required_dirs=(
        "frontend"
        "mobile"
        "backend"
        "nginx"
        "scripts"
    )
    
    # Check required files
    for file in "${required_files[@]}"; do
        if [[ ! -f "$PROJECT_DIR/$file" ]]; then
            log_error "Required file not found: $file"
            exit 1
        else
            log_info "✓ $file found"
        fi
    done
    
    # Check required directories
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$PROJECT_DIR/$dir" ]]; then
            log_error "Required directory not found: $dir"
            exit 1
        else
            log_info "✓ $dir/ found"
        fi
    done
    
    log_success "Project structure validation completed"
}

# Run pre-deployment tests
run_predeploy_tests() {
    if [[ "$SKIP_TESTS" == "true" ]]; then
        log_info "Skipping pre-deployment tests (SKIP_TESTS=true)"
        return 0
    fi
    
    log_step "Running pre-deployment tests..."
    
    # Test Docker Compose configuration
    log_info "Testing Docker Compose configuration..."
    if docker-compose -f "$PROJECT_DIR/docker-compose.prod.yml" config &> /dev/null; then
        log_success "✓ Docker Compose configuration is valid"
    else
        log_error "Docker Compose configuration is invalid"
        exit 1
    fi
    
    # Test Nginx configuration
    if [[ -f "$PROJECT_DIR/nginx/nexuscos-online.conf" ]]; then
        log_info "Testing Nginx configuration..."
        if docker run --rm -v "$PROJECT_DIR/nginx:/etc/nginx/conf.d:ro" nginx:alpine nginx -t &> /dev/null; then
            log_success "✓ Nginx configuration is valid"
        else
            log_error "Nginx configuration is invalid"
            exit 1
        fi
    fi
    
    log_success "Pre-deployment tests completed"
}

# Build Docker images
build_docker_images() {
    log_step "Building Docker images..."
    
    cd "$PROJECT_DIR"
    
    if [[ "$PARALLEL_BUILDS" == "true" ]]; then
        log_info "Building images in parallel..."
        
        # Build core services in parallel
        {
            log_deploy "Building frontend image..."
            docker-compose -f docker-compose.prod.yml build frontend &
            FRONTEND_PID=$!
        }
        
        {
            log_deploy "Building backend image..."
            docker-compose -f docker-compose.prod.yml build backend &
            BACKEND_PID=$!
        }
        
        {
            log_deploy "Building V-Suite images..."
            docker-compose -f docker-compose.prod.yml build v-screen v-stage v-caster-pro &
            VSUITE_PID=$!
        }
        
        # Wait for core builds to complete
        wait $FRONTEND_PID && log_success "✓ Frontend image built"
        wait $BACKEND_PID && log_success "✓ Backend image built"
        wait $VSUITE_PID && log_success "✓ V-Suite images built"
        
        # Build remaining services
        log_deploy "Building remaining services..."
        docker-compose -f docker-compose.prod.yml build
        
    else
        log_info "Building images sequentially..."
        docker-compose -f docker-compose.prod.yml build
    fi
    
    log_success "Docker images built successfully"
}

# Deploy infrastructure services
deploy_infrastructure() {
    log_step "Deploying infrastructure services..."
    
    cd "$PROJECT_DIR"
    
    # Start database and cache services first
    log_deploy "Starting database and cache services..."
    docker-compose -f docker-compose.prod.yml up -d postgres redis
    
    # Wait for database to be ready
    log_info "Waiting for database to be ready..."
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker-compose -f docker-compose.prod.yml exec -T postgres pg_isready -U nexus_user &> /dev/null; then
            log_success "✓ Database is ready"
            break
        fi
        
        attempt=$((attempt + 1))
        log_info "Database not ready, waiting... (attempt $attempt/$max_attempts)"
        sleep 10
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        log_error "Database failed to start within expected time"
        exit 1
    fi
    
    # Wait for Redis to be ready
    log_info "Waiting for Redis to be ready..."
    attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        if docker-compose -f docker-compose.prod.yml exec -T redis redis-cli ping | grep -q "PONG"; then
            log_success "✓ Redis is ready"
            break
        fi
        
        attempt=$((attempt + 1))
        log_info "Redis not ready, waiting... (attempt $attempt/$max_attempts)"
        sleep 5
    done
    
    if [[ $attempt -eq $max_attempts ]]; then
        log_error "Redis failed to start within expected time"
        exit 1
    fi
    
    log_success "Infrastructure services deployed successfully"
}

# Deploy application services
deploy_application_services() {
    log_step "Deploying application services..."
    
    cd "$PROJECT_DIR"
    
    # Deploy core application services
    log_deploy "Starting core application services..."
    docker-compose -f docker-compose.prod.yml up -d \
        backend \
        frontend \
        v-screen \
        v-stage \
        v-caster-pro \
        v-prompter-pro \
        nexus-cos-studio-ai \
        boom-boom-room-live
    
    # Wait for services to be healthy
    wait_for_service_health "backend" "8000"
    wait_for_service_health "frontend" "3000"
    
    log_success "Application services deployed successfully"
}

# Deploy monitoring services
deploy_monitoring() {
    if [[ "$ENABLE_MONITORING" != "true" ]]; then
        log_info "Monitoring disabled, skipping deployment"
        return 0
    fi
    
    log_step "Deploying monitoring services..."
    
    cd "$PROJECT_DIR"
    
    # Start monitoring services
    log_deploy "Starting monitoring services..."
    docker-compose -f docker-compose.prod.yml up -d prometheus grafana
    
    # Wait for monitoring services
    wait_for_service_health "prometheus" "9090"
    wait_for_service_health "grafana" "3001"
    
    log_success "Monitoring services deployed successfully"
}

# Deploy reverse proxy
deploy_reverse_proxy() {
    log_step "Deploying reverse proxy..."
    
    cd "$PROJECT_DIR"
    
    # Start Nginx reverse proxy
    log_deploy "Starting Nginx reverse proxy..."
    docker-compose -f docker-compose.prod.yml up -d nginx
    
    # Wait for Nginx to be ready
    wait_for_service_health "nginx" "80"
    
    log_success "Reverse proxy deployed successfully"
}

# Setup SSL certificates
setup_ssl_certificates() {
    if [[ "$ENABLE_SSL" != "true" ]]; then
        log_info "SSL disabled, skipping certificate setup"
        return 0
    fi
    
    log_step "Setting up SSL certificates..."
    
    if [[ -f "$SCRIPTS_DIR/setup-ssl.sh" ]]; then
        log_info "Running SSL setup script..."
        chmod +x "$SCRIPTS_DIR/setup-ssl.sh"
        
        # Set environment variables for SSL script
        export SSL_EMAIL="${SSL_EMAIL:-admin@$DOMAIN}"
        export DOMAIN="$DOMAIN"
        
        if "$SCRIPTS_DIR/setup-ssl.sh"; then
            log_success "SSL certificates configured successfully"
        else
            log_error "SSL setup failed"
            exit 1
        fi
    else
        log_warning "SSL setup script not found, skipping SSL configuration"
    fi
}

# Deploy mobile applications
deploy_mobile_applications() {
    if [[ "$SKIP_MOBILE" == "true" ]]; then
        log_info "Skipping mobile deployment (SKIP_MOBILE=true)"
        return 0
    fi
    
    log_step "Deploying mobile applications..."
    
    if [[ -f "$SCRIPTS_DIR/deploy-mobile.sh" ]]; then
        log_info "Running mobile deployment script..."
        chmod +x "$SCRIPTS_DIR/deploy-mobile.sh"
        
        # Set environment variables for mobile deployment
        export BUILD_PROFILE="$ENVIRONMENT"
        export PLATFORM="${MOBILE_PLATFORM:-all}"
        
        if "$SCRIPTS_DIR/deploy-mobile.sh"; then
            log_success "Mobile applications deployed successfully"
        else
            log_warning "Mobile deployment failed, continuing with web deployment"
        fi
    else
        log_warning "Mobile deployment script not found, skipping mobile deployment"
    fi
}

# Wait for service health
wait_for_service_health() {
    local service_name="$1"
    local port="$2"
    local max_attempts=30
    local attempt=0
    
    log_info "Waiting for $service_name to be healthy..."
    
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s -f "http://localhost:$port/health" &> /dev/null || \
           curl -s -f "http://localhost:$port" &> /dev/null; then
            log_success "✓ $service_name is healthy"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "$service_name not ready, waiting... (attempt $attempt/$max_attempts)"
        sleep 10
    done
    
    log_warning "$service_name health check timed out"
    return 1
}

# Run post-deployment validation
run_postdeploy_validation() {
    log_step "Running post-deployment validation..."
    
    # Check service status
    log_info "Checking service status..."
    cd "$PROJECT_DIR"
    
    local services=$(docker-compose -f docker-compose.prod.yml ps --services)
    local failed_services=()
    
    for service in $services; do
        local status=$(docker-compose -f docker-compose.prod.yml ps -q "$service" | xargs docker inspect --format='{{.State.Status}}' 2>/dev/null || echo "not_found")
        
        if [[ "$status" == "running" ]]; then
            log_success "✓ $service is running"
        else
            log_error "✗ $service is not running (status: $status)"
            failed_services+=("$service")
        fi
    done
    
    # Check endpoint accessibility
    log_info "Checking endpoint accessibility..."
    
    local endpoints=(
        "http://localhost:80"
        "http://localhost:8000/health"
        "http://localhost:3000"
    )
    
    if [[ "$ENABLE_MONITORING" == "true" ]]; then
        endpoints+=(
            "http://localhost:9090"
            "http://localhost:3001"
        )
    fi
    
    for endpoint in "${endpoints[@]}"; do
        if curl -s -f "$endpoint" &> /dev/null; then
            log_success "✓ $endpoint is accessible"
        else
            log_warning "✗ $endpoint is not accessible"
        fi
    done
    
    # Report validation results
    if [[ ${#failed_services[@]} -eq 0 ]]; then
        log_success "Post-deployment validation completed successfully"
    else
        log_warning "Some services failed validation: ${failed_services[*]}"
    fi
}

# Generate deployment report
generate_deployment_report() {
    log_step "Generating deployment report..."
    
    local report_file="$LOGS_DIR/deployment-report-$DEPLOYMENT_ID.json"
    local deployment_end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Get service status
    cd "$PROJECT_DIR"
    local services_status=$(docker-compose -f docker-compose.prod.yml ps --format json 2>/dev/null || echo "[]")
    
    # Get system information
    local system_info=$(cat << EOF
{
  "hostname": "$(hostname)",
  "os": "$(uname -s)",
  "kernel": "$(uname -r)",
  "architecture": "$(uname -m)",
  "uptime": "$(uptime -p 2>/dev/null || echo 'unknown')",
  "dockerVersion": "$(docker --version | cut -d' ' -f3 | tr -d ',')",
  "dockerComposeVersion": "$(docker-compose --version | cut -d' ' -f3 | tr -d ',')"
}
EOF
)
    
    # Create comprehensive deployment report
    cat > "$report_file" << EOF
{
  "deployment": {
    "id": "$DEPLOYMENT_ID",
    "version": "$SCRIPT_VERSION",
    "startTime": "$deployment_start_time",
    "endTime": "$deployment_end_time",
    "duration": "$(($(date +%s) - deployment_start_timestamp)) seconds",
    "domain": "$DOMAIN",
    "environment": "$ENVIRONMENT",
    "deployMode": "$DEPLOY_MODE"
  },
  "configuration": {
    "enableSSL": $ENABLE_SSL,
    "enableMonitoring": $ENABLE_MONITORING,
    "enableBackups": $ENABLE_BACKUPS,
    "enableLogging": $ENABLE_LOGGING,
    "skipBackup": $SKIP_BACKUP,
    "skipTests": $SKIP_TESTS,
    "skipMobile": $SKIP_MOBILE,
    "parallelBuilds": $PARALLEL_BUILDS
  },
  "system": $system_info,
  "services": $services_status,
  "files": {
    "logFile": "$LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log",
    "configFile": "$CONFIG_DIR/deployment-$DEPLOYMENT_ID.conf",
    "backupFile": "$BACKUP_DIR/nexus-cos-backup-$DEPLOYMENT_ID.tar.gz"
  }
}
EOF
    
    log_success "Deployment report generated: $report_file"
}

# Print deployment completion summary
print_completion_summary() {
    local deployment_duration=$(($(date +%s) - deployment_start_timestamp))
    
    echo ""
    log_header "DEPLOYMENT COMPLETED SUCCESSFULLY! 🎉"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Deployment ID:       $DEPLOYMENT_ID"
    echo "Duration:            ${deployment_duration} seconds"
    echo "Domain:              $DOMAIN"
    echo "Environment:         $ENVIRONMENT"
    echo ""
    echo "🌐 Web Application:   http://$DOMAIN"
    if [[ "$ENABLE_SSL" == "true" ]]; then
        echo "🔒 Secure Access:     https://$DOMAIN"
    fi
    if [[ "$ENABLE_MONITORING" == "true" ]]; then
        echo "📊 Monitoring:        http://$DOMAIN/grafana"
        echo "📈 Metrics:           http://$DOMAIN/prometheus"
    fi
    echo ""
    echo "📁 Logs Directory:    $LOGS_DIR"
    echo "📋 Deployment Report: $LOGS_DIR/deployment-report-$DEPLOYMENT_ID.json"
    echo "⚙️  Configuration:     $CONFIG_DIR/deployment-$DEPLOYMENT_ID.conf"
    echo ""
    echo "🚀 Nexus COS Extended is now live and ready for use!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Print usage information
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Nexus COS Extended Master Deployment Script"
    echo ""
    echo "Options:"
    echo "  -d, --domain DOMAIN           Domain name (default: nexuscos.online)"
    echo "  -e, --environment ENV         Environment (development|staging|production)"
    echo "  -m, --mode MODE              Deploy mode (full|services|infrastructure)"
    echo "      --skip-backup            Skip system backup"
    echo "      --skip-tests             Skip pre-deployment tests"
    echo "      --skip-mobile            Skip mobile application deployment"
    echo "      --no-ssl                 Disable SSL/TLS setup"
    echo "      --no-monitoring          Disable monitoring services"
    echo "      --no-parallel            Disable parallel builds"
    echo "  -h, --help                   Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  DOMAIN                       Target domain name"
    echo "  ENVIRONMENT                  Deployment environment"
    echo "  SSL_EMAIL                    Email for SSL certificate registration"
    echo "  EXPO_TOKEN                   Expo authentication token for mobile builds"
    echo ""
    echo "Examples:"
    echo "  $0                           # Full deployment with default settings"
    echo "  $0 -d myapp.com -e production # Deploy to custom domain"
    echo "  $0 --skip-mobile --no-ssl    # Deploy without mobile apps and SSL"
    echo "  $0 -m services               # Deploy only application services"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                DOMAIN="$2"
                shift 2
                ;;
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -m|--mode)
                DEPLOY_MODE="$2"
                shift 2
                ;;
            --skip-backup)
                SKIP_BACKUP="true"
                shift
                ;;
            --skip-tests)
                SKIP_TESTS="true"
                shift
                ;;
            --skip-mobile)
                SKIP_MOBILE="true"
                shift
                ;;
            --no-ssl)
                ENABLE_SSL="false"
                shift
                ;;
            --no-monitoring)
                ENABLE_MONITORING="false"
                shift
                ;;
            --no-parallel)
                PARALLEL_BUILDS="false"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        log_error "Deployment failed with exit code $exit_code"
        
        # Attempt to collect failure information
        if [[ -d "$PROJECT_DIR" ]]; then
            cd "$PROJECT_DIR"
            log_info "Collecting failure information..."
            
            # Save Docker logs
            docker-compose -f docker-compose.prod.yml logs > "$LOGS_DIR/docker-logs-failure-$DEPLOYMENT_ID.log" 2>&1 || true
            
            # Save service status
            docker-compose -f docker-compose.prod.yml ps > "$LOGS_DIR/service-status-failure-$DEPLOYMENT_ID.log" 2>&1 || true
        fi
        
        echo ""
        log_error "Deployment failed! Check logs for details:"
        log_error "  Main log: $LOGS_DIR/master-deploy-$DEPLOYMENT_ID.log"
        log_error "  Docker logs: $LOGS_DIR/docker-logs-failure-$DEPLOYMENT_ID.log"
        log_error "  Service status: $LOGS_DIR/service-status-failure-$DEPLOYMENT_ID.log"
    fi
}

# Main execution function
main() {
    # Record deployment start time
    deployment_start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    deployment_start_timestamp=$(date +%s)
    
    print_banner
    print_deployment_summary
    
    # Confirm deployment
    if [[ "${FORCE_DEPLOY:-false}" != "true" ]]; then
        echo -n "Proceed with deployment? [y/N]: "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled by user"
            exit 0
        fi
    fi
    
    log_header "Starting Nexus COS Extended deployment..."
    
    # Execute deployment steps
    check_system_requirements
    setup_deployment_environment
    create_system_backup
    validate_project_structure
    run_predeploy_tests
    
    case "$DEPLOY_MODE" in
        "full")
            build_docker_images
            deploy_infrastructure
            deploy_application_services
            deploy_monitoring
            deploy_reverse_proxy
            setup_ssl_certificates
            deploy_mobile_applications
            ;;
        "services")
            build_docker_images
            deploy_application_services
            ;;
        "infrastructure")
            deploy_infrastructure
            deploy_monitoring
            deploy_reverse_proxy
            ;;
        *)
            log_error "Invalid deploy mode: $DEPLOY_MODE"
            exit 1
            ;;
    esac
    
    run_postdeploy_validation
    generate_deployment_report
    print_completion_summary
    
    log_success "Nexus COS Extended deployment completed successfully!"
}

# Set up signal handlers
trap cleanup EXIT
trap 'log_error "Deployment interrupted by user"; exit 130' INT TERM

# Parse arguments and execute main function
parse_arguments "$@"
main
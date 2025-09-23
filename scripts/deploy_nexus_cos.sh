#!/bin/bash

# Nexus COS VPS Deployment Script
# Automated deployment script for production VPS servers
# Version: 1.0.0

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="nexus-cos"
DEPLOY_USER="nexus"
DEPLOY_DIR="/opt/nexus-cos"
BACKUP_DIR="/opt/nexus-cos-backups"
LOG_FILE="/var/log/nexus-cos-deploy.log"
DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
ENV_FILE=".env.production"

# Default values
SKIP_BACKUP=false
SKIP_TESTS=false
FORCE_DEPLOY=false
DRY_RUN=false

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to show usage
show_usage() {
    cat << EOF
Nexus COS VPS Deployment Script

Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -d, --deploy-dir DIR    Deployment directory (default: $DEPLOY_DIR)
    -u, --user USER         Deployment user (default: $DEPLOY_USER)
    -s, --skip-backup       Skip backup creation
    -t, --skip-tests        Skip pre-deployment tests
    -f, --force             Force deployment even if tests fail
    --dry-run               Show what would be done without executing
    -v, --verbose           Enable verbose output

Examples:
    $0                      # Standard deployment
    $0 --skip-backup        # Deploy without backup
    $0 --dry-run            # Preview deployment steps
    $0 -f                   # Force deployment

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--deploy-dir)
            DEPLOY_DIR="$2"
            shift 2
            ;;
        -u|--user)
            DEPLOY_USER="$2"
            shift 2
            ;;
        -s|--skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        -t|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        -f|--force)
            FORCE_DEPLOY=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            set -x
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root for security reasons"
        exit 1
    fi
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Docker is installed and running
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running"
        exit 1
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    
    # Check if required files exist
    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        print_error "Docker Compose file not found: $DOCKER_COMPOSE_FILE"
        exit 1
    fi
    
    if [[ ! -f "$ENV_FILE" ]]; then
        print_error "Environment file not found: $ENV_FILE"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create backup
create_backup() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        print_warning "Skipping backup creation"
        return 0
    fi
    
    print_status "Creating backup..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would create backup in $BACKUP_DIR"
        return 0
    fi
    
    # Create backup directory if it doesn't exist
    sudo mkdir -p "$BACKUP_DIR"
    
    # Create timestamped backup
    BACKUP_NAME="nexus-cos-backup-$(date +%Y%m%d-%H%M%S)"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    if [[ -d "$DEPLOY_DIR" ]]; then
        sudo cp -r "$DEPLOY_DIR" "$BACKUP_PATH"
        print_success "Backup created: $BACKUP_PATH"
    else
        print_warning "No existing deployment found to backup"
    fi
}

# Function to run pre-deployment tests
run_tests() {
    if [[ "$SKIP_TESTS" == true ]]; then
        print_warning "Skipping pre-deployment tests"
        return 0
    fi
    
    print_status "Running pre-deployment tests..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would run deployment validation tests"
        return 0
    fi
    
    # Run deployment validation script if it exists
    if [[ -f "scripts/validate-deployment.ps1" ]]; then
        print_status "Running deployment validation..."
        if command -v pwsh &> /dev/null; then
            if ! pwsh -File scripts/validate-deployment.ps1 -CheckAll; then
                if [[ "$FORCE_DEPLOY" == false ]]; then
                    print_error "Deployment validation failed. Use --force to override."
                    exit 1
                else
                    print_warning "Deployment validation failed but continuing due to --force flag"
                fi
            fi
        else
            print_warning "PowerShell not available, skipping validation script"
        fi
    fi
    
    # Validate Docker Compose configuration
    if ! docker-compose -f "$DOCKER_COMPOSE_FILE" config &> /dev/null; then
        print_error "Docker Compose configuration is invalid"
        exit 1
    fi
    
    print_success "Pre-deployment tests passed"
}

# Function to stop existing services
stop_services() {
    print_status "Stopping existing services..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would stop existing Docker services"
        return 0
    fi
    
    if [[ -d "$DEPLOY_DIR" ]]; then
        cd "$DEPLOY_DIR"
        if [[ -f "$DOCKER_COMPOSE_FILE" ]]; then
            docker-compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans || true
        fi
    fi
    
    print_success "Services stopped"
}

# Function to deploy application
deploy_application() {
    print_status "Deploying application..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would deploy application to $DEPLOY_DIR"
        return 0
    fi
    
    # Create deployment directory
    sudo mkdir -p "$DEPLOY_DIR"
    sudo chown "$USER:$USER" "$DEPLOY_DIR"
    
    # Copy application files
    print_status "Copying application files..."
    rsync -av --exclude='.git' --exclude='node_modules' --exclude='.env*' . "$DEPLOY_DIR/"
    
    # Copy environment file
    cp "$ENV_FILE" "$DEPLOY_DIR/.env"
    
    # Set proper permissions
    sudo chown -R "$DEPLOY_USER:$DEPLOY_USER" "$DEPLOY_DIR"
    sudo chmod 600 "$DEPLOY_DIR/.env"
    
    print_success "Application files deployed"
}

# Function to build and start services
start_services() {
    print_status "Building and starting services..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would build and start Docker services"
        return 0
    fi
    
    cd "$DEPLOY_DIR"
    
    # Pull latest images
    docker-compose -f "$DOCKER_COMPOSE_FILE" pull
    
    # Build services
    docker-compose -f "$DOCKER_COMPOSE_FILE" build --no-cache
    
    # Start services
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    print_success "Services started"
}

# Function to run health checks
run_health_checks() {
    print_status "Running health checks..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would run health checks"
        return 0
    fi
    
    # Wait for services to start
    sleep 30
    
    # Run health check script if available
    if [[ -f "$DEPLOY_DIR/scripts/health-check.ps1" ]]; then
        cd "$DEPLOY_DIR"
        if command -v pwsh &> /dev/null; then
            pwsh -File scripts/health-check.ps1 -Quick
        else
            print_warning "PowerShell not available, skipping health check script"
        fi
    fi
    
    # Basic Docker health check
    if docker-compose -f "$DEPLOY_DIR/$DOCKER_COMPOSE_FILE" ps | grep -q "unhealthy"; then
        print_warning "Some services are unhealthy"
    else
        print_success "All services are healthy"
    fi
}

# Function to setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would setup monitoring"
        return 0
    fi
    
    # Create monitoring directories
    sudo mkdir -p /var/log/nexus-cos
    sudo mkdir -p /opt/nexus-cos-monitoring
    
    # Setup log rotation
    cat << EOF | sudo tee /etc/logrotate.d/nexus-cos
/var/log/nexus-cos/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $DEPLOY_USER $DEPLOY_USER
}
EOF
    
    print_success "Monitoring setup completed"
}

# Function to setup systemd service
setup_systemd() {
    print_status "Setting up systemd service..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would setup systemd service"
        return 0
    fi
    
    cat << EOF | sudo tee /etc/systemd/system/nexus-cos.service
[Unit]
Description=Nexus COS Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$DEPLOY_DIR
ExecStart=/usr/local/bin/docker-compose -f $DOCKER_COMPOSE_FILE up -d
ExecStop=/usr/local/bin/docker-compose -f $DOCKER_COMPOSE_FILE down
TimeoutStartSec=0
User=$DEPLOY_USER
Group=$DEPLOY_USER

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable nexus-cos.service
    
    print_success "Systemd service setup completed"
}

# Function to cleanup old backups
cleanup_backups() {
    print_status "Cleaning up old backups..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "[DRY RUN] Would cleanup old backups"
        return 0
    fi
    
    # Keep only last 5 backups
    if [[ -d "$BACKUP_DIR" ]]; then
        cd "$BACKUP_DIR"
        ls -t | tail -n +6 | xargs -r sudo rm -rf
    fi
    
    print_success "Backup cleanup completed"
}

# Function to show deployment summary
show_summary() {
    print_status "Deployment Summary"
    echo "===========================================" | tee -a "$LOG_FILE"
    echo "Project: $PROJECT_NAME" | tee -a "$LOG_FILE"
    echo "Deploy Directory: $DEPLOY_DIR" | tee -a "$LOG_FILE"
    echo "Deploy User: $DEPLOY_USER" | tee -a "$LOG_FILE"
    echo "Deployment Time: $(date)" | tee -a "$LOG_FILE"
    echo "===========================================" | tee -a "$LOG_FILE"
    
    if [[ "$DRY_RUN" == false ]]; then
        echo "Services Status:" | tee -a "$LOG_FILE"
        cd "$DEPLOY_DIR"
        docker-compose -f "$DOCKER_COMPOSE_FILE" ps | tee -a "$LOG_FILE"
    fi
}

# Main deployment function
main() {
    print_status "Starting Nexus COS deployment..."
    
    # Initialize log file
    sudo touch "$LOG_FILE"
    sudo chown "$USER:$USER" "$LOG_FILE"
    
    # Run deployment steps
    check_root
    check_prerequisites
    create_backup
    run_tests
    stop_services
    deploy_application
    start_services
    run_health_checks
    setup_monitoring
    setup_systemd
    cleanup_backups
    show_summary
    
    if [[ "$DRY_RUN" == true ]]; then
        print_success "Dry run completed successfully"
    else
        print_success "Deployment completed successfully!"
        print_status "Application should be available at the configured URLs"
        print_status "Check logs: tail -f $LOG_FILE"
        print_status "Check services: docker-compose -f $DEPLOY_DIR/$DOCKER_COMPOSE_FILE ps"
    fi
}

# Trap errors and cleanup
trap 'print_error "Deployment failed at line $LINENO"' ERR

# Run main function
main "$@"
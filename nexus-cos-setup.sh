#!/bin/bash

# === Nexus COS Automated Deployment Script ===
# This script handles the complete deployment of Nexus COS backend services
# using PM2 process management and dynamic Nginx configuration.

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Configuration
DEPLOY_ROOT="/var/www/nexus-cos"
LOG_DIR="/var/log/nexus-cos"
BACKUP_DIR="/var/backups/nexus-cos"
CONFIG_FILE="nexus-cos-services.yml"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to log messages
log() {
    echo -e "${2:-$NC}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and install dependencies
install_dependencies() {
    log "Checking and installing dependencies..." "$YELLOW"
    
    # Update package list
    apt-get update
    
    # Install Node.js if not present
    if ! command_exists node; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
        apt-get install -y nodejs
    fi
    
    # Install Python3 and pip if not present
    if ! command_exists python3; then
        apt-get install -y python3 python3-pip
    fi
    
    # Install MongoDB if not present
    if ! command_exists mongod; then
        wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
        echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
        apt-get update
        apt-get install -y mongodb-org
        systemctl enable mongod
        systemctl start mongod
    fi
    
    # Install Redis if not present
    if ! command_exists redis-server; then
        apt-get install -y redis-server
        systemctl enable redis-server
        systemctl start redis-server
    fi
    
    # Install PM2 globally if not present
    if ! command_exists pm2; then
        npm install -g pm2
    fi
    
    # Install other required packages
    apt-get install -y nginx ffmpeg build-essential python3-dev
    
    log "All dependencies installed successfully" "$GREEN"
}

# Function to create required directories
setup_directories() {
    log "Setting up directory structure..." "$YELLOW"
    
    mkdir -p "$DEPLOY_ROOT"
    mkdir -p "$LOG_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$DEPLOY_ROOT/static"
    mkdir -p "/var/nexus-cos/media"
    mkdir -p "/var/nexus-cos/venv"
    
    # Set proper permissions
    chown -R www-data:www-data "$DEPLOY_ROOT"
    chmod -R 755 "$DEPLOY_ROOT"
    
    log "Directory structure created successfully" "$GREEN"
}

# Function to backup existing deployment
backup_existing() {
    log "Creating backup of existing deployment..." "$YELLOW"
    
    if [ -d "$DEPLOY_ROOT" ]; then
        tar -czf "$BACKUP_DIR/nexus-cos-$TIMESTAMP.tar.gz" -C "$DEPLOY_ROOT" .
        log "Backup created at $BACKUP_DIR/nexus-cos-$TIMESTAMP.tar.gz" "$GREEN"
    else
        log "No existing deployment found to backup" "$YELLOW"
    fi
}

# Function to parse YAML configuration
parse_yaml() {
    local yaml_file=$1
    python3 -c '
import yaml
import json
import sys

with open("'"$yaml_file"'", "r") as f:
    try:
        data = yaml.safe_load(f)
        print(json.dumps(data))
    except Exception as e:
        print(f"Error parsing YAML: {str(e)}", file=sys.stderr)
        sys.exit(1)
    '
}

# Function to stop existing PM2 processes
stop_existing_processes() {
    log "Stopping existing PM2 processes..." "$YELLOW"
    
    if command_exists pm2; then
        pm2 delete all 2>/dev/null || true
        pm2 kill 2>/dev/null || true
    fi
    
    log "All PM2 processes stopped" "$GREEN"
}

# Function to start services with PM2
start_services() {
    log "Starting services with PM2..." "$YELLOW"
    
    local config_json
    config_json=$(parse_yaml "$CONFIG_FILE")
    
    # Extract and start each service
    echo "$config_json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
services = data.get("services", {})

for service_name, config in services.items():
    print(json.dumps({
        "name": config["name"],
        "script": config["script"],
        "env": config.get("env", {}),
        "interpreter": config.get("interpreter", "node"),
        "instances": config.get("instances", 1),
        "exec_mode": config.get("exec_mode", "fork")
    }))
' | while read -r service_config; do
        pm2 start "$(echo "$service_config" | jq -r '.script')" \
            --name "$(echo "$service_config" | jq -r '.name')" \
            --interpreter "$(echo "$service_config" | jq -r '.interpreter')" \
            --instances "$(echo "$service_config" | jq -r '.instances')" \
            --exec-mode "$(echo "$service_config" | jq -r '.exec_mode')" \
            --env "$(echo "$service_config" | jq -r '.env')"
    done
    
    # Save PM2 process list and setup startup script
    pm2 save
    pm2 startup
    
    log "All services started successfully" "$GREEN"
}

# Function to check service health
check_service_health() {
    log "Checking service health..." "$YELLOW"
    
    local config_json
    config_json=$(parse_yaml "$CONFIG_FILE")
    
    # Check each service's health endpoint
    echo "$config_json" | python3 -c '
import json
import sys
import urllib.request
import time

data = json.load(sys.stdin)
services = data.get("services", {})

for service_name, config in services.items():
    port = config.get("port")
    health_endpoint = config.get("health_endpoint", "/health")
    url = f"http://localhost:{port}{health_endpoint}"
    
    max_retries = 5
    retry_delay = 2
    
    for i in range(max_retries):
        try:
            response = urllib.request.urlopen(url)
            if response.getcode() == 200:
                print(f"Service {service_name} is healthy")
                break
        except Exception as e:
            if i == max_retries - 1:
                print(f"Error: Service {service_name} health check failed: {str(e)}")
                sys.exit(1)
            time.sleep(retry_delay)
'
    
    log "Health checks completed" "$GREEN"
}

# Main deployment process
main() {
    log "Starting Nexus COS deployment..." "$YELLOW"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log "Please run as root" "$RED"
        exit 1
    fi
    
    # Check if configuration file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log "Configuration file $CONFIG_FILE not found" "$RED"
        exit 1
    fi
    
    # Execute deployment steps
    install_dependencies
    setup_directories
    backup_existing
    stop_existing_processes
    start_services
    check_service_health
    
    log "Deployment completed successfully!" "$GREEN"
}

# Execute main function
main
#!/bin/bash
# Nexus COS PF v1.2 Deployment Script
# Handles dependency-aware deployment of services and modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="nexus-cos-services-v1.2.yml"
LOG_DIR="logs"
DEPLOY_MODE=${1:-"development"}  # development, staging, production

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    Nexus COS PF v1.2 Deployment                             ║${NC}"
    echo -e "${PURPLE}║                     With Dependency Mapping                                  ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Mode: ${DEPLOY_MODE}${NC}"
    echo -e "${CYAN}Config: ${CONFIG_FILE}${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if yq is installed
    if ! command -v yq &> /dev/null; then
        print_error "yq is required but not installed. Installing..."
        wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        chmod +x /usr/local/bin/yq
    fi
    
    # Check if PM2 is installed
    if ! command -v pm2 &> /dev/null; then
        print_error "PM2 is required but not installed. Installing..."
        npm install -g pm2
    fi
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed. Please install Node.js first."
        exit 1
    fi
    
    # Check configuration file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        print_error "Configuration file $CONFIG_FILE not found!"
        exit 1
    fi
    
    # Create log directory
    mkdir -p "$LOG_DIR"
    
    print_success "Prerequisites check complete"
}

# Stop existing services
stop_existing_services() {
    print_step "Stopping existing services..."
    
    if pm2 list | grep -q "online\|stopped\|errored"; then
        pm2 stop all || true
        pm2 delete all || true
        print_success "Stopped existing PM2 processes"
    else
        print_info "No existing PM2 processes found"
    fi
}

# Deploy core services (Phase 1)
deploy_core_services() {
    print_step "Deploying Phase 1: Core Services..."
    
    # Get core services from configuration
    local services=(
        "auth-service"
        "billing-service" 
        "user-profile-service"
        "media-encoding-service"
        "streaming-service"
        "recommendation-engine"
        "chat-service"
        "notification-service"
        "analytics-service"
    )
    
    for service in "${services[@]}"; do
        deploy_service "$service" "core_services"
        
        # Wait for service to be healthy before continuing
        wait_for_health "$service"
    done
    
    print_success "Phase 1: Core Services deployment complete"
}

# Deploy business modules (Phase 2)
deploy_business_modules() {
    print_step "Deploying Phase 2: Business Modules..."
    
    local modules=(
        "core-os"
        "puabo-dsp"
        "puabo-blac"
        "v-suite"
        "media-community"
        "business-tools"
        "integrations"
    )
    
    for module in "${modules[@]}"; do
        deploy_service "$module" "business_modules"
        
        # Wait for module to be healthy
        wait_for_health "$module"
    done
    
    print_success "Phase 2: Business Modules deployment complete"
}

# Deploy individual service/module
deploy_service() {
    local service_name=$1
    local service_type=$2
    
    print_info "Deploying $service_name ($service_type)..."
    
    # Get service configuration
    local script=$(yq eval ".${service_type}[] | select(.name == \"$service_name\") | .script" "$CONFIG_FILE")
    local port=$(yq eval ".${service_type}[] | select(.name == \"$service_name\") | .port" "$CONFIG_FILE")
    local interpreter=$(yq eval ".${service_type}[] | select(.name == \"$service_name\") | .interpreter" "$CONFIG_FILE")
    local cwd=$(yq eval ".${service_type}[] | select(.name == \"$service_name\") | .cwd" "$CONFIG_FILE")
    
    # Check if script file exists
    if [[ ! -f "$script" ]]; then
        print_warning "Script $script not found, creating placeholder..."
        create_service_placeholder "$service_name" "$script" "$port"
    fi
    
    # Install dependencies if package.json exists
    local service_dir=$(dirname "$script")
    if [[ -f "$service_dir/package.json" ]]; then
        print_info "Installing dependencies for $service_name..."
        cd "$service_dir"
        npm install --silent
        cd - >/dev/null
    fi
    
    # Check if port is available
    if ! check_port_available "$port"; then
        print_warning "Port $port is in use, stopping conflicting process..."
        fuser -k ${port}/tcp || true
        sleep 2
    fi
    
    # Start service with PM2
    pm2 start "$script" \
        --name "$service_name" \
        --interpreter "$interpreter" \
        --cwd "$cwd" \
        --log "$LOG_DIR/${service_name}.log" \
        --env NODE_ENV="$DEPLOY_MODE" \
        --env PORT="$port" \
        --max-memory-restart 500M
    
    print_success "$service_name started on port $port"
}

# Create placeholder service if it doesn't exist
create_service_placeholder() {
    local service_name=$1
    local script_path=$2
    local port=$3
    
    local script_dir=$(dirname "$script_path")
    mkdir -p "$script_dir"
    
    cat > "$script_path" << EOF
// $service_name - Auto-generated placeholder
// This is a temporary placeholder service generated by PF v1.2 deployment

const express = require('express');
const app = express();
const PORT = process.env.PORT || $port;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: '$service_name',
        version: 'placeholder',
        timestamp: new Date().toISOString(),
        port: PORT
    });
});

// Placeholder API endpoint
app.get('/', (req, res) => {
    res.json({ 
        message: 'Welcome to $service_name',
        status: 'placeholder - needs implementation',
        service: '$service_name'
    });
});

app.listen(PORT, () => {
    console.log(\`🚀 $service_name placeholder running on port \${PORT}\`);
    console.log(\`📊 Health check: http://localhost:\${PORT}/health\`);
});

module.exports = app;
EOF

    # Create package.json if it doesn't exist
    if [[ ! -f "$script_dir/package.json" ]]; then
        cat > "$script_dir/package.json" << EOF
{
  "name": "$service_name",
  "version": "1.0.0",
  "description": "$service_name service for Nexus COS PF v1.2",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "dotenv": "^16.3.1"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF
    fi
    
    print_info "Created placeholder service for $service_name"
}

# Check if port is available
check_port_available() {
    local port=$1
    ! netstat -ln | grep -q ":$port "
}

# Wait for service health check
wait_for_health() {
    local service_name=$1
    local max_attempts=30
    local attempt=1
    
    # Get service port
    local port=$(yq eval ".core_services[]?, .business_modules[]? | select(.name == \"$service_name\") | .port" "$CONFIG_FILE")
    
    print_info "Waiting for $service_name health check (port $port)..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -sf "http://localhost:$port/health" >/dev/null 2>&1; then
            print_success "$service_name is healthy"
            return 0
        fi
        
        print_info "Attempt $attempt/$max_attempts - waiting for $service_name..."
        sleep 2
        ((attempt++))
    done
    
    print_warning "$service_name health check timed out, but continuing deployment..."
    return 1
}

# Configure nginx reverse proxy
configure_nginx() {
    print_step "Configuring Nginx reverse proxy..."
    
    local nginx_config="/etc/nginx/sites-available/nexus-cos-pf-v1.2"
    
    cat > "$nginx_config" << 'EOF'
server {
    listen 80;
    server_name n3xuscos.online;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Core Services routing
    location /api/auth/ {
        proxy_pass http://localhost:3100/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/billing/ {
        proxy_pass http://localhost:3110/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/profile/ {
        proxy_pass http://localhost:3120/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/encoding/ {
        proxy_pass http://localhost:3130/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/streaming/ {
        proxy_pass http://localhost:3140/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/recommend/ {
        proxy_pass http://localhost:3150/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/chat/ {
        proxy_pass http://localhost:3160/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/notify/ {
        proxy_pass http://localhost:3170/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/analytics/ {
        proxy_pass http://localhost:3180/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Business Modules routing
    location /api/core-os/ {
        proxy_pass http://localhost:3200/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/dsp/ {
        proxy_pass http://localhost:3210/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/blac/ {
        proxy_pass http://localhost:3220/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/v-suite/ {
        proxy_pass http://localhost:3230/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/community/ {
        proxy_pass http://localhost:3250/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/business/ {
        proxy_pass http://localhost:3280/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /api/integrations/ {
        proxy_pass http://localhost:3290/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Frontend serving
    location / {
        root /var/www/nexus-cos;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
}
EOF
    
    # Enable site
    ln -sf "$nginx_config" /etc/nginx/sites-enabled/
    
    # Test and reload nginx
    if nginx -t; then
        systemctl reload nginx
        print_success "Nginx configuration updated"
    else
        print_error "Nginx configuration error"
        return 1
    fi
}

# Display deployment summary
display_summary() {
    print_step "Deployment Summary"
    echo ""
    
    print_info "🚀 Nexus COS PF v1.2 Deployment Complete!"
    echo ""
    
    print_info "📊 Service Status:"
    pm2 list
    echo ""
    
    print_info "🔗 API Endpoints:"
    echo "  Core Services:"
    echo "    - Auth Service:      http://localhost:3100/health"
    echo "    - Billing Service:   http://localhost:3110/health"
    echo "    - Profile Service:   http://localhost:3120/health"
    echo "    - Encoding Service:  http://localhost:3130/health"
    echo "    - Streaming Service: http://localhost:3140/health"
    echo "    - Recommend Engine:  http://localhost:3150/health"
    echo "    - Chat Service:      http://localhost:3160/health"
    echo "    - Notify Service:    http://localhost:3170/health"
    echo "    - Analytics Service: http://localhost:3180/health"
    echo ""
    echo "  Business Modules:"
    echo "    - Core OS:           http://localhost:3200/health"
    echo "    - PUABO DSP:         http://localhost:3210/health"
    echo "    - PUABO BLAC:        http://localhost:3220/health"
    echo "    - V-Suite:           http://localhost:3230/health"
    echo "    - Media Community:   http://localhost:3250/health"
    echo "    - Business Tools:    http://localhost:3280/health"
    echo "    - Integrations:      http://localhost:3290/health"
    echo ""
    
    print_info "📝 Next Steps:"
    echo "  1. Run health checks: ./health-check-pf-v1.2.sh"
    echo "  2. View logs:         pm2 logs"
    echo "  3. Monitor services:  pm2 monit"
    echo "  4. Stop services:     pm2 stop all"
    echo ""
    
    print_success "Nexus COS PF v1.2 is ready! 🎉"
}

# Main execution
main() {
    print_header
    
    # Check if running as root for nginx operations
    if [[ $EUID -ne 0 ]] && [[ "$DEPLOY_MODE" == "production" ]]; then
        print_warning "Production deployment requires sudo privileges for nginx configuration"
        print_info "Re-running with sudo..."
        exec sudo "$0" "$@"
    fi
    
    check_prerequisites
    stop_existing_services
    deploy_core_services
    deploy_business_modules
    
    if [[ "$DEPLOY_MODE" == "production" ]]; then
        configure_nginx
    fi
    
    display_summary
}

# Execute main function
main "$@"
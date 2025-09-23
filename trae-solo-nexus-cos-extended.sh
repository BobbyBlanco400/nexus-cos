#!/bin/bash

# TRAE Solo Deployment Script – Nexus COS Extended
# Part 2: Extended Modules + V-Suite + OTT
# Project: nexus-cos
# Domain: nexuscos.online
# Deploy Path: /opt/nexus-cos

set -e

# Configuration
PROJECT_NAME="nexus-cos"
DOMAIN="nexuscos.online"
DEPLOY_PATH="/opt/nexus-cos"
DOCKER_NETWORK="nexus_net"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
    fi
}

# Install dependencies
install_dependencies() {
    log "Installing system dependencies..."
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Install Docker and Docker Compose
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        systemctl enable docker
        systemctl start docker
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log "Installing Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    # Install additional tools
    apt-get install -y nginx certbot python3-certbot-nginx git curl wget unzip
}

# Setup directory structure
setup_directories() {
    log "Setting up directory structure..."
    
    mkdir -p $DEPLOY_PATH/{src,config,logs,data,ssl}
    mkdir -p $DEPLOY_PATH/src/modules/{puaboverse,creator-hub,ott-frontend,v-suite,boom-boom-room-live,nexus-cos-studio-ai}
    mkdir -p $DEPLOY_PATH/src/v-suite/{v-screen,v-stage,v-caster-pro,v-prompter-pro,v-hollywood-studio}
    mkdir -p $DEPLOY_PATH/data/{postgres,redis,uploads,media}
    mkdir -p $DEPLOY_PATH/logs/{nginx,app,kei-ai}
    
    # Set proper permissions
    chown -R www-data:www-data $DEPLOY_PATH
    chmod -R 755 $DEPLOY_PATH
}

# Setup environment variables
setup_environment() {
    log "Setting up environment configuration..."
    
    cat > $DEPLOY_PATH/.env << EOF
# Nexus COS Extended Environment Configuration
NODE_ENV=production
DOMAIN=$DOMAIN
DEPLOY_PATH=$DEPLOY_PATH

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=nexus_cos
POSTGRES_USER=nexus
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -base64 32)}

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=${REDIS_PASSWORD:-$(openssl rand -base64 32)}

# Kei AI Configuration
KEI_AI_KEY=${KEI_AI_KEY:-22181f6d296ef1bebb7fa8e9ea85ae22}
KEI_AI_ENDPOINT=https://api.kei.ai/v1

# JWT Configuration
JWT_SECRET=${JWT_SECRET:-$(openssl rand -base64 64)}
JWT_EXPIRES_IN=24h

# Stripe Configuration (for OTT subscriptions)
STRIPE_PUBLIC_KEY=${STRIPE_PUBLIC_KEY:?STRIPE_PUBLIC_KEY environment variable is required}
STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY:?STRIPE_SECRET_KEY environment variable is required}
STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET:?STRIPE_WEBHOOK_SECRET environment variable is required}

# Email Configuration
SMTP_HOST=${SMTP_HOST:-smtp.gmail.com}
SMTP_PORT=${SMTP_PORT:-587}
SMTP_USER=${SMTP_USER:?SMTP_USER environment variable is required}
SMTP_PASS=${SMTP_PASS:?SMTP_PASS environment variable is required}

# File Upload Configuration
MAX_FILE_SIZE=100MB
UPLOAD_PATH=$DEPLOY_PATH/data/uploads

# V-Suite Configuration
V_SUITE_STORAGE_PATH=$DEPLOY_PATH/data/v-suite
V_HOLLYWOOD_RENDER_PATH=$DEPLOY_PATH/data/renders

# OTT Configuration
OTT_CDN_URL=${OTT_CDN_URL:-https://cdn.$DOMAIN}
OTT_STREAMING_KEY=${OTT_STREAMING_KEY:-$(openssl rand -base64 32)}

# Boom Boom Room Configuration
BBR_WEBSOCKET_PORT=3001
BBR_TIPPING_WALLET_KEY=${BBR_TIPPING_WALLET_KEY:-$(openssl rand -base64 32)}

# Studio AI Configuration
STUDIO_AI_WORKSPACE_PATH=$DEPLOY_PATH/data/studio-workspaces
STUDIO_AI_RENDER_QUEUE_SIZE=10
EOF

    # Secure the environment file
    chmod 600 $DEPLOY_PATH/.env
}

# Clone and setup repositories
setup_repositories() {
    log "Setting up extended module repositories..."
    
    cd $DEPLOY_PATH/src/modules
    
    # PUABOverse Module
    if [ ! -d "puaboverse" ]; then
        log "Setting up PUABOverse module..."
        mkdir -p puaboverse/{backend,frontend,database}
        
        # Create basic structure for PUABOverse
        cat > puaboverse/package.json << EOF
{
  "name": "puaboverse",
  "version": "1.0.0",
  "description": "User Identity + Multiworld Profiles + Virtual Economy",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "mongoose": "^7.0.0",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "helmet": "^6.0.0"
  }
}
EOF
    fi
    
    # Creator Hub Module
    if [ ! -d "creator-hub" ]; then
        log "Setting up Creator Hub module..."
        mkdir -p creator-hub/{dashboard,asset-manager,integrations}
        
        cat > creator-hub/package.json << EOF
{
  "name": "creator-hub",
  "version": "1.0.0",
  "description": "Project Dashboard + Asset Manager + OTT Integration",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "multer": "^1.4.5",
    "sharp": "^0.32.0",
    "ffmpeg": "^0.0.4",
    "socket.io": "^4.6.0"
  }
}
EOF
    fi
    
    # OTT Frontend Module
    if [ ! -d "ott-frontend" ]; then
        log "Setting up OTT Frontend module..."
        mkdir -p ott-frontend/{components,pages,api,styles}
        
        cat > ott-frontend/package.json << EOF
{
  "name": "ott-frontend",
  "version": "1.0.0",
  "description": "User-Facing Streaming App with Subscription Plans",
  "main": "server.js",
  "dependencies": {
    "next": "^13.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "stripe": "^12.0.0",
    "video.js": "^8.0.0",
    "redis": "^4.6.0"
  }
}
EOF
    fi
}

# Setup V-Suite services
setup_v_suite() {
    log "Setting up V-Suite services..."
    
    cd $DEPLOY_PATH/src/v-suite
    
    # V-Screen: Virtual backdrops + immersive displays
    mkdir -p v-screen/{hollywood-edition,assets,renders}
    cat > v-screen/package.json << EOF
{
  "name": "v-screen",
  "version": "1.0.0",
  "description": "Virtual backdrops + immersive displays - Hollywood Edition",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "three": "^0.150.0",
    "canvas": "^2.11.0",
    "sharp": "^0.32.0",
    "ffmpeg": "^0.0.4"
  }
}
EOF
    
    # V-Stage: Virtual stage builder
    mkdir -p v-stage/{templates,events,live-sessions}
    cat > v-stage/package.json << EOF
{
  "name": "v-stage",
  "version": "1.0.0",
  "description": "Virtual stage builder for live events + concerts",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "socket.io": "^4.6.0",
    "webrtc": "^0.1.0",
    "three": "^0.150.0"
  }
}
EOF
    
    # V-Caster Pro: OTT broadcast + multi-streaming
    mkdir -p v-caster-pro/{streams,recordings,analytics}
    cat > v-caster-pro/package.json << EOF
{
  "name": "v-caster-pro",
  "version": "1.0.0",
  "description": "OTT broadcast + multi-streaming hub",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "node-media-server": "^2.4.0",
    "ffmpeg": "^0.0.4",
    "socket.io": "^4.6.0"
  }
}
EOF
    
    # V-Prompter Pro: AI-powered teleprompter
    mkdir -p v-prompter-pro/{scripts,ai-flow,sessions}
    cat > v-prompter-pro/package.json << EOF
{
  "name": "v-prompter-pro",
  "version": "1.0.0",
  "description": "AI-powered teleprompter + live script flow",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "openai": "^3.3.0",
    "socket.io": "^4.6.0",
    "natural": "^6.0.0"
  }
}
EOF
    
    # V-Hollywood Studio Engine
    mkdir -p v-hollywood-studio/{realism-engine,screenplay-generator,script-generator,virtual-production,kei-ai-pipeline}
    cat > v-hollywood-studio/package.json << EOF
{
  "name": "v-hollywood-studio",
  "version": "1.0.0",
  "description": "Hollywood Studio Engine with Kei AI pipeline",
  "main": "server.js",
  "dependencies": {
    "express": "^4.18.0",
    "three": "^0.150.0",
    "blender": "^1.0.0",
    "openai": "^3.3.0",
    "canvas": "^2.11.0",
    "sharp": "^0.32.0",
    "ffmpeg": "^0.0.4"
  }
}
EOF
}

# Main deployment function
main() {
    log "Starting TRAE Solo Deployment - Nexus COS Extended..."
    
    check_root
    install_dependencies
    setup_directories
    setup_environment
    setup_repositories
    setup_v_suite
    
    log "TRAE Solo deployment infrastructure setup completed!"
    log "Next steps:"
    log "1. Configure your environment variables in $DEPLOY_PATH/.env"
    log "2. Run the Docker Compose setup"
    log "3. Configure SSL certificates"
    log "4. Start all services"
    
    warn "Remember to set required environment variables:"
    warn "- STRIPE_PUBLIC_KEY, STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET"
    warn "- SMTP_USER, SMTP_PASS"
    warn "- KEI_AI_KEY (if different from default)"
}

# Run main function
main "$@"
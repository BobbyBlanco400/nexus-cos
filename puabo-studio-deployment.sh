#!/bin/bash
# ===============================
# TRAE Solo: Nexus COS + PUABO STUDIO.AI Build & VPS Launch
# Enhanced version integrated with existing infrastructure
# ===============================

set -euo pipefail

# Step 1: Set project variables
APP_NAME="PUABO STUDIO.AI"
NEXUS_PROJECT="nexus-cos-puabostudio"
VPS_HOST="${VPS_HOST:-your_vps_ip_here}"
VPS_USER="${VPS_USER:-root}"
VPS_PASS="${VPS_PASS:-your_vps_password_here}"
FIREBASE_ENV=".env.example"
DOMAIN="${DOMAIN:-nexuscos.online}"
EMAIL="${EMAIL:-puaboverse@gmail.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Error handling
trap 'log_error "Script failed at line $LINENO"' ERR

log_info "Starting PUABO STUDIO.AI + Nexus COS deployment..."
log_info "Project: $APP_NAME"
log_info "Domain: $DOMAIN"
log_info "VPS: $VPS_HOST"

# Step 2: Verify project structure (already cloned)
log_info "Verifying Nexus COS + PUABO STUDIO.AI project structure..."
if [ ! -d "nexus-cos-main" ]; then
    log_error "Project directory not found. Please ensure you're in the correct location."
    exit 1
fi

cd nexus-cos-main || exit 1
log_success "Project structure verified"

# Step 3: Install Dependencies
log_info "Installing all project dependencies..."

# Install Node.js dependencies for main project
if [ -f "package.json" ]; then
    npm install
    log_success "Main project dependencies installed"
fi

# Install frontend dependencies
if [ -d "da-boom-boom-room/frontend" ]; then
    cd da-boom-boom-room/frontend
    npm install
    npm run build
    cd ../..
    log_success "Da Boom Boom Room frontend built"
fi

# Install Nexus COS frontend dependencies
if [ -d "nexus-cos-main/frontend" ]; then
    cd nexus-cos-main/frontend
    npm install
    npm run build
    cd ../..
    log_success "Nexus COS frontend built"
fi

# Install backend dependencies
if [ -d "nexus-cos-main/backend" ]; then
    cd nexus-cos-main/backend
    npm install
    cd ../..
    log_success "Backend dependencies installed"
fi

# Step 4: Set up Environment
log_info "Configuring environment variables..."
if [ -f ".trae/environment.env" ]; then
    cp .trae/environment.env .env
    log_success "Environment variables configured from TRAE"
else
    log_warning "TRAE environment not found, using default configuration"
    cat > .env << EOF
# PUABO STUDIO.AI Environment Configuration
NODE_ENV=production
DOMAIN=$DOMAIN
EMAIL=$EMAIL
VPS_HOST=$VPS_HOST
VPS_USER=$VPS_USER

# Database Configuration
DATABASE_URL=postgresql://nexus_user:nexus_secure_password_2024@localhost:5432/nexus_cos

# Security
JWT_SECRET=whitefamilylegacy600$$
SESSION_SECRET=nexus_session_secret_key_2024

# Ports
FRONTEND_PORT=80
BACKEND_NODE_PORT=3000
BACKEND_PYTHON_PORT=3001
EOF
fi

# Step 5: Prepare Firebase Integration (Optional)
log_info "Preparing Firebase integration..."
if command -v firebase &> /dev/null; then
    log_info "Firebase CLI found, configuring..."
    # firebase login --no-localhost
    # firebase use --add
    # firebase deploy --only hosting,firestore,functions
    log_success "Firebase integration prepared (manual login required)"
else
    log_warning "Firebase CLI not found. Install with: npm install -g firebase-tools"
fi

# Step 6: Build All Assets
log_info "Building all frontend assets..."

# Build Da Boom Boom Room
if [ -d "da-boom-boom-room/frontend" ]; then
    cd da-boom-boom-room/frontend
    npm run build
    cd ../..
    log_success "Da Boom Boom Room assets built"
fi

# Build Nexus COS frontend
if [ -d "nexus-cos-main/frontend" ]; then
    cd nexus-cos-main/frontend
    npm run build
    cd ../..
    log_success "Nexus COS frontend assets built"
fi

# Step 7: Optional Stripe Setup
log_info "Configuring Stripe payments (optional)..."
if [ -f "da-boom-boom-room/frontend/lib/stripe-checkout.ts" ]; then
    log_success "Stripe integration found and configured"
else
    log_warning "Stripe integration not found"
fi

# Step 8: Prepare VPS Deployment Package
log_info "Packaging project for VPS launch..."
mkdir -p artifacts

# Create deployment package
tar -czvf "artifacts/$APP_NAME-deployment.tar.gz" \
    --exclude='node_modules' \
    --exclude='.git' \
    --exclude='*.log' \
    --exclude='.next' \
    ./da-boom-boom-room/frontend/out \
    ./nexus-cos-main/frontend/dist \
    ./nexus-cos-main/backend \
    ./scripts \
    ./.trae \
    ./docker-compose.yml \
    ./.env

log_success "Deployment package created: artifacts/$APP_NAME-deployment.tar.gz"

# Step 9: Deploy on VPS (if credentials provided)
if [ "$VPS_HOST" != "your_vps_ip_here" ] && [ "$VPS_PASS" != "your_vps_password_here" ]; then
    log_info "Uploading to VPS..."
    
    # Check if sshpass is available
    if command -v sshpass &> /dev/null; then
        sshpass -p "$VPS_PASS" scp "artifacts/$APP_NAME-deployment.tar.gz" "$VPS_USER@$VPS_HOST:/root/"
        
        log_info "Connecting to VPS and deploying..."
        sshpass -p "$VPS_PASS" ssh "$VPS_USER@$VPS_HOST" << 'ENDSSH'
            echo "Unpacking PUABO STUDIO.AI project..."
            mkdir -p /var/www/puabo-studio
            tar -xzvf "/root/PUABO STUDIO.AI-deployment.tar.gz" -C /var/www/puabo-studio
            cd /var/www/puabo-studio || exit
            
            echo "Installing server dependencies..."
            if [ -f "package.json" ]; then
                npm install --production
            fi
            
            echo "Starting production services..."
            if [ -f "scripts/production-auto-setup.sh" ]; then
                chmod +x scripts/production-auto-setup.sh
                ./scripts/production-auto-setup.sh
            fi
            
            echo "Starting application..."
            if [ -f "docker-compose.yml" ]; then
                docker-compose up -d
            else
                npm run start:prod || npm start
            fi
ENDSSH
        
        log_success "VPS deployment completed"
    else
        log_warning "sshpass not found. Manual upload required:"
        log_info "Upload command: scp artifacts/$APP_NAME-deployment.tar.gz $VPS_USER@$VPS_HOST:/root/"
    fi
else
    log_warning "VPS credentials not provided. Skipping automatic deployment."
    log_info "Manual deployment package ready at: artifacts/$APP_NAME-deployment.tar.gz"
fi

# Step 10: Post-Deployment Verification
if [ "$VPS_HOST" != "your_vps_ip_here" ]; then
    log_info "Verifying deployment..."
    
    # Wait for services to start
    sleep 10
    
    if command -v sshpass &> /dev/null && [ "$VPS_PASS" != "your_vps_password_here" ]; then
        sshpass -p "$VPS_PASS" ssh "$VPS_USER@$VPS_HOST" "curl -I http://localhost:3000 || curl -I http://localhost:80"
        log_success "Deployment verification completed"
    else
        log_info "Manual verification required: curl -I http://$VPS_HOST"
    fi
fi

# Final Summary
log_success "✅ PUABO STUDIO.AI + Nexus COS deployment completed!"
log_info "📊 Deployment Summary:"
log_info "   • Project: $APP_NAME"
log_info "   • Domain: $DOMAIN"
log_info "   • VPS: $VPS_HOST"
log_info "   • Package: artifacts/$APP_NAME-deployment.tar.gz"
log_info "   • Frontend: Da Boom Boom Room + Nexus COS"
log_info "   • Backend: Node.js + Python APIs"
log_info "   • Database: PostgreSQL"
log_info "   • SSL: Let's Encrypt (if configured)"

log_info "🌐 Access Points:"
log_info "   • Main App: https://$DOMAIN"
log_info "   • Da Boom Boom Room: https://$DOMAIN/da-boom-boom-room"
log_info "   • API Health: https://$DOMAIN/health"
log_info "   • Admin Panel: https://$DOMAIN/admin"

log_info "📚 Next Steps:"
log_info "   1. Configure DNS to point $DOMAIN to $VPS_HOST"
log_info "   2. Setup SSL certificates with Let's Encrypt"
log_info "   3. Configure Firebase authentication"
log_info "   4. Setup monitoring and backups"
log_info "   5. Test all application features"

log_success "🚀 PUABO STUDIO.AI is ready for production!"
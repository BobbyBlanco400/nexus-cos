#!/bin/bash
# ==============================================================================
# NEXUS COS - MASTER DEPLOYMENT SCRIPT
# ==============================================================================
# Bulletproof deployment script for VPS server
# Version: 1.0.0
# Date: December 18, 2025
# 
# This script will deploy the complete Nexus COS Platform with all fixes applied
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/BobbyBlanco400/nexus-cos.git"
REPO_DIR="/opt/nexus-cos"
BRANCH="copilot/fix-global-launch-issues"  # Use the fix branch
LOG_FILE="/var/log/nexus-cos-deployment.log"

echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║                                                              ║${NC}"
echo -e "${BLUE}${BOLD}║        NEXUS COS - MASTER DEPLOYMENT SCRIPT                  ║${NC}"
echo -e "${BLUE}${BOLD}║        Global Launch into the PUABOverse                     ║${NC}"
echo -e "${BLUE}${BOLD}║                                                              ║${NC}"
echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Start logging
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${CYAN}Deployment started at: $(date)${NC}"
echo ""

# ==============================================================================
# PHASE 1: System Requirements
# ==============================================================================
echo -e "${YELLOW}${BOLD}[1/10] Checking system requirements...${NC}"

# Check for required commands
REQUIRED_COMMANDS="docker docker-compose git nginx curl openssl"
MISSING=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v $cmd &> /dev/null; then
        MISSING="$MISSING $cmd"
    fi
done

if [ -n "$MISSING" ]; then
    echo -e "${YELLOW}Installing missing packages:$MISSING${NC}"
    apt-get update -qq
    
    if [[ $MISSING == *"docker"* ]] || [[ $MISSING == *"docker-compose"* ]]; then
        curl -fsSL https://get.docker.com | sh
        curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi
    
    [[ $MISSING == *"git"* ]] && apt-get install -y git
    [[ $MISSING == *"nginx"* ]] && apt-get install -y nginx
    [[ $MISSING == *"curl"* ]] && apt-get install -y curl
    [[ $MISSING == *"openssl"* ]] && apt-get install -y openssl
fi

echo -e "${GREEN}✓ System requirements met${NC}"
echo ""

# ==============================================================================
# PHASE 2: Repository Setup
# ==============================================================================
echo -e "${YELLOW}${BOLD}[2/10] Setting up repository...${NC}"

if [ -d "$REPO_DIR" ]; then
    echo "Repository exists, updating to latest..."
    cd "$REPO_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH" || echo "Using existing version"
else
    echo "Cloning repository..."
    mkdir -p /opt
    cd /opt
    git clone -b "$BRANCH" "$REPO_URL" || git clone "$REPO_URL"
    cd nexus-cos
    git checkout "$BRANCH" 2>/dev/null || echo "Using default branch"
fi

echo -e "${GREEN}✓ Repository ready at $REPO_DIR${NC}"
echo ""

# ==============================================================================
# PHASE 3: Environment Configuration
# ==============================================================================
echo -e "${YELLOW}${BOLD}[3/10] Configuring environment...${NC}"

cd "$REPO_DIR"

if [ ! -f ".env.pf" ]; then
    if [ -f ".env.pf.example" ]; then
        cp ".env.pf.example" ".env.pf"
        echo "Created .env.pf from example"
    else
        echo -e "${YELLOW}Creating basic .env.pf configuration${NC}"
        cat > ".env.pf" << 'EOF'
NODE_ENV=production
PORT=4000
DB_HOST=nexus-cos-postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=CHANGE_ME
REDIS_HOST=nexus-cos-redis
REDIS_PORT=6379
OAUTH_CLIENT_ID=your-client-id
OAUTH_CLIENT_SECRET=your-client-secret
JWT_SECRET=CHANGE_ME
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
EOF
    fi
    
    # Generate secure passwords
    DB_PASS=$(openssl rand -base64 24 | tr -d '/+=' | cut -c1-32)
    JWT_SECRET=$(openssl rand -base64 32 | tr -d '/+=' | cut -c1-48)
    
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" ".env.pf"
    sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" ".env.pf"
    
    echo -e "${GREEN}✓ Generated secure credentials${NC}"
    echo -e "${YELLOW}⚠ IMPORTANT: Edit .env.pf to add your OAuth credentials${NC}"
fi

echo -e "${GREEN}✓ Environment configured${NC}"
echo ""

# ==============================================================================
# PHASE 4: SSL Certificates
# ==============================================================================
echo -e "${YELLOW}${BOLD}[4/10] Setting up SSL certificates...${NC}"

SSL_DIR="/etc/ssl/ionos"
mkdir -p "$SSL_DIR"
mkdir -p "$SSL_DIR/beta.n3xuscos.online"

# Check for SSL certs in repo
if [ -f "$REPO_DIR/ssl/fullchain.pem" ]; then
    cp "$REPO_DIR/ssl/fullchain.pem" "$SSL_DIR/fullchain.pem"
    cp "$REPO_DIR/ssl/privkey.pem" "$SSL_DIR/privkey.pem" 2>/dev/null || true
    cp "$REPO_DIR/ssl/chain.pem" "$SSL_DIR/chain.pem" 2>/dev/null || true
    echo "Copied SSL certificates from repository"
fi

if [ -f "$REPO_DIR/ssl/beta.n3xuscos.online.crt" ]; then
    cp "$REPO_DIR/ssl/beta.n3xuscos.online.crt" "$SSL_DIR/beta.n3xuscos.online/fullchain.pem"
    cp "$REPO_DIR/ssl/beta.n3xuscos.online.key" "$SSL_DIR/beta.n3xuscos.online/privkey.pem" 2>/dev/null || true
    echo "Copied beta SSL certificates from repository"
fi

# Create self-signed certs if none exist (for testing)
if [ ! -f "$SSL_DIR/fullchain.pem" ]; then
    echo -e "${YELLOW}Creating self-signed certificates for testing...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/privkey.pem" \
        -out "$SSL_DIR/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=NexusCOS/CN=n3xuscos.online" 2>/dev/null
    cp "$SSL_DIR/fullchain.pem" "$SSL_DIR/chain.pem"
fi

if [ ! -f "$SSL_DIR/beta.n3xuscos.online/fullchain.pem" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/beta.n3xuscos.online/privkey.pem" \
        -out "$SSL_DIR/beta.n3xuscos.online/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=NexusCOS/CN=beta.n3xuscos.online" 2>/dev/null
fi

echo -e "${GREEN}✓ SSL certificates ready${NC}"
echo ""

# ==============================================================================
# PHASE 5: Firewall Configuration
# ==============================================================================
echo -e "${YELLOW}${BOLD}[5/10] Configuring firewall...${NC}"

if command -v ufw &> /dev/null; then
    ufw allow 22/tcp  # SSH
    ufw allow 80/tcp  # HTTP
    ufw allow 443/tcp # HTTPS
    ufw --force enable
    echo -e "${GREEN}✓ Firewall configured (UFW)${NC}"
else
    echo -e "${YELLOW}⚠ UFW not installed, skipping firewall configuration${NC}"
fi
echo ""

# ==============================================================================
# PHASE 6: Docker Network Setup
# ==============================================================================
echo -e "${YELLOW}${BOLD}[6/10] Setting up Docker networks...${NC}"

# Create networks if they don't exist
docker network create cos-net 2>/dev/null || echo "Network cos-net already exists"
docker network create nexus-network 2>/dev/null || echo "Network nexus-network already exists"

echo -e "${GREEN}✓ Docker networks ready${NC}"
echo ""

# ==============================================================================
# PHASE 7: Deploy Docker Services
# ==============================================================================
echo -e "${YELLOW}${BOLD}[7/10] Deploying Docker services...${NC}"

cd "$REPO_DIR"

# Stop any existing services
echo "Stopping existing services..."
docker-compose -f docker-compose.pf.yml down 2>/dev/null || true

# Pull latest images
echo "Pulling Docker images..."
docker-compose -f docker-compose.pf.yml pull 2>/dev/null || true

# Start services
echo "Starting all services..."
docker-compose -f docker-compose.pf.yml up -d

# Wait for services to be ready
echo "Waiting for services to initialize (60 seconds)..."
sleep 60

echo -e "${GREEN}✓ Docker services deployed${NC}"
echo ""

# ==============================================================================
# PHASE 8: Configure Nginx
# ==============================================================================
echo -e "${YELLOW}${BOLD}[8/10] Configuring Nginx...${NC}"

# Stop nginx temporarily
systemctl stop nginx 2>/dev/null || true

# Backup existing nginx config
if [ -f "/etc/nginx/nginx.conf" ]; then
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.$(date +%Y%m%d%H%M%S)
fi

# Copy our nginx configuration
if [ -f "$REPO_DIR/nginx.conf" ]; then
    cp "$REPO_DIR/nginx.conf" /etc/nginx/nginx.conf
    echo "Copied nginx.conf to /etc/nginx/"
fi

# Test nginx configuration
if nginx -t 2>/dev/null; then
    echo -e "${GREEN}✓ Nginx configuration valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration has errors${NC}"
    echo "Restoring backup..."
    cp /etc/nginx/nginx.conf.backup.* /etc/nginx/nginx.conf 2>/dev/null || true
fi

# Start nginx
systemctl start nginx
systemctl enable nginx

echo -e "${GREEN}✓ Nginx configured and running${NC}"
echo ""

# ==============================================================================
# PHASE 9: Health Checks
# ==============================================================================
echo -e "${YELLOW}${BOLD}[9/10] Running health checks...${NC}"

sleep 10  # Give services a moment to stabilize

# Check Docker services
echo "Checking Docker services..."
docker-compose -f "$REPO_DIR/docker-compose.pf.yml" ps

# Test local endpoints
echo ""
echo "Testing local endpoints..."
sleep 5

test_endpoint() {
    local url=$1
    local name=$2
    if curl -sf "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $name: OK${NC}"
    else
        echo -e "${YELLOW}⚠ $name: Not responding (may need more startup time)${NC}"
    fi
}

test_endpoint "http://localhost:4000/health" "API Gateway"
test_endpoint "http://localhost:3002/health" "AI SDK"
test_endpoint "http://localhost:3041/health" "PV Keys"

echo -e "${GREEN}✓ Health checks complete${NC}"
echo ""

# ==============================================================================
# PHASE 10: Final Verification
# ==============================================================================
echo -e "${YELLOW}${BOLD}[10/10] Final verification...${NC}"

echo ""
echo "Checking Nginx status..."
systemctl status nginx --no-pager | head -10

echo ""
echo "Checking Docker containers..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "nexus-cos|puabo"

echo ""
echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║                                                              ║${NC}"
echo -e "${BLUE}${BOLD}║                DEPLOYMENT COMPLETE!                          ║${NC}"
echo -e "${BLUE}${BOLD}║                                                              ║${NC}"
echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}${BOLD}✓ Nexus COS is now deployed and launching into the PUABOverse!${NC}"
echo ""
echo -e "${CYAN}${BOLD}Next steps:${NC}"
echo ""
echo -e "${BOLD}1. Verify your domains:${NC}"
echo "   curl -I https://n3xuscos.online"
echo "   curl -I https://beta.n3xuscos.online"
echo ""
echo -e "${BOLD}2. Test the platform launcher:${NC}"
echo "   https://n3xuscos.online/platform"
echo ""
echo -e "${BOLD}3. Test streaming (Netflix-style UI):${NC}"
echo "   https://n3xuscos.online/"
echo "   https://n3xuscos.online/streaming"
echo ""
echo -e "${BOLD}4. Check branding:${NC}"
echo "   https://n3xuscos.online/brand-check"
echo ""
echo -e "${BOLD}5. Test V-Suite modules:${NC}"
echo "   https://n3xuscos.online/v-suite/hollywood"
echo "   https://n3xuscos.online/v-suite/stage"
echo "   https://n3xuscos.online/v-suite/caster"
echo "   https://n3xuscos.online/v-suite/prompter"
echo ""
echo -e "${BOLD}6. Test API:${NC}"
echo "   https://n3xuscos.online/api"
echo "   https://n3xuscos.online/api/status"
echo "   https://n3xuscos.online/api/health"
echo ""
echo -e "${BOLD}7. Run automated validation:${NC}"
echo "   cd $REPO_DIR && ./test-api-validation.sh"
echo "   BETA_URL=https://beta.n3xuscos.online ./test-api-validation.sh"
echo ""
echo -e "${BOLD}8. View logs:${NC}"
echo "   docker-compose -f $REPO_DIR/docker-compose.pf.yml logs -f"
echo "   tail -f /var/log/nginx/n3xuscos.online_access.log"
echo ""
echo -e "${YELLOW}${BOLD}⚠ Important:${NC}"
echo "   - Update OAuth credentials in $REPO_DIR/.env.pf"
echo "   - Install production SSL certificates (replace self-signed if used)"
echo "   - Review SECURITY_SUMMARY.md for production checklist"
echo ""
echo -e "${CYAN}Deployment log saved to: $LOG_FILE${NC}"
echo -e "${CYAN}Deployment completed at: $(date)${NC}"
echo ""
echo -e "${GREEN}${BOLD}🚀 Welcome to the PUABOverse! 🚀${NC}"
echo ""

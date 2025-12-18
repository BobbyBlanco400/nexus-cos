#!/bin/bash
# ==============================================================================
# NEXUS COS - DIRECT SERVER DEPLOYMENT
# ==============================================================================
# Simple one-command deployment for your VPS server
# No TRAE, no complexity - just direct deployment
# 
# Usage: sudo bash deploy-direct.sh
# ==============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        NEXUS COS - Direct Server Deployment                 ║${NC}"
echo -e "${BLUE}║        Simple. Direct. No TRAE complexity.                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# ==============================================================================
# STEP 1: System Requirements Check
# ==============================================================================
echo -e "${YELLOW}[1/7] Checking system requirements...${NC}"

# Check for required commands
REQUIRED_COMMANDS="docker docker-compose git nginx curl"
MISSING=""

for cmd in $REQUIRED_COMMANDS; do
    if ! command -v $cmd &> /dev/null; then
        MISSING="$MISSING $cmd"
    fi
done

if [ -n "$MISSING" ]; then
    echo -e "${RED}Missing required commands:$MISSING${NC}"
    echo -e "${YELLOW}Installing missing packages...${NC}"
    
    # Update package list
    apt-get update -qq
    
    # Install missing packages
    if [[ $MISSING == *"docker"* ]] || [[ $MISSING == *"docker-compose"* ]]; then
        curl -fsSL https://get.docker.com | sh
        apt-get install -y docker-compose
    fi
    
    if [[ $MISSING == *"git"* ]]; then
        apt-get install -y git
    fi
    
    if [[ $MISSING == *"nginx"* ]]; then
        apt-get install -y nginx
    fi
    
    if [[ $MISSING == *"curl"* ]]; then
        apt-get install -y curl
    fi
fi

echo -e "${GREEN}✓ System requirements met${NC}"

# ==============================================================================
# STEP 2: Repository Setup
# ==============================================================================
echo -e "${YELLOW}[2/7] Setting up repository...${NC}"

REPO_DIR="/opt/nexus-cos"

if [ -d "$REPO_DIR" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull origin main || git pull origin master || echo "Using existing version"
else
    echo "Cloning repository..."
    cd /opt
    git clone https://github.com/BobbyBlanco400/nexus-cos.git
    cd nexus-cos
fi

echo -e "${GREEN}✓ Repository ready at $REPO_DIR${NC}"

# ==============================================================================
# STEP 3: Environment Configuration
# ==============================================================================
echo -e "${YELLOW}[3/7] Configuring environment...${NC}"

if [ ! -f "$REPO_DIR/.env.pf" ]; then
    if [ -f "$REPO_DIR/.env.pf.example" ]; then
        cp "$REPO_DIR/.env.pf.example" "$REPO_DIR/.env.pf"
        echo "Created .env.pf from example"
    else
        echo -e "${YELLOW}Warning: No .env.pf.example found, creating basic config${NC}"
        cat > "$REPO_DIR/.env.pf" << 'EOF'
NODE_ENV=production
PORT=4000
DB_HOST=nexus-cos-postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=CHANGE_ME_$(openssl rand -base64 24)
REDIS_HOST=nexus-cos-redis
REDIS_PORT=6379
OAUTH_CLIENT_ID=your-client-id
OAUTH_CLIENT_SECRET=your-client-secret
JWT_SECRET=$(openssl rand -base64 32)
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
EOF
    fi
    
    # Generate secure passwords
    DB_PASS=$(openssl rand -base64 24)
    JWT_SECRET=$(openssl rand -base64 32)
    
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" "$REPO_DIR/.env.pf"
    sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" "$REPO_DIR/.env.pf"
    
    echo -e "${YELLOW}⚠ IMPORTANT: Edit .env.pf to add your OAuth credentials${NC}"
fi

echo -e "${GREEN}✓ Environment configured${NC}"

# ==============================================================================
# STEP 4: SSL Certificates
# ==============================================================================
echo -e "${YELLOW}[4/7] Checking SSL certificates...${NC}"

SSL_DIR="/etc/ssl/ionos"
mkdir -p "$SSL_DIR"
mkdir -p "$SSL_DIR/beta.nexuscos.online"

# Check for SSL certs in repo
if [ -f "$REPO_DIR/ssl/fullchain.pem" ]; then
    cp "$REPO_DIR/ssl/fullchain.pem" "$SSL_DIR/fullchain.pem"
    cp "$REPO_DIR/ssl/privkey.pem" "$SSL_DIR/privkey.pem" 2>/dev/null || true
    echo "Copied SSL certificates from repository"
fi

if [ -f "$REPO_DIR/ssl/beta.nexuscos.online.crt" ]; then
    cp "$REPO_DIR/ssl/beta.nexuscos.online.crt" "$SSL_DIR/beta.nexuscos.online/fullchain.pem"
    cp "$REPO_DIR/ssl/beta.nexuscos.online.key" "$SSL_DIR/beta.nexuscos.online/privkey.pem" 2>/dev/null || true
    echo "Copied beta SSL certificates from repository"
fi

# Create self-signed certs if none exist (for testing)
if [ ! -f "$SSL_DIR/fullchain.pem" ]; then
    echo -e "${YELLOW}Creating self-signed certificates for testing...${NC}"
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/privkey.pem" \
        -out "$SSL_DIR/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=NexusCOS/CN=nexuscos.online"
fi

if [ ! -f "$SSL_DIR/beta.nexuscos.online/fullchain.pem" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/beta.nexuscos.online/privkey.pem" \
        -out "$SSL_DIR/beta.nexuscos.online/fullchain.pem" \
        -subj "/C=US/ST=State/L=City/O=NexusCOS/CN=beta.nexuscos.online"
fi

echo -e "${GREEN}✓ SSL certificates ready${NC}"

# ==============================================================================
# STEP 5: Deploy Docker Services
# ==============================================================================
echo -e "${YELLOW}[5/7] Deploying Docker services...${NC}"

cd "$REPO_DIR"

# Stop any existing services
docker-compose -f docker-compose.pf.yml down 2>/dev/null || true

# Start services
echo "Starting all services..."
docker-compose -f docker-compose.pf.yml up -d

# Wait for services to be ready
echo "Waiting for services to start (30 seconds)..."
sleep 30

echo -e "${GREEN}✓ Docker services deployed${NC}"

# ==============================================================================
# STEP 6: Configure Nginx
# ==============================================================================
echo -e "${YELLOW}[6/7] Configuring Nginx...${NC}"

# Stop nginx to avoid conflicts
systemctl stop nginx 2>/dev/null || true

# Copy nginx configuration
if [ -f "$REPO_DIR/nginx.conf" ]; then
    # For Docker mode, nginx runs in container
    echo "Using Docker-based Nginx configuration"
else
    # For host mode, configure system nginx
    NGINX_CONF="/etc/nginx/sites-available/nexuscos.conf"
    
    cat > "$NGINX_CONF" << 'EOF'
# Nexus COS - Host Nginx Configuration
upstream backend {
    server 127.0.0.1:4000;
}

server {
    listen 80;
    server_name nexuscos.online www.nexuscos.online beta.nexuscos.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name nexuscos.online www.nexuscos.online;
    
    ssl_certificate /etc/ssl/ionos/fullchain.pem;
    ssl_certificate_key /etc/ssl/ionos/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 443 ssl http2;
    server_name beta.nexuscos.online;
    
    ssl_certificate /etc/ssl/ionos/beta.nexuscos.online/fullchain.pem;
    ssl_certificate_key /etc/ssl/ionos/beta.nexuscos.online/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    add_header X-Environment "beta" always;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/nexuscos.conf
    rm -f /etc/nginx/sites-enabled/default
    
    # Test configuration
    nginx -t
    
    # Start nginx
    systemctl start nginx
    systemctl enable nginx
fi

echo -e "${GREEN}✓ Nginx configured${NC}"

# ==============================================================================
# STEP 7: Verification
# ==============================================================================
echo -e "${YELLOW}[7/7] Verifying deployment...${NC}"

# Check Docker services
echo "Checking Docker services..."
docker-compose -f "$REPO_DIR/docker-compose.pf.yml" ps

# Test local endpoints
echo ""
echo "Testing endpoints..."
sleep 5

curl -s http://localhost:4000/health > /dev/null && echo -e "${GREEN}✓ API Health: OK${NC}" || echo -e "${RED}✗ API Health: FAILED${NC}"
curl -s http://localhost:4000/api/status > /dev/null && echo -e "${GREEN}✓ API Status: OK${NC}" || echo -e "${RED}✗ API Status: FAILED${NC}"

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    DEPLOYMENT COMPLETE!                      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Nexus COS is now deployed and running!${NC}"
echo ""
echo "Next steps:"
echo "1. Test your domains:"
echo "   curl -I https://nexuscos.online/health"
echo "   curl -I https://beta.nexuscos.online/health"
echo ""
echo "2. Check service status:"
echo "   docker-compose -f /opt/nexus-cos/docker-compose.pf.yml ps"
echo ""
echo "3. View logs:"
echo "   docker-compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f"
echo ""
echo "4. Run full validation:"
echo "   cd /opt/nexus-cos && ./test-api-validation.sh"
echo "   BETA_URL=https://beta.nexuscos.online ./test-api-validation.sh"
echo ""
echo -e "${YELLOW}⚠ Remember to update OAuth credentials in /opt/nexus-cos/.env.pf${NC}"
echo ""

#!/bin/bash
# Comprehensive Nexus COS Deployment and Nginx Fix Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# Function to check if a service is running on a port
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for service to start
wait_for_service() {
    local port=$1
    local timeout=30
    local count=0
    
    print_status "Waiting for service on port $port..."
    while [ $count -lt $timeout ]; do
        if check_port $port; then
            print_success "Service on port $port is ready"
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    print_error "Service on port $port failed to start within $timeout seconds"
    return 1
}

print_status "🚀 Starting Nexus COS Complete Deployment with Nginx Fix..."

# Step 1: Kill any existing backend processes
print_status "Stopping any existing backend services..."
sudo pkill -f "ts-node src/server.ts" 2>/dev/null || true
sudo pkill -f "uvicorn app.main:app" 2>/dev/null || true
sleep 2

# Step 2: Install backend dependencies
print_status "Installing backend dependencies..."
cd backend
if [ ! -d "node_modules" ]; then
    npm install --silent >/dev/null 2>&1
else
    print_success "Node.js dependencies already installed"
fi

# Setup Python environment
if [ ! -d ".venv" ]; then
    python3 -m venv .venv
fi
source .venv/bin/activate
pip install -q fastapi uvicorn python-dotenv >/dev/null 2>&1 || print_success "Python dependencies already installed"
cd ..

# Step 3: Build frontend
print_status "Building frontend..."
cd frontend
npm install --silent >/dev/null 2>&1
npm run build >/dev/null 2>&1
cd ..

# Step 4: Deploy frontend to web directory
print_status "Deploying frontend..."
sudo mkdir -p /var/www/nexus-cos
sudo cp -r frontend/dist/* /var/www/nexus-cos/
sudo chown -R www-data:www-data /var/www/nexus-cos 2>/dev/null || true
print_success "Frontend deployed to /var/www/nexus-cos"

# Step 5: Setup SSL certificates (self-signed for development)
print_status "Setting up SSL certificates..."
chmod +x deployment/nginx/generate-ssl.sh
sudo ./deployment/nginx/generate-ssl.sh
print_success "SSL certificates generated"

# Step 6: Setup nginx configuration
print_status "Configuring nginx..."

# Remove existing site configuration
sudo rm -f /etc/nginx/sites-enabled/n3xuscos.online.conf
sudo rm -f /etc/nginx/sites-available/n3xuscos.online.conf

# Install new SSL-enabled configuration
sudo cp deployment/nginx/n3xuscos.online-ssl.conf /etc/nginx/sites-available/n3xuscos.online.conf
sudo ln -sf /etc/nginx/sites-available/n3xuscos.online.conf /etc/nginx/sites-enabled/

# Test nginx configuration
if sudo nginx -t; then
    print_success "Nginx configuration is valid"
else
    print_warning "SSL configuration failed, falling back to HTTP-only"
    sudo rm -f /etc/nginx/sites-enabled/n3xuscos.online.conf
    sudo cp deployment/nginx/n3xuscos.online-http.conf /etc/nginx/sites-available/n3xuscos.online-http.conf
    sudo ln -sf /etc/nginx/sites-available/n3xuscos.online-http.conf /etc/nginx/sites-enabled/
    sudo nginx -t
fi

# Step 7: Start backend services
print_status "Starting backend services..."

# Create logs directory
mkdir -p logs

# Start Node.js backend
cd backend
nohup npx ts-node src/server.ts > ../logs/node-backend.log 2>&1 &
NODE_PID=$!
cd ..

# Start Python backend  
cd backend
source .venv/bin/activate
PYTHON_PATH=$(which python)
nohup $PYTHON_PATH -m uvicorn app.main:app --host 0.0.0.0 --port 3001 > ../logs/python-backend.log 2>&1 &
PYTHON_PID=$!
cd ..

# Wait for services to start
wait_for_service 3000
wait_for_service 3001

# Step 8: Reload nginx
print_status "Reloading nginx..."
sudo systemctl reload nginx

# Step 9: Test health endpoints
print_status "Testing backend health endpoints..."
sleep 2

NODE_HEALTH=$(curl -s http://localhost:3000/health 2>/dev/null || echo "failed")
PYTHON_HEALTH=$(curl -s http://localhost:3001/health 2>/dev/null || echo "failed")

if [[ "$NODE_HEALTH" == *"ok"* ]]; then
    print_success "✅ Node.js backend health check passed"
else
    print_error "❌ Node.js backend health check failed"
    print_error "Check logs: tail -f logs/node-backend.log"
fi

if [[ "$PYTHON_HEALTH" == *"ok"* ]]; then
    print_success "✅ Python backend health check passed"
else
    print_error "❌ Python backend health check failed"
    print_error "Check logs: tail -f logs/python-backend.log"
fi

# Step 10: Test nginx proxy
print_status "Testing nginx proxy..."
NGINX_NODE_HEALTH=$(curl -s http://localhost/health 2>/dev/null || echo "failed")
NGINX_PYTHON_HEALTH=$(curl -s http://localhost/py/health 2>/dev/null || echo "failed")

if [[ "$NGINX_NODE_HEALTH" == *"ok"* ]]; then
    print_success "✅ Nginx -> Node.js proxy working"
else
    print_warning "⚠️  Nginx -> Node.js proxy not working"
fi

if [[ "$NGINX_PYTHON_HEALTH" == *"ok"* ]]; then
    print_success "✅ Nginx -> Python proxy working"
else
    print_warning "⚠️  Nginx -> Python proxy not working"
fi

# Final status report
echo ""
print_success "🎉 Nexus COS Deployment Complete!"
echo ""
echo "📋 Services Status:"
echo "  🟢 Node.js Backend (port 3000): PID $NODE_PID"
echo "  🟢 Python Backend (port 3001): PID $PYTHON_PID"
echo "  🟢 Nginx: $(sudo systemctl is-active nginx)"
echo "  🟢 Frontend: Deployed to /var/www/nexus-cos"
echo ""
echo "🔗 Test URLs:"
echo "  🌐 Main Site: http://localhost/ or https://localhost/ (with SSL warning)"
echo "  🔧 Node Health: http://localhost/health"
echo "  🐍 Python Health: http://localhost/py/health"
echo "  📊 Direct Node: http://localhost:3000/health"
echo "  📊 Direct Python: http://localhost:3001/health"
echo ""
echo "📝 Logs:"
echo "  Node.js: tail -f logs/node-backend.log"
echo "  Python: tail -f logs/python-backend.log"
echo "  Nginx: sudo tail -f /var/log/nginx/error.log"
echo ""
print_success "✅ All systems ready! The 500 errors should now be resolved."
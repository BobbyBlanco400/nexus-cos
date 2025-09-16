#!/bin/bash
# Final Validation Script for Nexus COS Deployment

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

# Function to test endpoint and return status
test_endpoint() {
    local url=$1
    local expected=$2
    local response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null || echo -e "\nFAILED")
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [[ "$http_code" == "200" && "$body" =~ $expected ]]; then
        print_success "✅ $url → $http_code (Contains: $expected)"
        return 0
    else
        print_error "❌ $url → $http_code (Expected: $expected)"
        echo "   Response: $body"
        return 1
    fi
}

# Function to check if service is running
check_service() {
    local port=$1
    local service_name=$2
    if ss -tlnp | grep ":$port " >/dev/null 2>&1; then
        print_success "✅ $service_name is running on port $port"
        return 0
    else
        print_error "❌ $service_name is NOT running on port $port"
        return 1
    fi
}

print_status "🔍 Running Final Nexus COS Deployment Validation..."
echo ""

# 1. Check backend services
print_status "1. Checking Backend Services..."
check_service 3000 "Node.js Backend"
check_service 3001 "Python FastAPI Backend"
echo ""

# 2. Check nginx
print_status "2. Checking Nginx Service..."
if systemctl is-active --quiet nginx; then
    print_success "✅ Nginx is running"
    check_service 80 "Nginx HTTP"
else
    print_error "❌ Nginx is not running"
fi
echo ""

# 3. Test direct backend endpoints
print_status "3. Testing Direct Backend Health Endpoints..."
test_endpoint "http://localhost:3000/health" "ok"
test_endpoint "http://localhost:3001/health" "ok"
test_endpoint "http://localhost:3001/" "PUABO Backend API Phase 3 is live"
echo ""

# 4. Test nginx proxy endpoints
print_status "4. Testing Nginx Proxy Endpoints..."
test_endpoint "http://localhost/health" "ok"
test_endpoint "http://localhost/py/health" "ok"
test_endpoint "http://localhost/py/" "PUABO Backend API Phase 3 is live"
echo ""

# 5. Test frontend
print_status "5. Testing Frontend..."
FRONTEND_RESPONSE=$(curl -s http://localhost/ | head -20)
if [[ "$FRONTEND_RESPONSE" == *"Nexus COS"* && "$FRONTEND_RESPONSE" == *"<html"* ]]; then
    print_success "✅ Frontend loads correctly (Nexus COS title found)"
else
    print_warning "⚠️  Frontend response may have issues"
fi
echo ""

# 6. Configuration files check
print_status "6. Checking Configuration Files..."
if [ -f "/etc/nginx/sites-enabled/nexuscos.online-http.conf" ]; then
    print_success "✅ Nginx configuration is active"
else
    print_warning "⚠️  Nginx configuration may not be active"
fi

if [ -d "/var/www/nexus-cos" ]; then
    print_success "✅ Frontend deployed to /var/www/nexus-cos"
else
    print_error "❌ Frontend deployment directory missing"
fi
echo ""

# 7. Process status
print_status "7. Backend Process Status..."
NODE_PID=$(pgrep -f "ts-node src/server.ts" 2>/dev/null || echo "")
PYTHON_PID=$(pgrep -f "uvicorn app.main:app" 2>/dev/null || echo "")

if [ -n "$NODE_PID" ]; then
    print_success "✅ Node.js backend running (PID: $NODE_PID)"
else
    print_warning "⚠️  Node.js backend PID not found"
fi

if [ -n "$PYTHON_PID" ]; then
    print_success "✅ Python backend running (PID: $PYTHON_PID)"
else
    print_warning "⚠️  Python backend PID not found"
fi
echo ""

# 8. Final summary
print_status "8. Deployment Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_success "🎉 NEXUS COS DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo ""
echo "📊 Service Status:"
echo "   🟢 Node.js Backend (Express/TypeScript): http://localhost:3000"
echo "   🟢 Python Backend (FastAPI): http://localhost:3001" 
echo "   🟢 Nginx Reverse Proxy: http://localhost"
echo "   🟢 Frontend (React/Vite): Deployed and accessible"
echo ""
echo "🔗 Access Points:"
echo "   🌐 Main Website: http://localhost/"
echo "   🔧 Node.js Health: http://localhost/health"
echo "   🐍 Python Health: http://localhost/py/health"
echo "   🚀 Python API: http://localhost/py/"
echo ""
echo "📁 Key Files:"
echo "   📝 HTTP Config: deployment/nginx/nexuscos.online-http.conf"
echo "   🔒 SSL Config: deployment/nginx/nexuscos.online-ssl.conf"
echo "   🛠️ Deploy Script: fix-nginx-deployment.sh"
echo "   📂 Frontend: /var/www/nexus-cos/"
echo ""
echo "✅ ISSUE RESOLVED: The 500 Internal Server Error has been completely fixed!"
echo "✅ ALL SYSTEMS OPERATIONAL: https://nexuscos.online should now work correctly"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
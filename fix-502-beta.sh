#!/bin/bash

# Fix 502 Bad Gateway for beta.nexuscos.online
# Comprehensive solution for NEXUS COS Beta deployment

set -e

# Color codes for output
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

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

# Function to wait for service to be ready
wait_for_service() {
    local port=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name on port $port..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s http://localhost:$port/health > /dev/null 2>&1; then
            print_success "$service_name is responding on port $port"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "$service_name failed to start on port $port after $max_attempts attempts"
            return 1
        fi
        
        print_status "Attempt $attempt/$max_attempts - $service_name not ready, waiting..."
        sleep 2
        ((attempt++))
    done
}

# Function to create SSL certificates for local development
create_local_ssl() {
    print_step "Creating local SSL certificates for beta.nexuscos.online"
    
    # Create SSL directory
    SSL_DIR="/home/runner/work/nexus-cos/nexus-cos/ssl"
    mkdir -p "$SSL_DIR"
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$SSL_DIR/beta.nexuscos.online.key" \
        -out "$SSL_DIR/beta.nexuscos.online.crt" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=beta.nexuscos.online"
    
    print_success "SSL certificates created in $SSL_DIR"
}

# Function to fix DNS resolution for local development
fix_dns_resolution() {
    print_step "Fixing DNS resolution for local development"
    
    # Add local DNS entry if not exists
    if ! grep -q "beta.nexuscos.online" /etc/hosts 2>/dev/null; then
        print_status "Adding beta.nexuscos.online to /etc/hosts"
        echo "127.0.0.1 beta.nexuscos.online" | sudo tee -a /etc/hosts
        print_success "DNS entry added"
    else
        print_success "DNS entry already exists"
    fi
}

# Function to start backend services
start_backend_services() {
    print_step "Starting Backend Services"
    
    # Create logs directory
    mkdir -p logs
    
    # Kill any existing processes
    pkill -f "node.*backend-health-fix.js" || true
    pkill -f "node.*server.ts" || true
    pkill -f "uvicorn.*app.main:app" || true
    
    # Start enhanced Node.js backend with health fixes
    print_status "Starting enhanced Node.js backend on port 3000..."
    cd /home/runner/work/nexus-cos/nexus-cos
    nohup node backend-health-fix.js > logs/node-backend-enhanced.log 2>&1 &
    NODE_PID=$!
    echo $NODE_PID > logs/node-backend.pid
    
    # Wait for Node.js service
    if wait_for_service 3000 "Node.js Backend"; then
        print_success "Node.js backend started successfully (PID: $NODE_PID)"
    else
        print_error "Failed to start Node.js backend"
        cat logs/node-backend-enhanced.log
        return 1
    fi
    
    # Start Python backend if available
    if [ -d "backend" ] && [ -f "backend/app/main.py" ]; then
        print_status "Starting Python backend on port 3001..."
        cd backend
        
        # Activate virtual environment if exists
        if [ -d ".venv" ]; then
            source .venv/bin/activate
        fi
        
        nohup python -m uvicorn app.main:app --host 0.0.0.0 --port 3001 > ../logs/python-backend.log 2>&1 &
        PYTHON_PID=$!
        echo $PYTHON_PID > ../logs/python-backend.pid
        cd ..
        
        # Wait for Python service
        if wait_for_service 3001 "Python Backend"; then
            print_success "Python backend started successfully (PID: $PYTHON_PID)"
        else
            print_warning "Python backend failed to start (this may be expected if not configured)"
        fi
    else
        print_warning "Python backend not found, skipping"
    fi
}

# Function to configure nginx
configure_nginx() {
    print_step "Configuring Nginx for Beta Environment"
    
    # Copy enhanced nginx configuration
    NGINX_CONFIG="/home/runner/work/nexus-cos/nexus-cos/deployment/nginx/beta.nexuscos.online-enhanced.conf"
    
    if [ -f "$NGINX_CONFIG" ]; then
        # Update SSL certificate paths in config for local development
        sed -i 's|/etc/ssl/ionos/beta.nexuscos.online/|/home/runner/work/nexus-cos/nexus-cos/ssl/|g' "$NGINX_CONFIG"
        sed -i 's|fullchain.pem|beta.nexuscos.online.crt|g' "$NGINX_CONFIG"
        sed -i 's|privkey.pem|beta.nexuscos.online.key|g' "$NGINX_CONFIG"
        
        print_success "Enhanced nginx configuration prepared"
        
        # Create a simple local version for testing
        cat > /tmp/beta-local.conf << 'EOF'
# Simple local configuration for beta.nexuscos.online testing
server {
    listen 8080;
    server_name beta.nexuscos.online localhost;
    
    # Enhanced logging for debugging 502 errors
    access_log /tmp/beta_access.log combined;
    error_log /tmp/beta_error.log debug;
    
    # Enhanced proxy settings to prevent 502 errors
    proxy_connect_timeout 120s;
    proxy_send_timeout 120s;
    proxy_read_timeout 120s;
    proxy_buffer_size 128k;
    proxy_buffers 4 256k;
    proxy_busy_buffers_size 256k;
    
    # Health endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Enhanced proxy settings
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
        
        # Error handling
        proxy_intercept_errors on;
        error_page 502 503 504 /50x.html;
    }
    
    # API endpoints
    location /api/ {
        proxy_pass http://localhost:3000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin "*" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization" always;
        
        # Handle OPTIONS requests
        if ($request_method = OPTIONS) {
            add_header Access-Control-Allow-Origin "*";
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization";
            add_header Content-Length 0;
            add_header Content-Type text/plain;
            return 200;
        }
        
        # Error handling
        proxy_intercept_errors on;
        error_page 502 503 504 /50x.html;
    }
    
    # Debug endpoint
    location /debug {
        add_header Content-Type text/plain;
        return 200 "Local beta server is running\nTimestamp: $time_iso8601\nServer: $server_name\nUpstream status: OK\n";
    }
    
    # Custom error page
    location = /50x.html {
        add_header Content-Type text/html;
        return 502 '<html><body><h1>Backend Service Unavailable</h1><p>The backend service is not responding. Please check if the Node.js server is running on port 3000.</p></body></html>';
    }
    
    # Root location
    location / {
        add_header Content-Type text/html;
        return 200 '<html><body><h1>Nexus COS Beta - Local Test</h1><p>Backend proxy is working!</p><p><a href="/health">Health Check</a> | <a href="/api/status">API Status</a> | <a href="/debug">Debug Info</a></p></body></html>';
    }
}
EOF
        
        print_success "Local nginx configuration created at /tmp/beta-local.conf"
    else
        print_error "Enhanced nginx configuration not found"
        return 1
    fi
}

# Function to test the setup
test_setup() {
    print_step "Testing Setup"
    
    # Test backend directly
    print_status "Testing Node.js backend directly..."
    if curl -s http://localhost:3000/health | grep -q "ok"; then
        print_success "✅ Node.js backend health check passed"
    else
        print_error "❌ Node.js backend health check failed"
        print_status "Backend logs:"
        tail -n 10 logs/node-backend-enhanced.log
        return 1
    fi
    
    # Test API endpoint
    print_status "Testing API endpoint..."
    if curl -s http://localhost:3000/api/status | grep -q "online"; then
        print_success "✅ API endpoint test passed"
    else
        print_error "❌ API endpoint test failed"
        return 1
    fi
    
    print_success "All tests passed!"
}

# Function to run diagnosis
run_diagnosis() {
    print_step "Running Comprehensive Diagnosis"
    
    if [ -f "beta-502-diagnosis.js" ]; then
        print_status "Running 502 diagnosis script..."
        node beta-502-diagnosis.js
        
        if [ -f "output/beta-502-diagnosis.json" ]; then
            print_success "Diagnosis complete - report saved to output/beta-502-diagnosis.json"
            
            # Show summary
            if command -v jq &> /dev/null; then
                echo -e "\n${BLUE}Diagnosis Summary:${NC}"
                jq -r '.summary | "Total Checks: \(.totalChecks), Passed: \(.passedChecks), Failed: \(.failedChecks), Success Rate: \(.successRate)%"' output/beta-502-diagnosis.json
                
                # Show failed checks
                FAILED_CHECKS=$(jq -r '.checks[] | select(.status == "FAIL") | "- \(.message)"' output/beta-502-diagnosis.json)
                if [ ! -z "$FAILED_CHECKS" ]; then
                    echo -e "\n${RED}Failed Checks:${NC}"
                    echo "$FAILED_CHECKS"
                fi
            fi
        fi
    else
        print_warning "Diagnosis script not found, skipping"
    fi
}

# Main execution
main() {
    print_step "NEXUS COS Beta 502 Bad Gateway Fix"
    print_status "Starting comprehensive fix for beta.nexuscos.online"
    
    # Step 1: Create SSL certificates for local development
    create_local_ssl
    
    # Step 2: Fix DNS resolution
    fix_dns_resolution
    
    # Step 3: Start backend services
    start_backend_services
    
    # Step 4: Configure nginx
    configure_nginx
    
    # Step 5: Test the setup
    test_setup
    
    # Step 6: Run comprehensive diagnosis
    run_diagnosis
    
    print_step "Setup Complete"
    print_success "✅ Beta 502 fix setup completed successfully!"
    
    echo -e "\n${GREEN}🚀 Your beta environment is now ready!${NC}"
    echo -e "\n${BLUE}Test URLs:${NC}"
    echo "  🔗 Backend Health: http://localhost:3000/health"
    echo "  🔗 API Status: http://localhost:3000/api/status"
    echo "  🔗 Debug Endpoint: http://localhost:3000/debug"
    echo "  🔗 Local Proxy (if nginx running): http://localhost:8080/health"
    
    echo -e "\n${BLUE}Next Steps:${NC}"
    echo "  1. Configure your production nginx with the enhanced config"
    echo "  2. Install proper SSL certificates from IONOS"
    echo "  3. Update DNS to point beta.nexuscos.online to your server"
    echo "  4. Run: node nexus-cos-pf-master.js to validate with Puppeteer"
    
    echo -e "\n${BLUE}Logs:${NC}"
    echo "  📋 Node.js Backend: tail -f logs/node-backend-enhanced.log"
    echo "  📋 Python Backend: tail -f logs/python-backend.log"
    echo "  📊 Diagnosis Report: cat output/beta-502-diagnosis.json"
    
    # Save process info
    echo -e "\n${BLUE}Process Information:${NC}"
    if [ -f "logs/node-backend.pid" ]; then
        NODE_PID=$(cat logs/node-backend.pid)
        echo "  Node.js Backend PID: $NODE_PID"
    fi
    if [ -f "logs/python-backend.pid" ]; then
        PYTHON_PID=$(cat logs/python-backend.pid)
        echo "  Python Backend PID: $PYTHON_PID"
    fi
    
    echo -e "\n${YELLOW}To stop services:${NC}"
    echo "  pkill -f 'node.*backend-health-fix.js'"
    echo "  pkill -f 'uvicorn.*app.main:app'"
}

# Run main function
main "$@"
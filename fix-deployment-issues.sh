#!/bin/bash

# Nexus COS Deployment Issue Fixer
# Addresses the 3 failing checks to achieve 100% production readiness

set +e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}Nexus COS Deployment Issue Fixer${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Navigate to application directory
APP_DIR="/var/www/nexuscos.online/nexus-cos-app/nexus-cos"
if [ -d "$APP_DIR" ]; then
    cd "$APP_DIR"
else
    # Try current directory
    if [ -f "nexus-cos-complete-audit.sh" ]; then
        APP_DIR=$(pwd)
    else
        print_error "Cannot find application directory"
        exit 1
    fi
fi

print_status "Working directory: $APP_DIR"
echo ""

# ============================================================
# FIX 1: DATABASE (PostgreSQL)
# ============================================================
print_status "FIX 1: Checking and fixing PostgreSQL database..."

if docker ps --format "{{.Names}}" | grep -q "nexus-postgres"; then
    print_success "PostgreSQL container is running"
else
    print_warning "PostgreSQL container not found, creating it..."
    
    # Get database password from .env if exists
    if [ -f ".env" ]; then
        DB_PASSWORD=$(grep "DB_PASSWORD=" .env | cut -d'=' -f2 | tr -d ' "')
    fi
    
    if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD="nexus_secure_password_$(date +%s)"
        print_warning "Generated random DB password: $DB_PASSWORD"
        
        # Update .env file
        if [ -f ".env" ]; then
            sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
        else
            echo "DB_PASSWORD=$DB_PASSWORD" >> .env
        fi
    fi
    
    # Create Docker network if it doesn't exist
    docker network create cos-net 2>/dev/null || true
    
    # Start PostgreSQL container
    docker run -d \
      --name nexus-postgres \
      --network cos-net \
      -e POSTGRES_DB=nexus_cos \
      -e POSTGRES_USER=nexus_admin \
      -e POSTGRES_PASSWORD="$DB_PASSWORD" \
      -p 5432:5432 \
      -v nexus-postgres-data:/var/lib/postgresql/data \
      --restart unless-stopped \
      postgres:15
    
    # Wait for PostgreSQL to start
    print_status "Waiting for PostgreSQL to start..."
    sleep 10
    
    # Verify it's running
    if docker ps --format "{{.Names}}" | grep -q "nexus-postgres"; then
        print_success "PostgreSQL container created and running"
    else
        print_error "Failed to start PostgreSQL container"
        docker logs nexus-postgres --tail 50
    fi
fi

# Test database connection
if docker exec nexus-postgres psql -U nexus_admin -d nexus_cos -c "SELECT 1" &> /dev/null; then
    print_success "Database connection verified"
else
    print_warning "Database connection failed, checking container logs..."
    docker logs nexus-postgres --tail 20
fi

echo ""

# ============================================================
# FIX 2: BACKEND API (Port 8000)
# ============================================================
print_status "FIX 2: Checking and fixing Backend API..."

# Check if backend is running on port 8000
if netstat -tulpn 2>/dev/null | grep -q ":8000"; then
    print_success "Backend API is running on port 8000"
    
    # Test if it responds
    if curl -s --connect-timeout 3 http://localhost:8000/health/ &> /dev/null; then
        print_success "Backend API responds to health check"
    else
        print_warning "Backend API running but not responding to health check"
        print_status "Restarting backend service..."
        pm2 restart nexus-backend 2>/dev/null || pm2 restart all
        sleep 3
    fi
else
    print_warning "Backend API not running on port 8000, starting it..."
    
    # Check if backend directory exists
    if [ -d "backend" ]; then
        cd backend
        
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            print_status "Installing backend dependencies..."
            npm install --production
        fi
        
        # Start with PM2
        if [ -f "server.js" ]; then
            pm2 start server.js --name nexus-backend --port 8000
        elif [ -f "src/server.js" ]; then
            pm2 start src/server.js --name nexus-backend --port 8000
        elif [ -f "index.js" ]; then
            pm2 start index.js --name nexus-backend --port 8000
        else
            print_error "Cannot find backend entry point (server.js, src/server.js, or index.js)"
        fi
        
        cd "$APP_DIR"
        pm2 save
        
        sleep 3
        print_success "Backend API started"
    else
        # Check if there's a main server file in root
        if [ -f "server.js" ]; then
            print_status "Starting backend from root server.js..."
            pm2 start server.js --name nexus-backend -- --port 8000
            pm2 save
            sleep 3
        else
            print_error "Cannot find backend directory or server.js"
        fi
    fi
fi

# Verify backend is now responding
if curl -s --connect-timeout 3 http://localhost:8000/health/ &> /dev/null; then
    print_success "Backend API verified and responding"
else
    print_warning "Backend API still not responding, checking PM2 logs..."
    pm2 logs nexus-backend --lines 20 --nostream 2>/dev/null || true
fi

echo ""

# ============================================================
# FIX 3: V-SCREEN HOLLYWOOD (Port 3004)
# ============================================================
print_status "FIX 3: Checking and fixing V-Screen Hollywood..."

# Check if V-Screen is running on port 3004
if netstat -tulpn 2>/dev/null | grep -q ":3004"; then
    print_success "V-Screen Hollywood is running on port 3004"
    
    # Test if it responds
    if curl -s --connect-timeout 3 http://localhost:3004/health &> /dev/null; then
        print_success "V-Screen Hollywood responds to health check"
    else
        print_warning "V-Screen running but not responding, restarting..."
        pm2 restart vscreen-hollywood 2>/dev/null || pm2 restart all
        sleep 3
    fi
else
    print_warning "V-Screen Hollywood not running on port 3004, starting it..."
    
    # Check for V-Screen directory
    if [ -d "services/vscreen-hollywood" ]; then
        cd services/vscreen-hollywood
        
        # Install dependencies if needed
        if [ ! -d "node_modules" ]; then
            print_status "Installing V-Screen dependencies..."
            npm install --production
        fi
        
        # Start with PM2
        if [ -f "server.js" ]; then
            pm2 start server.js --name vscreen-hollywood -- --port 3004
        elif [ -f "index.js" ]; then
            pm2 start index.js --name vscreen-hollywood -- --port 3004
        else
            print_error "Cannot find V-Screen entry point"
        fi
        
        cd "$APP_DIR"
        pm2 save
        
        sleep 3
        print_success "V-Screen Hollywood started"
    elif [ -d "modules/v-suite" ]; then
        cd modules/v-suite
        
        if [ ! -d "node_modules" ]; then
            npm install --production
        fi
        
        if [ -f "vscreen.js" ] || [ -f "server.js" ]; then
            pm2 start ${[ -f "vscreen.js" ] && echo "vscreen.js" || echo "server.js"} --name vscreen-hollywood -- --port 3004
            cd "$APP_DIR"
            pm2 save
            sleep 3
        fi
    else
        print_error "Cannot find V-Screen Hollywood service directory"
    fi
fi

# Verify V-Screen is now responding
if curl -s --connect-timeout 3 http://localhost:3004/health &> /dev/null; then
    print_success "V-Screen Hollywood verified and responding"
else
    print_warning "V-Screen still not responding, checking logs..."
    pm2 logs vscreen-hollywood --lines 20 --nostream 2>/dev/null || true
fi

echo ""

# ============================================================
# BONUS: Check Monitoring Service (Port 3006)
# ============================================================
print_status "BONUS: Checking Monitoring Service..."

if curl -s --connect-timeout 3 http://localhost:3006/health &> /dev/null; then
    print_success "Monitoring Service is responding"
else
    print_warning "Monitoring Service not responding (non-critical)"
    
    if [ -d "monitoring" ]; then
        cd monitoring
        
        if [ ! -d "node_modules" ]; then
            npm install --production 2>/dev/null || true
        fi
        
        if [ -f "server.js" ]; then
            pm2 start server.js --name monitoring-service -- --port 3006 2>/dev/null || true
            cd "$APP_DIR"
            pm2 save
        fi
    fi
fi

echo ""

# ============================================================
# SUMMARY AND RE-AUDIT
# ============================================================
print_status "All fixes applied. Running production audit again..."
echo ""

if [ -f "nexus-cos-complete-audit.sh" ]; then
    ./nexus-cos-complete-audit.sh
else
    print_error "Cannot find audit script"
fi

echo ""
print_status "Fix script complete!"
print_status ""
print_status "Manual checks if still failing:"
print_status "1. Check PM2 status: pm2 list"
print_status "2. View logs: pm2 logs"
print_status "3. Check ports: netstat -tulpn | grep -E '8000|3004|3005|3006|5432'"
print_status "4. Check Docker: docker ps"
print_status "5. Review .env file: cat .env"
echo ""

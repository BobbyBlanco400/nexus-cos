#!/bin/bash
# Nexus COS Deployment Issue Fixer
# Comprehensive script to fix all deployment issues and get the system running

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the working directory
WORK_DIR=$(pwd)

echo "=========================================="
echo "Nexus COS Deployment Issue Fixer"
echo "=========================================="
echo ""
echo -e "${BLUE}[INFO]${NC} Working directory: $WORK_DIR"
echo ""

# Helper functions
print_info() {
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

# FIX 1: PostgreSQL Database
print_info "FIX 1: Checking and fixing PostgreSQL database..."

# Check if PostgreSQL container exists
if docker ps -a | grep -q "nexus-postgres"; then
    print_warning "PostgreSQL container exists, checking its status..."
    
    # Check if it's running
    if docker ps | grep -q "nexus-postgres"; then
        print_success "PostgreSQL container is already running"
    else
        print_warning "PostgreSQL container exists but is not running, starting it..."
        if docker start nexus-postgres; then
            print_success "PostgreSQL container started successfully"
        else
            print_warning "Failed to start existing container, removing and recreating..."
            docker rm -f nexus-postgres || true
            docker run -d \
                --name nexus-postgres \
                -e POSTGRES_DB=nexuscos_db \
                -e POSTGRES_USER=nexuscos \
                -e POSTGRES_PASSWORD=password \
                -p 5432:5432 \
                postgres:15-alpine
            print_success "PostgreSQL container recreated and started"
        fi
    fi
else
    print_warning "PostgreSQL container not found, creating it..."
    docker run -d \
        --name nexus-postgres \
        -e POSTGRES_DB=nexuscos_db \
        -e POSTGRES_USER=nexuscos \
        -e POSTGRES_PASSWORD=password \
        -p 5432:5432 \
        postgres:15-alpine
    print_success "PostgreSQL container created and started"
fi

# Wait for PostgreSQL to be ready
print_info "Waiting for PostgreSQL to start..."
sleep 5

# Test database connection
if docker exec nexus-postgres pg_isready -U nexuscos > /dev/null 2>&1; then
    print_success "PostgreSQL is ready and accepting connections"
else
    print_warning "PostgreSQL may not be fully ready yet, continuing anyway..."
fi

echo ""

# FIX 2: Install dependencies for all services
print_info "FIX 2: Installing dependencies for services..."

# Install root dependencies (required for shared routes)
print_info "Installing root dependencies..."
cd "$WORK_DIR"
if [ -f "package.json" ]; then
    PUPPETEER_SKIP_DOWNLOAD=true npm install --quiet 2>/dev/null || PUPPETEER_SKIP_DOWNLOAD=true npm install
    print_success "Root dependencies installed"
fi

# Install dependencies for backend-api
if [ -d "$WORK_DIR/services/backend-api" ]; then
    print_info "Installing backend-api dependencies..."
    cd "$WORK_DIR/services/backend-api"
    if [ -f "package.json" ]; then
        npm install --production --quiet 2>/dev/null || npm install --production
        print_success "backend-api dependencies installed"
    fi
fi

# Install dependencies for puabomusicchain
if [ -d "$WORK_DIR/services/puabomusicchain" ]; then
    print_info "Installing puabomusicchain dependencies..."
    cd "$WORK_DIR/services/puabomusicchain"
    if [ -f "package.json" ]; then
        npm install --production --quiet 2>/dev/null || npm install --production
        print_success "puabomusicchain dependencies installed"
    fi
fi

# Install dependencies for vstage (v-suite module)
if [ -d "$WORK_DIR/modules/v-suite/v-stage" ]; then
    print_info "Installing vstage dependencies..."
    cd "$WORK_DIR/modules/v-suite/v-stage"
    if [ -f "package.json" ]; then
        npm install --production --quiet 2>/dev/null || npm install --production
        print_success "vstage dependencies installed"
    fi
fi

# Install dependencies for other v-suite services
for vservice in v-caster-pro v-prompter-pro v-screen; do
    if [ -d "$WORK_DIR/modules/v-suite/$vservice" ]; then
        print_info "Installing $vservice dependencies..."
        cd "$WORK_DIR/modules/v-suite/$vservice"
        if [ -f "package.json" ]; then
            npm install --production --quiet 2>/dev/null || npm install --production
            print_success "$vservice dependencies installed"
        fi
    fi
done

cd "$WORK_DIR"
echo ""

# FIX 3: Stop and remove errored PM2 processes
print_info "FIX 3: Cleaning up errored PM2 processes..."

# Delete errored backend-api process
if pm2 describe backend-api > /dev/null 2>&1; then
    print_warning "Stopping and removing existing backend-api process..."
    pm2 delete backend-api || true
    print_success "backend-api process removed"
fi

# Delete errored puabomusicchain process
if pm2 describe puabomusicchain > /dev/null 2>&1; then
    print_warning "Stopping and removing existing puabomusicchain process..."
    pm2 delete puabomusicchain || true
    print_success "puabomusicchain process removed"
fi

# Delete errored vstage process
if pm2 describe vstage > /dev/null 2>&1; then
    print_warning "Stopping and removing existing vstage process..."
    pm2 delete vstage || true
    print_success "vstage process removed"
fi

# Delete errored nexus-api-health process
if pm2 describe nexus-api-health > /dev/null 2>&1; then
    print_warning "Stopping and removing existing nexus-api-health process..."
    pm2 delete nexus-api-health || true
    print_success "nexus-api-health process removed"
fi

echo ""

# FIX 4: Start services properly using PM2 ecosystem config
print_info "FIX 4: Starting services using PM2 ecosystem configuration..."

# Start all services using the ecosystem config
if [ -f "$WORK_DIR/ecosystem.config.js" ]; then
    print_info "Starting services from ecosystem.config.js..."
    pm2 start ecosystem.config.js --update-env
    print_success "Services started from ecosystem configuration"
else
    print_error "ecosystem.config.js not found!"
fi

echo ""

# FIX 5: Save PM2 configuration
print_info "FIX 5: Saving PM2 process list..."
pm2 save
print_success "PM2 process list saved"

echo ""

# FIX 6: Check service status
print_info "FIX 6: Checking PM2 service status..."
pm2 list

echo ""

# FIX 7: Verify critical services are running
print_info "FIX 7: Verifying critical services..."

sleep 3

# Check backend-api
if pm2 describe backend-api 2>/dev/null | grep -q "online"; then
    print_success "backend-api is ONLINE"
else
    print_warning "backend-api is not online, checking logs..."
    pm2 logs backend-api --lines 20 --nostream || true
fi

# Check puabomusicchain
if pm2 describe puabomusicchain 2>/dev/null | grep -q "online"; then
    print_success "puabomusicchain is ONLINE"
else
    print_warning "puabomusicchain is not online, checking logs..."
    pm2 logs puabomusicchain --lines 20 --nostream || true
fi

# Check vstage
if pm2 describe vstage 2>/dev/null | grep -q "online"; then
    print_success "vstage is ONLINE"
else
    print_warning "vstage is not online, checking logs..."
    pm2 logs vstage --lines 20 --nostream || true
fi

# Check nexus-api-health
if pm2 describe nexus-api-health 2>/dev/null | grep -q "online"; then
    print_success "nexus-api-health is ONLINE"
else
    print_warning "nexus-api-health is not online, checking logs..."
    pm2 logs nexus-api-health --lines 20 --nostream || true
fi

echo ""

# FIX 8: Test service endpoints
print_info "FIX 8: Testing service endpoints..."

sleep 2

# Test backend-api health endpoint
if curl -s http://localhost:3001/health > /dev/null 2>&1; then
    print_success "Backend API health endpoint is responding"
else
    print_warning "Backend API health endpoint not responding yet (may need more time)"
fi

# Test puabomusicchain health endpoint
if curl -s http://localhost:3013/health > /dev/null 2>&1; then
    print_success "PuaboMusicChain health endpoint is responding"
else
    print_warning "PuaboMusicChain health endpoint not responding yet (may need more time)"
fi

# Test vstage health endpoint
if curl -s http://localhost:3012/health > /dev/null 2>&1; then
    print_success "vstage health endpoint is responding"
else
    print_warning "vstage health endpoint not responding yet (may need more time)"
fi

# Test nexus-api-health endpoint
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    print_success "nexus-api-health endpoint is responding"
else
    print_warning "nexus-api-health endpoint not responding yet (may need more time)"
fi

echo ""

# FIX 9: Check and fix vstage service
print_info "FIX 9: Checking vstage service..."

if pm2 describe vstage > /dev/null 2>&1; then
    if pm2 describe vstage | grep -q "online"; then
        print_success "vstage is already running"
    else
        print_warning "vstage exists but not online, attempting fix..."
        
        # Delete the errored process
        pm2 delete vstage || true
        sleep 2
        
        # Reinstall dependencies
        if [ -d "$WORK_DIR/modules/v-suite/v-stage" ]; then
            print_info "Reinstalling vstage dependencies..."
            cd "$WORK_DIR/modules/v-suite/v-stage"
            npm install --production --quiet 2>/dev/null || npm install --production
            
            # Start fresh
            print_info "Starting vstage fresh..."
            pm2 start index.js --name vstage
            cd "$WORK_DIR"
            
            # Wait and check if it started
            sleep 3
            if pm2 describe vstage 2>/dev/null | grep -q "online"; then
                print_success "vstage successfully started"
            else
                print_error "vstage failed to start, check logs with: pm2 logs vstage"
            fi
        fi
    fi
else
    if [ -d "$WORK_DIR/modules/v-suite/v-stage" ]; then
        print_warning "vstage not in PM2, starting it..."
        cd "$WORK_DIR/modules/v-suite/v-stage"
        
        # Make sure dependencies are installed
        if [ ! -d "node_modules" ]; then
            print_info "Installing vstage dependencies..."
            npm install --production --quiet 2>/dev/null || npm install --production
        fi
        
        pm2 start index.js --name vstage
        cd "$WORK_DIR"
        
        # Wait and verify
        sleep 3
        if pm2 describe vstage 2>/dev/null | grep -q "online"; then
            print_success "vstage started successfully"
        else
            print_error "vstage failed to start, check logs with: pm2 logs vstage"
        fi
    else
        print_info "vstage service directory not found, skipping..."
    fi
fi

echo ""

# FIX 10: Check and fix nexus-api-health service
print_info "FIX 10: Checking nexus-api-health service..."

if pm2 describe nexus-api-health > /dev/null 2>&1; then
    if pm2 describe nexus-api-health | grep -q "online"; then
        # Check if it has too many restarts
        RESTART_COUNT=$(pm2 describe nexus-api-health | grep "restarts" | head -1 | awk '{print $4}' || echo "0")
        if [ "$RESTART_COUNT" -gt 50 ]; then
            print_warning "nexus-api-health has $RESTART_COUNT restarts, resetting..."
            pm2 delete nexus-api-health || true
            sleep 2
            
            if [ -f "$WORK_DIR/server.js" ]; then
                cd "$WORK_DIR"
                PORT=3000 pm2 start server.js --name nexus-api-health
                sleep 3
                if pm2 describe nexus-api-health 2>/dev/null | grep -q "online"; then
                    print_success "nexus-api-health restarted successfully"
                else
                    print_error "nexus-api-health failed to restart"
                fi
            fi
        else
            print_success "nexus-api-health is already running"
        fi
    else
        print_warning "nexus-api-health exists but not online, fixing..."
        pm2 delete nexus-api-health || true
        sleep 2
        
        if [ -f "$WORK_DIR/server.js" ]; then
            cd "$WORK_DIR"
            PORT=3000 pm2 start server.js --name nexus-api-health
            sleep 3
            if pm2 describe nexus-api-health 2>/dev/null | grep -q "online"; then
                print_success "nexus-api-health started successfully"
            else
                print_error "nexus-api-health failed to start"
            fi
        fi
    fi
else
    if [ -f "$WORK_DIR/server.js" ]; then
        print_warning "nexus-api-health not in PM2, starting it..."
        cd "$WORK_DIR"
        PORT=3000 pm2 start server.js --name nexus-api-health
        sleep 3
        if pm2 describe nexus-api-health 2>/dev/null | grep -q "online"; then
            print_success "nexus-api-health started on port 3000"
        else
            print_error "nexus-api-health failed to start, check logs with: pm2 logs nexus-api-health"
        fi
    else
        print_info "server.js not found, skipping nexus-api-health..."
    fi
fi

echo ""

# FIX 11: Check and fix V-Screen Hollywood if needed
print_info "FIX 11: Checking V-Screen Hollywood service..."

if pm2 describe vscreen-hollywood > /dev/null 2>&1; then
    if pm2 describe vscreen-hollywood | grep -q "online"; then
        print_success "V-Screen Hollywood is already running"
    else
        print_warning "V-Screen Hollywood exists but not online, restarting..."
        pm2 restart vscreen-hollywood
    fi
else
    if [ -d "$WORK_DIR/services/vscreen-hollywood" ]; then
        print_warning "V-Screen Hollywood not in PM2, starting it..."
        cd "$WORK_DIR/services/vscreen-hollywood"
        pm2 start server.js --name vscreen-hollywood
        cd "$WORK_DIR"
        print_success "V-Screen Hollywood started"
    else
        print_info "V-Screen Hollywood service directory not found, skipping..."
    fi
fi

echo ""

# FIX 12: Update and fix any npm audit issues (non-breaking)
print_info "FIX 12: Running npm audit fix (non-breaking)..."
cd "$WORK_DIR"
npm audit fix --only=prod || print_warning "Some audit issues could not be auto-fixed"

echo ""

# FINAL: Summary and recommendations
print_info "==========================================
${GREEN}Deployment fix script completed!${NC}
==========================================

${BLUE}Summary:${NC}
✓ PostgreSQL database container configured
✓ Service dependencies installed
✓ Errored PM2 processes cleaned up
✓ Services restarted from ecosystem configuration
✓ PM2 configuration saved

${YELLOW}Next Steps:${NC}
1. Check PM2 status: ${BLUE}pm2 list${NC}
2. View logs: ${BLUE}pm2 logs${NC}
3. Check specific service: ${BLUE}pm2 logs <service-name>${NC}
4. Restart a service: ${BLUE}pm2 restart <service-name>${NC}
5. Check service health: ${BLUE}curl http://localhost:<port>/health${NC}

${YELLOW}Service Ports:${NC}
- backend-api: 3001
- puabomusicchain: 3013
- vstage: 3012
- nexus-api-health: 3000
- vscreen-hollywood: 8088

${YELLOW}Manual checks if services still failing:${NC}
1. Check PM2 status: pm2 list
2. View logs: pm2 logs
3. Check ports: netstat -tulpn | grep -E '3000|3001|3012|3013|8088|5432'
4. Check Docker: docker ps
5. Review .env file: cat .env
6. Test endpoints: curl http://localhost:3001/health

${GREEN}For production deployment validation, run:${NC}
${BLUE}./production-audit.sh${NC}
"

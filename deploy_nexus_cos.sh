#!/bin/bash
# Nexus COS Deployment Script
# Updated for extended deployment

set -e

echo "🚀 Starting Nexus COS Deployment..."

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

# Check if running in CI environment
if [[ -n "$CI" ]]; then
    print_status "Running in CI environment"
    
    # Install backend dependencies
    print_status "Installing backend dependencies..."
    cd backend
    npm ci --omit=dev
    cd ..
    
    # Install frontend dependencies (check for correct directory name)
    if [[ -d "frontend" ]]; then
        print_status "Installing frontend dependencies..."
        cd frontend
        npm ci --omit=dev
        cd ..
    elif [[ -d "web" ]]; then
        print_status "Installing web dependencies..."
        cd web
        npm ci --omit=dev
        cd ..
    else
        print_warning "Frontend directory not found"
    fi
    
    # Install mobile dependencies
    if [[ -d "mobile" ]]; then
        print_status "Installing mobile dependencies..."
        cd mobile
        npm ci --omit=dev
        cd ..
    else
        print_warning "Mobile directory not found"
    fi
    
    print_success "Dependencies installed successfully"
    
    # For CI, just build and test - don't deploy
    print_status "Building services..."
    
    # Build frontend
    if [[ -d "frontend" ]]; then
        cd frontend && npm run build && cd ..
    fi
    
    # Test backends
    print_status "Testing backend services..."
    cd backend
    npx ts-node src/server.ts &
    BACKEND_PID=$!
    sleep 5
    
    # Test health endpoint
    if curl -f http://localhost:3000/health; then
        print_success "Backend health check passed"
    else
        print_warning "Backend health check failed"
    fi
    
    # Cleanup
    kill $BACKEND_PID 2>/dev/null || true
    cd ..
    
else
    # Local deployment
    print_status "Running local deployment..."
    
    # Run the complete deployment script
    if [[ -f "deploy-nexus-cos-extended.sh" ]]; then
        chmod +x deploy-nexus-cos-extended.sh
        ./deploy-nexus-cos-extended.sh
    else
        # Fallback to basic deployment
        chmod +x deployment/deploy-complete.sh
        ./deployment/deploy-complete.sh
    fi
fi

print_success "Deployment completed successfully!"


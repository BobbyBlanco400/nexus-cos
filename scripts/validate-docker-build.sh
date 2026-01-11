#!/bin/bash

# Docker Build Validation Script
# This script validates the Docker build process and helps diagnose issues
#
# NOTE: Ensure this script has executable permissions:
#   chmod +x scripts/validate-docker-build.sh

set -e

echo "==================================="
echo "Docker Build Validation Script"
echo "==================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Step 1: Check if we're in the correct directory
echo "Step 1: Validating build context..."
if [ ! -f "package.json" ]; then
    print_error "package.json not found in current directory"
    echo "Please run this script from the repository root"
    exit 1
fi
print_success "package.json found in build context"

if [ ! -f "package-lock.json" ]; then
    print_warning "package-lock.json not found (optional but recommended)"
else
    print_success "package-lock.json found in build context"
fi

if [ ! -f "server.js" ]; then
    print_error "server.js not found in current directory"
    exit 1
fi
print_success "server.js found in build context"

if [ ! -f "Dockerfile" ]; then
    print_error "Dockerfile not found in current directory"
    exit 1
fi
print_success "Dockerfile found in build context"

echo ""

# Step 2: Check .dockerignore
echo "Step 2: Checking .dockerignore configuration..."
if [ -f ".dockerignore" ]; then
    if grep -q "^package.json$" .dockerignore 2>/dev/null; then
        print_error "package.json is excluded in .dockerignore - this will cause build failures!"
        exit 1
    fi
    if grep -q "^server.js$" .dockerignore 2>/dev/null; then
        print_error "server.js is excluded in .dockerignore - this will cause runtime failures!"
        exit 1
    fi
    print_success ".dockerignore configuration is correct"
else
    print_warning ".dockerignore not found (optional)"
fi

echo ""

# Step 3: Validate Docker is available
echo "Step 3: Checking Docker availability..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi
print_success "Docker is available"

# Check Docker daemon
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
fi
print_success "Docker daemon is running"

# Check curl availability
if ! command -v curl &> /dev/null; then
    print_warning "curl is not installed (required for testing health endpoint)"
fi

echo ""

# Step 4: Build the Docker image
echo "Step 4: Building Docker image..."
IMAGE_NAME="nexus-cos-validated"
if docker build -t "$IMAGE_NAME" . ; then
    print_success "Docker image built successfully"
else
    print_error "Docker build failed"
    exit 1
fi

echo ""

# Step 5: Verify the image
echo "Step 5: Verifying Docker image..."
if docker images "$IMAGE_NAME" | grep -q "$IMAGE_NAME"; then
    print_success "Docker image exists"
    
    # Get image size
    IMAGE_SIZE=$(docker images "$IMAGE_NAME" --format "{{.Size}}" | head -n 1)
    echo "  Image size: $IMAGE_SIZE"
else
    print_error "Docker image not found after build"
    exit 1
fi

echo ""

# Step 6: Test the image
echo "Step 6: Testing the Docker image..."
echo "  Starting a test container..."
CONTAINER_ID=$(docker run -d -p 3001:3000 \
    -e NODE_ENV=production \
    -e DB_HOST=postgres \
    -e DB_PORT=5432 \
    -e DB_NAME=test_db \
    -e DB_USER=test_user \
    -e DB_PASSWORD=test_pass \
    "$IMAGE_NAME")

if [ -z "$CONTAINER_ID" ]; then
    print_error "Failed to start test container"
    exit 1
fi

print_success "Test container started (ID: ${CONTAINER_ID:0:12})"

# Wait for container to start
echo "  Waiting for container to initialize..."
sleep 5

# Get container logs
echo ""
echo "Container logs (first 15 lines):"
echo "---"
docker logs "$CONTAINER_ID" 2>&1 | head -n 15
echo "---"

# Check if container is still running OR if it exited with error
CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "$CONTAINER_ID" 2>/dev/null)

if [ "$CONTAINER_STATUS" = "running" ]; then
    print_success "Container is running"
    
    # Test health endpoint (might fail if DB is not available, but that's okay)
    echo ""
    echo "Testing health endpoint..."
    if command -v curl &> /dev/null; then
        if curl -f http://localhost:3001/health 2>/dev/null; then
            print_success "Health endpoint responding"
        else
            print_warning "Health endpoint not responding (expected if database is not available)"
        fi
    else
        print_warning "curl not available, skipping health endpoint test"
    fi
elif [ "$CONTAINER_STATUS" = "exited" ]; then
    # Check exit code
    EXIT_CODE=$(docker inspect --format='{{.State.ExitCode}}' "$CONTAINER_ID" 2>/dev/null)
    
    # Check if the server actually started (look for successful startup message)
    if docker logs "$CONTAINER_ID" 2>&1 | grep -q "Server running on"; then
        print_success "Container started successfully and server initialized"
        print_warning "Container exited (likely due to missing database, which is expected in this test)"
    else
        print_error "Container failed to start server (exit code: $EXIT_CODE)"
        docker rm "$CONTAINER_ID" &>/dev/null
        exit 1
    fi
else
    print_error "Container in unexpected state: $CONTAINER_STATUS"
    docker rm "$CONTAINER_ID" &>/dev/null
    exit 1
fi

# Cleanup
echo ""
echo "Cleaning up test container..."
docker stop "$CONTAINER_ID" &>/dev/null
docker rm "$CONTAINER_ID" &>/dev/null
print_success "Test container cleaned up"

echo ""
echo "==================================="
print_success "All validation steps passed!"
echo "==================================="
echo ""
echo "The Docker build is working correctly."
echo "You can now use: docker-compose up -d"
echo ""

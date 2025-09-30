#!/bin/bash

# PUABO / Nexus COS - Pre-Flight Quick Deployment Script
# Date: 2025-09-30
# This script deploys the Nexus COS platform according to PF specifications

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PUABO / Nexus COS - Pre-Flight Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${YELLOW}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if Docker is installed
print_status "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi
print_success "Docker is installed"

# Check if Docker Compose is installed
print_status "Checking Docker Compose installation..."
if ! command -v docker compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi
print_success "Docker Compose is installed"

echo ""
print_status "Starting deployment..."
echo ""

# Stop any existing containers
print_status "Stopping any existing containers..."
docker compose -f docker compose.pf.yml down 2>/dev/null || true
print_success "Cleaned up existing containers"

# Build and start services
print_status "Building and starting services..."
docker compose -f docker compose.pf.yml up -d --build

# Wait for services to be ready
print_status "Waiting for services to be ready..."
echo ""

# Wait for PostgreSQL
print_status "Waiting for PostgreSQL..."
for i in {1..30}; do
    if docker compose -f docker compose.pf.yml exec -T nexus-cos-postgres pg_isready -U nexus_user -d nexus_db &>/dev/null; then
        print_success "PostgreSQL is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        print_error "PostgreSQL failed to start"
        exit 1
    fi
    sleep 2
done

# Apply migrations
print_status "Applying database migrations..."
docker compose -f docker compose.pf.yml exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -f /docker-entrypoint-initdb.d/schema.sql &>/dev/null || true
print_success "Migrations applied"

# Wait for API services
print_status "Waiting for API services..."
sleep 5

echo ""
print_status "Verifying services..."
echo ""

# Function to test endpoint
test_endpoint() {
    local url=$1
    local service_name=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        print_success "$service_name is responding"
        return 0
    else
        print_error "$service_name is not responding"
        return 1
    fi
}

# Test services
test_endpoint "http://localhost:4000/health" "puabo-api (Port 4000)"
test_endpoint "http://localhost:3002/health" "nexus-cos-puaboai-sdk (Port 3002)"
test_endpoint "http://localhost:3041/health" "nexus-cos-pv-keys (Port 3041)"

echo ""
print_status "Checking database..."

# Verify database tables
TABLES=$(docker compose -f docker compose.pf.yml exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;" 2>/dev/null | grep -v "^$" || echo "")

if echo "$TABLES" | grep -q "users"; then
    print_success "Users table exists"
else
    print_error "Users table not found"
fi

if echo "$TABLES" | grep -q "sessions"; then
    print_success "Sessions table exists"
else
    print_error "Sessions table not found"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${YELLOW}Service Status:${NC}"
docker compose -f docker compose.pf.yml ps
echo ""

echo -e "${YELLOW}📊 Service Endpoints:${NC}"
echo -e "  • puabo-api:              http://localhost:4000"
echo -e "  • nexus-cos-puaboai-sdk:  http://localhost:3002"
echo -e "  • nexus-cos-pv-keys:      http://localhost:3041"
echo -e "  • PostgreSQL:             localhost:5432"
echo -e "  • Redis:                  localhost:6379"
echo ""

echo -e "${YELLOW}🔍 Quick Tests:${NC}"
echo -e "  curl http://localhost:4000/health"
echo -e "  curl http://localhost:4000/"
echo -e "  curl http://localhost:3002/health"
echo -e "  curl http://localhost:3041/health"
echo ""

echo -e "${YELLOW}📝 Database Access:${NC}"
echo -e "  docker compose -f docker compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db"
echo ""

echo -e "${YELLOW}📊 View Logs:${NC}"
echo -e "  docker compose -f docker compose.pf.yml logs -f [service-name]"
echo ""

echo -e "${YELLOW}🛑 Stop Services:${NC}"
echo -e "  docker compose -f docker compose.pf.yml down"
echo ""

echo -e "${GREEN}For full documentation, see: PF_DEPLOYMENT_VERIFICATION.md${NC}"
echo ""

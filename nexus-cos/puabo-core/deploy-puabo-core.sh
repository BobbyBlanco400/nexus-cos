#!/bin/bash
#
# Nexus COS PUABO Core - One-Shot Deployment Script
# Run this via SSH to deploy the complete banking platform
# Safe to run even if TRAE automation is active
#
set -e

echo "=========================================="
echo "Nexus COS PUABO Core - Deployment"
echo "=========================================="
echo ""

# Navigate to the puabo-core directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Working directory: $(pwd)"
echo ""

# Step 1: Pull latest changes
echo "🔄 Step 1/6: Pulling latest changes..."
git pull origin $(git branch --show-current) || echo "⚠️  Could not pull (continuing anyway)"
echo ""

# Step 2: Stop any existing containers
echo "🛑 Step 2/6: Stopping existing containers..."
docker compose -f docker-compose.core.yml down -v 2>/dev/null || echo "No containers to stop"
echo ""

# Step 3: Build and start all services
echo "🚀 Step 3/6: Building and starting services..."
docker compose -f docker-compose.core.yml up -d --build
echo ""

# Step 4: Wait for services to be ready
echo "⏳ Step 4/6: Waiting for services to start (60 seconds)..."
sleep 60
echo ""

# Step 5: Initialize products
echo "💼 Step 5/6: Initializing banking products..."
chmod +x scripts/init-products.sh
./scripts/init-products.sh
echo ""

# Step 6: Check health
echo "🏥 Step 6/6: Checking service health..."
if curl -s http://localhost:7777/health | grep -q "healthy"; then
    echo "✅ PUABO Core Adapter is healthy!"
else
    echo "⚠️  PUABO Core Adapter health check failed"
fi
echo ""

# Display service status
echo "=========================================="
echo "📊 Service Status"
echo "=========================================="
docker compose -f docker-compose.core.yml ps
echo ""

# Display access information
echo "=========================================="
echo "🎉 Deployment Complete!"
echo "=========================================="
echo ""
echo "Services are now available:"
echo "  • PUABO Core Adapter API: http://localhost:7777"
echo "  • Apache Fineract:        http://localhost:8880"
echo "  • PostgreSQL:             localhost:5434"
echo "  • Redis:                  localhost:6379"
echo ""
echo "Next steps:"
echo "  1. Test the API:  curl http://localhost:7777/health"
echo "  2. Seed test data: cd scripts && npm install axios uuid && node seed-mock-data.js"
echo "  3. Run API tests:  cd scripts && node test-api.js"
echo ""
echo "View logs:  docker compose -f docker-compose.core.yml logs -f"
echo "Stop stack: docker compose -f docker-compose.core.yml down"
echo ""
echo "=========================================="

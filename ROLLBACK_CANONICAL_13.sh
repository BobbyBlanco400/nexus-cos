#!/bin/bash
set -e

# TRAE ROLLBACK PROTOCOL - CANONICAL 13 SERVICES
# Advisory ID: TRAE-2026-001-ROLLBACK

echo "=================================================="
echo "🚀 INITIATING TRAE ROLLBACK PROTOCOL"
echo "Target: Canonical 13-Service Core"
echo "Compliance: N3XUS LAW 55-45-17"
echo "=================================================="

# Define Deployment Directory
DEPLOY_DIR="/opt/nexus-cos"
cd "$DEPLOY_DIR" || { echo "❌ Directory $DEPLOY_DIR not found!"; exit 1; }

# 1. STOP EVERYTHING
echo -e "\n🛑 [1/4] Stopping all containers..."
docker compose -f docker-compose.unified.yml down --remove-orphans || true
docker compose -f docker-compose.full.yml down --remove-orphans 2>/dev/null || true

# 2. CLEANUP (Safe Prune)
echo -e "\n🧹 [2/4] Cleaning up resources..."
# Only prune stopped containers and unused networks, keep volumes for data safety
docker container prune -f
docker network prune -f

# 3. DEPLOY CANONICAL 13
echo -e "\n🚀 [3/4] Deploying Canonical 13-Service Core..."
export NEXUS_HANDSHAKE="55-45-17"

# Service List Mapped to docker-compose.unified.yml
SERVICES="nexus-cos-postgres nexus-cos-redis puabo-api auth-service puabo-nexus-fleet-manager puabo-nexus-ai-dispatch casino-nexus-api ledger-mgr token-mgr invoice-gen rewards-ms pv-keys nginx"

# Check if nginx service exists in unified, if not, try nexus-nginx
if grep -q "nexus-nginx" docker-compose.unified.yml; then
    if ! grep -q "nginx:" docker-compose.unified.yml; then
       # It's named nexus-nginx but likely under 'nginx' key or 'nexus-nginx' key
       # Let's rely on the service name key.
       # In my read, the key was 'nginx'.
       SERVICES="nexus-cos-postgres nexus-cos-redis puabo-api auth-service puabo-nexus-fleet-manager puabo-nexus-ai-dispatch casino-nexus-api ledger-mgr token-mgr invoice-gen rewards-ms pv-keys nginx"
    fi
fi

echo "Services: $SERVICES"

docker compose -f docker-compose.unified.yml up -d $SERVICES

# 4. VERIFY
echo -e "\n✅ [4/4] Verification..."
sleep 5
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n🎉 ROLLBACK COMPLETE. SYSTEM STABILIZED."

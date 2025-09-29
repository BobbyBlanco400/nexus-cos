#!/bin/bash
# PUABO Platform VPS Deployment Script

echo "🚀 Deploying Nexus COS + PUABO modules to VPS..."

# Stop existing containers
echo "Stopping existing services..."
docker-compose down || echo "Warning: docker-compose down failed"

# Pull latest images
echo "Pulling latest Docker images..."
docker-compose pull || echo "Warning: docker-compose pull failed"

# Start all services
echo "Starting PUABO platform services..."
docker-compose up -d || echo "Warning: docker-compose up failed"

# Wait for services to start
echo "Waiting for services to initialize..."
sleep 10

# Verify deployment
echo "Verifying deployment..."
curl -f http://localhost:3000/health || echo "Warning: Main service health check failed"

echo "✅ PUABO Platform deployment complete!"
echo "📊 Services running:"
docker-compose ps || echo "Warning: Could not list running services"
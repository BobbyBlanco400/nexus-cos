#!/bin/bash
# Run Nexus COS locally using Docker Compose

set -e

echo "Starting Nexus COS locally..."

# Check if .env file exists
if [ ! -f .env ]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
fi

# Start services
docker-compose -f docs/THIIO-HANDOFF/deployment/docker-compose.full.yml up -d

echo "✓ Services started"
echo "Access API Gateway at http://localhost:3000"

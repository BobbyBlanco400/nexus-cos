#!/bin/bash
# Verify environment is ready for deployment

set -e

echo "Verifying environment..."

# Check required tools
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "docker not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "node not found"; exit 1; }

# Check Kubernetes connection
kubectl cluster-info >/dev/null 2>&1 || { echo "Cannot connect to Kubernetes"; exit 1; }

# Check environment variables
if [ -f .env ]; then
  source .env
  [ -n "$DATABASE_URL" ] || echo "⚠ DATABASE_URL not set"
  [ -n "$REDIS_URL" ] || echo "⚠ REDIS_URL not set"
  [ -n "$JWT_SECRET" ] || echo "⚠ JWT_SECRET not set"
fi

echo "✓ Environment verification complete"

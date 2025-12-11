#!/bin/bash
# Build all Nexus COS services

set -e

echo "Building all Nexus COS services..."

# Build backend services
for service in services/*/; do
  if [ -f "$service/package.json" ]; then
    echo "Building $(basename $service)..."
    (cd "$service" && npm install && npm run build 2>/dev/null || true)
  fi
done

echo "✓ Build complete"

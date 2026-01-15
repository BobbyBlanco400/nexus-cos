#!/bin/bash
# Phase 3 & 4 Ignition Script (Codespaces)

set -e

echo "=== N3XUS v-COS Phase 3 & 4 Ignition ==="

# Detect environment
if [ "$CODESPACES" == "true" ] || [ -n "$GITHUB_CODESPACES" ]; then
    ENV="codespaces"
    DOCKER_COMPOSE_FILE="docker-compose.codespaces.yml"
else
    ENV="local"
    DOCKER_COMPOSE_FILE="docker-compose.final.yml"
fi

echo "Environment detected: $ENV"
echo "Launching Docker stack..."

# Start services
bash scripts/bootstrap-phase3-4.sh

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 10

# Enforce Handshake
for CONTAINER in v-supercore-codespaces puabo_api_ai_hf-codespaces ledger-mgr founding-creatives puabo-nexus-driver-app-backend puaboverse-v2 puabo-nuki-inventory-mgr puabo-dsp-metadata-mgr; do
    echo "Checking N3XUS Handshake for $CONTAINER..."
    HEADER=$(docker logs "$CONTAINER" 2>&1 | grep "X-N3XUS-Handshake: 55-45-17" || true)
    if [ -z "$HEADER" ]; then
        echo "❌ Handshake missing in $CONTAINER. Exiting."
        exit 1
    else
        echo "✅ Handshake verified for $CONTAINER"
    fi
done

echo "Phase 3 & 4 ignition complete!"

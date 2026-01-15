#!/bin/bash
# Verify N3XUS v-COS Launch

echo "=== N3XUS v-COS Launch Verification ==="

DOCKER_CONTAINERS=("v-supercore-codespaces" "puabo_api_ai_hf-codespaces" "ledger-mgr" "founding-creatives" "puabo-nexus-driver-app-backend" "puaboverse-v2" "puabo-nuki-inventory-mgr" "puabo-dsp-metadata-mgr")

# Check containers
for CONTAINER in "${DOCKER_CONTAINERS[@]}"; do
    RUNNING=$(docker ps --filter "name=$CONTAINER" --format "{{.Names}}")
    if [ "$RUNNING" != "$CONTAINER" ]; then
        echo "⚠️ Container NOT running: $CONTAINER"
    else
        echo "✅ Container running: $CONTAINER"
    fi
done

# Verify handshake headers
for CONTAINER in "${DOCKER_CONTAINERS[@]}"; do
    HEADER=$(docker logs "$CONTAINER" 2>&1 | grep "X-N3XUS-Handshake: 55-45-17" || true)
    if [ -z "$HEADER" ]; then
        echo "❌ Handshake missing in $CONTAINER"
    else
        echo "✅ Handshake verified in $CONTAINER"
    fi
done

# Check key files
for FILE in docker-compose.codespaces.yml .env; do
    if [ ! -f "$FILE" ]; then
        echo "⚠️ File missing: $FILE"
    else
        echo "✅ File exists: $FILE"
    fi
done

echo "Launch verification complete!"

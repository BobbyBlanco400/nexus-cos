#!/bin/bash
# Bootstrap Phase 3 & 4 for N3XUS v-COS (Codespaces)

set -e

echo "=== N3XUS v-COS Phase 3 & 4 Bootstrap ==="

# Detect Codespaces
if [ "$CODESPACES" == "true" ] || [ -n "$GITHUB_CODESPACES" ]; then
    ENV="codespaces"
    DOCKER_COMPOSE_FILE="docker-compose.codespaces.yml"
else
    ENV="local"
    DOCKER_COMPOSE_FILE="docker-compose.final.yml"
fi

echo "Environment detected: $ENV"

# Start Docker stack
echo "Starting Docker stack using $DOCKER_COMPOSE_FILE..."
docker compose -f $DOCKER_COMPOSE_FILE up -d --build --remove-orphans

# Optional Node.js verification
for SERVICE in services/* founding-creatives; do
    if [ -f "$SERVICE/package.json" ]; then
        echo "Verifying Node.js modules for $SERVICE..."
        (cd "$SERVICE" && npm ci --only=production || echo "⚠️ Node modules missing, skipped for $SERVICE")
    fi
done

echo "Bootstrap complete!"

#!/bin/bash

# NEXUS COS - FINAL IGNITION SEQUENCE
# Executes the Docker runtime launch with correct environment injection

echo "🚀 INITIATING NEXUS COS SOVEREIGN LAUNCH..."

# 1. Ensure .env.pf exists
if [ ! -f ".env.pf" ]; then
    echo "⚠️  .env.pf not found. Creating from example..."
    if [ -f ".env.pf.example" ]; then
        cp .env.pf.example .env.pf
        echo "✅ Created .env.pf from template."
        echo "⚠️  PLEASE UPDATE .env.pf WITH REAL SECRETS BEFORE PRODUCTION USE!"
    else
        echo "❌ Error: .env.pf.example missing. Cannot configure environment."
        exit 1
    fi
fi

# 2. Execute Docker Compose with explicit environment file
# This fixes the "variable missing" error by forcing docker compose to read .env.pf
echo "🐳 Starting Docker Services..."
docker compose --env-file .env.pf -f docker-compose.pf.yml up -d --build

# 3. Verify Status
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ IGNITION SUCCESSFUL."
    echo "   - Gateway:   http://localhost:4000"
    echo "   - Casino:    http://localhost:4000/casino"
    echo "   - Streaming: http://localhost:4000/streaming"
    echo ""
    echo "🔍 Run ./tools/system-health.sh to verify all components."
else
    echo ""
    echo "❌ IGNITION FAILED. Please check Docker logs."
    exit 1
fi

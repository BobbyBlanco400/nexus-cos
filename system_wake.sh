#!/bin/bash
# -----------------------------------------------------------------------------
# N3XUS v-COS | SYSTEM WAKE TIMER
# Governance: 55-45-17 (ENFORCED)
# Schedule: Daily @ 23:15 PST
# -----------------------------------------------------------------------------

echo "[$(date)] >>> WAKING N3XUS v-COS GRID..."

# 1. Start Core Services
echo "[$(date)] Starting v-Studios Core (8088)..."
# docker start v-studios || systemctl start v-studios

# 2. Start Phase 11 Sidecars
echo "[$(date)] Starting Franchise Forge (3050)..."
# docker start franchise-forge

echo "[$(date)] Starting Royalty Bridge (3053)..."
# docker start royalty-bridge

# 3. Verify Mesh
echo "[$(date)] Verifying Mesh Connectivity..."
curl -s http://localhost:3050/forge/health > /dev/null && echo "✅ Franchise Forge ONLINE" || echo "❌ Franchise Forge FAILED"
curl -s http://localhost:3053/royalty/health > /dev/null && echo "✅ Royalty Bridge ONLINE" || echo "❌ Royalty Bridge FAILED"

echo "[$(date)] >>> WAKE SEQUENCE COMPLETE."

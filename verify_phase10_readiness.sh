#!/bin/bash
# verify_phase10_readiness.sh
# Phase 10 Readiness Verification

echo "=== Phase 10 Readiness Verification ==="
echo "Target: 2/1/2026"
echo "Current Date: $(date)"
echo ""

check_service() {
    name=$1
    port=$2
    echo -n "Checking $name (Port $port)... "
    if curl -s -m 2 "http://localhost:$port/health" > /dev/null; then
        echo "✅ ONLINE"
    else
        # Try checking if container is running even if health endpoint fails
        if docker ps --format '{{.Names}}' | grep -q "$name"; then
            echo "⚠️  RUNNING (Health Check Failed)"
        else
            echo "❌ OFFLINE"
        fi
    fi
}

echo "--- Core Dependencies ---"
check_service "v-supercore" 3001
check_service "puabo-api-ai-hf" 3002

echo ""
echo "--- Phase 10 Services ---"
check_service "earnings-oracle" 3040
check_service "pmmg-media-engine" 3041
check_service "royalty-engine" 3042
check_service "v-caster-pro" 4070
check_service "v-screen-pro" 4072
check_service "vscreen-hollywood" 4073

echo ""
echo "--- Verification Complete ---"

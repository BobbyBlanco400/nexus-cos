#!/bin/bash
# VERIFY_PHASES_1_10.sh
# N3XUS v-COS Verification Script for Phases 1-10
# Target: Local Sovereign System (localhost)

TARGET_HOST=${1:-localhost}

echo "========================================================"
echo "   N3XUS v-COS VERIFICATION: PHASES 1-10"
echo "   Target: $TARGET_HOST"
echo "   Handshake: 55-45-17"
echo "========================================================"

check_service() {
    NAME=$1
    PORT=$2
    PATH=${3:-/health}
    
    echo -n "Checking $NAME (Port $PORT)... "
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$TARGET_HOST:$PORT$PATH)
    
    if [ "$STATUS" == "200" ]; then
        echo "[ PASS ]"
    else
        echo "[ FAIL ] (Status: $STATUS)"
    fi
}

echo ""
echo "--- CORE SERVICES ---"
check_service "v-supercore" 3001
check_service "puabo-api-ai-hf" 3002

echo ""
echo "--- PHASE 10: SETTLEMENT ---"
check_service "earnings-oracle" 3040
check_service "pmmg-media-engine" 3041
check_service "royalty-engine" 3042

echo ""
echo "--- MISSING SERVICES CHECK ---"
check_service "v-prompter-lite" 3504
check_service "remote-mic-bridge" 8081 "/"

echo ""
echo "========================================================"
echo "Verification Complete."

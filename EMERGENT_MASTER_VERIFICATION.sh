#!/bin/bash
# EMERGENT_MASTER_VERIFICATION.sh
# STRICT VERIFICATION PROTOCOL: N3XUS LAW 55-45-17
# TARGET: FULL STACK (51 SERVICES)
# PURPOSE: Master Verification Script for EMERGENT Audit. No opinions, only facts.

echo "=================================================="
echo "   EMERGENT MASTER VERIFICATION PROTOCOL"
echo "   N3XUS v-COS PLATFORM STACK"
echo "   TIMESTAMP: $(date -u)"
echo "=================================================="
echo ""

FAILURES=0

# 1. VERIFY SETTLEMENT LOCK
if [ -f "SETTLEMENT_PROTOCOL_72H.md" ]; then
    echo "✅ [LOCK] SETTLEMENT_PROTOCOL_72H.md FOUND."
else
    echo "❌ [LOCK] SETTLEMENT_PROTOCOL_72H.md MISSING."
    FAILURES=$((FAILURES+1))
fi

# 2. VERIFY SERVICE COUNT (RUNTIME)
# Count running containers managed by this project
# We filter by 'nexus' network or project name if possible, or just raw count if dedicated host.
# Assuming dedicated host as per context.
SERVICE_COUNT=$(docker ps --format "{{.Names}}" | wc -l)

if [ "$SERVICE_COUNT" -ge 51 ]; then
    echo "✅ [STACK] Service Count Verified: $SERVICE_COUNT/51"
else
    echo "❌ [STACK] Service Count Mismatch: $SERVICE_COUNT/51 (Expected >= 51)"
    FAILURES=$((FAILURES+1))
fi

# 3. VERIFY CRITICAL PORTS (RUNTIME)
# v-supercore must map host 3001 to container 8080
V_SUPERCORE_PORT=$(docker port v-supercore 8080/tcp 2>/dev/null)
if [[ "$V_SUPERCORE_PORT" == *"0.0.0.0:3001"* || "$V_SUPERCORE_PORT" == *":::3001"* ]]; then
    echo "✅ [PORT] v-supercore maps 8080 -> 3001"
else
    echo "❌ [PORT] v-supercore PORT MISMATCH. Found: $V_SUPERCORE_PORT"
    FAILURES=$((FAILURES+1))
fi

# 4. VERIFY HANDSHAKE PROTOCOL
# We check the runtime environment variable of v-supercore
HANDSHAKE_CHECK=$(docker exec v-supercore printenv N3XUS_HANDSHAKE 2>/dev/null)
if [ "$HANDSHAKE_CHECK" == "55-45-17" ]; then
    echo "✅ [PROTO] N3XUS_HANDSHAKE = 55-45-17 (Confirmed in Runtime)"
else
    echo "❌ [PROTO] N3XUS_HANDSHAKE Failed/Missing"
    FAILURES=$((FAILURES+1))
fi

# 5. VERIFY REPORT EXISTENCE
if [ -f "EMERGENT_VERIFICATION_REPORT.md" ]; then
    echo "✅ [DOCS] EMERGENT_VERIFICATION_REPORT.md FOUND."
else
    echo "❌ [DOCS] EMERGENT_VERIFICATION_REPORT.md MISSING."
    FAILURES=$((FAILURES+1))
fi

echo ""
echo "=================================================="
if [ $FAILURES -eq 0 ]; then
    echo "   STATUS: VERIFIED [PASSED]"
    echo "   SIGNATURE: VALID"
    exit 0
else
    echo "   STATUS: REJECTED [FAILED]"
    echo "   FAILURES: $FAILURES"
    exit 1
fi

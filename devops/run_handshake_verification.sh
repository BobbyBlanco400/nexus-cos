#!/bin/bash
################################################################################
# Nexus-Handshake 55-45-17 Compliance Verification
# Ensures platform stability and feature integrity across all services
################################################################################

set -euo pipefail

ENFORCE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --enforce)
            ENFORCE_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Nexus-Handshake 55-45-17 Compliance Verification ==="
echo

# 55% - Core Platform Stability Check
echo "Checking Core Platform Stability (55%)..."
CORE_SERVICES=("frontend" "gateway" "postgres" "redis" "puaboai-sdk")
CORE_HEALTHY=0
CORE_TOTAL=${#CORE_SERVICES[@]}

for service in "${CORE_SERVICES[@]}"; do
    if docker ps --filter "name=$service" --filter "status=running" | grep -q "$service"; then
        echo "  ✓ $service: RUNNING"
        ((CORE_HEALTHY++)) || true
    else
        echo "  ✗ $service: NOT RUNNING"
    fi
done

CORE_PERCENT=$((CORE_HEALTHY * 100 / CORE_TOTAL))
echo "Core Platform: $CORE_HEALTHY/$CORE_TOTAL services ($CORE_PERCENT%)"
echo

# 45% - Feature Layer Integrity Check
echo "Checking Feature Layer Integrity (45%)..."
FEATURE_SERVICES=("casino-nexus" "streaming-service" "puaboverse" "auth-service")
FEATURE_HEALTHY=0
FEATURE_TOTAL=${#FEATURE_SERVICES[@]}

for service in "${FEATURE_SERVICES[@]}"; do
    if docker ps --filter "name=$service" --filter "status=running" | grep -q "$service"; then
        echo "  ✓ $service: RUNNING"
        ((FEATURE_HEALTHY++)) || true
    else
        echo "  ✗ $service: NOT RUNNING"
    fi
done

FEATURE_PERCENT=$((FEATURE_HEALTHY * 100 / FEATURE_TOTAL))
echo "Feature Layer: $FEATURE_HEALTHY/$FEATURE_TOTAL services ($FEATURE_PERCENT%)"
echo

# 17 - Microservices Health Check
echo "Checking Microservices Health (17 critical services)..."
CRITICAL_SERVICES=(
    "frontend" "gateway" "postgres" "redis" "puaboai-sdk"
    "pv-keys" "casino-nexus" "skill-games-ms" "streaming-service"
    "auth-service" "puaboverse" "nexcoin-ms" "rewards-ms"
    "nft-marketplace-ms" "vr-world-ms" "content-management" "scheduler"
)

HEALTHY_COUNT=0
for service in "${CRITICAL_SERVICES[@]}"; do
    if docker ps --filter "name=$service" --filter "status=running" | grep -q "$service"; then
        ((HEALTHY_COUNT++)) || true
    fi
done

echo "Microservices: $HEALTHY_COUNT/17 critical services running"
echo

# Calculate overall compliance
OVERALL_SCORE=$(( (CORE_PERCENT * 55 + FEATURE_PERCENT * 45) / 100 ))
echo "=== Nexus-Handshake Compliance Score: $OVERALL_SCORE% ==="
echo

# Determine compliance status
if [[ $OVERALL_SCORE -ge 90 ]]; then
    echo "✅ COMPLIANT: Nexus-Handshake 55-45-17 requirements MET"
    echo "   Core: ${CORE_PERCENT}% | Feature: ${FEATURE_PERCENT}% | Services: ${HEALTHY_COUNT}/17"
    exit 0
elif [[ $OVERALL_SCORE -ge 75 ]]; then
    echo "⚠️  WARNING: Partial compliance detected"
    echo "   Core: ${CORE_PERCENT}% | Feature: ${FEATURE_PERCENT}% | Services: ${HEALTHY_COUNT}/17"
    if [[ "$ENFORCE_MODE" == "true" ]]; then
        echo "   ENFORCEMENT MODE: Failing due to insufficient compliance"
        exit 1
    fi
    exit 0
else
    echo "❌ FAILED: Nexus-Handshake 55-45-17 requirements NOT MET"
    echo "   Core: ${CORE_PERCENT}% | Feature: ${FEATURE_PERCENT}% | Services: ${HEALTHY_COUNT}/17"
    exit 1
fi

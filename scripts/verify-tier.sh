#!/bin/bash

# ===============================
# NΞ3XUS·COS PF-MASTER v3.0
# Tier Verification Script
# ===============================

set -e

TIER=$1

if [ -z "$TIER" ]; then
    echo "Usage: $0 <tier_number>"
    echo "Example: $0 0"
    exit 1
fi

echo "==========================================="
echo "Verifying Tier $TIER - $(date)"
echo "==========================================="

# Define tier services
declare -A TIER_SERVICES

TIER_SERVICES[0]="postgres redis backend-api auth-service key-service streamcore puaboai-sdk"
TIER_SERVICES[1]="ledger-mgr wallet-ms invoice-gen token-mgr"
TIER_SERVICES[2]="license-service musicchain-ms puabomusicchain dsp-api content-management pmmg-nexus-recordings"
TIER_SERVICES[3]="streaming-service-v2 chat-stream-ms ott-api"
TIER_SERVICES[4]="avatar-ms world-engine-ms gamecore-ms casino-nexus-api rewards-ms skill-games-ms puabo-nexus-ai-dispatch"

SERVICES=${TIER_SERVICES[$TIER]}

if [ -z "$SERVICES" ]; then
    echo "❌ Invalid tier number: $TIER"
    exit 1
fi

echo "📋 Tier $TIER Services: $SERVICES"
echo ""

# Check if running in Docker Compose or Kubernetes
if command -v docker-compose &> /dev/null || command -v docker &> /dev/null; then
    MODE="docker"
elif command -v kubectl &> /dev/null; then
    MODE="kubernetes"
else
    echo "❌ Neither Docker nor Kubernetes found"
    exit 1
fi

# Function to check Docker service
check_docker_service() {
    local service=$1
    local container_name="nexus-${service}"
    
    # Check if container exists and is running
    if docker ps --format "{{.Names}}" | grep -q "^${container_name}$"; then
        # Check health status
        health=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "none")
        
        if [ "$health" = "healthy" ] || [ "$health" = "none" ]; then
            echo "✅ $service: Running and healthy"
            return 0
        else
            echo "⚠️  $service: Running but unhealthy (status: $health)"
            return 1
        fi
    else
        echo "❌ $service: Not running"
        return 1
    fi
}

# Function to check Kubernetes service
check_k8s_service() {
    local service=$1
    local namespace="nexus-core"
    
    # Determine namespace based on tier
    case $TIER in
        0) namespace="nexus-core" ;;
        1) namespace="nexus-ledger" ;;
        2) namespace="nexus-ai" ;;
        3) namespace="nexus-streaming" ;;
        4) namespace="nexus-casino" ;;
    esac
    
    # Check if deployment exists and is ready
    ready=$(kubectl get deployment "$service" -n "$namespace" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    desired=$(kubectl get deployment "$service" -n "$namespace" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")
    
    if [ "$ready" -eq "$desired" ] && [ "$ready" -gt 0 ]; then
        echo "✅ $service: $ready/$desired replicas ready"
        return 0
    else
        echo "❌ $service: $ready/$desired replicas ready"
        return 1
    fi
}

# Verify each service
FAILED_COUNT=0
SUCCESS_COUNT=0

for service in $SERVICES; do
    if [ "$MODE" = "docker" ]; then
        if check_docker_service "$service"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    else
        if check_k8s_service "$service"; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
        fi
    fi
done

echo ""
echo "==========================================="
echo "Verification Summary for Tier $TIER"
echo "==========================================="
echo "✅ Successful: $SUCCESS_COUNT"
echo "❌ Failed: $FAILED_COUNT"
echo "📊 Total: $((SUCCESS_COUNT + FAILED_COUNT))"
echo ""

# Check for unhealthy containers in Docker mode
if [ "$MODE" = "docker" ]; then
    UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" | grep "nexus-" || true)
    if [ -n "$UNHEALTHY" ]; then
        echo "⚠️  Unhealthy containers detected:"
        echo "$UNHEALTHY"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
fi

# Final result
if [ $FAILED_COUNT -eq 0 ]; then
    echo "✅ Tier $TIER verification: PASSED"
    exit 0
else
    echo "❌ Tier $TIER verification: FAILED"
    exit 1
fi

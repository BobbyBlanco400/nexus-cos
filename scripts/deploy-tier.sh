#!/bin/bash

# ===============================
# NΞ3XUS·COS PF-MASTER v3.0
# Tier Deployment Script
# ===============================

set -e

TIER=$1

if [ -z "$TIER" ]; then
    echo "Usage: $0 <tier_number>"
    echo "Example: $0 0"
    exit 1
fi

echo "================================================"
echo "🚀 Deploying Tier $TIER - $(date)"
echo "================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Define tier services
declare -A TIER_SERVICES
declare -A TIER_NAMES

TIER_SERVICES[0]="postgres redis backend-api auth-service key-service streamcore puaboai-sdk"
TIER_SERVICES[1]="ledger-mgr wallet-ms invoice-gen token-mgr"
TIER_SERVICES[2]="license-service musicchain-ms puabomusicchain dsp-api content-management pmmg-nexus-recordings"
TIER_SERVICES[3]="streaming-service-v2 chat-stream-ms ott-api"
TIER_SERVICES[4]="avatar-ms world-engine-ms gamecore-ms casino-nexus-api rewards-ms skill-games-ms puabo-nexus-ai-dispatch"

TIER_NAMES[0]="Foundation Services"
TIER_NAMES[1]="Economic Core"
TIER_NAMES[2]="Platform Services"
TIER_NAMES[3]="Streaming Extensions"
TIER_NAMES[4]="Virtual Gaming"

SERVICES=${TIER_SERVICES[$TIER]}
TIER_NAME=${TIER_NAMES[$TIER]}

if [ -z "$SERVICES" ]; then
    echo "❌ Invalid tier number: $TIER"
    exit 1
fi

echo "📋 Deploying: $TIER_NAME"
echo "   Services: $SERVICES"
echo ""

# Check deployment mode
if command -v docker-compose &> /dev/null && [ -f "$PROJECT_ROOT/docker-compose.pf-master.yml" ]; then
    MODE="docker-compose"
elif command -v docker &> /dev/null; then
    MODE="docker"
elif command -v kubectl &> /dev/null; then
    MODE="kubernetes"
else
    echo "❌ No supported deployment tool found (docker-compose, docker, or kubectl)"
    exit 1
fi

echo "🔧 Deployment mode: $MODE"
echo ""

# Deploy services based on mode
if [ "$MODE" = "docker-compose" ]; then
    echo "🐳 Deploying services using Docker Compose..."
    
    cd "$PROJECT_ROOT"
    
    # Deploy specific tier services
    for service in $SERVICES; do
        echo "  ➜ Starting $service..."
        docker-compose -f docker-compose.pf-master.yml up -d "$service" || true
    done
    
    echo ""
    echo "⏳ Waiting for services to stabilize (30s)..."
    sleep 30
    
elif [ "$MODE" = "kubernetes" ]; then
    echo "☸️  Deploying services using Kubernetes..."
    
    # Determine namespace
    case $TIER in
        0) NAMESPACE="nexus-core" ;;
        1) NAMESPACE="nexus-ledger" ;;
        2) NAMESPACE="nexus-ai" ;;
        3) NAMESPACE="nexus-streaming" ;;
        4) NAMESPACE="nexus-casino" ;;
    esac
    
    echo "   Namespace: $NAMESPACE"
    
    # Create namespace if it doesn't exist
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy tier manifests
    if [ -d "$PROJECT_ROOT/k8s/tiers/tier-$TIER" ]; then
        echo "  ➜ Applying manifests from k8s/tiers/tier-$TIER/"
        kubectl apply -f "$PROJECT_ROOT/k8s/tiers/tier-$TIER/" -n "$NAMESPACE"
    else
        echo "⚠️  Kubernetes manifests not found at k8s/tiers/tier-$TIER/"
        echo "   Falling back to Helm deployment..."
        
        if [ -d "$PROJECT_ROOT/helm" ]; then
            helm upgrade --install "nexus-tier-$TIER" \
                "$PROJECT_ROOT/helm/nexus-cos" \
                --namespace "$NAMESPACE" \
                --create-namespace \
                --set "tier=$TIER"
        fi
    fi
    
    echo ""
    echo "⏳ Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s \
        deployment --all -n "$NAMESPACE" || true
fi

echo ""
echo "================================================"
echo "✅ Tier $TIER deployment complete!"
echo "================================================"
echo ""

# Verify deployment
echo "🔍 Running verification..."
if [ -f "$SCRIPT_DIR/verify-tier.sh" ]; then
    bash "$SCRIPT_DIR/verify-tier.sh" "$TIER"
else
    echo "⚠️  Verification script not found, skipping verification"
fi

exit 0

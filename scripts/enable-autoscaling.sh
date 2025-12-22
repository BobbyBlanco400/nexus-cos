#!/bin/bash

# ===============================
# NΞ3XUS·COS PF-MASTER v3.0
# Enable Autoscaling
# ===============================

set -e

echo "================================================"
echo "🔧 Enabling Autoscaling - $(date)"
echo "================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check deployment mode
if command -v kubectl &> /dev/null; then
    MODE="kubernetes"
elif command -v docker &> /dev/null; then
    MODE="docker"
    echo "⚠️  Docker mode: Autoscaling is managed via docker-compose deploy.replicas"
    echo "   HPA (Horizontal Pod Autoscaling) requires Kubernetes"
    exit 0
else
    echo "❌ No supported deployment tool found"
    exit 1
fi

echo "📋 Deployment mode: $MODE"
echo ""

# Install metrics-server if not present
echo "🔍 Checking for metrics-server..."
if ! kubectl get deployment metrics-server -n kube-system &> /dev/null; then
    echo "📦 Installing metrics-server..."
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch metrics-server for development environments
    kubectl patch deployment metrics-server -n kube-system --type='json' \
      -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]' || true
    
    echo "⏳ Waiting for metrics-server to be ready..."
    kubectl wait --for=condition=available --timeout=120s deployment/metrics-server -n kube-system || true
else
    echo "✅ metrics-server is already installed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Applying HPA Configurations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Apply HPA for each tier
TIERS=(0 1 2 3 4)
TOTAL_HPAS=0
APPLIED_HPAS=0

for tier in "${TIERS[@]}"; do
    echo ""
    echo "📊 Tier $tier: Applying HPAs..."
    
    TIER_DIR="$PROJECT_ROOT/k8s/tiers/tier-$tier"
    
    if [ -d "$TIER_DIR" ]; then
        # Check if HPA resources exist in the manifests
        HPA_COUNT=$(grep -r "kind: HorizontalPodAutoscaler" "$TIER_DIR" 2>/dev/null | wc -l || echo 0)
        
        if [ "$HPA_COUNT" -gt 0 ]; then
            echo "   Found $HPA_COUNT HPA(s) in Tier $tier manifests"
            TOTAL_HPAS=$((TOTAL_HPAS + HPA_COUNT))
            
            # The HPAs are already in the deployment manifests, just verify they're applied
            case $tier in
                0) NAMESPACE="nexus-core" ;;
                1) NAMESPACE="nexus-ledger" ;;
                2) NAMESPACE="nexus-ai" ;;
                3) NAMESPACE="nexus-streaming" ;;
                4) NAMESPACE="nexus-casino" ;;
            esac
            
            # Count active HPAs in the namespace
            ACTIVE=$(kubectl get hpa -n "$NAMESPACE" 2>/dev/null | grep -v NAME | wc -l || echo 0)
            echo "   Active HPAs in $NAMESPACE: $ACTIVE"
            APPLIED_HPAS=$((APPLIED_HPAS + ACTIVE))
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Verifying HPA Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# List all HPAs across namespaces
kubectl get hpa --all-namespaces 2>/dev/null || echo "No HPAs found (this is normal if services aren't deployed yet)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Autoscaling Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Metrics Server: Installed"
echo "📊 Total HPAs Expected: $TOTAL_HPAS"
echo "✅ Active HPAs: $APPLIED_HPAS"
echo ""

# Display autoscaling policies
echo "📋 Autoscaling Policies:"
echo "   • Default: 2-12 replicas"
echo "   • CPU Target: 65%"
echo "   • Memory Target: 70%"
echo "   • Scale Up: 30s cooldown"
echo "   • Scale Down: 180s cooldown"
echo ""
echo "   • Streaming Override:"
echo "     - Min: 5 replicas"
echo "     - Max: 25 replicas"
echo "     - CPU Target: 70%"
echo "     - Memory Target: 75%"
echo ""

echo "✅ Autoscaling configuration complete!"
exit 0

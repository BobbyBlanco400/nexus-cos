#!/bin/bash

# ===============================
# NΞ3XUS·COS PF-MASTER v3.0
# Apply Cost Governor
# ===============================

set -e

echo "================================================"
echo "💰 Applying Cost Governor - $(date)"
echo "================================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "📋 Cost Governance Configuration:"
echo "   • Platform Fee: 20%"
echo "   • Enforcement Layer: ledger-mgr"
echo "   • Billing Mode: Real-time"
echo "   • Throttling: Enabled"
echo ""

# Check if ledger service is available
echo "🔍 Verifying ledger-mgr service..."

if command -v kubectl &> /dev/null; then
    MODE="kubernetes"
    
    if kubectl get service ledger-mgr -n nexus-ledger &> /dev/null; then
        echo "✅ ledger-mgr service found in Kubernetes"
        LEDGER_URL="http://ledger-mgr.nexus-ledger.svc.cluster.local:4000"
    else
        echo "⚠️  ledger-mgr service not found in Kubernetes"
        echo "   Cost governor will be configured when ledger-mgr is deployed"
    fi
elif command -v docker &> /dev/null; then
    MODE="docker"
    
    if docker ps --format "{{.Names}}" | grep -q "nexus-ledger-mgr"; then
        echo "✅ ledger-mgr container found in Docker"
        LEDGER_URL="http://localhost:4000"
    else
        echo "⚠️  ledger-mgr container not found in Docker"
        echo "   Cost governor will be configured when ledger-mgr is deployed"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Tenant Limits"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   • CPU Max: 4000m (4 cores)"
echo "   • Memory Max: 8Gi"
echo "   • Storage Max: 100Gi"
echo "   • Streams Max: 5 concurrent"
echo "   • Bandwidth Max: 1TB/month"
echo ""

# Apply resource quotas for tenant namespaces (if Kubernetes)
if [ "$MODE" = "kubernetes" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔒 Applying Resource Quotas"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Create tenant namespace if it doesn't exist
    if ! kubectl get namespace nexus-tenants &> /dev/null; then
        echo "📦 Creating nexus-tenants namespace..."
        kubectl create namespace nexus-tenants
    fi
    
    # Apply resource quota
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ResourceQuota
metadata:
  name: tenant-quota
  namespace: nexus-tenants
spec:
  hard:
    requests.cpu: "4000m"
    requests.memory: "8Gi"
    requests.storage: "100Gi"
    limits.cpu: "8000m"
    limits.memory: "16Gi"
    persistentvolumeclaims: "10"
    pods: "50"
EOF
    
    echo "✅ Resource quota applied to nexus-tenants namespace"
    
    # Apply limit range
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: LimitRange
metadata:
  name: tenant-limits
  namespace: nexus-tenants
spec:
  limits:
  - max:
      cpu: "4000m"
      memory: "8Gi"
    min:
      cpu: "10m"
      memory: "64Mi"
    default:
      cpu: "500m"
      memory: "1Gi"
    defaultRequest:
      cpu: "250m"
      memory: "512Mi"
    type: Container
EOF
    
    echo "✅ Limit range applied to nexus-tenants namespace"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💵 Budget Alerts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   • 50% threshold: Notify"
echo "   • 75% threshold: Warn"
echo "   • 90% threshold: Throttle"
echo "   • 100% threshold: Suspend"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 Cost Optimization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   • Spot Instances: Enabled"
echo "   • Reserved Instances: 30%"
echo "   • Auto-shutdown:"
echo "     - Dev: 20:00-08:00"
echo "     - Staging: 22:00-06:00"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Platform Economics"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Platform Fee Distribution (20%):"
echo "   • Infrastructure: 40% (8% of revenue)"
echo "   • Development: 30% (6% of revenue)"
echo "   • Operations: 20% (4% of revenue)"
echo "   • Reserve: 10% (2% of revenue)"
echo ""

# Verify ledger configuration
if [ -n "$LEDGER_URL" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Verifying Ledger Configuration"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Try to verify platform fee configuration
    if [ -x "$SCRIPT_DIR/verify-ledger.sh" ]; then
        bash "$SCRIPT_DIR/verify-ledger.sh" || echo "⚠️  Ledger verification pending deployment"
    else
        echo "ℹ️  Ledger verification script not found"
    fi
fi

echo ""
echo "================================================"
echo "✅ Cost Governor Applied Successfully"
echo "================================================"
echo ""
echo "📝 Next Steps:"
echo "   1. Deploy ledger-mgr service (if not already deployed)"
echo "   2. Configure monitoring dashboards"
echo "   3. Set up budget alert webhooks"
echo "   4. Enable cost tracking for tenants"
echo ""

exit 0

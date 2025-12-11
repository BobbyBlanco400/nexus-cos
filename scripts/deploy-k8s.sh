#!/bin/bash
# Deploy Nexus COS to Kubernetes

set -e

K8S_DIR="docs/THIIO-HANDOFF/deployment/kubernetes"

echo "Deploying Nexus COS to Kubernetes..."

# Apply namespaces
kubectl apply -f "$K8S_DIR/namespace.yaml"

# Apply ConfigMaps
kubectl apply -f "$K8S_DIR/configmaps/"

# Apply secrets (must be configured first)
echo "⚠ Please ensure secrets are configured before deployment"
echo "  See: $K8S_DIR/secrets-template.yaml"

# Apply deployments
kubectl apply -f "$K8S_DIR/deployments/"

# Apply services
kubectl apply -f "$K8S_DIR/services/"

echo "✓ Deployment initiated"
echo "Monitor with: kubectl get pods --all-namespaces"

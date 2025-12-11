#!/bin/bash
# Run diagnostics on deployed services

set -e

echo "Running Nexus COS diagnostics..."

# Check pod status
echo "=== Pod Status ==="
kubectl get pods --all-namespaces | grep nexus

# Check service endpoints
echo ""
echo "=== Service Endpoints ==="
kubectl get svc --all-namespaces | grep nexus

# Check resource usage
echo ""
echo "=== Resource Usage ==="
kubectl top pods --all-namespaces | grep nexus

echo ""
echo "✓ Diagnostics complete"

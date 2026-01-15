#!/usr/bin/env bash
# Verify Nuisance Services
# N3XUS LAW 55-45-17 Enforced
set -e

echo "=========================================="
echo "Nuisance Services Verification"
echo "=========================================="
echo ""

echo "🔹 Verifying Nuisance services..."
echo ""

# Check each service port
for port in 4001 4002 4003 4004 4005; do
  echo -n "Checking port $port... "
  if command -v nc >/dev/null 2>&1; then
    if nc -z localhost $port 2>/dev/null; then
      echo "✅ Service on port $port is responding"
    else
      echo "⚠️  Service on port $port is NOT responding"
    fi
  else
    # Fallback to curl if nc is not available
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health | grep -q "200"; then
      echo "✅ Service on port $port is responding"
    else
      echo "⚠️  Service on port $port is NOT responding"
    fi
  fi
done

echo ""
echo "🔹 Testing health endpoints..."
echo ""

# Test health endpoints
services=("payment-partner:4001" "jurisdiction-rules:4002" "responsible-gaming:4003" "legal-entity:4004" "explicit-opt-in:4005")

for service_port in "${services[@]}"; do
  IFS=':' read -r service port <<< "$service_port"
  echo -n "Testing $service... "
  
  if curl -s http://localhost:$port/health | grep -q "ok"; then
    echo "✅ Health check passed"
  else
    echo "⚠️  Health check failed"
  fi
done

echo ""
echo "✅ Verification complete"

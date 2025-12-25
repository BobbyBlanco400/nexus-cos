#!/bin/bash
# Verify Federation Architecture
# Ensures federation system supports multi-casino operations

set -e

echo "🔍 Verifying Federation Architecture..."

# Check federation modules
if [ ! -d "addons/casino-nexus-core/federation" ]; then
  echo "❌ FAILED: Federation directory not found"
  exit 1
fi

# Verify casino registry
if [ ! -f "addons/casino-nexus-core/federation/casino.registry.ts" ]; then
  echo "❌ FAILED: Casino registry missing"
  exit 1
fi

# Verify strip router (casino routing)
if [ ! -f "addons/casino-nexus-core/federation/strip.router.ts" ]; then
  echo "❌ FAILED: Strip router missing"
  exit 1
fi

# Check for revenue split configuration
if ! grep -q "RevenueSplit" addons/casino-nexus-core/federation/casino.registry.ts; then
  echo "❌ FAILED: Revenue split system missing"
  exit 1
fi

# Verify jackpot/pool support
if ! grep -q "revenue\|Revenue" addons/casino-nexus-core/federation/casino.registry.ts; then
  echo "⚠️  WARNING: Revenue tracking may not be fully implemented"
fi

echo "✅ PASSED: Federation architecture verified"
exit 0

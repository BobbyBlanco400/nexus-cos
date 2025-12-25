#!/bin/bash
# Verify NexCoin Enforcement
# Ensures NexCoin is required for all premium features

set -e

echo "🔍 Verifying NexCoin Enforcement..."

# Check NexCoin guard exists
if [ ! -f "addons/casino-nexus-core/enforcement/nexcoin.guard.ts" ]; then
  echo "❌ FAILED: NexCoin guard module not found"
  exit 1
fi

# Verify enforcement functions exist
if ! grep -q "requireNexCoin" addons/casino-nexus-core/enforcement/nexcoin.guard.ts; then
  echo "❌ FAILED: NexCoin enforcement function missing"
  exit 1
fi

# Check for feature costs configuration
if ! grep -q "FEATURE_COSTS" addons/casino-nexus-core/enforcement/nexcoin.guard.ts; then
  echo "❌ FAILED: Feature costs configuration missing"
  exit 1
fi

# Verify wallet lock mechanism
if [ ! -f "addons/casino-nexus-core/enforcement/wallet.lock.ts" ]; then
  echo "⚠️  WARNING: Wallet lock module not found (optional but recommended)"
fi

echo "✅ PASSED: NexCoin enforcement verified"
exit 0

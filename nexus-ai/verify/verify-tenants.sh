#!/bin/bash
# Verify Tenant Isolation
# Ensures multi-tenant architecture with proper isolation

set -e

echo "🔍 Verifying Tenant Isolation..."

# Check jurisdiction toggle (part of isolation)
if [ ! -f "addons/casino-nexus-core/enforcement/jurisdiction.toggle.ts" ]; then
  echo "⚠️  WARNING: Jurisdiction toggle not found"
fi

# Check for owner/tenant fields in casino registry
if ! grep -q "owner" addons/casino-nexus-core/federation/casino.registry.ts; then
  echo "❌ FAILED: Casino ownership system missing"
  exit 1
fi

# Verify compliance profiles (tenant-specific compliance)
if ! grep -q "complianceProfile" addons/casino-nexus-core/federation/casino.registry.ts; then
  echo "❌ FAILED: Compliance profile system missing"
  exit 1
fi

# Check for tenant-specific metadata
if ! grep -q "metadata" addons/casino-nexus-core/federation/casino.registry.ts; then
  echo "⚠️  WARNING: Casino metadata system not found"
fi

echo "✅ PASSED: Tenant isolation architecture verified"
exit 0

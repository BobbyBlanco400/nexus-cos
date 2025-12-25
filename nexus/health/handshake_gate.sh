#!/usr/bin/env bash
# Nexus-Handshake Health Gate
# Blocks service startup if handshake verification fails

set -euo pipefail

HANDSHAKE_REQUIRED="55-45-17"

echo "🚦 Nexus-Handshake Health Gate"

# Check handshake
if [ -z "${NEXUS_HANDSHAKE:-}" ]; then
  echo "❌ BLOCKED: NEXUS_HANDSHAKE not set"
  echo "   Required: $HANDSHAKE_REQUIRED"
  exit 1
fi

if [ "${NEXUS_HANDSHAKE}" != "$HANDSHAKE_REQUIRED" ]; then
  echo "❌ BLOCKED: Invalid handshake"
  echo "   Expected: $HANDSHAKE_REQUIRED"
  echo "   Got: ${NEXUS_HANDSHAKE}"
  exit 1
fi

# Verify tenant configuration
TENANTS_FILE="${NEXUS_HOME:-/opt/nexus}/tenants/canonical_tenants.json"
if [ ! -f "$TENANTS_FILE" ]; then
  TENANTS_FILE="nexus/tenants/canonical_tenants.json"
fi

if [ -f "$TENANTS_FILE" ]; then
  TENANT_COUNT=$(grep -o '"id"' "$TENANTS_FILE" | wc -l)
  if [ "$TENANT_COUNT" -ne 12 ]; then
    echo "❌ BLOCKED: Invalid tenant count"
    echo "   Expected: 12"
    echo "   Got: $TENANT_COUNT"
    exit 1
  fi
  echo "✅ Tenant count verified: 12"
fi

echo "✅ PASSED: Handshake gate check"
echo "   Handshake: $HANDSHAKE_REQUIRED"
echo "   Status: AUTHORIZED"

exit 0

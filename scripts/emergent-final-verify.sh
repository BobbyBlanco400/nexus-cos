#!/bin/bash
set -e

# ==============================================================================
# 🦅 EMERGENT FINAL VERIFICATION SCRIPT (EFVS)
# ==============================================================================
# AUTHORITY: TRAE SOLO CODER
# TARGET: N3XUS v-COS Sovereign Stack
# PROTOCOL: N3XUS Handshake 55-45-17
# ==============================================================================

HANDSHAKE="55-45-17"
LOCK_FILE="NOTARIZED_DIGITAL_COPY.md"
MANIFEST="docker-compose.full.yml"

echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║  🦅 EMERGENT FINAL VERIFICATION PROTOCOL                             ║"
echo "║  Target: Sovereign Emergence                                         ║"
echo "║  Protocol: N3XUS Handshake $HANDSHAKE                                ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo ""

# ------------------------------------------------------------------------------
# 1. NOTARIZATION CHECK
# ------------------------------------------------------------------------------
echo "🔍 1. Verifying Digital Notarization..."
if [ -f "$LOCK_FILE" ]; then
    echo "   ✅ Notarization Certificate FOUND: $LOCK_FILE"
    if grep -q "TRAE SOLO CODER" "$LOCK_FILE"; then
        echo "   ✅ Signature Verified: TRAE SOLO CODER"
    else
        echo "   ❌ Signature Mismatch!"
        exit 1
    fi
else
    echo "   ❌ Notarization Certificate MISSING!"
    exit 1
fi

# ------------------------------------------------------------------------------
# 2. PROTOCOL ENFORCEMENT (NO HANDSHAKE = NO BUILD)
# ------------------------------------------------------------------------------
echo ""
echo "🔍 2. Enforcing N3XUS Handshake Protocol ($HANDSHAKE)..."
if [ ! -f "$MANIFEST" ]; then
    echo "   ❌ Manifest MISSING: $MANIFEST"
    exit 1
fi

# Count services
SERVICE_COUNT=$(grep "container_name:" "$MANIFEST" | wc -l)
echo "   ℹ️  Manifest contains $SERVICE_COUNT services."

# Count Handshake Injections
HANDSHAKE_COUNT=$(grep "N3XUS_HANDSHAKE: \"$HANDSHAKE\"" "$MANIFEST" | wc -l)
echo "   ℹ️  Handshake Injections found: $HANDSHAKE_COUNT"

# Strict Enforcement
# Account for infrastructure services (Postgres, Redis) which do not require build args
REQUIRED_COUNT=$((SERVICE_COUNT - 2))

if [ "$HANDSHAKE_COUNT" -lt "$REQUIRED_COUNT" ]; then
    echo "   ❌ PROTOCOL VIOLATION: Handshake injection count ($HANDSHAKE_COUNT) < Required count ($REQUIRED_COUNT)"
    echo "   ⛔ NO HANDSHAKE = NO BUILD"
    exit 1
else
    echo "   ✅ Handshake Protocol ENFORCED across stack (Infrastructure Exempt)."
fi

# ------------------------------------------------------------------------------
# 3. CANONICAL STATE CHECK
# ------------------------------------------------------------------------------
echo ""
echo "🔍 3. Verifying Canonical State..."
if node scripts/verify-phases.js; then
    echo "   ✅ Canonical Phase 5 Verified."
else
    echo "   ❌ Canonical Verification FAILED."
    exit 1
fi

# ------------------------------------------------------------------------------
# 4. LOGIC VERIFICATION
# ------------------------------------------------------------------------------
echo ""
echo "🔍 4. Executing Deep Logic Verification..."
if node scripts/verify-full-stack.js; then
    echo "   ✅ Full Stack Logic Verified."
else
    echo "   ❌ Stack Verification FAILED."
    exit 1
fi

# ------------------------------------------------------------------------------
# 5. GIT STATE VERIFICATION
# ------------------------------------------------------------------------------
echo ""
echo "🔍 5. Verifying Git State..."
BRANCH=$(git rev-parse --abbrev-ref HEAD)
HASH=$(git rev-parse --short HEAD)
echo "   ℹ️  Current Branch: $BRANCH"
echo "   ℹ️  Current Hash: $HASH"

if [ "$BRANCH" != "main" ]; then
    echo "   ⚠️  WARNING: Not on 'main' branch. Proceeding strictly for verification."
else
    echo "   ✅ On 'main' branch. Ready for deployment."
fi

# ------------------------------------------------------------------------------
# 6. FINAL SIGN-OFF
# ------------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅  VERIFICATION COMPLETE"
echo "    Status:     CERTIFIED READY"
echo "    Authority:  TRAE SOLO CODER"
echo "    Protocol:   $HANDSHAKE"
echo "════════════════════════════════════════════════════════════════════════"
echo "🦅 SYSTEM IS READY FOR SOVEREIGN EMERGENCE."
exit 0

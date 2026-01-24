#!/bin/bash
set -e

echo "🦅 EMERGENT MASTER VERIFICATION SCRIPT"
echo "Timestamp: $(date -u)"
echo "Protocol: N3XUS Handshake 55-45-17"
echo "----------------------------------------"

# 1. Check Directory Structure
echo "🔍 Checking Directory Structure..."
if [ -d "verification" ] && [ -d "scripts" ] && [ -d ".github/workflows" ]; then
    echo "✅ Core directories present."
else
    echo "❌ Critical directories missing."
    exit 1
fi

# 2. Verify Notarization
echo "🔍 Verifying Notarization..."
if [ -f "NOTARIZED_DIGITAL_COPY.md" ]; then
    echo "✅ Notarized Digital Copy found."
else
    echo "❌ Notarization missing."
    exit 1
fi

# 3. Verify Scripts
echo "🔍 Verifying Automation Scripts..."
if [ -f "scripts/verify-full-stack.js" ] && [ -f "scripts/verify-phases.js" ]; then
    echo "✅ Verification scripts present."
else
    echo "❌ Scripts missing."
    exit 1
fi

# 4. Check CI Workflow
echo "🔍 Checking CI Pipeline..."
if [ -f ".github/workflows/n3xus-master-verify.yml" ]; then
    echo "✅ Master Verification Workflow present."
else
    echo "❌ Workflow missing."
    exit 1
fi

# 5. Execute Node Verification (Dry Run)
echo "🔍 Executing Logic Check..."
if node -v > /dev/null 2>&1; then
    node scripts/verify-phases.js
    echo "✅ Logic check passed."
else
    echo "⚠️ Node.js not found, skipping runtime check (CI will handle this)."
fi

echo "----------------------------------------"
echo "🏆 ALL LOCAL CHECKS PASSED. READY FOR PR."

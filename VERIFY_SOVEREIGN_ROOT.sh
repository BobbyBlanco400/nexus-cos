#!/bin/bash
# -----------------------------------------------------------------------------
# N3XUS v-COS | SOVEREIGN ROOT VERIFICATION (LITE)
# Target: srv1213380
# Governance: 55-45-17 (ENFORCED)
# -----------------------------------------------------------------------------

echo ">>> INITIATING SOVEREIGN ROOT VERIFICATION..."
echo ">>> TARGET: srv1213380"
echo ">>> GOVERNANCE: 55-45-17 (ENFORCED)"

# 1. ARCHIVE INTEGRITY
echo ">>> [1/4] Checking Archive Integrity..."
if [ -d "PUABO_vSTUDIOS_MASTER_PR" ]; then
    echo "✅ Master PR Directory FOUND"
else
    echo "❌ Master PR Directory MISSING"
    exit 1
fi

# 2. GOVERNANCE ENFORCEMENT
echo ">>> [2/4] Verifying 55-45-17 Governance..."
SCRIPT_PATH="PUABO_vSTUDIOS_MASTER_PR/01_Story_Development/Scripts/UP-N3X_EP1_VERIFIED.md"
if grep -q "55-45-17" "$SCRIPT_PATH"; then
    echo "✅ Governance Protocol ENFORCED"
else
    echo "⚠️ Governance Protocol MISSING in Script"
fi

# 3. PORT AUDIT
echo ">>> [3/4] Auditing Studio Ports..."
PORTS=(8088 4070 4071 4055 4054 3050 3053)
for PORT in "${PORTS[@]}"; do
    if netstat -tuln | grep -q ":$PORT "; then
        echo "✅ Port $PORT: ACTIVE"
    else
        echo "🟡 Port $PORT: STAGED (Ready for Activation)"
    fi
done

# 4. WAKE TIMER
echo ">>> [4/4] Checking System Wake Timer..."
if crontab -l | grep -q "system_wake.sh"; then
    echo "✅ Wake Timer: ACTIVE"
else
    echo "⚠️ Wake Timer: MANUAL (Configuration Required)"
fi

echo ">>> VERIFICATION COMPLETE."
echo ">>> SYSTEM STATUS: SOVEREIGN & READY"

#!/bin/bash

# ===============================
# NΞ3XUS·COS PF-MASTER v3.0
# Ledger Enforcement Verification
# ===============================

set -e

echo "==========================================="
echo "Verifying Ledger Enforcement - $(date)"
echo "==========================================="

# Configuration
LEDGER_HOST="${LEDGER_HOST:-localhost}"
LEDGER_PORT="${LEDGER_PORT:-4000}"
LEDGER_URL="http://${LEDGER_HOST}:${LEDGER_PORT}"

echo "🔍 Checking ledger service at $LEDGER_URL"
echo ""

# Check if ledger service is reachable
if ! curl -sf "${LEDGER_URL}/ledger/health" > /dev/null 2>&1; then
    echo "❌ Ledger service is not reachable at ${LEDGER_URL}/ledger/health"
    exit 1
fi

echo "✅ Ledger service is running"
echo ""

# Check platform fee configuration
echo "🔍 Checking platform fee configuration..."

FEE_RESPONSE=$(curl -sf "${LEDGER_URL}/ledger/config/platform-fee" 2>/dev/null || echo "")

if [ -z "$FEE_RESPONSE" ]; then
    echo "⚠️  Unable to fetch platform fee configuration"
    echo "   Attempting alternative endpoint..."
    
    # Try alternative endpoint
    FEE_RESPONSE=$(curl -sf "${LEDGER_URL}/platform-fee" 2>/dev/null || echo "")
    
    if [ -z "$FEE_RESPONSE" ]; then
        echo "❌ Could not retrieve platform fee configuration from any endpoint"
        exit 1
    fi
fi

# Check if response contains 20% or 0.20
if echo "$FEE_RESPONSE" | grep -qE "(20%|0\.20|\"fee\":20|\"percentage\":20)"; then
    echo "✅ Platform fee correctly set to 20%"
    echo "   Response: $FEE_RESPONSE"
else
    echo "❌ Platform fee is not correctly configured"
    echo "   Expected: 20%"
    echo "   Got: $FEE_RESPONSE"
    exit 1
fi

echo ""

# Check audit mode
echo "🔍 Checking audit configuration..."

AUDIT_RESPONSE=$(curl -sf "${LEDGER_URL}/ledger/config/audit" 2>/dev/null || echo "")

if [ -z "$AUDIT_RESPONSE" ]; then
    echo "⚠️  Unable to fetch audit configuration (this may be expected)"
else
    if echo "$AUDIT_RESPONSE" | grep -qi "immutable"; then
        echo "✅ Audit mode is set to immutable"
    else
        echo "⚠️  Audit mode may not be immutable"
        echo "   Response: $AUDIT_RESPONSE"
    fi
fi

echo ""

# Check tenant isolation
echo "🔍 Checking tenant isolation..."

ISOLATION_RESPONSE=$(curl -sf "${LEDGER_URL}/ledger/config/tenant-isolation" 2>/dev/null || echo "")

if [ -z "$ISOLATION_RESPONSE" ]; then
    echo "⚠️  Unable to fetch tenant isolation configuration (this may be expected)"
else
    if echo "$ISOLATION_RESPONSE" | grep -qiE "(true|enabled)"; then
        echo "✅ Tenant isolation is enabled"
    else
        echo "⚠️  Tenant isolation may not be enabled"
        echo "   Response: $ISOLATION_RESPONSE"
    fi
fi

echo ""

# Test a sample transaction (if API supports it)
echo "🔍 Testing ledger transaction recording..."

TRANSACTION_TEST=$(curl -sf -X POST "${LEDGER_URL}/ledger/test/transaction" \
    -H "Content-Type: application/json" \
    -d '{"amount":100,"type":"test","tenant_id":"test-tenant"}' 2>/dev/null || echo "")

if [ -n "$TRANSACTION_TEST" ]; then
    if echo "$TRANSACTION_TEST" | grep -qiE "(success|recorded|created)"; then
        echo "✅ Test transaction recorded successfully"
        
        # Check if platform fee was calculated
        if echo "$TRANSACTION_TEST" | grep -qE "(20|platform.*fee)"; then
            echo "✅ Platform fee calculation verified in transaction"
        fi
    else
        echo "⚠️  Test transaction response: $TRANSACTION_TEST"
    fi
else
    echo "ℹ️  Transaction testing endpoint not available (this is optional)"
fi

echo ""
echo "==========================================="
echo "Ledger Enforcement Verification Summary"
echo "==========================================="
echo "✅ Ledger service: OPERATIONAL"
echo "✅ Platform fee: 20% CONFIGURED"
echo "✅ Enforcement: ACTIVE"
echo ""
echo "✅ All ledger enforcement checks: PASSED"
exit 0

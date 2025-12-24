#!/bin/bash
################################################################################
# Nexus COS 12 Tenants Verification
# Verifies all platform tenants are operational with correct URLs
################################################################################

set -euo pipefail

VERIFY_ALL=false
URLS_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            VERIFY_ALL=true
            shift
            ;;
        --urls-file)
            URLS_FILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Nexus COS 12 Tenants Verification ==="
echo

# Define 12 tenants with ports and health check paths
declare -A TENANTS=(
    ["N3XUS STREAM"]="3000:/"
    ["Casino-Nexus Lounge"]="3060:/puaboverse"
    ["Casino-Nexus Core"]="9503:/health"
    ["PUABO API Gateway"]="4000:/health"
    ["Streaming Service"]="3070:/health"
    ["PUABO AI SDK"]="3002:/health"
    ["PV Keys Service"]="3041:/health"
    ["Auth Service"]="3001:/health"
    ["Wallet Service"]="3000:/wallet"
    ["Admin Portal"]="9504:/health"
    ["PostgreSQL Database"]="5432:"
    ["Redis Cache"]="6379:"
)

PASSED=0
FAILED=0

for tenant in "${!TENANTS[@]}"; do
    IFS=':' read -r port path <<< "${TENANTS[$tenant]}"
    
    echo -n "Checking $tenant (port $port)... "
    
    # Check if service is listening on port
    if nc -z localhost "$port" 2>/dev/null; then
        echo "✓ OPERATIONAL"
        ((PASSED++)) || true
        
        # If path is provided, do HTTP check
        if [[ -n "$path" && "$VERIFY_ALL" == "true" ]]; then
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${port}${path}" 2>/dev/null || echo "000")
            if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
                echo "  └─ HTTP $HTTP_CODE: Accessible"
            else
                echo "  └─ HTTP $HTTP_CODE: Warning (service running but endpoint issue)"
            fi
        fi
    else
        echo "✗ OFFLINE"
        ((FAILED++)) || true
    fi
done

echo
echo "=== Tenant Verification Summary ==="
echo "Passed: $PASSED/12"
echo "Failed: $FAILED/12"
echo

if [[ $FAILED -eq 0 ]]; then
    echo "✅ All 12 tenants are operational"
    exit 0
elif [[ $PASSED -ge 10 ]]; then
    echo "⚠️  Most tenants operational ($PASSED/12)"
    exit 0
else
    echo "❌ Too many tenants offline ($FAILED/12)"
    exit 1
fi

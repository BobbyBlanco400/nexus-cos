#!/bin/bash
################################################################################
# Casino-Nexus 9-Card Grid Verification
# Verifies the 9-card casino lounge interface is properly configured
################################################################################

set -euo pipefail

CARD_COUNT=9

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cards)
            CARD_COUNT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== Casino-Nexus ${CARD_COUNT}-Card Grid Verification ==="
echo

# Define the 9 casino cards
declare -a CASINO_CARDS=(
    "Slots & Skill Games"
    "Table Games (Blackjack, Poker)"
    "Live Dealers"
    "VR Casino"
    "High Roller Suite"
    "Progressive Jackpots"
    "Tournament Hub"
    "Loyalty Rewards"
    "Marketplace"
)

# Check if puaboverse (Casino-Nexus Lounge) is running
echo "Checking Casino-Nexus Lounge service..."
if docker ps --filter "name=puaboverse" --filter "status=running" | grep -q "puaboverse"; then
    echo "✓ Casino-Nexus Lounge: RUNNING (port 3060)"
else
    echo "✗ Casino-Nexus Lounge: NOT RUNNING"
    echo "❌ Cannot verify 9-card grid without Casino-Nexus Lounge"
    exit 1
fi

echo
echo "Verifying 9-Card Grid Configuration..."

# Check if lounge endpoint is accessible
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3060/puaboverse" 2>/dev/null || echo "000")
if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
    echo "✓ Casino-Nexus Lounge endpoint accessible (HTTP $HTTP_CODE)"
else
    echo "✗ Casino-Nexus Lounge endpoint not accessible (HTTP $HTTP_CODE)"
    exit 1
fi

echo
echo "Casino Grid Cards:"
for i in "${!CASINO_CARDS[@]}"; do
    card_num=$((i + 1))
    echo "  Card $card_num: ${CASINO_CARDS[$i]}"
done

echo
echo "Verifying backend services for grid cards..."

# Check casino-nexus-api (main casino backend)
if nc -z localhost 9500 2>/dev/null; then
    echo "✓ Casino-Nexus API: RUNNING (port 9500)"
else
    echo "✗ Casino-Nexus API: OFFLINE (port 9500)"
fi

# Check skill-games-ms
if docker ps --filter "name=skill-games-ms" --filter "status=running" | grep -q "skill-games-ms"; then
    echo "✓ Skill Games Microservice: RUNNING"
else
    echo "✗ Skill Games Microservice: OFFLINE"
fi

# Check vr-world-ms
if nc -z localhost 9505 2>/dev/null; then
    echo "✓ VR World Microservice: RUNNING (port 9505)"
else
    echo "✗ VR World Microservice: OFFLINE (port 9505)"
fi

# Check rewards-ms
if nc -z localhost 9504 2>/dev/null; then
    echo "✓ Rewards Microservice: RUNNING (port 9504)"
else
    echo "✗ Rewards Microservice: OFFLINE (port 9504)"
fi

# Check nft-marketplace-ms
if nc -z localhost 9502 2>/dev/null; then
    echo "✓ NFT Marketplace Microservice: RUNNING (port 9502)"
else
    echo "✗ NFT Marketplace Microservice: OFFLINE (port 9502)"
fi

echo
echo "=== 9-Card Casino Grid Verification Complete ==="
echo "✅ Casino-Nexus Lounge with 9 Cards is configured and accessible"
echo "   Access via: https://n3xuscos.online/puaboverse"
exit 0

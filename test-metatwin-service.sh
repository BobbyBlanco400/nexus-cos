#!/bin/bash

# META-TWIN v2.5 Service Test Script
# Tests all API endpoints of the META-TWIN service

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3403"

echo "================================================"
echo "META-TWIN v2.5 Service Test Suite"
echo "================================================"
echo ""

# Test 1: Health Check
echo -e "${YELLOW}Test 1: Health Check${NC}"
response=$(curl -s ${BASE_URL}/health)
if echo "$response" | grep -q "ok"; then
    echo -e "${GREEN}✓ Health check passed${NC}"
else
    echo -e "${RED}✗ Health check failed${NC}"
    exit 1
fi
echo ""

# Test 2: Service Info
echo -e "${YELLOW}Test 2: Service Info${NC}"
response=$(curl -s ${BASE_URL}/)
if echo "$response" | grep -q "META-TWIN v2.5"; then
    echo -e "${GREEN}✓ Service info passed${NC}"
else
    echo -e "${RED}✗ Service info failed${NC}"
    exit 1
fi
echo ""

# Test 3: Create MetaTwin
echo -e "${YELLOW}Test 3: Create MetaTwin${NC}"
response=$(curl -s -X POST ${BASE_URL}/api/metatwin/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Twin Alpha",
    "behaviorMode": "host",
    "avatarType": "3D"
  }')
  
if echo "$response" | grep -q "MetaTwin created successfully"; then
    echo -e "${GREEN}✓ Create MetaTwin passed${NC}"
    MTID=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
    echo "  Created MTID: $MTID"
else
    echo -e "${RED}✗ Create MetaTwin failed${NC}"
    exit 1
fi
echo ""

# Test 4: Train MetaTwin
echo -e "${YELLOW}Test 4: Train MetaTwin${NC}"
response=$(curl -s -X POST ${BASE_URL}/api/metatwin/train \
  -H "Content-Type: application/json" \
  -d "{
    \"mtid\": \"$MTID\",
    \"behaviorPreset\": \"casino_dealer\"
  }")
  
if echo "$response" | grep -q "training initiated"; then
    echo -e "${GREEN}✓ Train MetaTwin passed${NC}"
else
    echo -e "${RED}✗ Train MetaTwin failed${NC}"
    exit 1
fi
echo ""

# Wait for training to complete
echo "  Waiting 2 seconds for training to complete..."
sleep 2

# Test 5: Link MetaTwin
echo -e "${YELLOW}Test 5: Link MetaTwin to Module${NC}"
response=$(curl -s -X POST ${BASE_URL}/api/metatwin/link \
  -H "Content-Type: application/json" \
  -d "{
    \"mtid\": \"$MTID\",
    \"module\": \"casino\",
    \"mode\": \"dealer\"
  }")
  
if echo "$response" | grep -q "mt-link://"; then
    echo -e "${GREEN}✓ Link MetaTwin passed${NC}"
    LINK_URL=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['linkUrl'])")
    echo "  Link URL: $LINK_URL"
else
    echo -e "${RED}✗ Link MetaTwin failed${NC}"
    exit 1
fi
echo ""

# Test 6: Deploy MetaTwin
echo -e "${YELLOW}Test 6: Deploy MetaTwin${NC}"
response=$(curl -s -X POST ${BASE_URL}/api/metatwin/deploy \
  -H "Content-Type: application/json" \
  -d "{
    \"mtid\": \"$MTID\",
    \"environment\": \"production\"
  }")
  
if echo "$response" | grep -q "deployed successfully"; then
    echo -e "${GREEN}✓ Deploy MetaTwin passed${NC}"
else
    echo -e "${RED}✗ Deploy MetaTwin failed${NC}"
    exit 1
fi
echo ""

# Test 7: List MetaTwins
echo -e "${YELLOW}Test 7: List MetaTwins${NC}"
response=$(curl -s ${BASE_URL}/api/metatwin/list)
if echo "$response" | grep -q "success"; then
    echo -e "${GREEN}✓ List MetaTwins passed${NC}"
    count=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['count'])")
    echo "  Total MetaTwins: $count"
else
    echo -e "${RED}✗ List MetaTwins failed${NC}"
    exit 1
fi
echo ""

# Test 8: Get Specific MetaTwin
echo -e "${YELLOW}Test 8: Get Specific MetaTwin${NC}"
# URL encode the MTID (replace # with %23)
ENCODED_MTID=$(echo "$MTID" | sed 's/#/%23/g')
response=$(curl -s ${BASE_URL}/api/metatwin/${ENCODED_MTID})
if echo "$response" | grep -q "Test Twin Alpha"; then
    echo -e "${GREEN}✓ Get MetaTwin passed${NC}"
else
    echo -e "${RED}✗ Get MetaTwin failed${NC}"
    exit 1
fi
echo ""

# Test 9: Mesh Status
echo -e "${YELLOW}Test 9: MT-IM Mesh Status${NC}"
response=$(curl -s ${BASE_URL}/api/metatwin/mesh)
if echo "$response" | grep -q "MT-IM"; then
    echo -e "${GREEN}✓ Mesh status passed${NC}"
    active=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['mesh']['activeConnections'])")
    echo "  Active connections: $active"
else
    echo -e "${RED}✗ Mesh status failed${NC}"
    exit 1
fi
echo ""

# Test 10: Economy Registration
echo -e "${YELLOW}Test 10: Economy Registration${NC}"
response=$(curl -s -X POST ${BASE_URL}/api/metatwin/economy/register \
  -H "Content-Type: application/json" \
  -d "{
    \"mtid\": \"$MTID\",
    \"creatorWallet\": \"0xTEST123456789\"
  }")
  
if echo "$response" | grep -q "registered in economy"; then
    echo -e "${GREEN}✓ Economy registration passed${NC}"
    nftId=$(echo "$response" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['nftId'])")
    echo "  NFT ID: $nftId"
else
    echo -e "${RED}✗ Economy registration failed${NC}"
    exit 1
fi
echo ""

# Test 11: Status Endpoint
echo -e "${YELLOW}Test 11: Status Endpoint${NC}"
response=$(curl -s ${BASE_URL}/status)
if echo "$response" | grep -q "metatwin"; then
    echo -e "${GREEN}✓ Status endpoint passed${NC}"
else
    echo -e "${RED}✗ Status endpoint failed${NC}"
    exit 1
fi
echo ""

echo "================================================"
echo -e "${GREEN}✓ All tests passed successfully!${NC}"
echo "================================================"
echo ""
echo "META-TWIN v2.5 Service is fully operational"
echo "Service URL: ${BASE_URL}"
echo "API Documentation: /home/runner/work/nexus-cos/nexus-cos/META_TWIN_V2.5_SPEC.md"

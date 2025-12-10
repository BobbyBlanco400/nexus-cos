#!/bin/bash
# Test script for Socket.IO Streaming Service
# This script verifies the service is working correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Socket.IO Streaming Service Test${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 1: Install dependencies
echo -e "${YELLOW}Test 1: Installing dependencies...${NC}"
cd services/socket-io-streaming
npm install --silent
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Test 2: Start service
echo -e "${YELLOW}Test 2: Starting service...${NC}"
PORT=3043 CORS_ORIGIN="https://nexuscos.online,https://www.nexuscos.online" node server.js &
SERVICE_PID=$!
sleep 3

if ps -p $SERVICE_PID > /dev/null; then
    echo -e "${GREEN}✓ Service started (PID: $SERVICE_PID)${NC}"
else
    echo -e "${RED}✗ Service failed to start${NC}"
    exit 1
fi
echo ""

# Test 3: Health check
echo -e "${YELLOW}Test 3: Testing health endpoint...${NC}"
HEALTH_RESPONSE=$(curl -sS http://localhost:3043/health)
if echo "$HEALTH_RESPONSE" | grep -q '"status":"ok"'; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "$HEALTH_RESPONSE" | jq .
else
    echo -e "${RED}✗ Health check failed${NC}"
    kill $SERVICE_PID
    exit 1
fi
echo ""

# Test 4: Status check
echo -e "${YELLOW}Test 4: Testing status endpoint...${NC}"
STATUS_RESPONSE=$(curl -sS http://localhost:3043/status)
if echo "$STATUS_RESPONSE" | grep -q '"status":"running"'; then
    echo -e "${GREEN}✓ Status check passed${NC}"
    echo "$STATUS_RESPONSE" | jq .
else
    echo -e "${RED}✗ Status check failed${NC}"
    kill $SERVICE_PID
    exit 1
fi
echo ""

# Test 5: Socket.IO endpoint
echo -e "${YELLOW}Test 5: Testing Socket.IO endpoint...${NC}"
SOCKETIO_RESPONSE=$(curl -sS "http://localhost:3043/socket.io/?EIO=4&transport=polling")
if echo "$SOCKETIO_RESPONSE" | grep -q '"sid"'; then
    echo -e "${GREEN}✓ Socket.IO endpoint passed${NC}"
    echo "$SOCKETIO_RESPONSE" | head -c 200
    echo ""
else
    echo -e "${RED}✗ Socket.IO endpoint failed${NC}"
    kill $SERVICE_PID
    exit 1
fi
echo ""

# Test 6: Streaming health check
echo -e "${YELLOW}Test 6: Testing streaming health endpoint...${NC}"
STREAM_HEALTH_RESPONSE=$(curl -sS http://localhost:3043/streaming/health)
if echo "$STREAM_HEALTH_RESPONSE" | grep -q '"status":"ok"'; then
    echo -e "${GREEN}✓ Streaming health check passed${NC}"
    echo "$STREAM_HEALTH_RESPONSE" | jq .
else
    echo -e "${RED}✗ Streaming health check failed${NC}"
    kill $SERVICE_PID
    exit 1
fi
echo ""

# Cleanup
echo -e "${YELLOW}Cleaning up...${NC}"
kill $SERVICE_PID
sleep 1
echo -e "${GREEN}✓ Service stopped${NC}"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}All tests passed! ✓${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "The Socket.IO streaming service is ready for deployment."
echo ""
echo "Next steps:"
echo "1. Deploy using PM2: pm2 start ecosystem.platform.config.js --only socket-io-streaming"
echo "2. Configure Apache2: sudo bash deployment/apache2/deploy-socket-io.sh"
echo "3. Or configure Nginx: sudo cp deployment/nginx/socket-io-streaming.conf /etc/nginx/conf.d/"
echo "4. Verify endpoints are accessible via your domain"
echo ""

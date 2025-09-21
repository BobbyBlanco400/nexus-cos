#!/bin/bash
# Direct replacement for: ssh root@74.208.155.161 'pm2 logs boomroom-backend --lines 20'
# Fixed version using correct IP, service name, and log command

# Configuration - adjust these if needed
SERVER_IP="75.208.155.161"  # Corrected IP from FINAL_VALIDATION.sh
SERVICE_NAME="nexus-backend-node"  # Corrected service name
LOG_LINES=20

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Original (incorrect) command:${NC}"
echo "ssh root@74.208.155.161 'pm2 logs boomroom-backend --lines 20'"
echo ""
echo -e "${GREEN}Fixed command being executed:${NC}"
echo "ssh root@$SERVER_IP 'journalctl -u $SERVICE_NAME -n $LOG_LINES --no-pager'"
echo ""
echo "============================================"

# Execute the corrected command
ssh root@"$SERVER_IP" "journalctl -u $SERVICE_NAME -n $LOG_LINES --no-pager"
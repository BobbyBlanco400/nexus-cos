#!/bin/bash
################################################################################
# Nexus COS - SSH Quick Deploy
# For VPS at n3xuscos.online (74.208.155.161)
#
# This is the ONE COMMAND you need to deploy Nexus COS Platform Stack
################################################################################

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Nexus COS Platform Stack - SSH Quick Deploy                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Deploying to: n3xuscos.online (74.208.155.161)"
echo "Deployment ID: nexus-cos-production-v1.0.0"
echo ""
echo "This will deploy:"
echo "  • 52 microservices"
echo "  • 43 modules"
echo "  • PUABO Core banking platform"
echo "  • Nginx + SSL (IONOS)"
echo "  • Socket.IO endpoints"
echo ""
echo "Estimated time: 20-25 minutes"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run the master deployment script
ssh root@74.208.155.161 'curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-nexus-cos-vps-master.sh | bash'

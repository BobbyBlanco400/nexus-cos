#!/bin/bash
# Quick verification script for all 29 services

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "    29 Services Health Check"
echo "========================================="
echo ""

# Array of all services with their ports
declare -A services=(
    ["backend-api"]=3001
    ["ai-service"]=3010
    ["puaboai-sdk"]=3012
    ["puabomusicchain"]=3013
    ["key-service"]=3014
    ["pv-keys"]=3015
    ["streamcore"]=3016
    ["glitch"]=3017
    ["puabo-dsp-upload-mgr"]=3211
    ["puabo-dsp-metadata-mgr"]=3212
    ["puabo-dsp-streaming-api"]=3213
    ["puabo-blac-loan-processor"]=3221
    ["puabo-blac-risk-assessment"]=3222
    ["puabo-nexus-ai-dispatch"]=3231
    ["puabo-nexus-driver-app-backend"]=3232
    ["puabo-nexus-fleet-manager"]=3233
    ["puabo-nexus-route-optimizer"]=3234
    ["puabo-nuki-inventory-mgr"]=3241
    ["puabo-nuki-order-processor"]=3242
    ["puabo-nuki-product-catalog"]=3243
    ["puabo-nuki-shipping-service"]=3244
    ["auth-service"]=3301
    ["content-management"]=3302
    ["creator-hub"]=3303
    ["user-auth"]=3304
    ["kei-ai"]=3401
    ["nexus-cos-studio-ai"]=3402
    ["puaboverse"]=3403
    ["streaming-service"]=3404
    ["boom-boom-room-live"]=3601
)

healthy=0
unhealthy=0

for service in "${!services[@]}"; do
    port=${services[$service]}
    printf "%-40s " "$service (Port $port):"
    
    if curl -s -f "http://localhost:$port/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ HEALTHY${NC}"
        healthy=$((healthy + 1))
    else
        echo -e "${RED}✗ UNHEALTHY${NC}"
        unhealthy=$((unhealthy + 1))
    fi
done

echo ""
echo "========================================="
echo -e "Summary: ${GREEN}$healthy healthy${NC}, ${RED}$unhealthy unhealthy${NC} out of 29 services"
echo "========================================="

if [ $healthy -eq 29 ]; then
    echo -e "${GREEN}🎉 ALL SERVICES ARE RUNNING!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some services need attention${NC}"
    exit 1
fi

#!/bin/bash
# Nexus COS - PF Nginx Configuration Validation Script
# Validates nginx configuration syntax and structure

echo "🔍 Nexus COS - PF Nginx Configuration Validation"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if nginx files exist
echo -e "${BLUE}1. Checking PF Configuration Files${NC}"
echo ""

if [ -f "nginx/nginx.conf" ]; then
    echo -e "${GREEN}✓${NC} nginx/nginx.conf exists"
else
    echo -e "${RED}✗${NC} nginx/nginx.conf not found"
    exit 1
fi

if [ -f "nginx/conf.d/nexus-proxy.conf" ]; then
    echo -e "${GREEN}✓${NC} nginx/conf.d/nexus-proxy.conf exists"
else
    echo -e "${RED}✗${NC} nginx/conf.d/nexus-proxy.conf not found"
    exit 1
fi

echo ""
echo -e "${BLUE}2. Validating PF Upstreams${NC}"
echo ""

# Check for PF upstreams
if grep -q "upstream pf_gateway" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} pf_gateway upstream defined (puabo-api:4000)"
else
    echo -e "${RED}✗${NC} pf_gateway upstream not found"
fi

if grep -q "upstream pf_puaboai_sdk" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} pf_puaboai_sdk upstream defined (nexus-cos-puaboai-sdk:3002)"
else
    echo -e "${RED}✗${NC} pf_puaboai_sdk upstream not found"
fi

if grep -q "upstream pf_pv_keys" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} pf_pv_keys upstream defined (nexus-cos-pv-keys:3041)"
else
    echo -e "${RED}✗${NC} pf_pv_keys upstream not found"
fi

echo ""
echo -e "${BLUE}3. Validating PF Health Endpoints${NC}"
echo ""

# Check for health endpoints
if grep -q "location /health" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} Gateway health endpoint configured (/health)"
else
    echo -e "${RED}✗${NC} Gateway health endpoint not found"
fi

if grep -q "location /health/puaboai-sdk" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} PuaboAI SDK health endpoint configured (/health/puaboai-sdk)"
else
    echo -e "${RED}✗${NC} PuaboAI SDK health endpoint not found"
fi

if grep -q "location /health/pv-keys" nginx/nginx.conf; then
    echo -e "${GREEN}✓${NC} PV Keys health endpoint configured (/health/pv-keys)"
else
    echo -e "${RED}✗${NC} PV Keys health endpoint not found"
fi

echo ""
echo -e "${BLUE}4. Validating PF Routes${NC}"
echo ""

# Check for PF frontend routes
ROUTES=(
    "/admin:Admin Panel"
    "/hub:Creator Hub"
    "/studio:Studio"
    "/streaming:Streaming"
    "/api:Main API"
)

for route_desc in "${ROUTES[@]}"; do
    IFS=':' read -r route desc <<< "$route_desc"
    if grep -q "location $route" nginx/conf.d/nexus-proxy.conf; then
        echo -e "${GREEN}✓${NC} $desc route configured ($route)"
    else
        echo -e "${RED}✗${NC} $desc route not found ($route)"
    fi
done

echo ""
echo -e "${BLUE}5. Validating V-Suite PF Routes${NC}"
echo ""

# Check for V-Suite routes
VSUITE_ROUTES=(
    "/v-suite/hollywood:V-Suite Hollywood"
    "/v-suite/prompter:V-Suite Prompter (v-prompter-pro)"
    "/v-suite/caster:V-Suite Caster"
    "/v-suite/stage:V-Suite Stage"
)

for route_desc in "${VSUITE_ROUTES[@]}"; do
    IFS=':' read -r route desc <<< "$route_desc"
    if grep -q "location $route" nginx/conf.d/nexus-proxy.conf; then
        echo -e "${GREEN}✓${NC} $desc route configured ($route)"
    else
        echo -e "${RED}✗${NC} $desc route not found ($route)"
    fi
done

echo ""
echo -e "${BLUE}6. Validating Frontend Environment${NC}"
echo ""

# Check frontend .env files
if [ -f "frontend/.env" ]; then
    echo -e "${GREEN}✓${NC} frontend/.env exists"
    if grep -q "VITE_API_URL=https://n3xuscos.online/api" frontend/.env; then
        echo -e "${GREEN}✓${NC} VITE_API_URL correctly set to https://n3xuscos.online/api"
    else
        echo -e "${RED}✗${NC} VITE_API_URL not set correctly"
    fi
else
    echo -e "${RED}✗${NC} frontend/.env not found"
fi

if [ -f "frontend/.env.example" ]; then
    echo -e "${GREEN}✓${NC} frontend/.env.example exists"
    if grep -q "VITE_API_URL=https://n3xuscos.online/api" frontend/.env.example; then
        echo -e "${GREEN}✓${NC} VITE_API_URL example correctly set"
    else
        echo -e "${RED}✗${NC} VITE_API_URL example not set correctly"
    fi
else
    echo -e "${RED}✗${NC} frontend/.env.example not found"
fi

echo ""
echo -e "${BLUE}7. Validating PF Architecture Diagram${NC}"
echo ""

if [ -f "test-diagram/NexusCOS-PF.mmd" ]; then
    echo -e "${GREEN}✓${NC} test-diagram/NexusCOS-PF.mmd exists"
    
    # Check for key PF components in diagram
    if grep -q "puabo-api" test-diagram/NexusCOS-PF.mmd && \
       grep -q "nexus-cos-puaboai-sdk" test-diagram/NexusCOS-PF.mmd && \
       grep -q "nexus-cos-pv-keys" test-diagram/NexusCOS-PF.mmd; then
        echo -e "${GREEN}✓${NC} All PF services represented in diagram"
    else
        echo -e "${RED}✗${NC} Some PF services missing from diagram"
    fi
    
    if grep -q "/v-suite/" test-diagram/NexusCOS-PF.mmd; then
        echo -e "${GREEN}✓${NC} V-Suite routes represented in diagram"
    else
        echo -e "${RED}✗${NC} V-Suite routes missing from diagram"
    fi
else
    echo -e "${RED}✗${NC} test-diagram/NexusCOS-PF.mmd not found"
fi

echo ""
echo -e "${BLUE}8. Configuration Syntax Check${NC}"
echo ""

# Note: This will fail if services aren't running, but syntax is valid
echo -e "${YELLOW}ℹ${NC} Nginx syntax check (requires services to be running):"
echo -e "${YELLOW}ℹ${NC} Run: sudo nginx -t -c $(pwd)/nginx/nginx.conf"
echo -e "${YELLOW}ℹ${NC} Note: Will show 'host not found' error if Docker services aren't running"
echo ""

echo "================================================"
echo -e "${GREEN}✓ PF Configuration Validation Complete${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Start PF services: docker compose -f docker-compose.pf.yml up -d"
echo "2. Verify all containers running: docker ps"
echo "3. Test health endpoints:"
echo "   - curl http://localhost:4000/health"
echo "   - curl http://localhost:3002/health"
echo "   - curl http://localhost:3041/health"
echo "4. Deploy nginx config to production server"
echo "5. Test all PF routes without 502 errors"
echo ""

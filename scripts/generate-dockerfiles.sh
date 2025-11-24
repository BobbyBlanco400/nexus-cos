#!/bin/bash
# Generate Dockerfiles for Nexus COS Services
# Part of Nexus COS v2025 Final Unified Build

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SERVICES_DIR="$REPO_ROOT/services"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Nexus COS Dockerfile Generator${NC}"
echo -e "${BLUE}v2025 Final Unified Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

CREATED=0
SKIPPED=0
FAILED=0

# Function to generate standard Dockerfile for Node.js services
generate_nodejs_dockerfile() {
    local service_dir=$1
    local service_name=$2
    local port=${3:-3000}
    
    cat > "$service_dir/Dockerfile" <<EOF
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy application files
COPY . .

# Expose port
EXPOSE $port

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \\
  CMD node -e "require('http').get('http://localhost:$port/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the service
CMD ["node", "server.js"]
EOF
}

# Function to detect port from server.js or use default
detect_port() {
    local service_dir=$1
    local default_port=$2
    
    if [ -f "$service_dir/server.js" ]; then
        # Try to extract port from server.js
        local port=$(grep -E "(PORT|port).*[0-9]{4}" "$service_dir/server.js" | head -1 | grep -oE "[0-9]{4}" | head -1)
        if [ -n "$port" ]; then
            echo "$port"
            return
        fi
    fi
    
    echo "$default_port"
}

# Service port mappings (based on existing configuration)
declare -A SERVICE_PORTS=(
    ["ai-service"]="3003"
    ["backend-api"]="3001"
    ["billing-service"]="3004"
    ["boom-boom-room-live"]="3005"
    ["content-management"]="3006"
    ["creator-hub-v2"]="3007"
    ["glitch"]="3008"
    ["kei-ai"]="3009"
    ["key-service"]="3010"
    ["nexus-cos-studio-ai"]="3011"
    ["puabo-blac-loan-processor"]="3020"
    ["puabo-blac-risk-assessment"]="3021"
    ["puabo-dsp-metadata-mgr"]="3030"
    ["puabo-dsp-streaming-api"]="3031"
    ["puabo-dsp-upload-mgr"]="3032"
    ["puabo-nexus-ai-dispatch"]="3231"
    ["puabo-nexus-driver-app-backend"]="3232"
    ["puabo-nexus-fleet-manager"]="3233"
    ["puabo-nexus-route-optimizer"]="3234"
    ["puabo-nuki-inventory-mgr"]="3040"
    ["puabo-nuki-order-processor"]="3041"
    ["puabo-nuki-product-catalog"]="3042"
    ["puabo-nuki-shipping-service"]="3244"
    ["puabomusicchain"]="3050"
    ["puaboverse-v2"]="3060"
    ["socket-io-streaming"]="3043"
    ["streaming-service-v2"]="3070"
    ["user-auth"]="3080"
    ["v-caster-pro"]="3012"
    ["v-prompter-pro"]="3013"
    ["v-screen-pro"]="3014"
    ["auth-service-v2"]="3081"
    ["puabo-nexus"]="3230"
)

cd "$SERVICES_DIR"

echo -e "${YELLOW}Scanning services directory...${NC}"
echo ""

for service_dir in */; do
    service_name="${service_dir%/}"
    
    # Skip if Dockerfile already exists
    if [ -f "$service_dir/Dockerfile" ]; then
        echo -e "${GREEN}✓${NC} $service_name - Dockerfile exists (skipped)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Check if it's a Node.js service (has package.json)
    if [ ! -f "$service_dir/package.json" ]; then
        echo -e "${YELLOW}⚠${NC} $service_name - No package.json (skipped)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Get port for this service
    port=${SERVICE_PORTS[$service_name]:-3000}
    
    # Generate Dockerfile
    if generate_nodejs_dockerfile "$service_dir" "$service_name" "$port"; then
        echo -e "${GREEN}✓${NC} $service_name - Dockerfile created (port: $port)"
        CREATED=$((CREATED + 1))
    else
        echo -e "${RED}✗${NC} $service_name - Failed to create Dockerfile"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Created:${NC} $CREATED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo -e "${RED}Failed:${NC} $FAILED"
echo ""

if [ $CREATED -gt 0 ]; then
    echo -e "${GREEN}✓ Dockerfiles generated successfully${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ No new Dockerfiles were created${NC}"
    exit 0
fi

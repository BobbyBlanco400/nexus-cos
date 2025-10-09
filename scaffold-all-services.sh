#!/bin/bash

# Nexus COS - Master Scaffolding Script
# Creates all service directories with Dockerfiles and basic Node.js servers

set -e

MODULES_DIR="/home/runner/work/nexus-cos/nexus-cos/modules"
SERVICES_DIR="/home/runner/work/nexus-cos/nexus-cos/services"

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Nexus COS Master Scaffolding...${NC}"

# Function to create a basic Dockerfile
create_dockerfile() {
    local dir=$1
    local port=$2
    cat > "$dir/Dockerfile" << 'EOF'
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production || npm install --only=production

COPY . .

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:${PORT}/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["node", "index.js"]
EOF
    echo -e "${GREEN}✓ Created Dockerfile in $dir${NC}"
}

# Function to create a basic package.json
create_package_json() {
    local dir=$1
    local name=$2
    local port=$3
    cat > "$dir/package.json" << EOF
{
  "name": "$name",
  "version": "1.0.0",
  "description": "$name service for Nexus COS",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOF
    echo -e "${GREEN}✓ Created package.json in $dir${NC}"
}

# Function to create a basic index.js with health endpoint
create_index_js() {
    local dir=$1
    local name=$2
    local port=$3
    cat > "$dir/index.js" << EOF
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || $port;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: '$name',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: '$name - Nexus COS Service',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(\`$name running on port \${PORT}\`);
});
EOF
    echo -e "${GREEN}✓ Created index.js in $dir${NC}"
}

# Function to scaffold a service
scaffold_service() {
    local dir=$1
    local name=$2
    local port=$3
    
    echo -e "${BLUE}Scaffolding $name...${NC}"
    mkdir -p "$dir"
    create_dockerfile "$dir" "$port"
    create_package_json "$dir" "$name" "$port"
    create_index_js "$dir" "$name" "$port"
}

# ============================================================================
# PUABO NEXUS Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO NEXUS Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-nexus/services/fleet-service" "fleet-service" 8080
scaffold_service "$MODULES_DIR/puabo-nexus/services/tracker-ms" "tracker-ms" 8081
scaffold_service "$MODULES_DIR/puabo-nexus/microservices/location-ms" "location-ms" 8082

# ============================================================================
# PUABOverse Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABOverse Services...${NC}"

scaffold_service "$MODULES_DIR/puaboverse/services/world-engine-ms" "world-engine-ms" 8090
scaffold_service "$MODULES_DIR/puaboverse/services/avatar-ms" "avatar-ms" 8091

# ============================================================================
# PUABO DSP Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO DSP Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-dsp/services/dsp-api" "dsp-api" 9000

# ============================================================================
# MusicChain Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding MusicChain Services...${NC}"

scaffold_service "$MODULES_DIR/musicchain/services/musicchain-ms" "musicchain-ms" 9001

# ============================================================================
# PUABO BLAC Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO BLAC Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-blac/services/blac-api" "blac-api" 9100
scaffold_service "$MODULES_DIR/puabo-blac/services/wallet-ms" "wallet-ms" 9101

# ============================================================================
# PUABO Studio Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO Studio Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-studio/services/studio-api" "studio-api" 9200
scaffold_service "$MODULES_DIR/puabo-studio/microservices/mixer-ms" "mixer-ms" 9201
scaffold_service "$MODULES_DIR/puabo-studio/microservices/mastering-ms" "mastering-ms" 9202

# ============================================================================
# V-Suite Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding V-Suite Services...${NC}"

scaffold_service "$MODULES_DIR/v-suite/v-screen" "v-screen-ms" 3010
scaffold_service "$MODULES_DIR/v-suite/v-caster-pro" "v-caster-ms" 3011
scaffold_service "$MODULES_DIR/v-suite/v-stage" "v-stage-ms" 3012
scaffold_service "$MODULES_DIR/v-suite/v-prompter-pro" "v-prompter-ms" 3002

# ============================================================================
# StreamCore Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding StreamCore Services...${NC}"

scaffold_service "$MODULES_DIR/streamcore/services/streamcore-ms" "streamcore-ms" 3016
scaffold_service "$MODULES_DIR/streamcore/microservices/chat-stream-ms" "chat-stream-ms" 3017

# ============================================================================
# GameCore Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding GameCore Services...${NC}"

scaffold_service "$MODULES_DIR/gamecore/services/gamecore-ms" "gamecore-ms" 3020

# ============================================================================
# Nexus Studio AI Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding Nexus Studio AI Services...${NC}"

scaffold_service "$MODULES_DIR/nexus-studio-ai/services/nexus-ai-ms" "nexus-ai-ms" 3030

# ============================================================================
# PUABO NUKI Clothing Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO NUKI Clothing Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-nuki-clothing/services/fashion-api" "fashion-api" 9300

# ============================================================================
# PUABO OTT TV Streaming Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding PUABO OTT TV Streaming Services...${NC}"

scaffold_service "$MODULES_DIR/puabo-ott-tv-streaming/services/ott-api" "ott-api" 9400

# ============================================================================
# Infrastructure Services
# ============================================================================
echo -e "${BLUE}📦 Scaffolding Infrastructure Services...${NC}"

mkdir -p "$SERVICES_DIR/auth-service"
mkdir -p "$SERVICES_DIR/scheduler"

scaffold_service "$SERVICES_DIR/auth-service" "auth-ms" 3100
scaffold_service "$SERVICES_DIR/scheduler" "scheduler-ms" 3101

echo -e "${GREEN}✅ Scaffolding Complete!${NC}"
echo -e "${BLUE}Total services scaffolded: 25+${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Review the generated docker-compose.nexus-full.yml"
echo -e "2. Run: docker compose -f docker-compose.nexus-full.yml build"
echo -e "3. Run: docker compose -f docker-compose.nexus-full.yml up -d"
echo -e "4. Test health endpoints for all services"

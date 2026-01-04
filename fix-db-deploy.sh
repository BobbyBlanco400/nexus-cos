#!/bin/bash
# One-Liner PM2 Database Fix Deployment
# Usage: bash fix-db-deploy.sh [localhost|docker|remote]

set -e

DB_CONFIG="${1:-localhost}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 Nexus COS - PM2 DB Fix Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

echo -e "${BLUE}Step 1/6: Pulling latest code...${NC}"
git pull origin main || echo "Already up to date"
echo ""

echo -e "${BLUE}Step 2/6: Stopping PM2 processes...${NC}"
pm2 delete all || echo "No processes to delete"
sleep 2
echo ""

echo -e "${BLUE}Step 3/6: Configuring database connection...${NC}"
case "$DB_CONFIG" in
    "docker")
        echo "Using Docker PostgreSQL configuration..."
        sed -i "s/DB_HOST: 'localhost'/DB_HOST: 'nexus-cos-postgres'/g" ecosystem.config.js
        sed -i "s/DB_NAME: 'nexuscos_db'/DB_NAME: 'nexus_db'/g" ecosystem.config.js
        sed -i "s/DB_USER: 'nexuscos'/DB_USER: 'nexus_user'/g" ecosystem.config.js
        sed -i "s/DB_PASSWORD: 'password'/DB_PASSWORD: 'Momoney2025\$'/g" ecosystem.config.js
        echo -e "${GREEN}✓ Configured for Docker (nexus-cos-postgres container)${NC}"
        ;;
    "remote")
        echo "Please specify remote DB host:"
        read -p "DB_HOST: " DB_HOST_VALUE
        read -p "DB_NAME: " DB_NAME_VALUE
        read -p "DB_USER: " DB_USER_VALUE
        read -sp "DB_PASSWORD: " DB_PASSWORD_VALUE
        echo ""
        sed -i "s/DB_HOST: 'localhost'/DB_HOST: '$DB_HOST_VALUE'/g" ecosystem.config.js
        sed -i "s/DB_NAME: 'nexuscos_db'/DB_NAME: '$DB_NAME_VALUE'/g" ecosystem.config.js
        sed -i "s/DB_USER: 'nexuscos'/DB_USER: '$DB_USER_VALUE'/g" ecosystem.config.js
        sed -i "s/DB_PASSWORD: 'password'/DB_PASSWORD: '$DB_PASSWORD_VALUE'/g" ecosystem.config.js
        echo -e "${GREEN}✓ Configured for remote database${NC}"
        ;;
    *)
        echo -e "${GREEN}✓ Using localhost PostgreSQL configuration (default)${NC}"
        ;;
esac
echo ""

echo -e "${BLUE}Step 4/6: Starting PM2 services...${NC}"
pm2 start ecosystem.config.js
pm2 save
echo ""

echo -e "${BLUE}Step 5/6: Waiting for services to initialize...${NC}"
sleep 10
echo ""

echo -e "${BLUE}Step 6/6: Verifying deployment...${NC}"
echo "-----------------------------------"
if command -v jq &> /dev/null; then
    HEALTH=$(curl -s https://n3xuscos.online/health)
    echo "$HEALTH" | jq .
    
    DB_STATUS=$(echo "$HEALTH" | jq -r '.db')
    if [ "$DB_STATUS" = "up" ]; then
        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}✅ SUCCESS! Database is connected!${NC}"
        echo -e "${GREEN}🎉 READY FOR BETA LAUNCH!${NC}"
        echo -e "${GREEN}========================================${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}========================================${NC}"
        echo -e "${RED}⚠️  Database is still down${NC}"
        echo -e "${RED}========================================${NC}"
        echo ""
        echo "Running diagnostics..."
        bash verify-pm2-env.sh
        exit 1
    fi
else
    curl -s https://n3xuscos.online/health
    echo ""
    echo -e "${YELLOW}Install jq for better output: apt-get install jq${NC}"
fi
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deployment Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo "View status: pm2 list"
echo "View logs: pm2 logs"
echo "Check health: curl https://n3xuscos.online/health | jq"
echo "Run diagnostics: bash verify-pm2-env.sh"

#!/bin/bash

# Service Mapping Fix Script
# This script helps identify and fix service name/port mismatches

echo "🔍 Analyzing service definitions..."
echo ""

echo "📋 Services mentioned in problem statement:"
echo "- puabo-api:4000 -> /api/"
echo "- puaboai-sdk:3002 -> /ai/"  
echo "- pv-keys:3041 -> /keys/"
echo ""

echo "📋 Services found in docker-compose files:"
if [ -f "docker-compose.yml" ]; then
    echo "From docker-compose.yml:"
    grep -A5 -B1 "container_name:\|ports:" docker-compose.yml | grep -E "container_name:|ports:" | head -10
fi

if [ -f "docker-compose.prod.yml" ]; then
    echo ""
    echo "From docker-compose.prod.yml:"
    grep -A5 -B1 "container_name:\|ports:" docker-compose.prod.yml | grep -E "container_name:|ports:" | head -20
fi

echo ""
echo "🔧 Recommended actions:"
echo ""

# Check if the services from problem statement exist
echo "1. Check if problem statement services exist:"
if grep -q "puabo-api" docker-compose*.yml 2>/dev/null; then
    echo "   ✅ puabo-api found in compose files"
else
    echo "   ❌ puabo-api NOT found - need to add service or update nginx.conf"
fi

if grep -q "puaboai-sdk" docker-compose*.yml 2>/dev/null; then
    echo "   ✅ puaboai-sdk found in compose files"
else
    echo "   ❌ puaboai-sdk NOT found - need to add service or update nginx.conf"
fi

if grep -q "pv-keys" docker-compose*.yml 2>/dev/null; then
    echo "   ✅ pv-keys found in compose files"
else
    echo "   ❌ pv-keys NOT found - need to add service or update nginx.conf"
fi

echo ""
echo "2. Alternative: Update nginx.conf to use existing services:"
echo "   Current services that could be mapped:"
echo "   - nexus-backend-node:3000 (could handle /api/)"
echo "   - nexus-backend-python:3001 (could handle /ai/)"  
echo "   - nexus-v-suite:3010 (could handle /keys/ or other endpoint)"
echo ""

echo "3. To use existing services, run:"
echo "   # Option A: Update nginx.conf upstreams to match existing services"
echo "   # Option B: Add the missing services to docker-compose files"
echo "   # Option C: Use the docker-compose.nginx.yml with placeholder services"
echo ""

echo "🚀 Quick start options:"
echo ""
echo "Option 1 - Test with placeholder services:"
echo "  docker-compose -f docker-compose.nginx.yml up -d"
echo "  ./test-nginx-routing.sh"
echo ""
echo "Option 2 - Update nginx.conf for existing services:"
echo "  # Edit nginx.conf to use nexus-backend-node, nexus-backend-python, etc."
echo "  # Then restart nginx in your main compose setup"
echo ""
echo "Option 3 - Check if there's a different compose file that has the required services:"
echo "  find . -name '*.yml' -o -name '*.yaml' | xargs grep -l 'puabo-api\\|puaboai-sdk\\|pv-keys'"
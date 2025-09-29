#!/bin/bash

# Test Nginx Routing Configuration
# Tests the routing endpoints as specified in the problem statement

echo "🔧 Testing Nginx routing configuration..."
echo ""

echo "📝 Step 1: Testing API endpoint routing"
echo "curl -i http://localhost/api/health"
curl -i http://localhost/api/health
echo ""
echo ""

echo "📝 Step 2: Testing AI endpoint routing"  
echo "curl -i http://localhost/ai/health"
curl -i http://localhost/ai/health
echo ""
echo ""

echo "📝 Step 3: Testing Keys endpoint routing"
echo "curl -i http://localhost/keys/health" 
curl -i http://localhost/keys/health
echo ""
echo ""

echo "✅ Nginx routing tests completed."
echo ""
echo "Expected results:"
echo "- If services are running: HTTP 200 responses with service health data"
echo "- If services are down: HTTP 502 Bad Gateway errors"
echo "- If nginx.conf is not loaded: Connection refused errors"
echo ""
echo "🔄 To restart nginx with the new configuration:"
echo "docker compose restart nginx"
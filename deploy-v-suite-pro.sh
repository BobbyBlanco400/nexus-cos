#!/bin/bash

# Deploy V-Suite Pro Services
# Deploys the four professional video suite services: v-caster-pro, v-prompter-pro, v-screen-pro, v-screen-hollywood

set -e

echo "🚀 Deploying V-Suite Pro Services..."
echo ""

# Check if pm2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 is not installed. Please install PM2 first:"
    echo "   npm install -g pm2"
    exit 1
fi

echo "📦 Installing dependencies..."
echo ""

# Install dependencies for each service
for service in v-caster-pro v-prompter-pro v-screen-pro v-screen-hollywood; do
    echo "  → Installing dependencies for $service..."
    cd "services/$service"
    npm install --silent
    cd ../..
done

echo ""
echo "✅ Dependencies installed"
echo ""

# Start services with PM2
echo "🚀 Starting services with PM2..."
echo ""

pm2 start ecosystem.config.js --only v-caster-pro,v-prompter-pro,v-screen-pro,v-screen-hollywood

echo ""
echo "⏳ Waiting for services to start..."
sleep 3

echo ""
echo "📊 Service Status:"
pm2 list | grep "v-.*-pro"

echo ""
echo "🔍 Testing health endpoints..."
echo ""

# Test health endpoints
for service in "v-caster-pro:3501" "v-prompter-pro:3502" "v-screen-pro:3503" "v-screen-hollywood:3504"; do
    service_name="${service%%:*}"
    port="${service##*:}"
    echo "  → Testing $service_name on port $port..."
    
    response=$(curl -s http://localhost:$port/health)
    status=$(echo $response | jq -r '.status' 2>/dev/null || echo "error")
    
    if [ "$status" = "ok" ]; then
        echo "    ✅ $service_name is healthy"
    else
        echo "    ❌ $service_name failed health check"
    fi
done

echo ""
echo "✅ V-Suite Pro Services Deployment Complete!"
echo ""
echo "📝 Service Details:"
echo "  • v-caster-pro:       http://localhost:3501"
echo "  • v-prompter-pro:     http://localhost:3502"
echo "  • v-screen-pro:       http://localhost:3503"
echo "  • v-screen-hollywood: http://localhost:3504"
echo ""
echo "🎯 To view logs:"
echo "  pm2 logs v-caster-pro"
echo "  pm2 logs v-prompter-pro"
echo "  pm2 logs v-screen-pro"
echo "  pm2 logs v-screen-hollywood"
echo ""
echo "🛑 To stop services:"
echo "  pm2 stop v-caster-pro,v-prompter-pro,v-screen-pro,v-screen-hollywood"
echo ""

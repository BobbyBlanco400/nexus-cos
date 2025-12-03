#!/bin/bash

echo "=========================================="
echo "DEPLOYING 14 NEW NEXUS COS MODULES"
echo "=========================================="
echo ""

cd /var/www/nexuscos.online

# Install dependencies for all new services
echo "Installing dependencies..."
for service in v-prompter talk-show game-show reality-tv documentary cooking-show home-improvement kids-programming music-video comedy-special drama-series animation podcast; do
  echo "  Installing $service..."
  cd services/$service && npm install --production && cd ../..
done

echo ""
echo "Building Docker containers..."
docker-compose up -d --build v-prompter-pro talk-show-studio game-show-creator reality-tv-producer documentary-suite cooking-show-kitchen home-improvement-hub kids-programming-studio music-video-director comedy-special-suite drama-series-manager animation-studio podcast-producer

echo ""
echo "Waiting for services to start..."
sleep 10

echo ""
echo "Testing new services..."
curl -s http://localhost:3060/health && echo "  ✓ V-Prompter Pro 10x10" || echo "  ✗ V-Prompter Pro"
curl -s http://localhost:3020/health && echo "  ✓ Talk Show Studio" || echo "  ✗ Talk Show"
curl -s http://localhost:3021/health && echo "  ✓ Game Show Creator" || echo "  ✗ Game Show"
curl -s http://localhost:3022/health && echo "  ✓ Reality TV Producer" || echo "  ✗ Reality TV"
curl -s http://localhost:3023/health && echo "  ✓ Documentary Suite" || echo "  ✗ Documentary"
curl -s http://localhost:3024/health && echo "  ✓ Cooking Show Kitchen" || echo "  ✗ Cooking Show"
curl -s http://localhost:3025/health && echo "  ✓ Home Improvement Hub" || echo "  ✗ Home Improvement"
curl -s http://localhost:3026/health && echo "  ✓ Kids Programming Studio" || echo "  ✗ Kids Programming"
curl -s http://localhost:3027/health && echo "  ✓ Music Video Director" || echo "  ✗ Music Video"
curl -s http://localhost:3028/health && echo "  ✓ Comedy Special Suite" || echo "  ✗ Comedy Special"
curl -s http://localhost:3029/health && echo "  ✓ Drama Series Manager" || echo "  ✗ Drama Series"
curl -s http://localhost:3030/health && echo "  ✓ Animation Studio" || echo "  ✗ Animation"
curl -s http://localhost:3031/health && echo "  ✓ Podcast Producer" || echo "  ✗ Podcast"

echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE"
echo "=========================================="
echo "Total containers: $(docker ps -q | wc -l)/51"
echo ""
echo "New Service URLs:"
echo "- V-Prompter Pro 10x10: http://localhost:3060"
echo "- Talk Show Studio: http://localhost:3020"
echo "- Game Show Creator: http://localhost:3021"
echo "- Reality TV Producer: http://localhost:3022"
echo "- Documentary Suite: http://localhost:3023"
echo "- Cooking Show Kitchen: http://localhost:3024"
echo "- Home Improvement Hub: http://localhost:3025"
echo "- Kids Programming Studio: http://localhost:3026"
echo "- Music Video Director: http://localhost:3027"
echo "- Comedy Special Suite: http://localhost:3028"
echo "- Drama Series Manager: http://localhost:3029"
echo "- Animation Studio: http://localhost:3030"
echo "- Podcast Producer: http://localhost:3031"
echo "=========================================="

#!/bin/bash
echo "🔍 Checking backend health..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health > health_code.txt
if [ "$(cat health_code.txt)" = "200" ]; then
  echo "✅ Backend is healthy (200 OK)"
else
  echo "❌ Backend health check failed"
  exit 1
fi
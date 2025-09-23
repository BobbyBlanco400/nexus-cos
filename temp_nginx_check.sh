#!/bin/bash
echo "🔍 Checking Nginx routes..."
curl -s -o /dev/null -w "%{http_code}" https://nexuscos.online > nginx_code.txt
if [ "$(cat nginx_code.txt)" = "200" ]; then
  echo "✅ Nginx is serving the frontend correctly"
else
  echo "⚠️ Warning: Nginx returned $(cat nginx_code.txt)"
fi
#!/bin/bash

# Quick Nexus COS Status Check
echo "🚀 NEXUS COS QUICK STATUS CHECK"
echo "==============================="
echo "Timestamp: $(date)"
echo ""

# Check if services are running
echo "📊 Service Status:"
if curl -s http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Node.js Backend (3000): RUNNING"
else
    echo "❌ Node.js Backend (3000): NOT RUNNING"
fi

if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    echo "✅ Python Backend (3001): RUNNING"
else
    echo "❌ Python Backend (3001): NOT RUNNING"
fi

if curl -s http://localhost:8080 >/dev/null 2>&1; then
    echo "✅ Frontend (8080): RUNNING"
else
    echo "❌ Frontend (8080): NOT RUNNING"
fi

echo ""
echo "🔗 Quick API Tests:"
echo "Node.js Health: $(curl -s http://localhost:3000/health 2>/dev/null || echo 'FAILED')"
echo "Python Health: $(curl -s http://localhost:3001/health 2>/dev/null || echo 'FAILED')"
echo "Auth Test: $(curl -s http://localhost:3000/api/auth/test 2>/dev/null | jq -r '.message' 2>/dev/null || echo 'FAILED')"

echo ""
echo "📋 Files Status:"
[[ -f "backend/package.json" ]] && echo "✅ Backend config" || echo "❌ Backend config"
[[ -f "frontend/package.json" ]] && echo "✅ Frontend config" || echo "❌ Frontend config"  
[[ -d "frontend/dist" ]] && echo "✅ Frontend build" || echo "❌ Frontend build"
[[ -d "backend/node_modules" ]] && echo "✅ Backend deps" || echo "❌ Backend deps"

echo ""
echo "🎯 Overall Status: $(curl -s http://localhost:3000/health >/dev/null 2>&1 && curl -s http://localhost:3001/health >/dev/null 2>&1 && curl -s http://localhost:8080 >/dev/null 2>&1 && echo "🟢 ALL SYSTEMS OPERATIONAL" || echo "🟡 SOME SERVICES DOWN")"
echo "==============================="
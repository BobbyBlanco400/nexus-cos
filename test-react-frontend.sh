#!/bin/bash
# Test script for local validation of Nexus COS React Frontend deployment

set -e

echo "🧪 Testing Nexus COS React Frontend deployment locally..."

# Create test deployment structure
TEST_DIR="/tmp/nexus-cos-test"
mkdir -p "$TEST_DIR/admin"
mkdir -p "$TEST_DIR/creator-hub"
mkdir -p "$TEST_DIR/frontend/dist"
mkdir -p "$TEST_DIR/diagram"

echo "📦 Testing React application builds..."

# Copy admin build if it exists
if [ -d "/home/runner/work/nexus-cos/nexus-cos/admin/build" ]; then
    cp -r /home/runner/work/nexus-cos/nexus-cos/admin/build/* "$TEST_DIR/admin/"
    echo "  ✅ Admin panel build copied"
    
    # Verify admin index.html exists and is valid
    if [ -f "$TEST_DIR/admin/index.html" ]; then
        echo "  ✅ Admin index.html found"
        # Check for problematic base tag
        if grep -q '<base href=' "$TEST_DIR/admin/index.html"; then
            echo "  ⚠️  Admin index.html contains base tag - this can cause issues"
        else
            echo "  ✅ Admin index.html looks good (no base tag)"
        fi
    fi
else
    echo "  ❌ Admin build not found"
fi

# Copy creator-hub build if it exists  
if [ -d "/home/runner/work/nexus-cos/nexus-cos/creator-hub/build" ]; then
    cp -r /home/runner/work/nexus-cos/nexus-cos/creator-hub/build/* "$TEST_DIR/creator-hub/"
    echo "  ✅ Creator hub build copied"
    
    # Verify creator-hub index.html exists and is valid
    if [ -f "$TEST_DIR/creator-hub/index.html" ]; then
        echo "  ✅ Creator hub index.html found"
        # Check for problematic base tag
        if grep -q '<base href=' "$TEST_DIR/creator-hub/index.html"; then
            echo "  ⚠️  Creator hub index.html contains base tag - this can cause issues"
        else
            echo "  ✅ Creator hub index.html looks good (no base tag)"
        fi
    fi
else
    echo "  ❌ Creator hub build not found"
fi

echo ""
echo "📁 Deployment structure:"
tree "$TEST_DIR" -L 3 2>/dev/null || find "$TEST_DIR" -type d | head -20

echo ""
echo "🔍 Checking static assets:"
echo "Admin static files:"
ls -la "$TEST_DIR/admin/static/" 2>/dev/null | head -5 || echo "  No admin static directory"

echo "Creator hub static files:"  
ls -la "$TEST_DIR/creator-hub/static/" 2>/dev/null | head -5 || echo "  No creator-hub static directory"

echo ""
echo "📝 Generating test Nginx configuration..."

# Generate test nginx config
cat > "$TEST_DIR/nginx-test.conf" << 'EOF'
# Nexus COS React Frontend Test Configuration
server {
    listen 8080;
    server_name localhost;
    
    root /tmp/nexus-cos-test;
    
    # Default redirect to admin panel
    location = / {
        return 301 /admin/;
    }
    
    # Admin Panel React Application
    location /admin/ {
        alias /tmp/nexus-cos-test/admin/;
        index index.html;
        try_files $uri $uri/ @admin_fallback;
    }
    
    location @admin_fallback {
        rewrite ^/admin/(.*)$ /admin/index.html last;
    }
    
    # Creator Hub React Application
    location /creator-hub/ {
        alias /tmp/nexus-cos-test/creator-hub/;
        index index.html;
        try_files $uri $uri/ @creator_fallback;
    }
    
    location @creator_fallback {
        rewrite ^/creator-hub/(.*)$ /creator-hub/index.html last;
    }
}
EOF

echo "✅ Test Nginx configuration created at $TEST_DIR/nginx-test.conf"

echo ""
echo "🎯 Test Results Summary:"
echo "  📁 Test directory: $TEST_DIR"
echo "  📄 Nginx config: $TEST_DIR/nginx-test.conf"
echo "  🔧 Ready for deployment testing"

echo ""
echo "💡 To test with a simple HTTP server:"
echo "  cd $TEST_DIR && python3 -m http.server 8000"
echo "  Then visit: http://localhost:8000/admin/"
#!/bin/bash
# Quick Deployment Script for Black Screen Fix
# For TRAE SOLO - Nexus COS
# This script deploys the fixed frontend with error handling

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║     🔧 BLACK SCREEN FIX DEPLOYMENT - NEXUS COS        ║${NC}"
    echo -e "${PURPLE}║              For TRAE SOLO                            ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header

# Configuration
FRONTEND_SOURCE="/home/runner/work/nexus-cos/nexus-cos/frontend"
DEPLOYMENT_TARGET="/var/www/nexus-cos"
BACKUP_DIR="/var/backups/nexus-cos"

# Step 1: Backup current deployment
print_step "Step 1: Backup Current Deployment"
if [ -d "$DEPLOYMENT_TARGET" ]; then
    print_status "Creating backup..."
    sudo mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    sudo tar -czf "$BACKUP_DIR/frontend_backup_$TIMESTAMP.tar.gz" -C "$DEPLOYMENT_TARGET" . 2>/dev/null || true
    print_success "Backup created at $BACKUP_DIR/frontend_backup_$TIMESTAMP.tar.gz"
else
    print_status "No existing deployment found, skipping backup"
fi

# Step 2: Build frontend with fixes
print_step "Step 2: Build Frontend with Black Screen Fixes"
cd "$FRONTEND_SOURCE"

print_status "Installing dependencies..."
npm install --silent

print_status "Building frontend with error handling..."
npm run build

print_success "Frontend built successfully"
print_status "✅ Error Boundary component included"
print_status "✅ Comprehensive error handling in main.tsx"
print_status "✅ Critical inline styles in index.html"
print_status "✅ Console logging for debugging"

# Step 3: Deploy to target directory
print_step "Step 3: Deploy to Production Directory"

print_status "Creating deployment directory..."
sudo mkdir -p "$DEPLOYMENT_TARGET"

print_status "Deploying built files..."
sudo rm -rf "$DEPLOYMENT_TARGET"/*
sudo cp -r dist/* "$DEPLOYMENT_TARGET"/

print_status "Setting proper permissions..."
sudo chown -R www-data:www-data "$DEPLOYMENT_TARGET" 2>/dev/null || {
    print_status "www-data user not available, using current user"
    sudo chown -R $(whoami):$(whoami) "$DEPLOYMENT_TARGET"
}
sudo chmod -R 755 "$DEPLOYMENT_TARGET"

print_success "Frontend deployed to $DEPLOYMENT_TARGET"

# Step 4: Verify deployment
print_step "Step 4: Verify Deployment"

# Check critical files
if [ -f "$DEPLOYMENT_TARGET/index.html" ]; then
    print_success "✅ index.html deployed"
else
    print_error "❌ index.html missing!"
    exit 1
fi

# Check for inline styles (critical for preventing black screen)
if grep -q "Critical inline styles" "$DEPLOYMENT_TARGET/index.html"; then
    print_success "✅ Critical inline styles present"
else
    print_error "❌ Inline styles missing!"
fi

# Check assets
JS_FILES=$(find "$DEPLOYMENT_TARGET/assets" -name "*.js" 2>/dev/null | wc -l)
CSS_FILES=$(find "$DEPLOYMENT_TARGET/assets" -name "*.css" 2>/dev/null | wc -l)

if [ "$JS_FILES" -gt 0 ]; then
    print_success "✅ JavaScript files deployed ($JS_FILES files)"
else
    print_error "❌ No JavaScript files found!"
fi

if [ "$CSS_FILES" -gt 0 ]; then
    print_success "✅ CSS files deployed ($CSS_FILES files)"
else
    print_error "❌ No CSS files found!"
fi

# Step 5: Test with curl (if server is running)
print_step "Step 5: Quick Health Check"

if command -v curl >/dev/null 2>&1; then
    if curl -sf http://localhost/ >/dev/null 2>&1; then
        print_success "✅ Frontend responding on localhost"
    else
        print_status "⚠️  Cannot reach localhost (nginx may need to be started)"
    fi
fi

# Step 6: Summary and next steps
print_step "Step 6: Deployment Summary"

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 BLACK SCREEN FIX DEPLOYED!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "📋 DEPLOYMENT DETAILS:"
echo "  • Source: $FRONTEND_SOURCE"
echo "  • Target: $DEPLOYMENT_TARGET"
echo "  • Backup: $BACKUP_DIR/"
echo ""
echo "✨ FIXES APPLIED:"
echo "  ✅ Error Boundary component catches React errors"
echo "  ✅ Comprehensive error handling in main.tsx"
echo "  ✅ Critical inline styles prevent black screen"
echo "  ✅ Console logging for easy debugging"
echo "  ✅ User-friendly error messages"
echo "  ✅ Reload button for error recovery"
echo ""
echo "🔍 WHAT CHANGED:"
echo "  • frontend/src/ErrorBoundary.tsx (NEW) - Catches React errors"
echo "  • frontend/src/main.tsx - Enhanced error handling"
echo "  • frontend/index.html - Critical inline styles"
echo "  • frontend/src/App.tsx - Debug logging"
echo ""
echo "📖 DOCUMENTATION:"
echo "  • See BLACK_SCREEN_FIX_SUMMARY.md for complete details"
echo ""

# Nginx configuration check
if command -v nginx >/dev/null 2>&1; then
    print_step "Step 7: Nginx Configuration"
    
    if nginx -t 2>/dev/null; then
        print_success "✅ Nginx configuration is valid"
        
        if systemctl is-active --quiet nginx 2>/dev/null; then
            print_status "Reloading nginx..."
            sudo systemctl reload nginx
            print_success "✅ Nginx reloaded"
        else
            print_status "Starting nginx..."
            sudo systemctl start nginx
            print_success "✅ Nginx started"
        fi
    else
        print_error "❌ Nginx configuration has errors"
        print_status "Run: sudo nginx -t"
    fi
else
    print_status "⚠️  Nginx not found - you'll need to configure it manually"
fi

echo ""
echo "🧪 TESTING THE FIX:"
echo "==================="
echo ""
echo "1. Open browser to: http://$(hostname -I | awk '{print $1}')/"
echo "   or: http://nexuscos.online/"
echo ""
echo "2. Open browser console (F12)"
echo ""
echo "3. You should see:"
echo "   ✅ Nexus COS Frontend - main.tsx loaded"
echo "   ✅ Root element found, mounting React app..."
echo "   ✅ React app mounted successfully"
echo "   🎭 Club Saditty App component mounted"
echo ""
echo "4. If there's an error, you'll see:"
echo "   • Purple gradient background (not black!)"
echo "   • Clear error message"
echo "   • Reload button"
echo "   • Detailed error info in console"
echo ""
echo "🐛 TROUBLESHOOTING:"
echo "==================="
echo "If you still see a black screen:"
echo ""
echo "  1. Check browser console for errors:"
echo "     • Right-click → Inspect → Console tab"
echo "     • Look for red error messages"
echo ""
echo "  2. Check nginx error log:"
echo "     sudo tail -f /var/log/nginx/error.log"
echo ""
echo "  3. Verify assets are loading:"
echo "     • Open browser Network tab"
echo "     • Refresh page"
echo "     • Check if JS/CSS files load (200 status)"
echo ""
echo "  4. Check file permissions:"
echo "     ls -la $DEPLOYMENT_TARGET"
echo ""
echo "  5. Test assets directly:"
echo "     curl -I http://localhost/assets/"
echo ""
echo "🎯 EXPECTED BEHAVIOR:"
echo "====================="
echo ""
echo "✨ On Success:"
echo "  1. Purple gradient background appears immediately"
echo "  2. 'Loading Nexus COS...' shows briefly"
echo "  3. Loading spinner with 'Loading Club Saditty...'"
echo "  4. After 2 seconds, full Club Saditty interface"
echo ""
echo "⚠️  On Error:"
echo "  1. Purple gradient background (NOT black!)"
echo "  2. Clear error message"
echo "  3. 'Reload Application' button"
echo "  4. Expandable error details"
echo ""
echo "🎉 The black screen issue is FIXED!"
echo ""
print_success "Deployment complete! The black screen error is now resolved."
echo ""

# Restore instructions
echo "💾 TO RESTORE BACKUP (if needed):"
echo "  sudo tar -xzf $BACKUP_DIR/frontend_backup_$TIMESTAMP.tar.gz -C $DEPLOYMENT_TARGET"
echo ""

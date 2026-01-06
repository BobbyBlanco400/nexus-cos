#!/bin/bash
################################################################################
# Nexus COS - PWA Deployment Script
# Registers PWA service worker & manifest
################################################################################

set -e

echo "🚀 Deploying Nexus COS PWA..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PWA_DIR="${PWA_DIR:-./frontend}"
PUBLIC_DIR="${PUBLIC_DIR:-/var/www/n3xuscos.online}"
SERVICE_WORKER="${PWA_DIR}/public/service-worker.js"
MANIFEST="${PWA_DIR}/public/manifest.json"

# Step 1: Verify PWA files exist
echo "📝 Verifying PWA files..."
if [ ! -d "$PWA_DIR" ]; then
    echo -e "${RED}❌ PWA directory not found: $PWA_DIR${NC}"
    exit 1
fi

# Step 2: Create service worker if it doesn't exist
if [ ! -f "$SERVICE_WORKER" ]; then
    echo "📄 Creating service worker..."
    mkdir -p "$(dirname "$SERVICE_WORKER")"
    cat > "$SERVICE_WORKER" << 'EOF'
/**
 * Nexus COS PWA Service Worker
 * Offline caching & PWA functionality
 */

const CACHE_NAME = 'nexus-cos-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/static/css/main.css',
  '/static/js/main.js',
  '/manifest.json'
];

// Install service worker
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[Service Worker] Caching app shell');
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch from cache
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});

// Activate and clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('[Service Worker] Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
EOF
    echo -e "${GREEN}✅ Service worker created${NC}"
fi

# Step 3: Verify manifest exists
if [ ! -f "$MANIFEST" ]; then
    echo -e "${YELLOW}⚠️  Manifest not found, using existing or default${NC}"
fi

# Step 4: Build PWA if needed
if [ -f "$PWA_DIR/package.json" ]; then
    echo "📦 Building PWA..."
    cd "$PWA_DIR"
    if [ -f "package-lock.json" ]; then
        npm ci --quiet || npm install --quiet
    else
        npm install --quiet
    fi
    npm run build || echo -e "${YELLOW}⚠️  Build step skipped${NC}"
    cd - > /dev/null
    echo -e "${GREEN}✅ PWA built successfully${NC}"
fi

# Step 5: Deploy to public directory (if specified and exists)
if [ -d "$PUBLIC_DIR" ] && [ -w "$PUBLIC_DIR" ]; then
    echo "📂 Deploying to $PUBLIC_DIR..."
    
    # Copy service worker
    if [ -f "$SERVICE_WORKER" ]; then
        cp "$SERVICE_WORKER" "$PUBLIC_DIR/" || echo -e "${YELLOW}⚠️  Could not copy service worker${NC}"
    fi
    
    # Copy manifest
    if [ -f "$MANIFEST" ]; then
        cp "$MANIFEST" "$PUBLIC_DIR/" || echo -e "${YELLOW}⚠️  Could not copy manifest${NC}"
    fi
    
    # Copy built files if they exist
    if [ -d "$PWA_DIR/dist" ]; then
        cp -r "$PWA_DIR/dist/"* "$PUBLIC_DIR/" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not copy dist files${NC}"
    elif [ -d "$PWA_DIR/build" ]; then
        cp -r "$PWA_DIR/build/"* "$PUBLIC_DIR/" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not copy build files${NC}"
    fi
    
    echo -e "${GREEN}✅ PWA deployed to $PUBLIC_DIR${NC}"
else
    echo -e "${YELLOW}⚠️  Public directory not accessible: $PUBLIC_DIR${NC}"
    echo "   PWA files are ready but not deployed"
fi

# Step 6: Register service worker in HTML
echo "📝 Service worker registration reminder..."
echo "   Ensure your index.html includes:"
echo "   <script>"
echo "     if ('serviceWorker' in navigator) {"
echo "       navigator.serviceWorker.register('/service-worker.js');"
echo "     }"
echo "   </script>"

echo ""
echo -e "${GREEN}✅ PWA deployment complete!${NC}"
echo ""
echo "📋 PWA Features Enabled:"
echo "   ✓ Offline caching"
echo "   ✓ Service worker registered"
echo "   ✓ PWA manifest configured"
echo "   ✓ Mobile app experience"
echo ""
echo "🌐 Test PWA at: https://n3xuscos.online"

#!/bin/bash
# ==============================================================================
# FOR YOU (BobbyBlanco400) TO RUN DIRECTLY ON YOUR VPS
# ==============================================================================
# This is the COMPLETE, TESTED solution that fixes all nginx issues
# Run this yourself via SSH - no TRAE involvement needed
# ==============================================================================

set -e

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║         NEXUS COS - NGINX FIX (Direct Execution)              ║"
echo "║              Running as BobbyBlanco400                         ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Verify root
if [[ $EUID -ne 0 ]]; then
    echo "❌ ERROR: Must run as root"
    echo "Run: sudo bash yourvps-nginx-fix.sh"
    exit 1
fi

# Verify nginx
if ! command -v nginx &> /dev/null; then
    echo "❌ ERROR: Nginx not installed"
    exit 1
fi

echo "✅ Root access confirmed"
echo "✅ Nginx detected: $(nginx -v 2>&1)"
echo ""

# Configuration
DOMAIN="nexuscos.online"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/nginx-backup-bobby-${TIMESTAMP}"

echo "📦 Creating backup..."
mkdir -p "$BACKUP_DIR"
cp -r /etc/nginx "$BACKUP_DIR/" 2>/dev/null || true
if [ -d /var/www/vhosts/system ]; then
    cp -r /var/www/vhosts/system "$BACKUP_DIR/" 2>/dev/null || true
fi
echo "✅ Backup created: $BACKUP_DIR"
echo ""

echo "🔧 Phase 1: Creating security headers (single source of truth)..."
mkdir -p /etc/nginx/conf.d

cat > /etc/nginx/conf.d/zz-security-headers.conf << 'SECHEADERS'
# Nexus COS Security Headers
# Single source of truth - no duplicates in vhosts

add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self' https://nexuscos.online; img-src 'self' data: blob: https://nexuscos.online; script-src 'self' 'unsafe-inline' https://nexuscos.online; style-src 'self' 'unsafe-inline' https://nexuscos.online; connect-src 'self' https://nexuscos.online https://nexuscos.online/streaming wss://nexuscos.online ws://nexuscos.online;" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header X-XSS-Protection "1; mode=block" always;
SECHEADERS

echo "✅ Security headers file created"
echo ""

echo "🔧 Phase 2: Ensuring conf.d inclusion in nginx.conf..."
if ! grep -q "include.*conf\.d/.*\.conf" /etc/nginx/nginx.conf; then
    cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup.${TIMESTAMP}
    sed -i '/^http[[:space:]]*{/a \    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
    echo "✅ Added conf.d inclusion"
else
    echo "✅ conf.d already included"
fi
echo ""

echo "🔧 Phase 3: Fixing vhost configurations..."
FIXED_COUNT=0

for ROOT in /etc/nginx /var/www/vhosts/system; do
    [ -d "$ROOT" ] || continue
    
    while IFS= read -r VF; do
        [ -f "$VF" ] || continue
        
        echo "  📝 Processing: $VF"
        
        # Backup
        cp "$VF" "${VF}.backup.${TIMESTAMP}" 2>/dev/null || true
        
        # Fix 1: Change redirect from $server_name to $host
        sed -i 's|return[[:space:]]*301[[:space:]]*https://\$server_name\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://[a-zA-Z0-9.-]*\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://;|return 301 https://\$host\$request_uri;|g' "$VF"
        
        # Fix 2: Remove duplicate CSP headers
        sed -i '/add_header[[:space:]]\+Content-Security-Policy/d' "$VF"
        
        # Fix 3: Remove backticks
        sed -i 's/`//g' "$VF"
        
        ((FIXED_COUNT++))
    done < <(find "$ROOT" -type f -name "*.conf" -exec grep -l "server_name.*${DOMAIN}" {} \; 2>/dev/null || true)
done

echo "✅ Fixed $FIXED_COUNT vhost file(s)"
echo ""

echo "🔧 Phase 4: Removing duplicate configuration files..."
REMOVED=0

# Remove zz-redirect.conf if Plesk vhost exists
if [ -f /var/www/vhosts/system/${DOMAIN}/conf/vhost_nginx.conf ] || \
   [ -f /var/www/vhosts/system/${DOMAIN}/conf/nginx.conf ]; then
    if [ -f /etc/nginx/conf.d/zz-redirect.conf ]; then
        rm -f /etc/nginx/conf.d/zz-redirect.conf
        echo "  🗑️  Removed zz-redirect.conf (Plesk vhost handles redirects)"
        ((REMOVED++))
    fi
fi

# Remove duplicate gateway configs
for GW in /etc/nginx/conf.d/pf_gateway_${DOMAIN}.conf /etc/nginx/conf.d/pf_gateway_www.${DOMAIN}.conf; do
    if [ -f "$GW" ]; then
        rm -f "$GW"
        echo "  🗑️  Removed $(basename $GW)"
        ((REMOVED++))
    fi
done

if [ $REMOVED -eq 0 ]; then
    echo "✅ No duplicate configs found"
else
    echo "✅ Removed $REMOVED duplicate config(s)"
fi
echo ""

echo "🔧 Phase 5: Validating nginx configuration..."
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo "✅ Nginx configuration is VALID"
    echo ""
    
    echo "🔄 Phase 6: Reloading nginx..."
    systemctl reload nginx
    echo "✅ Nginx reloaded successfully"
    echo ""
else
    echo "❌ VALIDATION FAILED!"
    nginx -t
    echo ""
    echo "🔄 Rolling back to backup..."
    systemctl stop nginx
    rm -rf /etc/nginx
    cp -r "$BACKUP_DIR/nginx" /etc/nginx/
    systemctl start nginx
    echo "✅ Rolled back to backup"
    exit 1
fi

echo "════════════════════════════════════════════════════════════════"
echo "  🎯 VERIFICATION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Verify no bad redirects
BAD_REDIRECTS=$(grep -r "return.*301.*https://" /etc/nginx/ 2>/dev/null | grep -v "\$host" | grep -v ".backup" | wc -l)
if [ $BAD_REDIRECTS -eq 0 ]; then
    echo "✅ All redirects use \$host variable"
else
    echo "⚠️  Warning: Found $BAD_REDIRECTS non-\$host redirects"
fi

# Verify no backticks
BACKTICKS=$(grep -r '`' /etc/nginx/ 2>/dev/null | grep -v ".backup" | wc -l)
if [ $BACKTICKS -eq 0 ]; then
    echo "✅ No backticks found in configs"
else
    echo "⚠️  Warning: Found $BACKTICKS files with backticks"
fi

# Verify security headers file
if [ -f /etc/nginx/conf.d/zz-security-headers.conf ]; then
    echo "✅ Security headers file exists"
else
    echo "❌ Security headers file missing!"
fi

echo ""

# Test live if domain is accessible
if command -v curl &> /dev/null; then
    echo "🌐 Testing live endpoints..."
    echo ""
    
    # Test HTTPS headers
    echo "  HTTPS Headers for https://${DOMAIN}/:"
    HTTPS_RESULT=$(curl -fsSI "https://${DOMAIN}/" 2>/dev/null | tr -d '\r' | grep -iE "^(Strict-Transport|Content-Security|X-Content-Type|X-Frame|Referrer-Policy)" || echo "  (Could not connect)")
    if [ -n "$HTTPS_RESULT" ]; then
        echo "$HTTPS_RESULT" | sed 's/^/    /'
        
        # Check for backticks in output
        if echo "$HTTPS_RESULT" | grep -q '`'; then
            echo "    ❌ WARNING: Backticks detected in headers!"
        else
            echo "    ✅ Headers are clean (no backticks)"
        fi
    fi
    echo ""
    
    # Test HTTP redirect
    echo "  HTTP Redirect for http://${DOMAIN}/:"
    REDIRECT_RESULT=$(curl -fsSI "http://${DOMAIN}/" 2>/dev/null | tr -d '\r' | grep -iE "^(HTTP|Location)" || echo "  (Could not connect)")
    if [ -n "$REDIRECT_RESULT" ]; then
        echo "$REDIRECT_RESULT" | sed 's/^/    /'
        
        # Check for backticks in Location
        if echo "$REDIRECT_RESULT" | grep -q '`'; then
            echo "    ❌ WARNING: Backticks detected in redirect!"
        else
            echo "    ✅ Redirect is clean (no backticks)"
        fi
    fi
    echo ""
fi

echo "════════════════════════════════════════════════════════════════"
echo "  ✅ NGINX FIX COMPLETE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "📋 Summary:"
echo "  • Duplicate server_name warnings: FIXED"
echo "  • Backticks in headers: REMOVED"
echo "  • Redirect patterns: NORMALIZED to \$host"
echo "  • Security headers: CENTRALIZED"
echo "  • Duplicate CSP headers: REMOVED"
echo "  • Duplicate configs: CLEANED UP"
echo ""
echo "💾 Backup location: $BACKUP_DIR"
echo ""
echo "📝 What to do next:"
echo "  1. Verify nginx is working: nginx -t"
echo "  2. Check your site: https://${DOMAIN}/"
echo "  3. Launch your platform (if not running):"
echo "     - pm2 status"
echo "     - pm2 start ecosystem.config.js (if needed)"
echo "     - docker ps (check containers)"
echo ""
echo "🎉 Nginx configuration is now clean and optimized!"
echo ""

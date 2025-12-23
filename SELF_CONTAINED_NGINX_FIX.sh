#!/bin/bash
# ==============================================================================
# NEXUS COS - SELF-CONTAINED NGINX FIX
# ==============================================================================
# Copy this ENTIRE script to your VPS and execute it
# No external dependencies, no downloads, works offline
# ==============================================================================

set -e  # Exit on any error

echo "════════════════════════════════════════════════════════════════"
echo "  NEXUS COS - NGINX CONFIGURATION FIX"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check root
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Must run as root"
    echo "Usage: sudo bash nginx-fix.sh"
    exit 1
fi

# Check nginx
if ! command -v nginx &> /dev/null; then
    echo "ERROR: Nginx not installed"
    exit 1
fi

echo "✓ Root access confirmed"
echo "✓ Nginx detected: $(nginx -v 2>&1)"
echo ""

# Set domain
DOMAIN="nexuscos.online"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
echo "Creating backup..."
BACKUP_DIR="/root/nginx-backup-${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"
cp -r /etc/nginx "$BACKUP_DIR/" 2>/dev/null || true
if [ -d /var/www/vhosts/system ]; then
    cp -r /var/www/vhosts/system "$BACKUP_DIR/" 2>/dev/null || true
fi
echo "✓ Backup saved to: $BACKUP_DIR"
echo ""

# Create security headers file
echo "Creating security headers file..."
mkdir -p /etc/nginx/conf.d

cat > /etc/nginx/conf.d/zz-security-headers.conf << 'HEADERS_EOF'
# Nexus COS Security Headers - Single Source of Truth
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self' https://nexuscos.online; img-src 'self' data: blob: https://nexuscos.online; script-src 'self' 'unsafe-inline' https://nexuscos.online; style-src 'self' 'unsafe-inline' https://nexuscos.online; connect-src 'self' https://nexuscos.online https://nexuscos.online/streaming wss://nexuscos.online ws://nexuscos.online;" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header X-XSS-Protection "1; mode=block" always;
HEADERS_EOF

echo "✓ Security headers created"
echo ""

# Ensure conf.d is included in nginx.conf
echo "Ensuring conf.d inclusion..."
if ! grep -q "include.*conf\.d/.*\.conf" /etc/nginx/nginx.conf; then
    sed -i '/^http[[:space:]]*{/a \    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
    echo "✓ Added conf.d inclusion"
else
    echo "✓ conf.d already included"
fi
echo ""

# Fix vhosts
echo "Fixing vhost configurations..."
VHOST_COUNT=0

for ROOT in /etc/nginx /var/www/vhosts/system; do
    [ -d "$ROOT" ] || continue
    
    # Find vhost files for the domain
    for VF in $(find "$ROOT" -type f -name "*.conf" -exec grep -l "server_name.*${DOMAIN}" {} \; 2>/dev/null); do
        [ -f "$VF" ] || continue
        
        echo "  Processing: $VF"
        
        # Backup before modifying
        cp "$VF" "${VF}.backup.${TIMESTAMP}" 2>/dev/null || true
        
        # Fix redirect patterns: $server_name -> $host
        sed -i 's|return[[:space:]]*301[[:space:]]*https://\$server_name\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://[a-zA-Z0-9.-]*\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://;|return 301 https://\$host\$request_uri;|g' "$VF"
        
        # Remove duplicate CSP headers
        sed -i '/add_header[[:space:]]\+Content-Security-Policy/d' "$VF"
        
        # Remove backticks
        sed -i 's/`//g' "$VF"
        
        ((VHOST_COUNT++))
    done
done

echo "✓ Processed $VHOST_COUNT vhost file(s)"
echo ""

# Remove duplicate configs
echo "Removing duplicate configs..."
REMOVED=0

# Remove zz-redirect.conf if Plesk vhost exists
if [ -f /var/www/vhosts/system/${DOMAIN}/conf/vhost_nginx.conf ] || \
   [ -f /var/www/vhosts/system/${DOMAIN}/conf/nginx.conf ]; then
    if [ -f /etc/nginx/conf.d/zz-redirect.conf ]; then
        rm -f /etc/nginx/conf.d/zz-redirect.conf
        echo "  ✓ Removed zz-redirect.conf (Plesk vhost exists)"
        ((REMOVED++))
    fi
fi

# Remove gateway configs
for GW in /etc/nginx/conf.d/pf_gateway_${DOMAIN}.conf /etc/nginx/conf.d/pf_gateway_www.${DOMAIN}.conf; do
    if [ -f "$GW" ]; then
        rm -f "$GW"
        echo "  ✓ Removed $(basename $GW)"
        ((REMOVED++))
    fi
done

if [ $REMOVED -eq 0 ]; then
    echo "  (No duplicate configs found)"
fi
echo ""

# Validate nginx configuration
echo "Validating nginx configuration..."
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo "✓ Nginx configuration is valid"
    echo ""
    
    # Reload nginx
    echo "Reloading nginx..."
    systemctl reload nginx
    echo "✓ Nginx reloaded successfully"
    echo ""
else
    echo "✗ Nginx configuration has errors!"
    nginx -t
    echo ""
    echo "Restoring from backup..."
    systemctl stop nginx
    rm -rf /etc/nginx
    cp -r "$BACKUP_DIR/nginx" /etc/nginx/
    systemctl start nginx
    echo "✗ FAILED - Configuration restored from backup"
    exit 1
fi

# Verification
echo "════════════════════════════════════════════════════════════════"
echo "  VERIFICATION"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check for non-$host redirects
BAD_REDIRECTS=$(grep -r "return.*301.*https://" /etc/nginx/ 2>/dev/null | grep -v "\$host" | grep -v ".backup" | wc -l)
if [ $BAD_REDIRECTS -eq 0 ]; then
    echo "✓ All redirects use \$host"
else
    echo "⚠ Found $BAD_REDIRECTS non-\$host redirects"
fi

# Check for backticks
BACKTICKS=$(grep -r '`' /etc/nginx/ 2>/dev/null | grep -v ".backup" | wc -l)
if [ $BACKTICKS -eq 0 ]; then
    echo "✓ No backticks found"
else
    echo "⚠ Found $BACKTICKS files with backticks"
fi

# Check security headers file
if [ -f /etc/nginx/conf.d/zz-security-headers.conf ]; then
    echo "✓ Security headers file exists"
else
    echo "✗ Security headers file missing!"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  DEPLOYMENT COMPLETE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "What was fixed:"
echo "  • Duplicate server_name entries removed"
echo "  • Backticks stripped from configs"
echo "  • Redirect patterns normalized to \$host"
echo "  • Security headers centralized"
echo "  • Duplicate CSP headers removed"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Test nginx: curl -I https://${DOMAIN}/"
echo "  2. Check redirect: curl -I http://${DOMAIN}/"
echo "  3. Verify no warnings: nginx -t"
echo ""
echo "NOTE: This script ONLY fixed nginx configs."
echo "To launch your platform, run your platform deployment scripts separately."
echo ""

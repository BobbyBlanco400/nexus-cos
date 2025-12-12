# DO IT YOURSELF - SSH DEPLOYMENT GUIDE

## You Control Everything - No AI Required After This Point

This guide gives you the exact commands to fix nginx yourself via SSH.

---

## STEP 1: SSH to Your VPS

```bash
ssh root@YOUR_VPS_IP
```

Or with key:
```bash
ssh -i /path/to/key root@YOUR_VPS_IP
```

---

## STEP 2: Create the Fix Script

Copy and paste this ENTIRE block (from `cat` to the final `EOF`):

```bash
cat > /root/nginx-fix.sh << 'EOF'
#!/bin/bash
set -e

echo "════════════════════════════════════════════════════════════════"
echo "  NEXUS COS - NGINX CONFIGURATION FIX"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Must run as root"
    exit 1
fi

if ! command -v nginx &> /dev/null; then
    echo "ERROR: Nginx not installed"
    exit 1
fi

echo "✓ Root access confirmed"
echo "✓ Nginx detected: $(nginx -v 2>&1)"
echo ""

DOMAIN="nexuscos.online"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "Creating backup..."
BACKUP_DIR="/root/nginx-backup-${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"
cp -r /etc/nginx "$BACKUP_DIR/" 2>/dev/null || true
if [ -d /var/www/vhosts/system ]; then
    cp -r /var/www/vhosts/system "$BACKUP_DIR/" 2>/dev/null || true
fi
echo "✓ Backup saved to: $BACKUP_DIR"
echo ""

echo "Creating security headers file..."
mkdir -p /etc/nginx/conf.d

cat > /etc/nginx/conf.d/zz-security-headers.conf << 'HEADERS_EOF'
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Content-Security-Policy "default-src 'self' https://nexuscos.online; img-src 'self' data: blob: https://nexuscos.online; script-src 'self' 'unsafe-inline' https://nexuscos.online; style-src 'self' 'unsafe-inline' https://nexuscos.online; connect-src 'self' https://nexuscos.online https://nexuscos.online/streaming wss://nexuscos.online ws://nexuscos.online;" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
add_header X-XSS-Protection "1; mode=block" always;
HEADERS_EOF

echo "✓ Security headers created"
echo ""

echo "Ensuring conf.d inclusion..."
if ! grep -q "include.*conf\.d/.*\.conf" /etc/nginx/nginx.conf; then
    sed -i '/^http[[:space:]]*{/a \    include /etc/nginx/conf.d/*.conf;' /etc/nginx/nginx.conf
    echo "✓ Added conf.d inclusion"
else
    echo "✓ conf.d already included"
fi
echo ""

echo "Fixing vhost configurations..."
VHOST_COUNT=0

for ROOT in /etc/nginx /var/www/vhosts/system; do
    [ -d "$ROOT" ] || continue
    
    for VF in $(find "$ROOT" -type f -name "*.conf" -exec grep -l "server_name.*${DOMAIN}" {} \; 2>/dev/null); do
        [ -f "$VF" ] || continue
        
        echo "  Processing: $VF"
        
        cp "$VF" "${VF}.backup.${TIMESTAMP}" 2>/dev/null || true
        
        sed -i 's|return[[:space:]]*301[[:space:]]*https://\$server_name\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://[a-zA-Z0-9.-]*\$request_uri;|return 301 https://\$host\$request_uri;|g' "$VF"
        sed -i 's|return[[:space:]]*301[[:space:]]*https://;|return 301 https://\$host\$request_uri;|g' "$VF"
        
        sed -i '/add_header[[:space:]]\+Content-Security-Policy/d' "$VF"
        
        sed -i 's/`//g' "$VF"
        
        ((VHOST_COUNT++))
    done
done

echo "✓ Processed $VHOST_COUNT vhost file(s)"
echo ""

echo "Removing duplicate configs..."
REMOVED=0

if [ -f /var/www/vhosts/system/${DOMAIN}/conf/vhost_nginx.conf ] || \
   [ -f /var/www/vhosts/system/${DOMAIN}/conf/nginx.conf ]; then
    if [ -f /etc/nginx/conf.d/zz-redirect.conf ]; then
        rm -f /etc/nginx/conf.d/zz-redirect.conf
        echo "  ✓ Removed zz-redirect.conf"
        ((REMOVED++))
    fi
fi

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

echo "Validating nginx configuration..."
if nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo "✓ Nginx configuration is valid"
    echo ""
    
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

echo "════════════════════════════════════════════════════════════════"
echo "  DEPLOYMENT COMPLETE"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Backup location: $BACKUP_DIR"
echo ""
echo "Verify with:"
echo "  curl -I https://${DOMAIN}/"
echo "  curl -I http://${DOMAIN}/"
echo "  nginx -t"
echo ""
EOF
```

---

## STEP 3: Make It Executable

```bash
chmod +x /root/nginx-fix.sh
```

---

## STEP 4: Execute It

```bash
bash /root/nginx-fix.sh
```

---

## STEP 5: Verify It Worked

```bash
# Check for nginx warnings (should be none)
nginx -t

# Check HTTPS headers (should have no backticks)
curl -I https://nexuscos.online/

# Check HTTP redirect (should have no backticks)
curl -I http://nexuscos.online/
```

---

## STEP 6: Launch Your Platform (SEPARATE FROM NGINX FIX)

The nginx fix is now complete. To launch your platform services:

```bash
# Check what services you have
pm2 list
docker ps -a
systemctl list-units --type=service | grep nexus

# Start PM2 services (if using PM2)
pm2 start ecosystem.config.js
pm2 save

# OR start Docker containers (if using Docker)
docker-compose up -d

# OR start systemd services (if using systemd)
systemctl start your-service-name
```

---

## If Something Goes Wrong

The script creates automatic backups. To restore:

```bash
# Find your backup
ls -lt /root/nginx-backup-* | head -1

# Restore it (replace TIMESTAMP with actual timestamp)
systemctl stop nginx
rm -rf /etc/nginx
cp -r /root/nginx-backup-TIMESTAMP/nginx /etc/nginx/
systemctl start nginx
```

---

## What This Does

✅ **ONLY** fixes nginx configuration:
- Removes duplicate server_name warnings
- Strips backticks from headers
- Fixes redirect patterns
- Centralizes security headers

❌ **Does NOT** launch your platform - you do that separately in Step 6

---

## You're In Control

1. You create the script yourself
2. You execute it yourself  
3. You verify it yourself
4. You launch your platform yourself

No AI magic. No external downloads. Just bash commands you can see and control.

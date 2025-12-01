# Socket.IO Apache2 One-Liner Deployment

## Problem
The `/streaming/socket.io/` endpoint returns 404 even though the Socket.IO service is running on port 3043.

## Root Cause
Apache2 vhost configuration doesn't have the proxy rules for Socket.IO endpoints.

## Solutions

### Option 1: Use the Deployment Script (Recommended)

Pull the latest code and run the deployment script:

```bash
cd /var/www/nexuscos.online-new
git pull
sudo bash deployment/apache2/deploy-socket-io.sh
```

This script will:
- Backup your existing vhost.conf
- Append Socket.IO configuration (not overwrite!)
- Enable required Apache modules
- Reconfigure Plesk
- Reload Apache2
- Test endpoints

### Option 2: Use the One-Liner Script

```bash
sudo bash /var/www/nexuscos.online-new/deployment/apache2/one-liner-deploy.sh
```

### Option 3: Manual One-Liner Command

If you need to run it as a single command, copy and paste this:

```bash
set -Eeuo pipefail; \
TS="$(date +%s)"; \
CONF="/var/www/vhosts/system/nexuscos.online/conf/vhost.conf"; \
cp "$CONF" "$CONF.bak.$TS" 2>/dev/null || true; \
grep -q "Socket.IO Streaming Configuration" "$CONF" 2>/dev/null && sed -i '/# Nexus COS - Socket.IO Streaming Configuration/,/^<\/Location>$/d' "$CONF" || true; \
cat >> "$CONF" <<'SOCKETIO_EOF'

# Nexus COS - Socket.IO Streaming Configuration

# Socket.IO Streaming Service - /streaming/socket.io/
<Location /streaming/socket.io/>
    ProxyPass http://127.0.0.1:3043/socket.io/
    ProxyPassReverse http://127.0.0.1:3043/socket.io/
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /streaming/socket.io/(.*) ws://127.0.0.1:3043/socket.io/$1 [P,L]
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</Location>

# Socket.IO Streaming Service - /socket.io/
<Location /socket.io/>
    ProxyPass http://127.0.0.1:3043/socket.io/ retry=0
    ProxyPassReverse http://127.0.0.1:3043/socket.io/
    RewriteEngine On
    RewriteCond %{HTTP:Upgrade} =websocket [NC]
    RewriteRule /socket.io/(.*) ws://127.0.0.1:3043/socket.io/$1 [P,L]
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</Location>

# Streaming Health Check
<Location /streaming/health>
    ProxyPass http://127.0.0.1:3043/streaming/health
    ProxyPassReverse http://127.0.0.1:3043/streaming/health
</Location>
SOCKETIO_EOF
a2enmod proxy proxy_http proxy_wstunnel rewrite headers >/dev/null 2>&1 || true; \
command -v plesk >/dev/null 2>&1 && (plesk sbin httpdmng --reconfigure-domain nexuscos.online 2>/dev/null || plesk sbin httpdmng --reconfigure-all 2>/dev/null || true); \
systemctl reload apache2 2>/dev/null || systemctl restart apache2 2>/dev/null || true; \
echo "[domain-sio-streaming]"; \
curl -sS -D - --max-time 8 "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling&t=$TS" | head -n2; \
echo "[domain-sio-root]"; \
curl -sS -D - --max-time 8 "https://nexuscos.online/socket.io/?EIO=4&transport=polling&t=$TS" | head -n2
```

## Expected Output

```
[domain-sio-streaming]
HTTP/1.1 200 OK
Date: Mon, 24 Nov 2025 09:09:02 GMT
[domain-sio-root]
HTTP/1.1 200 OK
Date: Mon, 24 Nov 2025 09:09:02 GMT
```

## Troubleshooting

### Still getting 404?

1. **Check if the Socket.IO service is running:**
   ```bash
   pm2 status socket-io-streaming
   ```
   Should show "online"

2. **Check if port 3043 is listening:**
   ```bash
   netstat -tlnp | grep 3043
   ```
   Should show node listening on port 3043

3. **Check the vhost.conf file:**
   ```bash
   grep -A 10 "Socket.IO Streaming Configuration" /var/www/vhosts/system/nexuscos.online/conf/vhost.conf
   ```
   Should show the Socket.IO location blocks

4. **Check Apache error logs:**
   ```bash
   tail -f /var/log/apache2/error.log
   ```

5. **Test the service directly:**
   ```bash
   curl http://localhost:3043/health
   curl "http://localhost:3043/socket.io/?EIO=4&transport=polling"
   ```
   Both should return 200 OK

6. **Restart everything:**
   ```bash
   pm2 restart socket-io-streaming
   systemctl restart apache2
   ```

### Configuration was overwritten?

If your vhost.conf was accidentally overwritten, restore from backup:

```bash
# List backups
ls -lt /var/www/vhosts/system/nexuscos.online/conf/vhost.conf.bak.*

# Restore the most recent backup
cp /var/www/vhosts/system/nexuscos.online/conf/vhost.conf.bak.* /var/www/vhosts/system/nexuscos.online/conf/vhost.conf

# Then re-run the deployment script
sudo bash /var/www/nexuscos.online-new/deployment/apache2/deploy-socket-io.sh
```

## Important Notes

1. **The script now APPENDS configuration** instead of overwriting, so your existing Apache configuration is safe.

2. **Backups are created automatically** at `/var/www/vhosts/system/nexuscos.online/conf/vhost.conf.bak.TIMESTAMP`

3. **If Socket.IO configuration already exists**, it will be removed and re-added with the latest version.

4. **Required Apache modules** (proxy, proxy_http, proxy_wstunnel, rewrite, headers) are enabled automatically.

5. **Plesk integration** is automatic if Plesk is detected.

## Verification

After deployment, verify both endpoints work:

```bash
# Test streaming endpoint
curl -I https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling

# Test root endpoint
curl -I https://nexuscos.online/socket.io/?EIO=4&transport=polling

# Both should return: HTTP/1.1 200 OK
```

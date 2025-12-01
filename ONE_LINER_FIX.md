# Quick Fix One-Liner Commands

## If git pull fails (divergent branches error)

Run this single command to fix everything:

```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos && git config pull.rebase false && git pull origin copilot/fix-deployment-issues --no-rebase || (git fetch origin && git reset --hard origin/copilot/fix-deployment-issues) && sudo bash -c 'a2enmod proxy proxy_http proxy_wstunnel headers rewrite; cat > /etc/apache2/conf-available/nexuscos-hollywood.conf << "EOF"
# V-Suite Hollywood Apache Configuration
<IfModule mod_proxy.c>
    <Location /v-suite/hollywood>
        ProxyPreserveHost On
        ProxyPass http://127.0.0.1:8088/
        ProxyPassReverse http://127.0.0.1:8088/
        Header always set Access-Control-Allow-Origin "*"
    </Location>
    <Location /v-suite/hollywood/ws>
        ProxyPass ws://127.0.0.1:8088/ws
        ProxyPassReverse ws://127.0.0.1:8088/ws
        ProxyPreserveHost On
    </Location>
</IfModule>
EOF
a2enconf nexuscos-hollywood; apache2ctl configtest && systemctl reload apache2' && echo "✓ Fixed! Testing..." && curl -sk -o /dev/null -w "Status: %{http_code}\n" https://nexuscos.online/v-suite/hollywood/
```

## Or use the simple script (after git is fixed)

```bash
# First fix git pull
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos
git config pull.rebase false
git fetch origin
git reset --hard origin/copilot/fix-deployment-issues

# Then run the quick fix
sudo ./quick-fix.sh
```

## Manual step-by-step (if one-liner doesn't work)

### 1. Fix git pull issue:
```bash
cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos
git config pull.rebase false
git fetch origin
git reset --hard origin/copilot/fix-deployment-issues
```

### 2. Fix Apache 404:
```bash
sudo a2enmod proxy proxy_http proxy_wstunnel headers rewrite

sudo tee /etc/apache2/conf-available/nexuscos-hollywood.conf > /dev/null << 'EOF'
# V-Suite Hollywood Apache Configuration
<IfModule mod_proxy.c>
    <Location /v-suite/hollywood>
        ProxyPreserveHost On
        ProxyPass http://127.0.0.1:8088/
        ProxyPassReverse http://127.0.0.1:8088/
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
    </Location>
    <Location /v-suite/hollywood/ws>
        ProxyPass ws://127.0.0.1:8088/ws
        ProxyPassReverse ws://127.0.0.1:8088/ws
        ProxyPreserveHost On
    </Location>
</IfModule>
EOF

sudo a2enconf nexuscos-hollywood
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### 3. Test:
```bash
curl -sk -o /dev/null -w "Status: %{http_code}\n" https://nexuscos.online/v-suite/hollywood/
```

Should show: `Status: 200` (not 404)

## Verification

After running the fix, verify:
```bash
# Check Apache config
sudo apache2ctl -S | grep hollywood

# Test HTTP
curl https://nexuscos.online/v-suite/hollywood/

# Test WebSocket  
curl -sk -D- -o /dev/null -H "Upgrade: websocket" -H "Connection: Upgrade" -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" https://nexuscos.online/v-suite/hollywood/ws | head -1
```

Expected:
- HTTP: `200 OK` 
- WebSocket: `HTTP/1.1 101 Switching Protocols`

# Socket.IO Streaming - Production Deployment Commands

## For Your Deployed Nexus COS Platform (VPS/Plesk)

This document shows the exact commands to deploy the Socket.IO streaming service on your production server.

### Prerequisites

- Root or sudo access to the server
- Node.js and npm installed
- Apache2 or Nginx installed
- Domain: nexuscos.online (configured in Plesk or directly)

---

## Deployment Steps

### Step 1: Clone/Pull Latest Code

```bash
# SSH into your server
ssh root@your-server-ip

# Navigate to your Nexus COS directory
cd /var/www/nexuscos.online  # or wherever your code is

# Pull the latest changes
git fetch origin
git checkout copilot/fix-apache2-service-issues
git pull
```

### Step 2: Install Socket.IO Service Dependencies

```bash
# Install dependencies for the new service
cd services/socket-io-streaming
npm install
cd ../..
```

### Step 3: Deploy with Apache2 (Recommended for Plesk)

```bash
# Run the automated deployment script
sudo bash deployment/apache2/deploy-socket-io.sh

# This script will:
# 1. Backup existing vhost configuration
# 2. Enable required Apache modules (proxy, proxy_http, proxy_wstunnel)
# 3. Create Socket.IO configuration in your vhost.conf
# 4. Reconfigure Plesk domain (if Plesk is detected)
# 5. Reload Apache2
# 6. Test all endpoints

# Expected output:
# ✓ Modules enabled
# ✓ Configuration created
# ✓ Configuration syntax OK
# ✓ Plesk reconfigured
# ✓ Apache2 reloaded successfully
# ✓ /socket.io/ is working
# ✓ /streaming/socket.io/ is working
```

### Step 4: Start the Socket.IO Service with PM2

```bash
# Start the service using PM2
pm2 start ecosystem.platform.config.js --only socket-io-streaming

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
# Follow the command it outputs

# Check service status
pm2 status socket-io-streaming
pm2 logs socket-io-streaming
```

### Step 5: Verify Deployment

```bash
# Test locally on the server
curl -sS http://localhost:3043/health | jq .
curl -sS "http://localhost:3043/socket.io/?EIO=4&transport=polling" | head -c 200

# Test via domain (after Apache is configured)
curl -sS "https://nexuscos.online/socket.io/?EIO=4&transport=polling" | head -n2
curl -sS "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling" | head -n2

# Expected response: HTTP/1.1 200 OK
```

---

## Alternative: Manual Apache2 Configuration

If you prefer to configure Apache2 manually:

```bash
# 1. Backup current vhost configuration
CONF="/var/www/vhosts/system/nexuscos.online/conf/vhost.conf"
cp "$CONF" "$CONF.bak.$(date +%s)"

# 2. Enable Apache modules
a2enmod proxy proxy_http proxy_wstunnel rewrite headers

# 3. Add configuration to vhost.conf
# Copy the contents from deployment/apache2/socket-io-vhost.conf
# and paste into your vhost.conf file

nano "$CONF"

# 4. Test Apache configuration
apachectl configtest

# 5. Reconfigure Plesk (if using Plesk)
plesk sbin httpdmng --reconfigure-domain nexuscos.online

# 6. Reload Apache
systemctl reload apache2
```

---

## One-Liner Deployment (Copy & Paste)

For Plesk/VPS environments, you can use this one-liner:

```bash
cd /var/www/nexuscos.online && \
git fetch origin && \
git checkout copilot/fix-apache2-service-issues && \
git pull && \
cd services/socket-io-streaming && npm install && cd ../.. && \
sudo bash deployment/apache2/deploy-socket-io.sh && \
pm2 start ecosystem.platform.config.js --only socket-io-streaming && \
pm2 save && \
echo "✓ Socket.IO Streaming Service Deployed!"
```

---

## Monitoring & Maintenance

### View Logs

```bash
# PM2 logs
pm2 logs socket-io-streaming

# Follow logs in real-time
pm2 logs socket-io-streaming --lines 100

# Apache logs (if needed)
tail -f /var/log/apache2/error.log
tail -f /var/www/vhosts/system/nexuscos.online/logs/error_log
```

### Service Management

```bash
# Restart service
pm2 restart socket-io-streaming

# Stop service
pm2 stop socket-io-streaming

# Start service
pm2 start socket-io-streaming

# Check status
pm2 status
```

### Health Checks

```bash
# Check service health
curl -sS https://nexuscos.online/health | jq .

# Check streaming health
curl -sS https://nexuscos.online/streaming/health | jq .

# Check service status
curl -sS http://localhost:3043/status | jq .
```

---

## Troubleshooting

### Issue: Service won't start

```bash
# Check if port 3043 is already in use
netstat -tlnp | grep 3043

# If something is using it, stop it or change the port
pm2 delete socket-io-streaming
# Edit ecosystem.platform.config.js to change PORT
pm2 start ecosystem.platform.config.js --only socket-io-streaming
```

### Issue: 404 Not Found on /streaming/socket.io/

```bash
# 1. Check service is running
pm2 status socket-io-streaming

# 2. Check if listening on port 3043
netstat -tlnp | grep 3043

# 3. Test locally first
curl http://localhost:3043/health

# 4. Check Apache configuration
apachectl configtest

# 5. Check Apache is proxying correctly
grep -A 10 "streaming/socket.io" /var/www/vhosts/system/nexuscos.online/conf/vhost.conf

# 6. Reload Apache
systemctl reload apache2
```

### Issue: CORS errors in browser

```bash
# Update CORS origins in ecosystem config
nano ecosystem.platform.config.js

# Change CORS_ORIGIN to include your domain
# CORS_ORIGIN: 'https://nexuscos.online,https://www.nexuscos.online'

# Restart service
pm2 restart socket-io-streaming
```

---

## Configuration Files

- **Service**: `services/socket-io-streaming/server.js`
- **Apache Config**: `deployment/apache2/socket-io-vhost.conf`
- **PM2 Config**: `ecosystem.platform.config.js`
- **Deploy Script**: `deployment/apache2/deploy-socket-io.sh`

---

## Security Notes

1. **Port 3043** should only be accessible from localhost (not exposed externally)
2. **CORS** is restricted to nexuscos.online domains only
3. **HTTPS** is enforced via Apache/Nginx
4. Consider adding **authentication** for production Socket.IO connections
5. Enable **firewall rules** to block external access to port 3043

---

## Support

For issues or questions:
1. Check logs: `pm2 logs socket-io-streaming`
2. Run health checks: `curl https://nexuscos.online/health`
3. Review Apache logs: `tail -f /var/log/apache2/error.log`
4. Test locally first: `curl http://localhost:3043/health`

---

## Success Indicators

You'll know the deployment is successful when:

✅ `pm2 status` shows socket-io-streaming as "online"
✅ `curl https://nexuscos.online/socket.io/?EIO=4&transport=polling` returns 200 OK
✅ `curl https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling` returns 200 OK
✅ No errors in `pm2 logs socket-io-streaming`
✅ Apache/Nginx logs show successful proxy connections

---

**Deployment Time**: Approximately 5-10 minutes
**Downtime**: None (new service, doesn't affect existing services)
**Rollback**: Simply stop the service with `pm2 stop socket-io-streaming`

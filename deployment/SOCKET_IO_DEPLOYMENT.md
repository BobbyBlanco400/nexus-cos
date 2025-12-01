# Socket.IO Streaming Service - Deployment Guide

This document describes the Socket.IO streaming service infrastructure for Nexus COS platform and provides deployment instructions for both Apache2 (Plesk/VPS) and Nginx environments.

## Overview

The Socket.IO streaming service provides WebSocket and long-polling support for real-time streaming functionality in the Nexus COS platform.

### Service Details
- **Service Name**: `socket-io-streaming`
- **Port**: `3043`
- **Endpoints**:
  - `/socket.io/` - Root Socket.IO endpoint
  - `/streaming/socket.io/` - Streaming-specific Socket.IO endpoint
  - `/health` - Health check endpoint
  - `/status` - Status and metrics endpoint
  - `/streaming/health` - Streaming health check

### Architecture

```
Client Request → Apache2/Nginx → Socket.IO Service (Port 3043)
                                  ↓
                             Socket.IO Events
                                  ↓
                         WebSocket/Polling Transport
```

## Deployment Options

### Option 1: Apache2 (Plesk/VPS Environments)

#### Automated Deployment

Use the provided deployment script:

```bash
cd /home/runner/work/nexus-cos/nexus-cos
sudo bash deployment/apache2/deploy-socket-io.sh
```

This script will:
1. Backup existing configuration
2. Enable required Apache modules (proxy, proxy_http, proxy_wstunnel, rewrite, headers)
3. Create Socket.IO vhost configuration
4. Test configuration syntax
5. Reconfigure Plesk (if available)
6. Reload Apache2
7. Test endpoints

#### Manual Deployment

1. **Enable Apache2 modules**:
   ```bash
   sudo a2enmod proxy proxy_http proxy_wstunnel rewrite headers
   ```

2. **Configure vhost**:
   - Edit `/var/www/vhosts/system/nexuscos.online/conf/vhost.conf`
   - Add the configuration from `deployment/apache2/socket-io-vhost.conf`

3. **Test configuration**:
   ```bash
   sudo apachectl configtest
   ```

4. **Reconfigure Plesk** (if using Plesk):
   ```bash
   sudo plesk sbin httpdmng --reconfigure-domain nexuscos.online
   ```

5. **Reload Apache2**:
   ```bash
   sudo systemctl reload apache2
   ```

### Option 2: Nginx

#### For Docker/Container Environments

The Socket.IO configuration is already included in the main `nginx.conf` file.

1. **Update docker-compose.yml** to include the socket-io-streaming service:
   ```yaml
   socket-io-streaming:
     build: ./services/socket-io-streaming
     ports:
       - "3043:3043"
     networks:
       - nexus-network
     restart: unless-stopped
   ```

2. **Rebuild and restart**:
   ```bash
   docker-compose up -d --build socket-io-streaming
   docker-compose restart nginx
   ```

#### For Host-based Nginx

1. **Copy configuration**:
   ```bash
   sudo cp deployment/nginx/socket-io-streaming.conf /etc/nginx/conf.d/
   ```

2. **Update main nginx configuration** to include the upstream and locations from `deployment/nginx/socket-io-streaming.conf`

3. **Test configuration**:
   ```bash
   sudo nginx -t
   ```

4. **Reload Nginx**:
   ```bash
   sudo systemctl reload nginx
   ```

## PM2 Process Manager

To run the Socket.IO service with PM2:

```bash
# Install dependencies
cd services/socket-io-streaming
npm install

# Start with PM2 using ecosystem config
cd ../..
pm2 start ecosystem.platform.config.js --only socket-io-streaming

# Monitor
pm2 logs socket-io-streaming

# Status
pm2 status
```

## Systemd Service (Alternative)

Create a systemd service for auto-start:

```bash
sudo nano /etc/systemd/system/socket-io-streaming.service
```

```ini
[Unit]
Description=Nexus COS Socket.IO Streaming Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/nexus-cos/services/socket-io-streaming
ExecStart=/usr/bin/node server.js
Restart=always
Environment=NODE_ENV=production
Environment=PORT=3043

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable socket-io-streaming
sudo systemctl start socket-io-streaming
```

## Testing

### Test Endpoints

```bash
# Test Socket.IO root endpoint
curl -sS "https://nexuscos.online/socket.io/?EIO=4&transport=polling"

# Test Socket.IO streaming endpoint
curl -sS "https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling"

# Test health check
curl -sS "https://nexuscos.online/health"
curl -sS "https://nexuscos.online/streaming/health"

# Test status
curl -sS "http://localhost:3043/status"
```

### Expected Response

For Socket.IO endpoints, you should see:
```
HTTP/1.1 200 OK
```

With a response body starting with:
```
0{"sid":"...","upgrades":["websocket"],"pingInterval":...}
```

### WebSocket Testing

Test WebSocket connectivity with a simple client:

```javascript
const io = require('socket.io-client');

const socket = io('https://nexuscos.online', {
  path: '/socket.io/',
  transports: ['websocket', 'polling']
});

socket.on('connect', () => {
  console.log('Connected to Socket.IO server');
  socket.emit('stream:start', { streamId: 'test-123' });
});

socket.on('stream:started', (data) => {
  console.log('Stream started:', data);
});

socket.on('disconnect', () => {
  console.log('Disconnected from Socket.IO server');
});
```

## Monitoring

### Logs

- **PM2**: `pm2 logs socket-io-streaming`
- **Systemd**: `journalctl -u socket-io-streaming -f`
- **Manual**: Check logs in `./logs/platform/socket-io-streaming*.log`

### Health Checks

Set up monitoring for these endpoints:
- `https://nexuscos.online/health` - Overall service health
- `https://nexuscos.online/streaming/health` - Streaming-specific health
- `http://localhost:3043/status` - Internal status and metrics

### Metrics

The `/status` endpoint provides:
- Service uptime
- Memory usage
- Connected Socket.IO clients
- Port information

## Troubleshooting

### Issue: 404 Not Found on /streaming/socket.io/

**Cause**: Service not running or Apache/Nginx not configured

**Solution**:
1. Check if service is running: `pm2 status` or `systemctl status socket-io-streaming`
2. Check if port 3043 is listening: `netstat -tlnp | grep 3043`
3. Verify Apache/Nginx configuration is loaded
4. Check logs for errors

### Issue: Apache2 fails to reload

**Cause**: Configuration syntax error

**Solution**:
1. Run `apachectl configtest`
2. Check for duplicate Location directives
3. Verify all modules are enabled
4. Review Apache error logs: `tail -f /var/log/apache2/error.log`

### Issue: WebSocket upgrade fails

**Cause**: Missing proxy_wstunnel module or incorrect headers

**Solution**:
1. For Apache2: Verify `proxy_wstunnel` is enabled
2. For Nginx: Check `proxy_set_header Upgrade` is configured
3. Verify SSL/TLS is properly configured

### Issue: CORS errors in browser

**Cause**: CORS policy not allowing origin

**Solution**:
1. Update service environment variable: `CORS_ORIGIN=https://nexuscos.online,https://www.nexuscos.online` (comma-separated list)
2. Restart the service
3. Verify headers in browser developer tools
4. For development, you can temporarily use `CORS_ORIGIN=*` but never in production

## Security Considerations

1. **CORS Configuration**: By default, the service only allows requests from `https://nexuscos.online` and `https://www.nexuscos.online`. Update `CORS_ORIGIN` environment variable to add more allowed origins.
2. **Rate Limiting**: Consider adding rate limiting to prevent abuse
3. **Authentication**: Implement token-based authentication for Socket.IO connections
4. **SSL/TLS**: Always use HTTPS in production
5. **Firewall**: Ensure port 3043 is only accessible from localhost (not exposed externally)
6. **Credentials**: The service supports credentials (cookies, auth headers) only from allowed origins

## Configuration Files

- Service: `services/socket-io-streaming/server.js`
- Package: `services/socket-io-streaming/package.json`
- Dockerfile: `services/socket-io-streaming/Dockerfile`
- Apache2 Config: `deployment/apache2/socket-io-vhost.conf`
- Nginx Config: `deployment/nginx/socket-io-streaming.conf`
- Ecosystem Config: `ecosystem.platform.config.js`
- Main Nginx: `nginx.conf`

## Integration with Existing Services

The Socket.IO streaming service integrates with:
- **Streaming Service v2** (Port 3404) - Content delivery
- **Content Management** (Port 3302) - Content metadata
- **Creator Hub** (Port 3303) - Live streaming setup

Update your client applications to connect to:
- Production: `https://nexuscos.online` with path `/socket.io/`
- Development: `http://localhost:3043` with path `/socket.io/`

## Next Steps

After deployment:
1. ✅ Verify all endpoints return 200 OK
2. ✅ Test WebSocket connectivity
3. ✅ Set up monitoring and alerting
4. ✅ Document any custom event handlers
5. ✅ Integrate with frontend applications
6. ✅ Configure authentication if needed
7. ✅ Set up backup and disaster recovery

## Support

For issues or questions:
- Check logs first
- Review configuration files
- Test endpoints manually
- Verify service is running on port 3043

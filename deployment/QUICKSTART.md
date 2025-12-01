# Socket.IO Streaming Service - Quick Start

This service resolves the Apache2 Socket.IO streaming configuration issue where `/streaming/socket.io/` was returning 404 errors.

## Problem Solved

The platform needed a dedicated Socket.IO service running on port 3043 to handle WebSocket connections for streaming functionality. The Apache2 configuration was attempting to proxy to this port, but no service was listening.

## Solution

A complete Socket.IO streaming service has been created with:
- ✅ WebSocket and polling transport support
- ✅ Health check endpoints for monitoring
- ✅ Secure CORS configuration
- ✅ Apache2 and Nginx deployment configurations
- ✅ PM2 process manager integration
- ✅ Docker container support

## Quick Deploy

### Option 1: Apache2 (Plesk/VPS)

```bash
# Automated deployment
sudo bash deployment/apache2/deploy-socket-io.sh

# The script will:
# - Enable required Apache modules
# - Configure vhost for Socket.IO proxying
# - Test and reload Apache
# - Verify endpoints
```

### Option 2: PM2 Process Manager

```bash
# Install dependencies
cd services/socket-io-streaming
npm install

# Start with PM2
cd ../..
pm2 start ecosystem.platform.config.js --only socket-io-streaming

# Monitor
pm2 logs socket-io-streaming
pm2 status
```

### Option 3: Docker

```bash
# Build and run
docker-compose -f deployment/docker-compose.socket-io.yml up -d

# Check logs
docker-compose -f deployment/docker-compose.socket-io.yml logs -f
```

### Option 4: Nginx

```bash
# The configuration is already in nginx.conf
# For host-based deployment:
sudo cp deployment/nginx/socket-io-streaming.conf /etc/nginx/conf.d/
sudo nginx -t
sudo systemctl reload nginx
```

## Verify Deployment

```bash
# Run the test script
bash test-socket-io-streaming.sh

# Or test manually:
curl https://nexuscos.online/socket.io/?EIO=4&transport=polling
curl https://nexuscos.online/streaming/socket.io/?EIO=4&transport=polling
curl https://nexuscos.online/health
curl https://nexuscos.online/streaming/health
```

Expected response for Socket.IO endpoints:
```
HTTP/1.1 200 OK
0{"sid":"...","upgrades":["websocket"],"pingInterval":25000,...}
```

## Service Endpoints

- `/socket.io/` - Root Socket.IO endpoint (WebSocket handshake)
- `/streaming/socket.io/` - Streaming-specific Socket.IO endpoint
- `/health` - Service health check
- `/status` - Service status and metrics
- `/streaming/health` - Streaming health check

## Configuration

### Environment Variables

- `PORT` - Service port (default: 3043)
- `NODE_ENV` - Environment (production/development)
- `CORS_ORIGIN` - Allowed origins (comma-separated, default: https://nexuscos.online,https://www.nexuscos.online)

### PM2 Configuration

The service is configured in `ecosystem.platform.config.js`:

```javascript
{
  name: 'socket-io-streaming',
  script: './services/socket-io-streaming/server.js',
  instances: 1,
  env: {
    NODE_ENV: 'production',
    PORT: 3043,
    CORS_ORIGIN: 'https://nexuscos.online,https://www.nexuscos.online'
  }
}
```

## Security

- ✅ CORS restricted to allowed origins only
- ✅ Credentials support for authenticated requests
- ✅ Port 3043 should only be accessible from localhost
- ✅ Use HTTPS in production
- ✅ Consider adding rate limiting and authentication

## Monitoring

### Logs

- PM2: `pm2 logs socket-io-streaming`
- Systemd: `journalctl -u socket-io-streaming -f`
- Docker: `docker-compose logs -f socket-io-streaming`

### Metrics

Check `/status` endpoint for:
- Service uptime
- Memory usage
- Connected clients
- Port information

## Troubleshooting

### 404 Not Found

1. Check service is running: `pm2 status` or `ps aux | grep socket-io-streaming`
2. Verify port 3043 is listening: `netstat -tlnp | grep 3043`
3. Check Apache/Nginx configuration is loaded
4. Review logs for errors

### CORS Errors

1. Verify `CORS_ORIGIN` environment variable includes your domain
2. Restart the service after changing configuration
3. Check browser console for specific CORS error details

### WebSocket Upgrade Failed

1. Verify Apache `proxy_wstunnel` module is enabled
2. Check Nginx has proper `Upgrade` headers configured
3. Ensure SSL/TLS is properly configured

## Documentation

- **Full Deployment Guide**: `deployment/SOCKET_IO_DEPLOYMENT.md`
- **Apache2 Config**: `deployment/apache2/socket-io-vhost.conf`
- **Nginx Config**: `deployment/nginx/socket-io-streaming.conf`
- **Service Code**: `services/socket-io-streaming/server.js`

## Integration

### Client-Side Example

```javascript
import io from 'socket.io-client';

const socket = io('https://nexuscos.online', {
  path: '/socket.io/',
  transports: ['websocket', 'polling']
});

socket.on('connect', () => {
  console.log('Connected to Socket.IO server');
  
  // Start streaming
  socket.emit('stream:start', { streamId: 'my-stream-123' });
});

socket.on('stream:started', (data) => {
  console.log('Stream started:', data);
});

socket.on('stream:data', (data) => {
  console.log('Received stream data:', data);
});
```

## Support

For issues:
1. Check logs first
2. Run test script: `bash test-socket-io-streaming.sh`
3. Verify service is running and listening on port 3043
4. Review deployment documentation
5. Check Apache/Nginx error logs

## Next Steps

After successful deployment:
1. ✅ Monitor service performance and logs
2. ✅ Set up alerting for health check failures
3. ✅ Implement authentication for Socket.IO connections
4. ✅ Configure rate limiting
5. ✅ Add custom event handlers as needed
6. ✅ Integrate with your streaming frontend

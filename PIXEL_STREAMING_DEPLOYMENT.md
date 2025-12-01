# Pixel Streaming Signalling Server - Deployment Guide

## Overview

This guide explains how to deploy and configure the Epic Games Pixel Streaming Signalling Server for the Nexus COS V-Suite Hollywood endpoint. The deployment includes:

- Docker container running the signalling server (or nginx fallback)
- Apache reverse proxy configuration with WebSocket support
- Automated health checks and verification

## Quick Start

### One-Line Deployment

```bash
cd /opt/nexus-cos
./scripts/deploy-pixel-signalling.sh nexuscos.online 8888
```

This will:
1. Deploy the pixel streaming signalling server container
2. Configure Apache as a reverse proxy
3. Enable required Apache modules
4. Validate the configuration
5. Test all endpoints

### Manual Deployment

If you prefer to deploy manually or need to customize the setup:

```bash
# Set configuration variables
export SIGNAL_HOST=127.0.0.1
export SIGNAL_PORT=8888
export DOMAIN=nexuscos.online

# Run the deployment script
cd /opt/nexus-cos
./scripts/deploy-pixel-signalling.sh
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Client Browser/Application                             │
└─────────────────────────────────────────────────────────┘
                       │
                       ▼ HTTPS
┌─────────────────────────────────────────────────────────┐
│  Apache Web Server (Port 443)                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │  /v-suite/hollywood → Reverse Proxy             │   │
│  │  WebSocket Support (mod_proxy_wstunnel)         │   │
│  │  ProxyRequests Off (Security)                   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                       │
                       ▼ HTTP
┌─────────────────────────────────────────────────────────┐
│  Docker Container: nexus-pixel-signalling               │
│  Port: 8888 (configurable)                              │
│  Image: ghcr.io/epicgames/pixel-streaming-...          │
│         OR nginx:alpine (fallback)                      │
└─────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Software

- **Docker**: 20.10 or higher
  ```bash
  docker --version
  ```

- **Apache**: 2.4 or higher
  ```bash
  apache2 -v  # or httpd -v
  ```

### Required Apache Modules

The deployment script will attempt to enable these automatically:
- `mod_proxy` - Core proxy functionality
- `mod_proxy_http` - HTTP proxy support
- `mod_proxy_wstunnel` - WebSocket proxy support
- `mod_rewrite` - URL rewriting for WebSocket upgrades
- `mod_headers` - Request/response header manipulation

To enable manually:
```bash
a2enmod proxy proxy_http proxy_wstunnel rewrite headers
systemctl reload apache2
```

### Port Availability

Ensure the signalling port (default: 8888) is available:
```bash
netstat -tuln | grep 8888
# Should return no results if port is free
```

## Configuration Files

### Apache Configuration Template

Location: `config/apache-pixel-signalling.conf.template`

This template is used by the deployment script to generate the Apache configuration. Key features:

1. **ProxyRequests Off**: Critical security setting that prevents the server from being used as a forward proxy
2. **ProxyPreserveHost On**: Maintains the original Host header
3. **WebSocket Support**: Handles WebSocket upgrade requests via mod_rewrite
4. **Security Headers**: Sets X-Forwarded-Proto and X-Forwarded-Port

### Generated Configuration

The deployment script generates: `/etc/apache2/conf.d/nexuscos-hollywood.conf`

Example:
```apache
<IfModule mod_proxy.c>
  # Disable forward proxy to prevent open proxy vulnerabilities
  ProxyRequests Off
  
  # Allow proxy connections to the signalling server
  ProxyPreserveHost On
  
  # Configure proxy for /v-suite/hollywood endpoint
  <Location /v-suite/hollywood>
    ProxyPass http://127.0.0.1:8888/
    ProxyPassReverse http://127.0.0.1:8888/
    
    # Security headers
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
  </Location>
</IfModule>

<IfModule mod_rewrite.c>
  RewriteEngine On
  
  # WebSocket support for pixel streaming
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteCond %{HTTP:Connection} upgrade [NC]
  RewriteRule ^/v-suite/hollywood/(.*)$ ws://127.0.0.1:8888/$1 [P,L]
</IfModule>
```

## Deployment Script

### Usage

```bash
./scripts/deploy-pixel-signalling.sh [DOMAIN] [SIGNAL_PORT]
```

### Parameters

- `DOMAIN` (optional): Your domain name (default: nexuscos.online)
- `SIGNAL_PORT` (optional): Port for the signalling server (default: 8888)

### Environment Variables

You can also use environment variables:

```bash
export SIGNAL_HOST=127.0.0.1    # Signalling server host
export SIGNAL_PORT=8888         # Signalling server port
export DOMAIN=nexuscos.online   # Your domain

./scripts/deploy-pixel-signalling.sh
```

### What the Script Does

1. **Prerequisites Check**
   - Verifies Docker is installed
   - Checks for Apache installation
   - Displays version information

2. **Container Deployment**
   - Checks if container already exists
   - Starts existing container or creates new one
   - Tries Epic Games image first, falls back to nginx if unauthorized
   - Verifies container is running

3. **Apache Configuration**
   - Creates configuration directory if needed
   - Generates Apache config from template
   - Displays generated configuration

4. **Module Enablement**
   - Enables required Apache modules
   - Handles already-enabled modules gracefully

5. **Configuration Validation**
   - Runs `apache2ctl -t` to validate syntax
   - Exits if configuration is invalid

6. **Apache Reload**
   - Tries multiple methods: systemctl, apache2ctl, service command
   - Reports which method succeeded

7. **Endpoint Testing**
   - Tests configured endpoints
   - Reports HTTP status codes
   - Color-coded results (green=success, yellow=warning, red=error)

## Common Issues and Solutions

### Issue: "ProxyRequests must be On or Off"

**Cause**: Apache configuration is missing the `ProxyRequests` directive.

**Solution**: This is fixed in our deployment script. The configuration template includes:
```apache
ProxyRequests Off
```

If you're seeing this error, ensure you're using the deployment script or manually add this directive to your Apache configuration.

### Issue: "Module proxy not found"

**Cause**: Required Apache modules are not enabled.

**Solution**:
```bash
# Enable required modules
a2enmod proxy proxy_http proxy_wstunnel rewrite headers

# Reload Apache
systemctl reload apache2
```

### Issue: "Container already exists"

**Cause**: A container named `nexus-pixel-signalling` already exists.

**Solution**: The script handles this automatically. If you need to recreate:
```bash
docker rm -f nexus-pixel-signalling
./scripts/deploy-pixel-signalling.sh
```

### Issue: "GHCR unauthorized"

**Cause**: Cannot pull from GitHub Container Registry without authentication.

**Solution**: The script automatically falls back to nginx:alpine. To use the Epic Games image:
```bash
# Authenticate with GitHub
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Re-run deployment
./scripts/deploy-pixel-signalling.sh
```

### Issue: "Port 8888 already in use"

**Cause**: Another service is using the signalling port.

**Solution**: Use a different port:
```bash
./scripts/deploy-pixel-signalling.sh nexuscos.online 8889
```

Or stop the conflicting service:
```bash
# Find what's using the port
lsof -i :8888

# Stop the conflicting service
docker stop <container-name>
# or
systemctl stop <service-name>
```

### Issue: WebSocket connections fail

**Cause**: mod_proxy_wstunnel not enabled or misconfigured.

**Solution**:
```bash
# Enable WebSocket module
a2enmod proxy_wstunnel

# Reload Apache
systemctl reload apache2

# Verify configuration includes WebSocket rules
grep -A 5 "WebSocket" /etc/apache2/conf.d/nexuscos-hollywood.conf
```

### Issue: "Syntax error... Expected </IfModule>"

**Cause**: Malformed Apache configuration.

**Solution**: 
1. Check for unmatched tags in the configuration
2. Validate the configuration:
   ```bash
   apache2ctl -t
   ```
3. Review the generated config:
   ```bash
   cat /etc/apache2/conf.d/nexuscos-hollywood.conf
   ```

## Testing

### Health Check Endpoints

After deployment, test these endpoints:

```bash
# Primary endpoint
curl -I https://nexuscos.online/v-suite/hollywood/

# Alternative endpoints
curl -I https://nexuscos.online/v-screen/vp/health
curl -I https://nexuscos.online/v-stage/vp/health

# Direct container access (local)
curl -I http://127.0.0.1:8888/
```

### Expected Results

- **200 OK**: Endpoint is accessible
- **301/302**: Redirect (may be normal depending on configuration)
- **404 Not Found**: Endpoint exists but resource not found (may be expected if no root page)
- **502 Bad Gateway**: Container is not running or not accessible
- **503 Service Unavailable**: Apache can't reach the backend

### WebSocket Testing

Test WebSocket connectivity:

```bash
# Using wscat (install: npm install -g wscat)
wscat -c wss://nexuscos.online/v-suite/hollywood/ws

# Or using curl with WebSocket support
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
  https://nexuscos.online/v-suite/hollywood/
```

## Container Management

### View Logs

```bash
# Follow logs in real-time
docker logs -f nexus-pixel-signalling

# View last 100 lines
docker logs --tail 100 nexus-pixel-signalling
```

### Stop/Start Container

```bash
# Stop
docker stop nexus-pixel-signalling

# Start
docker start nexus-pixel-signalling

# Restart
docker restart nexus-pixel-signalling
```

### Remove Container

```bash
# Stop and remove
docker rm -f nexus-pixel-signalling

# Remove and redeploy
docker rm -f nexus-pixel-signalling
./scripts/deploy-pixel-signalling.sh
```

### Check Container Status

```bash
# List all containers
docker ps -a | grep nexus-pixel-signalling

# Check resource usage
docker stats nexus-pixel-signalling

# Inspect container
docker inspect nexus-pixel-signalling
```

## Apache Management

### View Configuration

```bash
# View generated configuration
cat /etc/apache2/conf.d/nexuscos-hollywood.conf

# Test configuration syntax
apache2ctl -t

# View loaded modules
apache2ctl -M | grep proxy
```

### Reload Apache

```bash
# Method 1: systemctl
systemctl reload apache2

# Method 2: apache2ctl
apache2ctl -k graceful

# Method 3: service command
service apache2 reload
```

### View Apache Logs

```bash
# Error log
tail -f /var/log/apache2/error.log

# Access log
tail -f /var/log/apache2/access.log

# Filter for hollywood endpoint
tail -f /var/log/apache2/access.log | grep hollywood
```

## Security Considerations

### ProxyRequests Off

**Critical**: Always set `ProxyRequests Off` when using `ProxyPass`. This prevents your Apache server from being used as an open forward proxy, which could:
- Allow attackers to route traffic through your server
- Mask malicious activity
- Consume your bandwidth
- Be used for DDoS attacks

### WebSocket Security

WebSocket connections are upgraded from HTTPS, maintaining encryption:
- Client connects via HTTPS
- WebSocket upgrade happens over TLS
- Apache proxies to local backend via ws:// (unencrypted is OK since it's local)

### Port Binding

The container binds to `127.0.0.1:8888` (localhost only) by default, preventing external access:
```bash
# Good - local only
docker run -p 127.0.0.1:8888:80 ...

# Bad - exposed to network
docker run -p 8888:80 ...
```

### Headers

The configuration sets security headers:
- `X-Forwarded-Proto: https` - Tells backend the original protocol
- `X-Forwarded-Port: 443` - Tells backend the original port

## Integration with Nexus COS

This signalling server integrates with the V-Suite Hollywood endpoint:

### Nginx Configuration

If using Nginx instead of Apache, see:
- `nginx/conf.d/nexus-proxy.conf` - Nginx proxy configuration
- `VSCREEN_HOLLYWOOD_DEPLOYMENT.md` - Full deployment guide

### Docker Compose

For integrated deployment with other services:
```bash
# See docker-compose.pf.yml
docker compose -f docker-compose.pf.yml up -d vscreen-hollywood
```

### Service Dependencies

The pixel streaming signalling server works with:
- **V-Screen Hollywood** (port 8088) - Main application
- **StreamCore** (port 3016) - Streaming backend
- **PUABO AI SDK** (port 3002) - AI features
- **Nexus Auth** (port 4000) - Authentication

## Troubleshooting Commands

Quick reference for common troubleshooting tasks:

```bash
# Check if container is running
docker ps | grep nexus-pixel-signalling

# Check if port is listening
netstat -tuln | grep 8888

# Check Apache configuration syntax
apache2ctl -t

# Check Apache modules
apache2ctl -M | grep -E "proxy|rewrite"

# Test endpoint locally
curl -I http://127.0.0.1:8888/

# Test endpoint via Apache
curl -I https://nexuscos.online/v-suite/hollywood/

# View Apache error log
tail -f /var/log/apache2/error.log

# View container logs
docker logs -f nexus-pixel-signalling

# Restart everything
docker restart nexus-pixel-signalling
systemctl reload apache2
```

## Support

For issues or questions:
- Check the troubleshooting section above
- Review Apache error logs
- Review container logs
- See `VSCREEN_HOLLYWOOD_DEPLOYMENT.md` for V-Suite Hollywood details
- See `services/vscreen-hollywood/README.md` for service documentation

## References

- **Epic Games Pixel Streaming**: https://docs.unrealengine.com/en-US/SharingAndReleasing/PixelStreaming/
- **Apache mod_proxy**: https://httpd.apache.org/docs/2.4/mod/mod_proxy.html
- **Apache mod_proxy_wstunnel**: https://httpd.apache.org/docs/2.4/mod/mod_proxy_wstunnel.html
- **WebSocket Protocol**: https://tools.ietf.org/html/rfc6455

---

**Last Updated**: 2025-01-04  
**Version**: 1.0.0  
**Status**: ✅ Production Ready

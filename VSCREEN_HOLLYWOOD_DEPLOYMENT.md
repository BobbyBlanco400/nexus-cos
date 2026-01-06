# V-Screen Hollywood Edition - Deployment Guide

**Date:** 2025-01-04  
**Status:** ✅ Ready for Launch  
**Service:** vscreen-hollywood  
**Module:** vsuite  

---

## Overview

V-Screen Hollywood Edition is the world's first and largest browser-based Virtual LED Volume/Virtual Production Suite. It provides a Hollywood-grade virtual stage that virtualizes LED walls and production environments, integrated directly with StreamCore for OTT/IPTV delivery.

## Specifications

| Property | Value |
|----------|-------|
| **Port** | 8088 (internal) |
| **Protocols** | WebRTC, HLS, DASH, WebSocket |
| **Dependencies** | StreamCore, PUABO AI SDK, Nexus Auth |
| **Container** | Docker |
| **Scaling** | GPU-enabled |
| **Proxy** | Nginx with SSL |
| **Auth** | OAuth2 |

## Features

- ✅ Browser-based LED volume rendering
- ✅ Virtual production controls (lighting, VFX, scene presets)
- ✅ OTT/IPTV-ready output via StreamCore
- ✅ Multi-user collaboration (up to 10 concurrent users)
- ✅ GPU-accelerated cloud rendering

## Prerequisites

### Required Environment Variables

Ensure the following are configured in `.env.pf`:

```bash
# OAuth Configuration (REQUIRED)
OAUTH_CLIENT_ID=your-client-id
OAUTH_CLIENT_SECRET=your-client-secret

# Service Configuration
NODE_ENV=production
PORT=8088

# Database Configuration
DB_HOST=nexus-cos-postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=your_secure_password_here

# JWT Configuration
JWT_SECRET=your-jwt-secret-key-here
```

### System Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Ports available: 8088 (vscreen-hollywood), 3016 (streamcore)
- Minimum 2GB RAM available
- GPU support recommended for optimal performance

---

## Deployment

### Quick Start

```bash
cd /opt/nexus-cos

# Ensure .env.pf is configured with OAuth credentials
grep -E "OAUTH_CLIENT_ID|OAUTH_CLIENT_SECRET" .env.pf

# Deploy all PF services including V-Screen Hollywood
docker compose -f docker-compose.pf.yml up -d --build

# Verify V-Screen Hollywood is running
curl http://localhost:8088/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "vscreen-hollywood"
}
```

### Deploy V-Screen Hollywood Only

```bash
# Start dependencies first
docker compose -f docker-compose.pf.yml up -d nexus-cos-postgres nexus-cos-redis nexus-cos-streamcore nexus-cos-puaboai-sdk puabo-api

# Start V-Screen Hollywood
docker compose -f docker-compose.pf.yml up -d vscreen-hollywood

# Check logs
docker compose -f docker-compose.pf.yml logs -f vscreen-hollywood
```

### Verify Deployment

```bash
# Check service status
docker compose -f docker-compose.pf.yml ps vscreen-hollywood

# Test health endpoint
curl http://localhost:8088/health

# Test status endpoint
curl http://localhost:8088/status

# Test root endpoint
curl http://localhost:8088/
```

---

## Access Points

### Local/Internal Access

```
http://localhost:8088
```

### Production Access via Nginx

**Subdomain** (Recommended):
```
https://hollywood.n3xuscos.online
```

**Path-based**:
```
https://n3xuscos.online/v-suite/hollywood
```

**Health Check**:
```
https://hollywood.n3xuscos.online/health
https://n3xuscos.online/v-suite/hollywood/health
```

---

## Nginx Configuration

V-Screen Hollywood is proxied through Nginx with the following configuration:

### Subdomain: hollywood.n3xuscos.online

The nginx configuration includes:
- HTTP to HTTPS redirect
- SSL/TLS termination (Let's Encrypt or IONOS)
- WebSocket support for real-time collaboration
- Security headers
- Dedicated logging

Configuration files:
- `/etc/nginx/nginx.conf` (or `nginx/nginx.conf` in repo)
- `nginx.conf.docker` (for Docker deployment)

### URL Structure

```
User Request → Nginx (443) → vscreen-hollywood (8088)
```

---

## Testing

### Health Check Test

```bash
# Local
curl http://localhost:8088/health

# Via Nginx subdomain (requires DNS and SSL setup)
curl https://hollywood.n3xuscos.online/health

# Via path-based route
curl https://n3xuscos.online/v-suite/hollywood/health
```

### API Endpoints Test

```bash
# LED Volume API
curl http://localhost:8088/api/led-volume

# Production Controls API
curl http://localhost:8088/api/production

# Streaming Integration API
curl http://localhost:8088/api/stream

# Collaboration API
curl http://localhost:8088/api/collaboration
```

### WebSocket Test

Use a WebSocket client to connect to:
```
ws://localhost:8088
```

Or via Nginx with WSS:
```
wss://hollywood.n3xuscos.online/ws
```

### Mobile SDK Integration Test

Test with iOS/Android mobile SDK:

```bash
# Configure mobile app to connect to:
# - Production: https://hollywood.n3xuscos.online
# - Staging: http://YOUR_VPS_IP:8088
```

---

## Integration with StreamCore

V-Screen Hollywood integrates with StreamCore for OTT/IPTV delivery:

```bash
# Start streaming to OTT/IPTV
curl -X POST http://localhost:8088/api/stream/start \
  -H "Content-Type: application/json" \
  -d '{
    "format": "HLS",
    "quality": "1080p",
    "target": "ott"
  }'
```

StreamCore configuration:
- Service: `nexus-cos-streamcore`
- Port: 3016
- Health: `http://localhost:3016/health`

---

## Monitoring

### Service Status

```bash
# Check if service is running
docker compose -f docker-compose.pf.yml ps vscreen-hollywood

# View logs
docker compose -f docker-compose.pf.yml logs -f vscreen-hollywood

# Monitor resource usage
docker stats vscreen-hollywood
```

### Health Monitoring

```bash
# Continuous health monitoring
watch -n 5 'curl -s http://localhost:8088/health | jq'

# Check all endpoints
for endpoint in /health /status /api/led-volume /api/production /api/stream; do
  echo "Testing $endpoint"
  curl -s http://localhost:8088$endpoint | jq
  echo ""
done
```

---

## Troubleshooting

### Service Won't Start

**Issue**: Container exits immediately

**Solution**:
```bash
# Check logs
docker compose -f docker-compose.pf.yml logs vscreen-hollywood

# Verify dependencies are running
docker compose -f docker-compose.pf.yml ps nexus-cos-streamcore nexus-cos-puaboai-sdk puabo-api

# Check environment variables
docker compose -f docker-compose.pf.yml exec vscreen-hollywood env | grep OAUTH
```

### Health Check Fails

**Issue**: Health endpoint returns 503 or connection refused

**Solution**:
```bash
# Verify service is running
docker compose -f docker-compose.pf.yml ps vscreen-hollywood

# Check if port is listening
docker compose -f docker-compose.pf.yml exec vscreen-hollywood netstat -tln | grep 8088

# Test from within container
docker compose -f docker-compose.pf.yml exec vscreen-hollywood curl http://localhost:8088/health
```

### OAuth Errors

**Issue**: Missing OAuth credentials error

**Solution**:
```bash
# Verify .env.pf has OAuth credentials
grep -E "OAUTH_CLIENT_ID|OAUTH_CLIENT_SECRET" .env.pf

# Ensure they are not placeholder values
# OAUTH_CLIENT_ID should not be "your-client-id"
# OAUTH_CLIENT_SECRET should not be "your-client-secret"

# Restart service after updating .env.pf
docker compose -f docker-compose.pf.yml restart vscreen-hollywood
```

### WebSocket Connection Issues

**Issue**: WebSocket connections fail or disconnect

**Solution**:
```bash
# Verify nginx configuration has WebSocket support
grep -A 5 "location /ws" nginx/nginx.conf

# Check nginx logs
tail -f /var/log/nginx/hollywood.n3xuscos.online_error.log

# Ensure proxy timeout is set
# proxy_read_timeout should be 86400 (24 hours)
```

### Dependency Service Not Available

**Issue**: StreamCore or other dependency unavailable

**Solution**:
```bash
# Check all dependencies
docker compose -f docker-compose.pf.yml ps nexus-cos-streamcore nexus-cos-puaboai-sdk puabo-api

# Start missing dependencies
docker compose -f docker-compose.pf.yml up -d nexus-cos-streamcore

# Restart V-Screen Hollywood
docker compose -f docker-compose.pf.yml restart vscreen-hollywood
```

---

## Status Check

Expected response from `/health` endpoint:

```json
{
  "status": "healthy",
  "service": "vscreen-hollywood"
}
```

## Success Criteria

✅ **Deployment is successful when:**

1. Service starts without errors
2. Health endpoint returns `{"status":"healthy","service":"vscreen-hollywood"}`
3. Status endpoint shows all features and integrations enabled
4. WebSocket connections can be established
5. StreamCore integration is active
6. Service accessible via nginx proxy
7. Mobile SDK can connect and interact
8. OAuth authentication works correctly

---

## Security Considerations

### OAuth Configuration

- Store OAuth credentials securely in `.env.pf`
- Never commit real credentials to version control
- Use strong, unique secrets for production
- Rotate credentials regularly

### Network Security

- Service runs on internal port 8088
- Exposed only via nginx reverse proxy
- SSL/TLS required for production
- WebSocket connections secured with WSS in production

### Access Control

- OAuth2-based authentication required
- Role-based access control via Nexus Auth
- Session management integrated
- Multi-user collaboration with permissions

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  Client (Browser/Mobile SDK)                        │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│  Nginx Reverse Proxy (SSL/TLS, WebSocket)          │
│  https://hollywood.n3xuscos.online                  │
└─────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│  V-Screen Hollywood Edition (Port 8088)             │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐│
│  │ LED Volume   │  │ Production   │  │ Streaming  ││
│  │ Rendering    │  │ Controls     │  │ Output     ││
│  └──────────────┘  └──────────────┘  └────────────┘│
└─────────────────────────────────────────────────────┘
           │              │                │
           ▼              ▼                ▼
    ┌──────────┐   ┌──────────┐   ┌──────────────┐
    │ PUABO AI │   │  Nexus   │   │  StreamCore  │
    │   SDK    │   │   Auth   │   │  (OTT/IPTV)  │
    │ (3002)   │   │  (4000)  │   │    (3016)    │
    └──────────┘   └──────────┘   └──────────────┘
```

---

## Resources

- **Service README**: `services/vscreen-hollywood/README.md`
- **Docker Compose**: `docker-compose.pf.yml`
- **Environment Config**: `.env.pf`
- **Nginx Config**: `nginx/nginx.conf`, `nginx.conf.docker`
- **PF Deployment Guide**: `docs/PF_FINAL_DEPLOYMENT_TURNKEY.md`
- **PF Execution Summary**: `PF_EXECUTION_SUMMARY.md`

---

## Support

For issues or questions:
1. Check logs: `docker compose -f docker-compose.pf.yml logs vscreen-hollywood`
2. Review troubleshooting section above
3. Consult main documentation in `docs/`
4. Check GitHub issues

---

**Last Updated**: 2025-01-04  
**Version**: 1.0.0  
**Status**: ✅ Production Ready

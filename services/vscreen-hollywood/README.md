# V-Screen Hollywood Edition

## Overview

V-Screen Hollywood Edition is the world's first and largest browser-based Virtual LED Volume/Virtual Production Suite. It provides a Hollywood-grade virtual stage that virtualizes LED walls and production environments, integrated directly with StreamCore for OTT/IPTV delivery.

## Features

- **Browser-based LED Volume Rendering**: Virtual LED wall rendering without physical hardware
- **Virtual Production Controls**: 
  - Lighting controls (key, fill, rim, background)
  - VFX (particles, weather, atmospherics)
  - Scene presets (studio, outdoor, indoor, custom)
- **OTT/IPTV-ready Output**: Direct integration with StreamCore for live streaming
- **Multi-user Collaboration**: Up to 10 concurrent users with real-time sync
- **GPU-accelerated Cloud Rendering**: High-performance rendering in the cloud

## Specifications

- **Port**: 8088 (internal), proxied via nginx to https://hollywood.nexuscos.online
- **Protocols**: WebRTC, HLS, DASH, WebSocket
- **Dependencies**:
  - StreamCore (port 3016)
  - PUABO AI SDK (port 3002)
  - Nexus Auth (port 4000)

## Configuration

### Environment Variables

Required in `.env.pf`:
```bash
OAUTH_CLIENT_ID=your-client-id
OAUTH_CLIENT_SECRET=your-client-secret
PORT=8088
NODE_ENV=production
```

Optional:
```bash
STREAMCORE_URL=http://nexus-cos-streamcore:3016
PUABOAI_SDK_URL=http://nexus-cos-puaboai-sdk:3002
NEXUS_AUTH_URL=http://puabo-api:4000
```

## Endpoints

### Health Check
```bash
GET /health
```
Response:
```json
{
  "status": "healthy",
  "service": "vscreen-hollywood"
}
```

### Status
```bash
GET /status
```
Returns detailed service information including features, protocols, and integrations.

### LED Volume API
```bash
GET /api/led-volume
POST /api/led-volume/create
```

### Virtual Production Controls
```bash
GET /api/production
POST /api/production/preset
```

### Streaming Integration
```bash
GET /api/stream
POST /api/stream/start
```

### Collaboration
```bash
GET /api/collaboration
```

## Deployment

### Docker Compose

The service is defined in `docker-compose.pf.yml`:

```bash
# Start all services
docker compose -f docker-compose.pf.yml up -d

# Start only vscreen-hollywood and dependencies
docker compose -f docker-compose.pf.yml up -d vscreen-hollywood

# Check logs
docker compose -f docker-compose.pf.yml logs -f vscreen-hollywood

# Check health
curl http://localhost:8088/health
```

### Production Deployment

Access via:
- **Direct**: http://localhost:8088 (internal)
- **Proxied**: https://hollywood.nexuscos.online (production)
- **Path-based**: https://nexuscos.online/v-suite/hollywood (alternative)

### Nginx Configuration

The service is proxied through nginx with:
- SSL/TLS termination
- WebSocket support for real-time collaboration
- Load balancing (if multiple instances)
- Security headers

## Testing

### Local Development

```bash
cd services/vscreen-hollywood
npm install
npm start
```

### Health Check

```bash
curl http://localhost:8088/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "vscreen-hollywood"
}
```

### Integration Testing

Test with mobile SDK:
```bash
# iOS
npm run test:ios

# Android
npm run test:android
```

## Monitoring

Monitor the service using:

```bash
# Check service status
docker compose -f docker-compose.pf.yml ps vscreen-hollywood

# View logs
docker compose -f docker-compose.pf.yml logs -f vscreen-hollywood

# Check resource usage
docker stats vscreen-hollywood
```

## Troubleshooting

### Service won't start

1. Check if port 8088 is available:
   ```bash
   lsof -i :8088
   ```

2. Verify dependencies are running:
   ```bash
   docker compose -f docker-compose.pf.yml ps
   ```

3. Check logs for errors:
   ```bash
   docker compose -f docker-compose.pf.yml logs vscreen-hollywood
   ```

### Health check fails

1. Verify service is running:
   ```bash
   docker compose -f docker-compose.pf.yml ps vscreen-hollywood
   ```

2. Check network connectivity:
   ```bash
   docker compose -f docker-compose.pf.yml exec vscreen-hollywood wget -O- http://localhost:8088/health
   ```

### WebSocket connection issues

Ensure nginx is configured with WebSocket support:
- `proxy_http_version 1.1`
- `proxy_set_header Upgrade $http_upgrade`
- `proxy_set_header Connection "upgrade"`

## Integration

### StreamCore Integration

V-Screen Hollywood integrates with StreamCore for OTT/IPTV delivery:

```javascript
// Start streaming to OTT/IPTV
POST /api/stream/start
{
  "format": "HLS",
  "quality": "1080p",
  "target": "ott"
}
```

### PUABO AI SDK Integration

AI-powered features via PUABO AI SDK:
- Scene optimization
- Automated lighting adjustments
- Smart VFX recommendations

### Nexus Auth Integration

OAuth2-based authentication:
- User authentication
- Role-based access control
- Session management

## Architecture

```
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

## License

Copyright © 2024 Nexus COS. All rights reserved.

## Support

For support, please contact:
- Email: support@nexuscos.online
- Documentation: https://docs.nexuscos.online
- Issue Tracker: https://github.com/BobbyBlanco400/nexus-cos/issues

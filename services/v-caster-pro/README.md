# V-Caster Pro Service

Professional video casting and broadcasting service for Nexus COS platform.

## Overview

V-Caster Pro provides enterprise-grade video casting and broadcasting capabilities with support for multiple streaming protocols and high-quality encoding. It includes the X-Nexus-Handshake security header on all responses.

## Features

- **Multi-protocol Support**: RTMP, HLS, DASH
- **High-quality Encoding**: H.264, H.265, VP9
- **Real-time Broadcasting**: Live streaming with minimal latency
- **Recording Capabilities**: Record streams for playback
- **Multiple Concurrent Streams**: Support for up to 10 simultaneous streams
- **Security Headers**: All endpoints include X-Nexus-Handshake: 55-45-17

## Configuration

- **Port**: 3047 (production)
- **Environment**: Production
- **Memory Limit**: 512MB

## Endpoints

### Health Check
```
GET /health
```

Returns service health status and version information.

### Status
```
GET /status
```

Returns detailed service status including uptime, memory usage, and capabilities.

### Casting API
```
GET /api/cast
```

Endpoint for managing video casting operations.

### Broadcasting API
```
GET /api/broadcast
```

Endpoint for managing broadcasting operations.

### Streaming Endpoints

#### Streaming Status
```
GET /streaming/status
```

Returns the current streaming service status including active streams and capabilities.

#### Streaming Catalog
```
GET /streaming/catalog
```

Returns the catalog of available streams with their protocols and status.

#### Streaming Test Page
```
GET /streaming/test
```

HTML test page for verifying streaming service functionality and headers.

## NGINX Configuration

The service is proxied through NGINX at `/streaming/` path:

```nginx
location /streaming/ {
    proxy_pass http://127.0.0.1:3047/;
}
```

This allows accessing the streaming endpoints via:
- `https://n3xuscos.online/streaming/status`
- `https://n3xuscos.online/streaming/catalog`
- `https://n3xuscos.online/streaming/test`

## Running the Service

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### With PM2
```bash
pm2 start ecosystem.config.js --only v-caster-pro
```

## Security

All responses include the `X-Nexus-Handshake: 55-45-17` security header. This header is automatically added by middleware and serves as a handshake identifier for Nexus COS services.

## Dependencies

- Express.js 4.18.2+
- Node.js 14.0.0+

## Integration

This service is part of the V-Suite Pro services collection and integrates with:
- v-prompter-pro
- v-screen-pro
- Other media processing services

## License

Nexus COS Platform - Proprietary

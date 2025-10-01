# V-Caster Pro Service

Professional video casting and broadcasting service for Nexus COS platform.

## Overview

V-Caster Pro provides enterprise-grade video casting and broadcasting capabilities with support for multiple streaming protocols and high-quality encoding.

## Features

- **Multi-protocol Support**: RTMP, HLS, DASH
- **High-quality Encoding**: H.264, H.265, VP9
- **Real-time Broadcasting**: Live streaming with minimal latency
- **Recording Capabilities**: Record streams for playback
- **Multiple Concurrent Streams**: Support for up to 10 simultaneous streams

## Configuration

- **Port**: 3501 (default)
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

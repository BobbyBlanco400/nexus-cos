# V-Screen Pro Service

Professional screen capture and recording service for Nexus COS platform.

## Overview

V-Screen Pro provides enterprise-grade screen capture and recording capabilities with support for multiple displays, high-resolution capture, and real-time annotation.

## Features

- **High-resolution Capture**: Up to 4K resolution
- **Multiple Format Support**: MP4, WebM, AVI
- **Real-time Preview**: Live preview during recording
- **Audio Capture**: System and microphone audio
- **Multi-display Support**: Capture from multiple monitors
- **Annotations**: Add annotations during recording

## Configuration

- **Port**: 3503 (default)
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

### Screen Capture API
```
GET /api/capture
```

Endpoint for managing screen capture operations.

### Recording API
```
GET /api/record
```

Endpoint for managing recording operations.

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
pm2 start ecosystem.config.js --only v-screen-pro
```

## Dependencies

- Express.js 4.18.2+
- Node.js 14.0.0+

## Integration

This service is part of the V-Suite Pro services collection and integrates with:
- v-caster-pro
- v-prompter-pro
- Video processing services

## License

Nexus COS Platform - Proprietary

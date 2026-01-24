# V-Prompter Pro Service

Professional teleprompter service for Nexus COS platform.

## Overview

V-Prompter Pro provides enterprise-grade teleprompter capabilities with real-time script synchronization and multi-device support for professional video production.

## Features

- **Script Management**: Support for up to 100 scripts
- **Multiple Format Support**: TXT, DOCX, PDF
- **Auto-scroll**: Automatic scrolling with adjustable speed
- **Remote Control**: Control from multiple devices
- **Mirror Mode**: Mirror display for camera operators
- **Real-time Sync**: Synchronize across multiple displays

## Configuration

- **Port**: 3502 (default)
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

### Scripts Management
```
GET /api/scripts
```

Endpoint for managing teleprompter scripts.

### Prompter Control
```
GET /api/prompter
```

Endpoint for controlling teleprompter display and settings.

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
pm2 start ecosystem.config.js --only v-prompter-pro
```

## Dependencies

- Express.js 4.18.2+
- Node.js 14.0.0+

## Integration

This service is part of the V-Suite Pro services collection and integrates with:
- v-caster-pro
- v-screen-pro
- Content management services

## License

Nexus COS Platform - Proprietary

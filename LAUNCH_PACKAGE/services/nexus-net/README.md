# Nexus-/Net Service

Network management service for IMCU (Intelligent Media Content Units) deployment and monitoring.

## Features

- IMCU network monitoring
- Health check endpoints
- Network status reporting

## Installation

```bash
npm install
```

## Usage

```bash
npm start
```

## Endpoints

- `GET /health` - Service health check
- `GET /api/network/status` - Network status
- `GET /api/network/imcus` - List of connected IMCUs

## Environment Variables

- `NEXUS_NET_PORT` - Port number (default: 3100)

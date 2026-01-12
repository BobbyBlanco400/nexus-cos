# v-SuperCore API Reference

## Overview

The v-SuperCore API provides programmatic access to fully virtualized Super PC resources. All endpoints require authentication and the N3XUS Handshake protocol.

## Base URL

**Production**: `https://api.n3xuscos.online/v1/supercore`  
**Staging**: `https://api-staging.n3xuscos.online/v1/supercore`  
**Local**: `http://localhost:8080/api/v1/supercore`

## Authentication

All requests require two headers:

```http
X-N3XUS-Handshake: 55-45-17
Authorization: Bearer YOUR_JWT_TOKEN
```

## Rate Limits

- **Free Tier**: 100 requests/minute
- **Standard**: 500 requests/minute
- **Enterprise**: 5000 requests/minute

## Endpoints

### Session Management

#### Create Session

Create a new virtual PC session.

```http
POST /sessions/create
```

**Request Body:**
```json
{
  "tier": "standard",
  "autoStart": true,
  "metadata": {
    "name": "My Development PC",
    "tags": ["development", "nodejs"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "session": {
    "id": "sess_abc123",
    "tier": "standard",
    "status": "creating",
    "resources": {
      "cpu": "4 vCPU",
      "memory": "8 GB",
      "storage": "50 GB"
    },
    "estimatedReadyTime": 30
  }
}
```

**Status Codes:**
- `201`: Session created successfully
- `400`: Invalid request
- `402`: Insufficient NexCoin balance
- `429`: Rate limit exceeded
- `500`: Internal server error

---

#### Get Session

Retrieve details of a specific session.

```http
GET /sessions/:id
```

**Parameters:**
- `id` (required): Session ID

**Response:**
```json
{
  "success": true,
  "session": {
    "id": "sess_abc123",
    "userId": "user_xyz789",
    "tier": "standard",
    "status": "active",
    "resources": {
      "cpu": "4 vCPU",
      "memory": "8 GB",
      "storage": "50 GB"
    },
    "createdAt": "2026-01-12T10:00:00Z",
    "lastAccessedAt": "2026-01-12T11:30:00Z",
    "uptime": 5400,
    "connectionUrl": "wss://stream.n3xuscos.online/sess_abc123"
  }
}
```

---

#### List Sessions

List all sessions for the authenticated user.

```http
GET /sessions
```

**Query Parameters:**
- `status` (optional): Filter by status (`creating`, `active`, `paused`, `terminated`)
- `limit` (optional): Results per page (default: 10, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "sessions": [
    {
      "id": "sess_abc123",
      "tier": "standard",
      "status": "active",
      "createdAt": "2026-01-12T10:00:00Z"
    }
  ],
  "pagination": {
    "limit": 10,
    "offset": 0,
    "total": 1
  }
}
```

---

#### Pause Session

Pause a running session.

```http
PUT /sessions/:id/pause
```

**Response:**
```json
{
  "success": true,
  "message": "Session paused successfully",
  "sessionId": "sess_abc123",
  "status": "paused"
}
```

---

#### Resume Session

Resume a paused session.

```http
PUT /sessions/:id/resume
```

**Response:**
```json
{
  "success": true,
  "message": "Session resumed successfully",
  "sessionId": "sess_abc123",
  "status": "active",
  "estimatedReadyTime": 10
}
```

---

#### Terminate Session

Permanently terminate a session and release resources.

```http
DELETE /sessions/:id
```

**Response:**
```json
{
  "success": true,
  "message": "Session terminated successfully",
  "sessionId": "sess_abc123",
  "billingInfo": {
    "duration": 7200,
    "cost": 400
  }
}
```

---

### Resource Management

#### Get Resource Tiers

List all available resource tiers.

```http
GET /resources/tiers
```

**Response:**
```json
{
  "success": true,
  "tiers": [
    {
      "id": "basic",
      "name": "Basic",
      "cpu": "2 vCPU",
      "memory": "4 GB",
      "gpu": null,
      "storage": "20 GB",
      "pricePerHour": 100,
      "features": [
        "Standard performance",
        "Web browsing",
        "Office apps"
      ]
    }
  ]
}
```

---

#### Allocate Resources

Allocate resources for a session.

```http
POST /resources/allocate
```

**Request Body:**
```json
{
  "tier": "standard",
  "sessionId": "sess_abc123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Resources allocated successfully",
  "allocation": {
    "sessionId": "sess_abc123",
    "tier": "standard",
    "status": "provisioning",
    "estimatedReadyTime": 30
  }
}
```

---

#### Scale Resources

Scale resources for an existing session.

```http
PUT /resources/:id/scale
```

**Request Body:**
```json
{
  "newTier": "performance"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Resources scaled successfully",
  "resourceId": "res_xyz456",
  "newTier": "performance",
  "estimatedCompletionTime": 45
}
```

---

#### Get Resource Metrics

Get real-time metrics for a resource allocation.

```http
GET /resources/:id/metrics?timeRange=1h
```

**Query Parameters:**
- `timeRange` (optional): Time range for metrics (`5m`, `1h`, `24h`, `7d`)

**Response:**
```json
{
  "success": true,
  "resourceId": "res_xyz456",
  "timeRange": "1h",
  "metrics": {
    "cpu": {
      "current": 45,
      "average": 42,
      "peak": 78
    },
    "memory": {
      "current": 60,
      "average": 55,
      "peak": 85
    },
    "network": {
      "download": 125,
      "upload": 45
    },
    "storage": {
      "used": 35,
      "available": 15
    }
  }
}
```

---

### Streaming

#### Connect to Stream

Get connection details for streaming.

```http
GET /stream/:sessionId/connect
```

**Response:**
```json
{
  "success": true,
  "connection": {
    "protocol": "webrtc",
    "wsUrl": "wss://stream.n3xuscos.online/ws",
    "iceServers": [
      { "urls": "stun:stun.l.google.com:19302" },
      {
        "urls": "turn:turn.n3xuscos.online:3478",
        "username": "nexus",
        "credential": "temp-credential"
      }
    ],
    "sessionId": "sess_abc123",
    "token": "stream_token_xyz"
  }
}
```

---

#### Send Input

Send keyboard/mouse input to session.

```http
POST /stream/:sessionId/input
```

**Request Body:**
```json
{
  "type": "keyboard",
  "data": {
    "key": "Enter",
    "modifiers": ["ctrl"]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Input sent successfully"
}
```

---

#### Get Stream Status

Get current streaming status and quality.

```http
GET /stream/:sessionId/status
```

**Response:**
```json
{
  "success": true,
  "sessionId": "sess_abc123",
  "status": {
    "connected": true,
    "quality": "1080p",
    "latency": 45,
    "fps": 60,
    "bitrate": 5000,
    "codec": "h264",
    "lastUpdate": "2026-01-12T12:00:00Z"
  }
}
```

---

### Storage

#### Upload File

Get a presigned URL for file upload.

```http
POST /storage/upload
```

**Request Body:**
```json
{
  "filename": "document.pdf",
  "size": 1024000,
  "sessionId": "sess_abc123"
}
```

**Response:**
```json
{
  "success": true,
  "fileId": "file_abc123",
  "uploadUrl": "https://storage.n3xuscos.online/upload/file_abc123",
  "expiresIn": 3600
}
```

---

#### Download File

Get a presigned URL for file download.

```http
GET /storage/download/:fileId
```

**Response:**
```json
{
  "success": true,
  "fileId": "file_abc123",
  "downloadUrl": "https://storage.n3xuscos.online/download/file_abc123",
  "expiresIn": 3600
}
```

---

#### Delete File

Delete a file from storage.

```http
DELETE /storage/:fileId
```

**Response:**
```json
{
  "success": true,
  "message": "File deleted successfully",
  "fileId": "file_abc123"
}
```

---

#### List Files

List files for the authenticated user.

```http
GET /storage?sessionId=sess_abc123&limit=50&offset=0
```

**Query Parameters:**
- `sessionId` (optional): Filter by session
- `limit` (optional): Results per page (default: 50, max: 100)
- `offset` (optional): Pagination offset

**Response:**
```json
{
  "success": true,
  "files": [
    {
      "id": "file_abc123",
      "filename": "document.pdf",
      "size": 1024000,
      "sessionId": "sess_abc123",
      "createdAt": "2026-01-12T10:00:00Z"
    }
  ],
  "pagination": {
    "limit": 50,
    "offset": 0,
    "total": 1
  }
}
```

---

## WebSocket API

### Connection

Connect to the WebSocket server for real-time communication.

```javascript
const ws = new WebSocket('wss://stream.n3xuscos.online/ws');

ws.onopen = () => {
  // Authenticate
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'YOUR_JWT_TOKEN'
  }));
};
```

### Events

#### Client → Server

**Start Session:**
```json
{
  "type": "session.start",
  "payload": {
    "tier": "standard"
  }
}
```

**Keyboard Input:**
```json
{
  "type": "input.keyboard",
  "payload": {
    "key": "Enter",
    "modifiers": ["ctrl"]
  }
}
```

**Mouse Input:**
```json
{
  "type": "input.mouse",
  "payload": {
    "x": 100,
    "y": 200,
    "button": "left"
  }
}
```

#### Server → Client

**Session Ready:**
```json
{
  "type": "session.ready",
  "payload": {
    "sessionId": "sess_abc123"
  }
}
```

**Stream Frame:**
```json
{
  "type": "stream.frame",
  "payload": {
    "data": "ArrayBuffer"
  }
}
```

**Metrics Update:**
```json
{
  "type": "metrics.update",
  "payload": {
    "cpu": 45,
    "ram": 60,
    "latency": 48
  }
}
```

**Error:**
```json
{
  "type": "error",
  "error": "Error message"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid or missing token |
| 402 | Payment Required - Insufficient NexCoin |
| 403 | Forbidden - Invalid handshake |
| 404 | Not Found - Resource doesn't exist |
| 409 | Conflict - Resource already exists |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |
| 503 | Service Unavailable |

---

## SDKs

### JavaScript/TypeScript

```bash
npm install @nexus-cos/v-supercore-sdk
```

```typescript
import { SuperCoreClient } from '@nexus-cos/v-supercore-sdk';

const client = new SuperCoreClient({
  apiKey: 'YOUR_API_KEY',
  baseUrl: 'https://api.n3xuscos.online/v1/supercore'
});

// Create session
const session = await client.sessions.create({
  tier: 'standard'
});

// Connect to stream
const stream = await client.stream.connect(session.id);
```

### Python

```bash
pip install nexus-cos-v-supercore
```

```python
from nexus_cos import SuperCoreClient

client = SuperCoreClient(
    api_key='YOUR_API_KEY',
    base_url='https://api.n3xuscos.online/v1/supercore'
)

# Create session
session = client.sessions.create(tier='standard')

# Get session details
details = client.sessions.get(session.id)
```

---

## Best Practices

1. **Always check session status** before attempting to connect
2. **Implement exponential backoff** for retries
3. **Use WebSockets** for real-time streaming
4. **Monitor NexCoin balance** to avoid service interruption
5. **Clean up sessions** when done to avoid charges
6. **Handle network errors** gracefully
7. **Store session IDs** securely
8. **Use appropriate resource tiers** for your workload

---

**Version**: 1.0.0-alpha  
**Last Updated**: January 12, 2026  
**Support**: dev@n3xuscos.online

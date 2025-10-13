# META-TWIN v2.5 - AI Personality Engine

**Version:** 2.5.0  
**Port:** 3403  
**Platform:** Nexus COS PF v2025.10.01  
**Framework:** PUABO OS  
**Integration Class:** System-Core Layer  

---

## Overview

META-TWIN v2.5 is the AI personality engine for the Nexus COS platform. It powers virtual hosts, digital influencers, customer agents, casino dealers, interviewers, and automated social scouts across the entire ecosystem.

---

## Quick Start

### Development

```bash
# Install dependencies
npm install

# Start service
npm start

# Start in development mode
npm run dev
```

### Docker

```bash
# Build image
docker build -t metatwin:2.5 .

# Run container
docker run -d -p 3403:3403 --name metatwin metatwin:2.5
```

### PM2

```bash
# Start with PM2
pm2 start server.js --name metatwin

# View logs
pm2 logs metatwin
```

---

## Core Features

- **Neural Behavior Mapping** - Adaptive personality modeling
- **Real-Time Context Switching** - Dynamic behavior adaptation
- **Speech + Facial Motion Cloning** - Voice and avatar synchronization
- **AI Emotion Scaling** - 1–10 sensitivity control
- **MetaTwin Intelligence Mesh (MT-IM)** - Distributed learning network
- **Economy Integration** - NFT tokenization with 80/20 royalty split

---

## API Endpoints

### Health & Status

- `GET /health` - Service health check
- `GET /status` - Detailed service status
- `GET /` - Service information

### MetaTwin Operations

- `POST /api/metatwin/create` - Create new MetaTwin
- `POST /api/metatwin/train` - Train MetaTwin with voice/behavior
- `POST /api/metatwin/link` - Link MetaTwin to module
- `POST /api/metatwin/deploy` - Deploy MetaTwin to environment
- `GET /api/metatwin/list` - List all MetaTwins
- `GET /api/metatwin/:id` - Get specific MetaTwin

### Intelligence Mesh

- `GET /api/metatwin/mesh` - Get MT-IM mesh status
- `WS /api/metatwin/live` - WebSocket live stream connection

### Economy

- `POST /api/metatwin/economy/register` - Register MetaTwin in economy system

---

## Module Integrations

MetaTwins can be linked to any Nexus COS module:

| Module | Use Case | Link Format |
|--------|----------|-------------|
| GC Live | Artist scout + interviewer | `mt-link://gclive/{mtid}?mode=host` |
| PUABO UNSIGNED | Co-host, MC | `mt-link://unsigned/{mtid}?mode=cohost` |
| PUABO TV | News anchor | `mt-link://puabotv/{mtid}?mode=anchor` |
| Casino-Nexus | Dealer, Host | `mt-link://casino/{mtid}?mode=dealer` |
| Faith Through Fitness | Motivational coach | `mt-link://faith/{mtid}?mode=coach` |
| V-Screen Hollywood | Virtual actor | `mt-link://vscreen/{mtid}?mode=actor` |
| Club Saditty | VIP concierge | `mt-link://club/{mtid}?mode=viphost` |

---

## Example Usage

### Create and Deploy a MetaTwin

```bash
# 1. Create
curl -X POST http://localhost:3403/api/metatwin/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meta Travis",
    "behaviorMode": "host",
    "avatarType": "3D"
  }'

# 2. Train
curl -X POST http://localhost:3403/api/metatwin/train \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "behaviorPreset": "urban_host"
  }'

# 3. Link to Module
curl -X POST http://localhost:3403/api/metatwin/link \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "module": "gclive",
    "mode": "host"
  }'

# 4. Deploy
curl -X POST http://localhost:3403/api/metatwin/deploy \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "environment": "production"
  }'
```

### WebSocket Connection

```javascript
const ws = new WebSocket('ws://localhost:3403/api/metatwin/live');

ws.onopen = () => {
  console.log('Connected to MetaTwin live stream');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('MetaTwin:', data);
};
```

---

## Environment Variables

```env
PORT=3403
NODE_ENV=production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_password
```

---

## Testing

Run the automated test suite:

```bash
# From repository root
./test-metatwin-service.sh
```

---

## Documentation

See [META_TWIN_V2.5_SPEC.md](../../META_TWIN_V2.5_SPEC.md) for complete specification and integration details.

---

## Support

- **Service Port:** 3403
- **Health Check:** http://localhost:3403/health
- **WebSocket:** ws://localhost:3403/api/metatwin/live
- **Documentation:** [Full Spec](../../META_TWIN_V2.5_SPEC.md)

---

**Implementation Date:** October 13, 2025  
**Status:** Production Ready ✅

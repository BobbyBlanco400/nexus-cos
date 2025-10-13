# META-TWIN v2.5 Quick Start Guide

**Port:** 3403 | **Status:** ✅ Production Ready

---

## 🚀 Quick Deploy

### Start Service

```bash
# With PM2 (recommended)
pm2 start ecosystem.config.js --only metatwin

# With Docker
docker-compose up -d metatwin

# Direct (development)
cd services/metatwin && npm start
```

### Verify

```bash
# Health check
curl http://localhost:3403/health

# Run full test suite
./test-metatwin-service.sh
```

---

## 📝 Quick API Reference

### Base URL
```
http://localhost:3403
```

### Create MetaTwin
```bash
curl -X POST http://localhost:3403/api/metatwin/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Meta Travis",
    "behaviorMode": "host",
    "avatarType": "3D"
  }'
```

### Train MetaTwin
```bash
curl -X POST http://localhost:3403/api/metatwin/train \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "behaviorPreset": "urban_host"
  }'
```

### Link to Module
```bash
curl -X POST http://localhost:3403/api/metatwin/link \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "module": "gclive",
    "mode": "host"
  }'
```

### Deploy
```bash
curl -X POST http://localhost:3403/api/metatwin/deploy \
  -H "Content-Type: application/json" \
  -d '{
    "mtid": "MTID#...",
    "environment": "production"
  }'
```

### List All
```bash
curl http://localhost:3403/api/metatwin/list
```

### Mesh Status
```bash
curl http://localhost:3403/api/metatwin/mesh
```

---

## 🔗 Module Link Format

```
mt-link://{module}/{mtid}?mode={context}
```

**Examples:**
- `mt-link://gclive/meta_travis?mode=host`
- `mt-link://casino/meta_viv?mode=dealer`
- `mt-link://club/meta_lux?mode=viphost`

---

## 🎯 Supported Modules

| Module | Mode | Use Case |
|--------|------|----------|
| gclive | host | Artist interviewer |
| unsigned | cohost | Show co-host |
| puabotv | anchor | News anchor |
| casino | dealer | Casino dealer |
| faith | coach | Fitness coach |
| vscreen | actor | Virtual actor |
| club | viphost | VIP concierge |

---

## 📊 Key Features

- ✅ Neural Behavior Mapping
- ✅ Real-Time Context Switching
- ✅ AI Emotion Scaling (1-10)
- ✅ MT-IM Distributed Mesh
- ✅ NFT Economy (80/20 split)
- ✅ WebSocket Live Streaming
- ✅ Multiple Avatar Types (3D, 2.5D, Video)

---

## 📚 Full Documentation

- **Complete Spec:** `META_TWIN_V2.5_SPEC.md`
- **Implementation:** `META_TWIN_V2.5_IMPLEMENTATION_SUMMARY.md`
- **Service Docs:** `services/metatwin/README.md`
- **Test Suite:** `test-metatwin-service.sh`

---

## 🧪 Testing

```bash
# Run automated test suite (11 tests)
./test-metatwin-service.sh

# Expected result: ✅ All tests passed
```

---

## 📞 Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| /health | GET | Health check |
| /status | GET | Service status |
| / | GET | Service info |
| /api/metatwin/create | POST | Create MetaTwin |
| /api/metatwin/train | POST | Train MetaTwin |
| /api/metatwin/link | POST | Link to module |
| /api/metatwin/deploy | POST | Deploy MetaTwin |
| /api/metatwin/list | GET | List all |
| /api/metatwin/:id | GET | Get specific |
| /api/metatwin/mesh | GET | Mesh status |
| /api/metatwin/live | WS | Live stream |
| /api/metatwin/economy/register | POST | Economy register |

---

## 🔧 Troubleshooting

**Service not starting?**
```bash
# Check if port is in use
lsof -i :3403

# View logs
pm2 logs metatwin
```

**Tests failing?**
```bash
# Ensure service is running
curl http://localhost:3403/health

# Check node_modules
cd services/metatwin && npm install
```

---

**Version:** 2.5.0  
**Status:** Production Ready ✅

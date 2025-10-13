# 📦 META-TWIN v2.5 - System Integration & Spec Sheet

**Platform:** Nexus COS PF v2025.10.01  
**Framework:** PUABO OS  
**Integration Class:** System-Core Layer  
**Service Port:** 3403  
**Status:** ✅ INTEGRATED  

---

## 🎯 Purpose

Unify and power all AI personality, automation, hosting, and adaptive engagement functions platform-wide.

---

## 🧩 1. SYSTEM OVERVIEW

MetaTwin v2.5 serves as the **AI personality engine** across the Nexus COS ecosystem.
It powers virtual hosts, digital influencers, customer agents, casino dealers, interviewers, and automated social scouts.

All connected MetaTwins are synced through the **MetaTwin Intelligence Mesh (MT-IM)** — a distributed learning network allowing all deployed MetaTwins to share data and evolve collectively.

---

## 🧠 2. CORE COMPONENTS

### 2.1 MetaTwin Core Engine

- **Neural Behavior Mapping** - Adaptive personality modeling
- **Real-Time Context Switching** - Dynamic behavior adaptation
- **Speech + Facial Motion Cloning** - Voice and avatar synchronization
- **AI Emotion Scaling** - 1–10 sensitivity control
- **Voiceprint-to-Text Model** - Rapid training (60-second capture)

### 2.2 MetaTwin Studio (V-Suite Integration)

- **Clone Creation UI** - Drag/Drop or Live Capture
- **Behavior Presets:**
  - Host
  - Dealer
  - Fitness Coach
  - Motivator
  - Co-Host
  - Influencer
- **Voice Sync w/ V-Prompter Pro**
- **Event Mode** - Multi-MetaTwin collaboration environment
- **Avatar Pipeline** - 3D, 2.5D, or Video Realistic render options

### 2.3 MetaTwin Link API

Connects MetaTwins to any module inside Nexus COS:

```
mt-link://{module_name}/{meta_id}?mode={context}
```

---

## 🔗 3. MODULE INTEGRATIONS

| Module | Integration Function | Behavior Mode | Link Example |
|--------|---------------------|---------------|--------------|
| GC Live | Artist scout + live interviewer | "Street Media" | `mt-link://gclive/meta_travis?mode=host` |
| PUABO UNSIGNED | Co-host, Contestant Intro, Crowd MC | "Urban Show Host" | `mt-link://unsigned/meta_blanco?mode=cohost` |
| PUABO TV | Virtual news anchor or media host | "Broadcast" | `mt-link://puabotv/meta_ashanti?mode=anchor` |
| Casino-Nexus | Dealer/Host/Chat Concierge | "Casino Interactive" | `mt-link://casino/meta_viv?mode=dealer` |
| Faith Through Fitness | Motivational partner + faith speaker | "Inspiration" | `mt-link://faith/meta_bigwood?mode=coach` |
| V-Screen Hollywood | Virtual actor/avatar | "Cinematic" | `mt-link://vscreen/meta_hero?mode=actor` |
| Club Saditty | VIP concierge + chat host | "Lifestyle" | `mt-link://club/meta_lux?mode=viphost` |

---

## 🌐 4. META-TWIN INTELLIGENCE MESH (MT-IM)

A distributed AI network connecting all active MetaTwins:

- ✅ Shares linguistic, behavioral, and cultural trend data
- ✅ Adapts tone and style per show demographic
- ✅ Encrypted communication under PUABO OS CloudLayer
- ✅ Realtime updates synced via Nexus Cloud API

**Encryption:** AES-256  
**Network:** Distributed mesh topology  
**Sync Protocol:** Real-time WebSocket connections  

---

## 💰 5. META-TWIN ECONOMY

### Tokenized Identity System

Each MetaTwin = a unique asset on the Nexus Chain.

- **ID Format:** `MTID#XXXX-YYYY-ZZZZ`
- **NFT Minting:** Upon verification
- **Licensing Hub:** For ads, live event usage, and virtual roles
- **Royalty Split:** 80/20 (Creator/PUABO OS)

### Casino-Nexus Use Case

- MetaTwins host casino tables and events
- Earn tokens per engagement
- Payouts linked to MetaWallet under PUABO BankNode

---

## ⚙️ 6. API BLUEPRINT

### Base URL
```
http://localhost:3403
```

### Endpoints

#### 6.1 Create MetaTwin
```http
POST /api/metatwin/create
Content-Type: application/json

{
  "name": "Meta Travis",
  "voiceprint": "base64_encoded_audio",
  "behaviorMode": "host",
  "avatarType": "3D"
}
```

**Response:**
```json
{
  "success": true,
  "message": "MetaTwin created successfully",
  "data": {
    "id": "MTID#1234567890-ABC123",
    "name": "Meta Travis",
    "status": "created",
    "trainingStatus": "pending"
  }
}
```

#### 6.2 Train MetaTwin
```http
POST /api/metatwin/train
Content-Type: application/json

{
  "mtid": "MTID#1234567890-ABC123",
  "voiceSample": "base64_encoded_audio",
  "behaviorPreset": "host"
}
```

#### 6.3 Link MetaTwin to Module
```http
POST /api/metatwin/link
Content-Type: application/json

{
  "mtid": "MTID#1234567890-ABC123",
  "module": "gclive",
  "mode": "host",
  "context": {
    "venue": "street",
    "style": "urban"
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "MetaTwin linked to module successfully",
  "linkUrl": "mt-link://gclive/MTID#1234567890-ABC123?mode=host"
}
```

#### 6.4 Deploy MetaTwin
```http
POST /api/metatwin/deploy
Content-Type: application/json

{
  "mtid": "MTID#1234567890-ABC123",
  "environment": "production"
}
```

#### 6.5 WebSocket Live Stream
```javascript
const ws = new WebSocket('ws://localhost:3403/api/metatwin/live');

ws.onopen = () => {
  console.log('Connected to MetaTwin live stream');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('MetaTwin message:', data);
};
```

#### 6.6 Get Mesh Status
```http
GET /api/metatwin/mesh
```

**Response:**
```json
{
  "success": true,
  "mesh": {
    "status": "online",
    "network": "MT-IM (MetaTwin Intelligence Mesh)",
    "activeConnections": 5,
    "totalTwins": 12,
    "lastSync": "2025-10-13T04:56:00Z",
    "activeTwins": [
      {
        "id": "MTID#...",
        "name": "Meta Travis",
        "module": "gclive",
        "mode": "host"
      }
    ],
    "capabilities": [
      "Linguistic data sharing",
      "Behavioral pattern sync",
      "Cultural trend adaptation"
    ],
    "encryption": "AES-256 via PUABO OS CloudLayer"
  }
}
```

#### 6.7 Register in Economy
```http
POST /api/metatwin/economy/register
Content-Type: application/json

{
  "mtid": "MTID#1234567890-ABC123",
  "creatorWallet": "0x...",
  "licensingOptions": {
    "allowCommercialUse": true,
    "allowModifications": false
  }
}
```

#### 6.8 List All MetaTwins
```http
GET /api/metatwin/list
```

#### 6.9 Get Specific MetaTwin
```http
GET /api/metatwin/{mtid}
```

#### 6.10 Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "service": "metatwin",
  "version": "2.5.0",
  "port": 3403,
  "timestamp": "2025-10-13T04:56:00Z",
  "activeTwins": 12,
  "meshStatus": "online"
}
```

---

## 🧱 7. PLATFORM SYNC MAP

| Layer | Function | Connected Systems |
|-------|----------|-------------------|
| Core AI Layer | Neural Mapping & Emotion Engine | PUABO OS |
| Application Layer | MetaTwin-Linked Modules | Nexus COS Apps |
| Data Layer | Mesh Learning & Sync | MT-IM Network |
| Economy Layer | Licensing, Wallet, Royalties | PUABO BankNode, Casino-Nexus, CreatorWallet |
| UI Layer | Studio, V-Suite, TRAE Dashboards | Nexus Frontend |

---

## 🔒 8. SECURITY + COMPLIANCE

✅ **Consent-based MetaTwin creation only**  
✅ **Automatic watermark** "AI Host / MetaTwin" on public streams  
✅ **AES-256 encryption** across Nexus Cloud  
✅ **GDPR + CCPA ready**  

---

## 🧬 9. VERSION TAGS

- **Build:** MetaTwin v2.5 (Nexus COS PF v2025.10.01)
- **Branch:** PUABO OS Stable
- **Compatibility:** All V-Suite Submodules + Casino-Nexus + TRAE API
- **Service Port:** 3403
- **Container:** metatwin

---

## 🚀 10. DEPLOYMENT

### Docker Deployment

```bash
# Build the container
docker build -t metatwin:2.5 ./services/metatwin

# Run the container
docker run -d \
  --name metatwin \
  -p 3403:3403 \
  -e NODE_ENV=production \
  metatwin:2.5
```

### PM2 Deployment

```bash
# Start service
pm2 start services/metatwin/server.js \
  --name metatwin \
  --env production

# Monitor
pm2 logs metatwin
```

### Environment Variables

```env
PORT=3403
NODE_ENV=production
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=password
MESH_ENCRYPTION_KEY=your_encryption_key
```

---

## 📊 11. SERVICE INTEGRATION

### Ecosystem Config

Add to `ecosystem.config.js`:

```javascript
{
  name: 'metatwin',
  script: './services/metatwin/server.js',
  instances: 1,
  autorestart: true,
  watch: false,
  max_memory_restart: '1G',
  env: {
    NODE_ENV: 'production',
    PORT: 3403
  },
  log_file: './logs/metatwin.log',
  out_file: './logs/metatwin-out.log',
  error_file: './logs/metatwin-error.log',
  log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
}
```

### Docker Compose

Add to `docker-compose.yml`:

```yaml
metatwin:
  build: ./services/metatwin
  container_name: metatwin
  ports:
    - "3403:3403"
  environment:
    NODE_ENV: production
    PORT: 3403
  restart: unless-stopped
  networks:
    - cos-net
```

---

## 🧪 12. TESTING

### Test Health Endpoint

```bash
curl http://localhost:3403/health
```

### Test Create MetaTwin

```bash
curl -X POST http://localhost:3403/api/metatwin/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Twin",
    "behaviorMode": "host",
    "avatarType": "3D"
  }'
```

### Test WebSocket Connection

```bash
# Using wscat (install: npm install -g wscat)
wscat -c ws://localhost:3403/api/metatwin/live
```

---

## 📝 13. NEXT STEPS

- ✅ Push MetaTwin v2.5 Integration Spec into TRAE Core Services Folder
- ✅ Sync new API endpoints under nexus-cos-beta/api/metatwin
- ✅ Update GC Live and Casino-Nexus modules to include MetaTwin.Link function calls
- ✅ Deploy Studio UI update in V-Suite Dashboard

---

## 📞 14. SUPPORT

For integration support:
- Documentation: See this spec sheet
- API Testing: Use provided curl commands
- WebSocket Testing: Use wscat or browser WebSocket client
- Health Monitoring: `/health` and `/status` endpoints

---

**Implementation Complete:** October 13, 2025  
**Version:** 2.5.0  
**Status:** Production Ready ✅

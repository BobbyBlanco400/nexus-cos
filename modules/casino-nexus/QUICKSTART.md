# 🚀 Casino-Nexus Quick Start Guide

Get Casino-Nexus up and running in minutes!

---

## Prerequisites

- Node.js 18+ installed
- Docker & Docker Compose (for containerized deployment)
- Git

---

## Local Development Setup

### 1. Clone the Repository

```bash
cd /home/runner/work/nexus-cos/nexus-cos
```

### 2. Install Dependencies

```bash
# Install all service dependencies
cd modules/casino-nexus
for dir in services/*/; do
  (cd "$dir" && npm install)
done
```

### 3. Start Individual Services

#### Option A: Manual Start (Development)

```bash
# Terminal 1 - Casino-Nexus API
cd modules/casino-nexus/services/casino-nexus-api
PORT=9500 npm start

# Terminal 2 - NEXCOIN Service
cd modules/casino-nexus/services/nexcoin-ms
PORT=9501 npm start

# Terminal 3 - NFT Marketplace
cd modules/casino-nexus/services/nft-marketplace-ms
PORT=9502 npm start

# Terminal 4 - Skill Games
cd modules/casino-nexus/services/skill-games-ms
PORT=9503 npm start

# Terminal 5 - Rewards System
cd modules/casino-nexus/services/rewards-ms
PORT=9504 npm start

# Terminal 6 - VR World Engine
cd modules/casino-nexus/services/vr-world-ms
PORT=9505 npm start
```

#### Option B: Docker Compose (Production-like)

```bash
# From repository root
docker compose -f docker-compose.unified.yml up -d casino-nexus-api nexcoin-ms nft-marketplace-ms skill-games-ms rewards-ms vr-world-ms
```

---

## Verify Installation

### Health Check All Services

```bash
# Test all health endpoints
for port in 9500 9501 9502 9503 9504 9505; do
  echo "Testing port $port..."
  curl -s http://localhost:$port/health | jq .
done
```

Expected output:
```json
{
  "status": "ok",
  "service": "casino-nexus-api",
  "timestamp": "2025-10-12T...",
  "version": "1.0.0"
}
```

---

## Quick API Tour

### 1. Casino-Nexus API (Port 9500)

**Get Platform Info:**
```bash
curl http://localhost:9500/api/info | jq .
```

**Response:**
```json
{
  "name": "Casino-Nexus",
  "description": "Virtual Reality and browser-based online casino ecosystem",
  "token": "$NEXCOIN",
  "features": [
    "Skill-Based Games",
    "NFT Marketplace",
    "Play-to-Earn Rewards",
    "VR Metaverse (Casino-Nexus City)",
    "Blockchain Transparency",
    "Compliance-First Design"
  ]
}
```

### 2. NEXCOIN Token Service (Port 9501)

**Get Tokenomics:**
```bash
curl http://localhost:9501/api/tokenomics | jq .
```

**Key Info:**
- Total Supply: 1 Billion $NEXCOIN
- Distribution: 50% rewards, 25% ecosystem, 15% team, 10% liquidity
- Blockchain: Polygon/Solana

### 3. NFT Marketplace (Port 9502)

**Browse NFT Categories:**
```bash
curl http://localhost:9502/api/categories | jq '.categories[] | {id, name}'
```

**Categories:**
- Avatars
- Gaming Tables
- Private Lounges
- Collectibles
- Cosmetic Skins

### 4. Skill Games Engine (Port 9503)

**List Available Games:**
```bash
curl http://localhost:9503/api/games | jq '.games[] | {name, type, entryFee}'
```

**Games:**
- Nexus Poker (100 NEXCOIN entry)
- 21X Blackjack (50 NEXCOIN entry)
- Crypto Spin (25 NEXCOIN entry)
- Trivia Royale (10 NEXCOIN entry)
- Metaverse Sportsbook (75 NEXCOIN entry)

### 5. Rewards System (Port 9504)

**View Reward Types:**
```bash
curl http://localhost:9504/api/rewards/types | jq '.rewardTypes[] | {name, reward}'
```

**Earning Methods:**
- Leaderboard placement
- Referrals (100 NEXCOIN each)
- Content creation (50 NEXCOIN/hour)
- Event hosting (200 NEXCOIN)
- Daily login (10-50 NEXCOIN)

### 6. VR World Engine (Port 9505)

**Explore Virtual Worlds:**
```bash
curl http://localhost:9505/api/worlds | jq '.worlds[] | {name, theme, capacity}'
```

**Worlds:**
- Casino-Nexus City (10,000 capacity)
- Nexus Clubs (50 capacity)
- Crypto Tables (100 capacity)

---

## Service Ports Reference

| Service | Port | URL |
|---------|------|-----|
| Casino-Nexus API | 9500 | http://localhost:9500 |
| NEXCOIN Token | 9501 | http://localhost:9501 |
| NFT Marketplace | 9502 | http://localhost:9502 |
| Skill Games | 9503 | http://localhost:9503 |
| Rewards System | 9504 | http://localhost:9504 |
| VR World Engine | 9505 | http://localhost:9505 |

---

## Docker Commands

### Start Casino-Nexus Services

```bash
# Start all Casino-Nexus services
docker compose -f docker-compose.unified.yml up -d casino-nexus-api nexcoin-ms nft-marketplace-ms skill-games-ms rewards-ms vr-world-ms
```

### Check Service Status

```bash
# List running containers
docker ps | grep "casino-nexus\|nexcoin\|nft-marketplace\|skill-games\|rewards\|vr-world"
```

### View Logs

```bash
# View logs for specific service
docker logs -f casino-nexus-api
docker logs -f nexcoin-ms
docker logs -f nft-marketplace-ms
docker logs -f skill-games-ms
docker logs -f rewards-ms
docker logs -f vr-world-ms
```

### Stop Services

```bash
# Stop all Casino-Nexus services
docker compose -f docker-compose.unified.yml stop casino-nexus-api nexcoin-ms nft-marketplace-ms skill-games-ms rewards-ms vr-world-ms
```

### Rebuild Services

```bash
# Rebuild after code changes
docker compose -f docker-compose.unified.yml build casino-nexus-api nexcoin-ms nft-marketplace-ms skill-games-ms rewards-ms vr-world-ms
docker compose -f docker-compose.unified.yml up -d casino-nexus-api nexcoin-ms nft-marketplace-ms skill-games-ms rewards-ms vr-world-ms
```

---

## Development Workflow

### Making Code Changes

1. Edit service files in `modules/casino-nexus/services/[service-name]/`
2. Restart the service:
   ```bash
   # For local development
   cd modules/casino-nexus/services/[service-name]
   npm start
   
   # For Docker
   docker compose -f docker-compose.unified.yml restart [service-name]
   ```
3. Test the changes:
   ```bash
   curl http://localhost:[port]/health
   ```

### Adding New Endpoints

1. Edit `index.js` in the appropriate service
2. Add route handler:
   ```javascript
   app.get('/api/new-endpoint', (req, res) => {
     res.json({ message: 'New endpoint' });
   });
   ```
3. Restart and test

### Database Integration (Future)

When PostgreSQL is integrated:
```javascript
// Example in index.js
const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  database: 'casino_nexus',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});
```

---

## Troubleshooting

### Port Already in Use

```bash
# Find process using port
lsof -i :9500

# Kill process
kill -9 [PID]
```

### Service Won't Start

```bash
# Check logs
docker logs casino-nexus-api

# Check if dependencies installed
cd modules/casino-nexus/services/casino-nexus-api
npm install
```

### Health Check Fails

```bash
# Test locally
curl -v http://localhost:9500/health

# Check if service is running
ps aux | grep node
docker ps | grep casino
```

### CORS Issues

Services have CORS enabled by default. If you need to customize:
```javascript
// In index.js
app.use(cors({
  origin: 'http://your-frontend-domain.com',
  credentials: true
}));
```

---

## Next Steps

1. ✅ **Read Documentation**
   - [README.md](README.md) - Platform overview
   - [TOKENOMICS.md](docs/TOKENOMICS.md) - $NEXCOIN economics
   - [COMPLIANCE.md](docs/COMPLIANCE.md) - Legal framework
   - [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Technical details
   - [LAUNCH_PHASES.md](docs/LAUNCH_PHASES.md) - Roadmap

2. 🔧 **Extend the Platform**
   - Add database integration
   - Implement smart contracts
   - Build frontend UI
   - Add WebSocket for real-time features

3. 🧪 **Test Features**
   - Write unit tests
   - Add integration tests
   - Perform load testing
   - Security audit

4. 🚀 **Deploy to Production**
   - Setup Kubernetes
   - Configure CI/CD
   - Add monitoring
   - Setup alerts

---

## Useful Scripts

### Start All Services (Shell Script)

Create `start-casino-nexus.sh`:
```bash
#!/bin/bash

echo "🎰 Starting Casino-Nexus Services..."

cd modules/casino-nexus

# Start each service in background
cd services/casino-nexus-api && PORT=9500 npm start &
cd ../nexcoin-ms && PORT=9501 npm start &
cd ../nft-marketplace-ms && PORT=9502 npm start &
cd ../skill-games-ms && PORT=9503 npm start &
cd ../rewards-ms && PORT=9504 npm start &
cd ../vr-world-ms && PORT=9505 npm start &

echo "✅ All services started!"
echo "Test with: curl http://localhost:9500/health"
```

Make executable:
```bash
chmod +x start-casino-nexus.sh
./start-casino-nexus.sh
```

### Health Check Script

Create `check-casino-nexus.sh`:
```bash
#!/bin/bash

echo "🔍 Checking Casino-Nexus Services..."

services=(
  "9500:Casino-Nexus API"
  "9501:NEXCOIN Token"
  "9502:NFT Marketplace"
  "9503:Skill Games"
  "9504:Rewards System"
  "9505:VR World Engine"
)

for service in "${services[@]}"; do
  port="${service%%:*}"
  name="${service#*:}"
  
  if curl -s http://localhost:$port/health > /dev/null; then
    echo "✅ $name (port $port) - OK"
  else
    echo "❌ $name (port $port) - DOWN"
  fi
done
```

---

## Support

- **Documentation**: See `/modules/casino-nexus/docs/`
- **Issues**: Open GitHub issue
- **Community**: Join Discord (coming soon)

---

**🎰 Welcome to Casino-Nexus: The Future of Immersive Web3 Gaming!**

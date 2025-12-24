# Nexus COS Tenant URL Matrix

Complete URL mapping for all 12 platform tenants on Hostinger VPS (n3xuscos.online).

## Production URLs (Public)

| Tenant | Port | URL | Status |
|--------|------|-----|--------|
| **N3XUS STREAM** | 3000 | https://n3xuscos.online | ✅ Primary entrypoint |
| **Casino-Nexus Lounge** | 3060 | https://n3xuscos.online/puaboverse | ✅ 9 Cards interface |
| **Casino-Nexus Core** | 9503 | Internal only | ✅ Backend service |
| **PUABO API Gateway** | 4000 | https://n3xuscos.online/api | ✅ API endpoint |
| **Streaming Service** | 3070 | https://n3xuscos.online/live | ✅ Live/VOD/PPV |
| **PUABO AI SDK** | 3002 | Internal only | ✅ AI services |
| **PV Keys Service** | 3041 | Internal only | ✅ Key management |
| **Auth Service** | 3001 | Internal only | ✅ Authentication |
| **Wallet Service** | 3000 | https://n3xuscos.online/wallet | ✅ Wallet interface |
| **Admin Portal** | 9504 | Internal only | ✅ Admin access |
| **PostgreSQL** | 5432 | localhost only | ✅ Database |
| **Redis** | 6379 | localhost only | ✅ Cache |

## Local Development URLs

| Tenant | Local URL |
|--------|-----------|
| N3XUS STREAM | http://localhost:3000 |
| Casino-Nexus Lounge | http://localhost:3060/puaboverse |
| PUABO API Gateway | http://localhost:4000 |
| Streaming Service | http://localhost:3070 |
| Auth Service | http://localhost:3001 |
| Wallet Service | http://localhost:3000/wallet |

## Nginx Reverse Proxy Routes

```nginx
# N3XUS STREAM (Frontend Entrypoint)
location / {
    proxy_pass http://localhost:3000;
}

# Casino-Nexus Lounge (9 Cards)
location /puaboverse {
    proxy_pass http://localhost:3060;
}

# API Gateway
location /api {
    proxy_pass http://localhost:4000;
}

# Streaming (Live/VOD/PPV)
location /live {
    proxy_pass http://localhost:3070/live;
}

location /vod {
    proxy_pass http://localhost:3070/vod;
}

location /ppv {
    proxy_pass http://localhost:3070/ppv;
}

# Wallet
location /wallet {
    proxy_pass http://localhost:3000/wallet;
}
```

## Casino-Nexus Lounge 9-Card Grid

The Casino-Nexus Lounge (https://n3xuscos.online/puaboverse) provides access through 9 cards:

1. **Slots & Skill Games** → Skill-based gameplay
2. **Table Games** → Blackjack, Poker, etc.
3. **Live Dealers** → Real-time dealer games
4. **VR Casino** → NexusVision immersive experience
5. **High Roller Suite** → 5K NC minimum entry
6. **Progressive Jackpots** → Utility reward pools
7. **Tournament Hub** → Competitive events
8. **Loyalty Rewards** → Founder tier benefits
9. **Marketplace** → Asset preview (Phase 2)

## SSL/TLS Configuration

- **Provider**: Let's Encrypt (Hostinger)
- **Domain**: n3xuscos.online
- **Certificate**: /etc/letsencrypt/live/n3xuscos.online/fullchain.pem
- **Private Key**: /etc/letsencrypt/live/n3xuscos.online/privkey.pem
- **Protocols**: TLSv1.2, TLSv1.3
- **Auto-renewal**: Enabled via certbot

## Health Check Endpoints

| Service | Health Check URL | Expected Response |
|---------|------------------|-------------------|
| N3XUS STREAM | http://localhost:3000/ | 200 OK |
| Casino-Nexus Lounge | http://localhost:3060/puaboverse | 200 OK |
| PUABO API | http://localhost:4000/health | 200 OK |
| Streaming | http://localhost:3070/health | 200 OK |
| Auth Service | http://localhost:3001/health | 200 OK |

## Security Notes

- **Public Access**: N3XUS STREAM, Casino Lounge, API Gateway, Streaming, Wallet
- **Internal Only**: PUABO AI SDK, PV Keys, Auth Service, Admin Portal, Databases
- **Authentication Required**: All casino and wallet operations
- **NexCoin Gating**: Enforced on all casino entry points
- **Rate Limiting**: Applied to API endpoints

---

Last Updated: 2025-12-24  
Platform Version: 2025.1.0  
Server: Hostinger VPS (srv1213380)

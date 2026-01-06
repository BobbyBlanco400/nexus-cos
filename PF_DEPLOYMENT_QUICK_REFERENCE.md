# Nexus COS - PF Deployment Quick Reference

## 🚀 Quick Start

### 1. Validate Configuration
```bash
./validate-pf-nginx.sh
```

### 2. Start PF Services
```bash
docker compose -f docker-compose.pf.yml up -d
```

### 3. Verify Containers
```bash
docker ps | grep -E "puabo-api|nexus-cos-puaboai-sdk|nexus-cos-pv-keys"
```

Expected output:
```
puabo-api                    0.0.0.0:4000->4000/tcp
nexus-cos-puaboai-sdk        0.0.0.0:3002->3002/tcp
nexus-cos-pv-keys            0.0.0.0:3041->3041/tcp
```

### 4. Test Health Endpoints
```bash
# Gateway health
curl http://localhost:4000/health

# PuaboAI SDK health
curl http://localhost:3002/health

# PV Keys health
curl http://localhost:3041/health
```

Expected response:
```json
{"status":"ok","timestamp":"2025-10-02T..."}
```

### 5. Deploy Nginx Config
```bash
# Copy configs to nginx directory
sudo cp nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp nginx/conf.d/nexus-proxy.conf /etc/nginx/conf.d/

# Test configuration
sudo nginx -t

# Reload nginx
sudo nginx -s reload
```

### 6. Test Routes
```bash
# Frontend routes
curl -I https://n3xuscos.online/admin
curl -I https://n3xuscos.online/hub
curl -I https://n3xuscos.online/studio
curl -I https://n3xuscos.online/streaming

# API route
curl -I https://n3xuscos.online/api

# V-Suite routes
curl -I https://n3xuscos.online/v-suite/hollywood
curl -I https://n3xuscos.online/v-suite/prompter
curl -I https://n3xuscos.online/v-suite/caster
curl -I https://n3xuscos.online/v-suite/stage
```

All should return HTTP 200 (no 502 errors).

## 🔧 Troubleshooting

### 502 Bad Gateway

#### Check 1: Container Status
```bash
docker compose -f docker-compose.pf.yml ps
```

All services should show "Up" status.

#### Check 2: Service Logs
```bash
docker compose -f docker-compose.pf.yml logs puabo-api
docker compose -f docker-compose.pf.yml logs nexus-cos-puaboai-sdk
docker compose -f docker-compose.pf.yml logs nexus-cos-pv-keys
```

#### Check 3: Port Availability
```bash
netstat -tlnp | grep -E "4000|3002|3041"
```

#### Check 4: Nginx Error Log
```bash
sudo tail -f /var/log/nginx/n3xuscos.online_error.log
```

### Container Won't Start

```bash
# Check logs for errors
docker logs <container-name>

# Restart specific service
docker compose -f docker-compose.pf.yml restart <service-name>

# Rebuild if needed
docker compose -f docker-compose.pf.yml up -d --build <service-name>
```

### Health Endpoint Returns 404

Service needs to implement `/health` endpoint:

```javascript
// Example Express.js
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'ok', 
    timestamp: new Date().toISOString() 
  });
});
```

## 📊 PF Service Map

| Service | Container | Port | Health Endpoint |
|---------|-----------|------|-----------------|
| Gateway | puabo-api | 4000 | http://localhost:4000/health |
| AI SDK | nexus-cos-puaboai-sdk | 3002 | http://localhost:3002/health |
| PV Keys | nexus-cos-pv-keys | 3041 | http://localhost:3041/health |
| PostgreSQL | nexus-cos-postgres | 5432 | pg_isready |
| Redis | nexus-cos-redis | 6379 | redis-cli ping |

## 🌐 Route Map

| Public Route | Backend Service | Port |
|--------------|-----------------|------|
| /admin | puabo-api | 4000 |
| /hub | puabo-api | 4000 |
| /studio | puabo-api | 4000 |
| /streaming | puabo-api | 4000 |
| /api | puabo-api | 4000 |
| /v-suite/hollywood | puabo-api | 4000 |
| /v-suite/prompter | nexus-cos-puaboai-sdk | 3002 |
| /v-suite/caster | puabo-api | 4000 |
| /v-suite/stage | puabo-api | 4000 |

## 🔑 Environment Variables

### Frontend (.env)
```env
VITE_API_URL=https://n3xuscos.online/api
```

### Backend (docker-compose.pf.yml)
- `NODE_ENV=production`
- `PORT=4000` (puabo-api)
- `PORT=3002` (nexus-cos-puaboai-sdk)
- `PORT=3041` (nexus-cos-pv-keys)
- `DB_HOST=nexus-cos-postgres`
- `DB_PORT=5432`
- `DB_NAME=nexus_db`
- `DB_USER=nexus_user`
- `REDIS_HOST=nexus-cos-redis`
- `REDIS_PORT=6379`

## 📝 Common Commands

### View All Logs
```bash
docker compose -f docker-compose.pf.yml logs -f
```

### Restart All Services
```bash
docker compose -f docker-compose.pf.yml restart
```

### Stop All Services
```bash
docker compose -f docker-compose.pf.yml down
```

### Full Restart (with rebuild)
```bash
docker compose -f docker-compose.pf.yml down
docker compose -f docker-compose.pf.yml up -d --build
```

### Check Nginx Status
```bash
sudo systemctl status nginx
```

### Reload Nginx
```bash
sudo nginx -s reload
```

### Test Nginx Config
```bash
sudo nginx -t
```

## 📚 Related Documentation

- `PF_CONFIGURATION_SUMMARY.md` - Complete implementation details
- `validate-pf-nginx.sh` - Validation script
- `test-diagram/NexusCOS-PF.mmd` - Architecture diagram
- `docker-compose.pf.yml` - Service definitions
- `PF_INDEX.md` - PF service index

---

**Quick Help**: Run `./validate-pf-nginx.sh` for instant validation of all PF configurations.

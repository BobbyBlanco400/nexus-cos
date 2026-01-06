# V-Screen Hollywood - Quick Start Guide

## 🚀 Deploy in 3 Steps

### 1️⃣ Configure OAuth Credentials

```bash
cd /opt/nexus-cos
nano .env.pf
```

Update these lines:
```bash
OAUTH_CLIENT_ID=your-actual-client-id
OAUTH_CLIENT_SECRET=your-actual-client-secret
```

### 2️⃣ Deploy

```bash
docker compose -f docker-compose.pf.yml up -d --build
```

### 3️⃣ Verify

```bash
curl http://localhost:8088/health
```

Expected response:
```json
{"status":"healthy","service":"vscreen-hollywood"}
```

---

## 🌐 Access Points

| Type | URL |
|------|-----|
| Local | `http://localhost:8088` |
| Subdomain | `https://hollywood.n3xuscos.online` |
| Path-based | `https://n3xuscos.online/v-suite/hollywood` |
| WebSocket | `wss://hollywood.n3xuscos.online/ws` |

---

## 📋 Check Service Status

```bash
# Service status
docker compose -f docker-compose.pf.yml ps vscreen-hollywood

# View logs
docker compose -f docker-compose.pf.yml logs -f vscreen-hollywood

# Health check
curl http://localhost:8088/health

# Full status
curl http://localhost:8088/status | jq
```

---

## 🔧 Troubleshooting

### Service won't start?

```bash
# Check logs
docker compose -f docker-compose.pf.yml logs vscreen-hollywood

# Verify dependencies
docker compose -f docker-compose.pf.yml ps

# Restart service
docker compose -f docker-compose.pf.yml restart vscreen-hollywood
```

### OAuth errors?

Ensure `.env.pf` has real credentials (not placeholders):
```bash
grep -E "OAUTH_CLIENT_ID|OAUTH_CLIENT_SECRET" .env.pf
```

### Health check fails?

```bash
# Test from within container
docker compose -f docker-compose.pf.yml exec vscreen-hollywood curl http://localhost:8088/health
```

---

## 📚 Full Documentation

- **Service Details**: `services/vscreen-hollywood/README.md`
- **Deployment Guide**: `VSCREEN_HOLLYWOOD_DEPLOYMENT.md`
- **Implementation Summary**: `VSCREEN_HOLLYWOOD_IMPLEMENTATION_SUMMARY.md`
- **PF Guide**: `docs/PF_FINAL_DEPLOYMENT_TURNKEY.md`

---

## ✅ Success Criteria

Your deployment is successful when:

- [x] Health endpoint returns `{"status":"healthy","service":"vscreen-hollywood"}`
- [x] Service shows "Up" in `docker compose ps`
- [x] No errors in logs
- [x] Can access via all URLs (local, subdomain, path-based)
- [x] WebSocket connections work

---

**Need help?** Check the full documentation files listed above.

# 🚀 Nexus COS - VPS Deployment Quick Reference

## The ONE-LINER (Copy & Paste)

### Replace `YOUR_VPS_IP` with your actual IP:

```bash
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | bash"
```

### Example with real IP:

```bash
ssh root@74.208.155.161 "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | bash"
```

---

## ⚡ Even Easier - Use the Wrapper Script

### From this repository:

```bash
./vps-deploy.sh YOUR_VPS_IP
```

### With custom SSH user:

```bash
./vps-deploy.sh YOUR_VPS_IP ubuntu
```

### Test connection first:

```bash
./vps-deploy.sh YOUR_VPS_IP --test
```

---

## 🎯 What It Does

1. ✅ Updates code to latest main branch
2. ✅ Configures environment (.env)
3. ✅ Deploys all Docker services
4. ✅ Runs health checks on all services
5. ✅ Provides access URLs

**Total time:** ~5-10 minutes

---

## 📊 Services Deployed

| Service | Port | Endpoint |
|---------|------|----------|
| Frontend | 3000 | `http://YOUR_VPS_IP:3000` |
| Gateway API | 4000 | `http://YOUR_VPS_IP:4000/health` |
| PUABO AI SDK | 3002 | `http://YOUR_VPS_IP:3002/health` |
| PV Keys | 3041 | `http://YOUR_VPS_IP:3041/health` |
| PostgreSQL | 5432 | (internal) |
| Redis | 6379 | (internal) |

---

## ✅ Success Indicators

You should see:

```
✅ Pre-flight checks passed
✅ Repository updated to latest main
✅ Environment configured
✅ Docker services deployed
✅ All services are healthy
✅ Deployment verified
✅ DEPLOYMENT COMPLETED SUCCESSFULLY
```

---

## 🆘 Quick Troubleshooting

### Check deployment status:
```bash
ssh root@YOUR_VPS_IP "docker ps"
```

### View deployment logs:
```bash
ssh root@YOUR_VPS_IP "cat /tmp/nexus-deploy-*.log"
```

### Check specific service:
```bash
ssh root@YOUR_VPS_IP "docker logs nexus-cos-gateway"
```

### Restart all services:
```bash
ssh root@YOUR_VPS_IP "cd /opt/nexus-cos && docker compose restart"
```

---

## 🔄 Re-Deploy (Update)

Just run the one-liner again - it's safe to run multiple times:

```bash
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | bash"
```

---

## 📝 Requirements

- **VPS with:** Ubuntu 20.04+, 4GB+ RAM, 10GB+ disk
- **Access:** Root or sudo privileges
- **Network:** Ports 3000, 3002, 3041, 4000 open

---

## 🎉 That's It!

**Full documentation:** [VPS_ONE_LINER_GUIDE.md](./VPS_ONE_LINER_GUIDE.md)

---

**Created:** 2025-12-24  
**Version:** 1.0.0  
**Based on:** PR #174 & PR #168

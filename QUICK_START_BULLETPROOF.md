# 🚀 Nexus COS - Quick Start (Bulletproof PF)

**VPS:** 74.208.155.161 | **Domains:** n3xuscos.online, hollywood.n3xuscos.online

---

## ⚡ One-Line Deploy

```bash
ssh root@74.208.155.161 "cd /opt/nexus-cos && ./bulletproof-pf-deploy.sh && ./bulletproof-pf-validate.sh"
```

---

## 📋 Before You Start

### Required Credentials
- [ ] OAuth Client ID
- [ ] OAuth Client Secret
- [ ] JWT Secret (generate: `openssl rand -hex 32`)
- [ ] DB Password (generate: `openssl rand -base64 24`)

### Required Files
- [ ] IONOS SSL certificate for n3xuscos.online (.crt and .key)
- [ ] IONOS SSL certificate for hollywood.n3xuscos.online (.crt and .key)

---

## 🔧 Manual Deploy (5 Steps)

### 1. Connect
```bash
ssh root@74.208.155.161
cd /opt/nexus-cos
```

### 2. Configure
```bash
cp .env.pf.example .env.pf
nano .env.pf
# Update: OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, JWT_SECRET, DB_PASSWORD
```

### 3. SSL Setup
```bash
mkdir -p /etc/nginx/ssl/{apex,hollywood}
# Copy IONOS certificates to:
# /etc/nginx/ssl/apex/n3xuscos.online.crt
# /etc/nginx/ssl/apex/n3xuscos.online.key
# /etc/nginx/ssl/hollywood/hollywood.n3xuscos.online.crt
# /etc/nginx/ssl/hollywood/hollywood.n3xuscos.online.key
```

### 4. Deploy
```bash
./bulletproof-pf-deploy.sh
```

### 5. Validate
```bash
./bulletproof-pf-validate.sh
```

---

## ✅ Success = This Message

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ✅ ALL CHECKS PASSED                         ║
║                                                                ║
║         Nexus COS Production Framework Deployed!               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

---

## 🔍 Quick Health Check

```bash
curl http://localhost:4000/health  # Gateway API
curl http://localhost:3002/health  # AI SDK
curl http://localhost:3041/health  # PV Keys
curl http://localhost:8088/health  # V-Screen Hollywood
curl http://localhost:3016/health  # StreamCore
```

**All should return:** HTTP 200 OK

---

## 📊 View Services

```bash
docker compose -f docker-compose.pf.yml ps
```

**Expected:** All services show "Up (healthy)" or "Up"

---

## 📝 View Logs

```bash
# All services
docker compose -f docker-compose.pf.yml logs -f

# Specific service
docker compose -f docker-compose.pf.yml logs -f puabo-api
```

---

## 🔄 Restart Services

```bash
# Restart all
docker compose -f docker-compose.pf.yml restart

# Restart one
docker compose -f docker-compose.pf.yml restart puabo-api
```

---

## 🌐 Production URLs

- **Main:** https://n3xuscos.online
- **API:** https://n3xuscos.online/api/health
- **Hollywood:** https://hollywood.n3xuscos.online
- **TV/Streaming:** https://tv.n3xuscos.online

---

## 🆘 Troubleshooting

### Services won't start?
```bash
# Check credentials
grep -E "(your-|<.*>)" .env.pf
# Should return nothing

# Check disk space
df -h

# View detailed logs
docker compose -f docker-compose.pf.yml logs
```

### Health checks failing?
```bash
# Wait 60 seconds for initialization
sleep 60

# Re-run validation
./bulletproof-pf-validate.sh
```

### SSL errors?
```bash
# Verify certificates
openssl x509 -in /etc/nginx/ssl/apex/n3xuscos.online.crt -noout -text

# Check permissions
ls -la /etc/nginx/ssl/apex/
# .crt should be 644, .key should be 600
```

---

## 📚 Documentation

- **Complete Guide:** `PF_BULLETPROOF_GUIDE.md`
- **Step-by-Step:** `TRAE_SOLO_EXECUTION.md`
- **Full Spec:** `nexus-cos-pf-bulletproof.yaml`
- **Overview:** `PF_BULLETPROOF_README.md`

---

## 🎯 Service Ports

| Service | Port | Container |
|---------|------|-----------|
| Gateway API | 4000 | puabo-api |
| AI SDK / V-Prompter | 3002 | nexus-cos-puaboai-sdk |
| PV Keys | 3041 | nexus-cos-pv-keys |
| V-Screen Hollywood | 8088 | vscreen-hollywood |
| StreamCore | 3016 | nexus-cos-streamcore |
| PostgreSQL | 5432 | nexus-cos-postgres |
| Redis | 6379 | nexus-cos-redis |

---

## 💡 Pro Tips

1. **Always validate:** Run `./bulletproof-pf-validate.sh` after any changes
2. **Monitor logs:** Keep `docker compose logs -f` running in another terminal
3. **Check health:** Use `watch -n 5 'docker compose ps'` for continuous monitoring
4. **Backup database:** Run daily backups with `pg_dump`
5. **SSL expiration:** Check certificate expiration monthly

---

## 🎊 That's It!

**You're ready to deploy Nexus COS in under 10 minutes.**

**Need help?** Read `PF_BULLETPROOF_GUIDE.md` or `TRAE_SOLO_EXECUTION.md`

**Ready to launch?** Run `./bulletproof-pf-deploy.sh`

---

**Version:** 1.0 BULLETPROOF  
**Date:** 2025-10-07  
**Status:** ✅ PRODUCTION READY

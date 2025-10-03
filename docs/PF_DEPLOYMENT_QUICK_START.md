# PF Deployment - Quick Start Card

**Target VPS:** 74.208.155.161 (nexuscos.online)  
**Created:** 2025-10-03T14:46Z

---

## ⚡ 1-Command Deployment

```bash
ssh root@74.208.155.161 'cd /opt/nexus-cos && ./scripts/pf-final-deploy.sh'
```

---

## 📋 Prerequisites Checklist

- [ ] VPS accessible: `ssh root@74.208.155.161`
- [ ] Repository at: `/opt/nexus-cos`
- [ ] Docker & Docker Compose installed
- [ ] Nginx installed
- [ ] SSL certificates available
- [ ] `.env.pf` configured with secrets

---

## 🚀 Step-by-Step (5 Minutes)

### Step 1: SSH to VPS
```bash
ssh root@74.208.155.161
```

### Step 2: Navigate to Repo
```bash
cd /opt/nexus-cos
```

### Step 3: Run Deployment
```bash
./scripts/pf-final-deploy.sh
```

### Step 4: Verify Health
```bash
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

### Step 5: Test V-Prompter Pro
```bash
curl https://nexuscos.online/v-suite/prompter/health
```

**Expected:** All return `200 OK`

---

## 🔍 Quick Health Check

```bash
# All services
docker compose -f docker-compose.pf.yml ps

# Service logs
docker compose -f docker-compose.pf.yml logs -f

# Nginx status
systemctl status nginx

# Test all endpoints
for port in 4000 3002 3041; do 
  echo "Testing :$port"; 
  curl -f http://localhost:$port/health || echo "FAILED"; 
done
```

---

## 🛠️ Common Fixes

### Missing SSL Certificates
```bash
sudo mkdir -p /opt/nexus-cos/ssl
sudo cp /path/to/cert.crt /opt/nexus-cos/ssl/nexus-cos.crt
sudo cp /path/to/key.key /opt/nexus-cos/ssl/nexus-cos.key
sudo chmod 644 /opt/nexus-cos/ssl/nexus-cos.crt
sudo chmod 600 /opt/nexus-cos/ssl/nexus-cos.key
```

### Configure Secrets
```bash
nano .env
# Update: OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, JWT_SECRET
```

### Restart Services
```bash
docker compose -f docker-compose.pf.yml restart
systemctl reload nginx
```

### View Logs
```bash
# All logs
docker compose -f docker-compose.pf.yml logs -f

# Specific service
docker compose -f docker-compose.pf.yml logs puabo-api
```

---

## 📊 Success Indicators

✅ **All services "Up"** in `docker compose ps`  
✅ **All health endpoints return 200**  
✅ **V-Prompter Pro accessible:** `https://nexuscos.online/v-suite/prompter/health`  
✅ **No errors in logs**  
✅ **SSL certificate valid**

---

## 📚 Full Documentation

- **Complete Guide:** [PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md](../PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md)
- **Assets Manifest:** [PF_ASSETS_LOCKED_2025-10-03T14-46Z.md](./PF_ASSETS_LOCKED_2025-10-03T14-46Z.md)
- **Deployment Script:** [scripts/pf-final-deploy.sh](../scripts/pf-final-deploy.sh)

---

## 🆘 Emergency Commands

```bash
# Stop all services
docker compose -f docker-compose.pf.yml down

# Restart everything
docker compose -f docker-compose.pf.yml up -d --force-recreate

# Check system resources
df -h && free -h && docker system df

# Test connectivity
curl -I https://nexuscos.online

# SSL check
openssl s_client -connect nexuscos.online:443 -servername nexuscos.online
```

---

## 🎯 Key Endpoints

| Endpoint | URL | Expected |
|----------|-----|----------|
| Gateway | http://localhost:4000/health | 200 OK |
| AI SDK | http://localhost:3002/health | 200 OK |
| PV Keys | http://localhost:3041/health | 200 OK |
| V-Prompter Pro | https://nexuscos.online/v-suite/prompter/health | 200 OK |

---

## 🔐 SSL Paths

```
Certificate: /opt/nexus-cos/ssl/nexus-cos.crt (644)
Key:         /opt/nexus-cos/ssl/nexus-cos.key (600)
```

---

**🎉 You're ready to deploy!**

Run: `./scripts/pf-final-deploy.sh`

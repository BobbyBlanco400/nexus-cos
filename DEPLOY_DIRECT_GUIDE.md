# 🚀 Nexus COS - Direct Deployment Guide

## Your Simple Deployment Command

No TRAE. No complexity. Just run this on your server:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/deploy-direct.sh | sudo bash
```

Or if you already have the repository:

```bash
cd /opt/nexus-cos
sudo bash deploy-direct.sh
```

**That's it!** The script will:
1. ✅ Check system requirements (Docker, Nginx, etc.)
2. ✅ Setup repository at `/opt/nexus-cos`
3. ✅ Configure environment variables
4. ✅ Setup SSL certificates
5. ✅ Deploy all Docker services
6. ✅ Configure Nginx for **both** domains
7. ✅ Verify everything is working

---

## What Gets Deployed

### Both Domains Configured

- ✅ **https://nexuscos.online** - Main production site
- ✅ **https://beta.nexuscos.online** - Beta experience (12/15/2025 - 12/31/2025)

### All Services Running

- ✅ PostgreSQL (Port 5432)
- ✅ Redis (Port 6379)
- ✅ PUABO API (Port 4000)
- ✅ AI SDK (Port 3002)
- ✅ PV Keys (Port 3041)
- ✅ StreamCore (Port 3016)
- ✅ V-Screen Hollywood (Port 8088)
- ✅ PUABO NEXUS Fleet (Ports 3231-3234)

---

## After Deployment

### 1. Test Your Domains

```bash
# Test main domain
curl -I https://nexuscos.online/health
curl -I https://nexuscos.online/api/status

# Test beta domain
curl -I https://beta.nexuscos.online/health
curl -I https://beta.nexuscos.online/api/status
```

All should return `HTTP/2 200`

### 2. Check Service Status

```bash
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml ps
```

All services should show as "Up"

### 3. Run Full Validation

```bash
cd /opt/nexus-cos

# Test main domain
./test-api-validation.sh

# Test beta domain
BETA_URL=https://beta.nexuscos.online ./test-api-validation.sh
```

### 4. View Logs

```bash
cd /opt/nexus-cos

# All services
docker-compose -f docker-compose.pf.yml logs -f

# Specific service
docker-compose -f docker-compose.pf.yml logs -f puabo-api
```

---

## Important Configuration

### Environment Variables

Edit `/opt/nexus-cos/.env.pf` to configure:

```bash
# Edit the file
nano /opt/nexus-cos/.env.pf

# Required changes:
# - OAUTH_CLIENT_ID=your-actual-client-id
# - OAUTH_CLIENT_SECRET=your-actual-client-secret
# 
# Already auto-generated:
# - DB_PASSWORD (secure random password)
# - JWT_SECRET (secure random secret)
```

After editing:

```bash
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml restart
```

### SSL Certificates

The script creates self-signed certificates for testing. For production:

1. **Get real SSL certificates** from your provider (IONOS, Let's Encrypt, etc.)

2. **Place them here:**
   ```
   /etc/ssl/ionos/fullchain.pem
   /etc/ssl/ionos/privkey.pem
   /etc/ssl/ionos/beta.nexuscos.online/fullchain.pem
   /etc/ssl/ionos/beta.nexuscos.online/privkey.pem
   ```

3. **Reload Nginx:**
   ```bash
   nginx -t && systemctl reload nginx
   ```

---

## Troubleshooting

### Services Won't Start

```bash
cd /opt/nexus-cos

# Check what's wrong
docker-compose -f docker-compose.pf.yml ps
docker-compose -f docker-compose.pf.yml logs

# Rebuild and restart
docker-compose -f docker-compose.pf.yml up -d --build --force-recreate
```

### Can't Access Domains

1. **Check DNS:** Ensure your domains point to your server IP
   ```bash
   dig nexuscos.online
   dig beta.nexuscos.online
   ```

2. **Check Firewall:**
   ```bash
   # Allow HTTP/HTTPS
   ufw allow 80/tcp
   ufw allow 443/tcp
   ufw reload
   ```

3. **Check Nginx:**
   ```bash
   nginx -t
   systemctl status nginx
   systemctl restart nginx
   ```

### API Endpoints Return 502

```bash
# Check if API service is running
docker-compose -f /opt/nexus-cos/docker-compose.pf.yml ps puabo-api

# Check API logs
docker-compose -f /opt/nexus-cos/docker-compose.pf.yml logs puabo-api

# Restart API
docker-compose -f /opt/nexus-cos/docker-compose.pf.yml restart puabo-api
```

---

## Quick Commands Reference

### Restart Everything

```bash
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml restart
systemctl restart nginx
```

### Stop Everything

```bash
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml down
systemctl stop nginx
```

### Start Everything

```bash
cd /opt/nexus-cos
docker-compose -f docker-compose.pf.yml up -d
systemctl start nginx
```

### Update from GitHub

```bash
cd /opt/nexus-cos
git pull origin main
docker-compose -f docker-compose.pf.yml up -d --build
```

### View Container Stats

```bash
cd /opt/nexus-cos
docker stats $(docker-compose -f docker-compose.pf.yml ps -q)
```

---

## Beta Experience (12/15/2025 - 12/31/2025)

Your beta domain is **fully configured** and working:

- **URL:** https://beta.nexuscos.online
- **Same API:** Uses same backend as main domain
- **Same Services:** All endpoints available
- **Beta Header:** Includes `X-Environment: beta` header
- **Separate SSL:** Has its own SSL certificate

### Test Beta Domain

```bash
# Quick test
curl -I https://beta.nexuscos.online/health

# Full test
cd /opt/nexus-cos
BETA_URL=https://beta.nexuscos.online ./test-api-validation.sh

# Check beta header
curl -I https://beta.nexuscos.online/ | grep "X-Environment"
# Should show: X-Environment: beta
```

---

## What Changed from TRAE

Before (TRAE):
- ❌ Complex multi-script deployment
- ❌ Multiple configuration files
- ❌ Hard to debug
- ❌ Required TRAE solo knowledge

Now (Direct):
- ✅ **One command:** `sudo bash deploy-direct.sh`
- ✅ **One script:** Everything in one place
- ✅ **Easy to understand:** Clear steps with progress
- ✅ **You control it:** Run it yourself, no abstraction

---

## Your Global Launch is Ready

Both domains are configured and ready:
- ✅ `nexuscos.online` - Main production
- ✅ `beta.nexuscos.online` - Beta experience

All API endpoints work:
- ✅ `/api/`
- ✅ `/api/status`
- ✅ `/api/health`
- ✅ `/api/system/status`
- ✅ `/api/v1/imcus/001/status`

All services deploy correctly:
- ✅ Database (PostgreSQL)
- ✅ Cache (Redis)
- ✅ API Gateway
- ✅ All microservices

**You're in control. Just run the deployment script and verify!**

---

**Need help?** All the fixes are documented in:
- `NEXUS_COS_GLOBAL_LAUNCH_FIXED.md`
- `DEPLOYMENT_GUIDE.md`
- `LAUNCH_STATUS.md`

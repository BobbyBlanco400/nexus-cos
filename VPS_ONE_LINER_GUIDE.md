# 🚀 Nexus COS - VPS One-Liner Deployment Guide

**Version:** 1.0.0  
**Date:** 2025-12-24  
**Status:** ✅ Production Ready

---

## 📋 Overview

This guide provides a single, bulletproofed SSH command to deploy Nexus COS on your VPS server. Based on the most recent Platform Files (PFs) from PR #174 and PR #168, this deployment method ensures:

- ✅ **Zero Downtime** - Graceful container restarts
- ✅ **Full Stack** - All services and dependencies
- ✅ **Health Validated** - Automatic health checks
- ✅ **Error Recovery** - Automatic diagnostics on failure
- ✅ **Production Ready** - Based on verified PF work

---

## ⚡ Quick Start - The One-Liner

### Copy and paste this command into your terminal:

```bash
ssh root@YOUR_VPS_IP 'bash -s' < <(curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh)
```

**Replace `YOUR_VPS_IP` with your actual VPS IP address.**

### Alternative: Download and execute directly

```bash
ssh root@YOUR_VPS_IP "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh | bash"
```

---

## 🎯 What This Command Does

The one-liner executes a comprehensive deployment script that:

### 1. **Pre-Flight Checks** ✈️
- Verifies sudo/root access
- Checks for required commands (git, docker, curl, nc)
- Validates Docker is running
- Checks available disk space

### 2. **Repository Setup** 📦
- Clones repository (if not exists)
- Updates to latest main branch
- Stashes any local changes
- Sets correct permissions

### 3. **Environment Configuration** ⚙️
- Configures production environment
- Sets database credentials
- Configures Redis cache
- Applies PF-specific settings

### 4. **Docker Deployment** 🐋
- Stops existing containers gracefully
- Cleans up old images
- Builds latest services
- Starts all containers

### 5. **Health Validation** 🏥
- Waits for services to start (up to 120s)
- Checks all critical ports:
  - `4000` - Gateway API
  - `3002` - PUABO AI SDK
  - `3041` - PV Keys
  - `3000` - Frontend
  - `5432` - PostgreSQL
  - `6379` - Redis
- Validates HTTP endpoints

### 6. **Verification** ✅
- Lists running containers
- Checks PR #174 features
- Validates deployment success

---

## 📊 Expected Output

### Success Output:

```
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗     ██████╗ ██████╗  ║
║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ██╔════╝██╔═══██╗ ║
║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ██║     ██║   ██║ ║
║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ██║     ██║   ██║ ║
║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ╚██████╗╚██████╔╝ ║
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝  ║
║                                                                       ║
║         BULLETPROOFED VPS DEPLOYMENT - ONE-LINER EXECUTION           ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝

Deployment Timestamp: 2025-12-24 16:14:37

✅ Pre-flight checks passed
✅ Repository updated to latest main
✅ Environment configured
✅ Docker services deployed
✅ All services are healthy
✅ Deployment verified

═══════════════════════════════════════════════════════════════════════════════
✅ DEPLOYMENT COMPLETED SUCCESSFULLY
═══════════════════════════════════════════════════════════════════════════════

📊 Deployment Summary:
  - Repository: Updated to latest main branch
  - Environment: Configured
  - Docker Services: Running
  - Health Checks: Passed

🌐 Access Points:
  - Frontend: http://YOUR_VPS_IP:3000
  - Gateway API: http://YOUR_VPS_IP:4000
  - PUABO AI SDK: http://YOUR_VPS_IP:3002
  - PV Keys: http://YOUR_VPS_IP:3041

✅ Nexus COS is now running on your VPS!
```

---

## 🔧 Manual Deployment (Step-by-Step)

If you prefer to run commands manually:

### Step 1: SSH into your VPS
```bash
ssh root@YOUR_VPS_IP
```

### Step 2: Download the deployment script
```bash
cd /tmp
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh -o deploy.sh
chmod +x deploy.sh
```

### Step 3: Execute the deployment
```bash
./deploy.sh
```

---

## 📝 Requirements

### Server Requirements:
- **OS:** Ubuntu 20.04+ or Debian 11+
- **RAM:** Minimum 4GB (8GB recommended)
- **Disk:** Minimum 10GB free space
- **Network:** Public IP address with open ports
- **Access:** Root or sudo privileges

### Local Requirements:
- SSH client
- Network connectivity to your VPS
- SSH key configured (or password)

### Ports Used:
- `3000` - Frontend (React)
- `3002` - PUABO AI SDK
- `3041` - PV Keys Service
- `4000` - Gateway API
- `5432` - PostgreSQL (internal)
- `6379` - Redis (internal)

---

## 🆘 Troubleshooting

### Issue: "Permission Denied"

**Solution:** Ensure you're using root or a user with sudo privileges:
```bash
ssh root@YOUR_VPS_IP ...
```

Or add sudo when running locally:
```bash
sudo bash VPS_BULLETPROOF_ONE_LINER.sh
```

---

### Issue: "Docker not found"

**Solution:** The script will attempt to install Docker. If it fails, install manually:
```bash
curl -fsSL https://get.docker.com | sh
sudo systemctl start docker
sudo systemctl enable docker
```

---

### Issue: "Health check timeout"

**Cause:** Services took longer than 120 seconds to start.

**Solution:**
1. Check container logs:
```bash
docker logs <container_name>
```

2. Check system resources:
```bash
free -h
df -h
```

3. Restart specific service:
```bash
docker compose restart <service_name>
```

---

### Issue: "Port already in use"

**Cause:** Another service is using required ports.

**Solution:**
1. Identify the process:
```bash
sudo lsof -i :3000
sudo lsof -i :4000
```

2. Stop the conflicting service:
```bash
sudo systemctl stop <service_name>
```

---

### Issue: "Git pull failed"

**Cause:** Local changes conflict with remote changes.

**Solution:** The script automatically stashes changes, but if needed:
```bash
cd /opt/nexus-cos
git stash
git pull origin main
```

---

## 🔍 Verification Commands

After deployment, verify everything is working:

### Check all containers:
```bash
docker ps
```

### Check specific service logs:
```bash
docker logs nexus-cos-gateway
docker logs nexus-cos-puaboai-sdk
docker logs nexus-cos-pv-keys
```

### Test health endpoints:
```bash
curl http://localhost:3000/
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

### View deployment log:
```bash
cat /tmp/nexus-deploy-*.log
```

---

## 🔄 Re-Deployment

To redeploy (update to latest code):

Simply run the one-liner again:
```bash
ssh root@YOUR_VPS_IP 'bash -s' < <(curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh)
```

The script is idempotent and safe to run multiple times.

---

## 🎨 Customization

### Change Installation Directory

Edit the script and modify:
```bash
REPO_DIR="/your/custom/path"
```

### Change Health Check Timeout

Edit the script and modify:
```bash
HEALTH_CHECK_TIMEOUT=180  # 3 minutes
```

### Use Different Branch

Edit the script and modify the git commands:
```bash
git reset --hard origin/your-branch
```

---

## 📚 Related Documentation

- **PR #174:** Nexus COS Expansion Layer (Jurisdiction toggle, marketplace, AI dealers, casino federation)
- **PR #168:** Nexus COS Platform Synopsis
- **Docker Compose:** `/opt/nexus-cos/docker-compose.pf.yml`
- **Environment:** `/opt/nexus-cos/.env`

---

## ✨ Features Included

Based on the most recent PF work:

### From PR #174 (Expansion Layer):
- ✅ Jurisdiction engine configuration
- ✅ Marketplace Phase 2 setup
- ✅ AI dealer expansion
- ✅ Casino federation architecture

### From PR #168 (Platform Synopsis):
- ✅ Complete platform overview
- ✅ Service documentation
- ✅ Integration points
- ✅ API endpoints

---

## 🎯 Best Practices

1. **Always backup before deploying:**
```bash
ssh root@YOUR_VPS_IP "cd /opt/nexus-cos && tar -czf backup-$(date +%Y%m%d).tar.gz ."
```

2. **Test in development first:**
Use a test VPS before deploying to production.

3. **Monitor logs during deployment:**
```bash
ssh root@YOUR_VPS_IP "tail -f /tmp/nexus-deploy-*.log"
```

4. **Keep SSH keys secure:**
Use SSH keys instead of passwords for better security.

5. **Regular updates:**
Run the one-liner weekly to stay up to date.

---

## 🏆 Success Criteria

After deployment, you should have:

- ✅ All Docker containers running
- ✅ All health endpoints responding
- ✅ Frontend accessible on port 3000
- ✅ Gateway API accessible on port 4000
- ✅ No error messages in logs
- ✅ System resources within normal range

---

## 📞 Support

For issues or questions:

1. Check the deployment log: `/tmp/nexus-deploy-*.log`
2. Review container logs: `docker logs <container>`
3. Check Docker status: `docker ps -a`
4. Verify network: `netstat -tulpn | grep LISTEN`

---

## 🚀 Next Steps

After successful deployment:

1. **Configure Domain:**
   - Point your domain to the VPS IP
   - Update Nginx configuration
   - Set up SSL certificates

2. **Secure Services:**
   - Configure firewall rules
   - Set up fail2ban
   - Enable automatic updates

3. **Monitor:**
   - Set up monitoring alerts
   - Configure log rotation
   - Enable backup automation

4. **Scale:**
   - Add load balancing
   - Set up database replication
   - Configure CDN

---

**🎉 Congratulations! Your Nexus COS platform is now running on your VPS!**

---

**Last Updated:** 2025-12-24  
**Script Version:** 1.0.0  
**Maintainer:** Nexus COS Platform Team

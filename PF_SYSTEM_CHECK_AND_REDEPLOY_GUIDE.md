# Nexus COS - PF System Check and Re-deployment Guide

**Created:** 2025-10-03T14:46Z  
**Target VPS:** 74.208.155.161 (n3xuscos.online)  
**Status:** ✅ Ready for Production Deployment

---

## 📋 Overview

This guide provides complete instructions for performing a full system check and re-deployment of Nexus COS Pre-Flight (PF) to your VPS. It includes specific instructions for fixing common issues and ensures a successful deployment.

---

## 🎯 What's Been Created

### 1. **PF Assets Locked Manifest** ✅
**Location:** `docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md`

This timestamped manifest serves as the single source of truth for:
- All PF asset locations (env files, SSL artifacts)
- Canonical SSL paths (`/opt/nexus-cos/ssl/nexus-cos.crt` and `.key`)
- V-Prompter Pro routing details (locked configuration)
- Validation steps and deployment procedures
- References to all deployment scripts and documentation

**Key Information:**
- **Public Route:** `/v-suite/prompter/`
- **Service Target:** `http://127.0.0.1:3502/`
- **Health Route:** `/v-suite/prompter/health`
- **Expected Response:** `200 OK` from `https://n3xuscos.online/v-suite/prompter/health`

### 2. **PF Final Deployment Script** ✅
**Location:** `scripts/pf-final-deploy.sh`

Comprehensive automated deployment script that performs:
- ✅ Complete system requirements validation
- ✅ Repository and file structure verification
- ✅ Automated SSL certificate management
- ✅ Environment configuration with validation
- ✅ Docker service deployment
- ✅ Nginx configuration and reload
- ✅ Post-deployment health checks
- ✅ Detailed deployment summary and next steps

---

## 🚀 Quick Deployment (5 Steps)

### Step 1: Access Your VPS

```bash
ssh root@74.208.155.161
```

### Step 2: Navigate to Repository

```bash
cd /opt/nexus-cos
```

If the repository isn't at `/opt/nexus-cos`, adjust the path accordingly.

### Step 3: Update Repository (Optional)

```bash
git pull origin main
```

### Step 4: Run the Deployment Script

```bash
./scripts/pf-final-deploy.sh
```

The script will:
1. Check all system requirements
2. Validate the repository structure
3. Manage SSL certificates automatically
4. Configure environment variables
5. Deploy all Docker services
6. Configure and reload Nginx
7. Validate the deployment
8. Provide a comprehensive summary

### Step 5: Verify Deployment

```bash
# Test local health endpoints
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health

# Test V-Prompter Pro (production)
curl https://n3xuscos.online/v-suite/prompter/health
```

**Expected:** All endpoints return `200 OK` with JSON response.

---

## 🔧 Detailed Deployment Instructions

### Prerequisites

Before running the deployment script, ensure:

1. **VPS Access**
   - SSH access to 74.208.155.161
   - Root or sudo privileges

2. **Required Software Installed**
   - Docker Engine
   - Docker Compose
   - Nginx
   - OpenSSL (for SSL validation)

3. **Ports Available**
   - 80 (HTTP)
   - 443 (HTTPS)
   - 4000 (puabo-api)
   - 3002 (puaboai-sdk)
   - 3041 (pv-keys)
   - 5432 (PostgreSQL)
   - 6379 (Redis)

### Pre-Deployment Checklist

- [ ] VPS accessible via SSH
- [ ] Repository cloned to `/opt/nexus-cos` (or known location)
- [ ] Docker and Docker Compose installed
- [ ] Nginx installed
- [ ] Valid SSL certificates available
- [ ] At least 5GB free disk space
- [ ] Required ports not blocked by firewall

---

## 🛠️ Fixing Common Issues

### Issue 1: SSL Certificates Missing

**Symptom:** Script warns "SSL certificates not found"

**Solution:**

Option A - Use certificates from repository:
```bash
cd /opt/nexus-cos

# If you have certificates in the repository
ls -la ssl/          # Check for *.crt and *.key files
ls -la fullchain.crt # Check root directory
```

Option B - Manually place certificates:
```bash
# Create SSL directory
sudo mkdir -p /opt/nexus-cos/ssl

# Copy your certificates
sudo cp /path/to/your/certificate.crt /opt/nexus-cos/ssl/nexus-cos.crt
sudo cp /path/to/your/private.key /opt/nexus-cos/ssl/nexus-cos.key

# Set permissions
sudo chmod 644 /opt/nexus-cos/ssl/nexus-cos.crt
sudo chmod 600 /opt/nexus-cos/ssl/nexus-cos.key
```

Option C - Generate self-signed certificate (testing only):
```bash
sudo mkdir -p /opt/nexus-cos/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /opt/nexus-cos/ssl/nexus-cos.key \
  -out /opt/nexus-cos/ssl/nexus-cos.crt \
  -subj "/CN=n3xuscos.online"
sudo chmod 644 /opt/nexus-cos/ssl/nexus-cos.crt
sudo chmod 600 /opt/nexus-cos/ssl/nexus-cos.key
```

### Issue 2: Environment Variables Not Configured

**Symptom:** Script warns about missing OAUTH_CLIENT_ID, OAUTH_CLIENT_SECRET, etc.

**Solution:**

```bash
cd /opt/nexus-cos

# Edit .env file (created by script from .env.pf)
nano .env

# Update the following variables:
# OAUTH_CLIENT_ID=your-actual-client-id
# OAUTH_CLIENT_SECRET=your-actual-client-secret
# JWT_SECRET=your-secure-random-string-here
# DB_PASSWORD=your-secure-database-password

# Save and exit (Ctrl+X, then Y, then Enter)

# Re-run deployment
./scripts/pf-final-deploy.sh
```

### Issue 3: Docker Not Installed

**Symptom:** "Docker not installed" error

**Solution:**

```bash
# Install Docker on Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Verify installation
docker --version
docker compose version

# Re-run deployment
cd /opt/nexus-cos
./scripts/pf-final-deploy.sh
```

### Issue 4: Nginx Not Installed

**Symptom:** "Nginx not installed" warning

**Solution:**

```bash
# Install Nginx on Ubuntu/Debian
sudo apt-get update
sudo apt-get install nginx

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify installation
nginx -v

# Re-run deployment
cd /opt/nexus-cos
./scripts/pf-final-deploy.sh
```

### Issue 5: Port Already in Use

**Symptom:** Script warns "Port XXXX is already in use"

**Solution:**

```bash
# Check what's using the port (example for port 4000)
sudo lsof -i :4000

# Option A: Stop the conflicting service
sudo systemctl stop <service-name>

# Option B: Kill the process
sudo kill <PID>

# Re-run deployment
cd /opt/nexus-cos
./scripts/pf-final-deploy.sh
```

### Issue 6: Services Not Starting

**Symptom:** "Some services may not be running" warning

**Solution:**

```bash
cd /opt/nexus-cos

# Check service status
docker compose -f docker-compose.pf.yml ps

# Check logs for errors
docker compose -f docker-compose.pf.yml logs

# Check specific service logs
docker compose -f docker-compose.pf.yml logs puabo-api
docker compose -f docker-compose.pf.yml logs nexus-cos-puaboai-sdk

# Restart services
docker compose -f docker-compose.pf.yml restart

# If issues persist, rebuild
docker compose -f docker-compose.pf.yml down
docker compose -f docker-compose.pf.yml up -d --build
```

### Issue 7: Database Connection Issues

**Symptom:** "PostgreSQL failed to start" error

**Solution:**

```bash
cd /opt/nexus-cos

# Check PostgreSQL container
docker compose -f docker-compose.pf.yml logs nexus-cos-postgres

# Check if PostgreSQL is ready
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres pg_isready -U nexus_user

# Access database to verify
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db

# Check for volume issues
docker volume ls
docker volume inspect nexus-cos_postgres_data
```

### Issue 8: Health Endpoints Not Responding

**Symptom:** Health check URLs return errors

**Solution:**

```bash
cd /opt/nexus-cos

# Check if services are running
docker compose -f docker-compose.pf.yml ps

# Check service logs
docker compose -f docker-compose.pf.yml logs puabo-api
docker compose -f docker-compose.pf.yml logs nexus-cos-puaboai-sdk
docker compose -f docker-compose.pf.yml logs nexus-cos-pv-keys

# Restart specific service
docker compose -f docker-compose.pf.yml restart puabo-api

# Test from within container
docker compose -f docker-compose.pf.yml exec puabo-api curl http://localhost:4000/health
```

### Issue 9: V-Prompter Pro 502 Bad Gateway

**Symptom:** `https://n3xuscos.online/v-suite/prompter/health` returns 502

**Solution:**

```bash
cd /opt/nexus-cos

# Verify puaboai-sdk service is running
docker compose -f docker-compose.pf.yml ps nexus-cos-puaboai-sdk

# Check service logs
docker compose -f docker-compose.pf.yml logs nexus-cos-puaboai-sdk

# Verify Nginx upstream configuration
sudo nginx -t
sudo cat /etc/nginx/conf.d/nexus-proxy.conf | grep -A5 "pf_puaboai_sdk"

# Restart services
docker compose -f docker-compose.pf.yml restart nexus-cos-puaboai-sdk
sudo systemctl reload nginx

# Test again
curl https://n3xuscos.online/v-suite/prompter/health
```

### Issue 10: Nginx Configuration Errors

**Symptom:** "Nginx configuration test failed"

**Solution:**

```bash
# Test nginx configuration
sudo nginx -t

# Check the error details
sudo nginx -t 2>&1

# Verify SSL certificate paths exist
ls -la /opt/nexus-cos/ssl/

# If SSL paths are wrong, update nginx config
sudo nano /etc/nginx/sites-available/nexus-cos.conf

# Test again
sudo nginx -t

# If successful, reload
sudo systemctl reload nginx
```

---

## 📊 Post-Deployment Validation

### 1. Verify All Services Running

```bash
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml ps
```

**Expected:** All services show "Up" status.

### 2. Test Health Endpoints

```bash
# Local endpoints
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
```

**Expected:** Each returns JSON with `"status":"ok"`

### 3. Verify Database

```bash
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db -c "\dt"
```

**Expected:** List of tables (users, sessions, api_keys, audit_log, etc.)

### 4. Test V-Prompter Pro Production URL

```bash
curl -v https://n3xuscos.online/v-suite/prompter/health
```

**Expected:** `200 OK` response with JSON health data

### 5. Check SSL Certificate

```bash
openssl s_client -connect n3xuscos.online:443 -servername n3xuscos.online < /dev/null
```

**Expected:** Valid certificate chain, no errors

### 6. Verify All Routes

Test these URLs in your browser or with curl:
- `https://n3xuscos.online/` - Main site
- `https://n3xuscos.online/admin` - Admin panel
- `https://n3xuscos.online/hub` - Creator hub
- `https://n3xuscos.online/studio` - Studio
- `https://n3xuscos.online/api/health` - API health
- `https://n3xuscos.online/v-suite/prompter/health` - V-Prompter Pro

### 7. Monitor Logs

```bash
# Watch all logs
docker compose -f docker-compose.pf.yml logs -f

# Watch specific service
docker compose -f docker-compose.pf.yml logs -f puabo-api
```

**Monitor for:** No error messages, successful requests

---

## 🔍 Advanced Troubleshooting

### Check System Resources

```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check CPU usage
top

# Check Docker disk usage
docker system df
```

### Clean Up Docker Resources

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Full cleanup (careful!)
docker system prune -a --volumes
```

### Restart Everything

```bash
cd /opt/nexus-cos

# Stop all services
docker compose -f docker-compose.pf.yml down

# Remove volumes (if needed - will delete data!)
docker compose -f docker-compose.pf.yml down -v

# Restart Docker daemon
sudo systemctl restart docker

# Redeploy
./scripts/pf-final-deploy.sh
```

### Check Firewall Rules

```bash
# Check UFW status (Ubuntu)
sudo ufw status

# Allow required ports
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp

# Check iptables
sudo iptables -L -n
```

---

## 📚 Additional Resources

### Key Documentation Files

1. **PF Assets Manifest** - `docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md`
   - Single source of truth for all PF assets and configurations

2. **PF README** - `PF_README.md`
   - Complete guide to PF deployment and services

3. **Deployment Checklist** - `PF_DEPLOYMENT_CHECKLIST.md`
   - Step-by-step deployment verification checklist

4. **Configuration Summary** - `PF_CONFIGURATION_SUMMARY.md`
   - Nginx and service configuration details

5. **Production Sign-off** - `PF_PRODUCTION_LAUNCH_SIGNOFF.md`
   - Production readiness validation

### Validation Scripts

```bash
# Validate PF configuration
./validate-pf.sh

# Validate Nginx configuration
./validate-pf-nginx.sh

# Test PF configuration
./test-pf-configuration.sh
```

---

## 🎯 Success Criteria

Your deployment is successful when:

- ✅ All Docker containers are running
- ✅ All health endpoints return 200 OK
- ✅ Database is accessible and contains tables
- ✅ SSL certificate is valid and working
- ✅ Nginx is serving requests without errors
- ✅ V-Prompter Pro URL responds: `https://n3xuscos.online/v-suite/prompter/health`
- ✅ No errors in Docker logs
- ✅ All application routes are accessible

---

## 🆘 Getting Help

### Check Logs First

```bash
# All services
docker compose -f docker-compose.pf.yml logs -f

# Specific service
docker compose -f docker-compose.pf.yml logs puabo-api

# Last 100 lines
docker compose -f docker-compose.pf.yml logs --tail=100

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Useful Commands Reference

```bash
# Service management
docker compose -f docker-compose.pf.yml ps           # Status
docker compose -f docker-compose.pf.yml up -d        # Start
docker compose -f docker-compose.pf.yml down         # Stop
docker compose -f docker-compose.pf.yml restart      # Restart
docker compose -f docker-compose.pf.yml logs -f      # Logs

# Database access
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db

# Container shell access
docker compose -f docker-compose.pf.yml exec puabo-api bash

# Nginx management
sudo nginx -t                      # Test configuration
sudo systemctl reload nginx        # Reload
sudo systemctl restart nginx       # Restart
sudo systemctl status nginx        # Status
```

---

## ⚡ Quick Reference

### Deployment Command
```bash
cd /opt/nexus-cos && ./scripts/pf-final-deploy.sh
```

### Health Check URLs
```
http://localhost:4000/health
http://localhost:3002/health
http://localhost:3041/health
https://n3xuscos.online/v-suite/prompter/health
```

### SSL Paths
```
Certificate: /opt/nexus-cos/ssl/nexus-cos.crt (644)
Private Key: /opt/nexus-cos/ssl/nexus-cos.key (600)
```

### Environment File
```
Source: .env.pf (in repository)
Active: .env (copied during deployment)
```

---

## 🎉 Deployment Complete!

Once all checks pass and services are running:

1. ✅ Services are deployed and healthy
2. ✅ SSL is configured and working
3. ✅ V-Prompter Pro is accessible
4. ✅ All routes are responding
5. ✅ Database is operational
6. ✅ Logs show no errors

**Next Steps:**
- Monitor the system for 24 hours
- Test all application functionality
- Set up automated backups
- Configure monitoring and alerting
- Document any custom configurations

---

**Created:** 2025-10-03T14:46Z  
**Author:** GitHub Copilot Code Agent  
**Repository:** BobbyBlanco400/nexus-cos  
**Status:** ✅ Ready for Production

For the authoritative list of all PF assets and configurations, always refer to:
`docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md`

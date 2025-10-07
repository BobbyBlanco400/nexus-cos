# Nexus COS - Global VPS Launch Guide

This guide provides complete instructions for deploying Nexus COS to production VPS with streaming/OTT services.

## Overview

- **Production Domain**: nexuscos.online
- **VPS IP**: 74.208.155.161
- **Frontend**: Served via Nginx at https://nexuscos.online
- **API**: Reverse-proxied at https://nexuscos.online/api
- **Streaming Services**: V-Suite routes under `/v-suite/*`

## Key Differences: Development vs Production

### Development (Port 5173)
- Vite dev server: `http://localhost:5173`
- V-Screen: `http://localhost:8088`
- API: `http://localhost:4000`
- Fast iteration, hot reload

### Production (nexuscos.online)
- Frontend: `https://nexuscos.online` (Nginx)
- V-Screen: `https://nexuscos.online/v-suite/screen` or `/v-screen`
- API: `https://nexuscos.online/api`
- Clean domain routes, SSL/TLS, production optimized

## Streaming/OTT Service Mapping

Nginx routes all streaming services under the V-Suite namespace:

### V-Suite Routes

| Route | Service | Backend Port | Description |
|-------|---------|--------------|-------------|
| `/v-suite/screen` | V-Screen Hollywood | 8088 | Virtual LED Volume/Production |
| `/v-screen` | V-Screen Hollywood | 8088 | Direct route (alternative) |
| `/v-suite/hollywood` | V-Screen Hollywood | 8088 | Hollywood edition features |
| `/v-suite/prompter` | V-Prompter Pro | 3002 | Teleprompter service |
| `/v-suite/caster` | V-Caster | 4000 | Broadcast/casting service |
| `/v-suite/stage` | V-Stage | 4000 | Stage production service |

**Note**: After deployment, verify which routes exist on your VPS and use them consistently. Some configs expose both `/v-suite/screen` and `/v-screen` for the same service.

## Production Environment Variables

### Frontend (.env in /frontend)

```bash
# Production API URL - NO localhost!
VITE_API_URL=/api

# V-Suite Streaming Services
VITE_V_SCREEN_URL=https://nexuscos.online/v-suite/screen
# OR use: VITE_V_SCREEN_URL=https://nexuscos.online/v-screen

VITE_V_CASTER_URL=https://nexuscos.online/v-suite/caster
VITE_V_STAGE_URL=https://nexuscos.online/v-suite/stage
VITE_V_PROMPTER_URL=https://nexuscos.online/v-suite/prompter
```

### Development Override

For local development, create `frontend/.env.local`:

```bash
# Development - use localhost
VITE_API_URL=http://localhost:4000/api
VITE_V_SCREEN_URL=http://localhost:8088
```

⚠️ **IMPORTANT**: The PF master script enforces production URLs during builds. Never use localhost URLs in production `.env` files.

## SSH Key Authorization (Non-Interactive Deploys)

### Setup SSH Keys on VPS

1. Three SSH public keys are provided in the repository:
   - `vps_key.pub`
   - `vps_key2.pub` (not in repo, use vps_key3.pub)
   - `vps_key3.pub`

2. Add keys to VPS authorized_keys:

```bash
# SSH into VPS
ssh root@74.208.155.161

# Add keys to authorized_keys
cat >> /root/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCz+6v+K7DSAWg2erdS1WS38797R2jJJqGe5uZXIot4SsBtTdAKyAwMFyM1dZpzD7z5V/itBQOqsp7eZ4VDF34TiAQJoI/juIgOapGvpMlGXvTTXfHRL9F2AKe2bZxtRZjbeRfwddoZsTsXpXuHPmALZ4W1sh7vJSrCmGdSZ+Z9xgRYtUSBbCj22zTKuDQBouuJXZLnYHn7AofqL1mu9sA66BOWSGPYeu21h3O2dvzRoC5rPvoOUqSDJHQUP/kFUfrBAugp8PQYPOMd3y/fY/c/5ebpDVtSSOg9K6tPFVYLiYvQs4pk5ClvP1QsKhIeBSd5W9zHgSe30LxUMhqm0bpV wecon@BobbysPC
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqzAEN7AnA+sBVy+K8EzM4F4Fg3tFKidVtb/l3QqtwPJlIX5RaBMs0iCocCp0maBRDkKj3v1y2HVwlubFqz8rQ8+CQvgTTc+OF2Q7fg1HIxcoDeHSyKh1aiXnmi7j44vZj5MmitdzfsIrLncequItCCDLWcAwovtCjv1YXOd2ytf7g3qoPOqcS5EpSmIBvYuaim00GBbsy8+fby5bgahC613uk6GQeXefHHiNGTZq037w41e91EUvKejTQ+OIatp+BguuRlOxeI6aH+BDkVW5sRomxWl5QUfi67SM2JcSC9pgNbK8WUZLUo6OaNJ8Fi9lamNvXNKVCFe1IrKBer2Pf wecon@BobbysPC
EOF

# Set permissions
chmod 600 /root/.ssh/authorized_keys
chmod 700 /root/.ssh
```

3. The `pf-final-deploy.sh` script automatically configures these keys when run on the VPS.

## Global VPS Launch Plan

### Step 1: Authorize SSH Keys (One-Time Setup)

Choose ONE of the provided SSH keys and add it to the VPS:

```bash
# From Windows PowerShell
$sshKey = Get-Content vps_key.pub
ssh root@74.208.155.161 "echo '$sshKey' >> /root/.ssh/authorized_keys"

# OR from Linux/Mac
cat vps_key.pub | ssh root@74.208.155.161 "cat >> /root/.ssh/authorized_keys"
```

### Step 2: Run PF Turnkey Deploy on VPS

Execute the deployment script directly on the VPS:

```bash
# Download and run the deployment script
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/scripts/pf-final-deploy.sh -o /tmp/pf-final-deploy.sh

# Execute deployment
sudo bash /tmp/pf-final-deploy.sh -r https://github.com/BobbyBlanco400/nexus-cos.git -d nexuscos.online
```

#### What This Does

1. **Installs Docker/Compose** - Container runtime environment
2. **Opens Required Ports** - 80, 443, 4000, 3002, 3041, 8088
3. **Clones Repository** - To `/opt/nexus-cos`
4. **Configures SSH Keys** - For non-interactive deployment
5. **Starts PF Services** - Via Docker Compose:
   - Streamcore (3016)
   - V-Screen Hollywood (8088)
   - V-Stage, V-Caster, V-Prompter
   - Gateway API (4000)
   - AI SDK (3002)
   - PV Keys (3041)
6. **Configures Nginx** - Unified proxy configuration
7. **Attaches to Docker Network** - `cos-net` bridge network
8. **Validates Deployment** - Health checks and route testing

### Step 3: Deploy from Windows (PowerShell)

After SSH keys are authorized, deploy from Windows:

```powershell
# Navigate to repository
cd C:\path\to\nexus-cos

# Run PowerShell deployment script
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -SshUser "root" `
  -KeyFile "C:\path\to\private\key"

# OR use PuTTY plink
.\scripts\pf-vps-deploy.ps1 `
  -VpsIp "74.208.155.161" `
  -Domain "nexuscos.online" `
  -UsePlink
```

#### PowerShell Script Features

- ✅ Non-interactive SSH deployment
- ✅ Automatic service validation
- ✅ Streaming route verification
- ✅ Deployment log capture
- ✅ OpenSSH or PuTTY support

### Step 4: Validation (Production)

After deployment, validate all endpoints:

```bash
# Frontend
curl -I https://nexuscos.online/
# Expected: 200 OK or 301/302 redirect

# Admin Panel
curl -I https://nexuscos.online/admin
# Expected: 200 OK or 301/302 redirect

# API
curl -I https://nexuscos.online/api
# Expected: 200 OK

# Health Check
curl -s https://nexuscos.online/health
# Expected: JSON with status

# V-Screen (primary route)
curl -I https://nexuscos.online/v-suite/screen
# Expected: 200 OK

# V-Screen (alternative route)
curl -I https://nexuscos.online/v-screen
# Expected: 200 OK

# V-Hollywood
curl -I https://nexuscos.online/v-suite/hollywood
# Expected: 200 OK

# V-Prompter
curl -I https://nexuscos.online/v-suite/prompter
# Expected: 200 OK

# WebSocket (if applicable)
curl -I https://nexuscos.online/socket.io/
# Expected: 101 Switching Protocols
```

## Common Issues & Solutions

### Issue: Frontend Still Shows Dev URLs

**Problem**: Accessing `http://localhost:5173` shows development version

**Solution**: 
- This is expected - localhost:5173 is the dev server
- Production is at `https://nexuscos.online`
- Rebuild frontend with production env vars:
  ```bash
  cd frontend
  npm run build
  ```

### Issue: V-Screen Returns 502 Bad Gateway

**Problem**: Nginx returns 502 when accessing V-Screen routes

**Solutions**:
1. Check if V-Screen Hollywood container is running:
   ```bash
   docker ps | grep vscreen-hollywood
   ```

2. Check if port 8088 is accessible:
   ```bash
   curl http://localhost:8088/health
   ```

3. Verify Nginx upstream configuration:
   ```bash
   grep -A 3 "upstream vscreen_hollywood" /etc/nginx/nginx.conf
   ```

4. Check container logs:
   ```bash
   docker logs vscreen-hollywood
   ```

### Issue: Localhost URLs in Production Build

**Problem**: Frontend .env contains localhost URLs

**Solution**:
```bash
cd frontend
# Edit .env to use production URLs
echo "VITE_API_URL=/api" > .env
echo "VITE_V_SCREEN_URL=https://nexuscos.online/v-suite/screen" >> .env
# Rebuild
npm run build
```

### Issue: SSH Key Not Working

**Problem**: PowerShell script fails to connect

**Solutions**:
1. Verify key is in VPS authorized_keys:
   ```bash
   ssh root@74.208.155.161 "cat /root/.ssh/authorized_keys"
   ```

2. Check key permissions (Linux/Mac):
   ```bash
   chmod 600 /path/to/private/key
   ```

3. Test manual SSH connection:
   ```bash
   ssh -i /path/to/private/key root@74.208.155.161
   ```

## Docker Network Configuration

All services must be on the `cos-net` bridge network for container-to-container communication:

```bash
# Verify network exists
docker network inspect cos-net

# Check which containers are on the network
docker network inspect cos-net | grep -A 3 '"Name"'
```

## Service Ports Reference

| Service | Container Port | Host Port | Description |
|---------|---------------|-----------|-------------|
| Nginx | 80, 443 | 80, 443 | Web server (HTTP/HTTPS) |
| Gateway API | 4000 | 4000 | Main API endpoint |
| AI SDK | 3002 | 3002 | PUABO AI SDK |
| PV Keys | 3041 | 3041 | Key management |
| Streamcore | 3016 | 3016 | Streaming core |
| V-Screen Hollywood | 8088 | 8088 | Virtual LED/Production |
| PostgreSQL | 5432 | 5432 | Database |
| Redis | 6379 | 6379 | Cache |

## Nginx Configuration Files

- **Docker Mode**: `nginx.conf.docker` - Uses Docker service names
- **Host Mode**: `nginx.conf.host` - Uses localhost with ports
- **Routes**: `nginx/conf.d/nexus-proxy.conf` - All PF service routes

## Logs & Monitoring

### Docker Logs
```bash
# All services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f

# Specific service
docker logs -f vscreen-hollywood
docker logs -f puabo-api
```

### Nginx Logs
```bash
# Access log
tail -f /var/log/nginx/nexuscos.online_access.log

# Error log
tail -f /var/log/nginx/nexuscos.online_error.log
```

### Service Status
```bash
# Check all services
docker compose -f /opt/nexus-cos/docker-compose.pf.yml ps

# Check specific service health
curl http://localhost:8088/health
curl http://localhost:4000/health
```

## Deployment Checklist

- [ ] SSH keys authorized on VPS
- [ ] Production environment variables configured (no localhost!)
- [ ] Frontend .env has V-Suite URLs
- [ ] Docker and Docker Compose installed
- [ ] Ports opened in firewall (80, 443, 4000, 3002, 3041, 8088)
- [ ] SSL certificates present and valid
- [ ] Repository cloned to `/opt/nexus-cos`
- [ ] All services started via docker-compose.pf.yml
- [ ] Nginx configured with nexus-proxy.conf routes
- [ ] Frontend built with production URLs
- [ ] Health endpoints responding (200 OK)
- [ ] V-Suite streaming routes accessible
- [ ] WebSocket connections working
- [ ] DNS pointing to VPS IP

## Quick Commands

```bash
# Start all services
cd /opt/nexus-cos
docker compose -f docker-compose.pf.yml up -d

# Stop all services
docker compose -f docker-compose.pf.yml down

# Restart a service
docker compose -f docker-compose.pf.yml restart vscreen-hollywood

# View logs
docker compose -f docker-compose.pf.yml logs -f

# Rebuild and restart
docker compose -f docker-compose.pf.yml up -d --build

# Check nginx config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx

# Test streaming routes
curl -I https://nexuscos.online/v-suite/screen
curl -I https://nexuscos.online/v-screen
curl -I https://nexuscos.online/v-suite/hollywood
```

## Support & Documentation

- **Architecture**: `PF_ARCHITECTURE.md`
- **Nginx Config**: `NGINX_CONFIGURATION_README.md`
- **IP/Domain**: `PF_IP_DOMAIN_UNIFICATION.md`
- **V-Screen Implementation**: `VSCREEN_HOLLYWOOD_IMPLEMENTATION_SUMMARY.md`
- **29 Services**: `29_SERVICES_DEPLOYMENT.md`

## Next Steps After Deployment

1. ✅ Validate all endpoints return 200 OK
2. ✅ Test V-Suite streaming routes
3. ✅ Verify WebSocket connections
4. ✅ Check service logs for errors
5. ✅ Configure monitoring/alerting
6. ✅ Set up automated backups
7. ✅ Document custom configurations
8. ✅ Test frontend in production
9. ✅ Verify SSL certificate expiry
10. ✅ Load test critical endpoints

---

**For questions or issues, refer to the repository documentation or deployment logs.**

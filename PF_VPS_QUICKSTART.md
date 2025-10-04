# PF VPS Quick Start Guide

**Target:** Production deployment on VPS at `/opt/nexus-cos`  
**Time Required:** ~15 minutes  
**Status:** ✅ Ready for Launch

---

## Pre-Flight Checklist

Before you begin, ensure you have:

- [ ] SSH access to your VPS
- [ ] Docker installed and running
- [ ] Docker Compose v2.0+ installed
- [ ] Repository cloned at `/opt/nexus-cos`
- [ ] OAuth credentials from your provider
- [ ] Secure JWT secret generated
- [ ] Database password chosen

---

## 5-Step Launch Process

### Step 1: Configure Credentials (2 minutes)

```bash
# SSH into your VPS
ssh your-user@your-vps-ip

# Navigate to repository
cd /opt/nexus-cos

# Copy environment template
cp .env.pf.example .env.pf

# Edit with your credentials
nano .env.pf
```

**Required Changes in .env.pf:**

```bash
# Change these placeholder values:
OAUTH_CLIENT_ID=your-actual-oauth-client-id-here
OAUTH_CLIENT_SECRET=your-actual-oauth-client-secret-here
JWT_SECRET=generate-a-secure-random-string-here
DB_PASSWORD=choose-a-strong-database-password-here
```

**Tip:** Generate a secure JWT secret:
```bash
openssl rand -base64 32
```

Save and exit (Ctrl+X, Y, Enter in nano).

---

### Step 2: Validate Configuration (1 minute)

```bash
# Run the validation script
./validate-pf.sh
```

**Expected Output:**
- All configuration files found ✓
- All services configured ✓
- Docker installed ✓

If validation fails, review error messages and fix issues before proceeding.

---

### Step 3: Deploy PF Stack (5 minutes)

```bash
# Stop any existing services
docker compose -f docker-compose.pf.yml down

# Build and start all services
docker compose -f docker-compose.pf.yml up -d --build
```

**What This Does:**
- Builds frontend with TypeScript validation
- Pulls required Docker images
- Starts all PF services
- Creates database and applies schema
- Sets up health checks

**Monitor Progress:**
```bash
# Watch the logs during startup
docker compose -f docker-compose.pf.yml logs -f
```

Press Ctrl+C to stop watching logs (services continue running).

---

### Step 4: Verify Deployment (3 minutes)

```bash
# Run the health check script
./pf-health-check.sh
```

**Expected Results:**
- ✅ All services running
- ✅ Hollywood health check (port 4000) → 200 OK
- ✅ Prompter health check (port 3002) → 200 OK
- ✅ PV Keys health check (port 3041) → 200 OK
- ✅ Database connected
- ✅ Redis responding

**Alternative Manual Checks:**
```bash
# Check Hollywood/Gateway endpoint
curl http://localhost:4000/health

# Check Prompter/AI SDK endpoint
curl http://localhost:3002/health

# Check PV Keys endpoint
curl http://localhost:3041/health

# Check service statuses
docker compose -f docker-compose.pf.yml ps
```

All health checks should return: `{"status":"ok","timestamp":"..."}`

---

### Step 5: Final Verification (2 minutes)

```bash
# Check database tables
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "\dt"
```

**Expected Tables:**
- users
- sessions
- api_keys
- audit_log

```bash
# Check service logs for errors
docker compose -f docker-compose.pf.yml logs --tail=50
```

Look for:
- ✅ No error messages
- ✅ "Server listening on port..." messages
- ✅ "Database connected successfully" messages

---

## Success! You're Live 🎉

Your Nexus COS PF platform is now running!

**Service Endpoints:**

| Endpoint | URL | Purpose |
|----------|-----|---------|
| Hollywood | http://your-vps-ip:4000/health | Main API Gateway |
| Prompter | http://your-vps-ip:3002/health | V-Suite Prompter |
| PV Keys | http://your-vps-ip:3041/health | Key Management |

**Next Steps:**

1. **Configure Nginx** (if not using Docker nginx):
   - Update nginx configuration on host
   - Point routes to PF services
   - Configure SSL certificates

2. **Test Your Application**:
   - Access your application through the configured domain
   - Test authentication flows
   - Verify API endpoints

3. **Set Up Monitoring**:
   - Check logs regularly: `docker compose -f docker-compose.pf.yml logs -f`
   - Monitor resource usage: `docker stats`
   - Set up alerts for service failures

---

## Common Commands

### Service Management

```bash
# View service status
docker compose -f docker-compose.pf.yml ps

# Restart all services
docker compose -f docker-compose.pf.yml restart

# Restart specific service
docker compose -f docker-compose.pf.yml restart puabo-api

# Stop all services
docker compose -f docker-compose.pf.yml down

# View logs (all services)
docker compose -f docker-compose.pf.yml logs -f

# View logs (specific service)
docker compose -f docker-compose.pf.yml logs -f puabo-api
```

### Health Checks

```bash
# Run comprehensive health check
./pf-health-check.sh

# Manual health checks
curl http://localhost:4000/health  # Hollywood/Gateway
curl http://localhost:3002/health  # Prompter/AI SDK
curl http://localhost:3041/health  # PV Keys
```

### Database Access

```bash
# Connect to PostgreSQL
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db

# View tables
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "\dt"

# Query users
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
  psql -U nexus_user -d nexus_db -c "SELECT * FROM users;"
```

### Updates and Rebuilds

```bash
# Pull latest changes from repository
git pull origin main

# Rebuild and restart services
docker compose -f docker-compose.pf.yml down
docker compose -f docker-compose.pf.yml up -d --build

# Verify after update
./pf-health-check.sh
```

---

## Troubleshooting

### Services Won't Start

**Check logs:**
```bash
docker compose -f docker-compose.pf.yml logs --tail=100
```

**Common issues:**
- Missing or invalid credentials in `.env.pf`
- Ports already in use (check with `netstat -tulpn`)
- Insufficient disk space (check with `df -h`)
- Docker not running (restart with `systemctl restart docker`)

### Health Checks Fail

**Check if services are running:**
```bash
docker compose -f docker-compose.pf.yml ps
```

**Check network connectivity:**
```bash
docker network ls
docker network inspect nexus-cos_cos-net
```

**Restart failed service:**
```bash
docker compose -f docker-compose.pf.yml restart [service-name]
```

### Database Connection Errors

**Check database is running:**
```bash
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres pg_isready
```

**Verify credentials:**
```bash
grep DB_PASSWORD .env.pf
```

**Check database logs:**
```bash
docker compose -f docker-compose.pf.yml logs nexus-cos-postgres
```

### Frontend Build Fails

**Check TypeScript configuration:**
```bash
cat frontend/tsconfig.json
```

**Review build logs:**
```bash
docker compose -f docker-compose.pf.yml logs puabo-api | grep -i typescript
```

**Rebuild frontend:**
```bash
docker compose -f docker-compose.pf.yml up -d --build puabo-api
```

---

## Need Help?

**Documentation:**
- Complete guide: `docs/PF_FINAL_DEPLOYMENT_TURNKEY.md`
- Implementation details: `PF_EXECUTION_SUMMARY.md`
- Deployment verification: `PF_DEPLOYMENT_VERIFICATION.md`

**Quick Reference:**
- PF Index: `PF_INDEX.md`
- Service architecture: `PF_ARCHITECTURE.md`

**Scripts:**
- Health check: `./pf-health-check.sh`
- Validation: `./validate-pf.sh`
- Deployment: `./deploy-pf.sh`

---

## Post-Deployment Security

1. **Secure your .env.pf:**
   ```bash
   chmod 600 .env.pf
   ```

2. **Regular backups:**
   ```bash
   # Backup database
   docker compose -f docker-compose.pf.yml exec nexus-cos-postgres \
     pg_dump -U nexus_user nexus_db > backup-$(date +%Y%m%d).sql
   ```

3. **Update regularly:**
   ```bash
   # Keep Docker images updated
   docker compose -f docker-compose.pf.yml pull
   docker compose -f docker-compose.pf.yml up -d
   ```

4. **Monitor logs:**
   ```bash
   # Set up log rotation and monitoring
   docker compose -f docker-compose.pf.yml logs -f | tee -a logs/pf.log
   ```

---

**Last Updated:** 2025-01-04  
**Status:** ✅ Production Ready  
**Tested:** ✅ Verified on VPS Environment

Happy Launching! 🚀

# Fixing Deployment Issues - Nexus COS

This document provides comprehensive guidance on fixing deployment issues for the Nexus COS platform on a VPS server.

## Table of Contents
1. [Common Issues and Solutions](#common-issues-and-solutions)
2. [Automated Fix Script](#automated-fix-script)
3. [Manual Troubleshooting](#manual-troubleshooting)
4. [Service-Specific Fixes](#service-specific-fixes)
5. [Production Deployment Checklist](#production-deployment-checklist)

---

## Common Issues and Solutions

### Issue 1: PostgreSQL Container Conflict
**Error:** `The container name "/nexus-postgres" is already in use`

**Solution:**
```bash
# Remove the existing container
docker rm -f nexus-postgres

# Create a new container
docker run -d \
  --name nexus-postgres \
  -e POSTGRES_DB=nexuscos_db \
  -e POSTGRES_USER=nexuscos \
  -e POSTGRES_PASSWORD=password \
  -p 5432:5432 \
  postgres:15-alpine

# Verify it's running
docker ps | grep nexus-postgres
```

### Issue 2: Backend API Error - "unknown option '--port'"
**Error:** `error: unknown option '--port'`

**Root Cause:** PM2 was started with invalid command-line options instead of using environment variables.

**Solution:**
```bash
# Remove the errored process
pm2 delete backend-api

# Restart using ecosystem config (which uses env vars)
pm2 start ecosystem.config.js --only backend-api

# Or restart all services
pm2 start ecosystem.config.js
```

**Why it happened:** The PORT should be set via environment variables in the ecosystem.config.js file, not as a command-line argument.

### Issue 3: Services in Errored State
**Symptoms:** Services showing status "errored" with high restart counts

**Common Causes:**
1. Missing dependencies (`node_modules`)
2. Database connection failures
3. Port conflicts
4. Missing environment variables

**Solution:**
```bash
# Install dependencies for a specific service
cd services/backend-api
npm install --production

# Check logs to identify the actual error
pm2 logs backend-api --lines 50

# Restart the service
pm2 restart backend-api
```

### Issue 4: Missing Dependencies
**Error:** `Cannot find module 'express'` or similar

**Solution:**
```bash
# Install root dependencies
npm install

# Install service-specific dependencies
cd services/backend-api && npm install
cd ../puabomusicchain && npm install

# Or use the automated script
./fix-deployment-issues.sh
```

---

## Automated Fix Script

The `fix-deployment-issues.sh` script automates most common fixes:

### What It Does:
1. ✅ Fixes PostgreSQL container conflicts
2. ✅ Installs missing dependencies for all services
3. ✅ Cleans up errored PM2 processes
4. ✅ Restarts services using proper configuration
5. ✅ Validates service health
6. ✅ Runs security audits

### Usage:
```bash
# Make it executable (first time only)
chmod +x fix-deployment-issues.sh

# Run the script
./fix-deployment-issues.sh
```

### Expected Output:
```
==========================================
Nexus COS Deployment Issue Fixer
==========================================

[INFO] Working directory: /var/www/nexuscos.online/nexus-cos-app/nexus-cos
[INFO] FIX 1: Checking and fixing PostgreSQL database...
[SUCCESS] PostgreSQL container is already running
[INFO] FIX 2: Installing dependencies for services...
[SUCCESS] backend-api dependencies installed
[SUCCESS] puabomusicchain dependencies installed
...
[SUCCESS] Deployment fix script completed!
```

---

## Manual Troubleshooting

### Check Service Status
```bash
# List all PM2 processes
pm2 list

# Check specific service status
pm2 describe backend-api

# View logs
pm2 logs backend-api --lines 50
pm2 logs --lines 100
```

### Check Ports
```bash
# Check if services are listening on expected ports
netstat -tulpn | grep -E '3001|3013|8088|5432'

# Check specific port
lsof -i :3001
```

### Check Docker Services
```bash
# List running containers
docker ps

# Check PostgreSQL logs
docker logs nexus-postgres

# Execute command in container
docker exec -it nexus-postgres psql -U nexuscos -d nexuscos_db
```

### Test Service Endpoints
```bash
# Test backend-api
curl http://localhost:3001/health
curl http://localhost:3001/api

# Test puabomusicchain
curl http://localhost:3013/health

# Test v-screen-hollywood
curl http://localhost:8088/health
```

---

## Service-Specific Fixes

### Backend API (Port 3001)

**Common Issues:**
- Database connection failures
- Missing route modules
- Port already in use

**Fix:**
```bash
# 1. Check if dependencies are installed
cd services/backend-api
ls node_modules/ | grep express

# 2. If missing, install
npm install --production

# 3. Check database connectivity
docker exec nexus-postgres pg_isready -U nexuscos

# 4. Restart the service
pm2 restart backend-api

# 5. Check logs
pm2 logs backend-api --lines 20
```

**Configuration (ecosystem.config.js):**
```javascript
{
  name: 'backend-api',
  script: './services/backend-api/server.js',
  instances: 1,
  autorestart: true,
  env: {
    NODE_ENV: 'production',
    PORT: 3001,
    DB_HOST: 'localhost',
    DB_PORT: 5432,
    DB_NAME: 'nexuscos_db',
    DB_USER: 'nexuscos',
    DB_PASSWORD: 'password'
  }
}
```

### PuaboMusicChain (Port 3013)

**Common Issues:**
- Missing express dependency
- Port conflicts

**Fix:**
```bash
# 1. Install dependencies
cd services/puabomusicchain
npm install express --save

# 2. Restart
pm2 restart puabomusicchain

# 3. Verify
curl http://localhost:3013/health
```

### V-Screen Hollywood (Port 8088)

**Common Issues:**
- Not started with PM2
- Service directory missing

**Fix:**
```bash
# 1. Check if directory exists
ls -la services/vscreen-hollywood/

# 2. Start with PM2
cd services/vscreen-hollywood
pm2 start server.js --name vscreen-hollywood

# 3. Verify
curl http://localhost:8088/health
```

---

## Production Deployment Checklist

### Pre-Deployment
- [ ] Backup existing database and configurations
- [ ] Review `.env` file for correct settings
- [ ] Ensure all SSL certificates are valid
- [ ] Check DNS settings point to VPS

### Deployment Steps
1. **Clone/Update Repository**
   ```bash
   cd /var/www/nexuscos.online/nexus-cos-app/nexus-cos
   git pull origin main
   ```

2. **Install Dependencies**
   ```bash
   npm install
   # Install for each service
   find services/ -name package.json -execdir npm install \;
   ```

3. **Setup Database**
   ```bash
   ./fix-deployment-issues.sh
   # Or manually:
   docker run -d --name nexus-postgres \
     -e POSTGRES_DB=nexuscos_db \
     -e POSTGRES_USER=nexuscos \
     -e POSTGRES_PASSWORD=password \
     -p 5432:5432 \
     postgres:15-alpine
   ```

4. **Start Services**
   ```bash
   pm2 start ecosystem.config.js
   pm2 save
   pm2 startup  # Enable PM2 to start on boot
   ```

5. **Configure Nginx**
   ```bash
   # Copy nginx configuration
   sudo cp nginx.conf /etc/nginx/sites-available/nexuscos.online
   sudo ln -s /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/
   
   # Test and reload
   sudo nginx -t
   sudo systemctl reload nginx
   ```

6. **Setup SSL**
   ```bash
   sudo certbot --nginx -d nexuscos.online -d www.nexuscos.online
   ```

### Post-Deployment Validation
- [ ] All PM2 services showing "online" status
- [ ] Database accepting connections
- [ ] All health endpoints responding
- [ ] Nginx routing correctly
- [ ] SSL certificates valid
- [ ] No errors in PM2 logs
- [ ] No errors in Nginx logs

### Validation Commands
```bash
# Check all services
pm2 list

# Test all critical endpoints
curl http://localhost:3001/health  # Backend API
curl http://localhost:3013/health  # PuaboMusicChain
curl http://localhost:8088/health  # V-Screen Hollywood

# Check database
docker exec nexus-postgres pg_isready -U nexuscos

# Check Nginx
sudo nginx -t
curl -I https://nexuscos.online

# View logs
pm2 logs --lines 50
sudo tail -f /var/log/nginx/error.log
```

### Production Audit
Run the production audit script to validate everything:
```bash
./production-audit.sh
```

This will check:
- ✅ All services are running
- ✅ Database connectivity
- ✅ Nginx configuration
- ✅ SSL certificates
- ✅ Port availability
- ✅ Security settings

---

## Monitoring and Maintenance

### Set Up PM2 Monitoring
```bash
# Enable PM2 monitoring
pm2 install pm2-logrotate

# Configure log rotation
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### Regular Health Checks
Create a cron job for automated health checks:
```bash
# Edit crontab
crontab -e

# Add health check every 5 minutes
*/5 * * * * /var/www/nexuscos.online/nexus-cos-app/nexus-cos/health-check.sh >> /var/log/nexus-health.log 2>&1
```

### Backup Strategy
```bash
# Backup database daily
0 2 * * * docker exec nexus-postgres pg_dump -U nexuscos nexuscos_db | gzip > /backups/nexuscos_db_$(date +\%Y\%m\%d).sql.gz

# Keep only last 7 days of backups
0 3 * * * find /backups/ -name "nexuscos_db_*.sql.gz" -mtime +7 -delete
```

---

## Troubleshooting Common Errors

### Error: "EADDRINUSE" (Port already in use)
```bash
# Find process using the port
lsof -i :3001

# Kill the process
kill -9 <PID>

# Or use PM2 to manage
pm2 delete backend-api
pm2 start ecosystem.config.js --only backend-api
```

### Error: "Cannot connect to database"
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check database logs
docker logs nexus-postgres

# Restart PostgreSQL
docker restart nexus-postgres

# Wait for it to be ready
sleep 5
docker exec nexus-postgres pg_isready -U nexuscos
```

### Error: High Memory Usage
```bash
# Check memory usage
pm2 monit

# Restart services with high memory
pm2 restart <service-name>

# Set memory limit in ecosystem.config.js
max_memory_restart: '512M'
```

### Error: Service Keeps Crashing
```bash
# Check error logs
pm2 logs <service-name> --err --lines 100

# Common fixes:
# 1. Install dependencies
cd services/<service-name>
npm install

# 2. Check environment variables
pm2 describe <service-name>

# 3. Disable auto-restart temporarily to see the error
pm2 stop <service-name>
node services/<service-name>/server.js
```

---

## Getting Help

If issues persist after following this guide:

1. **Check Logs:**
   - PM2 logs: `pm2 logs --lines 100`
   - Nginx logs: `sudo tail -f /var/log/nginx/error.log`
   - Docker logs: `docker logs nexus-postgres`

2. **Verify Configuration:**
   - `.env` file has correct values
   - `ecosystem.config.js` has correct ports
   - Nginx config is valid: `sudo nginx -t`

3. **Run Diagnostics:**
   ```bash
   ./fix-deployment-issues.sh
   ./production-audit.sh
   pm2 list
   docker ps
   ```

4. **Contact Support:**
   - Include output from diagnostic commands
   - Include relevant log excerpts
   - Specify which services are failing

---

## Version History

- **v1.0.0** (2024-11-17): Initial deployment fix documentation
  - Added PostgreSQL container fix
  - Added PM2 service fixes
  - Added comprehensive troubleshooting guide
  - Added production checklist

---

## Additional Resources

- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [PostgreSQL Docker Documentation](https://hub.docker.com/_/postgres)
- [Nginx Configuration Guide](https://nginx.org/en/docs/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

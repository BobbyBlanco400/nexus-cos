# N3XUS Emergency Network Fix - Complete Guide

## 🚨 Emergency Network Repair Script

This guide explains the **N3XUS Handshake 55-45-17** emergency network repair system implemented to fix Docker Compose and nginx configuration issues.

## 🎯 Problem Statement

The original issue manifested as:
```
nginx: [emerg] host not found in upstream "nexus-cos-puaboai-sdk:3002" in /etc/nginx/nginx.conf:11
```

### Root Causes Identified:
1. ❌ Obsolete `version` attribute in docker-compose.yml
2. ❌ Missing PostgreSQL database service
3. ❌ nginx.conf referenced non-existent upstream services
4. ❌ API container missing curl for health checks
5. ❌ Inconsistent database environment variables

## ✅ Solution Implemented

### 1. Fixed docker-compose.yml

**Changes Made:**
- Removed obsolete `version` attribute (Docker Compose v2+ doesn't require it)
- Added PostgreSQL service with health checks:
  ```yaml
  postgres:
    image: postgres:15-alpine
    container_name: nexus-postgres
    environment:
      POSTGRES_DB: ${DATABASE_NAME:-nexus_db}
      POSTGRES_USER: ${DATABASE_USER:-nexus_user}
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD:-nexus_pass}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DATABASE_USER:-nexus_user} -d ${DATABASE_NAME:-nexus_db}"]
      interval: 10s
      timeout: 5s
      retries: 5
  ```
- Configured API service with comprehensive database environment variables
- Added service dependencies with health check conditions

### 2. Enhanced Dockerfile

**Added curl for health checks:**
```dockerfile
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

### 3. Updated Environment Variables

**Added to .env:**
```bash
# For Docker Compose - these variables are used by docker-compose.yml
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=nexus_db
DATABASE_USER=nexus_user
DATABASE_PASSWORD=nexus_pass
```

### 4. Created Emergency Network Repair Script

**Location:** `/scripts/emergency-network-fix.sh`

**Features:**
- ✅ Auto-detects Docker Compose v1 or v2
- ✅ Enforces N3XUS Handshake 55-45-17
- ✅ Verifies handshake in configuration files
- ✅ Rebuilds and restarts all services
- ✅ Performs comprehensive health checks
- ✅ Validates N3XUS Handshake in HTTP responses
- ✅ Provides color-coded status output
- ✅ Returns proper exit codes

## 🚀 How to Use the Emergency Network Fix

### Quick Start

From the repository root:
```bash
cd /var/www/nexus-cos/nexus-cos
bash scripts/emergency-network-fix.sh
```

### What the Script Does

1. **Verification Phase:**
   - Checks N3XUS Handshake 55-45-17 in configuration files
   - Verifies nginx.conf.docker has the handshake header
   - Verifies server.js sets the handshake header

2. **Cleanup Phase:**
   - Stops and removes all existing containers
   - Cleans up dangling Docker images

3. **Build and Deploy Phase:**
   - Builds Docker images with latest changes
   - Starts all services in detached mode
   - Waits 30 seconds for services to stabilize

4. **Health Check Phase:**
   - **Backend API (Port 3000):**
     - Verifies /health endpoint is accessible
     - Validates N3XUS Handshake 55-45-17 header
     - Displays health check JSON response
   
   - **Nginx Proxy (Port 80):**
     - Verifies proxy is routing correctly
     - Validates N3XUS Handshake 55-45-17 header
   
   - **PostgreSQL Database:**
     - Verifies database is accepting connections
     - Tests with pg_isready command

5. **Final Summary:**
   - Reports overall system status
   - Lists all running containers
   - Returns exit code 0 if all systems operational
   - Returns exit code 1 if any system requires attention

### Expected Output (Success)

```bash
🔵 Starting Emergency Network Repair...
🔒 Enforcing N3XUS Handshake 55-45-17...
   Using: docker compose

🔍 Verifying N3XUS Handshake 55-45-17 in configuration files...
✓ N3XUS Handshake 55-45-17 verified in nginx.conf.docker
✓ N3XUS Handshake 55-45-17 verified in server.js

🛑 Stopping all existing containers...
🧹 Cleaning up dangling images...
🚀 Building and starting services with N3XUS Handshake 55-45-17...
⏳ Waiting for services to stabilize (30s)...

🔍 Verifying Backend Status (Host -> Port 3000)...
✅ BACKEND OPERATIONAL on Port 3000
✅ N3XUS Handshake 55-45-17 VERIFIED in API Response
   Header: x-nexus-handshake: 55-45-17

📊 Backend Health:
{
  "status": "ok",
  "timestamp": "2026-01-11T06:56:00.000Z",
  "uptime": 5.123,
  "environment": "production",
  "version": "1.0.0",
  "db": "up"
}

🔍 Verifying Nginx Proxy (Host -> Port 80)...
✅ NGINX PROXY OPERATIONAL
✅ N3XUS Handshake 55-45-17 VERIFIED in Nginx Response
   Header: x-nexus-handshake: 55-45-17

🔍 Verifying Database Connection...
✅ DATABASE OPERATIONAL

📦 Running Containers:
NAME              IMAGE              STATUS        PORTS
nexus-postgres   postgres:15-alpine  Up 35 seconds  0.0.0.0:5432->5432/tcp
puabo-api        nexus-cos-api       Up 30 seconds  0.0.0.0:3000->3000/tcp
nexus-nginx      nginx:alpine        Up 25 seconds  0.0.0.0:80->80/tcp

═══════════════════════════════════════════════════════
         N3XUS EMERGENCY REPAIR COMPLETE
         Handshake 55-45-17 Enforcement Active
═══════════════════════════════════════════════════════

✅ ALL SYSTEMS OPERATIONAL
✅ N3XUS Handshake 55-45-17 VERIFIED
✅ Platform Ready for Launch
```

## 🔧 Configuration

### Environment Variables

The script uses these environment variables (with defaults):
```bash
DATABASE_USER=nexus_user    # PostgreSQL username
DATABASE_NAME=nexus_db      # PostgreSQL database name  
DATABASE_PASSWORD=nexus_pass # PostgreSQL password
```

### Customization

You can customize the defaults in the script:
```bash
# Configuration section at top of script
DEFAULT_DB_USER="nexus_user"
DEFAULT_DB_NAME="nexus_db"
```

## 📝 N3XUS Handshake 55-45-17 Compliance

### What is N3XUS Handshake 55-45-17?

The N3XUS Handshake is a governance header that ensures:
- Platform authenticity
- Service integrity verification
- Request tracking and compliance
- Inter-service communication validation

### Implementation Points

1. **nginx.conf.docker (Line 13):**
   ```nginx
   proxy_set_header X-N3XUS-Handshake "55-45-17";
   ```

2. **nginx.conf.docker (Line 31):**
   ```nginx
   add_header X-Nexus-Handshake "55-45-17" always;
   ```

3. **server.js (Lines 18-22):**
   ```javascript
   app.use((req, res, next) => {
     res.setHeader('X-Nexus-Handshake', '55-45-17');
     next();
   });
   ```

## 🐛 Troubleshooting

### Script Fails with "Command not found"

**Problem:** Docker or Docker Compose not installed
**Solution:**
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Verify installation
docker --version
docker compose version
```

### Backend Unreachable

**Problem:** API service fails to start
**Solution:**
```bash
# Check API logs
docker logs puabo-api --tail 100

# Common issues:
# - Database connection failed: Check DATABASE_* variables in .env
# - Port already in use: Stop conflicting service on port 3000
# - Build errors: Check package.json dependencies
```

### Nginx Proxy Failed

**Problem:** Nginx fails to start
**Solution:**
```bash
# Check nginx logs
docker logs nexus-nginx --tail 100

# Common issues:
# - Port 80 already in use: Stop conflicting web server
# - Configuration syntax error: Validate nginx.conf.docker
# - Upstream not found: Ensure API service is healthy
```

### Database Connection Failed

**Problem:** PostgreSQL not responding
**Solution:**
```bash
# Check database logs
docker logs nexus-postgres --tail 100

# Verify database is running
docker ps | grep postgres

# Connect to database manually
docker exec -it nexus-postgres psql -U nexus_user -d nexus_db
```

## 🎯 Verification Steps

After running the emergency fix, verify:

1. **All containers are running:**
   ```bash
   docker compose ps
   ```

2. **Backend API is accessible:**
   ```bash
   curl -i http://localhost:3000/health
   ```

3. **Nginx proxy is working:**
   ```bash
   curl -i http://localhost:80/health
   ```

4. **N3XUS Handshake is present:**
   ```bash
   curl -I http://localhost:3000/health | grep -i "x-nexus-handshake"
   curl -I http://localhost:80/health | grep -i "x-nexus-handshake"
   ```

5. **Database is operational:**
   ```bash
   docker exec nexus-postgres pg_isready -U nexus_user -d nexus_db
   ```

## 📚 Related Documentation

- [docker-compose.yml](/docker-compose.yml) - Main Docker Compose configuration
- [nginx.conf.docker](/nginx.conf.docker) - Nginx configuration for Docker mode
- [Dockerfile](/Dockerfile) - API service Docker image
- [.env.example](/.env.example) - Environment variable template

## 🔐 Security Notes

- Change default database passwords in production
- Use strong JWT secrets
- Enable SSL/TLS for production deployments
- Keep Docker images updated
- Review and update N3XUS Handshake governance as needed

## 📞 Support

For issues or questions:
1. Check troubleshooting section above
2. Review Docker logs: `docker compose logs`
3. Verify environment variables in `.env`
4. Ensure Docker and Docker Compose are up to date

---

**N3XUS Platform - Handshake 55-45-17 Enforcement Active**

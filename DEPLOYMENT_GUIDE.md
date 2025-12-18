# Nexus COS Platform - Global Launch Deployment Guide

## Overview
This guide provides instructions for deploying the Nexus COS Platform with all fixes applied for the global production launch.

## Critical Fixes Applied

### 1. Database Driver Correction
**Issue**: server.js was using MySQL driver but docker-compose.pf.yml deploys PostgreSQL
**Fix**: Replaced MySQL driver with PostgreSQL (`pg` package)

### 2. Missing API Endpoints
**Issue**: `/api/status` and `/api/health` endpoints were not implemented
**Fix**: Added both endpoints with database health checks

### 3. Service Path Corrections
**Issue**: PUABO NEXUS services had incorrect paths in docker-compose.pf.yml
**Fix**: Updated all service paths to match actual directory structure

### 4. Dockerfile Build Process
**Issue**: Dockerfile expected TypeScript compilation but no tsconfig.json existed
**Fix**: Updated Dockerfile to run JavaScript directly, created tsconfig.json for future use

## Prerequisites

1. **Docker & Docker Compose**: Installed and running
2. **Environment Configuration**: `.env.pf` file with all required values
3. **SSL Certificates**: Available in `ssl/` directory or at IONOS provider paths
4. **Nginx**: Installed and configured (for host deployment)

## Deployment Steps

### Step 1: Environment Configuration

Ensure `.env.pf` file exists with all required variables:

```bash
# Required variables in .env.pf
NODE_ENV=production
PORT=4000
DB_HOST=nexus-cos-postgres
DB_PORT=5432
DB_NAME=nexus_db
DB_USER=nexus_user
DB_PASSWORD=<your-secure-password>
REDIS_HOST=nexus-cos-redis
REDIS_PORT=6379
OAUTH_CLIENT_ID=<your-oauth-client-id>
OAUTH_CLIENT_SECRET=<your-oauth-client-secret>
JWT_SECRET=<your-jwt-secret>
```

### Step 2: Deploy Services with Docker Compose

```bash
# Navigate to repository root
cd /opt/nexus-cos

# Pull latest changes (if needed)
git pull origin main

# Start all services
docker compose -f docker-compose.pf.yml up -d

# Check service status
docker compose -f docker-compose.pf.yml ps

# View logs
docker compose -f docker-compose.pf.yml logs -f
```

### Step 3: Verify Database Initialization

```bash
# Check PostgreSQL is running
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres pg_isready -U nexus_user

# Verify schema was applied
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db -c "\dt"
```

### Step 4: Test API Endpoints

```bash
# Run the validation script
./test-api-validation.sh

# Or test manually
curl http://localhost:4000/health
curl http://localhost:4000/api
curl http://localhost:4000/api/status
curl http://localhost:4000/api/health
curl http://localhost:4000/api/system/status
curl http://localhost:4000/api/v1/imcus/001/status
```

### Step 5: Configure Nginx (Host Deployment)

```bash
# Copy nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/nexuscos.online

# Create symbolic link
sudo ln -sf /etc/nginx/sites-available/nexuscos.online /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Step 6: Verify Production URLs

```bash
# Test production endpoints (requires domain to be configured)
curl https://nexuscos.online/health
curl https://nexuscos.online/api/
curl https://nexuscos.online/api/status
curl https://nexuscos.online/api/system/status
curl https://nexuscos.online/api/v1/imcus/001/status
curl https://nexuscos.online/api/health
```

## Service Architecture

### Core Services (docker-compose.pf.yml)

1. **nexus-cos-postgres** (Port 5432)
   - PostgreSQL database
   - Schema auto-applied on initialization
   - Health checks enabled

2. **nexus-cos-redis** (Port 6379)
   - Redis cache
   - Used for sessions and caching

3. **puabo-api** (Port 4000)
   - Main API gateway
   - Handles all /api/* routes
   - Database and Redis connected

4. **nexus-cos-puaboai-sdk** (Port 3002)
   - AI SDK service
   - Handles V-Suite prompter routes

5. **nexus-cos-pv-keys** (Port 3041)
   - Key management service

6. **nexus-cos-streamcore** (Port 3016)
   - Streaming core dependency

7. **vscreen-hollywood** (Port 8088)
   - Virtual production suite

8. **PUABO NEXUS Services**:
   - **puabo-nexus-ai-dispatch** (Port 3231)
   - **puabo-nexus-driver-app-backend** (Port 3232)
   - **puabo-nexus-fleet-manager** (Port 3233)
   - **puabo-nexus-route-optimizer** (Port 3234)

### API Endpoints

All endpoints documented in the launch announcement are now functional:

- `GET /health` - Main health check
- `GET /api` - API information and endpoint listing
- `GET /api/health` - API health with database status
- `GET /api/status` - API operational status
- `GET /api/system/status` - Overall system status
- `GET /api/v1/imcus/:id/status` - IMCUS status endpoint
- `GET /api/v1/imcus/:id/nodes` - IMCUS nodes endpoint
- `POST /api/v1/imcus/:id/deploy` - IMCUS deployment endpoint
- `GET /api/creator-hub/status` - Creator Hub module status
- `GET /api/v-suite/status` - V-Suite module status
- `GET /api/puaboverse/status` - PuaboVerse module status
- `GET /api/auth` - Auth service root
- `POST /api/auth/login` - Login endpoint
- `POST /api/auth/register` - Registration endpoint
- `GET /api/users` - Users endpoint

## Troubleshooting

### Service Won't Start

```bash
# Check logs
docker compose -f docker-compose.pf.yml logs <service-name>

# Rebuild service
docker compose -f docker-compose.pf.yml up -d --build <service-name>

# Check environment variables
docker compose -f docker-compose.pf.yml config
```

### Database Connection Issues

```bash
# Verify PostgreSQL is running
docker compose -f docker-compose.pf.yml ps nexus-cos-postgres

# Check database logs
docker compose -f docker-compose.pf.yml logs nexus-cos-postgres

# Test connection
docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db
```

### Nginx Issues

```bash
# Check nginx status
sudo systemctl status nginx

# View nginx error logs
sudo tail -f /var/log/nginx/error.log

# Test configuration
sudo nginx -t

# Restart nginx
sudo systemctl restart nginx
```

### API Endpoints Not Responding

```bash
# Check if puabo-api is running
docker compose -f docker-compose.pf.yml ps puabo-api

# View service logs
docker compose -f docker-compose.pf.yml logs puabo-api

# Check service health
curl http://localhost:4000/health
```

## Health Monitoring

### Automated Health Checks

All services include health checks:
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 3
- Start period: 40 seconds (for dependent services)

### Manual Health Verification

```bash
# Check all services
docker compose -f docker-compose.pf.yml ps

# Run validation script
./test-api-validation.sh

# Check individual service health
curl http://localhost:4000/health
curl http://localhost:3002/health
curl http://localhost:3041/health
curl http://localhost:3016/health
curl http://localhost:8088/health
curl http://localhost:3231/health
curl http://localhost:3232/health
curl http://localhost:3233/health
curl http://localhost:3234/health
```

## Production Checklist

- [ ] All environment variables configured in `.env.pf`
- [ ] SSL certificates installed and configured
- [ ] Docker services running without errors
- [ ] Database schema applied successfully
- [ ] All health endpoints returning 200 OK
- [ ] Nginx configured and routing correctly
- [ ] All documented API endpoints tested and working
- [ ] DNS pointing to production server
- [ ] Monitoring and alerts configured
- [ ] Backup procedures in place

## Support

For issues or questions:
- Repository: https://github.com/BobbyBlanco400/nexus-cos
- Documentation: See PF_INDEX.md and related docs in repository

## Change Log

### 2025-12-18 - Global Launch Fixes
- Fixed database driver (MySQL → PostgreSQL)
- Added missing `/api/status` and `/api/health` endpoints
- Corrected PUABO NEXUS service paths in docker-compose
- Updated Dockerfile for JavaScript execution
- Created comprehensive test suite
- Added deployment documentation

---

**Status**: Ready for Production Deployment
**Last Updated**: 2025-12-18
**Version**: 1.0.0

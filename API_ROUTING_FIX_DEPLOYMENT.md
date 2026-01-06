# API Routing Fix - Deployment Guide

## Problem Diagnosed

The issue was that:
1. **PM2** was configured to run `./services/backend-api/server.js` on port 3001
2. **That file** only had basic health/status endpoints - missing all `/api/*` routes
3. **Root `server.js`** had the complete API routes but wasn't being used by PM2
4. **Nginx** was configured to proxy `/api/` to port 3001, but nothing was listening with the right routes

## Solution Implemented

Updated `services/backend-api/server.js` to include all API routes from the root `server.js`:
- System status endpoints
- Service health checks
- Module status endpoints (Creator Hub, V-Suite, PuaboVerse)
- Auth routes
- User routes

## Files Changed

### 1. `services/backend-api/server.js`
- ✅ Added all `/api/*` route handlers
- ✅ Integrated auth and user routes
- ✅ Added database connection pool
- ✅ Added proper middleware (cors, body-parser)
- ✅ Enhanced health check with DB status

### 2. `services/backend-api/package.json`
- ✅ Added required dependencies: body-parser, cors, dotenv, mysql2

## Deployment Steps

### On Production Server

1. **Pull the latest code:**
   ```bash
   cd /opt/nexus-cos  # or wherever your code is deployed
   git pull origin main
   ```

2. **Install dependencies:**
   ```bash
   # Install root dependencies (needed for routes/auth.js and routes/user.js)
   npm install
   
   # Install backend-api service dependencies
   cd services/backend-api
   npm install
   cd ../..
   ```

3. **Restart PM2 service:**
   ```bash
   pm2 restart backend-api
   # or restart all services
   pm2 restart all
   ```

4. **Verify the service:**
   ```bash
   # Check PM2 status
   pm2 status
   
   # Check logs
   pm2 logs backend-api --lines 50
   ```

## Testing Endpoints

Test locally on the server:

```bash
# Health check
curl http://localhost:3001/health | jq

# API info
curl http://localhost:3001/api | jq

# System status
curl http://localhost:3001/api/system/status | jq

# Auth endpoint
curl http://localhost:3001/api/auth | jq

# Service health
curl http://localhost:3001/api/services/auth/health | jq

# Module status
curl http://localhost:3001/api/creator-hub/status | jq
curl http://localhost:3001/api/v-suite/status | jq
curl http://localhost:3001/api/puaboverse/status | jq
```

Test through Nginx (publicly):

```bash
# Health check
curl https://n3xuscos.online/health | jq

# API endpoints
curl https://n3xuscos.online/api | jq
curl https://n3xuscos.online/api/system/status | jq
curl https://n3xuscos.online/api/auth | jq
curl https://n3xuscos.online/api/creator-hub/status | jq
```

## Nginx Configuration

**No Nginx changes are needed.** The existing configuration already proxies `/api/` to port 3001:

```nginx
# Main API (Port 3001)
location /api/ {
    proxy_pass http://localhost:3001/api/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}
```

**Important Note:** The trailing slashes in `location /api/` and `proxy_pass http://localhost:3001/api/` are critical for proper path forwarding.

## PM2 Configuration

**No PM2 changes are needed.** The existing `ecosystem.config.js` already has:

```javascript
{
  name: 'backend-api',
  script: './services/backend-api/server.js',
  instances: 1,
  autorestart: true,
  watch: false,
  max_memory_restart: '512M',
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

## Environment Variables

Ensure these environment variables are set in `.env` or through PM2:

```bash
# Database connection
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_secure_password

# Application
NODE_ENV=production
PORT=3001
```

## Troubleshooting

### If endpoints return 404:

1. **Check if PM2 service is running:**
   ```bash
   pm2 list
   pm2 logs backend-api
   ```

2. **Check if the service is listening on port 3001:**
   ```bash
   netstat -tlnp | grep 3001
   # or
   lsof -i :3001
   ```

3. **Test directly (bypassing Nginx):**
   ```bash
   curl http://localhost:3001/api
   ```

4. **Check Nginx configuration:**
   ```bash
   nginx -t
   cat /etc/nginx/sites-enabled/nexuscos.conf | grep -A 10 "location /api/"
   ```

### If endpoints return 502 Bad Gateway:

1. **Check PM2 logs for errors:**
   ```bash
   pm2 logs backend-api --err
   ```

2. **Ensure dependencies are installed:**
   ```bash
   cd services/backend-api
   npm list express cors body-parser dotenv mysql2
   ```

3. **Restart the service:**
   ```bash
   pm2 restart backend-api
   ```

### If database health shows "down":

This is expected if database credentials are not configured or the database is not running. The API endpoints will still work; only the database-dependent features will be affected.

## Success Criteria

✅ All API endpoints respond with 200 OK
✅ `/api` returns the API info JSON
✅ `/api/system/status` returns service status
✅ `/api/auth` and `/api/users` return route info
✅ Module status endpoints work correctly
✅ No 404 errors when accessing `/api/*` routes
✅ PM2 shows backend-api service as "online"

## Notes

- The root `server.js` file is kept as-is for reference and backward compatibility
- The `backend/src/server.ts` TypeScript version is also kept but not used in production
- All API functionality is now properly served by the PM2-managed `services/backend-api/server.js`
- This is the **minimal change** solution - we only updated the file that PM2 actually runs

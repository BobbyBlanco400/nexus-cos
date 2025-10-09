# API Routes Deployment Guide

## Overview
This guide documents the changes made to expose `/api/*` routes publicly on https://nexuscos.online.

## Changes Made

### Updated `server.js`
Added the following API endpoints to the root `server.js` file:

1. **System Status Endpoint**: `/api/system/status`
   - Returns health status of all services
   - Response format:
   ```json
   {
     "services": {
       "auth": "healthy",
       "creator-hub": "healthy",
       "v-suite": "healthy",
       "puaboverse": "healthy",
       "database": "healthy",
       "cache": "healthy"
     },
     "updatedAt": "2025-10-09T07:49:45.177Z"
   }
   ```

2. **Generic Service Health Endpoint**: `/api/services/:service/health`
   - Returns health status of a specific service
   - Example: `/api/services/auth/health`
   - Response format:
   ```json
   {
     "service": "auth",
     "status": "healthy",
     "updatedAt": "2025-10-09T07:49:45.178Z"
   }
   ```

3. **Module Status Endpoints**:
   - `/api/creator-hub/status` - Creator Hub module status
   - `/api/v-suite/status` - V-Suite module status
   - `/api/puaboverse/status` - PuaboVerse module status

4. **API Info Endpoint**: `/api`
   - Returns API information and available endpoints

## Deployment Steps

### On the VPS (Production)

1. **Pull the latest changes** from the repository:
   ```bash
   cd /opt/nexus-cos
   git pull origin main
   ```

2. **Restart PM2** to load the updated `server.js`:
   ```bash
   pm2 restart nexuscos-app
   ```
   
   Or if you need to reload:
   ```bash
   pm2 reload nexuscos-app
   ```

3. **Verify the deployment**:
   ```bash
   # Test health endpoint
   curl -s https://nexuscos.online/health | jq .
   
   # Test API root
   curl -s https://nexuscos.online/api | jq .
   
   # Test auth endpoint
   curl -s https://nexuscos.online/api/auth | jq .
   
   # Test system status
   curl -s https://nexuscos.online/api/system/status | jq .
   
   # Test service health
   curl -s https://nexuscos.online/api/services/auth/health | jq .
   
   # Test module status
   curl -s https://nexuscos.online/api/creator-hub/status | jq .
   curl -s https://nexuscos.online/api/v-suite/status | jq .
   curl -s https://nexuscos.online/api/puaboverse/status | jq .
   ```

## Nginx Configuration

The existing Nginx configuration should already be proxying `/api/*` to port 3000. If not, ensure your Nginx configuration includes:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3000/api/;
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

**Note**: The trailing slashes in both `location /api/` and `proxy_pass` are important to ensure proper path forwarding.

## Available Endpoints

After deployment, the following endpoints will be publicly accessible:

### Health & Status
- `GET /health` - Overall health check
- `GET /api` - API information
- `GET /api/system/status` - System-wide status
- `GET /api/services/:service/health` - Specific service health

### Authentication
- `GET /api/auth` - Auth service status
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout

### User Management
- `GET /api/users` - Users list
- `GET /api/users/profile` - User profile
- `PUT /api/users/profile` - Update profile
- `DELETE /api/users/:id` - Delete user

### Module Status
- `GET /api/creator-hub/status` - Creator Hub status
- `GET /api/v-suite/status` - V-Suite status
- `GET /api/puaboverse/status` - PuaboVerse status

## Testing Endpoints

Use the following commands to test all endpoints:

```bash
#!/bin/bash
# Test all API endpoints

BASE_URL="https://nexuscos.online"

echo "Testing /health endpoint..."
curl -sSI $BASE_URL/health

echo -e "\nTesting /api endpoint..."
curl -s $BASE_URL/api | jq .

echo -e "\nTesting /api/auth endpoint..."
curl -s $BASE_URL/api/auth | jq .

echo -e "\nTesting /api/system/status endpoint..."
curl -s $BASE_URL/api/system/status | jq .

echo -e "\nTesting /api/services/auth/health endpoint..."
curl -s $BASE_URL/api/services/auth/health | jq .

echo -e "\nTesting /api/creator-hub/status endpoint..."
curl -s $BASE_URL/api/creator-hub/status | jq .

echo -e "\nTesting /api/v-suite/status endpoint..."
curl -s $BASE_URL/api/v-suite/status | jq .

echo -e "\nTesting /api/puaboverse/status endpoint..."
curl -s $BASE_URL/api/puaboverse/status | jq .
```

## Troubleshooting

### If `/api` returns 404:
1. Verify PM2 is running the updated `server.js`:
   ```bash
   pm2 info nexuscos-app
   pm2 logs nexuscos-app --lines 50
   ```

2. Check if the code was pulled correctly:
   ```bash
   cd /opt/nexus-cos
   git log --oneline -n 5
   ```

3. Restart PM2:
   ```bash
   pm2 restart nexuscos-app
   ```

### If endpoints return 502 Bad Gateway:
1. Check if the Node.js server is running:
   ```bash
   pm2 list
   netstat -tlnp | grep 3000
   ```

2. Check PM2 logs for errors:
   ```bash
   pm2 logs nexuscos-app --err --lines 50
   ```

### If Nginx returns errors:
1. Check Nginx configuration:
   ```bash
   nginx -t
   ```

2. Check Nginx error logs:
   ```bash
   tail -f /var/log/nginx/error.log
   ```

## Notes

- No Nginx configuration changes are required if the existing setup already proxies `/api/*` to port 3000
- The changes are backward compatible - all existing routes continue to work
- PM2 is already managing the process, no systemd changes needed
- The server runs on port 3000 as before

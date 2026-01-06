# Production Deployment - Quick Start

This is the **fastest way** to deploy the API routing fix to production.

## Prerequisites

- SSH access to production server
- Code deployed at `/opt/nexus-cos` (or similar)
- PM2 installed and running
- Nginx installed and configured

## One-Liner Deployment

```bash
cd /opt/nexus-cos && git pull && npm install && cd services/backend-api && npm install && cd ../.. && pm2 restart backend-api && pm2 logs backend-api --lines 20
```

## Step-by-Step (if one-liner fails)

### 1. Pull Latest Code
```bash
cd /opt/nexus-cos
git pull origin main
```

### 2. Install Dependencies
```bash
# Root dependencies (for routes/auth.js and routes/user.js)
npm install

# Backend API service dependencies
cd services/backend-api
npm install
cd ../..
```

### 3. Restart PM2 Service
```bash
pm2 restart backend-api
```

### 4. Verify Service is Running
```bash
# Check PM2 status
pm2 status

# Check logs
pm2 logs backend-api --lines 30
```

Expected log output:
```
🚀 Server running on http://0.0.0.0:3001
🔗 Health check: http://localhost:3001/health
🔗 API info: http://localhost:3001/api
```

## Quick Test

### Test Locally (on server)
```bash
curl http://localhost:3001/api | jq
```

Expected response:
```json
{
  "name": "Nexus COS Backend API",
  "version": "1.0.0",
  "status": "running",
  "timestamp": "2025-10-09T...",
  "endpoints": {
    "health": "/health",
    "systemStatus": "/api/system/status",
    ...
  }
}
```

### Test Through Nginx (public)
```bash
curl https://n3xuscos.online/api | jq
```

Should return the same JSON response.

## Run Full Test Suite

```bash
./test-api-routing-fix.sh https://n3xuscos.online
```

Expected output:
```
✓ All tests passed! (10/10)
```

## Nginx Configuration Check

### Verify Nginx has /api/ proxy
```bash
sudo cat /etc/nginx/sites-enabled/nexuscos | grep -A 10 "location /api/"
```

Should show:
```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3001/api/;
    # ... other proxy settings
}
```

### If missing, add it
See `NGINX_API_PROXY_CONFIG.md` for complete configuration.

After adding:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Troubleshooting

### Issue: PM2 service won't start
```bash
# Check for errors
pm2 logs backend-api --err

# Check if port 3001 is in use
lsof -i :3001

# Restart with force
pm2 delete backend-api
pm2 start ecosystem.config.js --only backend-api
```

### Issue: 404 errors on /api/*
```bash
# 1. Check if service is running
pm2 status

# 2. Test direct backend
curl http://localhost:3001/api

# 3. Check Nginx config
sudo nginx -t
sudo cat /etc/nginx/sites-enabled/nexuscos | grep -A 10 "location /api/"

# 4. Check Nginx logs
sudo tail -f /var/log/nginx/error.log
```

### Issue: 502 Bad Gateway
```bash
# Backend is not responding
pm2 restart backend-api
pm2 logs backend-api
```

## Success Checklist

- [x] Code pulled from git
- [x] Dependencies installed (root and service)
- [x] PM2 service restarted
- [x] Service shows "online" in `pm2 status`
- [x] Local test returns JSON: `curl http://localhost:3001/api`
- [x] Public test returns JSON: `curl https://n3xuscos.online/api`
- [x] Full test suite passes: `./test-api-routing-fix.sh https://n3xuscos.online`

## Next Steps

Once deployed:
1. Monitor logs: `pm2 logs backend-api -f`
2. Check health: `curl https://n3xuscos.online/health`
3. Test all endpoints: `./test-api-routing-fix.sh https://n3xuscos.online`
4. Update any documentation with new endpoints

## Documentation

- **Full deployment guide:** `API_ROUTING_FIX_DEPLOYMENT.md`
- **Nginx configuration:** `NGINX_API_PROXY_CONFIG.md`
- **Summary:** `BACKEND_API_SERVICE_FIX.md`

## Support

If issues persist:
1. Check `pm2 logs backend-api --err` for errors
2. Check `sudo tail -f /var/log/nginx/error.log` for Nginx errors
3. Verify dependencies: `cd services/backend-api && npm list`
4. Review the full deployment guide: `API_ROUTING_FIX_DEPLOYMENT.md`

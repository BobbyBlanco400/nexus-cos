# Nginx API Proxy Configuration

## Required Nginx Configuration for /api/* Routing

This document provides the **exact Nginx configuration** needed to proxy `/api/*` requests to the Node.js backend on port 3001.

## Configuration Block

Add this location block to your Nginx server configuration (typically in `/etc/nginx/sites-available/nexuscos` or similar):

```nginx
# API Proxy - Routes /api/* to Node.js backend on port 3001
location /api/ {
    proxy_pass http://127.0.0.1:3001/api/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}

# Health Check - Direct proxy to backend health endpoint
location /health {
    proxy_pass http://127.0.0.1:3001/health;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Important Notes

### 1. Trailing Slashes Matter

✅ **Correct:**
```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3001/api/;
}
```

This configuration:
- Request: `https://n3xuscos.online/api/auth` → Backend: `http://127.0.0.1:3001/api/auth`
- Request: `https://n3xuscos.online/api/system/status` → Backend: `http://127.0.0.1:3001/api/system/status`

❌ **Incorrect:**
```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3001/;
}
```

This would strip `/api` from the path:
- Request: `https://n3xuscos.online/api/auth` → Backend: `http://127.0.0.1:3001/auth` (404!)

### 2. Port Configuration

The backend service runs on **port 3001** by default (configured in PM2 ecosystem.config.js):
```javascript
env: {
  NODE_ENV: 'production',
  PORT: 3001
}
```

If you change the port in PM2, you must also update the Nginx configuration.

### 3. Alternative: Upstream Block

For better load balancing and failover, you can use an upstream block:

```nginx
# Define upstream
upstream nexus_backend_api {
    server 127.0.0.1:3001 max_fails=3 fail_timeout=30s;
    keepalive 32;
}

# Use in location block
location /api/ {
    proxy_pass http://nexus_backend_api/api/;
    proxy_http_version 1.1;
    proxy_set_header Connection "";
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
}
```

## Complete Example Configuration

Here's a complete Nginx server block example:

```nginx
server {
    listen 443 ssl http2;
    server_name n3xuscos.online www.n3xuscos.online;
    
    # SSL Configuration (adjust paths as needed)
    ssl_certificate /etc/ssl/ionos/fullchain.pem;
    ssl_certificate_key /etc/ssl/ionos/privkey.pem;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # API Proxy
    location /api/ {
        proxy_pass http://127.0.0.1:3001/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Health Check
    location /health {
        proxy_pass http://127.0.0.1:3001/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Frontend (static files or other proxy)
    location / {
        root /var/www/nexus-cos;
        try_files $uri $uri/ /index.html;
    }
}
```

## Deployment Steps

### 1. Update Nginx Configuration

Edit your Nginx configuration file:

```bash
sudo nano /etc/nginx/sites-available/nexuscos
```

Add or update the `/api/` location block as shown above.

### 2. Test Nginx Configuration

```bash
sudo nginx -t
```

Expected output:
```
nginx: configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 3. Reload Nginx

```bash
sudo systemctl reload nginx
# or
sudo nginx -s reload
```

### 4. Verify Configuration

Test that Nginx is proxying correctly:

```bash
# Test locally (should work if backend is running)
curl -I http://localhost/api

# Test externally
curl -I https://n3xuscos.online/api
```

Expected response:
```
HTTP/2 200
content-type: application/json; charset=utf-8
...
```

## Troubleshooting

### Issue: 404 Not Found for /api/*

**Cause:** Nginx location block not configured or misconfigured

**Solution:**
1. Check if location block exists: `sudo grep -A 10 "location /api/" /etc/nginx/sites-enabled/nexuscos`
2. Verify syntax: `sudo nginx -t`
3. Reload: `sudo systemctl reload nginx`

### Issue: 502 Bad Gateway

**Cause:** Backend service (port 3001) is not running or not responding

**Solution:**
1. Check if backend is running: `pm2 status`
2. Check if port is listening: `netstat -tlnp | grep 3001`
3. Check backend logs: `pm2 logs backend-api`
4. Restart backend: `pm2 restart backend-api`

### Issue: 504 Gateway Timeout

**Cause:** Backend is too slow to respond

**Solution:** Add timeout settings to Nginx:

```nginx
location /api/ {
    proxy_pass http://127.0.0.1:3001/api/;
    proxy_read_timeout 60s;
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    # ... other proxy settings
}
```

## Verification Checklist

✅ Nginx configuration file has `/api/` location block
✅ Trailing slashes match in location and proxy_pass
✅ `nginx -t` reports no errors
✅ Nginx service has been reloaded
✅ Backend service is running on port 3001
✅ `curl http://localhost:3001/api` returns JSON (backend test)
✅ `curl https://n3xuscos.online/api` returns JSON (full stack test)
✅ All API endpoints return 200 OK instead of 404

## Next Steps

After configuring Nginx, verify all endpoints work:

```bash
# Run the test script
./test-api-routing-fix.sh https://n3xuscos.online
```

All tests should pass with 200 OK responses.

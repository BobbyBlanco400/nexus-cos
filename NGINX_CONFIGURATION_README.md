# Nginx Configuration for Nexus COS

This document explains the nginx configuration created to fix the 502 Bad Gateway issue.

## Problem Summary

The 502 Bad Gateway error was occurring because the nginx container was running but had no routing rules to forward traffic to the backend services.

## Solution

Created `nginx.conf` file in the root directory with proper upstream and routing configuration.

## Files Created

### 1. `nginx.conf` (Basic Configuration)
- Minimal configuration as specified in the problem statement
- Routes traffic to the three main services:
  - `/api/` → puabo-api:4000
  - `/ai/` → puaboai-sdk:3002  
  - `/keys/` → pv-keys:3041

### 2. `nginx-enhanced.conf` (Production-Ready Configuration)
- Enhanced version with additional features:
  - Proper logging
  - Gzip compression
  - Security headers
  - Connection keep-alive
  - Timeout settings
  - Health check endpoint

### 3. `docker-compose.nginx.yml` (Standalone Nginx Service)
- Docker compose configuration for standalone nginx service
- Includes placeholder services for testing
- Uses the nginx.conf file from root directory

### 4. `test-nginx-routing.sh` (Testing Script)
- Script to test all routing endpoints
- Tests the health endpoints as specified in the problem statement

## Deployment Instructions

### Option 1: Using Existing Frontend Service
If your nginx is embedded in the frontend service, update the docker-compose to mount the nginx.conf:

```yaml
frontend:
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

### Option 2: Using Standalone Nginx Service
If you need a standalone nginx service, use the provided docker-compose.nginx.yml:

```bash
# Start the standalone nginx service
docker-compose -f docker-compose.nginx.yml up -d nginx

# Restart nginx with new configuration
docker-compose -f docker-compose.nginx.yml restart nginx
```

## Testing

Run the test script to verify routing:

```bash
./test-nginx-routing.sh
```

Expected responses:
- **200 OK**: Services are running and responding correctly
- **502 Bad Gateway**: Services are defined but not responding (services down)
- **Connection Refused**: Nginx is not running or configuration not loaded

## Service Verification Commands

```bash
# Test API endpoint
curl -i http://localhost/api/health

# Test AI endpoint  
curl -i http://localhost/ai/health

# Test Keys endpoint
curl -i http://localhost/keys/health

# Test nginx health (if using enhanced config)
curl -i http://localhost/nginx/health
```

## Configuration Notes

### Service Names vs. Actual Services
The problem statement specified these services:
- puabo-api:4000
- puaboai-sdk:3002
- pv-keys:3041

However, the repository contains different service definitions. You may need to:

1. **Update service names/ports** in docker-compose files to match nginx.conf
2. **Update nginx.conf** to match existing services
3. **Create the missing services** mentioned in the problem statement

### Current Repository Services
Based on the analysis, the repository currently has:
- nexus-backend-node:3000
- nexus-backend-python:3001
- nexus-v-suite:3010
- nexus-creator-hub:3020
- nexus-puaboverse:3030

### Alternative Configuration
If you want to use existing services, update nginx.conf upstreams to:

```nginx
upstream nexus_api {
    server nexus-backend-node:3000;
}

upstream nexus_python {
    server nexus-backend-python:3001;
}

# And update location blocks accordingly
location /api/ {
    proxy_pass http://nexus_api/;
    # ... headers
}
```

## Troubleshooting

### 502 Bad Gateway
- Check if backend services are running: `docker ps`
- Verify service names match in docker-compose and nginx.conf
- Check nginx error logs: `docker logs <nginx-container>`

### Configuration Errors
- Test nginx config: `nginx -t -c /path/to/nginx.conf`
- Check nginx syntax in container: `docker exec <nginx-container> nginx -t`

### Service Not Found
- Ensure services are on the same Docker network
- Verify service names in docker-compose files
- Check if services are exposing the correct ports

## Next Steps

1. **Deploy the configuration**: Choose option 1 or 2 above
2. **Start/restart nginx**: `docker-compose restart nginx`
3. **Test endpoints**: Run the test script
4. **Adjust service definitions**: Match nginx.conf with actual services if needed
5. **Add CORS headers**: If frontend needs to call these APIs (mentioned in problem statement)

## Production Considerations

For production deployment:
- Use `nginx-enhanced.conf` instead of basic `nginx.conf`
- Set up proper SSL/TLS certificates
- Configure log rotation
- Set up monitoring and health checks
- Consider load balancing multiple instances of each service
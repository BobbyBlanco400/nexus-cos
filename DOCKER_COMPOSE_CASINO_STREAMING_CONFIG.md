# Docker Compose Configuration Updates for Casino V5 and Streaming

## Add to docker-compose.yml (or docker-compose.unified.yml)

### For Nginx Service

Add these volumes to the nginx service to serve static casino and streaming frontends:

```yaml
services:
  nginx:
    image: nginx:alpine
    container_name: nexus-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf.docker:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./ssl:/etc/ssl/ionos:ro
      - nginx_logs:/var/log/nginx
      # Casino V5 Frontend
      - ./modules/casino-nexus/frontend/public:/usr/share/nginx/html/casino:ro
      # Streaming Frontend
      - ./modules/puabo-ott-tv-streaming/frontend/public:/usr/share/nginx/html/streaming:ro
    depends_on:
      - api
    restart: unless-stopped
    networks:
      - cos-net
```

### Alternative: Direct File Serving (nginx.conf)

If you prefer nginx to serve files directly instead of proxying, update nginx.conf:

```nginx
# Casino V5 - Direct file serving
location /casino {
    alias /usr/share/nginx/html/casino;
    index index.html;
    try_files $uri $uri/ /casino/index.html;
    
    # Cache static assets
    location ~* \.(png|jpg|jpeg|gif|ico|svg|webp)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    location ~* \.(js|css)$ {
        expires 7d;
        add_header Cache-Control "public";
    }
}

# Casino V5 Assets - Optimized caching
location /casino/assets {
    alias /usr/share/nginx/html/casino/assets;
    expires 30d;
    add_header Cache-Control "public, immutable";
    
    # CORS headers for assets
    add_header Access-Control-Allow-Origin *;
}

# Streaming - Direct file serving
location /streaming {
    alias /usr/share/nginx/html/streaming;
    index index.html;
    try_files $uri $uri/ /streaming/index.html;
    
    # Cache static assets
    location ~* \.(png|jpg|jpeg|gif|ico|svg|webp)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

## Full Docker Compose Example

```yaml
version: "3.9"

networks:
  cos-net:
    driver: bridge

services:
  # Nginx Gateway
  nginx:
    image: nginx:alpine
    container_name: nexus-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf.docker:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./ssl:/etc/ssl/ionos:ro
      - nginx_logs:/var/log/nginx
      # Module Frontends
      - ./modules/casino-nexus/frontend/public:/usr/share/nginx/html/casino:ro
      - ./modules/puabo-ott-tv-streaming/frontend/public:/usr/share/nginx/html/streaming:ro
      - ./frontend/public:/usr/share/nginx/html:ro
    depends_on:
      - api
    restart: unless-stopped
    networks:
      - cos-net
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Main API Gateway
  api:
    build: .
    container_name: puabo-api
    environment:
      NODE_ENV: production
      PORT: 3000
    ports:
      - "3000:3000"
    volumes:
      # Mount module frontends so API can serve them if needed
      - ./modules/casino-nexus/frontend/public:/app/public/casino:ro
      - ./modules/puabo-ott-tv-streaming/frontend/public:/app/public/streaming:ro
    restart: unless-stopped
    networks:
      - cos-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  nginx_logs:
```

## Environment Variables

Add these to your `.env` file:

```bash
# Casino V5 Configuration
CASINO_FRONTEND_PATH=/var/www/nexus-cos/modules/casino-nexus/frontend/public
CASINO_ASSETS_PATH=/var/www/nexus-cos/modules/casino-nexus/frontend/public/assets

# Streaming Configuration
STREAMING_FRONTEND_PATH=/var/www/nexus-cos/modules/puabo-ott-tv-streaming/frontend/public

# Enable asset caching
ENABLE_ASSET_CACHING=true
ASSET_CACHE_DURATION=2592000  # 30 days in seconds
```

## Deployment Commands

After updating docker-compose.yml:

```bash
# Stop services
docker-compose down

# Pull latest images (if needed)
docker-compose pull

# Rebuild services
docker-compose build --no-cache

# Start services
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs
docker-compose logs -f nginx
docker-compose logs -f api
```

## Verification

Test the deployment:

```bash
# Test Casino V5
curl -I http://localhost/casino
curl -I http://localhost/casino/assets/textures/manifest.json

# Test Streaming
curl -I http://localhost/streaming

# Check nginx container
docker exec nexus-nginx ls -la /usr/share/nginx/html/casino
docker exec nexus-nginx ls -la /usr/share/nginx/html/streaming

# Check API container
docker exec puabo-api ls -la /app/public/casino
docker exec puabo-api ls -la /app/public/streaming
```

## Troubleshooting

### Casino assets not loading

1. Check volume mount:
   ```bash
   docker inspect nexus-nginx | grep -A 10 Mounts
   ```

2. Check file permissions:
   ```bash
   ls -la modules/casino-nexus/frontend/public
   ```

3. Rebuild container:
   ```bash
   docker-compose up -d --force-recreate nginx
   ```

### Streaming returning 404

1. Verify index.html exists:
   ```bash
   ls -la modules/puabo-ott-tv-streaming/frontend/public/index.html
   ```

2. Check nginx logs:
   ```bash
   docker logs nexus-nginx
   ```

3. Test inside container:
   ```bash
   docker exec nexus-nginx cat /usr/share/nginx/html/streaming/index.html
   ```

## Production Considerations

1. **Use read-only mounts** (`:ro`) for security
2. **Enable gzip compression** in nginx for better performance
3. **Set up CDN** for static assets if scaling globally
4. **Monitor disk usage** for asset storage
5. **Implement backup strategy** for frontend assets
6. **Use nginx caching** to reduce backend load
7. **Enable HTTP/2** for better performance
8. **Set up health checks** for all services

## Security Headers

Add these to nginx configuration:

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self' https:; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' https:; style-src 'self' 'unsafe-inline' https:;" always;
```

## Performance Optimization

Enable gzip compression:

```nginx
gzip on;
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript application/xml+rss application/rss+xml font/truetype font/opentype application/vnd.ms-fontobject image/svg+xml;
```

## Monitoring

Set up monitoring for:

- Nginx access logs
- Error rates
- Response times
- Disk usage
- Container health
- Service uptime

```bash
# Monitor nginx access in real-time
docker logs -f nexus-nginx

# Monitor API logs
docker logs -f puabo-api

# Check container stats
docker stats nexus-nginx puabo-api
```

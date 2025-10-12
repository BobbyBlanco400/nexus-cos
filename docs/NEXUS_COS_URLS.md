# Nexus COS URL Configuration Documentation

## Production Environment

### Main Application URLs
- Primary Domain: `https://nexuscos.online`
- Monitoring Domain: `https://monitoring.nexuscos.online`

### Internal Service URLs
- Backend API: `http://localhost:3001`
- Frontend Dev Server: `http://localhost:3000`
- Mock AI Service: `http://localhost:3010`
- Key Management Service: `http://localhost:3014`
- PostgreSQL Database: `localhost:5432`

### Health Check Endpoints
- Main Health: `https://nexuscos.online/health`
- API Health: `https://nexuscos.online/api/health`
- AI Service Health: `https://nexuscos.online/ai/health`
- Key Service Health: `https://nexuscos.online/keys/health`

## Beta Environment

### Main Beta URLs
- Beta Domain: `https://beta.nexuscos.online`
- Beta Monitoring: `https://monitoring.beta.nexuscos.online`

### Beta Health Check Endpoints
- Main Health: `https://beta.nexuscos.online/health`
- API Status: `https://beta.nexuscos.online/api/status`
- Metrics: `https://beta.nexuscos.online/metrics`

## SSL Configurations

### Production SSL
```nginx
ssl_certificate /etc/ssl/ionos/nexuscos.online/fullchain.pem;
ssl_certificate_key /etc/ssl/ionos/nexuscos.online/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
```

### Beta SSL
```nginx
ssl_certificate /etc/ssl/ionos/beta.nexuscos.online/fullchain.pem;
ssl_certificate_key /etc/ssl/ionos/beta.nexuscos.online/privkey.pem;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
```

## Security Headers (Both Environments)
```nginx
add_header Strict-Transport-Security "max-age=31536000" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Content-Security-Policy "default-src 'self';" always;
```

## CDN Configuration

### Production CDN
- Provider: CloudFlare
- SSL Mode: Full (Strict)
- Edge Locations: Worldwide
- Cache Rules:
  - Static Assets: Aggressive caching
  - API Endpoints: Dynamic caching
  - Media Content: Optimized caching

### Beta CDN
- Provider: CloudFlare
- SSL Mode: Full (Strict)
- Edge Locations: Worldwide
- Cache Rules:
  - Static Assets: Aggressive caching
  - API Endpoints: Dynamic caching
  - Media Content: Optimized caching

## Known Issues and Resolutions

### Issue 1: Nginx Routing Tests Failing
**Problem**: Initial Nginx routing tests were failing with connection errors.
**Root Cause**: 
- Port conflicts between mock services and actual services
- Incorrect Nginx configuration
- Missing container network connections

**Resolution**:
1. Stopped conflicting `puabo-api` service running on port 4000
2. Updated Nginx configuration with correct proxy passes
3. Ensured all containers were connected to `nexus-cos_nexus-network`
4. Verified correct port mappings:
   - nginx: 8080
   - puabo-api: 3001
   - puaboai-sdk: 3010
   - pv-keys: 3014

### Issue 2: SSL Certificate Validation
**Problem**: SSL certificate validation errors in beta environment
**Resolution**:
1. Verified correct certificate paths
2. Set proper file permissions:
   - fullchain.pem: 644
   - privkey.pem: 600
3. Configured Nginx with correct SSL parameters
4. Implemented proper security headers

### Issue 3: Health Check Failures
**Problem**: Health check endpoints returning errors
**Resolution**:
1. Implemented proper routing in Nginx configuration
2. Added health check endpoints to all services
3. Configured proper timeouts and proxy settings
4. Implemented monitoring for all health endpoints

## Monitoring Configuration

### Log File Locations
- Production:
  ```
  /var/log/nginx/nexuscos.online_access.log
  /var/log/nginx/nexuscos.online_error.log
  /var/log/nexuscos/app.log
  ```
- Beta:
  ```
  /var/log/nginx/beta.nexuscos.online_access.log
  /var/log/nginx/beta.nexuscos.online_error.log
  /var/log/nexuscos/beta_app.log
  ```

### Alert Thresholds
- Response Time: >200ms
- Error Rate: >0.1%
- SSL Certificate Expiry: <30 days

## Health Check Commands
```bash
# Production Health Checks
curl -k https://nexuscos.online/health
curl -k https://nexuscos.online/api/health
curl -k https://nexuscos.online/ai/health
curl -k https://nexuscos.online/keys/health

# Beta Health Checks
curl -k https://beta.nexuscos.online/health
curl -k https://beta.nexuscos.online/api/status
curl -k https://beta.nexuscos.online/metrics
```

## Verification Commands
```bash
# SSL Certificate Verification
openssl s_client -connect nexuscos.online:443 -servername nexuscos.online
openssl s_client -connect beta.nexuscos.online:443 -servername beta.nexuscos.online

# Nginx Configuration Test
nginx -t

# Container Network Verification
docker network inspect nexus-cos_nexus-network
```
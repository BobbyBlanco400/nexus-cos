# Nexus COS URL and SSL Certificate Inventory

## Production Environment

### Main Domain URLs
- Primary: `https://nexuscos.online`
- Monitoring: `https://monitoring.nexuscos.online`

### SSL Certificates (Production)
1. Main Domain Certificate:
   - Location: `/etc/ssl/ionos/fullchain.pem`
   - Private Key: `/etc/ssl/ionos/privkey.pem`
   - Permissions: 644 (fullchain.pem), 600 (privkey.pem)

2. Monitoring Subdomain Certificate:
   - Location: `/etc/nginx/ssl/nexuscos.online/fullchain.pem`
   - Private Key: `/etc/nginx/ssl/nexuscos.online/privkey.pem`
   - Chain File: `/etc/nginx/ssl/nexuscos.online/chain.pem`

### Internal Service URLs (Production)
- Backend API: `http://localhost:3001/health`
- AI Service: `http://localhost:3010/health`
- Key Service: `http://localhost:3014/health`
- Grafana: `http://127.0.0.1:3000`
- Prometheus: `http://127.0.0.1:9090`

## Beta Environment

### Beta Domain URLs
- Primary Beta: `https://beta.nexuscos.online`

### SSL Certificates (Beta)
1. Beta Domain Certificate:
   - Location: `/etc/ssl/ionos/beta.nexuscos.online/fullchain.pem`
   - Private Key: `/etc/ssl/ionos/beta.nexuscos.online/privkey.pem`
   - Permissions: 644 (fullchain.pem), 600 (privkey.pem)

## SSL Configuration Details

### Security Settings
```nginx
# SSL Protocols and Ciphers
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# Security Headers
add_header Strict-Transport-Security "max-age=31536000" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Content-Security-Policy "default-src 'self';" always;
```

### CDN Configuration
- Provider: CloudFlare
- SSL Mode: Full (Strict)
- Edge Locations: Worldwide
- Cache Rules:
  - Static Assets: Aggressive caching
  - API Endpoints: Dynamic caching
  - Media Content: Optimized caching

## Log File Locations
- Production Access Log: `/var/log/nginx/nexuscos.online_access.log`
- Production Error Log: `/var/log/nginx/nexuscos.online_error.log`
- Beta Access Log: `/var/log/nginx/beta.nexuscos.online_access.log`
- Beta Error Log: `/var/log/nginx/beta.nexuscos.online_error.log`

## SSL Validation Commands
```bash
# Test Nginx configuration
nginx -t

# Verify SSL certificate
openssl x509 -in /etc/ssl/ionos/fullchain.pem -text -noout

# Check SSL connection
openssl s_client -connect nexuscos.online:443 -tls1_2
openssl s_client -connect beta.nexuscos.online:443 -tls1_2
```

## Required SSL Files
1. Production:
   - `/etc/ssl/ionos/fullchain.pem`
   - `/etc/ssl/ionos/privkey.pem`
   - `/etc/nginx/ssl/nexuscos.online/chain.pem`

2. Beta:
   - `/etc/ssl/ionos/beta.nexuscos.online/fullchain.pem`
   - `/etc/ssl/ionos/beta.nexuscos.online/privkey.pem`

## File Permissions
- Certificate Files (*.pem, *.crt): 644
- Private Keys (*.key, privkey.pem): 600
- Directory Permissions: 755
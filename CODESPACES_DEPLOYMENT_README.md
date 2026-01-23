# CODESPACES DEPLOYMENT HANDOFF - BETA DOMAIN & API HEALTH
> **DATE:** 2026-01-16  
> **STATUS:** URGENT ACTION REQUIRED  
> **SCOPE:** BETA LAUNCH (72-HOUR WINDOW)

## 1. Beta Domain DNS & Infrastructure
**Objective:** Bring `beta.n3xuscos.online` online with SSL and correct routing.

### DNS Records (Action: Hostinger DNS Panel)
- **Type:** A Record
- **Host:** `beta` (or `beta.n3xuscos.online`)
- **Value:** [Your Hostinger VPS Public IP]
- **TTL:** 300s (or default)

### SSL Configuration (Action: VPS Terminal)
Use Certbot to generate the SSL certificate for the beta subdomain:
```bash
sudo certbot certonly --webroot -w /var/www/nexus-cos-beta -d beta.n3xuscos.online
```
*Ensure the webroot directory exists:*
```bash
sudo mkdir -p /var/www/nexus-cos-beta
sudo chown -R www-data:www-data /var/www/nexus-cos-beta
```

## 2. Nginx Configuration & 502 Fixes
**Current Issue:** Nginx is configured to proxy `/api` and `/health` to `localhost:3000`, but `docker-compose` maps services to ports `3010`, `3011`, and `3012`. This causes 502 Bad Gateway errors.

**Required Change:** Update the upstream ports in your Nginx vhost to match the Docker mapping (Federation Gateway is on `3012`).

### Validated Nginx Config (`/etc/nginx/sites-available/beta.n3xuscos.online`)
*Use the template below, noting the port change to **3012**.*

```nginx
server {
    listen 80;
    server_name beta.n3xuscos.online;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name beta.n3xuscos.online;

    # SSL Certs (Adjust paths if using Certbot default /etc/letsencrypt/live/...)
    ssl_certificate /etc/letsencrypt/live/beta.n3xuscos.online/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/beta.n3xuscos.online/privkey.pem;

    root /var/www/nexus-cos-beta;
    index index.html;

    # Frontend
    location / {
        try_files $uri $uri/ /index.html;
    }

    # API GATEWAY (CRITICAL FIX: Port 3012)
    location /api/ {
        # CHANGED FROM 3000 TO 3012 (Federation Gateway)
        proxy_pass http://localhost:3012/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-N3XUS-Handshake "55-45-17"; # Enforce Handshake
    }

    # HEALTH CHECK (CRITICAL FIX: Port 3012)
    location /health {
        # CHANGED FROM 3000 TO 3012
        proxy_pass http://localhost:3012/health;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
```

## 3. Deployment Steps
1.  **Deploy Code**:
    ```bash
    # Pull latest changes
    git pull origin main
    
    # Build and Start Services
    docker-compose -f docker-compose.final.yml up -d --build
    ```

2.  **Verify Services**:
    Ensure the gateway is listening on 3012:
    ```bash
    docker ps | grep federation-gateway
    # Output should show: 0.0.0.0:3012->3000/tcp
    ```

3.  **Apply Nginx Config**:
    ```bash
    sudo ln -s /etc/nginx/sites-available/beta.n3xuscos.online /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl reload nginx
    ```

4.  **Validate Endpoints**:
    ```bash
    # Health Check (Should return 200 OK)
    curl -I https://beta.n3xuscos.online/health
    
    # API Check (Requires Handshake)
    curl -H "X-N3XUS-Handshake: 55-45-17" https://beta.n3xuscos.online/api/status
    ```

## 4. Troubleshooting
-   **502 Bad Gateway**: Check that `federation-gateway` container is running and mapped to port `3012`.
-   **403 Forbidden / 401 Unauthorized**: Ensure `X-N3XUS-Handshake: 55-45-17` header is sent with requests.
-   **SSL Errors**: Verify Certbot paths in Nginx config match the actual generated certificate paths.

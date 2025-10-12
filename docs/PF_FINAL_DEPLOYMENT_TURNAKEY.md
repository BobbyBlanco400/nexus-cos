# Nexus COS — Turnkey PF Final Deployment (VPS Docker/Nginx, No Orchestration)

This appendix gives a single, reproducible path to deploy PF on any VPS using Docker + Nginx (containerized), without external orchestration.

## Usage

```bash
sudo bash scripts/pf-final-deploy.sh -r <repo_url> -d nexuscos.online
# Example:
sudo bash scripts/pf-final-deploy.sh -r https://github.com/your-org/nexus-cos.git -d nexuscos.online
```

## What It Does

- Installs Docker, Docker Compose, opens 80/443 on UFW, enables Docker service.
- Clones/updates repo into `/opt/nexus-cos`, ensures `.env` (from `.env.pf` if available).
- Creates `nexus-network`, starts PF services with `docker compose -f docker-compose.pf.yml up -d`.
- Launches Nginx container attached to `nexus-network`, mounts `nginx.conf`, `conf.d`, and SSL paths.
- Validates Nginx config and reloads; verifies upstream DNS/health from inside Nginx.
- Runs external validations against `https://nexuscos.online` routes and health endpoints.

## Manual Steps (for reference)

### VPS Prep

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && sudo usermod -aG docker $USER
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
sudo ufw allow 22,80,443/tcp && sudo ufw --force enable
```

### Repo + env

```bash
git clone <repo_url> /opt/nexus-cos && cd /opt/nexus-cos
cp .env.pf .env && nano .env
```

### PF stack

```bash
docker network create nexus-network || true
docker compose -f docker-compose.pf.yml up -d
```

### Nginx container

```bash
docker run -d --name nexus-nginx --restart always --network nexus-network -p 80:80 -p 443:443 \
  -v /opt/nexus-cos/nginx/nginx.conf:/etc/nginx/nginx.conf \
  -v /opt/nexus-cos/nginx/conf.d:/etc/nginx/conf.d \
  -v /opt/nexus-cos/ssl:/etc/nginx/ssl \
  -v /opt/nexus-cos/certbot:/var/www/certbot nginx:alpine
docker exec nexus-nginx nginx -t && docker exec nexus-nginx nginx -s reload
```

### SSL/TLS

- Place certs at `/opt/nexus-cos/ssl/nexus-cos.crt` and `/opt/nexus-cos/ssl/nexus-cos.key` (paths match `nginx/conf.d/nexus-proxy.conf`).
- Optional Let’s Encrypt (webroot):

```bash
certbot certonly --webroot -w /opt/nexus-cos/certbot -d nexuscos.online -d www.nexuscos.online
# then copy cert/key to /opt/nexus-cos/ssl/
```

### Upstream Reachability (inside Nginx)

```bash
docker exec nexus-nginx getent hosts puabo-api
docker exec nexus-nginx getent hosts nexus-cos-puaboai-sdk
docker exec nexus-nginx getent hosts nexus-cos-pv-keys
docker exec nexus-nginx curl -sf http://puabo-api:4000/health
docker exec nexus-nginx curl -sf http://nexus-cos-puaboai-sdk:3002/health
docker exec nexus-nginx curl -sf http://nexus-cos-pv-keys:3041/health
```

### External Validation

```bash
curl -I https://nexuscos.online/
curl -I https://nexuscos.online/admin
curl -I https://nexuscos.online/api
curl -I https://nexuscos.online/v-suite/prompter
curl -I -H "Upgrade: websocket" -H "Connection: Upgrade" https://nexuscos.online/socket.io/?EIO=4&transport=websocket
curl -s https://nexuscos.online/health
curl -s https://nexuscos.online/health/gateway
curl -s https://nexuscos.online/health/puaboai-sdk
curl -s https://nexuscos.online/health/pv-keys
```

### Success Criteria

- 200/301 for `/`, `/admin`
- 200 OK for `/api` and V‑Suite routes
- Health endpoints return JSON with expected content
- WebSocket handshake returns 101 Switching Protocols
- SSL valid chain, TLSv1.2/1.3, modern ciphers

### Troubleshooting

- 502 on routes:
  - Ensure PF services use expected names `puabo-api`, `nexus-cos-puaboai-sdk`, `nexus-cos-pv-keys` and are on `nexus-network`.
  - Confirm Nginx container resolves service names and reloads cleanly.
- SSL issues:
  - Verify cert/key file presence and paths; renew or replace if expired.
- Firewall/DNS:
  - `sudo ufw status`; A/AAAA records must point to this VPS.

### Fast Recovery

```bash
docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d
docker restart nexus-nginx && docker exec nexus-nginx nginx -t && docker exec nexus-nginx nginx -s reload
docker exec nexus-nginx curl -sf http://puabo-api:4000/health
curl -I https://nexuscos.online/api
curl -I https://nexuscos.online/v-suite/prompter
```

---

Run the single deploy command on your VPS to execute the final PF launch. You can tailor domain or repo parameters as needed. This script and manual sequence guarantee a rapid, reproducible, and validated PF launch for Nexus COS on any VPS.
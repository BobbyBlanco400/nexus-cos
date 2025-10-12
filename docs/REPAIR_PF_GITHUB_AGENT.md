# Repair PF — GitHub Code Agent Plan (Fix, Implement, Test, Deploy)

This document packages the final PF deployment flow into a reproducible plan for a GitHub automation agent to repair, implement, test, and deploy the stack to a VPS using Docker + Nginx (containerized), without external orchestration.

## Goal

- Ensure PF services and Nginx run on a VPS and serve `https://nexuscos.online` with the upstreams:
  - `pf_gateway -> puabo-api:4000`
  - `pf_puaboai_sdk -> nexus-cos-puaboai-sdk:3002`
  - `pf_pv_keys -> nexus-cos-pv-keys:3041`
  defined in `nginx/conf.d/nexus-proxy.conf`.

## Inputs & Secrets

- `domain` (input): Target domain (default: `nexuscos.online`).
- `repo_url` (input): Git repository URL (default: detected from remote origin).
- `vps_host` (input): VPS IP/hostname.
- `vps_user` (input): VPS SSH user (e.g., `root`, `ubuntu`, `deploy`).
- `VPS_SSH_KEY` (secret): Private key (PEM) for SSH auth. Optional if password provided.
- `VPS_PASSWORD` (secret): SSH password (used if key not set). Optional.

## High-Level Steps

1. Prepare VPS
   - Update and upgrade apt packages.
   - Install Docker and Docker Compose.
   - Enable UFW and allow `22/tcp`, `80/tcp`, `443/tcp`.
   - Ensure Docker service is enabled and started.

2. Repository & Environment
   - Clone or pull repo into `/opt/nexus-cos`.
   - Ensure `.env` exists (copy `.env.pf` if present).

3. PF Services
   - Create Docker network `nexus-network`.
   - Launch PF services with `docker compose -f docker-compose.pf.yml up -d`.

4. Nginx Container
   - Run Nginx attached to `nexus-network`.
   - Mount `nginx/nginx.conf`, `nginx/conf.d`, and SSL under `/etc/nginx/ssl`.
   - Validate config (`nginx -t`) & reload.

5. Validations
   - Internal (from Nginx container): resolve upstream DNS and hit health endpoints.
   - External: verify `https://nexuscos.online` routes and health endpoints respond.

6. Success Criteria
   - `200/301` for `/`, `/admin`.
   - `200 OK` for `/api` and V‑Suite routes.
   - Health endpoints return JSON.
   - WebSocket handshake returns `101 Switching Protocols`.
   - Valid SSL chain; TLSv1.2/1.3.

7. Troubleshooting
   - 502 errors: check container health, network attachment, upstream DNS resolution.
   - SSL: ensure cert/key paths match `nginx/conf.d/nexus-proxy.conf`.
   - Firewall: confirm UFW ports and any cloud firewall rules.

## Single Command (On VPS)

Run as a user with `sudo`:

```bash
curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/scripts/pf-final-deploy.sh -o /tmp/pf-final-deploy.sh && sudo bash /tmp/pf-final-deploy.sh -r git@github.com:BobbyBlanco400/nexus-cos.git -d nexuscos.online
```

## GitHub Workflow

Use `.github/workflows/pf-repair-deploy.yml` to execute the deployment over SSH (key or password). Configure repository secrets:

- `VPS_SSH_KEY`: Paste your private key (PEM) contents.
- `VPS_PASSWORD`: Optional password for SSH.

Then trigger the workflow via “Run workflow” with inputs for `domain`, `repo_url`, `vps_host`, and `vps_user`.

## Post-Deploy Checks

```bash
# Container status
docker ps

# Nginx config
docker exec nexus-nginx nginx -t
docker exec nexus-nginx nginx -s reload

# External validations
curl -I https://nexuscos.online/
curl -I https://nexuscos.online/admin
curl -I https://nexuscos.online/api
curl -s https://nexuscos.online/health
curl -s https://nexuscos.online/health/gateway
curl -s https://nexuscos.online/health/puaboai-sdk
curl -s https://nexuscos.online/health/pv-keys
```

## Fast Recovery

```bash
docker compose -f /opt/nexus-cos/docker-compose.pf.yml down && \
docker compose -f /opt/nexus-cos/docker-compose.pf.yml up -d

docker restart nexus-nginx && \
docker exec nexus-nginx nginx -t && \
docker exec nexus-nginx nginx -s reload
```

## Notes

- The plan assumes `nginx/conf.d/nexus-proxy.conf` upstreams match PF service names on the `nexus-network`.
- If deploying under non‑root, ensure the user belongs to `sudo` and `docker` groups.
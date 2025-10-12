# Nexus COS Platform – Full Blueprint (Architecture, Automation, and Ops)

## Executive Summary
- Strategy: Ubuntu + Docker (Compose) + Nginx reverse proxy, fronted by TLS via Certbot, automated by Ansible (idempotent, re‑runnable).
- Domains: `nexuscos.online` (prod) and `beta.nexuscos.online` (beta).
- Packaging: PF build artifacts zipped (`nexus-pf-deploy.zip`) with standardized Nginx configs and validation scripts.
- Baseline: Frontends use `VITE_API_URL=/api`; Nginx routes `/api` and V‑Suite upstreams to PF services on a Docker network.

## Architecture Overview
- Entry: Nginx as edge gateway with HTTP→HTTPS, security headers, gzip, and SPA fallback for frontends.
- Services: PF modules deployed via Docker Compose; all containers attached to `nexus-network` for name‑based upstream routing.
- Frontends: Static bundles built with Vite; served from Nginx root paths for `nexuscos.online` and `beta.nexuscos.online`.
- API: `/api` proxied to the PF backend/gateway service; upstreams defined in `nginx/conf.d/nexus-proxy.conf`.
- Health: `/health` and module health endpoints (`PF_INDEX.md`) exposed via Nginx proxy for external validation.

## Domains & Routing
- `nexuscos.online`: Primary site; SSL via Let’s Encrypt; server blocks installed in `/etc/nginx/conf.d/nexuscos.online.conf`.
- `beta.nexuscos.online`: Beta site; SSL via Let’s Encrypt; server blocks in `/etc/nginx/conf.d/beta.nexuscos.online.conf`.
- PF Proxy: `nginx/conf.d/nexus-proxy.conf` defines upstreams (gateway, SDK, keys, V‑Suite) with standardized timeouts and WebSocket support.

## Build & Packaging Flow
1. Ensure `.env` files:
   - `frontend/.env`, `admin/.env`, `creator-hub/.env` → `VITE_API_URL=/api`.
2. Build frontends:
   - `pnpm build` (or `npm run build`) outputs to `frontend/dist/` and respective app dist directories.
3. Stage artifacts:
   - Create `artifacts/pf-deploy/` with:
     - Nginx configs: `nginx/nginx.conf`, `nginx/conf.d/nexus-proxy.conf`, domain site files.
     - Scripts: `scripts/pf-final-deploy.sh`, validation helpers.
     - Built frontend bundles.
4. Package:
   - Zip to `artifacts/pf-deploy/nexus-pf-deploy.zip` for transport to VPS.

## Automation – Ansible (Best Path)
- Idempotent, SSH‑driven orchestration using:
  - `artifacts/pf-ansible/inventory.ini`: target hosts and SSH keys.
  - `artifacts/pf-ansible/group_vars/all.yml`: domains, TLS choices, artifact paths.
  - `artifacts/pf-ansible/playbook.yml`: full deploy: Docker, Nginx, TLS, PF stack, validations.
- Decisions:
  - Use Certbot (`use_certbot: true`) for automatic TLS issuance on Ubuntu.
  - Prefer non‑root deploy user (e.g., `ubuntu`) with SSH keys in `inventory.ini`.
  - Keep playbook re‑runnable for iterative changes; leverage idempotent modules.

### Playbook Responsibilities
- System prep: apt update, install Docker CE + Compose plugin, Nginx, UFW.
- Firewall: allow `22`, `80`, `443`; enable UFW.
- Files: create `/opt/nexus-cos`, `/etc/nginx/conf.d`, `/etc/nginx/ssl/{certs,private}`.
- Artifacts: upload `nexus-pf-deploy.zip` and unarchive to `/opt/nexus-cos`.
- Nginx: install `nginx.conf`, PF proxy, domain sites; test and reload.
- TLS: install Certbot (Ubuntu) and issue certs for both domains; enable redirect.
- PF deploy: run `pf-final-deploy.sh -d {{ domain }}` to start services.
- Validation: curl probes for `/`, `/admin`, `/api`, `/health`.

## Development Workflow (Future Opportunities)
- Add a new module/service:
  - Define upstream or routes in `nexus-proxy.conf` with a clear path and timeouts.
  - Add service container to `docker-compose.pf.yml` and attach to `nexus-network`.
  - Expose health endpoint; add to `PF_INDEX.md`.
- Update frontends:
  - Keep `VITE_API_URL=/api`; build with Vite; package into artifacts.
- Extend Nginx:
  - Create a new `deployment/nginx/<subdomain>.conf`; include SPA fallback and SSL.
- Release packaging:
  - Rebuild, refresh `artifacts/pf-deploy/`, regenerate ZIP; publish via Ansible.
- CI/CD (optional):
  - Use GitHub Actions to run Ansible over SSH for automated rollout.

## Ops Runbooks
- Deploy (control machine):
  - `cd artifacts/pf-ansible && ansible-playbook -i inventory.ini playbook.yml`.
- Rollback:
  - `docker compose -f /opt/nexus-cos/docker-compose.pf.yml down && up -d`.
  - Reinstall Nginx configs and reload if needed.
- Validate:
  - External `curl -I https://nexuscos.online/` and `/admin`, `/api`.
  - Container health via `docker ps`, logs via `docker compose logs -f`.
- Troubleshooting:
  - Nginx: `nginx -t`, `/var/log/nginx/error.log`.
  - TLS: ensure DNS A/AAAA records point to VPS; rerun Certbot.
  - Firewall: `sudo ufw status`.

## Security Posture
- TLS: Let’s Encrypt with auto‑renew; redirect HTTP→HTTPS.
- Headers: HSTS, X‑Content‑Type‑Options, X‑Frame‑Options, Referrer‑Policy in Nginx.
- Secrets: SSH keys for deploy; avoid embedding secrets in repo.
- Access: Non‑root deploy user; sudo and docker group membership where applicable.

## Monitoring & Health
- Basic: curl probes and `pf-cos-universal-health-check.sh`.
- Enhanced: add Prometheus exporters and Grafana dashboards (future work).

## Best Path Decision
- Choose Ansible + Certbot on Ubuntu as the primary automation path:
  - Rapid bootstrap, strong repeatability, automated TLS, safe re‑runs.
  - Domain‑specific Nginx configs already prepared; PF artifact packaging standardized.
  - Scales to multi‑host orchestration later (inventory groups).

## Checklist
- [ ] DNS A records for `nexuscos.online` and `beta.nexuscos.online` → VPS IP `74.208.155.161`.
- [ ] SSH key configured for deploy user; adjust `inventory.ini`.
- [ ] `nexus-pf-deploy.zip` present locally under `artifacts/pf-deploy/`.
- [ ] Run Ansible playbook; confirm TLS issuance and service health.
- [ ] Document new modules in `PF_INDEX.md` and add health checks.
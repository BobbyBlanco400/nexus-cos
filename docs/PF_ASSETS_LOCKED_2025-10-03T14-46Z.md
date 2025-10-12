# PF Assets Locked — 2025-10-03T14:46Z

This manifest records canonical PF assets (SSL and environment) discovered in the repository and the expected deployment targets per PF documentation. Use this as the single source of truth for the PF stack and Nginx.

## Environment Files

- Repo file: `.env.pf`
  - Path: `/opt/nexus-cos/.env.pf` (repo root when deployed)
  - Purpose: Base env for PF; copied to `.env` by deploy scripts if `.env` is absent
  - Referenced by: `validate-pf.sh` (checks `NODE_ENV`, `DB_USER`, `DB_PASSWORD`, `REDIS_HOST`)

## SSL Certificates and Keys

- Repo candidate certificate: `fullchain.crt`
  - Path: `/opt/nexus-cos/fullchain.crt` (repo root)
  - Deploy script behavior: If `ssl/nexus-cos.crt` is missing, script copies `fullchain.crt` into `/opt/nexus-cos/ssl/nexus-cos.crt`

- Repo SSL folders:
  - Certs: `/opt/nexus-cos/ssl/certs/` (may contain `*.crt`)
  - Private keys: `/opt/nexus-cos/ssl/private/` (may contain `*.key`)
  - Deploy script behavior: first `*.crt` under `ssl/certs` -> `/opt/nexus-cos/ssl/nexus-cos.crt`; first `*.key` under `ssl/private` -> `/opt/nexus-cos/ssl/nexus-cos.key`

### Canonical Nginx SSL Paths (PF)

- Certificate: `/opt/nexus-cos/ssl/nexus-cos.crt`
- Private key: `/opt/nexus-cos/ssl/nexus-cos.key`
- Referenced in: `nginx/conf.d/nexus-proxy.conf`, `scripts/fix-pf-ssl.sh`, `docs/PF_FINAL_DEPLOYMENT_TURNAKEY.md`

### Alternative/Legacy SSL References (Inventory docs)

- IONOS paths (production): `/etc/ssl/ionos/fullchain.pem`, `/etc/ssl/ionos/privkey.pem`
- Let’s Encrypt (example configs): `/etc/letsencrypt/live/nexuscos.online/fullchain.pem`, `/etc/letsencrypt/live/nexuscos.online/privkey.pem`

## PF Deployment Scripts and Docs

- `scripts/pf-final-deploy.sh`: Prepares `/opt/nexus-cos/ssl` and normalizes `.env` from `.env.pf`. Performs PF service startup and external validations including `/v-suite/prompter`.
- `docs/PF_FINAL_DEPLOYMENT_TURNAKEY.md`: Defines Nginx mount points and SSL target paths under `/opt/nexus-cos/ssl`.
- `PF_README.md`: PF-only Nginx notes; ensure `VITE_API_URL=https://nexuscos.online/api`.
- `validate-pf.sh`, `test-pf-configuration.sh`: Validation of env variables and PF routes.

## V‑Prompter Pro Routing (Locked)

- Public route: `/v-suite/prompter/`
- Target service: `http://127.0.0.1:3502/`
- Health: `/v-suite/prompter/health` -> `http://127.0.0.1:3502/health`
- Configured in: `nginx/conf.d/nexus-proxy.conf`
- Startup script aligned: `launch-v-suite.ps1` starts `services/v-prompter-pro`

## Actionable Steps (Server)

1. Place certificate and key:
   - Copy your valid certificate to `/opt/nexus-cos/ssl/nexus-cos.crt`
   - Copy your private key to `/opt/nexus-cos/ssl/nexus-cos.key`
   - Permissions: `644` for cert, `600` for key
2. Ensure `.env` present:
   - If missing, copy `.env.pf` -> `.env` and edit secrets (e.g., `OAUTH_CLIENT_ID`)
3. Reload Nginx:
   - `nginx -t && systemctl reload nginx`
4. Validate PF endpoints:
   - `https://nexuscos.online/v-suite/prompter/health` => `200 OK`

---

Locked by: automated PF asset discovery
Timestamp: 2025-10-03T14:46Z
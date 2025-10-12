# PF Beta Fix — GitHub Code Agent Brief

## Context
- Beta site `https://beta.nexuscos.online` consistently returns `HTTP 500` for `/`, `/index.html`, and static files.
- Server header: `nginx/1.24.0 (Ubuntu)` — failure occurs at Nginx before assets are served.
- SSH from Windows timed out and complex one‑liners were parsed incorrectly, so prefer Plesk UI or simple per‑line SSH.

## Symptoms
- `curl -I https://beta.nexuscos.online/` → `HTTP/2 500`
- `curl -I https://beta.nexuscos.online/index.html` → `HTTP/2 500`
- `curl -I https://beta.nexuscos.online/assets/branding/logo.svg` → `HTTP/2 500`

## Likely Root Causes
- Beta vhost routes `/` via a proxy/snippet to a non‑running upstream, causing 500 on static paths.
- Document Root mismatch or empty directory; conflicting roots observed in repo docs:
  - `/var/www/vhosts/beta.nexuscos.online/httpdocs` (Plesk standard)
  - `/opt/nexus-cos/web/beta` (legacy/alt in `deployment/nginx/nginx.conf.remote`)

## Target State
- Beta serves PF static build (SPA) from Plesk docroot with SPA fallback.
- Static assets (JS/CSS/SVG/JSON) served directly; `/api` proxies only if needed.
- All endpoints return `HTTP 200` (or 204 for certain health checks).

## Server Paths (use these)
- Document Root: `/var/www/vhosts/beta.nexuscos.online/httpdocs`
- Plesk override file: `/var/www/vhosts/system/beta.nexuscos.online/conf/vhost_nginx.conf`
- Logs: `/var/www/vhosts/system/beta.nexuscos.online/logs/error_log`, `/var/log/nginx/error.log`

## Repo Inputs for Publish
- PF static content: `web/beta/*` (includes `index.html`, `sitemap.xml`, etc.)
- Branding asset: `assets/branding/logo.svg`
- Nginx references for expectations:
  - `deployment/nginx/beta.nexuscos.online.conf` (SPA `try_files` at `/`)
  - `deployment/nginx/nginx.conf.remote` (beta blocks/snippets; do not proxy `/` in beta for static)
  - `nginx/conf.d/nexus-proxy.conf` (PF upstreams — not needed for static SPA)

## Implementation Tasks
1) Sync PF build into beta docroot
- Create docroot and copy assets:
```bash
mkdir -p /var/www/vhosts/beta.nexuscos.online/httpdocs
cp -a /var/tmp/upload-dist/* /var/www/vhosts/beta.nexuscos.online/httpdocs/ || true
# Alternatively, publish repo assets:
cp -a /opt/nexus-cos/web/beta/* /var/www/vhosts/beta.nexuscos.online/httpdocs/
cp -a /opt/nexus-cos/assets/branding/logo.svg /var/www/vhosts/beta.nexuscos.online/httpdocs/assets/branding/
```

2) Add SPA fallback via Plesk override
- Write `/var/www/vhosts/system/beta.nexuscos.online/conf/vhost_nginx.conf`:
```nginx
location / { try_files $uri $uri/ /index.html; }
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|json)$ {
  try_files $uri =404;
  expires 30d;
  add_header Cache-Control "public, no-transform";
}
```
- Ensure no conflicting `proxy_pass` at `location /` via snippets or custom configs.

3) Reconfigure and reload Nginx
```bash
plesk bin httpdmng --reconfigure-domain beta.nexuscos.online
nginx -t && systemctl reload nginx
```

## Verification (Success Criteria)
- Root and index:
```bash
curl -sSI https://beta.nexuscos.online/ | head -n 1   # HTTP/2 200
curl -sSI https://beta.nexuscos.online/index.html | head -n 1   # HTTP/2 200
```
- Static assets and config:
```bash
curl -sSI https://beta.nexuscos.online/assets/branding/logo.svg | head -n 1
curl -sSI https://beta.nexuscos.online/assets/index-*.js | head -n 1
curl -sSI https://beta.nexuscos.online/config/system-status.json | head -n 1
```
- Optional health:
```bash
curl -sSI https://beta.nexuscos.online/health | head -n 1  # 200
```

## Troubleshooting
- Logs:
```bash
tail -n 100 /var/www/vhosts/system/beta.nexuscos.online/logs/error_log
journalctl -u nginx --no-pager | tail -n 200
```
- Inspect active beta server block:
```bash
nginx -T | sed -n '/server_name beta.nexuscos.online/,/}/p'
```
- If `HTTP 500` persists, remove any `proxy_pass` at `location /` and confirm docroot contains a valid `index.html` and `/assets`.

## Windows-Friendly Transfer (if SSH one-liners fail)
- Use repo tools: `tools/plink.exe` and `tools/pscp.exe` with `vps_key` to push `web/beta/*` to the server docroot:
```powershell
.\tools\pscp.exe -i .\vps_key -r .\web\beta\* root@nexuscos.online:/var/www/vhosts/beta.nexuscos.online/httpdocs/
```

## Acceptance
- `HTTP 200` for `/`, `/index.html`, `/assets/*`, `/config/system-status.json`.
- No `proxy_pass` for `/` in beta; static SPA served directly.
- Nginx config validated and reloaded without errors.
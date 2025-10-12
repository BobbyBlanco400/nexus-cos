Overview

- Goal: Fix beta.nexuscos.online by serving the SPA statically with a proper fallback, removing any root proxying, and enabling asset caching — per PF_BETA_FIX_AGENT_BRIEF.md.
- This guide uses the Plesk UI so you can finish the PF-aligned correction without SSH.

Prerequisites

- You have `beta-dist.zip` available (prepared from `web/beta/*`).
- Beta docroot: `/var/www/vhosts/beta.nexuscos.online/httpdocs/`.

Upload and Extract Assets (Plesk)

- Open Plesk → Websites & Domains → beta.nexuscos.online → File Manager.
- Navigate to `/httpdocs/`.
- Upload `beta-dist.zip` and “Extract Files” into `/httpdocs/`.
- Ensure `index.html` is present at `/httpdocs/index.html`.

Add SPA Fallback and Static Asset Rules (Plesk)

- Plesk → Websites & Domains → Apache & nginx Settings → Additional nginx directives.
- Paste the following PF-aligned configuration:

```
location / {
    try_files $uri $uri/ /index.html;
}

location ~* \.(?:js|css|png|jpg|jpeg|gif|svg|ico|woff2?|ttf)$ {
    try_files $uri =404;
    expires 1y;
    add_header Cache-Control "public, max-age=31536000";
}
```

- Save. This triggers an nginx reload via Plesk.

What NOT to include

- Do not set `proxy_pass` in the root (`location /`). Beta should serve static files only, with the SPA fallback taking over.

Reload nginx (if needed)

- Saving the Additional nginx directives will reload nginx.
- Alternatively: Plesk → Tools & Settings → Services Management → Restart nginx.

Verification

- Root: `curl -I https://beta.nexuscos.online/` → expect `HTTP/1.1 200`.
- Index: `curl -I https://beta.nexuscos.online/index.html` → expect `200`.
- Asset: `curl -I https://beta.nexuscos.online/assets/branding/logo.svg` → expect `200`.
- Confirm no `proxy_pass` in the beta server block via Plesk config preview or `nginx -T` if SSH is available.

Troubleshooting

- 500 errors: Check Plesk logs under `/var/www/vhosts/system/beta.nexuscos.online/logs/error_log`.
- 404 on assets: Ensure files exist under `/httpdocs/` and the static asset block is present.
- SPA routing issues: Ensure `location / { try_files $uri $uri/ /index.html; }` is applied.

Optional: SSH Commands When Port 22 Is Open

- Upload and extract zip:
  - `pscp.exe -pw <PW> .\beta-dist.zip root@<IP>:/var/tmp/beta-dist.zip`
  - `plink.exe -pw <PW> root@<IP> "bash -lc 'set -e; DOCROOT=/var/www/vhosts/beta.nexuscos.online/httpdocs; mkdir -p \"$DOCROOT\"; unzip -o /var/tmp/beta-dist.zip -d \"$DOCROOT\"'"`
- Write Plesk override and reload nginx:
  - `plink.exe -pw <PW> root@<IP> "bash -lc 'set -e; OV=/var/www/vhosts/system/beta.nexuscos.online/conf/vhost_nginx.conf; mkdir -p \"$(dirname \"$OV\")\"; cat > \"$OV\" << \"EOF\"\nlocation / { try_files $uri $uri/ /index.html; }\nlocation ~* \\.(?:js|css|png|jpg|jpeg|gif|svg|ico|woff2?|ttf)$ { try_files $uri =404; expires 1y; add_header Cache-Control \"public, max-age=31536000\"; }\nEOF\n(command -v plesk && plesk sbin nginxmng -t && plesk sbin nginxmng -r) || (nginx -t && systemctl reload nginx)'"`

Notes

- This correction aligns with PF documentation and ensures beta serves static SPA content independently of the PF `/api` stack.
- Keep frontends pointing `VITE_API_URL=/api` if they interact with the PF backend via the same host.
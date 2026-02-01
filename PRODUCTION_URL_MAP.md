# 🌐 N3XUS v-COS PRODUCTION URL MAP
**Domain:** `n3xuscos.online`
**IP:** `72.62.86.217`
**Status:** ACTIVE

---

## 1. PUBLIC ACCESS POINTS

| Service | URL | Note |
| :--- | :--- | :--- |
| **Main Platform** | [https://n3xuscos.online](https://n3xuscos.online) | Primary Entry Point |
| **API Endpoint** | [https://n3xuscos.online/api](https://n3xuscos.online/api) | Core API |
| **Health Check** | [https://n3xuscos.online/health](https://n3xuscos.online/health) | System Status |

---

## 2. SPECIALIZED PORTALS (SUBDOMAINS/PORTS)

Since SSL is typically handled on port 443 (https), these services are mapped via Nginx or direct port access depending on your SSL config.

| Service | Direct Access (HTTP) | Secure Path (If Configured) |
| :--- | :--- | :--- |
| **Remote Mic Bridge** | [http://n3xuscos.online:8081](http://n3xuscos.online:8081) | *Direct Port Access* |
| **V-Prompter Lite** | [http://n3xuscos.online:3504](http://n3xuscos.online:3504) | *Direct Port Access* |
| **MetaTwin Console** | [http://n3xuscos.online:3403](http://n3xuscos.online:3403) | *Direct Port Access* |

---

## 3. DNS CONFIGURATION (REQUIRED)

Ensure your DNS records at your registrar point to your VPS:

*   **Type:** `A`
*   **Host:** `@`
*   **Value:** `72.62.86.217`
*   **TTL:** `3600` (or lower for faster propagation)

*   **Type:** `CNAME`
*   **Host:** `www`
*   **Value:** `n3xuscos.online`

---

**CONFIRMED:** Nginx is configured to listen for `n3xuscos.online`.
**ACTION:** Once DNS propagates (usually 1-24 hours), the URLs above will be live.

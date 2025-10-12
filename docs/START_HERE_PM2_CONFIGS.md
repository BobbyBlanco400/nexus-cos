# START HERE: PM2 Configuration Quick Guide

This guide shows how to start, stop, and monitor Nexus COS processes using the new modular PM2 ecosystem configuration files.

## Ecosystem Files

- `ecosystem.platform.config.js` — Core platform services
- `ecosystem.puabo.config.js` — PUABO suite (standardized module entries)
- `ecosystem.vsuite.config.js` — V-Suite production tools
- `ecosystem.family.config.js` — Family Entertainment modules
- `ecosystem.urban.config.js` — Urban Entertainment services

## Start Services

```bash
pm2 start ecosystem.platform.config.js
pm2 start ecosystem.puabo.config.js
pm2 start ecosystem.vsuite.config.js
pm2 start ecosystem.family.config.js
pm2 start ecosystem.urban.config.js

# Start all configs (glob support depends on shell):
pm2 start ecosystem.*.config.js
```

## Monitor & Logs

- List all processes: `pm2 ls`
- Show logs for a process: `pm2 logs <name>`
- Log files are written under `logs/<group>/` per app name.
  - Example: `logs/family/tyshawns-vdance-service.log` and `.err.log`

## Port Allocation Strategy

- `3100–3199`: Platform
- `3200–3299`: PUABO (module entry points begin at `3200`)
- `3300–3399`: Auth
- `3400–3499`: AI/Creator
- `3500–3599`: V-Suite
- `8400–8499`: Family (reserved)
- `8500–8599`: Urban (reserved)

Use these ranges to assign ports consistently across services.

## Environment Variables

- Configure secrets and service settings via environment variables.
- You can set `env` in each PM2 app entry or use a `.env` file loaded by the app.

## Reference

- Nexus COS Ecosystem PF (2025.10.12): https://github.com/BobbyBlanco400/nexus-cos/blob/main/PF_Nexus_COS_Ecosystem_2025.10.12.md
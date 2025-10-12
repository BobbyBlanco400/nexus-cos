# Nexus COS PM2 Ecosystem Configurations

This document catalogs the modular PM2 configuration files and the processes they manage, including log output locations and notes.

## Files & Groups

### Platform — `ecosystem.platform.config.js`
- Services: `auth-service`, `content-management`, `creator-hub`, `user-auth`, `pf-gateway`, `streaming`, `studio-ai`, `session-mgr`, `ledger-mgr`, `token-mgr`, `kei-ai`
- Logs: `logs/platform/<name>.log` and `<name>.err.log`

### PUABO — `ecosystem.puabo.config.js`
- Services: `puaboverse`, `puabo-nuki`, `puabo-nexus`, `puabo-blac`, `puabo-dsp`
- Ports: `3200–3204` reserved (module entry points)
- Logs: `logs/puabo/<name>.log` and `<name>.err.log`
- Note: Each module now uses a standardized single-entry `server.js` under `modules/<module>/`.

### V-Suite — `ecosystem.vsuite.config.js`
- Services: `v-prompter-pro`, `v-screen`, `v-stage`, `v-caster-pro`
- Logs: `logs/vsuite/<name>.log` and `<name>.err.log`

### Family — `ecosystem.family.config.js`
- Modules: `tyshawns-vdance-service`, `fayeloni-kreation-service`, `sassie-lashes-service`, `nee-nee-kids-service`
- Scripts: point to reclassified module paths under `modules/`
- Ports: `8401–8404` reserved
- Logs: `logs/family/<name>.log` and `<name>.err.log`

### Urban — `ecosystem.urban.config.js`
- Services: `ahshantis-munch-and-mingle`, `clocking-t-with-ta-gurl-p`, `headwina-comedy-club`, `idh-live-beauty-salon`, `roro-reefer-gaming-lounge`
- Logs: `logs/urban/<name>.log` and `<name>.err.log`

## Usage

```bash
pm2 start ecosystem.platform.config.js
pm2 start ecosystem.puabo.config.js
pm2 start ecosystem.vsuite.config.js
pm2 start ecosystem.family.config.js
pm2 start ecosystem.urban.config.js
```

## Port Allocation Strategy

- `3100–3199`: Platform
- `3200–3299`: PUABO
- `3300–3399`: Auth
- `3400–3499`: AI/Creator
- `3500–3599`: V-Suite
- `8400–8499`: Family
- `8500–8599`: Urban

## Reference

- PF: Nexus COS Ecosystem Map & Recommendations (2025.10.12)
  - https://github.com/BobbyBlanco400/nexus-cos/blob/main/PF_Nexus_COS_Ecosystem_2025.10.12.md
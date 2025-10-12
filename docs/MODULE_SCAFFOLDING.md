# Module Scaffolding — Nexus COS

This guide explains how to scaffold new modules and microservices consistently with existing patterns (Express, health/status endpoints, PM2 management).

## Quick Start

1. Generate a module:

```
node scripts/scaffold-module.mjs my-module --port 8100 --microservices worker,api --desc "My module description"
```

2. Install dependencies and start:

```
cd modules/my-module
npm install
pm2 start ecosystem.config.js
curl http://localhost:8100/health
```

3. Optional: start microservices

```
cd modules/my-module/services/worker && npm install && npm start
cd modules/my-module/services/api && npm install && npm start
```

## What’s Included

- `server.js` with routes: `/`, `/health`, `/api/status`
- `public/index.html` for assets
- `package.json` with `start`/`dev` scripts
- `ecosystem.config.js` for PM2
- `docs/README.md` summarizing port, endpoints, and usage
- Optional microservices under `modules/<name>/services/<microservice>/`

## Port Strategy

- Base port provided via `--port` (defaults to `8100`)
- Microservices increment ports from base (`8101`, `8102`, ...)

## Frontend Wiring (optional)

- Create a page at `frontend/src/pages/MyModule.jsx`
- Link to your module using an env var: `VITE_MY_MODULE_URL`
- Add a health chip and actions similar to `VScreenHollywood.jsx`

## Notes

- Works best with PM2 for dev orchestration
- Health checks should return `{ status: 'ok', service, port, time }`
- Status should return `{ service, version, uptime, port }`
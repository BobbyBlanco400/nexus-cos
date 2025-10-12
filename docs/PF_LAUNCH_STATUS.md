PF Launch Status — Nexus COS

Overview
- Goal: Restore “full beta launch” by validating env, rebuilding PF stack, and confirming health endpoints.
- Scope: PF gateway (Hollywood via gateway), Prompter, PV Keys, Nginx routed Prompter.

Prerequisites
- `.env.pf` contains real values: `OAUTH_CLIENT_ID`, `OAUTH_CLIENT_SECRET`, `JWT_SECRET`, `DB_PASSWORD`.
- `.env.pf` synced to `.env`.
- Docker and Docker Compose installed on the server.

Server Commands
- Verify env: `bash scripts/pf-env-verify.sh /opt/nexus-cos/.env.pf` (Linux)
- Rebuild stack: `docker compose -f /opt/nexus-cos/docker-compose.pf.yml up -d --build`
- Health checks:
  - `curl -sSf http://localhost:4000/health` (PF gateway/Hollywood)
  - `curl -sSf http://localhost:3002/health` (Prompter)
  - `curl -sSf http://localhost:3041/health` (PV Keys)
  - `curl -sSf https://nexuscos.online/v-suite/prompter/health` (Nginx routed)

Local Quick Checks (Windows)
- Env verify: `powershell -ExecutionPolicy Bypass -File scripts/pf-env-verify.ps1`
- Health quick check: `powershell -ExecutionPolicy Bypass -File scripts/pf-health-check.ps1`
  - Note: On local machines, services will be UNREACHABLE unless the PF stack is running.

Acceptance Criteria
- PF env verification reports all required keys present (no placeholders).
- PF gateway, Prompter, PV Keys return `200 OK` on server localhost.
- Nginx routed Prompter returns `200 OK` at `https://nexuscos.online/v-suite/prompter/health`.

Rollback / Recovery
- If any health check fails, run `docker compose -f /opt/nexus-cos/docker-compose.pf.yml logs -f` and fix env or service errors.
- Re-run env verification and health checks after remediation.
# N3XUS v-COS Full Codespaces Deployment

This PR contains all updates to deploy the **real VPS stack** into GitHub Codespaces.

## Features

✅ **Full Handshake Compliance**: Every step is strictly verified with **X-N3XUS-Handshake 55-45-17**  
✅ **Docker Compose** updated for Codespaces: `docker-compose.codespaces.yml`  
✅ **Bootstrap & Ignite scripts** updated to detect Codespaces and enforce handshake  
✅ **Verify-launch script** ensures all containers are running and handshake headers exist  
✅ Real backend, frontend, and extended services synced from VPS structure  
✅ Optional Node.js verifications are skipped gracefully without silent failures  

## Services Included

The deployment includes the following services:

1. **v-supercore-codespaces** - Core platform service (Port: 3001)
2. **puabo_api_ai_hf-codespaces** - AI/HuggingFace API service (Port: 3002)
3. **ledger-mgr** - Ledger management service (Port: 3112)
4. **founding-creatives** - Founding creatives service (Port: 3200)
5. **puabo-nexus-driver-app-backend** - Driver app backend (Port: 3301)
6. **puaboverse-v2** - Puaboverse platform v2 (Port: 3400)
7. **puabo-nuki-inventory-mgr** - NUKI inventory manager (Port: 3500)
8. **puabo-dsp-metadata-mgr** - DSP metadata manager (Port: 3600)

## Usage

After merge, run:

```bash
bash scripts/phase3-4-ignite.sh
bash scripts/verify-launch.sh
```

This will start all services and validate handshake compliance.

## Scripts

### `scripts/bootstrap-phase3-4.sh`

Bootstrap script that:
- Detects Codespaces vs local environment
- Starts the appropriate Docker Compose stack
- Optionally verifies Node.js modules for services

### `scripts/phase3-4-ignite.sh`

Ignition script that:
- Calls the bootstrap script to start services
- Waits for containers to initialize
- Verifies N3XUS Handshake (55-45-17) for all containers
- Exits with error if any handshake is missing

### `scripts/verify-launch.sh`

Verification script that:
- Checks if all containers are running
- Verifies N3XUS Handshake headers in logs
- Validates required files exist (.env, docker-compose.codespaces.yml)

## Docker Compose Configuration

The `docker-compose.codespaces.yml` file:
- Defines all 8 services with their build contexts
- Maps appropriate ports for each service
- Sets environment variables including X_N3XUS_HANDSHAKE
- Ensures handshake header is logged on startup via command override
- Creates a shared network for inter-service communication

## Environment Detection

Scripts automatically detect GitHub Codespaces via:
- `$CODESPACES` environment variable
- `$GITHUB_CODESPACES` environment variable

When detected, uses `docker-compose.codespaces.yml`, otherwise falls back to `docker-compose.final.yml` for local development.

## N3XUS Handshake Enforcement

All services are configured to:
1. Log the header `X-N3XUS-Handshake: 55-45-17` on startup
2. Expose this via Docker logs for verification
3. Fail deployment if handshake is not present

This ensures strict compliance with the N3XUS protocol specification.

# Deployment Notes

## Important Information About Deployment Files

### PM2 Configuration (ecosystem.config.js)

The deployment script looks for `ecosystem.config.js` to deploy services with PM2. If this file exists, it will:
- Stop existing PM2 processes
- Start all services defined in the config
- Save PM2 configuration
- Set up PM2 startup

**If the file doesn't exist**: The script will skip PM2 deployment but will log a warning. Services can be started manually later.

### Docker Compose Configuration

The deployment script looks for Docker Compose files in this order:
1. `docker-compose.unified.yml` (preferred)
2. `docker-compose.yml` (fallback)

**If neither exists**: The script will skip Docker deployment but will log a warning. Services can be started manually later.

### PUABO Core

PUABO Core has its own deployment script and Docker Compose file:
- Script: `nexus-cos/puabo-core/deploy-puabo-core.sh`
- Docker Compose: `nexus-cos/puabo-core/docker-compose.core.yml`

This is independent of the main platform deployment and will always run if the files exist.

## Flexible Deployment

The deployment script is designed to be flexible:
- It will deploy what it finds
- It logs warnings for missing components
- It continues even if some components are missing
- You can always add missing components and re-run specific parts later

## Manual Service Startup

If PM2 or Docker services are skipped during deployment, you can start them manually:

### PM2 Services
```bash
cd /var/www/nexus-cos
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Docker Services
```bash
cd /var/www/nexus-cos
docker compose -f docker-compose.unified.yml up -d --build
# or
docker compose -f docker-compose.yml up -d --build
```

### PUABO Core
```bash
cd /var/www/nexus-cos/nexus-cos/puabo-core
./deploy-puabo-core.sh
```

## Validation

The `validate-deployment-ready.sh` script checks for the existence of these files and will warn you if they're missing before deployment.

---

**Note**: The deployment manifest (`DEPLOYMENT_MANIFEST.json`) is the source of truth for the complete platform configuration. The deployment script uses this manifest to configure Nginx routing and endpoint expectations.

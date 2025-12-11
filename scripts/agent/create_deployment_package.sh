#!/bin/bash
# Create deployment package for IONOS
# Generates production-ready deployment bundle

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-$(pwd)}"
OUTPUT_DATE=$(date +%Y%m%d)
PACKAGE_NAME="deployment_package_${OUTPUT_DATE}.tar.gz"
PACKAGE_DIR="/tmp/nexus_deployment_package"
OUTPUT_FILE="${WORKDIR}/reports/${PACKAGE_NAME}"

echo "=========================================="
echo "Nexus COS Deployment Package Generator"
echo "=========================================="
echo "Working Directory: ${WORKDIR}"
echo "Package: ${PACKAGE_NAME}"
echo "=========================================="

# Create package directory
rm -rf "${PACKAGE_DIR}"
mkdir -p "${PACKAGE_DIR}"

# Copy deployment configurations
echo "Copying deployment configurations..."
mkdir -p "${PACKAGE_DIR}/deployment"

# Create docker-compose.ionos.yml for 52 services
cat > "${PACKAGE_DIR}/deployment/docker-compose.ionos.yml" <<'EOF'
version: '3.8'

networks:
  nexus-net:
    driver: bridge

volumes:
  postgres_data:
  redis_data:

services:
  # Infrastructure
  postgres:
    image: postgres:15-alpine
    container_name: nexus-postgres
    environment:
      POSTGRES_DB: ${POSTGRES_DB:-nexus_db}
      POSTGRES_USER: ${POSTGRES_USER:-nexus_user}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-changeme}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - nexus-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER"]
      interval: 10s
      timeout: 5s
      retries: 5
  
  redis:
    image: redis:7-alpine
    container_name: nexus-redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - nexus-net
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
  
  # Core Services
  backend-api:
    image: ${REGISTRY:-localhost:5000}/nexus/backend-api:${VERSION:-latest}
    container_name: nexus-backend-api
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-nexus_user}:${POSTGRES_PASSWORD:-changeme}@postgres:5432/${POSTGRES_DB:-nexus_db}
      REDIS_URL: redis://redis:6379
      PORT: 3000
    ports:
      - "3000:3000"
    depends_on:
      - postgres
      - redis
    networks:
      - nexus-net
    restart: unless-stopped
  
  # Template for additional services (52 total required)
  # Each service from deployment/service_list.txt should be added here
  # following the pattern above. Services include:
  # - Content Management & Streaming (10 services)
  # - Monetization & Commerce (5 services)
  # - Analytics (3 services)
  # - PUABO Universe (5 services)
  # - And 29 more services as defined in docs/investor_synopsis.md
  #
  # Example pattern for each service:
  # service-name:
  #   image: ${REGISTRY}/nexus/service-name:${VERSION}
  #   environment:
  #     - DATABASE_URL=postgresql://...
  #   depends_on:
  #     - postgres
  #     - redis
  #   networks:
  #     - nexus-net
  #   restart: unless-stopped
  
EOF

# Create .env.template
cat > "${PACKAGE_DIR}/deployment/.env.template" <<'EOF'
# Nexus COS Environment Configuration
# Copy this file to .env and fill in the values

# Database
POSTGRES_DB=nexus_db
POSTGRES_USER=nexus_user
POSTGRES_PASSWORD=CHANGEME_SECURE_PASSWORD

# Redis
REDIS_URL=redis://redis:6379

# Registry
REGISTRY=ghcr.io/yourusername
VERSION=latest

# Application
NODE_ENV=production
JWT_SECRET=CHANGEME_SECURE_SECRET
BCRYPT_ROUNDS=12

# Domain
DOMAIN=nexuscos.online
SSL_EMAIL=admin@nexuscos.online

# IONOS VPS
VPS_HOST=your-vps-ip
VPS_USER=root
VPS_SSH_PORT=22
EOF

# Copy deployment scripts
echo "Copying deployment scripts..."
mkdir -p "${PACKAGE_DIR}/scripts"

cat > "${PACKAGE_DIR}/scripts/remote_deploy_runner.sh" <<'EOF'
#!/bin/bash
# Remote deployment runner for IONOS VPS
set -euo pipefail

echo "========================================"
echo "Nexus COS Remote Deployment Runner"
echo "========================================"

# Load environment
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    echo "Copy .env.template to .env and configure it"
    exit 1
fi

source .env

# Validate required variables
required_vars=("POSTGRES_PASSWORD" "JWT_SECRET" "DOMAIN")
for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        echo "Error: $var is not set in .env"
        exit 1
    fi
done

# Pull images
echo "Pulling Docker images..."
docker compose -f deployment/docker-compose.ionos.yml pull

# Start services
echo "Starting services..."
docker compose -f deployment/docker-compose.ionos.yml up -d

# Wait for services to be healthy
echo "Waiting for services to be healthy..."
sleep 30

# Run health checks
echo "Running health checks..."
bash scripts/post_deploy_audit.sh

echo "========================================"
echo "Deployment complete!"
echo "========================================"
EOF

chmod +x "${PACKAGE_DIR}/scripts/remote_deploy_runner.sh"

cat > "${PACKAGE_DIR}/scripts/post_deploy_audit.sh" <<'EOF'
#!/bin/bash
# Post-deployment audit and health checks
set -euo pipefail

echo "========================================"
echo "Post-Deployment Audit"
echo "========================================"

AUDIT_DIR="/tmp/post_deploy_audit_$(date +%Y%m%d_%H%M%S)"
mkdir -p "${AUDIT_DIR}"

# Check container status
echo "Checking container status..."
docker compose -f deployment/docker-compose.ionos.yml ps > "${AUDIT_DIR}/container_status.txt"

# Check health endpoints
echo "Checking health endpoints..."
services=("backend-api:3000")

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    echo "Testing ${name}..."
    if curl -sf "http://localhost:${port}/health" > "${AUDIT_DIR}/health_${name}.json"; then
        echo "  ✓ ${name} is healthy"
    else
        echo "  ✗ ${name} failed health check"
    fi
done

# Collect logs
echo "Collecting logs..."
docker compose -f deployment/docker-compose.ionos.yml logs --tail=100 > "${AUDIT_DIR}/service_logs.txt"

# Create audit package
echo "Creating audit package..."
AUDIT_PACKAGE="/tmp/post_deploy_audit_$(date +%Y%m%d_%H%M%S).tgz"
tar -czf "${AUDIT_PACKAGE}" -C "$(dirname ${AUDIT_DIR})" "$(basename ${AUDIT_DIR})"

echo "========================================"
echo "Audit complete!"
echo "Package: ${AUDIT_PACKAGE}"
echo "========================================"
EOF

chmod +x "${PACKAGE_DIR}/scripts/post_deploy_audit.sh"

cat > "${PACKAGE_DIR}/scripts/rollback_to_tag.sh" <<'EOF'
#!/bin/bash
# Rollback to previous verified tag
set -euo pipefail

TAG="${1:-}"

if [ -z "${TAG}" ]; then
    echo "Usage: $0 <tag>"
    echo "Example: $0 verified_release_v1.0.0"
    exit 1
fi

echo "========================================"
echo "Rolling back to: ${TAG}"
echo "========================================"

# Stop current services
docker compose -f deployment/docker-compose.ionos.yml down

# Update VERSION in .env
sed -i "s/VERSION=.*/VERSION=${TAG#verified_release_v}/" .env

# Pull images for the tag
docker compose -f deployment/docker-compose.ionos.yml pull

# Start services
docker compose -f deployment/docker-compose.ionos.yml up -d

echo "========================================"
echo "Rollback complete!"
echo "========================================"
EOF

chmod +x "${PACKAGE_DIR}/scripts/rollback_to_tag.sh"

# Copy reports
echo "Copying reports..."
if [ -d "${WORKDIR}/reports" ]; then
    cp -r "${WORKDIR}/reports" "${PACKAGE_DIR}/" || true
fi

# Copy artifacts
echo "Copying artifacts..."
if [ -d "${WORKDIR}/artifacts" ]; then
    cp -r "${WORKDIR}/artifacts" "${PACKAGE_DIR}/" || true
fi

# Create README
cat > "${PACKAGE_DIR}/README.md" <<'EOF'
# Nexus COS Deployment Package for IONOS

This package contains everything needed to deploy Nexus COS to an IONOS VPS.

## Contents

- `deployment/` - Docker Compose and configuration files
- `scripts/` - Deployment and management scripts
- `reports/` - Compliance and deployment reports
- `artifacts/` - Build artifacts and manifests

## Prerequisites

- IONOS VPS with Ubuntu 24.04 LTS
- Docker and Docker Compose installed
- Minimum 8GB RAM, 50GB disk space
- Ports 80, 443, 22 open

## Quick Start

1. Copy `.env.template` to `.env` and configure:
   ```bash
   cp deployment/.env.template .env
   nano .env
   ```

2. Run deployment:
   ```bash
   bash scripts/remote_deploy_runner.sh
   ```

3. Verify deployment:
   ```bash
   bash scripts/post_deploy_audit.sh
   ```

## Rollback

To rollback to a previous version:

```bash
bash scripts/rollback_to_tag.sh verified_release_v1.0.0
```

## Support

For issues, see the reports directory or contact support.
EOF

# Create the package
echo "Creating package archive..."
cd "$(dirname ${PACKAGE_DIR})"
tar -czf "${OUTPUT_FILE}" "$(basename ${PACKAGE_DIR})"

# Cleanup
rm -rf "${PACKAGE_DIR}"

echo "=========================================="
echo "✓ Deployment package created!"
echo "  File: ${OUTPUT_FILE}"
echo "  Size: $(du -h "${OUTPUT_FILE}" | cut -f1)"
echo "=========================================="
echo ""
echo "To deploy to IONOS VPS:"
echo "  1. Upload: scp ${OUTPUT_FILE} user@vps:/opt/"
echo "  2. Extract: tar -xzf ${PACKAGE_NAME}"
echo "  3. Configure: cd $(basename ${PACKAGE_DIR}) && cp deployment/.env.template .env"
echo "  4. Deploy: bash scripts/remote_deploy_runner.sh"
echo "=========================================="

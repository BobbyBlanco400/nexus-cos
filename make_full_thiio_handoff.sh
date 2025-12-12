#!/bin/bash

# Nexus COS - Complete THIIO Handoff Package Generator
# This script creates a comprehensive ZIP bundle containing the entire Nexus COS platform
# Including: 52+ services, 43 modules, all infrastructure, manifests, scripts, and documentation

set -e

echo "============================================================="
echo "Nexus COS - Complete THIIO Handoff Package Generator"
echo "============================================================="
echo ""
echo "Generating full platform export including:"
echo "  • All services (backend, real-time, AI, banking, OTT, Stream, DSP, Auth)"
echo "  • All modules (43 functional modules)"
echo "  • All monorepos and internal packages"
echo "  • All infrastructure and DevOps scripts"
echo "  • Complete banking layer"
echo "  • Deployment manifests and configurations"
echo "  • 23-file THIIO minimal handoff documentation"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$PROJECT_ROOT/dist"
BUNDLE_NAME="Nexus-COS-THIIO-FullStack"
TEMP_DIR="$DIST_DIR/${BUNDLE_NAME}-temp"
ZIP_FILE="$DIST_DIR/${BUNDLE_NAME}.zip"
MANIFEST_FILE="$DIST_DIR/${BUNDLE_NAME}-manifest.json"

# Directories to exclude from the bundle
EXCLUDE_PATTERNS=(
  "node_modules"
  "dist"
  "build"
  ".next"
  "out"
  "logs"
  "*.log"
  ".git"
  "__pycache__"
  "*.pyc"
  ".pytest_cache"
  ".venv"
  "venv"
  "env"
  "target"
  "pkg"
  "*.zip"
  ".DS_Store"
  "Thumbs.db"
  "coverage"
  ".coverage"
  "*.swp"
  "*.swo"
  "*~"
)

# Step 1: Create clean directories
echo -e "${YELLOW}Step 1: Preparing workspace...${NC}"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$DIST_DIR"
echo -e "${GREEN}✓ Workspace ready${NC}"
echo ""

# Step 2: Generate Kubernetes manifests
echo -e "${YELLOW}Step 2: Generating Kubernetes manifests...${NC}"
if [ -f "$PROJECT_ROOT/scripts/generate-full-k8s.sh" ]; then
  bash "$PROJECT_ROOT/scripts/generate-full-k8s.sh" 2>&1 | grep -E "(✓|Generated|Complete)" || true
  echo -e "${GREEN}✓ Kubernetes manifests generated${NC}"
else
  echo -e "${YELLOW}⚠ K8s generator script not found, skipping${NC}"
fi
echo ""

# Step 3: Generate environment templates
echo -e "${YELLOW}Step 3: Generating environment templates...${NC}"
if [ -f "$PROJECT_ROOT/scripts/generate-env-templates.sh" ]; then
  bash "$PROJECT_ROOT/scripts/generate-env-templates.sh" 2>&1 | grep -E "(✓|Generated|Complete)" || true
  echo -e "${GREEN}✓ Environment templates generated${NC}"
else
  echo -e "${YELLOW}⚠ Env template generator script not found, skipping${NC}"
fi
echo ""

# Step 4: Copy all platform source code
echo -e "${YELLOW}Step 4: Copying platform source code...${NC}"

# Build rsync exclude arguments as array
EXCLUDE_ARGS=()
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  EXCLUDE_ARGS+=("--exclude=$pattern")
done

# Core platform components to include
COMPONENTS=(
  "services"
  "modules"
  "frontend"
  "backend"
  "src"
  "config"
  "scripts"
  "deployment"
  "docker-compose*.yml"
  "Dockerfile*"
  "package.json"
  "package-lock.json"
  "*.config.js"
  "*.config.ts"
  "tsconfig.json"
  "ecosystem*.config.js"
  "nginx"
  "ssl"
  "monitoring"
  "repos"
  "mobile"
  "mobile-sdk"
  "web"
  "admin"
  "apex"
  "branding"
  "creator-hub"
  "database"
  "routes"
  "tools"
)

echo "Copying core platform files..."
COPIED_FILES=0

for component in "${COMPONENTS[@]}"; do
  # Handle wildcards
  for item in $PROJECT_ROOT/$component; do
    if [ -e "$item" ]; then
      ITEM_NAME=$(basename "$item")
      
      # Skip excluded patterns
      SKIP=0
      for exclude in "${EXCLUDE_PATTERNS[@]}"; do
        if [[ "$ITEM_NAME" == $exclude ]]; then
          SKIP=1
          break
        fi
      done
      
      if [ $SKIP -eq 1 ]; then
        continue
      fi
      
      if [ -d "$item" ]; then
        echo "  Copying directory: $ITEM_NAME"
        # Use rsync for efficient copying with excludes
        rsync -a "${EXCLUDE_ARGS[@]}" "$item/" "$TEMP_DIR/$ITEM_NAME/" 2>/dev/null || \
          cp -r "$item" "$TEMP_DIR/" 2>/dev/null || true
      elif [ -f "$item" ]; then
        echo "  Copying file: $ITEM_NAME"
        cp "$item" "$TEMP_DIR/" 2>/dev/null || true
      fi
      COPIED_FILES=$((COPIED_FILES + 1))
    fi
  done
done

echo -e "${GREEN}✓ Platform source code copied ($COPIED_FILES components)${NC}"
echo ""

# Step 5: Copy THIIO documentation package
echo -e "${YELLOW}Step 5: Including THIIO handoff documentation...${NC}"

THIIO_DOCS=(
  "docs/THIIO-HANDOFF"
  "PROJECT-OVERVIEW.md"
  "THIIO-ONBOARDING.md"
  "CHANGELOG.md"
  "README.md"
  "deployment-manifest.json"
  "DEPLOYMENT_MANIFEST.json"
)

for doc in "${THIIO_DOCS[@]}"; do
  SOURCE="$PROJECT_ROOT/$doc"
  if [ -e "$SOURCE" ]; then
    if [ -d "$SOURCE" ]; then
      mkdir -p "$TEMP_DIR/$(dirname "$doc")"
      rsync -a "$SOURCE/" "$TEMP_DIR/$doc/" 2>/dev/null || true
      echo "  ✓ $doc (directory)"
    else
      mkdir -p "$TEMP_DIR/$(dirname "$doc")"
      cp "$SOURCE" "$TEMP_DIR/$doc" 2>/dev/null || true
      echo "  ✓ $doc"
    fi
  fi
done

echo -e "${GREEN}✓ THIIO documentation included${NC}"
echo ""

# Step 6: Copy generated manifests and templates
echo -e "${YELLOW}Step 6: Including generated manifests and templates...${NC}"

if [ -d "$DIST_DIR/kubernetes-manifests" ]; then
  mkdir -p "$TEMP_DIR/kubernetes-manifests"
  cp -r "$DIST_DIR/kubernetes-manifests/"* "$TEMP_DIR/kubernetes-manifests/" 2>/dev/null || true
  echo "  ✓ Kubernetes manifests"
fi

if [ -d "$DIST_DIR/env-templates" ]; then
  mkdir -p "$TEMP_DIR/env-templates"
  cp -r "$DIST_DIR/env-templates/"* "$TEMP_DIR/env-templates/" 2>/dev/null || true
  echo "  ✓ Environment templates"
fi

# Copy any existing .env.example
if [ -f "$PROJECT_ROOT/.env.example" ]; then
  cp "$PROJECT_ROOT/.env.example" "$TEMP_DIR/" 2>/dev/null || true
  echo "  ✓ .env.example"
fi

echo -e "${GREEN}✓ Generated files included${NC}"
echo ""

# Step 7: Copy scripts
echo -e "${YELLOW}Step 7: Including utility scripts...${NC}"

SCRIPT_FILES=(
  "scripts/run-local"
  "scripts/package-thiio-bundle.sh"
  "scripts/generate-full-k8s.sh"
  "scripts/generate-env-templates.sh"
  "scripts/build-all.sh"
  "scripts/test-all.sh"
  "scripts/validate-services.sh"
  "scripts/banking-migration.sh"
  "make_handoff_zip.ps1"
  "make_full_thiio_handoff.sh"
)

for script in "${SCRIPT_FILES[@]}"; do
  SOURCE="$PROJECT_ROOT/$script"
  if [ -f "$SOURCE" ]; then
    mkdir -p "$TEMP_DIR/$(dirname "$script")"
    cp "$SOURCE" "$TEMP_DIR/$script" 2>/dev/null || true
    echo "  ✓ $script"
  fi
done

echo -e "${GREEN}✓ Scripts included${NC}"
echo ""

# Step 8: Copy GitHub workflows
echo -e "${YELLOW}Step 8: Including GitHub workflows...${NC}"

if [ -d "$PROJECT_ROOT/.github/workflows" ]; then
  mkdir -p "$TEMP_DIR/.github/workflows"
  cp "$PROJECT_ROOT/.github/workflows/bundle-thiio-handoff.yml" "$TEMP_DIR/.github/workflows/" 2>/dev/null || true
  echo "  ✓ bundle-thiio-handoff.yml"
fi

echo -e "${GREEN}✓ Workflows included${NC}"
echo ""

# Step 9: Create README for the bundle
echo -e "${YELLOW}Step 9: Creating bundle README...${NC}"

cat > "$TEMP_DIR/THIIO-HANDOFF-README.md" <<'EOF'
# Nexus COS - Complete THIIO Handoff Package

This package contains the complete Nexus COS platform, ready for deployment by the THIIO team.

## Package Contents

### Services (52+)
All backend, real-time, AI, banking, OTT, streaming, DSP, and authentication services are included.
Located in: `services/`

### Modules (43)
All functional modules including:
- Casino Nexus
- Club Saditty
- PUABO BLAC (Banking)
- PUABO DSP (Digital Service Platform)
- PUABO Nexus (Ride-sharing)
- PUABO Nuki (E-commerce)
- PUABO OTT (Streaming TV)
- Nexus Stream
- MusicChain
- GameCore
- V-Suite Pro
- And more...

Located in: `modules/`

### Infrastructure & DevOps
- All Dockerfiles
- Kubernetes manifests (generated in `kubernetes-manifests/`)
- Docker Compose configurations
- PM2 ecosystem configurations
- Nginx configurations
- SSL configurations
- Monitoring configurations

### Scripts
- `scripts/run-local` - Run the platform locally
- `scripts/build-all.sh` - Build all services
- `scripts/test-all.sh` - Run platform-wide tests
- `scripts/generate-full-k8s.sh` - Generate Kubernetes manifests
- `scripts/generate-env-templates.sh` - Generate environment templates
- `scripts/validate-services.sh` - Validate service health endpoints
- `scripts/banking-migration.sh` - Run banking schema migrations

### Documentation
Complete THIIO handoff documentation in `docs/THIIO-HANDOFF/`:
- Architecture overview
- Service catalog
- Module catalog
- Operations runbooks
- Deployment guides
- Frontend guide

## Quick Start

### Prerequisites
- Node.js 18+ (for Node.js services)
- Python 3.9+ (for Python services)
- Go 1.19+ (for Go services)
- Docker & Docker Compose
- Kubernetes (for production deployment)
- PostgreSQL 14+
- Redis 7+

### Local Development

1. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Run the platform:**
   ```bash
   ./scripts/run-local
   ```

3. **Build all services:**
   ```bash
   ./scripts/build-all.sh
   ```

### Kubernetes Deployment

1. **Generate manifests (if not already present):**
   ```bash
   ./scripts/generate-full-k8s.sh
   ```

2. **Update secrets in `kubernetes-manifests/secrets/secrets-template.yaml`**

3. **Deploy:**
   ```bash
   cd kubernetes-manifests
   ./deploy.sh
   ```

### Database Setup

Run banking schema migrations:
```bash
./scripts/banking-migration.sh
```

### Validation

Validate all services have health endpoints:
```bash
./scripts/validate-services.sh
```

Run tests:
```bash
./scripts/test-all.sh
```

## Architecture

See `docs/THIIO-HANDOFF/architecture/` for detailed architecture diagrams and documentation.

## Support

For questions or issues during deployment, refer to:
- `docs/THIIO-HANDOFF/operations/runbook-daily-ops.md`
- `docs/THIIO-HANDOFF/operations/runbook-failover.md`
- `THIIO-ONBOARDING.md`

## What's NOT Included

To keep the bundle size manageable, the following are excluded:
- `node_modules/` (run `npm install` in each service)
- Build artifacts (`dist/`, `build/`)
- Log files
- `.git/` directory
- Python virtual environments and `__pycache__`

## Next Steps

1. Review `PROJECT-OVERVIEW.md` for platform overview
2. Read `THIIO-ONBOARDING.md` for onboarding instructions
3. Review `CHANGELOG.md` for recent changes
4. Set up your environment following the Quick Start guide
5. Deploy to your Kubernetes cluster
6. Configure monitoring and alerting

---

**Package Generated:** [TIMESTAMP]
**SHA256:** [SHA256_HASH]
**Size:** [FILE_SIZE] bytes

For the complete deployment experience, refer to the THIIO Handoff documentation.
EOF

echo -e "${GREEN}✓ Bundle README created${NC}"
echo ""

# Step 10: Create the ZIP file
echo -e "${YELLOW}Step 10: Creating ZIP archive...${NC}"
echo "This may take a few minutes..."

cd "$TEMP_DIR"
rm -f "$ZIP_FILE"

# Create ZIP with compression
zip -r -q "$ZIP_FILE" . \
  -x "*.git/*" \
  -x "*node_modules/*" \
  -x "*__pycache__/*" \
  -x "*.log" \
  -x "*dist/*" \
  -x "*build/*" || {
  echo -e "${RED}✗ Failed to create ZIP${NC}"
  exit 1
}

echo -e "${GREEN}✓ ZIP archive created${NC}"
echo ""

# Step 11: Calculate SHA256 and size
echo -e "${YELLOW}Step 11: Computing ZIP metadata...${NC}"

SHA256=$(sha256sum "$ZIP_FILE" | awk '{print toupper($1)}')

# Cross-platform file size
if stat -f%z "$ZIP_FILE" 2>/dev/null >/dev/null; then
  SIZE_BYTES=$(stat -f%z "$ZIP_FILE")
else
  SIZE_BYTES=$(stat -c%s "$ZIP_FILE")
fi

# Use bc if available, otherwise use shell arithmetic
if command -v bc &> /dev/null; then
  SIZE_KB=$(echo "scale=2; $SIZE_BYTES / 1024" | bc)
  SIZE_MB=$(echo "scale=2; $SIZE_BYTES / 1024 / 1024" | bc)
else
  SIZE_KB=$((SIZE_BYTES / 1024))
  SIZE_MB=$((SIZE_BYTES / 1024 / 1024))
fi
GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo -e "${GREEN}✓ Metadata computed${NC}"
echo ""

# Step 12: Generate manifest
echo -e "${YELLOW}Step 12: Generating manifest file...${NC}"

cat > "$MANIFEST_FILE" <<EOF
{
  "package": "Nexus COS - Complete THIIO Handoff Package",
  "version": "1.0.0",
  "path": "dist/$BUNDLE_NAME.zip",
  "sha256": "$SHA256",
  "size_bytes": $SIZE_BYTES,
  "size_human": "${SIZE_MB} MB",
  "generated_at": "$GENERATED_AT",
  "platform": {
    "name": "Nexus COS",
    "description": "Complete Operating System Platform"
  },
  "contents": {
    "services": "52+ services (backend, AI, banking, OTT, Stream, DSP, Auth, Core)",
    "modules": "43 functional modules",
    "infrastructure": "All Dockerfiles, K8s manifests, Docker Compose, PM2 configs",
    "banking_layer": "Complete PUABO BLAC banking services and migrations",
    "streaming": "Nexus Stream & Nexus OTT Mini",
    "documentation": "23-file THIIO minimal handoff documentation package",
    "scripts": "Build, test, deploy, migration, and validation scripts"
  },
  "excluded": [
    "node_modules",
    "dist/build output",
    "logs",
    "binaries",
    ".git",
    "__pycache__"
  ],
  "deployment": {
    "supported_platforms": ["Kubernetes", "Docker Compose", "PM2", "Bare Metal"],
    "required_services": ["PostgreSQL 14+", "Redis 7+", "RabbitMQ (optional)"],
    "min_requirements": {
      "cpu": "4 cores",
      "memory": "8GB RAM",
      "storage": "50GB"
    }
  },
  "note": "This package contains the entire Nexus COS platform stack (52+ services, 43 modules), all infrastructure, all manifests, all scripts, the banking layer, and the 23-file minimal THIIO kit. Ready for immediate deployment."
}
EOF

echo -e "${GREEN}✓ Manifest generated${NC}"
echo ""

# Update README with actual values
sed -i "s/\[TIMESTAMP\]/$GENERATED_AT/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || \
  sed -i '' "s/\[TIMESTAMP\]/$GENERATED_AT/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || true

sed -i "s/\[SHA256_HASH\]/$SHA256/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || \
  sed -i '' "s/\[SHA256_HASH\]/$SHA256/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || true

sed -i "s/\[FILE_SIZE\]/$SIZE_BYTES/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || \
  sed -i '' "s/\[FILE_SIZE\]/$SIZE_BYTES/g" "$TEMP_DIR/THIIO-HANDOFF-README.md" 2>/dev/null || true

# Step 13: Cleanup
echo -e "${YELLOW}Step 13: Cleaning up...${NC}"
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓ Cleanup complete${NC}"
echo ""

# Final Summary
echo "============================================================="
echo -e "${GREEN}THIIO Handoff Package Generated Successfully!${NC}"
echo "============================================================="
echo ""
echo -e "${BLUE}Package Information:${NC}"
echo "  Location: $ZIP_FILE"
echo "  Size: $SIZE_MB MB ($SIZE_BYTES bytes)"
echo "  SHA256: $SHA256"
echo ""
echo -e "${BLUE}Manifest:${NC}"
echo "  Location: $MANIFEST_FILE"
echo ""
echo -e "${BLUE}Contents:${NC}"
echo "  • 52+ services (all platform services)"
echo "  • 43 functional modules"
echo "  • Complete infrastructure (Docker, K8s, PM2)"
echo "  • Banking layer (PUABO BLAC)"
echo "  • Streaming services (Nexus Stream, OTT Mini)"
echo "  • All deployment scripts and manifests"
echo "  • 23-file THIIO handoff documentation"
echo ""
echo -e "${GREEN}Ready for THIIO deployment!${NC}"
echo ""
echo "To regenerate this ZIP, run:"
echo "  ./make_full_thiio_handoff.sh"
echo ""

exit 0

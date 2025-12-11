# Nexus COS Monorepo

## Overview

This is the complete Nexus COS platform monorepo containing all 43 services and 16 modules.

## Structure

```
nexus-cos-main/
├── apps/           # Frontend applications
├── services/       # Backend microservices (43 services)
├── modules/        # Platform modules (16 modules)
├── libs/           # Shared libraries
├── scripts/        # Build and deployment scripts
├── infra/          # Infrastructure as code
├── api/            # API definitions and contracts
├── package.json    # Root package configuration
└── pnpm-workspace.yaml  # Workspace configuration
```

## Quick Start

1. Install dependencies:
   ```bash
   pnpm install
   ```

2. Build all packages:
   ```bash
   pnpm build
   ```

3. Run in development:
   ```bash
   pnpm dev
   ```

4. Run tests:
   ```bash
   pnpm test
   ```

## Services (43)

See `docs/THIIO-HANDOFF/services/` for detailed service documentation.

## Modules (16)

See `docs/THIIO-HANDOFF/modules/` for detailed module documentation.

## Deployment

See `docs/THIIO-HANDOFF/deployment/` for deployment instructions.

## Development

### Prerequisites
- Node.js >= 18
- pnpm >= 8
- Docker
- Kubernetes (for deployment)

### Local Development
Each service can be developed independently:

```bash
cd services/auth-service
pnpm dev
```

### Building
```bash
# Build all
pnpm build

# Build specific service
pnpm --filter auth-service build
```

## Architecture

Refer to architecture documentation in `docs/THIIO-HANDOFF/architecture/`.

## License

Proprietary - Nexus COS Platform

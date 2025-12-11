#!/bin/bash

# Generate all THIIO handoff documentation files
# This script creates service descriptions, module descriptions, and operational docs

set -e

PROJECT_ROOT="/home/runner/work/nexus-cos/nexus-cos"
DOCS_DIR="$PROJECT_ROOT/docs/THIIO-HANDOFF"

echo "Generating THIIO handoff documentation..."

# Create service descriptions directory
mkdir -p "$DOCS_DIR/services"

# Generate service descriptions
declare -a services=(
    "ai-service:3031:General AI capabilities:Provides core AI and machine learning features"
    "auth-service:3001:Primary authentication:Handles user authentication and session management"
    "auth-service-v2:3002:Enhanced authentication:Modern OAuth 2.0 and JWT implementation"
    "backend-api:3000:API Gateway:Central API gateway routing requests to microservices"
    "billing-service:3020:Payment processing:Handles payments, subscriptions, and billing"
    "boom-boom-room-live:3070:Live entertainment:Live streaming platform for events"
    "content-management:3012:Content lifecycle:Manages content creation, storage, and distribution"
    "creator-hub-v2:3090:Creator platform:Platform for content creators"
    "glitch:3082:Error tracking:Error monitoring and tracking service"
    "invoice-gen:3021:Invoice generation:Generates and manages invoices"
    "kei-ai:3030:Core AI:Advanced AI processing and ML models"
    "key-service:3080:Key management:Cryptographic key management"
    "ledger-mgr:3022:Financial ledger:Manages financial transactions and ledger"
    "metatwin:3083:Digital twin:Digital twin technology platform"
    "nexus-cos-studio-ai:3032:Studio AI:AI features for studio operations"
    "puabo-blac-loan-processor:3050:Loan processing:Processes loan applications"
    "puabo-blac-risk-assessment:3051:Risk assessment:Assesses financial risk"
    "puabo-dsp-metadata-mgr:3014:Metadata management:Manages media metadata"
    "puabo-dsp-streaming-api:3013:DSP streaming:Digital service provider streaming API"
    "puabo-dsp-upload-mgr:3015:Upload orchestration:Manages file uploads"
    "puabo-nexus:3093:Nexus integration:Integration hub for services"
    "puabo-nexus-ai-dispatch:3034:AI dispatch:AI-powered dispatch system"
    "puabo-nexus-driver-app-backend:3060:Driver backend:Backend for driver application"
    "puabo-nexus-fleet-manager:3061:Fleet management:Manages delivery fleet"
    "puabo-nexus-route-optimizer:3062:Route optimization:Optimizes delivery routes"
    "puabo-nuki-inventory-mgr:3041:Inventory tracking:Manages product inventory"
    "puabo-nuki-order-processor:3042:Order processing:Processes customer orders"
    "puabo-nuki-product-catalog:3040:Product catalog:Manages product catalog"
    "puabo-nuki-shipping-service:3043:Shipping logistics:Handles shipping and logistics"
    "puaboai-sdk:3033:AI SDK:Software development kit for AI integration"
    "puabomusicchain:3091:Music blockchain:Blockchain for music industry"
    "puaboverse-v2:3092:Metaverse platform:Virtual world and metaverse platform"
    "pv-keys:3081:Private keys:Private key management"
    "scheduler:3023:Task scheduling:Schedules and orchestrates tasks"
    "session-mgr:3004:Session lifecycle:Manages user sessions"
    "streamcore:3011:Core streaming:Core streaming infrastructure"
    "streaming-service-v2:3010:Advanced streaming:Advanced video streaming service"
    "token-mgr:3005:Token operations:Manages authentication tokens"
    "user-auth:3003:User management:User authentication and management"
    "v-caster-pro:3072:Professional casting:Casting service for productions"
    "v-prompter-pro:3073:Teleprompter:Professional teleprompter service"
    "v-screen-pro:3074:Screen production:Screen and production services"
    "vscreen-hollywood:3071:Hollywood production:Hollywood-grade production tools"
)

for service_info in "${services[@]}"; do
    IFS=':' read -r name port purpose description <<< "$service_info"
    cat > "$DOCS_DIR/services/$name.md" << EOF
# $name

## Overview

**Service Name**: $name
**Port**: $port
**Purpose**: $purpose

## Description

$description

## Endpoints

### Health Check
- \`GET /health\` - Service health status
- \`GET /health/ready\` - Readiness probe
- \`GET /health/live\` - Liveness probe

### Metrics
- \`GET /metrics\` - Prometheus metrics

## Configuration

### Environment Variables
- \`PORT\` - Service port (default: $port)
- \`DATABASE_URL\` - Database connection string
- \`REDIS_URL\` - Redis connection string
- \`LOG_LEVEL\` - Logging level (debug, info, warn, error)

### Resource Requirements
- **CPU**: Varies by load
- **Memory**: See deployment manifest
- **Storage**: Depends on data volume

## Dependencies

### Internal Services
- Depends on specific services per architecture

### External Dependencies
- PostgreSQL database
- Redis cache
- Message queue (RabbitMQ)

## API Documentation

Detailed API documentation available via OpenAPI/Swagger at \`/api-docs\`

## Deployment

Deploy using Kubernetes manifests in \`docs/THIIO-HANDOFF/deployment/kubernetes/\`

## Monitoring

- Prometheus metrics exposed on \`/metrics\`
- Logs sent to centralized logging system
- Health checks configured for K8s

## Security

- JWT-based authentication
- TLS encryption in transit
- Secrets managed via Kubernetes secrets

## Troubleshooting

### Common Issues
1. **Connection errors**: Check database and Redis connectivity
2. **Performance issues**: Review resource allocation
3. **Authentication failures**: Verify JWT secret configuration

### Logs
Access logs via:
\`\`\`bash
kubectl logs -n <namespace> deployment/$name
\`\`\`

## Contact

For support, refer to operational runbooks in \`docs/THIIO-HANDOFF/operations/\`
EOF
done

echo "✓ Generated $(echo "${#services[@]}") service descriptions"

# Generate module descriptions
mkdir -p "$DOCS_DIR/modules"

declare -a modules=(
    "casino-nexus:Gaming platform:Provides casino and gaming functionality"
    "club-saditty:Social club:Social club and community features"
    "core-os:Operating system core:Core OS functionality"
    "gamecore:Game engine:Game engine integration and features"
    "musicchain:Music blockchain:Blockchain for music industry"
    "nexus-studio-ai:Studio AI:AI capabilities for studio operations"
    "puabo-blac:BLAC platform:Banking, lending, and credit platform"
    "puabo-dsp:Digital service provider:DSP infrastructure and features"
    "puabo-nexus:Nexus module:Core Nexus integration module"
    "puabo-nuki-clothing:NUKI clothing:E-commerce clothing platform"
    "puabo-os-v200:Puabo OS:Operating system version 2.0"
    "puabo-ott-tv-streaming:OTT streaming:Over-the-top TV streaming"
    "puabo-studio:Studio module:Studio production features"
    "puaboverse:Puaboverse:Metaverse and virtual world platform"
    "streamcore:Stream core:Core streaming module"
    "v-suite:V-Suite:Professional video suite"
)

for module_info in "${modules[@]}"; do
    IFS=':' read -r name purpose description <<< "$module_info"
    cat > "$DOCS_DIR/modules/$name.md" << EOF
# $name Module

## Overview

**Module Name**: $name
**Purpose**: $purpose

## Description

$description

## Features

### Core Capabilities
- Modular architecture
- Extensible plugin system
- Integration with Nexus COS platform
- Event-driven communication

### Components
The module consists of multiple components working together to provide comprehensive functionality.

## Architecture

### Module Structure
\`\`\`
$name/
├── src/
│   ├── components/
│   ├── services/
│   ├── models/
│   └── utils/
├── config/
├── tests/
└── README.md
\`\`\`

## Integration

### Platform Integration
Integrates with Nexus COS platform via:
- Service mesh
- Event bus
- Shared data layer
- API gateway

### Dependencies
- Core platform services
- Shared libraries
- Module-specific dependencies

## Configuration

### Module Configuration
Configuration managed via:
- Environment variables
- Config files
- K8s ConfigMaps

### Required Settings
- Module-specific configuration
- Platform connection settings
- Feature flags

## Usage

### Installation
\`\`\`bash
npm install @nexus-cos/$name
\`\`\`

### Basic Usage
\`\`\`javascript
import { $name } from '@nexus-cos/$name';

// Initialize module
const module = new $name(config);
await module.initialize();
\`\`\`

## API Reference

Detailed API documentation available in module source code and typings.

## Development

### Setup Development Environment
\`\`\`bash
cd modules/$name
npm install
npm run dev
\`\`\`

### Testing
\`\`\`bash
npm test
npm run test:integration
\`\`\`

## Deployment

Deployed as part of the Nexus COS platform. See deployment documentation.

## Monitoring

- Module metrics exported to platform monitoring
- Custom dashboards available in Grafana
- Alerts configured for critical events

## Troubleshooting

### Common Issues
1. **Module initialization fails**: Check configuration
2. **Integration errors**: Verify platform connectivity
3. **Performance issues**: Review resource allocation

### Debug Mode
Enable debug logging:
\`\`\`bash
DEBUG=$name:* npm start
\`\`\`

## Maintenance

### Updates
Module updates follow semantic versioning and are coordinated with platform releases.

### Migration Guides
Migration documentation available for major version upgrades.

## Support

Refer to platform documentation and operational runbooks for support.
EOF
done

echo "✓ Generated $(echo "${#modules[@]}") module descriptions"

echo ""
echo "Documentation generation complete!"
echo "  - Service descriptions: $DOCS_DIR/services/"
echo "  - Module descriptions: $DOCS_DIR/modules/"

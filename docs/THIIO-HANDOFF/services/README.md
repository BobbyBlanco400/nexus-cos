# Services Index

## Overview

The Nexus COS platform consists of 43 microservices organized into functional domains. Each service is independently deployable, scalable, and maintainable.

## Service Categories

### Core Services (5)

Essential authentication and platform services:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| auth-service | 3001 | Primary authentication service | [auth-service.md](auth-service.md) |
| auth-service-v2 | 3002 | Enhanced authentication with OAuth 2.0 | [auth-service-v2.md](auth-service-v2.md) |
| user-auth | 3003 | User registration and management | [user-auth.md](user-auth.md) |
| session-mgr | 3004 | Session lifecycle management | [session-mgr.md](session-mgr.md) |
| token-mgr | 3005 | JWT token operations | [token-mgr.md](token-mgr.md) |

**Core Auth Service**: See [core-auth.md](core-auth.md) for integrated authentication flow.

### Streaming & Content Services (9)

Media streaming and content management:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| streaming-service-v2 | 3010 | Advanced video streaming | [streaming-service-v2.md](streaming-service-v2.md) |
| streamcore | 3011 | Core streaming engine | [streamcore.md](streamcore.md) |
| content-management | 3012 | Content lifecycle management | [content-management.md](content-management.md) |
| v-caster-pro | 3072 | Professional casting service | [v-caster-pro.md](v-caster-pro.md) |
| v-prompter-pro | 3073 | Teleprompter service | [v-prompter-pro.md](v-prompter-pro.md) |
| v-screen-pro | 3074 | Screen production service | [v-screen-pro.md](v-screen-pro.md) |
| boom-boom-room-live | 3070 | Live entertainment streaming | [boom-boom-room-live.md](boom-boom-room-live.md) |
| vscreen-hollywood | 3071 | Hollywood production tools | [vscreen-hollywood.md](vscreen-hollywood.md) |
| creator-hub-v2 | 3090 | Creator platform | [creator-hub-v2.md](creator-hub-v2.md) |

### Puabo DSP Services (3)

Digital Service Provider platform:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| puabo-dsp-streaming-api | 3013 | DSP streaming API | [puabo-dsp-streaming-api.md](puabo-dsp-streaming-api.md) |
| puabo-dsp-metadata-mgr | 3014 | Metadata management | [puabo-dsp-metadata-mgr.md](puabo-dsp-metadata-mgr.md) |
| puabo-dsp-upload-mgr | 3015 | Upload orchestration | [puabo-dsp-upload-mgr.md](puabo-dsp-upload-mgr.md) |

### E-Commerce Services (4)

Puabo NUKI clothing platform:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| puabo-nuki-product-catalog | 3040 | Product catalog | [puabo-nuki-product-catalog.md](puabo-nuki-product-catalog.md) |
| puabo-nuki-inventory-mgr | 3041 | Inventory tracking | [puabo-nuki-inventory-mgr.md](puabo-nuki-inventory-mgr.md) |
| puabo-nuki-order-processor | 3042 | Order processing | [puabo-nuki-order-processor.md](puabo-nuki-order-processor.md) |
| puabo-nuki-shipping-service | 3043 | Shipping logistics | [puabo-nuki-shipping-service.md](puabo-nuki-shipping-service.md) |

### Financial Services (2)

Puabo BLAC lending platform:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| puabo-blac-loan-processor | 3050 | Loan processing | [puabo-blac-loan-processor.md](puabo-blac-loan-processor.md) |
| puabo-blac-risk-assessment | 3051 | Risk assessment | [puabo-blac-risk-assessment.md](puabo-blac-risk-assessment.md) |

### Logistics Services (4)

Puabo Nexus ride-sharing and delivery:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| puabo-nexus | 3093 | Main Nexus service | [puabo-nexus.md](puabo-nexus.md) |
| puabo-nexus-driver-app-backend | 3060 | Driver app backend | [puabo-nexus-driver-app-backend.md](puabo-nexus-driver-app-backend.md) |
| puabo-nexus-fleet-manager | 3061 | Fleet management | [puabo-nexus-fleet-manager.md](puabo-nexus-fleet-manager.md) |
| puabo-nexus-route-optimizer | 3062 | Route optimization | [puabo-nexus-route-optimizer.md](puabo-nexus-route-optimizer.md) |

### AI Services (5)

Artificial intelligence and machine learning:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| ai-service | 3031 | General AI service | [ai-service.md](ai-service.md) |
| kei-ai | 3030 | Core AI engine | [kei-ai.md](kei-ai.md) |
| nexus-cos-studio-ai | 3032 | Studio AI tools | [nexus-cos-studio-ai.md](nexus-cos-studio-ai.md) |
| puaboai-sdk | 3033 | AI SDK service | [puaboai-sdk.md](puaboai-sdk.md) |
| puabo-nexus-ai-dispatch | 3034 | AI dispatch service | [puabo-nexus-ai-dispatch.md](puabo-nexus-ai-dispatch.md) |

### Platform Services (6)

Core platform utilities:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| backend-api | 3000 | Main API gateway | [backend-api.md](backend-api.md) |
| billing-service | 3020 | Payment processing | [billing-service.md](billing-service.md) |
| invoice-gen | 3021 | Invoice generation | [invoice-gen.md](invoice-gen.md) |
| ledger-mgr | 3022 | Financial ledger | [ledger-mgr.md](ledger-mgr.md) |
| scheduler | 3023 | Task scheduling | [scheduler.md](scheduler.md) |
| key-service | 3080 | Key management | [key-service.md](key-service.md) |

### Supporting Services (5)

Additional platform services:

| Service | Port | Description | Documentation |
|---------|------|-------------|---------------|
| pv-keys | 3081 | Private key management | [pv-keys.md](pv-keys.md) |
| glitch | 3082 | Error tracking | [glitch.md](glitch.md) |
| metatwin | 3083 | Digital twin service | [metatwin.md](metatwin.md) |
| puabomusicchain | 3091 | Music blockchain | [puabomusicchain.md](puabomusicchain.md) |
| puaboverse-v2 | 3092 | Metaverse platform | [puaboverse-v2.md](puaboverse-v2.md) |

## Service Architecture Patterns

### Communication Patterns

1. **Synchronous (REST/HTTP)**
   - Request-response for real-time operations
   - Used by most services for direct communication
   - API gateway routes external requests

2. **Asynchronous (Event-Driven)**
   - Message queues for background processing
   - Pub/Sub for system-wide notifications
   - Event sourcing for audit trails

3. **Streaming (WebSocket)**
   - Real-time data updates
   - Live content streaming
   - Chat and notifications

### Service Discovery

Services register with Kubernetes service discovery:
- DNS-based service discovery
- Environment-based configuration
- Health check registration

### Load Balancing

- Round-robin distribution by default
- Session affinity where needed
- Health-based routing
- Auto-scaling based on load

## Service Dependencies

### Critical Paths

1. **Authentication Flow**:
   ```
   Client → backend-api → auth-service → user-auth → session-mgr → token-mgr
   ```

2. **Content Delivery**:
   ```
   Client → backend-api → content-management → streamcore → CDN
   ```

3. **Payment Processing**:
   ```
   Client → backend-api → billing-service → invoice-gen → ledger-mgr
   ```

## Deployment Order

For initial deployment or full restart:

1. **Infrastructure**: Databases, Redis, message queues
2. **Core Services**: auth-service, token-mgr, key-service
3. **Platform Services**: backend-api, billing-service, scheduler
4. **Business Services**: All domain-specific services
5. **Frontend**: Web and mobile applications

## Service Health

All services implement standard health endpoints:
- `GET /health` - Basic health check
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe
- `GET /metrics` - Prometheus metrics

## Service Template

For creating new services, see [service-template.md](service-template.md).

## Common Operations

### Scaling a Service

```bash
# Scale horizontally
kubectl scale deployment/<service-name> --replicas=5 -n nexus-cos

# Auto-scaling
kubectl autoscale deployment/<service-name> \
  --min=2 --max=10 --cpu-percent=70 -n nexus-cos
```

### Viewing Logs

```bash
# Recent logs
kubectl logs -n nexus-cos <pod-name> --tail=100

# Follow logs
kubectl logs -n nexus-cos <pod-name> -f

# All pods for a service
kubectl logs -n nexus-cos -l app=<service-name> --tail=100
```

### Restarting a Service

```bash
# Rolling restart
kubectl rollout restart deployment/<service-name> -n nexus-cos

# Force restart
kubectl delete pod -n nexus-cos -l app=<service-name>
```

## Service Ownership

### Teams

- **Core Platform**: auth-service, backend-api, key-service
- **Media Team**: All streaming and content services
- **Commerce Team**: NUKI e-commerce services
- **FinTech Team**: BLAC financial services
- **Logistics Team**: Nexus delivery services
- **AI/ML Team**: All AI services

## Support

For service-specific questions:
- **General**: owner+services@nexuscos.example.com
- **Platform**: owner+platform@nexuscos.example.com
- **On-Call**: owner+oncall@nexuscos.example.com

## Additional Resources

- [Architecture Overview](../architecture/system-overview.md)
- [Service Map](../architecture/service-map.md)
- [Operations Runbooks](../operations/)
- [Deployment Guide](../deployment/)

---

**Total Services**: 43  
**Last Updated**: December 2025  
**Status**: Production Ready

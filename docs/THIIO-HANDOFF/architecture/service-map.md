# Nexus COS Service Map

## Service Inventory (43 Services)

### Authentication & Authorization Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| auth-service | 3001 | Primary authentication | user-auth, session-mgr, token-mgr |
| auth-service-v2 | 3002 | Enhanced authentication | auth-service, token-mgr |
| user-auth | 3003 | User management | Database, session-mgr |
| session-mgr | 3004 | Session lifecycle | Redis, token-mgr |
| token-mgr | 3005 | Token operations | Redis, key-service |

### Content & Streaming Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| streaming-service-v2 | 3010 | Advanced streaming | streamcore, content-management |
| streamcore | 3011 | Core streaming | Database, CDN |
| content-management | 3012 | Content lifecycle | Database, storage |
| puabo-dsp-streaming-api | 3013 | DSP streaming | streamcore |
| puabo-dsp-metadata-mgr | 3014 | Metadata management | Database |
| puabo-dsp-upload-mgr | 3015 | Upload orchestration | storage, content-management |

### Business Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| billing-service | 3020 | Payment processing | Database, invoice-gen |
| invoice-gen | 3021 | Invoice generation | billing-service, ledger-mgr |
| ledger-mgr | 3022 | Financial ledger | Database |
| scheduler | 3023 | Task scheduling | Database, Redis |

### AI Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| kei-ai | 3030 | Core AI | ai-service |
| ai-service | 3031 | General AI | ML models |
| nexus-cos-studio-ai | 3032 | Studio AI | kei-ai |
| puaboai-sdk | 3033 | AI SDK | ai-service |
| puabo-nexus-ai-dispatch | 3034 | AI dispatch | kei-ai, scheduler |

### E-Commerce Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| puabo-nuki-product-catalog | 3040 | Product catalog | Database |
| puabo-nuki-inventory-mgr | 3041 | Inventory tracking | Database, Redis |
| puabo-nuki-order-processor | 3042 | Order processing | billing-service, inventory-mgr |
| puabo-nuki-shipping-service | 3043 | Shipping logistics | order-processor, route-optimizer |

### Financial Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| puabo-blac-loan-processor | 3050 | Loan processing | risk-assessment, billing-service |
| puabo-blac-risk-assessment | 3051 | Risk assessment | ai-service, ledger-mgr |

### Logistics Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| puabo-nexus-driver-app-backend | 3060 | Driver backend | fleet-manager, route-optimizer |
| puabo-nexus-fleet-manager | 3061 | Fleet management | Database, scheduler |
| puabo-nexus-route-optimizer | 3062 | Route optimization | ai-service, maps API |

### Entertainment Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| boom-boom-room-live | 3070 | Live entertainment | streaming-service-v2 |
| vscreen-hollywood | 3071 | Hollywood production | content-management |
| v-caster-pro | 3072 | Professional casting | Database |
| v-prompter-pro | 3073 | Teleprompter | streaming-service-v2 |
| v-screen-pro | 3074 | Screen production | content-management |

### Platform Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| backend-api | 3000 | API gateway | All services |
| key-service | 3080 | Key management | Database, Redis |
| pv-keys | 3081 | Private keys | key-service |
| glitch | 3082 | Error tracking | Database, monitoring |
| metatwin | 3083 | Digital twin | ai-service, Database |

### Specialized Services

| Service | Port | Purpose | Dependencies |
|---------|------|---------|--------------|
| creator-hub-v2 | 3090 | Creator platform | content-management, billing-service |
| puabomusicchain | 3091 | Music blockchain | blockchain, ledger-mgr |
| puaboverse-v2 | 3092 | Metaverse platform | streaming-service-v2, ai-service |
| puabo-nexus | 3093 | Nexus integration | Multiple services |

## Service Communication Patterns

### Synchronous Communication
- REST API calls for real-time operations
- Direct HTTP/HTTPS communication
- Request-response pattern

### Asynchronous Communication
- Event bus for decoupled messaging
- Message queues for background processing
- Pub/Sub pattern for notifications

## Service Discovery

Services register with the service registry on startup and discover other services dynamically:

```yaml
Service Registration Flow:
1. Service starts
2. Registers with service registry
3. Publishes availability
4. Begins health check heartbeat
5. Ready to receive requests
```

## Load Balancing

- Round-robin distribution
- Health-based routing
- Sticky sessions where needed
- Auto-scaling thresholds

## Network Architecture

```
Internet
    ↓
[Load Balancer]
    ↓
[API Gateway - backend-api:3000]
    ↓
[Service Mesh]
    ↓
[Microservices Layer]
    ↓
[Data Layer]
```

## Service Grouping by Domain

1. **Identity Domain**: auth-service, auth-service-v2, user-auth, session-mgr, token-mgr
2. **Media Domain**: streaming-service-v2, streamcore, content-management, DSP services
3. **Commerce Domain**: NUKI services, billing-service, invoice-gen
4. **Finance Domain**: BLAC services, ledger-mgr
5. **Logistics Domain**: Nexus delivery services
6. **Entertainment Domain**: V-Suite services, Boom Boom Room
7. **Intelligence Domain**: AI services, metatwin
8. **Platform Domain**: backend-api, key services, glitch

## Inter-Service Dependencies

Critical dependency chains:
- Authentication flow: backend-api → auth-service → user-auth → session-mgr → token-mgr
- Content delivery: backend-api → content-management → streamcore → CDN
- Order processing: backend-api → order-processor → inventory-mgr → billing-service → invoice-gen

## Service Health Monitoring

Each service exposes:
- `/health` - Basic health check
- `/health/ready` - Readiness probe
- `/health/live` - Liveness probe
- `/metrics` - Prometheus metrics

## Deployment Groups

Services are deployed in the following order:
1. **Foundation**: Database, Redis, Message Queue
2. **Core Services**: auth-service, key-service, backend-api
3. **Business Logic**: All domain services
4. **Frontend**: UI applications

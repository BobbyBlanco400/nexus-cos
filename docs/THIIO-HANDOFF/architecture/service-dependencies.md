# Service Dependencies

## Dependency Graph

This document outlines the dependency relationships between all 43 services in the Nexus COS platform.

## Core Dependencies

### Foundation Layer (No Dependencies)
These services have minimal external dependencies:

- **Database Service**: PostgreSQL cluster
- **Redis Service**: In-memory cache and session store
- **Message Queue**: Event bus infrastructure

### Authentication Layer

```
auth-service
├── user-auth
│   ├── Database
│   └── session-mgr
│       ├── Redis
│       └── token-mgr
│           ├── Redis
│           └── key-service
│               └── Database
└── auth-service-v2
    ├── auth-service
    └── token-mgr
```

### API Gateway Layer

```
backend-api
├── All downstream services
├── Auth services
└── Load balancer
```

### Content & Streaming

```
streaming-service-v2
├── streamcore
│   ├── Database
│   └── CDN
├── content-management
│   ├── Database
│   └── Storage service
└── session-mgr

puabo-dsp-streaming-api
├── streamcore
└── puabo-dsp-metadata-mgr
    └── Database

puabo-dsp-upload-mgr
├── Storage service
├── content-management
└── puabo-dsp-metadata-mgr
```

### Business Services

```
billing-service
├── Database
├── Payment gateway (external)
├── invoice-gen
│   ├── Database
│   └── ledger-mgr
│       └── Database
└── auth-service

scheduler
├── Database
├── Redis
└── Message queue
```

### AI Services

```
kei-ai
├── ai-service
│   ├── ML models
│   └── GPU resources
└── Database

nexus-cos-studio-ai
├── kei-ai
└── content-management

puaboai-sdk
└── ai-service

puabo-nexus-ai-dispatch
├── kei-ai
├── scheduler
└── puabo-nexus-fleet-manager
```

### E-Commerce Services

```
puabo-nuki-order-processor
├── puabo-nuki-product-catalog
│   └── Database
├── puabo-nuki-inventory-mgr
│   ├── Database
│   └── Redis
├── billing-service
└── puabo-nuki-shipping-service
    ├── puabo-nexus-route-optimizer
    └── External shipping APIs
```

### Financial Services

```
puabo-blac-loan-processor
├── puabo-blac-risk-assessment
│   ├── ai-service
│   ├── ledger-mgr
│   └── External credit APIs
├── billing-service
└── Database

ledger-mgr
├── Database
└── Blockchain service
```

### Logistics Services

```
puabo-nexus-fleet-manager
├── Database
├── scheduler
└── Redis

puabo-nexus-driver-app-backend
├── puabo-nexus-fleet-manager
├── puabo-nexus-route-optimizer
│   ├── ai-service
│   ├── Maps API (external)
│   └── Traffic data API
├── session-mgr
└── Database
```

### Entertainment Services

```
boom-boom-room-live
├── streaming-service-v2
├── content-management
└── user-auth

vscreen-hollywood
├── content-management
├── billing-service
└── creator-hub-v2

v-caster-pro
├── Database
└── content-management

v-prompter-pro
├── streaming-service-v2
└── Database

v-screen-pro
├── content-management
└── streaming-service-v2
```

### Platform Services

```
key-service
├── Database
└── Redis

pv-keys
├── key-service
└── Hardware Security Module (HSM)

glitch
├── Database
├── Monitoring stack
└── Alert system

metatwin
├── ai-service
├── Database
└── streamcore
```

### Specialized Services

```
creator-hub-v2
├── content-management
├── billing-service
├── user-auth
└── streaming-service-v2

puabomusicchain
├── Blockchain network
├── ledger-mgr
├── content-management
└── billing-service

puaboverse-v2
├── streaming-service-v2
├── ai-service
├── content-management
└── metatwin

puabo-nexus
├── Multiple services (integration hub)
├── auth-service
├── backend-api
└── Database
```

## Critical Path Dependencies

### User Authentication Flow
1. backend-api → 2. auth-service → 3. user-auth → 4. Database
5. session-mgr → 6. token-mgr → 7. Redis

### Content Upload Flow
1. backend-api → 2. puabo-dsp-upload-mgr → 3. content-management
4. Storage service → 5. puabo-dsp-metadata-mgr → 6. Database

### Order Processing Flow
1. backend-api → 2. puabo-nuki-order-processor
3. puabo-nuki-inventory-mgr → 4. billing-service
5. invoice-gen → 6. ledger-mgr → 7. Database

### Streaming Flow
1. backend-api → 2. streaming-service-v2 → 3. streamcore
4. content-management → 5. CDN → 6. End user

## External Dependencies

### Third-Party Services
- **Payment Processors**: Stripe, PayPal
- **Cloud Storage**: AWS S3, Azure Blob
- **CDN**: CloudFlare, AWS CloudFront
- **Maps & Routing**: Google Maps API, Mapbox
- **Email**: SendGrid, AWS SES
- **SMS**: Twilio
- **Blockchain**: Ethereum, Polygon

### Infrastructure Dependencies
- **Container Registry**: Docker Hub, AWS ECR
- **DNS**: CloudFlare, Route53
- **SSL Certificates**: Let's Encrypt
- **Monitoring**: Prometheus, Grafana
- **Logging**: ELK Stack

## Dependency Management

### Version Pinning
All dependencies are version-pinned to ensure reproducible builds:
```json
{
  "dependencies": {
    "express": "4.18.2",
    "mongoose": "7.0.3",
    // etc.
  }
}
```

### Health Check Dependencies

Each service verifies its dependencies during startup:
1. Database connectivity
2. Redis availability
3. External API accessibility
4. Required environment variables

### Failure Modes

#### Graceful Degradation
Services implement fallback behavior when non-critical dependencies fail:
- Cache miss → Fetch from database
- AI service down → Use rule-based system
- CDN unavailable → Serve from origin

#### Circuit Breakers
Prevent cascade failures:
- Open after 5 consecutive failures
- Half-open state after 30 seconds
- Close after 3 successful requests

## Startup Sequence

Recommended service startup order:

1. **Infrastructure** (0-30s)
   - PostgreSQL
   - Redis
   - Message Queue

2. **Core Services** (30-60s)
   - key-service
   - auth-service
   - session-mgr
   - token-mgr

3. **Platform Services** (60-90s)
   - backend-api
   - glitch
   - scheduler

4. **Domain Services** (90-120s)
   - All business logic services in parallel

5. **Frontend** (120-150s)
   - Web applications
   - Mobile backends

## Dependency Updates

### Update Strategy
- Monitor security advisories
- Test in development environment
- Stage rollout across services
- Automated rollback on failure

### Breaking Changes
- Maintain backward compatibility
- Version API endpoints
- Deprecation notices (90 days minimum)
- Migration guides for consumers

## Service Isolation

Services are isolated to minimize dependencies:
- Database per service pattern
- Separate Redis namespaces
- Independent deployment cycles
- Isolated failure domains

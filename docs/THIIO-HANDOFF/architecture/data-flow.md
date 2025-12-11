# Data Flow Architecture

## Overview

This document describes how data flows through the Nexus COS platform across all 43 services.

## Primary Data Flows

### 1. User Authentication Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /auth/login
     ▼
┌─────────────────┐
│  backend-api    │
│  (API Gateway)  │
└────┬────────────┘
     │
     ▼
┌─────────────────┐         ┌──────────────┐
│  auth-service   │────────▶│  user-auth   │
└────┬────────────┘         └──────┬───────┘
     │                             │
     │                             ▼
     │                      ┌──────────────┐
     │                      │  Database    │
     │                      │  (Users)     │
     │                      └──────────────┘
     ▼
┌─────────────────┐
│  session-mgr    │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  token-mgr      │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  Redis          │
│  (Sessions)     │
└─────────────────┘
     │
     │ JWT Token
     ▼
┌──────────┐
│  Client  │
└──────────┘
```

### 2. Content Upload Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /upload (multipart)
     ▼
┌──────────────────────┐
│  backend-api         │
└────┬─────────────────┘
     │
     ▼
┌──────────────────────────┐
│  puabo-dsp-upload-mgr    │
└────┬─────────────────────┘
     │
     ├───────────────────────┐
     │                       │
     ▼                       ▼
┌─────────────────┐   ┌──────────────────────┐
│  Storage        │   │  content-management  │
│  (S3/Azure)     │   └──────┬───────────────┘
└─────────────────┘          │
                             ▼
                      ┌──────────────────────────┐
                      │  puabo-dsp-metadata-mgr  │
                      └──────┬───────────────────┘
                             │
                             ▼
                      ┌──────────────┐
                      │  Database    │
                      │  (Metadata)  │
                      └──────────────┘
                             │
                             │ Success
                             ▼
                      ┌──────────┐
                      │  Client  │
                      └──────────┘
```

### 3. Video Streaming Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ GET /stream/{id}
     ▼
┌──────────────────────┐
│  backend-api         │
└────┬─────────────────┘
     │
     ▼
┌──────────────────────────┐
│  streaming-service-v2    │
└────┬─────────────────────┘
     │
     ▼
┌─────────────────┐
│  streamcore     │
└────┬────────────┘
     │
     ├─────────────────┐
     │                 │
     ▼                 ▼
┌──────────────┐  ┌─────────────────────┐
│  Database    │  │  content-management │
│  (Metadata)  │  └─────┬───────────────┘
└──────────────┘        │
                        ▼
                 ┌─────────────┐
                 │  CDN        │
                 └─────┬───────┘
                       │ HLS/DASH Stream
                       ▼
                 ┌──────────┐
                 │  Client  │
                 └──────────┘
```

### 4. E-Commerce Order Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /orders
     ▼
┌──────────────────────┐
│  backend-api         │
└────┬─────────────────┘
     │
     ▼
┌────────────────────────────────┐
│  puabo-nuki-order-processor    │
└────┬───────────────────────────┘
     │
     ├──────────────┬─────────────────┬──────────────┐
     │              │                 │              │
     ▼              ▼                 ▼              ▼
┌──────────┐  ┌──────────┐  ┌────────────────┐  ┌──────────┐
│ Product  │  │Inventory │  │ billing-service│  │ Database │
│ Catalog  │  │ Manager  │  └────┬───────────┘  │ (Orders) │
└──────────┘  └────┬─────┘       │              └──────────┘
                   │              ▼
                   │         ┌──────────┐
                   │         │invoice-  │
                   │         │gen       │
                   │         └────┬─────┘
                   │              │
                   │              ▼
                   │         ┌──────────┐
                   │         │ledger-   │
                   │         │mgr       │
                   │         └──────────┘
                   │
                   ▼
            ┌─────────────┐
            │ shipping-   │
            │ service     │
            └─────┬───────┘
                  │
                  ▼
            ┌─────────────┐
            │ route-      │
            │ optimizer   │
            └─────────────┘
                  │
                  │ Confirmation
                  ▼
            ┌──────────┐
            │  Client  │
            └──────────┘
```

### 5. AI Processing Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /ai/process
     ▼
┌──────────────────────┐
│  backend-api         │
└────┬─────────────────┘
     │
     ▼
┌─────────────────┐
│  kei-ai         │
└────┬────────────┘
     │
     ▼
┌─────────────────┐
│  ai-service     │
└────┬────────────┘
     │
     ├─────────────────┬──────────────┐
     │                 │              │
     ▼                 ▼              ▼
┌──────────┐    ┌──────────┐   ┌──────────┐
│ ML Model │    │ Database │   │  Cache   │
│ (GPU)    │    │ (History)│   │ (Results)│
└────┬─────┘    └──────────┘   └──────────┘
     │
     │ Result
     ▼
┌──────────┐
│  Client  │
└──────────┘
```

### 6. Live Streaming (Boom Boom Room) Flow

```
┌──────────┐
│ Streamer │
└────┬─────┘
     │ RTMP Push
     ▼
┌──────────────────────────┐
│  boom-boom-room-live     │
└────┬─────────────────────┘
     │
     ▼
┌──────────────────────────┐
│  streaming-service-v2    │
└────┬─────────────────────┘
     │
     ├──────────────┬────────────────┐
     │              │                │
     ▼              ▼                ▼
┌──────────┐  ┌──────────┐    ┌──────────┐
│transcoder│  │streamcore│    │ Database │
│          │  │          │    │(Metadata)│
└────┬─────┘  └────┬─────┘    └──────────┘
     │             │
     │             ▼
     │        ┌──────────┐
     │        │   CDN    │
     │        └────┬─────┘
     │             │
     └─────────────┤ HLS Stream
                   ▼
             ┌──────────┐
             │ Viewers  │
             └──────────┘
```

### 7. Logistics & Delivery Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /delivery/request
     ▼
┌──────────────────────────────────┐
│  puabo-nexus-driver-app-backend  │
└────┬─────────────────────────────┘
     │
     ▼
┌──────────────────────────┐
│  puabo-nexus-ai-dispatch │
└────┬─────────────────────┘
     │
     ├────────────────┬──────────────────┐
     │                │                  │
     ▼                ▼                  ▼
┌──────────┐   ┌──────────────┐   ┌─────────────┐
│fleet-    │   │route-        │   │  Database   │
│manager   │   │optimizer     │   │  (Deliveries│
└────┬─────┘   └──────┬───────┘   └─────────────┘
     │                │
     │                ▼
     │         ┌─────────────┐
     │         │   kei-ai    │
     │         └─────────────┘
     │
     │ Driver Assignment
     ▼
┌──────────┐
│  Driver  │
└──────────┘
```

### 8. Financial Transaction Flow

```
┌──────────┐
│  Client  │
└────┬─────┘
     │ POST /loan/apply
     ▼
┌──────────────────────────────────┐
│  puabo-blac-loan-processor       │
└────┬─────────────────────────────┘
     │
     ▼
┌──────────────────────────────────┐
│  puabo-blac-risk-assessment      │
└────┬─────────────────────────────┘
     │
     ├────────────────┬──────────────────┐
     │                │                  │
     ▼                ▼                  ▼
┌──────────┐   ┌──────────────┐   ┌─────────────┐
│ai-service│   │ledger-mgr    │   │  External   │
│          │   │              │   │  Credit API │
└────┬─────┘   └──────┬───────┘   └─────────────┘
     │                │
     │                ▼
     │         ┌─────────────┐
     │         │  Database   │
     │         │  (Ledger)   │
     │         └─────────────┘
     │
     │ Approved
     ▼
┌──────────────────┐
│ billing-service  │
└────┬─────────────┘
     │
     │ Confirmation
     ▼
┌──────────┐
│  Client  │
└──────────┘
```

## Event-Driven Data Flow

### Event Bus Architecture

```
┌────────────┐     ┌────────────┐     ┌────────────┐
│ Service A  │────▶│ Event Bus  │◀────│ Service B  │
└────────────┘     └─────┬──────┘     └────────────┘
                         │
                         ├───────────┐
                         ▼           ▼
                   ┌────────────┐ ┌────────────┐
                   │ Service C  │ │ Service D  │
                   └────────────┘ └────────────┘
```

### Key Events

- **UserCreated**: Published by user-auth, consumed by billing-service, notification-service
- **OrderPlaced**: Published by order-processor, consumed by inventory-mgr, shipping-service
- **ContentUploaded**: Published by upload-mgr, consumed by metadata-mgr, transcoder
- **PaymentProcessed**: Published by billing-service, consumed by ledger-mgr, invoice-gen
- **StreamStarted**: Published by streaming-service-v2, consumed by analytics, CDN
- **DeliveryAssigned**: Published by ai-dispatch, consumed by driver-app-backend, fleet-manager

## Data Storage Patterns

### Database Per Service
Each service maintains its own database schema:
- Ensures loose coupling
- Enables independent scaling
- Prevents cross-service dependencies

### Shared Cache Layer
Redis is used for:
- Session storage (session-mgr)
- Token cache (token-mgr)
- Rate limiting (backend-api)
- Real-time data (inventory-mgr)

### Event Sourcing
Selected services use event sourcing:
- ledger-mgr (financial audit trail)
- order-processor (order history)
- puabomusicchain (blockchain events)

## Data Consistency

### Eventual Consistency
Asynchronous operations accept eventual consistency:
- Analytics updates
- Notification delivery
- Cache invalidation

### Strong Consistency
Critical operations require strong consistency:
- Financial transactions
- Inventory updates
- Authentication

### Distributed Transactions
Saga pattern for multi-service transactions:
- Order placement (inventory + payment + shipping)
- Loan approval (risk + ledger + billing)

## Data Security

### Encryption
- At rest: AES-256
- In transit: TLS 1.3
- Sensitive fields: Field-level encryption

### Data Flow Controls
- API rate limiting
- Request validation
- Output sanitization
- PII redaction in logs

## Monitoring Data Flow

- Distributed tracing (OpenTelemetry)
- Request correlation IDs
- Performance metrics
- Error tracking (glitch service)

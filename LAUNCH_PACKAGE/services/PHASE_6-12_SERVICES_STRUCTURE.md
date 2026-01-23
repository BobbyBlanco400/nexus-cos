# Phase 6-12 Services Structure

This document describes the complete Phase 6-12 service architecture with N3XUS Handshake enforcement.

## Service Inventory

### Node.js Services (Express + N3XUS Handshake)
1. **Federation Spine** (Phase 6)
   - Framework: Node.js + Express
   - Port: 3000
   - Structure: Dockerfile, package.json, index.js

2. **Casino Core** (Phase 8)
   - Framework: Node.js + Express
   - Port: 3000
   - Structure: Dockerfile, package.json, index.js

3. **PMMG Media Engine** (Phase 11)
   - Framework: Node.js + Express
   - Port: 3000
   - Structure: Dockerfile, package.json, index.js

### FastAPI Services (Python + N3XUS Handshake)
1. **Identity Registry** (Phase 6)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

2. **Ledger Engine** (Phase 6)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

3. **Wallet Engine** (Phase 7)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

4. **Treasury Core** (Phase 7)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

5. **Payout Engine** (Phase 8)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

6. **Earnings Oracle** (Phase 9)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

7. **Royalty Engine** (Phase 10)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

8. **Federation Gateway** (Phase 10)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

9. **Attestation Service** (Phase 11)
   - Framework: Python FastAPI
   - Port: 3000
   - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

10. **Governance Core** (Phase 11)
    - Framework: Python FastAPI
    - Port: 3000
    - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

11. **Constitution Engine** (Phase 12)
    - Framework: Python FastAPI
    - Port: 3000
    - Structure: Dockerfile, requirements.txt, app/__init__.py, app/main.py

## Directory Structure

```
services/
├── federation-spine/
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
├── identity-registry/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── ledger-engine/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── casino-core/
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
├── wallet-engine/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── treasury-core/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── payout-engine/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── earnings-oracle/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── pmmg-media-engine/
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
├── royalty-engine/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── federation-gateway/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── attestation-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
├── governance-core/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── __init__.py
│       └── main.py
└── constitution-engine/
    ├── Dockerfile
    ├── requirements.txt
    └── app/
        ├── __init__.py
        └── main.py
```

## N3XUS Handshake Enforcement

All services enforce the N3XUS Handshake mechanism:

### Dockerfile Requirements
- **ARG**: `N3XUS_HANDSHAKE` argument required during build
- **ENV**: Sets environment variable from ARG
- **RUN**: Validates handshake code equals "55-45-17"
  - Fails immediately if code is incorrect
  - Produces error: "❌ N3XUS HANDSHAKE VIOLATION"

Example:
```dockerfile
ARG N3XUS_HANDSHAKE
ENV N3XUS_HANDSHAKE=${N3XUS_HANDSHAKE}
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; fi
```

### API Middleware Implementation

**Node.js (Express)**:
```javascript
app.use((req, res, next) => {
    if (req.path === '/health') return next();
    if (req.headers['x-n3xus-handshake'] !== '55-45-17') {
        return res.status(451).json({ error: 'N3XUS LAW VIOLATION' });
    }
    next();
});
```

**Python (FastAPI)**:
```python
@app.middleware("http")
async def nexus_handshake(request: Request, call_next):
    if request.url.path == "/health":
        return await call_next(request)
    if request.headers.get("X-N3XUS-Handshake") != "55-45-17":
        raise HTTPException(status_code=451, detail="N3XUS LAW VIOLATION")
    return await call_next(request)
```

## Health Check & Status Endpoints

Every service exposes two endpoints:

### /health
Returns: `{"status": "ok", "service": "<SERVICE_NAME>"}`
- Accessible without N3XUS Handshake header
- Used for load balancer health checks

### /
Returns: `{"service": "<SERVICE_NAME>", "phase": "<PHASE_NUMBER>"}`
- Requires X-N3XUS-Handshake: 55-45-17 header
- Returns phase information

## Build Command

To build any service with N3XUS Handshake enforcement:

```bash
docker build --build-arg N3XUS_HANDSHAKE="55-45-17" -t service-name:latest .
```

Building without the correct handshake will fail.

## Phase Distribution

- **Phase 6**: Federation Spine, Identity Registry, Ledger Engine
- **Phase 7**: Wallet Engine, Treasury Core
- **Phase 8**: Casino Core, Payout Engine
- **Phase 9**: Earnings Oracle
- **Phase 10**: Royalty Engine, Federation Gateway
- **Phase 11**: PMMG Media Engine, Attestation Service, Governance Core
- **Phase 12**: Constitution Engine

## Total Services Created

- 14 services (3 Node.js, 11 FastAPI)
- All with N3XUS Handshake enforcement
- All with health check endpoints
- All with standardized structure
- All ready for containerization

## Deployment Notes

1. Each service is independently deployable
2. Services can be orchestrated via Docker Compose
3. N3XUS Handshake validation occurs at build time
4. API handshake validation occurs at request time
5. Health endpoints are bypass endpoints for monitoring

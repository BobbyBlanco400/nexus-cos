# Nuisance Services - N3XUS v-COS

## Overview

The **Nuisance Services** are compliance-focused microservices that handle regulatory requirements, legal frameworks, and responsible gaming features. These services ensure N3XUS v-COS operates within legal boundaries while maintaining the sovereign stack architecture.

**N3XUS Handshake 55-45-17**: ENFORCED at build, runtime, and request layers.

---

## Services

### 1. Payment Partner (Port 4001)
**Stack**: Node.js + Express  
**Role**: Payment verification and method management

**Endpoints**:
- `GET /health` - Health check (no handshake)
- `GET /` - Service info (handshake required)
- `POST /api/v1/verify-payment` - Verify payment transaction
- `GET /api/v1/payment-methods` - List available payment methods

**Features**:
- Payment verification
- Multiple payment method support (credit, debit, crypto, wire)
- Transaction validation

---

### 2. Jurisdiction Rules (Port 4002)
**Stack**: Python 3.12 + Flask  
**Role**: Geographic and regulatory compliance

**Endpoints**:
- `GET /health` - Health check (no handshake)
- `GET /` - Service info (handshake required)
- `POST /api/v1/check-jurisdiction` - Check jurisdiction compliance
- `GET /api/v1/jurisdictions` - List supported jurisdictions

**Features**:
- Jurisdiction validation
- Regional compliance checks
- Age verification requirements
- KYC enforcement
- Geo-restriction management

---

### 3. Responsible Gaming (Port 4003)
**Stack**: Node.js + Express  
**Role**: Player protection and gaming limits

**Endpoints**:
- `GET /health` - Health check (no handshake)
- `GET /` - Service info (handshake required)
- `POST /api/v1/set-limits` - Set player gaming limits
- `POST /api/v1/self-exclude` - Self-exclusion management
- `GET /api/v1/gaming-activity/:userId` - Get player activity

**Features**:
- Daily/weekly/monthly limits
- Self-exclusion periods
- Activity monitoring
- Limit enforcement

---

### 4. Legal Entity (Port 4004)
**Stack**: Python 3.12 + Flask  
**Role**: Legal entity verification and compliance

**Endpoints**:
- `GET /health` - Health check (no handshake)
- `GET /` - Service info (handshake required)
- `POST /api/v1/verify-entity` - Verify legal entity
- `GET /api/v1/entities` - List legal entities
- `GET /api/v1/compliance-status` - Get compliance status

**Features**:
- Entity verification
- Licensing validation
- Regulatory filing status
- Insurance verification
- Multi-jurisdiction support

---

### 5. Explicit Opt-In (Port 4005)
**Stack**: Node.js + Express  
**Role**: Consent and opt-in management

**Endpoints**:
- `GET /health` - Health check (no handshake)
- `GET /` - Service info (handshake required)
- `POST /api/v1/record-consent` - Record user consent
- `GET /api/v1/consent-status/:userId` - Get consent status
- `POST /api/v1/withdraw-consent` - Withdraw consent
- `GET /api/v1/consent-types` - List consent types

**Features**:
- Terms of service consent
- Privacy policy agreement
- Marketing opt-in/out
- Data sharing consent
- Consent withdrawal tracking

---

## Deployment

### Quick Start

```bash
# Export handshake
export N3XUS_HANDSHAKE=55-45-17

# Bootstrap services
./scripts/bootstrap-nuisance.sh

# Launch services
./scripts/nuisance-launch.sh

# Verify deployment
./scripts/verify-nuisance.sh
```

### Docker Compose

**Codespaces deployment**:
```bash
export N3XUS_HANDSHAKE=55-45-17
docker compose -f docker-compose.codespaces.yml up -d \
  payment-partner \
  jurisdiction-rules \
  responsible-gaming \
  legal-entity \
  explicit-opt-in
```

**Full stack deployment**:
```bash
export N3XUS_HANDSHAKE=55-45-17
docker compose -f docker-compose.final.yml up -d
```

---

## N3XUS Handshake Enforcement

All nuisance services enforce the N3XUS Handshake at three layers:

### 1. Build Time (Dockerfile)
```dockerfile
ARG N3XUS_HANDSHAKE
RUN if [ "$N3XUS_HANDSHAKE" != "55-45-17" ]; then \
      echo "❌ N3XUS HANDSHAKE VIOLATION" && exit 1; \
    fi
```

### 2. Runtime (Startup)
```javascript
// Node.js
if (process.env.N3XUS_HANDSHAKE !== '55-45-17') {
    console.error('❌ N3XUS LAW VIOLATION');
    process.exit(1);
}
```

```python
# Python
if os.environ.get("N3XUS_HANDSHAKE") != "55-45-17":
    print("❌ N3XUS LAW VIOLATION", file=sys.stderr)
    sys.exit(1)
```

### 3. Request Level (Middleware)
All endpoints (except `/health`) require:
```
Header: X-N3XUS-Handshake: 55-45-17
```

**Invalid/missing handshake returns**: `451 Unavailable For Legal Reasons`

---

## Testing

### Health Checks
```bash
# Test all health endpoints
for port in 4001 4002 4003 4004 4005; do
  curl http://localhost:$port/health | jq
done
```

### Handshake Enforcement
```bash
# Valid handshake (should succeed)
curl -H "X-N3XUS-Handshake: 55-45-17" \
  http://localhost:4001/

# Invalid handshake (should fail with 451)
curl -H "X-N3XUS-Handshake: invalid" \
  http://localhost:4001/
```

### Service-Specific Tests

**Payment Partner**:
```bash
curl -X POST http://localhost:4001/api/v1/verify-payment \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "currency": "USD"}'
```

**Jurisdiction Rules**:
```bash
curl -X POST http://localhost:4002/api/v1/check-jurisdiction \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Content-Type: application/json" \
  -d '{"jurisdiction": "US"}'
```

**Responsible Gaming**:
```bash
curl -X POST http://localhost:4003/api/v1/set-limits \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Content-Type: application/json" \
  -d '{"userId": "user123", "limits": {"daily": 500}}'
```

**Legal Entity**:
```bash
curl -X POST http://localhost:4004/api/v1/verify-entity \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Content-Type: application/json" \
  -d '{"entity_id": "entity-001"}'
```

**Explicit Opt-In**:
```bash
curl -X POST http://localhost:4005/api/v1/record-consent \
  -H "X-N3XUS-Handshake: 55-45-17" \
  -H "Content-Type: application/json" \
  -d '{"userId": "user123", "consentType": "terms-of-service", "agreed": true}'
```

---

## Port Mapping

| Service | Port | Protocol |
|---------|------|----------|
| Payment Partner | 4001 | HTTP |
| Jurisdiction Rules | 4002 | HTTP |
| Responsible Gaming | 4003 | HTTP |
| Legal Entity | 4004 | HTTP |
| Explicit Opt-In | 4005 | HTTP |

---

## Security

- **Handshake Enforcement**: 3 layers (build, runtime, request)
- **Non-Root Execution**: All containers run as non-root
- **Health Check Exemption**: `/health` bypasses handshake for monitoring
- **HTTPS Ready**: Configure reverse proxy for production
- **Input Validation**: All endpoints validate input
- **Error Handling**: No sensitive data in error messages

---

## Dependencies

### Node.js Services (payment-partner, responsible-gaming, explicit-opt-in)
- express: ^4.18.2
- cors: ^2.8.5
- helmet: ^7.1.0

### Python Services (jurisdiction-rules, legal-entity)
- flask: 3.0.0
- werkzeug: 3.0.1

---

## Future Enhancements

### Phase 13+
- Database integration for persistent storage
- Event streaming for audit logs
- Advanced analytics and reporting
- Multi-tenancy support
- API rate limiting per jurisdiction
- Blockchain integration for immutable compliance records

---

## Compliance Features

### Implemented
- ✅ Payment verification
- ✅ Jurisdiction validation
- ✅ Responsible gaming limits
- ✅ Legal entity verification
- ✅ Explicit consent management

### Planned
- 📋 AML/KYC integration
- 📋 Age verification service
- 📋 Audit log service
- 📋 Regulatory reporting
- 📋 Cross-border compliance

---

## Troubleshooting

### Service won't start
```bash
# Check handshake environment variable
echo $N3XUS_HANDSHAKE

# Should output: 55-45-17
```

### Container exits immediately
```bash
# Check logs
docker logs <container-name>

# Look for: ❌ N3XUS LAW VIOLATION
```

### Health check fails
```bash
# Test directly
curl http://localhost:<port>/health

# Check container status
docker ps -a | grep <service-name>
```

---

## Support

For issues with nuisance services:
1. Run `./scripts/verify-nuisance.sh`
2. Check container logs: `docker logs <container-name>`
3. Verify handshake: `echo $N3XUS_HANDSHAKE`
4. Review service documentation above

---

**N3XUS v-COS Nuisance Services**  
**N3XUS LAW 55-45-17: ENFORCED EVERYWHERE**  
**Compliance-First | Sovereignty-Preserved**

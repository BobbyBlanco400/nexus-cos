# Nexus COS PUABO Core - Quick Deployment Guide

## 🚀 One-Command Launch

This guide will help you launch the complete Nexus COS PUABO Core platform stack in minutes.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 8GB RAM minimum
- 20GB free disk space

## Step 1: Navigate to PUABO Core

```bash
cd nexus-cos/puabo-core
```

## Step 2: Launch the Complete Stack

```bash
# Start all services (Fineract, PostgreSQL, Redis, PUABO Core Adapter, Smart Contracts)
docker compose -f docker-compose.core.yml up -d --build
```

This will start:
- **PostgreSQL** (port 5434) - Database for Fineract
- **Apache Fineract** (port 8880) - Core banking system
- **Redis** (port 6379) - Event bus for smart contracts
- **PUABO Core Adapter** (port 7777) - Main API service
- **Smart Contracts Engine** - Automated loan processing

## Step 3: Wait for Services to Start

```bash
# Wait 30-60 seconds for all services to initialize
sleep 60

# Check if services are healthy
docker compose -f docker-compose.core.yml ps
```

## Step 4: Verify API is Running

```bash
# Test the health endpoint
curl http://localhost:7777/health

# Expected response:
# {"status":"healthy","service":"puabo-core-adapter","timestamp":"..."}
```

## Step 5: Initialize Products

```bash
# Initialize PUABO banking products (BLAC Personal, SBL, Nexus Fleet)
chmod +x scripts/init-products.sh
./scripts/init-products.sh
```

This creates three product configurations:
- **BLAC Personal Loan** - Up to $50,000
- **BLAC SBL Loan** - Up to $100,000
- **Nexus Fleet Loan** - Up to $250,000

## Step 6: Seed Mock Data

```bash
# Install dependencies for scripts (if not already installed)
cd scripts
npm install axios uuid

# Seed test customers, accounts, and loans
node seed-mock-data.js
```

Expected output:
```
📋 Seeding mock customers...
✓ Created customer: <uuid> (John Doe)
✓ Created customer: <uuid> (Jane Smith)
...
💰 Seeding mock accounts...
✓ Created account: <uuid> (personal)
...
🏦 Seeding mock loans...
✓ Created personal loan: <uuid> ($2500)
...
✅ Mock data seeding complete!
```

## Step 7: Run API Tests

```bash
# Run comprehensive API tests
node test-api.js
```

Expected output:
```
Test 1: Health Check
✓ PASS - Health check successful

Test 2: Create Customer
✓ PASS - Customer created: <uuid>

Test 3: Create Account
✓ PASS - Account created: <uuid>

Test 4: Create Fleet Loan
✓ PASS - Fleet loan created: <uuid>
  Auto-approved: true

...

✅ All API tests completed successfully!
```

## Step 8: Test the Platform

### Create a Customer
```bash
curl -X POST http://localhost:7777/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "phone": "555-4321"
  }'
```

### Create an Account
```bash
curl -X POST http://localhost:7777/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "<customer-id-from-above>",
    "type": "personal",
    "balance": 1000,
    "status": "active"
  }'
```

### Apply for a Fleet Loan
```bash
curl -X POST http://localhost:7777/loans/fleet \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "<customer-id>",
    "amount": 75000,
    "riskScore": 85
  }'
```

### Apply for a Personal Loan
```bash
curl -X POST http://localhost:7777/loans/personal \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "<customer-id>",
    "amount": 5000,
    "riskScore": 90
  }'
```

### Apply for an SBL Loan
```bash
curl -X POST http://localhost:7777/loans/sbl \
  -H "Content-Type: application/json" \
  -d '{
    "customerId": "<customer-id>",
    "amount": 25000,
    "riskScore": 78
  }'
```

## Monitoring

### View Logs
```bash
# View all logs
docker compose -f docker-compose.core.yml logs -f

# View specific service logs
docker compose -f docker-compose.core.yml logs -f puabo-core-adapter
docker compose -f docker-compose.core.yml logs -f puabo-smart-contracts
docker compose -f docker-compose.core.yml logs -f fineract
```

### Check Service Status
```bash
docker compose -f docker-compose.core.yml ps
```

## Stopping the Platform

```bash
# Stop all services
docker compose -f docker-compose.core.yml down

# Stop and remove volumes (clean slate)
docker compose -f docker-compose.core.yml down -v
```

## Troubleshooting

### Services Won't Start
```bash
# Check Docker daemon is running
docker info

# Check for port conflicts
lsof -i :7777
lsof -i :8880
lsof -i :5434
lsof -i :6379

# View detailed logs
docker compose -f docker-compose.core.yml logs
```

### API Not Responding
```bash
# Restart the adapter service
docker compose -f docker-compose.core.yml restart puabo-core-adapter

# Check if the service is running
docker compose -f docker-compose.core.yml ps puabo-core-adapter
```

### Database Connection Issues
```bash
# Restart Fineract and database
docker compose -f docker-compose.core.yml restart fineract-db fineract

# Wait 30 seconds and try again
```

## Next Steps

1. **Explore the API**: Use the OpenAPI spec at `puabo-core-adapter/openapi.yaml`
2. **Integrate with Frontend**: Connect your UI to http://localhost:7777
3. **Customize Products**: Edit files in `config/products/`
4. **Add Smart Contracts**: Create new contracts in `puabo-smart-contracts/contracts/`
5. **Extend Modules**: Add features to modules in `puabo-core-adapter/src/modules/`

## Production Deployment

For production:
1. Change all default passwords
2. Enable SSL/TLS
3. Configure proper secrets management
4. Set up database backups
5. Configure monitoring and alerting
6. Use a reverse proxy (Nginx/Traefik)
7. Set up horizontal scaling

## Support

- **API Documentation**: See `openapi.yaml`
- **Architecture**: See `docs/system-diagram.mmd`
- **README**: See main `README.md`

---

**Congratulations!** 🎉 You've successfully launched the Nexus COS PUABO Core platform!

You now have a fully functional banking and lending platform with:
- ✅ Customer onboarding & KYC
- ✅ Account management
- ✅ Loan origination (Personal, SBL, Fleet)
- ✅ Smart contract automation
- ✅ AI-powered risk scoring
- ✅ Blockchain integration
- ✅ Core banking (Apache Fineract)

**Ready to disrupt the Fintech industry!** 🚀

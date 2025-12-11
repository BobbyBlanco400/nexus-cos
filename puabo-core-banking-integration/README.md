# PUABO Core Banking Integration

This project deploys:
- Apache Fineract (open-source core banking engine)
- PUABO Core Adapter Service
- Data mappings for PUABO BLAC + PUABO Nexus Fleet Financing
- Migration stubs for future Thought Machine integration

## Deploy Fineract
```bash
cd docker
docker-compose up -d
```

## Deploy Adapter
```bash
cd adapter
npm install
npm run start
```

Adapter will run on port 8080.

## End-to-End Test
```bash
POST /customers
POST /loans
POST /payments
```

This completes Phase 1 of PUABO Banking Core integration.

Thought Machine migration stubs included.

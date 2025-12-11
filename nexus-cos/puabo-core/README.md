# Nexus COS Full Production Stack + Banking Solutions

## Overview

This is the **Nexus COS PUABO Core** - a comprehensive banking and lending platform that integrates:

- **PUABO BLAC** - Personal & SBL (Small Business Loan) products
- **Nexus Fleet Financing** - Fleet loan management
- **Apache Fineract CE** - Core banking system
- **Smart Contract Engine** - Automated loan approval and processing
- **PUABO AI** - KYC verification and risk scoring
- **Blockchain Integration** - Transaction recording and smart contracts

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Nexus COS Platform                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │ PUABO BLAC  │    │ Nexus Fleet  │    │   PUABO AI   │  │
│  │ Personal+SBL│───▶│  Financing   │───▶│  KYC & Risk  │  │
│  └─────────────┘    └──────────────┘    └──────────────┘  │
│         │                   │                    │          │
│         └───────────────────┼────────────────────┘          │
│                             ▼                                │
│                  ┌─────────────────────┐                    │
│                  │ PUABO Core Adapter  │                    │
│                  │   (Express API)     │                    │
│                  └─────────────────────┘                    │
│                    │                 │                      │
│         ┌──────────┴────┐      ┌────┴──────────────┐      │
│         ▼                ▼      ▼                   ▼       │
│  ┌─────────────┐  ┌──────────────┐   ┌──────────────────┐ │
│  │  Fineract   │  │    Smart     │   │   Blockchain/    │ │
│  │     CE      │  │  Contracts   │   │   MusicChain     │ │
│  │  (Banking)  │  │   Engine     │   │                  │ │
│  └─────────────┘  └──────────────┘   └──────────────────┘ │
│         │                 │                                 │
│         ▼                 ▼                                 │
│  ┌─────────────┐  ┌──────────────┐                        │
│  │ PostgreSQL  │  │    Redis     │                        │
│  └─────────────┘  └──────────────┘                        │
└─────────────────────────────────────────────────────────────┘
```

## Features

### Banking Products
1. **Personal Loans** - Consumer lending up to $50,000
2. **SBL (Small Business Loans)** - Business lending up to $100,000
3. **Fleet Financing** - Vehicle fleet loans up to $250,000

### Core Capabilities
- Customer onboarding with KYC verification
- Account management (personal & business)
- Loan origination and approval
- Collateral management
- Payment processing
- Smart contract-based auto-approval
- AI-powered risk scoring
- Blockchain transaction recording

## Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for local development)

### Launch the Full Stack

```bash
cd nexus-cos/puabo-core

# Start all services
docker compose -f docker-compose.core.yml up -d --build

# Wait for services to be ready (30-60 seconds)
# Check health
curl http://localhost:7777/health

# Initialize products
chmod +x scripts/init-products.sh
./scripts/init-products.sh

# Seed mock data
npm install axios uuid
node scripts/seed-mock-data.js

# Run API tests
node scripts/test-api.js
```

### Services

Once running, the following services will be available:

- **PUABO Core Adapter API**: http://localhost:7777
- **Apache Fineract**: http://localhost:8880
- **PostgreSQL**: localhost:5434
- **Redis**: localhost:6379

## API Endpoints

### Base URL
```
http://localhost:7777
```

### Available Endpoints

#### Customers
```bash
POST /customers
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "555-1234"
}
```

#### Accounts
```bash
POST /accounts
{
  "customerId": "uuid",
  "type": "personal",
  "balance": 1000,
  "status": "active"
}
```

#### Loans

**Personal Loan**
```bash
POST /loans/personal
{
  "customerId": "uuid",
  "amount": 5000,
  "riskScore": 85
}
```

**SBL (Small Business Loan)**
```bash
POST /loans/sbl
{
  "customerId": "uuid",
  "amount": 15000,
  "riskScore": 75
}
```

**Fleet Loan**
```bash
POST /loans/fleet
{
  "customerId": "uuid",
  "amount": 50000,
  "riskScore": 80
}
```

#### Other Endpoints
- `POST /collateral` - Manage loan collateral
- `POST /fleet` - Fleet management
- `POST /payments` - Process payments
- `POST /business` - Business entity management

## Project Structure

```
nexus-cos/puabo-core/
├── docker-compose.core.yml       # Docker orchestration
├── puabo-core-adapter/           # Main API service
│   ├── src/
│   │   ├── index.js              # Express server
│   │   ├── modules/              # Business logic modules
│   │   │   ├── customers/
│   │   │   ├── accounts/
│   │   │   ├── loans/
│   │   │   ├── collateral/
│   │   │   ├── fleet/
│   │   │   ├── payments/
│   │   │   └── business/
│   │   └── integrations/         # External integrations
│   │       ├── puabo-ai/         # KYC & Risk scoring
│   │       ├── puabo-blockchain/ # Blockchain recording
│   │       └── diagram-generator/# System diagrams
│   ├── package.json
│   ├── openapi.yaml              # API specification
│   └── Dockerfile
├── puabo-smart-contracts/        # Smart contract engine
│   ├── contracts/
│   │   └── loan.approval.js      # Loan approval logic
│   ├── engine/
│   │   └── executor.js           # Contract executor
│   ├── package.json
│   └── Dockerfile
├── config/
│   └── products/                 # Product configurations
├── scripts/
│   ├── init-products.sh          # Product setup
│   ├── seed-mock-data.js         # Mock data seeder
│   └── test-api.js               # API tests
└── docs/
    └── system-diagram.mmd        # Mermaid diagram
```

## Development

### Local Development (without Docker)

```bash
# Terminal 1: Start Redis
redis-server

# Terminal 2: Start PUABO Core Adapter
cd puabo-core-adapter
npm install
cp .env.example .env
npm start

# Terminal 3: Start Smart Contracts Engine
cd puabo-smart-contracts
npm install
cp .env.example .env
npm start

# Terminal 4: Run tests
cd scripts
node test-api.js
```

## Smart Contract Logic

The platform includes automated loan approval based on:
- **Risk Score Threshold**: 70 or higher
- **Loan Amount Limit**: $100,000 or less

Loans meeting both criteria are auto-approved. Others go to manual review.

## Integration Points

### PUABO AI
- KYC verification
- Risk score calculation
- Credit assessment

### Blockchain
- Transaction recording
- Smart contract execution
- Immutable audit trail

### Fineract CE
- Core banking operations
- Account management
- Loan servicing

## Testing

Run the comprehensive API test suite:

```bash
node scripts/test-api.js
```

This tests:
- Health check
- Customer creation
- Account creation
- Fleet loan creation
- Personal loan creation
- SBL loan creation

## Production Deployment

For production deployment:

1. Update environment variables in `.env` files
2. Configure SSL/TLS certificates
3. Set up proper database backups
4. Configure monitoring and logging
5. Set up load balancing

```bash
docker compose -f docker-compose.core.yml up -d --build
```

## Security

- All passwords should be changed from defaults
- Enable SSL/TLS for production
- Implement proper authentication/authorization
- Regular security audits
- Database encryption at rest

## Support

For issues or questions, please refer to the main Nexus COS documentation.

## License

Proprietary - Nexus COS Platform

---

**Nexus COS** - The World's First Creative Operating System
Disrupting Film, TV, Streaming, Music, Media, Video Podcasting, Virtual Production/Creation, and Fintech Industries

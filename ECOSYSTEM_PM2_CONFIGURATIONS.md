# Nexus COS - PM2 Ecosystem Configurations

**Version**: 2025.01.12  
**Status**: Structured & Organized  
**Purpose**: Comprehensive PM2 orchestration coverage for Nexus COS

## 📋 Overview

This document describes the new modular PM2 ecosystem configuration structure for Nexus COS. Instead of a single monolithic configuration file, services are now organized into logical groups for better management, deployment, and scaling.

## 🗂️ Configuration Files

### 1. **ecosystem.config.js** (Main/Legacy)
**Status**: ✅ Active  
**Services**: 32 services (29 + 3 V-Suite Pro)  
**Coverage**: Core infrastructure, PUABO ecosystem, platform services, specialized services

This is the original comprehensive configuration file that includes most of the production services.

### 2. **ecosystem.platform.config.js** (NEW)
**Status**: ✅ Ready  
**Services**: 13 platform services  
**Coverage**:
- Authentication Services (2): auth-service, user-auth
- Content Management (1): content-management
- Creator Platform (1): creator-hub
- Session & Token Management (2): session-mgr, token-mgr
- Financial Services (2): ledger-mgr, invoice-gen
- Streaming Services (1): streaming
- Core Platform (3): kei-ai, nexus-cos-studio-ai, puaboverse

**Port Range**: 3101-3112, 3301-3304, 3401-3404

### 3. **ecosystem.puabo.config.js** (NEW)
**Status**: ✅ Ready  
**Services**: 17 PUABO microservices  
**Coverage**:
- PUABO DSP (3): upload-mgr, metadata-mgr, streaming-api
- PUABO BLAC (2): loan-processor, risk-assessment
- PUABO Nexus Fleet (4): ai-dispatch, driver-app-backend, fleet-manager, route-optimizer
- PUABO NUKI E-Commerce (4): inventory-mgr, order-processor, product-catalog, shipping-service
- PUABO Core (4): puaboai-sdk, puabomusicchain, pv-keys, streamcore

**Port Range**: 3012-3016, 3211-3213, 3221-3222, 3231-3234, 3241-3244

### 4. **ecosystem.vsuite.config.js** (NEW)
**Status**: ✅ Ready  
**Services**: 4 V-Suite production tools  
**Coverage**:
- v-caster-pro (Broadcasting)
- v-prompter-pro (Teleprompter)
- v-screen-pro (Display management)
- vscreen-hollywood (Production studio)

**Port Range**: 3501-3504

### 5. **ecosystem.family.config.js** (NEW - PLACEHOLDER)
**Status**: ⚠️ Planned  
**Services**: 5 family entertainment modules (not yet implemented)  
**Coverage** (Planned):
- Ahshanti's Munch & Mingle (ASMR cooking)
- Tyshawn's V-Dance Studio (Dance instruction)
- Fayeloni Kreation (Creative content)
- Sassie Lashes (Beauty/lifestyle)
- Nee Nee & Kids Show (Children's programming)

**Port Range**: 8401-8405  
**Note**: Services need to be reclassified from services to modules as per PF recommendations

### 6. **ecosystem.urban.config.js** (NEW - PARTIAL)
**Status**: ⚠️ Partial  
**Services**: 1 active + 5 planned urban entertainment services  
**Coverage**:
- ✅ Boom Boom Room Live (Active - Port 3601)
- ⚠️ Headwina Comedy Club (Planned)
- ⚠️ IDH Live Beauty Salon (Planned)
- ⚠️ Clocking T with Ta Gurl P (Planned)
- ⚠️ RoRo Reefer Gaming Lounge (Planned)
- ⚠️ Ahshanti's Service variant (Planned)

**Port Range**: 3601, 8501-8505

## 🚀 Usage

### Starting All Services

```bash
# Start main ecosystem (legacy comprehensive config)
pm2 start ecosystem.config.js

# Or start specific groups
pm2 start ecosystem.platform.config.js
pm2 start ecosystem.puabo.config.js
pm2 start ecosystem.vsuite.config.js
pm2 start ecosystem.urban.config.js

# Start all ecosystem configs at once
pm2 start ecosystem.*.config.js
```

### Starting Individual Groups

```bash
# Platform services only
pm2 start ecosystem.platform.config.js

# PUABO Business Suite only
pm2 start ecosystem.puabo.config.js

# V-Suite Production Tools only
pm2 start ecosystem.vsuite.config.js
```

### Managing Services

```bash
# List all PM2 processes
pm2 list

# Monitor services
pm2 monit

# View logs for a specific service
pm2 logs auth-service
pm2 logs puabo-dsp-upload-mgr

# Restart a specific service
pm2 restart auth-service

# Stop all services
pm2 stop all

# Delete all processes
pm2 delete all
```

### Saving PM2 Configuration

```bash
# Save current PM2 process list
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

## 📊 Service Distribution

| Configuration File | Services | Status | Ports |
|-------------------|----------|--------|-------|
| ecosystem.config.js | 32 | ✅ Active | 3001-3601 |
| ecosystem.platform.config.js | 13 | ✅ Ready | 3101-3404 |
| ecosystem.puabo.config.js | 17 | ✅ Ready | 3012-3244 |
| ecosystem.vsuite.config.js | 4 | ✅ Ready | 3501-3504 |
| ecosystem.family.config.js | 5 | ⚠️ Planned | 8401-8405 |
| ecosystem.urban.config.js | 6 | ⚠️ Partial | 3601, 8501-8505 |
| **TOTAL** | **77** | **Mixed** | **Various** |

## 🔧 Environment Variables

All configurations support the following environment variables:

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nexuscos_db
DB_USER=nexuscos
DB_PASSWORD=your_secure_password

# Authentication
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRY=24h
SESSION_SECRET=your_session_secret

# Redis (for session management)
REDIS_HOST=localhost
REDIS_PORT=6379

# API Keys (service-specific)
AI_API_KEY=your_ai_api_key
MAPS_API_KEY=your_maps_api_key
PAYMENT_API_KEY=your_payment_api_key
SHIPPING_API_KEY=your_shipping_api_key
LOAN_API_KEY=your_loan_api_key
CREDIT_API_KEY=your_credit_api_key
BLOCKCHAIN_API_KEY=your_blockchain_api_key
```

## 📝 Log Organization

Logs are now organized by service category:

```
logs/
├── platform/          # Platform services logs
│   ├── auth-service.log
│   ├── content-management.log
│   └── ...
├── puabo/            # PUABO microservices logs
│   ├── dsp-upload-mgr.log
│   ├── blac-loan-processor.log
│   └── ...
├── vsuite/           # V-Suite services logs
│   ├── v-caster-pro.log
│   ├── v-prompter-pro.log
│   └── ...
├── family/           # Family entertainment logs (planned)
└── urban/            # Urban entertainment logs
```

## 🎯 Implementation Roadmap

### ✅ Completed (Week 1)
- [x] Create ecosystem.platform.config.js
- [x] Create ecosystem.puabo.config.js
- [x] Create ecosystem.vsuite.config.js
- [x] Create placeholder ecosystem.family.config.js
- [x] Create placeholder ecosystem.urban.config.js
- [x] Document PM2 configuration structure

### 🔄 In Progress (Week 2-3)
- [ ] Implement Family Entertainment modules
- [ ] Implement Urban Entertainment services
- [ ] Update frontend sidebar/navigation
- [ ] Apply unified branding across ecosystem

### 📅 Planned (Week 4+)
- [ ] Create deployment scripts that use modular configs
- [ ] Implement health monitoring for all services
- [ ] Create automated deployment pipelines
- [ ] Establish governance and documentation standards

## 🚨 Critical Notes

1. **Port Conflicts**: Ensure no port conflicts exist between configurations
2. **Dependencies**: Some services may have dependencies on others (e.g., auth services)
3. **Database**: All services assume a PostgreSQL database is available
4. **Redis**: Session management services require Redis
5. **API Keys**: External service integrations require valid API keys

## 📚 Related Documentation

- [NEXUS_COS_V2025_FINAL_UNIFIED_PF.md](NEXUS_COS_V2025_FINAL_UNIFIED_PF.md) - Complete system architecture
- [PRODUCTION_DEPLOYMENT_GUIDE.md](PRODUCTION_DEPLOYMENT_GUIDE.md) - Deployment procedures
- [ecosystem.config.js](ecosystem.config.js) - Main PM2 configuration

## 🔗 Integration

To integrate these configurations with existing deployment scripts:

```bash
# Example: Update nexus-cos.ps1 to use modular configs
pm2 start ecosystem.platform.config.js
pm2 start ecosystem.puabo.config.js
pm2 start ecosystem.vsuite.config.js
pm2 start ecosystem.urban.config.js

# Or load all at once
pm2 start ecosystem.*.config.js
```

## 📈 Coverage Statistics

- **Total Components in Ecosystem**: 67 (as per PF)
- **PM2 Configured (Main)**: 32 services (48%)
- **PM2 Configured (New Modular)**: 35 services (52%)
- **Total PM2 Coverage**: 67 services (100% when all are active)
- **Active Services**: 51 (76%)
- **Planned Services**: 16 (24%)

## 🎯 Success Metrics

**PM2 Coverage Goals**:
- Current: 51/67 services configured (76%)
- Target: 60/67 services active (90%)
- Ultimate Goal: 67/67 services (100%)

---

**Document Prepared By**: Nexus COS DevOps Team  
**Last Updated**: 2025-01-12  
**Review Required**: System Architecture, DevOps, Product Management  
**Implementation Status**: Phase 1 Complete

# Nexus COS PF v1.2 Implementation Guide

This guide demonstrates how to use the Project Framework v1.2 with dependency mapping for automated scaffolding and deployment.

## 🚀 Quick Start

### 1. Generate Service Structure
```bash
# Run the Copilot Master Scaffold script
node copilot-master-scaffold.js

# This will generate:
# - Complete service/module directory structure
# - Boilerplate code with API endpoints
# - Docker configurations
# - Service-to-service communication templates
```

### 2. Deploy with Dependency Awareness
```bash
# Deploy in development mode
./deploy-pf-v1.2.sh development

# Deploy in production mode
sudo ./deploy-pf-v1.2.sh production
```

### 3. Health Check and Monitoring
```bash
# Run comprehensive health check
./health-check-pf-v1.2.sh

# Monitor services
pm2 monit
```

## 📊 Example Service Implementation

Here's how a complete service looks in PF v1.2:

### Auth Service Structure
```
services/auth-service/
├── deps.yaml                 # Dependency definition
├── README.md                 # Service documentation
├── server.js                 # Main service (auto-generated)
├── apiClient.js              # API client for dependencies
├── package.json              # Dependencies
├── Dockerfile                # Container configuration
└── microservices/
    ├── session-mgr/
    │   └── server.js         # Session management microservice
    └── token-mgr/
        └── server.js         # Token management microservice
```

### Auto-Generated Service Code
The scaffolding script generates complete Express.js services:

```javascript
// auth-service/server.js (Auto-generated)
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3100;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        service: 'auth-service',
        timestamp: new Date().toISOString(),
        port: PORT
    });
});

// Auto-generated API routes based on deps.yaml
app.post('/auth/login', async (req, res) => {
    try {
        // TODO: Implement User authentication
        res.json({ 
            message: 'User authentication',
            endpoint: '/auth/login',
            method: 'POST',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// More routes auto-generated...
```

### API Client Generation
Services that depend on others get auto-generated API clients:

```javascript
// puabo-dsp/apiClient.js (Auto-generated)
const axios = require('axios');

class APIClient {
    constructor() {
        this.baseURLs = {
            'auth-service': process.env.AUTH_SERVICE_URL || 'http://localhost:3100',
            'billing-service': process.env.BILLING_SERVICE_URL || 'http://localhost:3110'
        };
    }

    // Validate user authentication
    async authServiceValidate(data = {}) {
        try {
            const response = await axios({
                method: 'GET',
                url: `${this.baseURLs['auth-service']}/auth/validate`,
                data: data
            });
            return response.data;
        } catch (error) {
            console.error('Error calling auth-service/auth/validate:', error.message);
            throw error;
        }
    }
}

module.exports = new APIClient();
```

## 🐳 Docker Integration

### Auto-Generated Docker Compose
```yaml
# docker/docker-compose.yml (Auto-generated)
version: '3.8'

networks:
  nexus-network:
    driver: bridge

services:
  # Core Services
  auth-service:
    build: ../services/auth-service
    ports:
      - "3100:3100"
    environment:
      - NODE_ENV=production
      - PORT=3100
    networks:
      - nexus-network

  puabo-dsp:
    build: ../modules/puabo-dsp
    ports:
      - "3210:3210"
    depends_on:
      - auth-service
      - billing-service
    networks:
      - nexus-network
```

## 🔄 Dependency-Aware Deployment

### Startup Sequence
The deployment script follows dependency order:

1. **Phase 1 - Core Services** (no dependencies):
   - auth-service (port 3100)
   - billing-service (port 3110)
   - user-profile-service (port 3120)

2. **Phase 2 - Dependent Services**:
   - media-encoding-service (port 3130)
   - streaming-service (port 3140)
   - recommendation-engine (port 3150)

3. **Phase 3 - Business Modules**:
   - core-os (depends on auth-service, user-profile-service)
   - puabo-dsp (depends on multiple core services)
   - v-suite (depends on streaming, chat, notification services)

### Health Check Validation
```bash
# Example health check output
▼ Service Dependency Validation
═══════════════════════════════════════════════════════════════════
✅ puabo-dsp → auth-service (Port 3100) - DEPENDENCY OK
✅ puabo-dsp → billing-service (Port 3110) - DEPENDENCY OK
✅ puabo-dsp → media-encoding-service (Port 3130) - DEPENDENCY OK
✅ puabo-dsp - ALL DEPENDENCIES OK
```

## 🎯 GitHub Copilot Integration

### Prompt Templates
Use these prompts with GitHub Copilot to leverage the PF v1.2 structure:

```markdown
Based on the Nexus COS PF v1.2 dependency mapping in deps.yaml:
1. Generate a complete Express.js service for [service-name]
2. Include all API endpoints defined in the provides.apis section
3. Create API client functions for all dependencies listed in consumes.apis
4. Add proper error handling and logging
5. Include health check endpoint returning service status
```

### Code Generation Examples
```javascript
// Copilot can generate complete services like this:
// @nexus-cos-pf-v1.2 Generate billing-service with microservices
// Based on deps.yaml: invoice-gen, ledger-mgr, payout-engine
// Dependencies: integrations (stripe, paypal)
```

## 📈 Scaling and Monitoring

### PM2 Process Management
```bash
# View all services
pm2 list

# Monitor specific service
pm2 logs auth-service

# Scale a service
pm2 scale auth-service 3

# Restart with zero downtime
pm2 reload auth-service
```

### Load Balancing
Nginx automatically configured with routes:
- `/api/auth/*` → auth-service:3100
- `/api/billing/*` → billing-service:3110
- `/api/dsp/*` → puabo-dsp:3210

## 🔧 Development Workflow

### 1. Define Dependencies
Update `deps.yaml` with required services and APIs:

```yaml
dependencies:
  core_services:
    - auth-service
    - billing-service
    
consumes:
  apis:
    - service: "auth-service"
      endpoint: "/auth/validate"
      purpose: "Validate user tokens"
```

### 2. Generate Code
```bash
node copilot-master-scaffold.js
```

### 3. Implement Business Logic
Fill in the TODO sections in generated code:

```javascript
// Replace TODO with actual implementation
app.post('/auth/login', async (req, res) => {
    try {
        // TODO: Implement User authentication
        const { username, password } = req.body;
        const user = await authenticateUser(username, password);
        const token = generateJWT(user);
        res.json({ token, user });
    } catch (error) {
        res.status(401).json({ error: 'Authentication failed' });
    }
});
```

### 4. Deploy and Test
```bash
./deploy-pf-v1.2.sh development
./health-check-pf-v1.2.sh
```

## 🎉 Benefits

### For Developers
- **Faster Development**: Auto-generated boilerplate code
- **Clear Dependencies**: Explicit service relationships
- **Type Safety**: API contracts defined in deps.yaml
- **Easy Testing**: Isolated services with mock dependencies

### For DevOps
- **Reliable Deployment**: Dependency-aware startup order
- **Health Monitoring**: Comprehensive health checks
- **Scaling**: Individual service scaling
- **Load Balancing**: Automatic nginx configuration

### For GitHub Copilot
- **Context Awareness**: Understanding of service relationships
- **Code Generation**: Complete services from dependency definitions
- **API Wiring**: Automatic service-to-service communication
- **Docker Integration**: Container configurations from service definitions

## 🚀 Next Steps

1. **Customize Services**: Modify generated code for specific business logic
2. **Add Authentication**: Implement JWT validation in auth-service
3. **Database Integration**: Add database connections to services
4. **Event Bus**: Implement Kafka/RabbitMQ for async communication
5. **Monitoring**: Add Prometheus metrics and Grafana dashboards
6. **CI/CD**: Set up automated testing and deployment pipelines

---

**The Nexus COS PF v1.2 framework provides a complete foundation for building scalable, maintainable microservices with GitHub Copilot assistance.** 🎯
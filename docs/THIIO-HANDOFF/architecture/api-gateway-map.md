# API Gateway Map

## Overview

The `backend-api` service (port 3000) serves as the primary API gateway for the entire Nexus COS platform, routing requests to 43 microservices.

## Gateway Architecture

```
Client Requests
      ↓
[Load Balancer]
      ↓
[backend-api:3000]
      ↓
[Route Matching]
      ↓
[Authentication Middleware]
      ↓
[Authorization Middleware]
      ↓
[Rate Limiting]
      ↓
[Service Router]
      ↓
[Target Microservice]
```

## API Endpoints by Domain

### Authentication & Authorization

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/auth/login` | POST | auth-service:3001 | No |
| `/api/auth/logout` | POST | auth-service:3001 | Yes |
| `/api/auth/refresh` | POST | auth-service-v2:3002 | Yes |
| `/api/auth/register` | POST | user-auth:3003 | No |
| `/api/auth/verify` | POST | user-auth:3003 | Yes |
| `/api/sessions/*` | ALL | session-mgr:3004 | Yes |
| `/api/tokens/*` | ALL | token-mgr:3005 | Yes |

### Content & Streaming

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/stream/*` | GET | streaming-service-v2:3010 | Yes |
| `/api/streamcore/*` | ALL | streamcore:3011 | Yes |
| `/api/content/*` | ALL | content-management:3012 | Yes |
| `/api/dsp/stream/*` | GET | puabo-dsp-streaming-api:3013 | Yes |
| `/api/dsp/metadata/*` | ALL | puabo-dsp-metadata-mgr:3014 | Yes |
| `/api/dsp/upload` | POST | puabo-dsp-upload-mgr:3015 | Yes |

### Business Services

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/billing/*` | ALL | billing-service:3020 | Yes |
| `/api/invoices/*` | ALL | invoice-gen:3021 | Yes |
| `/api/ledger/*` | ALL | ledger-mgr:3022 | Yes |
| `/api/scheduler/*` | ALL | scheduler:3023 | Yes |

### AI Services

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/ai/kei/*` | POST | kei-ai:3030 | Yes |
| `/api/ai/general/*` | POST | ai-service:3031 | Yes |
| `/api/ai/studio/*` | POST | nexus-cos-studio-ai:3032 | Yes |
| `/api/ai/sdk/*` | ALL | puaboai-sdk:3033 | Yes |
| `/api/ai/dispatch/*` | POST | puabo-nexus-ai-dispatch:3034 | Yes |

### E-Commerce

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/products/*` | ALL | puabo-nuki-product-catalog:3040 | Partial |
| `/api/inventory/*` | ALL | puabo-nuki-inventory-mgr:3041 | Yes |
| `/api/orders/*` | ALL | puabo-nuki-order-processor:3042 | Yes |
| `/api/shipping/*` | ALL | puabo-nuki-shipping-service:3043 | Yes |

### Financial Services

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/loans/*` | ALL | puabo-blac-loan-processor:3050 | Yes |
| `/api/risk/*` | POST | puabo-blac-risk-assessment:3051 | Yes |

### Logistics

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/driver/*` | ALL | puabo-nexus-driver-app-backend:3060 | Yes |
| `/api/fleet/*` | ALL | puabo-nexus-fleet-manager:3061 | Yes |
| `/api/routes/*` | POST | puabo-nexus-route-optimizer:3062 | Yes |

### Entertainment

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/live/boom/*` | ALL | boom-boom-room-live:3070 | Yes |
| `/api/hollywood/*` | ALL | vscreen-hollywood:3071 | Yes |
| `/api/casting/*` | ALL | v-caster-pro:3072 | Yes |
| `/api/prompter/*` | ALL | v-prompter-pro:3073 | Yes |
| `/api/vscreen/*` | ALL | v-screen-pro:3074 | Yes |

### Platform Services

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/keys/*` | ALL | key-service:3080 | Yes |
| `/api/pvkeys/*` | ALL | pv-keys:3081 | Yes |
| `/api/errors/*` | POST | glitch:3082 | Partial |
| `/api/metatwin/*` | ALL | metatwin:3083 | Yes |

### Specialized Services

| Endpoint | Method | Target Service | Auth Required |
|----------|--------|----------------|---------------|
| `/api/creator/*` | ALL | creator-hub-v2:3090 | Yes |
| `/api/musicchain/*` | ALL | puabomusicchain:3091 | Yes |
| `/api/puaboverse/*` | ALL | puaboverse-v2:3092 | Yes |
| `/api/nexus/*` | ALL | puabo-nexus:3093 | Yes |

## Gateway Middleware Stack

### 1. Request Logging
```javascript
app.use((req, res, next) => {
  const requestId = generateRequestId();
  req.id = requestId;
  logger.info(`${req.method} ${req.path}`, { requestId });
  next();
});
```

### 2. CORS Configuration
```javascript
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS.split(','),
  credentials: true,
  maxAge: 86400
}));
```

### 3. Body Parsing
```javascript
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
```

### 4. Authentication Middleware
```javascript
app.use('/api/*', async (req, res, next) => {
  const publicPaths = ['/api/auth/login', '/api/auth/register'];
  if (publicPaths.includes(req.path)) return next();
  
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'No token provided' });
  
  try {
    const decoded = await verifyToken(token);
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});
```

### 5. Rate Limiting
```javascript
const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests, please try again later'
});

app.use('/api/*', rateLimiter);
```

### 6. Request Validation
```javascript
app.use('/api/*', (req, res, next) => {
  // Validate request structure
  // Sanitize inputs
  // Check content-type
  next();
});
```

## Service Discovery & Routing

### Dynamic Service Registry

```javascript
const serviceRegistry = {
  'auth-service': {
    url: process.env.AUTH_SERVICE_URL || 'http://auth-service:3001',
    healthCheck: '/health',
    timeout: 5000
  },
  'streaming-service-v2': {
    url: process.env.STREAMING_SERVICE_URL || 'http://streaming-service-v2:3010',
    healthCheck: '/health',
    timeout: 10000
  },
  // ... all 43 services
};
```

### Health Checking

```javascript
async function checkServiceHealth(serviceName) {
  const service = serviceRegistry[serviceName];
  try {
    const response = await axios.get(
      `${service.url}${service.healthCheck}`,
      { timeout: 5000 }
    );
    return response.status === 200;
  } catch (error) {
    logger.error(`Health check failed for ${serviceName}`, error);
    return false;
  }
}
```

### Load Balancing

For services with multiple instances:
```javascript
const loadBalancer = {
  'streaming-service-v2': [
    'http://streaming-1:3010',
    'http://streaming-2:3010',
    'http://streaming-3:3010'
  ]
};

function getServiceInstance(serviceName) {
  const instances = loadBalancer[serviceName] || [serviceRegistry[serviceName].url];
  const index = Math.floor(Math.random() * instances.length);
  return instances[index];
}
```

## Request Transformation

### Request Enrichment
```javascript
app.use('/api/*', (req, res, next) => {
  req.gateway = {
    requestId: req.id,
    timestamp: Date.now(),
    userAgent: req.headers['user-agent'],
    ip: req.ip,
    userId: req.user?.id
  };
  next();
});
```

### Response Transformation
```javascript
app.use('/api/*', (req, res, next) => {
  const originalJson = res.json;
  res.json = function(data) {
    const envelope = {
      success: true,
      data: data,
      meta: {
        requestId: req.id,
        timestamp: Date.now()
      }
    };
    originalJson.call(this, envelope);
  };
  next();
});
```

## Error Handling

### Gateway Error Handler
```javascript
app.use((error, req, res, next) => {
  logger.error('Gateway error', {
    requestId: req.id,
    error: error.message,
    stack: error.stack
  });
  
  if (error.type === 'SERVICE_UNAVAILABLE') {
    return res.status(503).json({
      error: 'Service temporarily unavailable',
      requestId: req.id
    });
  }
  
  if (error.type === 'SERVICE_TIMEOUT') {
    return res.status(504).json({
      error: 'Request timeout',
      requestId: req.id
    });
  }
  
  res.status(500).json({
    error: 'Internal server error',
    requestId: req.id
  });
});
```

## Circuit Breaker Pattern

```javascript
const circuitBreakers = {};

function getCircuitBreaker(serviceName) {
  if (!circuitBreakers[serviceName]) {
    circuitBreakers[serviceName] = new CircuitBreaker({
      threshold: 5,      // Open after 5 failures
      timeout: 30000,    // Try again after 30s
      resetTimeout: 60000 // Full reset after 60s
    });
  }
  return circuitBreakers[serviceName];
}
```

## Monitoring & Observability

### Metrics Exposed
- Request count by endpoint
- Response time by service
- Error rate by service
- Active connections
- Circuit breaker state

### Endpoints
- `GET /health` - Gateway health
- `GET /metrics` - Prometheus metrics
- `GET /status` - Service status dashboard

## Security Features

### API Key Validation
```javascript
app.use('/api/public/*', (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (!isValidApiKey(apiKey)) {
    return res.status(403).json({ error: 'Invalid API key' });
  }
  next();
});
```

### Request Signing
Critical endpoints require request signatures:
```javascript
function validateSignature(req) {
  const signature = req.headers['x-signature'];
  const payload = req.body;
  const expectedSignature = hmac(payload, SECRET_KEY);
  return signature === expectedSignature;
}
```

### IP Whitelisting
```javascript
const whitelist = process.env.IP_WHITELIST?.split(',') || [];

app.use('/api/admin/*', (req, res, next) => {
  if (!whitelist.includes(req.ip)) {
    return res.status(403).json({ error: 'Access denied' });
  }
  next();
});
```

## WebSocket Gateway

```javascript
const wss = new WebSocketServer({ server });

wss.on('connection', (ws, req) => {
  const token = parseToken(req.url);
  if (!verifyToken(token)) {
    ws.close(1008, 'Unauthorized');
    return;
  }
  
  // Route WebSocket messages to appropriate services
  ws.on('message', async (message) => {
    const { service, action, data } = JSON.parse(message);
    const targetService = serviceRegistry[service];
    // Forward to service WebSocket endpoint
  });
});
```

## API Versioning

```javascript
app.use('/api/v1/*', v1Router);
app.use('/api/v2/*', v2Router);

// Default to latest
app.use('/api/*', (req, res, next) => {
  if (!req.path.match(/^\/api\/v\d+/)) {
    req.url = req.url.replace('/api/', '/api/v2/');
  }
  next();
});
```

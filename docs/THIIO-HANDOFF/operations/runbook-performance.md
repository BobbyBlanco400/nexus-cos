# Performance Tuning Runbook

## Overview

This runbook provides guidance on optimizing the performance of the Nexus COS platform, including identifying bottlenecks, tuning configurations, and implementing performance improvements.

## Performance Targets

### Service Level Objectives (SLOs)

| Metric | Target | Warning | Critical |
|--------|--------|---------|----------|
| API Response Time (p50) | < 50ms | > 100ms | > 200ms |
| API Response Time (p95) | < 200ms | > 300ms | > 500ms |
| API Response Time (p99) | < 500ms | > 1s | > 2s |
| Error Rate | < 0.1% | > 0.5% | > 1% |
| Availability | > 99.99% | < 99.95% | < 99.9% |
| Database Query Time (p95) | < 50ms | > 100ms | > 200ms |
| Cache Hit Rate | > 90% | < 85% | < 80% |

## 1. Performance Monitoring

### Key Performance Indicators

```bash
# Check API response times
curl -s 'http://prometheus:9090/api/v1/query?query=histogram_quantile(0.95,rate(http_request_duration_seconds_bucket[5m]))' | jq

# Check database query performance
curl -s 'http://prometheus:9090/api/v1/query?query=histogram_quantile(0.95,rate(database_query_duration_seconds_bucket[5m]))' | jq

# Check cache hit rate
curl -s 'http://prometheus:9090/api/v1/query?query=redis_keyspace_hits_total/(redis_keyspace_hits_total+redis_keyspace_misses_total)' | jq
```

### Performance Dashboard

Access: https://grafana.nexuscos.online/d/performance

**Key Panels**:
- Request latency distribution
- Throughput (requests/sec)
- Error rate
- Database query performance
- Cache performance
- Resource utilization
- Slow endpoint ranking

## 2. Application Performance Optimization

### Node.js Configuration

#### Optimal Settings for Production

```javascript
// server.js
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  // Fork workers equal to CPU count
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  
  cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died, starting new worker`);
    cluster.fork();
  });
} else {
  // Worker processes
  const app = require('./app');
  const server = app.listen(process.env.PORT || 3000);
  
  // Increase max sockets
  require('http').globalAgent.maxSockets = 1000;
  require('https').globalAgent.maxSockets = 1000;
  
  // Graceful shutdown
  process.on('SIGTERM', () => {
    server.close(() => {
      process.exit(0);
    });
  });
}
```

#### Environment Variables for Performance

```bash
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  template:
    spec:
      containers:
      - name: backend-api
        env:
        - name: NODE_ENV
          value: "production"
        - name: NODE_OPTIONS
          value: "--max-old-space-size=4096 --max-http-header-size=16384"
        - name: UV_THREADPOOL_SIZE
          value: "128"
        resources:
          requests:
            cpu: "1000m"
            memory: "2Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"
```

### Database Connection Pooling

#### PostgreSQL Pool Configuration

```javascript
// database.js
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  // Performance tuning
  max: 100,                    // Maximum pool size
  min: 10,                     // Minimum pool size
  idleTimeoutMillis: 30000,    // Close idle clients after 30s
  connectionTimeoutMillis: 5000, // Timeout acquiring connection
  maxUses: 7500,               // Retire connection after uses
});

// Monitor pool
pool.on('error', (err, client) => {
  console.error('Unexpected error on idle client', err);
});

pool.on('connect', () => {
  console.log('New client connected to pool');
});

pool.on('acquire', () => {
  const { totalCount, idleCount, waitingCount } = pool;
  console.log(`Pool: ${totalCount} total, ${idleCount} idle, ${waitingCount} waiting`);
});
```

#### MongoDB Connection Optimization

```javascript
// mongodb.js
const { MongoClient } = require('mongodb');

const client = new MongoClient(process.env.MONGO_URL, {
  maxPoolSize: 100,
  minPoolSize: 10,
  maxIdleTimeMS: 30000,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  compressors: ['snappy', 'zlib'],
  retryWrites: true,
  retryReads: true,
  readPreference: 'secondaryPreferred', // Offload reads to replicas
});
```

### Caching Strategy

#### Multi-Layer Caching

```javascript
// cache.js
const redis = require('redis');
const NodeCache = require('node-cache');

// L1: In-memory cache (application level)
const memoryCache = new NodeCache({
  stdTTL: 60,        // 60 seconds TTL
  checkperiod: 120,  // Check for expired keys every 120s
  maxKeys: 10000,    // Max 10k keys
});

// L2: Redis cache (distributed)
const redisClient = redis.createClient({
  url: process.env.REDIS_URL,
  socket: {
    connectTimeout: 5000,
    keepAlive: 5000,
  },
  maxRetriesPerRequest: 3,
});

async function get(key) {
  // Try L1 cache first
  let value = memoryCache.get(key);
  if (value !== undefined) {
    return value;
  }
  
  // Try L2 cache
  value = await redisClient.get(key);
  if (value) {
    memoryCache.set(key, value);
    return value;
  }
  
  return null;
}

async function set(key, value, ttl = 300) {
  // Set in both caches
  memoryCache.set(key, value, ttl);
  await redisClient.setEx(key, ttl, value);
}
```

#### Cache Warming

```javascript
// cache-warmer.js
async function warmCache() {
  console.log('Warming cache...');
  
  // Pre-load frequently accessed data
  const popularItems = await db.query('SELECT * FROM popular_items LIMIT 1000');
  for (const item of popularItems) {
    await cache.set(`item:${item.id}`, JSON.stringify(item), 3600);
  }
  
  // Pre-load user sessions
  const activeSessions = await db.query('SELECT * FROM sessions WHERE last_active > NOW() - INTERVAL \'1 hour\'');
  for (const session of activeSessions) {
    await cache.set(`session:${session.id}`, JSON.stringify(session), 1800);
  }
  
  console.log('Cache warmed successfully');
}

// Run on startup and periodically
warmCache();
setInterval(warmCache, 30 * 60 * 1000); // Every 30 minutes
```

### Request Optimization

#### Compression

```javascript
// Enable gzip compression
const compression = require('compression');
app.use(compression({
  level: 6,  // Compression level (1-9)
  threshold: 1024, // Only compress if > 1KB
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));
```

#### Response Caching Headers

```javascript
// Add cache headers
app.use((req, res, next) => {
  if (req.method === 'GET') {
    // Cache static assets for 1 year
    if (req.url.match(/\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$/)) {
      res.set('Cache-Control', 'public, max-age=31536000, immutable');
    }
    // Cache API responses for 5 minutes
    else if (req.url.startsWith('/api/public/')) {
      res.set('Cache-Control', 'public, max-age=300');
    }
    // Don't cache private data
    else {
      res.set('Cache-Control', 'private, no-cache, no-store, must-revalidate');
    }
  }
  next();
});
```

#### Rate Limiting

```javascript
const rateLimit = require('express-rate-limit');

// General API rate limit
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // 1000 requests per window
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});

// Strict limit for authentication
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50,
  message: 'Too many authentication attempts',
});

app.use('/api/', apiLimiter);
app.use('/api/auth/', authLimiter);
```

## 3. Database Performance Tuning

### PostgreSQL Optimization

#### Index Optimization

```sql
-- Analyze slow queries
SELECT query, calls, mean_exec_time, max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  AND n_distinct > 100
  AND correlation < 0.1
ORDER BY n_distinct DESC;

-- Create index for frequently queried columns
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_orders_user_id ON orders(user_id);
CREATE INDEX CONCURRENTLY idx_orders_created_at ON orders(created_at DESC);

-- Composite indexes for multi-column queries
CREATE INDEX CONCURRENTLY idx_orders_user_status ON orders(user_id, status);
```

#### Query Optimization

```sql
-- Use EXPLAIN ANALYZE for query planning
EXPLAIN ANALYZE
SELECT o.*, u.email
FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.created_at > NOW() - INTERVAL '7 days'
  AND o.status = 'completed';

-- Optimize with materialized views for complex queries
CREATE MATERIALIZED VIEW daily_order_summary AS
SELECT DATE(created_at) as date,
       COUNT(*) as total_orders,
       SUM(total_amount) as revenue,
       AVG(total_amount) as avg_order_value
FROM orders
GROUP BY DATE(created_at);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY daily_order_summary;
```

#### PostgreSQL Configuration Tuning

```bash
# Edit postgresql.conf
kubectl edit configmap postgresql-config -n nexus-platform

# Key settings for performance
shared_buffers = 4GB                    # 25% of RAM
effective_cache_size = 12GB             # 75% of RAM
maintenance_work_mem = 1GB
work_mem = 64MB
max_connections = 500
random_page_cost = 1.1                  # For SSD
effective_io_concurrency = 200          # For SSD
wal_buffers = 16MB
checkpoint_completion_target = 0.9
max_wal_size = 4GB
min_wal_size = 1GB
max_worker_processes = 8
max_parallel_workers_per_gather = 4
max_parallel_workers = 8

# Apply changes
kubectl rollout restart statefulset/postgresql -n nexus-platform
```

### MongoDB Optimization

#### Index Creation

```javascript
// Create indexes
db.users.createIndex({ email: 1 }, { unique: true, background: true });
db.orders.createIndex({ userId: 1, createdAt: -1 }, { background: true });
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Compound index for complex queries
db.products.createIndex({ category: 1, price: 1, rating: -1 }, { background: true });

// Text index for full-text search
db.articles.createIndex({ title: "text", content: "text" });
```

#### Query Optimization

```javascript
// Use projection to return only needed fields
db.users.find(
  { status: 'active' },
  { _id: 1, name: 1, email: 1 }  // Only return these fields
);

// Use explain to analyze query
db.orders.find({ userId: 'user123' }).explain('executionStats');

// Use aggregation pipeline efficiently
db.orders.aggregate([
  { $match: { createdAt: { $gte: new Date('2024-01-01') } } },
  { $group: { _id: '$userId', total: { $sum: '$amount' } } },
  { $sort: { total: -1 } },
  { $limit: 100 }
]);
```

### Redis Optimization

#### Configuration Tuning

```bash
# redis.conf
maxmemory 8gb
maxmemory-policy allkeys-lru
tcp-backlog 511
timeout 300
tcp-keepalive 60
maxclients 10000

# Persistence (balance between performance and durability)
save 900 1      # Save if 1 key changed in 15 min
save 300 10     # Save if 10 keys changed in 5 min
save 60 10000   # Save if 10k keys changed in 1 min
appendonly yes
appendfsync everysec
```

#### Key Expiration Strategy

```javascript
// Set appropriate TTLs
await redis.setEx('user:session:123', 1800, sessionData);      // 30 min
await redis.setEx('api:cache:data', 300, apiData);              // 5 min
await redis.setEx('rate:limit:ip:1.2.3.4', 900, count);        // 15 min

// Clean up expired keys
await redis.del(await redis.keys('temp:*'));  // Avoid on production!
// Better: Use SCAN for cleanup
let cursor = '0';
do {
  const reply = await redis.scan(cursor, 'MATCH', 'temp:*', 'COUNT', 100);
  cursor = reply[0];
  const keys = reply[1];
  if (keys.length > 0) {
    await redis.del(...keys);
  }
} while (cursor !== '0');
```

## 4. Resource Optimization

### CPU Optimization

#### Right-Sizing Pods

```bash
# Check current CPU usage
kubectl top pods -n nexus-platform

# Analyze CPU usage patterns
curl -s 'http://prometheus:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total{namespace="nexus-platform"}[5m])'

# Adjust CPU limits based on usage
kubectl set resources deployment/backend-api -n nexus-platform \
  --requests=cpu=500m,memory=1Gi \
  --limits=cpu=1000m,memory=2Gi
```

#### CPU Affinity and Topology

```yaml
# Spread pods across nodes for high availability
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  template:
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            podAffinityTerm:
              labelSelector:
                matchExpressions:
                - key: app
                  operator: In
                  values:
                  - backend-api
              topologyKey: kubernetes.io/hostname
```

### Memory Optimization

#### Memory Leak Detection

```bash
# Monitor memory growth
kubectl top pod backend-api-xxxxx -n nexus-platform --containers

# Take heap dump for Node.js
kubectl exec -it backend-api-xxxxx -n nexus-platform -- node --inspect --heap-prof

# Analyze with Chrome DevTools or clinic.js
```

#### Memory Limits

```yaml
# Set appropriate memory limits
resources:
  requests:
    memory: "1Gi"
  limits:
    memory: "2Gi"  # 2x request for burst capacity

# Enable memory monitoring
env:
- name: NODE_OPTIONS
  value: "--max-old-space-size=1536"  # 75% of limit
```

### Network Optimization

#### Connection Pooling

```javascript
// HTTP connection pooling
const http = require('http');
const https = require('https');

const httpAgent = new http.Agent({
  keepAlive: true,
  maxSockets: 100,
  maxFreeSockets: 10,
  timeout: 60000,
  keepAliveMsecs: 30000
});

const httpsAgent = new https.Agent({
  keepAlive: true,
  maxSockets: 100,
  maxFreeSockets: 10,
  timeout: 60000,
  keepAliveMsecs: 30000
});

// Use agents in requests
axios.get(url, {
  httpAgent: httpAgent,
  httpsAgent: httpsAgent
});
```

#### CDN Configuration

```javascript
// Serve static assets from CDN
app.use('/static', express.static('public', {
  maxAge: '1y',
  immutable: true
}));

// Use CDN URLs in responses
const CDN_URL = 'https://cdn.nexuscos.online';
res.json({
  imageUrl: `${CDN_URL}/images/product.jpg`,
  scriptUrl: `${CDN_URL}/js/app.bundle.js`
});
```

## 5. Load Testing

### Running Load Tests

```bash
# Install k6
curl https://github.com/grafana/k6/releases/download/v0.45.0/k6-v0.45.0-linux-amd64.tar.gz -L | tar xvz

# Simple load test
k6 run --vus 100 --duration 5m load-test.js

# Staged load test
k6 run --stage 1m:10,5m:100,1m:0 load-test.js
```

#### Load Test Script

```javascript
// load-test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up to 100 users
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 200 },  // Ramp up to 200 users
    { duration: '5m', target: 200 },  // Stay at 200 users
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.01'],    // Error rate must be below 1%
  },
};

export default function () {
  const res = http.get('https://nexuscos.online/api/health');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

### Analyzing Results

```bash
# Generate HTML report
k6 run --out json=results.json load-test.js
# Use k6-reporter to generate HTML from JSON
```

## 6. Performance Checklist

### Before Deployment
- [ ] Run load tests
- [ ] Profile application for bottlenecks
- [ ] Review database query performance
- [ ] Check cache hit rates
- [ ] Verify resource limits are appropriate
- [ ] Enable compression
- [ ] Configure CDN for static assets
- [ ] Set up proper indexes

### Regular Tuning (Monthly)
- [ ] Review slow query logs
- [ ] Analyze memory usage patterns
- [ ] Check for N+1 query problems
- [ ] Review cache effectiveness
- [ ] Optimize indexes based on query patterns
- [ ] Update connection pool sizes
- [ ] Review and adjust rate limits

### Performance Issues
- [ ] Check monitoring dashboards
- [ ] Analyze slow traces in Jaeger
- [ ] Review database query performance
- [ ] Check cache hit rates
- [ ] Verify resource utilization
- [ ] Look for memory leaks
- [ ] Check for connection leaks

---

**Document Version**: 1.0  
**Last Updated**: December 2024  
**Owner**: DevOps Team

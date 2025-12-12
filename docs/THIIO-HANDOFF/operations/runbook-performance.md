# Performance Tuning Runbook

## Overview

This runbook provides performance optimization strategies, tuning procedures, and troubleshooting guidelines for the Nexus COS platform.

## Performance Targets

### Response Time Targets

| Service Type | p50 | p95 | p99 |
|--------------|-----|-----|-----|
| API Requests | < 50ms | < 200ms | < 500ms |
| Database Queries | < 10ms | < 50ms | < 100ms |
| Page Load | < 1s | < 2s | < 3s |
| Asset Load | < 100ms | < 300ms | < 500ms |

### Throughput Targets

- **API Gateway**: 10,000+ requests/second
- **Database**: 5,000+ queries/second
- **Streaming**: 1,000+ concurrent streams
- **WebSocket**: 50,000+ concurrent connections

## Application-Level Optimization

### Node.js Performance

#### Event Loop Monitoring

```javascript
// Check event loop lag
const { performance } = require('perf_hooks');

setInterval(() => {
  const start = performance.now();
  setImmediate(() => {
    const lag = performance.now() - start;
    if (lag > 100) {
      console.warn(`Event loop lag: ${lag}ms`);
    }
  });
}, 5000);
```

#### Memory Optimization

```bash
# Increase Node.js heap size
NODE_OPTIONS="--max-old-space-size=4096" node app.js

# Enable GC logging
NODE_OPTIONS="--trace-gc --trace-gc-verbose" node app.js

# Generate heap snapshot
kill -USR2 <node-process-pid>

# Analyze heap snapshot
node --inspect app.js
# Open chrome://inspect in Chrome
```

#### CPU Profiling

```bash
# CPU profile with clinic
npm install -g clinic
clinic doctor -- node app.js

# Profile with native Node.js
node --prof app.js
node --prof-process isolate-*.log > processed.txt
```

### API Optimization

#### Response Caching

```javascript
// Redis caching middleware
const cache = (duration) => async (req, res, next) => {
  const key = `cache:${req.originalUrl}`;
  const cached = await redis.get(key);
  
  if (cached) {
    return res.json(JSON.parse(cached));
  }
  
  res.sendResponse = res.json;
  res.json = (body) => {
    redis.setex(key, duration, JSON.stringify(body));
    res.sendResponse(body);
  };
  next();
};

// Usage
app.get('/api/users', cache(300), userController.list);
```

#### Query Optimization

```javascript
// Use select only needed fields
const users = await User.findAll({
  attributes: ['id', 'name', 'email'], // Don't fetch all fields
  where: { active: true }
});

// Use includes wisely
const users = await User.findAll({
  include: [{
    model: Profile,
    attributes: ['bio'], // Limit joined fields
    required: false // Use LEFT JOIN when appropriate
  }]
});

// Batch database calls
const userIds = [1, 2, 3, 4, 5];
const users = await User.findAll({
  where: { id: { [Op.in]: userIds } } // Single query instead of N queries
});
```

#### Connection Pooling

```javascript
// Optimize database pool
const pool = {
  max: 20, // Maximum connections
  min: 5,  // Minimum connections
  acquire: 30000, // Max time to get connection
  idle: 10000, // Max idle time before release
  evict: 1000 // Check for idle connections every 1s
};

const sequelize = new Sequelize(database, username, password, {
  pool,
  logging: false, // Disable in production
  benchmark: true  // Log query execution time
});
```

## Database Performance

### PostgreSQL Tuning

#### Configuration Optimization

```conf
# postgresql.conf
shared_buffers = 4GB              # 25% of RAM
effective_cache_size = 12GB       # 75% of RAM
maintenance_work_mem = 1GB
checkpoint_completion_target = 0.9
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 1.1            # For SSD
effective_io_concurrency = 200    # For SSD
work_mem = 20MB
min_wal_size = 1GB
max_wal_size = 4GB
max_worker_processes = 4
max_parallel_workers_per_gather = 2
max_parallel_workers = 4
```

#### Index Optimization

```sql
-- Find missing indexes
SELECT schemaname, tablename, attname, n_distinct, correlation
FROM pg_stats
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
  AND n_distinct > 100
ORDER BY n_distinct DESC;

-- Find unused indexes
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND schemaname NOT IN ('pg_catalog', 'information_schema');

-- Create composite index
CREATE INDEX CONCURRENTLY idx_users_email_active 
ON users(email, active) WHERE active = true;

-- Create partial index
CREATE INDEX CONCURRENTLY idx_orders_pending 
ON orders(created_at) WHERE status = 'pending';
```

#### Query Analysis

```sql
-- Enable query timing
\timing on

-- Analyze query plan
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE email = 'test@example.com';

-- Find slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 1000
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Vacuum analysis
SELECT schemaname, tablename, last_vacuum, last_autovacuum, n_dead_tup
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;

-- Run vacuum
VACUUM ANALYZE users;
```

### Redis Optimization

```bash
# Redis configuration
maxmemory 2gb
maxmemory-policy allkeys-lru
tcp-backlog 511
timeout 300
tcp-keepalive 60

# Check memory usage
redis-cli info memory

# Find large keys
redis-cli --bigkeys

# Monitor commands
redis-cli monitor

# Slow log
redis-cli slowlog get 10
```

## Infrastructure Optimization

### Kubernetes Resource Limits

```yaml
# Optimized resource limits
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: app
        resources:
          requests:
            cpu: "500m"      # Guaranteed CPU
            memory: "512Mi"  # Guaranteed memory
          limits:
            cpu: "2000m"     # Max CPU (burst)
            memory: "2Gi"    # Max memory (hard limit)
        # Horizontal Pod Autoscaler will scale based on these
```

### Horizontal Pod Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### Network Optimization

#### Nginx Tuning

```nginx
# nginx.conf
worker_processes auto;
worker_rlimit_nofile 65535;

events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

http {
    # Connection optimization
    keepalive_timeout 65;
    keepalive_requests 100;
    
    # Compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss;
    
    # Caching
    proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m 
                     max_size=10g inactive=60m use_temp_path=off;
    
    # Buffer sizes
    client_body_buffer_size 128k;
    client_max_body_size 50m;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;
    
    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    send_timeout 10;
    
    # File handling
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/s;
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    
    server {
        listen 80;
        
        location /api/ {
            limit_req zone=api_limit burst=20 nodelay;
            limit_conn addr 10;
            
            proxy_pass http://backend;
            proxy_cache my_cache;
            proxy_cache_valid 200 10m;
            proxy_cache_use_stale error timeout http_500 http_502 http_503;
        }
        
        location /static/ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

## Frontend Optimization

### Build Optimization

```javascript
// vite.config.js
export default {
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom'],
          'ui': ['@mui/material'],
          'utils': ['lodash', 'axios']
        }
      }
    },
    chunkSizeWarningLimit: 1000,
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    }
  },
  server: {
    hmr: {
      overlay: false
    }
  }
};
```

### Code Splitting

```javascript
// Lazy load routes
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<Loading />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Asset Optimization

```bash
# Image optimization
npm install -g sharp-cli
sharp -i input.jpg -o output.jpg --quality 80 --progressive

# Generate WebP
sharp -i input.jpg -o output.webp

# SVG optimization
npx svgo --multipass input.svg output.svg
```

## Load Testing

### Artillery.io

```yaml
# load-test.yml
config:
  target: 'https://api.nexuscos.example.com'
  phases:
    - duration: 60
      arrivalRate: 10
      name: Warm up
    - duration: 300
      arrivalRate: 100
      name: Sustained load
    - duration: 120
      arrivalRate: 500
      name: Spike test
scenarios:
  - name: "API Load Test"
    flow:
      - get:
          url: "/api/v1/users"
          headers:
            Authorization: "Bearer {{ token }}"
      - think: 2
      - post:
          url: "/api/v1/content"
          json:
            title: "Test Content"
```

```bash
# Run load test
artillery run load-test.yml --output report.json
artillery report report.json
```

## Performance Monitoring

### Key Metrics

```bash
# Request latency histogram
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, service)
)

# Throughput
sum(rate(http_requests_total[5m])) by (service)

# Error rate
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m]))

# Saturation
avg(rate(container_cpu_usage_seconds_total[5m])) by (pod)
```

## Troubleshooting Slow Performance

### Checklist

1. **Check dashboards**: Grafana overview
2. **Review logs**: Look for errors/warnings
3. **Database**: Check for slow queries
4. **CPU/Memory**: Check resource usage
5. **Network**: Check latency between services
6. **Cache**: Verify cache hit rates
7. **External APIs**: Check third-party response times

### Common Bottlenecks

- N+1 database queries
- Missing database indexes
- Large payload sizes
- No caching strategy
- Synchronous blocking operations
- Memory leaks
- Connection pool exhaustion

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Review Frequency**: Monthly

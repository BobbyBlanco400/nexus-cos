import { Application } from 'express';
import promClient from 'prom-client';

const register = new promClient.Registry();

// Default metrics
promClient.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const activeSessions = new promClient.Gauge({
  name: 'v_supercore_active_sessions',
  help: 'Number of active virtual PC sessions',
  registers: [register]
});

const resourceAllocation = new promClient.Gauge({
  name: 'v_supercore_resource_allocation',
  help: 'Total resource allocation',
  labelNames: ['resource_type'],
  registers: [register]
});

export function setupMetrics(app: Application) {
  // Metrics endpoint
  app.get('/metrics', async (req, res) => {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  });
  
  // Request duration middleware
  app.use((req, res, next) => {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = (Date.now() - start) / 1000;
      httpRequestDuration
        .labels(req.method, req.route?.path || req.path, res.statusCode.toString())
        .observe(duration);
    });
    
    next();
  });
  
  console.log('✅ Metrics initialized');
}

export {
  register,
  httpRequestDuration,
  activeSessions,
  resourceAllocation
};

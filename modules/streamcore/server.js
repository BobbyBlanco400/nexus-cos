const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const winston = require('winston');
const promClient = require('prom-client');
const os = require('os');
const fs = require('fs').promises;
const path = require('path');

require('dotenv').config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/v-suite-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/v-suite.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'v_suite_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const environmentCounter = new promClient.Counter({
  name: 'v_suite_environments_total',
  help: 'Total number of virtual environments created'
});

const activeEnvironmentsGauge = new promClient.Gauge({
  name: 'v_suite_active_environments',
  help: 'Number of currently active virtual environments'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(environmentCounter);
register.registerMetric(activeEnvironmentsGauge);

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api/', limiter);

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
    
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: duration,
      ip: req.ip
    });
  });
  next();
});

// Virtual Environment Management
class VirtualEnvironmentManager {
  constructor() {
    this.environments = new Map();
    this.resourceMonitor = new Map();
  }

  async createEnvironment(config) {
    const envId = `env_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const environment = {
      id: envId,
      name: config.name || `Environment ${envId}`,
      type: config.type || 'development',
      status: 'creating',
      resources: {
        cpu: config.cpu || 2,
        memory: config.memory || 4096,
        storage: config.storage || 20480
      },
      created: new Date(),
      lastAccessed: new Date(),
      config: config
    };

    this.environments.set(envId, environment);
    environmentCounter.inc();
    activeEnvironmentsGauge.inc();

    // Simulate environment creation
    setTimeout(() => {
      environment.status = 'running';
      this.startResourceMonitoring(envId);
      io.emit('environment_status', { id: envId, status: 'running' });
    }, 2000);

    return environment;
  }

  startResourceMonitoring(envId) {
    const interval = setInterval(() => {
      const env = this.environments.get(envId);
      if (!env || env.status !== 'running') {
        clearInterval(interval);
        return;
      }

      const usage = {
        cpu: Math.random() * 100,
        memory: Math.random() * env.resources.memory,
        storage: Math.random() * env.resources.storage,
        timestamp: new Date()
      };

      this.resourceMonitor.set(envId, usage);
      io.emit('resource_update', { envId, usage });
    }, 5000);
  }

  async getEnvironment(envId) {
    return this.environments.get(envId);
  }

  async listEnvironments() {
    return Array.from(this.environments.values());
  }

  async deleteEnvironment(envId) {
    const env = this.environments.get(envId);
    if (env) {
      this.environments.delete(envId);
      this.resourceMonitor.delete(envId);
      activeEnvironmentsGauge.dec();
      return true;
    }
    return false;
  }

  getResourceUsage(envId) {
    return this.resourceMonitor.get(envId);
  }
}

const envManager = new VirtualEnvironmentManager();

// API Routes
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'V-Suite Virtual Environment Management',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environments: envManager.environments.size
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Environment Management API
app.post('/api/environments', [
  body('name').isLength({ min: 1 }).withMessage('Name is required'),
  body('type').isIn(['development', 'staging', 'production']).withMessage('Invalid environment type')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const environment = await envManager.createEnvironment(req.body);
    res.status(201).json({
      success: true,
      environment: environment
    });
  } catch (error) {
    logger.error('Error creating environment:', error);
    res.status(500).json({ error: 'Failed to create environment' });
  }
});

app.get('/api/environments', async (req, res) => {
  try {
    const environments = await envManager.listEnvironments();
    res.json({
      success: true,
      environments: environments
    });
  } catch (error) {
    logger.error('Error listing environments:', error);
    res.status(500).json({ error: 'Failed to list environments' });
  }
});

app.get('/api/environments/:id', async (req, res) => {
  try {
    const environment = await envManager.getEnvironment(req.params.id);
    if (!environment) {
      return res.status(404).json({ error: 'Environment not found' });
    }

    const resourceUsage = envManager.getResourceUsage(req.params.id);
    res.json({
      success: true,
      environment: environment,
      resourceUsage: resourceUsage
    });
  } catch (error) {
    logger.error('Error getting environment:', error);
    res.status(500).json({ error: 'Failed to get environment' });
  }
});

app.delete('/api/environments/:id', async (req, res) => {
  try {
    const deleted = await envManager.deleteEnvironment(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Environment not found' });
    }

    res.json({
      success: true,
      message: 'Environment deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting environment:', error);
    res.status(500).json({ error: 'Failed to delete environment' });
  }
});

// System Analytics API
app.get('/api/analytics', async (req, res) => {
  try {
    const systemInfo = {
      cpu: os.cpus(),
      memory: {
        total: os.totalmem(),
        free: os.freemem(),
        used: os.totalmem() - os.freemem()
      },
      uptime: os.uptime(),
      platform: os.platform(),
      arch: os.arch()
    };

    res.json({
      success: true,
      system: systemInfo,
      environments: {
        total: envManager.environments.size,
        active: Array.from(envManager.environments.values()).filter(env => env.status === 'running').length
      }
    });
  } catch (error) {
    logger.error('Error getting analytics:', error);
    res.status(500).json({ error: 'Failed to get analytics' });
  }
});

// WebSocket connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('subscribe_environment', (envId) => {
    socket.join(`env_${envId}`);
    logger.info(`Client ${socket.id} subscribed to environment ${envId}`);
  });

  socket.on('unsubscribe_environment', (envId) => {
    socket.leave(`env_${envId}`);
    logger.info(`Client ${socket.id} unsubscribed from environment ${envId}`);
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

const PORT = process.env.PORT || 3010;
const HOST = process.env.HOST || '0.0.0.0';

server.listen(PORT, HOST, () => {
  logger.info(`V-Suite Virtual Environment Management Server running on ${HOST}:${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = app;
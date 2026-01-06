#!/usr/bin/env node

/**
 * Backend Health Fix and CORS Configuration
 * Adds enhanced error handling and CORS headers to prevent 502 errors
 */

const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

class BackendHealthFix {
  constructor() {
    this.app = express();
    this.setupMiddleware();
    this.setupRoutes();
  }

  setupMiddleware() {
    // Enhanced CORS configuration
    const corsOptions = {
      origin: [
        'https://beta.n3xuscos.online',
        'https://n3xuscos.online',
        'http://localhost:3000',
        'http://localhost:3001',
        'http://localhost',
        /\.nexuscos\.online$/
      ],
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: [
        'Origin',
        'X-Requested-With',
        'Content-Type',
        'Accept',
        'Authorization',
        'X-Real-IP',
        'X-Forwarded-For',
        'X-Forwarded-Proto'
      ],
      credentials: true,
      optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
    };

    this.app.use(cors(corsOptions));
    
    // Parse JSON bodies
    this.app.use(express.json({ limit: '10mb' }));
    this.app.use(express.urlencoded({ extended: true, limit: '10mb' }));
    
    // Request logging
    this.app.use(morgan('combined'));
    
    // Add security headers
    this.app.use((req, res, next) => {
      res.header('X-Powered-By', 'Nexus COS Beta');
      res.header('X-Content-Type-Options', 'nosniff');
      res.header('X-Frame-Options', 'SAMEORIGIN');
      res.header('X-XSS-Protection', '1; mode=block');
      next();
    });
    
    // Enhanced error handling middleware
    this.app.use((err, req, res, next) => {
      console.error('Backend Error:', {
        timestamp: new Date().toISOString(),
        error: err.message,
        stack: err.stack,
        url: req.url,
        method: req.method,
        headers: req.headers,
        body: req.body
      });
      
      res.status(err.status || 500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
        timestamp: new Date().toISOString(),
        requestId: req.headers['x-request-id'] || 'unknown'
      });
    });
  }

  setupRoutes() {
    // Enhanced health check endpoint
    this.app.get('/health', (req, res) => {
      const healthData = {
        status: 'ok',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development',
        version: '1.0.0',
        services: {
          database: 'connected', // Update with actual DB check
          cache: 'connected',     // Update with actual cache check
          memory: {
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB'
          },
          cpu: process.cpuUsage()
        }
      };
      
      res.json(healthData);
    });

    // Debug endpoint for troubleshooting
    this.app.get('/debug', (req, res) => {
      res.json({
        message: 'Debug endpoint active',
        timestamp: new Date().toISOString(),
        headers: req.headers,
        query: req.query,
        environment: process.env.NODE_ENV || 'development',
        nodeVersion: process.version,
        platform: process.platform,
        arch: process.arch
      });
    });

    // Enhanced API routes with better error handling
    this.app.use('/api', (req, res, next) => {
      // Add request ID for tracing
      req.headers['x-request-id'] = req.headers['x-request-id'] || 
        Math.random().toString(36).substr(2, 9);
      
      console.log(`API Request: ${req.method} ${req.path}`, {
        requestId: req.headers['x-request-id'],
        timestamp: new Date().toISOString(),
        userAgent: req.headers['user-agent'],
        origin: req.headers.origin
      });
      
      next();
    });

    // Sample API endpoints for testing
    this.app.get('/api/status', (req, res) => {
      res.json({
        status: 'online',
        message: 'Nexus COS Beta API is running',
        timestamp: new Date().toISOString(),
        requestId: req.headers['x-request-id']
      });
    });

    this.app.get('/api/test', (req, res) => {
      res.json({
        message: 'Test endpoint working',
        data: {
          timestamp: new Date().toISOString(),
          requestId: req.headers['x-request-id'],
          environment: 'beta'
        }
      });
    });

    // 404 handler
    this.app.use((req, res) => {
      res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} not found`,
        timestamp: new Date().toISOString(),
        requestId: req.headers['x-request-id'] || 'unknown'
      });
    });
  }

  start(port = 3000) {
    const server = this.app.listen(port, '0.0.0.0', () => {
      console.log(`🚀 Nexus COS Backend Health Fix Server running on port ${port}`);
      console.log(`🔗 Health check: http://localhost:${port}/health`);
      console.log(`🔗 Debug endpoint: http://localhost:${port}/debug`);
      console.log(`📊 API status: http://localhost:${port}/api/status`);
      console.log(`⏰ Started at: ${new Date().toISOString()}`);
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      console.log('SIGTERM received, shutting down gracefully');
      server.close(() => {
        console.log('Process terminated');
        process.exit(0);
      });
    });

    process.on('SIGINT', () => {
      console.log('SIGINT received, shutting down gracefully');
      server.close(() => {
        console.log('Process terminated');
        process.exit(0);
      });
    });

    return server;
  }
}

// Create and export the health fix class
const healthFix = new BackendHealthFix();

// Start server if this file is run directly
if (require.main === module) {
  const port = process.env.PORT || 3000;
  healthFix.start(port);
}

module.exports = BackendHealthFix;
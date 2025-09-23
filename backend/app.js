// NEXUS COS Node.js Backend Server
// Main application entry point

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const healthRouter = require('./health');

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'production';

// Security middleware
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", "data:", "https:"],
        },
    },
}));

// CORS configuration
app.use(cors({
    origin: process.env.FRONTEND_URL || 'https://nexuscos.online',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: {
        error: 'Too many requests from this IP, please try again later.',
        status: 429
    }
});
app.use('/api/', limiter);

// Compression middleware
app.use(compression());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`${timestamp} - ${req.method} ${req.path} - IP: ${req.ip}`);
    next();
});

// Health check routes (mounted at root level)
app.use('/', healthRouter);

// API routes
app.get('/api/status', (req, res) => {
    res.json({
        status: 'ok',
        service: 'nexus-cos-api',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        environment: NODE_ENV
    });
});

// API info endpoint
app.get('/api/info', (req, res) => {
    res.json({
        name: 'NEXUS COS API',
        version: '1.0.0',
        description: 'PUABO OS 2025 Backend API',
        environment: NODE_ENV,
        node_version: process.version,
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

// User management endpoints (placeholder)
app.get('/api/users', (req, res) => {
    res.json({
        users: [],
        message: 'User management endpoint - implementation pending',
        timestamp: new Date().toISOString()
    });
});

// System endpoints (placeholder)
app.get('/api/system', (req, res) => {
    res.json({
        system: {
            platform: process.platform,
            arch: process.arch,
            node_version: process.version,
            memory_usage: process.memoryUsage(),
            uptime: process.uptime()
        },
        timestamp: new Date().toISOString()
    });
});

// File upload endpoint (placeholder)
app.post('/api/upload', (req, res) => {
    res.json({
        message: 'File upload endpoint - implementation pending',
        timestamp: new Date().toISOString()
    });
});

// WebSocket support placeholder
app.get('/api/ws', (req, res) => {
    res.json({
        message: 'WebSocket endpoint - implementation pending',
        timestamp: new Date().toISOString()
    });
});

// 404 handler for API routes
app.use('/api/*', (req, res) => {
    res.status(404).json({
        error: 'API endpoint not found',
        path: req.path,
        method: req.method,
        timestamp: new Date().toISOString()
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Error:', err.stack);
    
    const isDevelopment = NODE_ENV === 'development';
    
    res.status(err.status || 500).json({
        error: err.message || 'Internal Server Error',
        status: err.status || 500,
        timestamp: new Date().toISOString(),
        ...(isDevelopment && { stack: err.stack })
    });
});

// Graceful shutdown handling
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

// Start server
const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 NEXUS COS Node.js Backend started`);
    console.log(`📡 Server running on port ${PORT}`);
    console.log(`🌍 Environment: ${NODE_ENV}`);
    console.log(`⏰ Started at: ${new Date().toISOString()}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
    console.log(`📊 API status: http://localhost:${PORT}/api/status`);
});

module.exports = app;
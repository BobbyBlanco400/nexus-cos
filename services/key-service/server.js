// Nexus COS - key-service
// Port: 3014
// Auto-generated service
// N3XUS Handshake 55-45-17 Compliant

const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3014;

// N3XUS Handshake Middleware (55-45-17)
const { setHandshakeResponse, validateHandshakeConditional } = require(path.join(__dirname, '../../middleware/handshake-validator'));

app.use(express.json());

// N3XUS Governance: Apply handshake to all responses and validate on all non-health endpoints
app.use(setHandshakeResponse);
app.use(validateHandshakeConditional);

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'key-service',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'key-service',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'key-service is running',
        endpoints: ['/health', '/status'],
        port: port
    });
});

// Start server
app.listen(port, () => {
    console.log(`✓ key-service running on port ${port}`);
    console.log(`  Health check: http://localhost:${port}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});

module.exports = app;

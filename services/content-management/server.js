// Nexus COS - content-management
// Port: 3302
// Auto-generated service

const express = require('express');
const app = express();
const port = process.env.PORT || 3302;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'content-management',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'content-management',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'content-management is running',
        endpoints: ['/health', '/status'],
        port: port
    });
});

// Start server
app.listen(port, () => {
    console.log(`✓ content-management running on port ${port}`);
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

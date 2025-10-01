// Nexus COS - nexus-cos-studio-ai
// Port: 3402
// Auto-generated service

const express = require('express');
const app = express();
const port = process.env.PORT || 3402;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'nexus-cos-studio-ai',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'nexus-cos-studio-ai',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'nexus-cos-studio-ai is running',
        endpoints: ['/health', '/status'],
        port: port
    });
});

// Start server
app.listen(port, () => {
    console.log(`✓ nexus-cos-studio-ai running on port ${port}`);
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

// Nexus COS - v-prompter-pro
// Port: 3502
// Professional teleprompter service
// N3XUS Handshake 55-45-17 Compliant

const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3502;

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
        service: 'v-prompter-pro',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        features: ['teleprompter', 'script-management', 'real-time-sync', 'multi-device']
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'v-prompter-pro',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port,
        capabilities: {
            maxScripts: 100,
            supportedFormats: ['TXT', 'DOCX', 'PDF'],
            features: ['Auto-scroll', 'Remote control', 'Mirror mode']
        }
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'v-prompter-pro is running',
        description: 'Professional teleprompter service for video production',
        endpoints: ['/health', '/status', '/api/scripts', '/api/prompter'],
        port: port
    });
});

// API endpoints
app.get('/api/scripts', (req, res) => {
    res.json({
        message: 'Scripts management API endpoint',
        status: 'ready'
    });
});

app.get('/api/prompter', (req, res) => {
    res.json({
        message: 'Prompter control API endpoint',
        status: 'ready'
    });
});

// Start server
const server = app.listen(port, () => {
    console.log(`✓ v-prompter-pro running on port ${port}`);
    console.log(`  Health check: http://localhost:${port}/health`);
    console.log(`  Service: Professional Teleprompter`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});

module.exports = app;

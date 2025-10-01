// Nexus COS - v-screen-pro
// Port: 3503
// Professional screen capture and recording service

const express = require('express');
const app = express();
const port = process.env.PORT || 3503;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'v-screen-pro',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        features: ['screen-capture', 'recording', 'streaming', 'annotations']
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'v-screen-pro',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port,
        capabilities: {
            maxResolution: '4K',
            supportedFormats: ['MP4', 'WebM', 'AVI'],
            features: ['Real-time preview', 'Audio capture', 'Multi-display']
        }
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'v-screen-pro is running',
        description: 'Professional screen capture and recording service',
        endpoints: ['/health', '/status', '/api/capture', '/api/record'],
        port: port
    });
});

// API endpoints
app.get('/api/capture', (req, res) => {
    res.json({
        message: 'Screen capture API endpoint',
        status: 'ready'
    });
});

app.get('/api/record', (req, res) => {
    res.json({
        message: 'Recording API endpoint',
        status: 'ready'
    });
});

// Start server
const server = app.listen(port, () => {
    console.log(`✓ v-screen-pro running on port ${port}`);
    console.log(`  Health check: http://localhost:${port}/health`);
    console.log(`  Service: Professional Screen Capture & Recording`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});

module.exports = app;

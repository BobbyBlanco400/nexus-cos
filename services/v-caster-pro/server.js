// Nexus COS - v-caster-pro
// Port: 3501
// Video casting and broadcasting service (Pro version)

const express = require('express');
const app = express();
const port = process.env.PORT || 3501;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'v-caster-pro',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        features: ['casting', 'broadcasting', 'streaming', 'recording']
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'v-caster-pro',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port,
        capabilities: {
            maxStreams: 10,
            supportedFormats: ['RTMP', 'HLS', 'DASH'],
            encoding: ['H.264', 'H.265', 'VP9']
        }
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'v-caster-pro is running',
        description: 'Professional video casting and broadcasting service',
        endpoints: ['/health', '/status', '/api/cast', '/api/broadcast'],
        port: port
    });
});

// API endpoints
app.get('/api/cast', (req, res) => {
    res.json({
        message: 'Casting API endpoint',
        status: 'ready'
    });
});

app.get('/api/broadcast', (req, res) => {
    res.json({
        message: 'Broadcasting API endpoint',
        status: 'ready'
    });
});

// Start server
const server = app.listen(port, () => {
    console.log(`✓ v-caster-pro running on port ${port}`);
    console.log(`  Health check: http://localhost:${port}/health`);
    console.log(`  Service: Professional Video Casting & Broadcasting`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});

module.exports = app;

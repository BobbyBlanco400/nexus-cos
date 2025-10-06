// Nexus COS - vscreen-hollywood
// V-Screen Hollywood Edition
// Port: 8088
// Browser-based Virtual LED Volume/Virtual Production Suite

const express = require('express');
const cors = require('cors');
const WebSocket = require('ws');

const app = express();
const port = process.env.PORT || 8088;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint - matches expected response from problem statement
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'vscreen-hollywood'
    });
});

// Status endpoint with detailed information
app.get('/status', (req, res) => {
    res.json({
        service: 'vscreen-hollywood',
        version: '1.0.0',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port,
        features: [
            'browser-based LED volume rendering',
            'virtual production controls (lighting, VFX, scene presets)',
            'OTT/IPTV-ready output',
            'multi-user collaboration',
            'gpu-accelerated cloud rendering'
        ],
        protocols: ['webrtc', 'hls', 'dash', 'websocket'],
        integrations: {
            streamcore: 'enabled',
            puaboAiSdk: 'enabled',
            nexusAuth: 'enabled'
        }
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'V-Screen Hollywood Edition',
        description: 'World\'s first and largest browser-based Virtual LED Volume/Virtual Production Suite',
        version: '1.0.0',
        endpoints: [
            '/health',
            '/status',
            '/api/led-volume',
            '/api/production',
            '/api/stream'
        ],
        port: port
    });
});

// LED Volume API endpoints
app.get('/api/led-volume', (req, res) => {
    res.json({
        message: 'LED Volume Management API',
        status: 'ready',
        capabilities: [
            'Virtual LED wall rendering',
            'Environment mapping',
            'Real-time tracking',
            'Color grading'
        ]
    });
});

app.post('/api/led-volume/create', (req, res) => {
    res.json({
        success: true,
        message: 'Virtual LED volume created',
        volumeId: `vol-${Date.now()}`
    });
});

// Virtual Production Controls
app.get('/api/production', (req, res) => {
    res.json({
        message: 'Virtual Production Controls API',
        status: 'ready',
        controls: {
            lighting: ['key', 'fill', 'rim', 'background'],
            vfx: ['particles', 'weather', 'atmospherics'],
            scenePresets: ['studio', 'outdoor', 'indoor', 'custom']
        }
    });
});

app.post('/api/production/preset', (req, res) => {
    const { preset } = req.body;
    res.json({
        success: true,
        message: `Production preset applied: ${preset || 'default'}`,
        preset: preset || 'default'
    });
});

// Streaming integration endpoint
app.get('/api/stream', (req, res) => {
    res.json({
        message: 'Streaming Integration API',
        status: 'ready',
        streamcore: 'connected',
        outputFormats: ['HLS', 'DASH', 'RTMP'],
        ottIptv: 'enabled'
    });
});

app.post('/api/stream/start', (req, res) => {
    res.json({
        success: true,
        message: 'Stream started',
        streamId: `stream-${Date.now()}`,
        url: 'rtmp://streamcore/live'
    });
});

// Collaboration endpoint
app.get('/api/collaboration', (req, res) => {
    res.json({
        message: 'Multi-user Collaboration API',
        status: 'ready',
        maxUsers: 10,
        features: ['Real-time sync', 'Role-based access', 'Live preview']
    });
});

// Start HTTP server
const server = app.listen(port, () => {
    console.log(`✓ vscreen-hollywood running on port ${port}`);
    console.log(`  V-Screen Hollywood Edition - Virtual LED Volume/Virtual Production Suite`);
    console.log(`  Health check: http://localhost:${port}/health`);
    console.log(`  Status: http://localhost:${port}/status`);
    console.log(`  Features: LED volume rendering, Virtual production, OTT/IPTV streaming`);
});

// WebSocket server for real-time collaboration
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
    console.log('New WebSocket connection established for V-Screen Hollywood');
    
    // Send initial connection message
    ws.send(JSON.stringify({
        type: 'connection',
        message: 'Connected to V-Screen Hollywood Edition',
        timestamp: new Date().toISOString()
    }));

    // Handle incoming messages
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            console.log('Received WebSocket message:', data.type);
            
            // Echo back for testing
            ws.send(JSON.stringify({
                type: 'response',
                originalMessage: data,
                timestamp: new Date().toISOString()
            }));
        } catch (error) {
            console.error('WebSocket message error:', error);
        }
    });

    ws.on('close', () => {
        console.log('WebSocket connection closed');
    });

    ws.on('error', (error) => {
        console.error('WebSocket error:', error);
    });
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        wss.close(() => {
            console.log('WebSocket server closed');
        });
    });
});

module.exports = app;

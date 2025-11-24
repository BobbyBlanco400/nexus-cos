// Nexus COS - Socket.IO Streaming Service
// Port: 3043
// Handles WebSocket connections for streaming functionality

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Configure CORS
const allowedOrigins = process.env.CORS_ORIGIN 
    ? process.env.CORS_ORIGIN.split(',')
    : ['https://nexuscos.online', 'https://www.nexuscos.online'];

app.use(cors({
    origin: function (origin, callback) {
        // Allow requests with no origin (mobile apps, curl, etc.)
        if (!origin) return callback(null, true);
        
        if (allowedOrigins.includes('*') || allowedOrigins.indexOf(origin) !== -1) {
            callback(null, true);
        } else {
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ['GET', 'POST'],
    credentials: true
}));

app.use(express.json());

const port = process.env.PORT || 3043;

// Initialize Socket.IO with both path configurations
const io = new Server(server, {
    cors: {
        origin: function (origin, callback) {
            if (!origin) return callback(null, true);
            
            if (allowedOrigins.includes('*') || allowedOrigins.indexOf(origin) !== -1) {
                callback(null, true);
            } else {
                callback(new Error('Not allowed by CORS'));
            }
        },
        methods: ['GET', 'POST'],
        credentials: true
    },
    path: '/socket.io/',
    transports: ['websocket', 'polling']
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'socket-io-streaming',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        connections: io.engine.clientsCount || 0
    });
});

// Status endpoint
app.get('/status', (req, res) => {
    res.json({
        service: 'socket-io-streaming',
        status: 'running',
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        port: port,
        socketio: {
            connected: io.engine.clientsCount || 0,
            path: '/socket.io/'
        }
    });
});

// Basic info endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Socket.IO Streaming Service is running',
        endpoints: ['/health', '/status', '/socket.io/'],
        port: port,
        socketio: {
            path: '/socket.io/',
            transports: ['websocket', 'polling']
        }
    });
});

// Handle /streaming path for health checks
app.get('/streaming/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'socket-io-streaming',
        path: '/streaming',
        timestamp: new Date().toISOString()
    });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
    console.log(`[${new Date().toISOString()}] Client connected: ${socket.id}`);
    
    // Handle streaming events
    socket.on('stream:start', (data) => {
        console.log(`[${new Date().toISOString()}] Stream started:`, data);
        socket.emit('stream:started', { status: 'ok', streamId: data.streamId });
    });
    
    socket.on('stream:data', (data) => {
        // Broadcast stream data to all connected clients except sender
        socket.broadcast.emit('stream:data', data);
    });
    
    socket.on('stream:stop', (data) => {
        console.log(`[${new Date().toISOString()}] Stream stopped:`, data);
        socket.emit('stream:stopped', { status: 'ok', streamId: data.streamId });
    });
    
    socket.on('disconnect', () => {
        console.log(`[${new Date().toISOString()}] Client disconnected: ${socket.id}`);
    });
    
    // Generic message handling
    socket.on('message', (data) => {
        console.log(`[${new Date().toISOString()}] Message received:`, data);
        socket.broadcast.emit('message', data);
    });
});

// Start server
server.listen(port, () => {
    console.log(`✓ Socket.IO Streaming Service running on port ${port}`);
    console.log(`  Health check: http://localhost:${port}/health`);
    console.log(`  Socket.IO path: /socket.io/`);
    console.log(`  Transports: websocket, polling`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing server');
    io.close(() => {
        server.close(() => {
            console.log('Server closed');
            process.exit(0);
        });
    });
});

process.on('SIGINT', () => {
    console.log('SIGINT signal received: closing server');
    io.close(() => {
        server.close(() => {
            console.log('Server closed');
            process.exit(0);
        });
    });
});

module.exports = { app, server, io };

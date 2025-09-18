const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { Server } = require('socket.io');
const http = require('http');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3003;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// PuaboVerse Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'PuaboVerse',
    features: ['Metaverse Worlds', 'Avatar System', 'Virtual Reality', 'Social Spaces'],
    timestamp: new Date().toISOString()
  });
});

app.get('/worlds', (req, res) => {
  res.json({
    worlds: [
      { id: 1, name: 'Nexus Plaza', users: 25, type: 'social' },
      { id: 2, name: 'Creator Space', users: 12, type: 'creative' },
      { id: 3, name: 'Virtual Office', users: 8, type: 'business' }
    ]
  });
});

app.get('/avatars', (req, res) => {
  res.json({
    avatars: [
      { id: 1, name: 'Default Avatar', style: 'realistic' },
      { id: 2, name: 'Cartoon Avatar', style: 'stylized' },
      { id: 3, name: 'Robot Avatar', style: 'futuristic' }
    ]
  });
});

// Socket.IO for real-time metaverse interactions
io.on('connection', (socket) => {
  console.log('🌐 User connected to PuaboVerse:', socket.id);
  
  socket.on('join_world', (worldId) => {
    socket.join(`world_${worldId}`);
    socket.to(`world_${worldId}`).emit('user_joined', { userId: socket.id });
  });
  
  socket.on('avatar_move', (data) => {
    socket.to(`world_${data.worldId}`).emit('avatar_moved', {
      userId: socket.id,
      position: data.position
    });
  });
  
  socket.on('disconnect', () => {
    console.log('🌐 User disconnected from PuaboVerse:', socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`🌐 PuaboVerse running on port ${PORT}`);
  console.log(`📍 Health: http://localhost:${PORT}/health`);
});
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const http = require('http');
const socketIo = require('socket.io');
require('dotenv').config();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3030;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// In-memory storage for demo (use database in production)
let virtualWorlds = new Map();
let activeUsers = new Map();

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', module: 'PuaboVerse', version: '1.0.0' });
});

// PuaboVerse API endpoints
app.get('/api/puaboverse/status', (req, res) => {
  res.json({
    status: 'active',
    features: [
      'Virtual World Creation',
      'Avatar Management',
      'Real-time Interaction',
      'Physics Simulation',
      'Multi-user Environments'
    ],
    activeWorlds: virtualWorlds.size,
    connectedUsers: activeUsers.size,
    uptime: process.uptime()
  });
});

app.get('/api/puaboverse/worlds', (req, res) => {
  const worlds = Array.from(virtualWorlds.values()).map(world => ({
    id: world.id,
    name: world.name,
    description: world.description,
    theme: world.theme,
    capacity: world.capacity,
    currentUsers: world.users ? world.users.length : 0,
    created: world.created,
    isPublic: world.isPublic
  }));

  res.json({ worlds });
});

app.post('/api/puaboverse/worlds', (req, res) => {
  const { name, description, theme, capacity } = req.body;
  
  const newWorld = {
    id: `world-${Date.now()}`,
    name: name || 'New Virtual World',
    description: description || 'A new virtual environment',
    theme: theme || 'default',
    capacity: capacity || 50,
    users: [],
    created: new Date().toISOString(),
    isPublic: true,
    environment: {
      lighting: 'dynamic',
      weather: 'clear',
      timeOfDay: 'midday',
      gravity: 9.81
    }
  };

  virtualWorlds.set(newWorld.id, newWorld);
  res.status(201).json({ success: true, world: newWorld });
});

app.get('/api/puaboverse/worlds/:worldId', (req, res) => {
  const world = virtualWorlds.get(req.params.worldId);
  if (!world) {
    return res.status(404).json({ error: 'World not found' });
  }
  res.json({ world });
});

app.get('/api/puaboverse/avatars', (req, res) => {
  res.json({
    avatars: [
      {
        id: 'avatar-001',
        name: 'Nexus Explorer',
        type: 'humanoid',
        customizations: ['hair', 'clothing', 'accessories'],
        animations: ['walk', 'run', 'jump', 'wave', 'dance']
      },
      {
        id: 'avatar-002',
        name: 'Tech Specialist',
        type: 'humanoid',
        customizations: ['gear', 'tools', 'augmentations'],
        animations: ['work', 'analyze', 'repair', 'communicate']
      },
      {
        id: 'avatar-003',
        name: 'Creative Artist',
        type: 'humanoid',
        customizations: ['art_tools', 'style', 'expressions'],
        animations: ['create', 'paint', 'sculpt', 'present']
      }
    ]
  });
});

// Socket.IO for real-time interactions
io.on('connection', (socket) => {
  console.log('New user connected to PuaboVerse:', socket.id);

  socket.on('join_world', (data) => {
    const { worldId, userId, avatar } = data;
    const world = virtualWorlds.get(worldId);
    
    if (world) {
      socket.join(worldId);
      world.users.push({ socketId: socket.id, userId, avatar });
      activeUsers.set(socket.id, { userId, worldId, avatar });
      
      // Notify other users in the world
      socket.to(worldId).emit('user_joined', {
        userId,
        avatar,
        timestamp: new Date().toISOString()
      });

      // Send world state to the new user
      socket.emit('world_state', {
        world: world,
        users: world.users
      });
    }
  });

  socket.on('move_avatar', (data) => {
    const user = activeUsers.get(socket.id);
    if (user) {
      // Broadcast avatar movement to other users in the same world
      socket.to(user.worldId).emit('avatar_moved', {
        userId: user.userId,
        position: data.position,
        rotation: data.rotation,
        animation: data.animation,
        timestamp: new Date().toISOString()
      });
    }
  });

  socket.on('chat_message', (data) => {
    const user = activeUsers.get(socket.id);
    if (user) {
      // Broadcast chat message to all users in the world
      io.to(user.worldId).emit('chat_message', {
        userId: user.userId,
        message: data.message,
        timestamp: new Date().toISOString()
      });
    }
  });

  socket.on('interact_object', (data) => {
    const user = activeUsers.get(socket.id);
    if (user) {
      // Broadcast object interaction
      socket.to(user.worldId).emit('object_interaction', {
        userId: user.userId,
        objectId: data.objectId,
        action: data.action,
        timestamp: new Date().toISOString()
      });
    }
  });

  socket.on('disconnect', () => {
    const user = activeUsers.get(socket.id);
    if (user) {
      const world = virtualWorlds.get(user.worldId);
      if (world) {
        // Remove user from world
        world.users = world.users.filter(u => u.socketId !== socket.id);
        
        // Notify other users
        socket.to(user.worldId).emit('user_left', {
          userId: user.userId,
          timestamp: new Date().toISOString()
        });
      }
      activeUsers.delete(socket.id);
    }
    console.log('User disconnected from PuaboVerse:', socket.id);
  });
});

// Initialize some demo worlds
const initDemoWorlds = () => {
  const demoWorlds = [
    {
      id: 'world-nexus-plaza',
      name: 'Nexus Plaza',
      description: 'Central hub for all PuaboVerse activities',
      theme: 'futuristic',
      capacity: 100,
      users: [],
      created: new Date().toISOString(),
      isPublic: true,
      environment: {
        lighting: 'neon',
        weather: 'clear',
        timeOfDay: 'night',
        gravity: 9.81
      }
    },
    {
      id: 'world-creator-space',
      name: 'Creator Space',
      description: 'Collaborative environment for content creation',
      theme: 'creative',
      capacity: 25,
      users: [],
      created: new Date().toISOString(),
      isPublic: true,
      environment: {
        lighting: 'soft',
        weather: 'clear',
        timeOfDay: 'midday',
        gravity: 5.0
      }
    }
  ];

  demoWorlds.forEach(world => {
    virtualWorlds.set(world.id, world);
  });
};

initDemoWorlds();

server.listen(PORT, () => {
  console.log(`🌐 PuaboVerse Module running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🚀 Virtual worlds initialized: ${virtualWorlds.size}`);
});

module.exports = app;
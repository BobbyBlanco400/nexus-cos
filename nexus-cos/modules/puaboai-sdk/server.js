const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const winston = require('winston');
const promClient = require('prom-client');
const cannon = require('cannon-es');
const { v4: uuidv4 } = require('uuid');

require('dotenv').config();

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Configure Winston logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/puaboverse-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/puaboverse.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'puaboverse_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const worldCounter = new promClient.Counter({
  name: 'puaboverse_worlds_total',
  help: 'Total number of virtual worlds created'
});

const avatarCounter = new promClient.Counter({
  name: 'puaboverse_avatars_total',
  help: 'Total number of avatars created'
});

const activeUsersGauge = new promClient.Gauge({
  name: 'puaboverse_active_users',
  help: 'Number of active users in virtual worlds'
});

const physicsStepsCounter = new promClient.Counter({
  name: 'puaboverse_physics_steps_total',
  help: 'Total number of physics simulation steps'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(worldCounter);
register.registerMetric(avatarCounter);
register.registerMetric(activeUsersGauge);
register.registerMetric(physicsStepsCounter);

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300 // limit each IP to 300 requests per windowMs
});
app.use('/api/', limiter);

// Request logging middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
    
    logger.info({
      method: req.method,
      url: req.url,
      status: res.statusCode,
      duration: duration,
      ip: req.ip
    });
  });
  next();
});

// Virtual World Management System
class VirtualWorldManager {
  constructor() {
    this.worlds = new Map();
    this.avatars = new Map();
    this.users = new Map();
    this.physicsWorlds = new Map();
    this.initializeDefaultWorlds();
  }

  initializeDefaultWorlds() {
    const defaultWorlds = [
      {
        id: 'nexus-plaza',
        name: 'Nexus Plaza',
        description: 'Central hub for all virtual activities',
        type: 'social',
        maxUsers: 100,
        environment: {
          skybox: 'space',
          lighting: 'dynamic',
          weather: 'clear'
        }
      },
      {
        id: 'creator-studio',
        name: 'Creator Studio',
        description: 'Virtual space for content creation',
        type: 'creative',
        maxUsers: 20,
        environment: {
          skybox: 'studio',
          lighting: 'bright',
          weather: 'none'
        }
      },
      {
        id: 'gaming-arena',
        name: 'Gaming Arena',
        description: 'Competitive gaming environment',
        type: 'gaming',
        maxUsers: 50,
        environment: {
          skybox: 'arena',
          lighting: 'dramatic',
          weather: 'none'
        }
      }
    ];

    defaultWorlds.forEach(world => {
      this.createWorld(world);
    });
  }

  createWorld(config) {
    const worldId = config.id || `world_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    // Create physics world
    const physicsWorld = new cannon.World({
      gravity: new cannon.Vec3(0, -9.82, 0)
    });

    // Add ground plane
    const groundShape = new cannon.Plane();
    const groundBody = new cannon.Body({ mass: 0 });
    groundBody.addShape(groundShape);
    groundBody.quaternion.setFromAxisAngle(new cannon.Vec3(1, 0, 0), -Math.PI / 2);
    physicsWorld.addBody(groundBody);

    const world = {
      id: worldId,
      name: config.name,
      description: config.description || '',
      type: config.type || 'social',
      maxUsers: config.maxUsers || 50,
      currentUsers: 0,
      users: new Set(),
      objects: new Map(),
      environment: config.environment || {
        skybox: 'default',
        lighting: 'normal',
        weather: 'clear'
      },
      physics: {
        enabled: true,
        gravity: config.gravity || -9.82,
        timeStep: 1/60
      },
      created: new Date(),
      lastActivity: new Date()
    };

    this.worlds.set(worldId, world);
    this.physicsWorlds.set(worldId, physicsWorld);
    worldCounter.inc();

    return world;
  }

  getWorld(worldId) {
    return this.worlds.get(worldId);
  }

  listWorlds() {
    return Array.from(this.worlds.values());
  }

  joinWorld(worldId, userId, avatar) {
    const world = this.worlds.get(worldId);
    if (!world) return null;

    if (world.currentUsers >= world.maxUsers) {
      throw new Error('World is at maximum capacity');
    }

    world.users.add(userId);
    world.currentUsers++;
    world.lastActivity = new Date();

    // Add user to tracking
    this.users.set(userId, {
      id: userId,
      worldId: worldId,
      avatar: avatar,
      position: { x: 0, y: 1, z: 0 },
      rotation: { x: 0, y: 0, z: 0 },
      joinedAt: new Date()
    });

    activeUsersGauge.inc();
    return world;
  }

  leaveWorld(worldId, userId) {
    const world = this.worlds.get(worldId);
    if (!world) return false;

    if (world.users.has(userId)) {
      world.users.delete(userId);
      world.currentUsers--;
      this.users.delete(userId);
      activeUsersGauge.dec();
      return true;
    }
    return false;
  }

  updateUserPosition(userId, position, rotation) {
    const user = this.users.get(userId);
    if (user) {
      user.position = position;
      user.rotation = rotation;
      return user;
    }
    return null;
  }

  getWorldUsers(worldId) {
    const world = this.worlds.get(worldId);
    if (!world) return [];

    return Array.from(world.users).map(userId => this.users.get(userId)).filter(Boolean);
  }

  stepPhysics(worldId) {
    const physicsWorld = this.physicsWorlds.get(worldId);
    if (physicsWorld) {
      physicsWorld.step(1/60);
      physicsStepsCounter.inc();
    }
  }
}

// Avatar Customization System
class AvatarManager {
  constructor() {
    this.avatars = new Map();
    this.presets = new Map();
    this.initializePresets();
  }

  initializePresets() {
    const defaultPresets = [
      {
        id: 'casual-male',
        name: 'Casual Male',
        gender: 'male',
        appearance: {
          body: 'athletic',
          height: 1.8,
          skinTone: 'medium',
          hairStyle: 'short',
          hairColor: 'brown',
          eyeColor: 'blue'
        },
        clothing: {
          top: 'casual-shirt',
          bottom: 'jeans',
          shoes: 'sneakers'
        }
      },
      {
        id: 'casual-female',
        name: 'Casual Female',
        gender: 'female',
        appearance: {
          body: 'athletic',
          height: 1.7,
          skinTone: 'light',
          hairStyle: 'long',
          hairColor: 'blonde',
          eyeColor: 'green'
        },
        clothing: {
          top: 'casual-top',
          bottom: 'jeans',
          shoes: 'sneakers'
        }
      },
      {
        id: 'professional',
        name: 'Professional',
        gender: 'neutral',
        appearance: {
          body: 'average',
          height: 1.75,
          skinTone: 'medium',
          hairStyle: 'professional',
          hairColor: 'black',
          eyeColor: 'brown'
        },
        clothing: {
          top: 'business-suit',
          bottom: 'dress-pants',
          shoes: 'dress-shoes'
        }
      }
    ];

    defaultPresets.forEach(preset => {
      this.presets.set(preset.id, preset);
    });
  }

  createAvatar(userId, config) {
    const avatarId = `avatar_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const avatar = {
      id: avatarId,
      userId: userId,
      name: config.name || 'Avatar',
      appearance: {
        body: config.appearance?.body || 'average',
        height: config.appearance?.height || 1.75,
        skinTone: config.appearance?.skinTone || 'medium',
        hairStyle: config.appearance?.hairStyle || 'short',
        hairColor: config.appearance?.hairColor || 'brown',
        eyeColor: config.appearance?.eyeColor || 'brown',
        accessories: config.appearance?.accessories || []
      },
      clothing: {
        top: config.clothing?.top || 'casual-shirt',
        bottom: config.clothing?.bottom || 'jeans',
        shoes: config.clothing?.shoes || 'sneakers',
        accessories: config.clothing?.accessories || []
      },
      animations: {
        idle: 'default-idle',
        walk: 'default-walk',
        run: 'default-run',
        jump: 'default-jump',
        wave: 'default-wave',
        dance: 'default-dance'
      },
      created: new Date(),
      lastModified: new Date()
    };

    this.avatars.set(avatarId, avatar);
    avatarCounter.inc();

    return avatar;
  }

  getAvatar(avatarId) {
    return this.avatars.get(avatarId);
  }

  getUserAvatars(userId) {
    return Array.from(this.avatars.values()).filter(avatar => avatar.userId === userId);
  }

  updateAvatar(avatarId, updates) {
    const avatar = this.avatars.get(avatarId);
    if (avatar) {
      Object.assign(avatar, updates, { lastModified: new Date() });
      return avatar;
    }
    return null;
  }

  deleteAvatar(avatarId) {
    return this.avatars.delete(avatarId);
  }

  getPresets() {
    return Array.from(this.presets.values());
  }
}

// Interaction System
class InteractionManager {
  constructor() {
    this.interactions = new Map();
    this.interactionTypes = [
      'wave', 'handshake', 'high-five', 'hug', 'dance', 'point', 'thumbs-up', 'applause'
    ];
  }

  createInteraction(fromUserId, toUserId, type, worldId) {
    const interactionId = uuidv4();
    
    const interaction = {
      id: interactionId,
      from: fromUserId,
      to: toUserId,
      type: type,
      worldId: worldId,
      status: 'pending',
      created: new Date(),
      expires: new Date(Date.now() + 30000) // 30 seconds
    };

    this.interactions.set(interactionId, interaction);
    return interaction;
  }

  respondToInteraction(interactionId, response) {
    const interaction = this.interactions.get(interactionId);
    if (interaction && interaction.status === 'pending') {
      interaction.status = response; // 'accepted' or 'declined'
      interaction.responded = new Date();
      return interaction;
    }
    return null;
  }

  getActiveInteractions(userId) {
    return Array.from(this.interactions.values()).filter(
      interaction => 
        (interaction.from === userId || interaction.to === userId) &&
        interaction.status === 'pending' &&
        interaction.expires > new Date()
    );
  }

  cleanupExpiredInteractions() {
    const now = new Date();
    for (const [id, interaction] of this.interactions) {
      if (interaction.expires < now) {
        this.interactions.delete(id);
      }
    }
  }
}

// Initialize managers
const worldManager = new VirtualWorldManager();
const avatarManager = new AvatarManager();
const interactionManager = new InteractionManager();

// Cleanup expired interactions every minute
setInterval(() => {
  interactionManager.cleanupExpiredInteractions();
}, 60000);

// Physics simulation loop
setInterval(() => {
  for (const worldId of worldManager.worlds.keys()) {
    worldManager.stepPhysics(worldId);
  }
}, 1000/60); // 60 FPS

// API Routes
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'PuaboVerse Virtual World Platform',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    worlds: worldManager.worlds.size,
    activeUsers: worldManager.users.size,
    avatars: avatarManager.avatars.size
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// World Management API
app.get('/api/worlds', async (req, res) => {
  try {
    const worlds = worldManager.listWorlds();
    res.json({
      success: true,
      worlds: worlds
    });
  } catch (error) {
    logger.error('Error listing worlds:', error);
    res.status(500).json({ error: 'Failed to list worlds' });
  }
});

app.get('/api/worlds/:id', async (req, res) => {
  try {
    const world = worldManager.getWorld(req.params.id);
    if (!world) {
      return res.status(404).json({ error: 'World not found' });
    }

    const users = worldManager.getWorldUsers(req.params.id);
    res.json({
      success: true,
      world: world,
      users: users
    });
  } catch (error) {
    logger.error('Error getting world:', error);
    res.status(500).json({ error: 'Failed to get world' });
  }
});

app.post('/api/worlds', [
  body('name').isLength({ min: 1 }).withMessage('World name is required'),
  body('type').isIn(['social', 'creative', 'gaming', 'educational']).withMessage('Invalid world type')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const world = worldManager.createWorld(req.body);
    res.status(201).json({
      success: true,
      world: world
    });
  } catch (error) {
    logger.error('Error creating world:', error);
    res.status(500).json({ error: 'Failed to create world' });
  }
});

// Avatar Management API
app.post('/api/avatars', [
  body('userId').isLength({ min: 1 }).withMessage('User ID is required'),
  body('name').isLength({ min: 1 }).withMessage('Avatar name is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const avatar = avatarManager.createAvatar(req.body.userId, req.body);
    res.status(201).json({
      success: true,
      avatar: avatar
    });
  } catch (error) {
    logger.error('Error creating avatar:', error);
    res.status(500).json({ error: 'Failed to create avatar' });
  }
});

app.get('/api/avatars/user/:userId', async (req, res) => {
  try {
    const avatars = avatarManager.getUserAvatars(req.params.userId);
    res.json({
      success: true,
      avatars: avatars
    });
  } catch (error) {
    logger.error('Error getting user avatars:', error);
    res.status(500).json({ error: 'Failed to get user avatars' });
  }
});

app.get('/api/avatars/:id', async (req, res) => {
  try {
    const avatar = avatarManager.getAvatar(req.params.id);
    if (!avatar) {
      return res.status(404).json({ error: 'Avatar not found' });
    }

    res.json({
      success: true,
      avatar: avatar
    });
  } catch (error) {
    logger.error('Error getting avatar:', error);
    res.status(500).json({ error: 'Failed to get avatar' });
  }
});

app.put('/api/avatars/:id', async (req, res) => {
  try {
    const avatar = avatarManager.updateAvatar(req.params.id, req.body);
    if (!avatar) {
      return res.status(404).json({ error: 'Avatar not found' });
    }

    res.json({
      success: true,
      avatar: avatar
    });
  } catch (error) {
    logger.error('Error updating avatar:', error);
    res.status(500).json({ error: 'Failed to update avatar' });
  }
});

app.delete('/api/avatars/:id', async (req, res) => {
  try {
    const deleted = avatarManager.deleteAvatar(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Avatar not found' });
    }

    res.json({
      success: true,
      message: 'Avatar deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting avatar:', error);
    res.status(500).json({ error: 'Failed to delete avatar' });
  }
});

app.get('/api/avatar-presets', async (req, res) => {
  try {
    const presets = avatarManager.getPresets();
    res.json({
      success: true,
      presets: presets
    });
  } catch (error) {
    logger.error('Error getting avatar presets:', error);
    res.status(500).json({ error: 'Failed to get avatar presets' });
  }
});

// WebSocket connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_world', async (data) => {
    try {
      const { worldId, userId, avatar } = data;
      const world = worldManager.joinWorld(worldId, userId, avatar);
      
      if (world) {
        socket.join(`world_${worldId}`);
        socket.userId = userId;
        socket.worldId = worldId;
        
        // Notify other users
        socket.to(`world_${worldId}`).emit('user_joined', {
          userId: userId,
          avatar: avatar,
          timestamp: new Date()
        });

        // Send current world state
        const users = worldManager.getWorldUsers(worldId);
        socket.emit('world_state', {
          world: world,
          users: users
        });

        logger.info(`User ${userId} joined world ${worldId}`);
      }
    } catch (error) {
      logger.error('Error joining world:', error);
      socket.emit('error', { message: error.message });
    }
  });

  socket.on('leave_world', () => {
    if (socket.worldId && socket.userId) {
      worldManager.leaveWorld(socket.worldId, socket.userId);
      socket.to(`world_${socket.worldId}`).emit('user_left', {
        userId: socket.userId,
        timestamp: new Date()
      });
      socket.leave(`world_${socket.worldId}`);
      logger.info(`User ${socket.userId} left world ${socket.worldId}`);
    }
  });

  socket.on('update_position', (data) => {
    if (socket.userId) {
      const user = worldManager.updateUserPosition(socket.userId, data.position, data.rotation);
      if (user) {
        socket.to(`world_${socket.worldId}`).emit('user_moved', {
          userId: socket.userId,
          position: data.position,
          rotation: data.rotation,
          timestamp: new Date()
        });
      }
    }
  });

  socket.on('interaction_request', (data) => {
    try {
      const { toUserId, type } = data;
      const interaction = interactionManager.createInteraction(
        socket.userId, 
        toUserId, 
        type, 
        socket.worldId
      );

      // Send to target user
      socket.to(`world_${socket.worldId}`).emit('interaction_request', {
        interaction: interaction,
        fromUser: socket.userId
      });

      logger.info(`Interaction ${type} requested from ${socket.userId} to ${toUserId}`);
    } catch (error) {
      logger.error('Error creating interaction:', error);
      socket.emit('error', { message: 'Failed to create interaction' });
    }
  });

  socket.on('interaction_response', (data) => {
    try {
      const { interactionId, response } = data;
      const interaction = interactionManager.respondToInteraction(interactionId, response);
      
      if (interaction) {
        // Notify both users
        socket.to(`world_${socket.worldId}`).emit('interaction_response', {
          interaction: interaction,
          response: response
        });

        logger.info(`Interaction ${interactionId} ${response} by ${socket.userId}`);
      }
    } catch (error) {
      logger.error('Error responding to interaction:', error);
      socket.emit('error', { message: 'Failed to respond to interaction' });
    }
  });

  socket.on('chat_message', (data) => {
    if (socket.worldId) {
      socket.to(`world_${socket.worldId}`).emit('chat_message', {
        userId: socket.userId,
        message: data.message,
        timestamp: new Date()
      });
    }
  });

  socket.on('disconnect', () => {
    if (socket.worldId && socket.userId) {
      worldManager.leaveWorld(socket.worldId, socket.userId);
      socket.to(`world_${socket.worldId}`).emit('user_left', {
        userId: socket.userId,
        timestamp: new Date()
      });
    }
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error:', error);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

const PORT = process.env.PORT || 3030;
const HOST = process.env.HOST || '0.0.0.0';

server.listen(PORT, HOST, () => {
  logger.info(`PuaboVerse Virtual World Platform running on ${HOST}:${PORT}`);
  logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Process terminated');
    process.exit(0);
  });
});

module.exports = app;
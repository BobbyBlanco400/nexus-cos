const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const sharp = require('sharp');
const { MongoClient } = require('mongodb');
const redis = require('redis');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const winston = require('winston');
const promClient = require('prom-client');
const AWS = require('aws-sdk');

require('dotenv').config();

// Configure FFmpeg
ffmpeg.setFfmpegPath(ffmpegStatic);

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// AWS S3 configuration
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeStagesGauge = new promClient.Gauge({
  name: 'active_virtual_stages',
  help: 'Number of active virtual stages'
});

const presentationsCounter = new promClient.Counter({
  name: 'presentations_total',
  help: 'Total number of presentations created'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(activeStagesGauge);
register.registerMetric(presentationsCounter);

// Logger configuration
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: '/app/logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: '/app/logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Database connections
let db, redisClient;

async function connectDatabases() {
  try {
    // MongoDB connection
    const mongoClient = new MongoClient(process.env.MONGODB_URI || 'mongodb://mongodb:27017/nexus_cos');
    await mongoClient.connect();
    db = mongoClient.db();
    logger.info('Connected to MongoDB');

    // Redis connection
    redisClient = redis.createClient({
      url: process.env.REDIS_URL || 'redis://redis:6379',
      password: process.env.REDIS_PASSWORD
    });
    await redisClient.connect();
    logger.info('Connected to Redis');
  } catch (error) {
    logger.error('Database connection error:', error);
    process.exit(1);
  }
}

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Metrics middleware
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  next();
});

// Authentication middleware
const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' });
  }
};

// File upload configuration
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/', 'model/', 'audio/', 'video/'];
    const isAllowed = allowedTypes.some(type => file.mimetype.startsWith(type));
    cb(null, isAllowed);
  }
});

// Virtual stage state management
const activeStages = new Map();
const stageTemplates = new Map();

// Initialize default stage templates
const initializeStageTemplates = () => {
  const defaultTemplates = [
    {
      id: 'modern_office',
      name: 'Modern Office',
      description: 'Professional office environment with modern furniture',
      category: 'business',
      assets: {
        environment: 'environments/modern_office.glb',
        lighting: 'lighting/office_hdri.hdr',
        materials: ['materials/wood.json', 'materials/glass.json']
      },
      settings: {
        lighting: { intensity: 1.2, color: '#ffffff' },
        camera: { position: [0, 1.6, 5], target: [0, 1, 0] },
        physics: { gravity: -9.81 }
      }
    },
    {
      id: 'concert_hall',
      name: 'Concert Hall',
      description: 'Grand concert hall with stage lighting',
      category: 'entertainment',
      assets: {
        environment: 'environments/concert_hall.glb',
        lighting: 'lighting/stage_lights.json',
        audio: 'audio/hall_reverb.wav'
      },
      settings: {
        lighting: { intensity: 0.8, color: '#ff6b35' },
        camera: { position: [0, 2, 10], target: [0, 1.5, 0] },
        audio: { reverb: 0.7, echo: 0.3 }
      }
    },
    {
      id: 'virtual_studio',
      name: 'Virtual Studio',
      description: 'Green screen studio with customizable backgrounds',
      category: 'production',
      assets: {
        environment: 'environments/green_screen.glb',
        backgrounds: ['backgrounds/city.jpg', 'backgrounds/nature.jpg'],
        effects: 'effects/particles.json'
      },
      settings: {
        lighting: { intensity: 1.5, color: '#ffffff' },
        camera: { position: [0, 1.8, 3], target: [0, 1.6, 0] },
        chromaKey: { color: '#00ff00', threshold: 0.1 }
      }
    }
  ];

  defaultTemplates.forEach(template => {
    stageTemplates.set(template.id, template);
  });
};

// Stage Management Routes
app.post('/stages', authenticateToken, [
  body('name').isLength({ min: 1, max: 100 }),
  body('template').optional().isString(),
  body('settings').optional().isObject()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, template = 'modern_office', settings = {} } = req.body;
    const userId = req.user.id;
    const stageId = `stage_${userId}_${Date.now()}`;

    // Get template
    const stageTemplate = stageTemplates.get(template);
    if (!stageTemplate) {
      return res.status(400).json({ error: 'Invalid template' });
    }

    // Create stage configuration
    const stageConfig = {
      id: stageId,
      name,
      userId,
      template,
      settings: { ...stageTemplate.settings, ...settings },
      assets: stageTemplate.assets,
      objects: [],
      participants: new Set(),
      createdAt: new Date(),
      isActive: false
    };

    // Save to database
    await db.collection('virtual_stages').insertOne({
      ...stageConfig,
      participants: [] // Convert Set to Array for MongoDB
    });

    // Store in memory
    activeStages.set(stageId, stageConfig);
    activeStagesGauge.set(activeStages.size);

    res.json({
      success: true,
      stageId,
      stage: {
        id: stageId,
        name,
        template,
        settings: stageConfig.settings,
        assets: stageConfig.assets
      }
    });

  } catch (error) {
    logger.error('Create stage error:', error);
    res.status(500).json({ error: 'Failed to create stage' });
  }
});

app.get('/stages', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const stages = await db.collection('virtual_stages')
      .find({ userId })
      .sort({ createdAt: -1 })
      .limit(50)
      .toArray();

    res.json({ stages });
  } catch (error) {
    logger.error('Get stages error:', error);
    res.status(500).json({ error: 'Failed to fetch stages' });
  }
});

app.get('/stages/:stageId', authenticateToken, async (req, res) => {
  try {
    const { stageId } = req.params;
    const stage = await db.collection('virtual_stages').findOne({ id: stageId });

    if (!stage) {
      return res.status(404).json({ error: 'Stage not found' });
    }

    // Check permissions
    if (stage.userId !== req.user.id && !stage.collaborators?.includes(req.user.id)) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({ stage });
  } catch (error) {
    logger.error('Get stage error:', error);
    res.status(500).json({ error: 'Failed to fetch stage' });
  }
});

// 3D Object Management
app.post('/stages/:stageId/objects', authenticateToken, upload.single('model'), [
  body('type').isIn(['model', 'primitive', 'light', 'camera', 'audio']),
  body('position').optional().isArray(),
  body('rotation').optional().isArray(),
  body('scale').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { stageId } = req.params;
    const { type, position = [0, 0, 0], rotation = [0, 0, 0], scale = [1, 1, 1], properties = {} } = req.body;
    const objectId = `obj_${Date.now()}`;

    // Get stage
    const stage = activeStages.get(stageId);
    if (!stage) {
      return res.status(404).json({ error: 'Stage not found' });
    }

    // Check permissions
    if (stage.userId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    let assetUrl = null;

    // Handle file upload for models
    if (req.file && type === 'model') {
      const fileName = `stages/${stageId}/objects/${objectId}.${req.file.originalname.split('.').pop()}`;
      
      const uploadParams = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: fileName,
        Body: req.file.buffer,
        ContentType: req.file.mimetype
      };

      const uploadResult = await s3.upload(uploadParams).promise();
      assetUrl = uploadResult.Location;
    }

    // Create object
    const object = {
      id: objectId,
      type,
      position,
      rotation,
      scale,
      properties,
      assetUrl,
      createdAt: new Date(),
      createdBy: req.user.id
    };

    // Add to stage
    stage.objects.push(object);

    // Update database
    await db.collection('virtual_stages').updateOne(
      { id: stageId },
      { $push: { objects: object } }
    );

    // Broadcast to stage participants
    io.to(`stage_${stageId}`).emit('object_added', { object });

    res.json({ success: true, object });

  } catch (error) {
    logger.error('Add object error:', error);
    res.status(500).json({ error: 'Failed to add object' });
  }
});

app.put('/stages/:stageId/objects/:objectId', authenticateToken, [
  body('position').optional().isArray(),
  body('rotation').optional().isArray(),
  body('scale').optional().isArray()
], async (req, res) => {
  try {
    const { stageId, objectId } = req.params;
    const updates = req.body;

    // Get stage
    const stage = activeStages.get(stageId);
    if (!stage) {
      return res.status(404).json({ error: 'Stage not found' });
    }

    // Find and update object
    const objectIndex = stage.objects.findIndex(obj => obj.id === objectId);
    if (objectIndex === -1) {
      return res.status(404).json({ error: 'Object not found' });
    }

    // Update object
    Object.assign(stage.objects[objectIndex], updates, { updatedAt: new Date() });

    // Update database
    await db.collection('virtual_stages').updateOne(
      { id: stageId, 'objects.id': objectId },
      { $set: { 'objects.$': stage.objects[objectIndex] } }
    );

    // Broadcast to stage participants
    io.to(`stage_${stageId}`).emit('object_updated', { 
      objectId, 
      updates: stage.objects[objectIndex] 
    });

    res.json({ success: true, object: stage.objects[objectIndex] });

  } catch (error) {
    logger.error('Update object error:', error);
    res.status(500).json({ error: 'Failed to update object' });
  }
});

// Presentation Management
app.post('/presentations', authenticateToken, [
  body('title').isLength({ min: 1, max: 200 }),
  body('stageId').isString(),
  body('slides').isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, stageId, slides, settings = {} } = req.body;
    const userId = req.user.id;
    const presentationId = `pres_${userId}_${Date.now()}`;

    // Verify stage access
    const stage = await db.collection('virtual_stages').findOne({ id: stageId });
    if (!stage || (stage.userId !== userId && !stage.collaborators?.includes(userId))) {
      return res.status(403).json({ error: 'Stage access denied' });
    }

    // Create presentation
    const presentation = {
      id: presentationId,
      title,
      stageId,
      userId,
      slides,
      settings,
      currentSlide: 0,
      status: 'draft',
      createdAt: new Date()
    };

    await db.collection('presentations').insertOne(presentation);
    presentationsCounter.inc();

    res.json({ success: true, presentationId, presentation });

  } catch (error) {
    logger.error('Create presentation error:', error);
    res.status(500).json({ error: 'Failed to create presentation' });
  }
});

app.post('/presentations/:presentationId/start', authenticateToken, async (req, res) => {
  try {
    const { presentationId } = req.params;
    const presentation = await db.collection('presentations').findOne({ id: presentationId });

    if (!presentation) {
      return res.status(404).json({ error: 'Presentation not found' });
    }

    if (presentation.userId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update presentation status
    await db.collection('presentations').updateOne(
      { id: presentationId },
      { 
        $set: { 
          status: 'active',
          startedAt: new Date(),
          currentSlide: 0
        }
      }
    );

    // Activate stage
    const stage = activeStages.get(presentation.stageId);
    if (stage) {
      stage.isActive = true;
      stage.activePresentation = presentationId;
    }

    // Broadcast to stage participants
    io.to(`stage_${presentation.stageId}`).emit('presentation_started', { 
      presentationId,
      slides: presentation.slides 
    });

    res.json({ success: true, message: 'Presentation started' });

  } catch (error) {
    logger.error('Start presentation error:', error);
    res.status(500).json({ error: 'Failed to start presentation' });
  }
});

// Asset Management
app.post('/assets/upload', authenticateToken, upload.single('asset'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const { category = 'general' } = req.body;
    const userId = req.user.id;
    const assetId = `asset_${userId}_${Date.now()}`;
    const fileName = `assets/${category}/${assetId}.${req.file.originalname.split('.').pop()}`;

    // Process image assets
    let processedBuffer = req.file.buffer;
    if (req.file.mimetype.startsWith('image/')) {
      processedBuffer = await sharp(req.file.buffer)
        .resize(2048, 2048, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 85 })
        .toBuffer();
    }

    // Upload to S3
    const uploadParams = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: fileName,
      Body: processedBuffer,
      ContentType: req.file.mimetype,
      Metadata: {
        userId,
        originalName: req.file.originalname,
        category
      }
    };

    const uploadResult = await s3.upload(uploadParams).promise();

    // Save asset info to database
    const asset = {
      id: assetId,
      userId,
      fileName: req.file.originalname,
      category,
      mimeType: req.file.mimetype,
      size: processedBuffer.length,
      url: uploadResult.Location,
      createdAt: new Date()
    };

    await db.collection('assets').insertOne(asset);

    res.json({ success: true, asset });

  } catch (error) {
    logger.error('Asset upload error:', error);
    res.status(500).json({ error: 'Failed to upload asset' });
  }
});

// Get stage templates
app.get('/templates', (req, res) => {
  const templates = Array.from(stageTemplates.values());
  res.json({ templates });
});

// Socket.IO for real-time collaboration
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_stage', async (data) => {
    const { stageId, token } = data;
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const stage = activeStages.get(stageId);

      if (stage) {
        socket.join(`stage_${stageId}`);
        stage.participants.add(socket.id);
        
        socket.emit('stage_joined', { 
          stageId,
          stage: {
            id: stage.id,
            name: stage.name,
            settings: stage.settings,
            objects: stage.objects
          }
        });

        socket.to(`stage_${stageId}`).emit('participant_joined', { 
          participantId: socket.id,
          participantCount: stage.participants.size 
        });
      } else {
        socket.emit('error', { message: 'Stage not found' });
      }
    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('stage_update', (data) => {
    const { stageId, type, payload } = data;
    socket.to(`stage_${stageId}`).emit('stage_update', { type, payload });
  });

  socket.on('cursor_move', (data) => {
    const { stageId, position } = data;
    socket.to(`stage_${stageId}`).emit('cursor_move', { 
      participantId: socket.id, 
      position 
    });
  });

  socket.on('voice_data', (data) => {
    const { stageId, audioData } = data;
    socket.to(`stage_${stageId}`).emit('voice_data', { 
      participantId: socket.id, 
      audioData 
    });
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
    
    // Remove from all stages
    activeStages.forEach((stage) => {
      if (stage.participants.has(socket.id)) {
        stage.participants.delete(socket.id);
        socket.to(`stage_${stage.id}`).emit('participant_left', {
          participantId: socket.id,
          participantCount: stage.participants.size
        });
      }
    });
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'v-stage',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeStages: activeStages.size,
    stageTemplates: stageTemplates.size
  });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// Start server
const PORT = process.env.PORT || 3046;

async function startServer() {
  await connectDatabases();
  initializeStageTemplates();
  
  server.listen(PORT, () => {
    logger.info(`V-Stage service running on port ${PORT}`);
  });
}

startServer().catch(error => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Close database connections
  if (redisClient) await redisClient.quit();
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
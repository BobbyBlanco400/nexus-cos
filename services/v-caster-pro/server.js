const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const NodeMediaServer = require('node-media-server');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const sharp = require('sharp');
const Canvas = require('canvas');
const WebSocket = require('ws');
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

// Node Media Server configuration
const nmsConfig = {
  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: 8000,
    mediaroot: './media',
    allow_origin: '*'
  },
  relay: {
    ffmpeg: ffmpegStatic,
    tasks: []
  }
};

const nms = new NodeMediaServer(nmsConfig);

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeStreamsGauge = new promClient.Gauge({
  name: 'active_streams',
  help: 'Number of active streams'
});

const broadcastsCounter = new promClient.Counter({
  name: 'broadcasts_total',
  help: 'Total number of broadcasts started'
});

const viewersGauge = new promClient.Gauge({
  name: 'total_viewers',
  help: 'Total number of viewers across all streams'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(activeStreamsGauge);
register.registerMetric(broadcastsCounter);
register.registerMetric(viewersGauge);

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
    const mongoClient = new MongoClient(process.env.MONGODB_URI || 'mongodb://mongo:27017/nexus_cos');
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
    fileSize: 500 * 1024 * 1024 // 500MB
  }
});

// Broadcasting state management
const activeStreams = new Map();
const streamConfigs = new Map();
const overlayTemplates = new Map();

// Initialize overlay templates
const initializeOverlayTemplates = () => {
  const templates = [
    {
      id: 'news_lower_third',
      name: 'News Lower Third',
      category: 'news',
      elements: [
        {
          type: 'rectangle',
          x: 50, y: 400, width: 600, height: 80,
          fill: '#1a1a1a', opacity: 0.8
        },
        {
          type: 'text',
          x: 70, y: 430, text: '{{title}}',
          font: '24px Arial', fill: '#ffffff'
        },
        {
          type: 'text',
          x: 70, y: 460, text: '{{subtitle}}',
          font: '16px Arial', fill: '#cccccc'
        }
      ]
    },
    {
      id: 'gaming_overlay',
      name: 'Gaming Overlay',
      category: 'gaming',
      elements: [
        {
          type: 'image',
          x: 20, y: 20, width: 200, height: 150,
          src: 'overlays/webcam_frame.png'
        },
        {
          type: 'text',
          x: 20, y: 200, text: 'Viewers: {{viewers}}',
          font: '18px Arial', fill: '#00ff00'
        },
        {
          type: 'text',
          x: 20, y: 230, text: 'Followers: {{followers}}',
          font: '18px Arial', fill: '#00ff00'
        }
      ]
    }
  ];

  templates.forEach(template => {
    overlayTemplates.set(template.id, template);
  });
};

// Stream Management Routes
app.post('/streams', authenticateToken, [
  body('title').isLength({ min: 1, max: 200 }),
  body('description').optional().isLength({ max: 1000 }),
  body('category').optional().isString(),
  body('quality').optional().isIn(['720p', '1080p', '1440p', '4k']),
  body('platforms').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      title, 
      description = '', 
      category = 'general',
      quality = '1080p',
      platforms = ['nexus'],
      settings = {}
    } = req.body;
    
    const userId = req.user.id;
    const streamId = `stream_${userId}_${Date.now()}`;
    const streamKey = `sk_${Math.random().toString(36).substring(2, 15)}`;

    // Quality settings
    const qualitySettings = {
      '720p': { width: 1280, height: 720, bitrate: '2500k', fps: 30 },
      '1080p': { width: 1920, height: 1080, bitrate: '4500k', fps: 30 },
      '1440p': { width: 2560, height: 1440, bitrate: '8000k', fps: 30 },
      '4k': { width: 3840, height: 2160, bitrate: '15000k', fps: 30 }
    };

    const streamConfig = {
      id: streamId,
      userId,
      title,
      description,
      category,
      quality: qualitySettings[quality],
      platforms,
      streamKey,
      rtmpUrl: `rtmp://localhost:1935/live/${streamKey}`,
      hlsUrl: `http://localhost:8000/live/${streamKey}/index.m3u8`,
      status: 'created',
      viewers: 0,
      settings: {
        enableChat: true,
        enableDonations: true,
        enableOverlays: true,
        recordStream: true,
        ...settings
      },
      createdAt: new Date()
    };

    // Save to database
    await db.collection('streams').insertOne(streamConfig);
    streamConfigs.set(streamId, streamConfig);

    res.json({
      success: true,
      streamId,
      streamKey,
      rtmpUrl: streamConfig.rtmpUrl,
      hlsUrl: streamConfig.hlsUrl,
      config: streamConfig
    });

  } catch (error) {
    logger.error('Create stream error:', error);
    res.status(500).json({ error: 'Failed to create stream' });
  }
});

app.post('/streams/:streamId/start', authenticateToken, async (req, res) => {
  try {
    const { streamId } = req.params;
    const streamConfig = streamConfigs.get(streamId);

    if (!streamConfig) {
      return res.status(404).json({ error: 'Stream not found' });
    }

    if (streamConfig.userId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Start multi-platform streaming
    const streamingTasks = [];

    for (const platform of streamConfig.platforms) {
      if (platform !== 'nexus') {
        const task = await startPlatformStream(streamConfig, platform);
        if (task) streamingTasks.push(task);
      }
    }

    // Update stream status
    streamConfig.status = 'live';
    streamConfig.startedAt = new Date();
    streamConfig.streamingTasks = streamingTasks;

    await db.collection('streams').updateOne(
      { id: streamId },
      { 
        $set: { 
          status: 'live',
          startedAt: new Date(),
          streamingTasks: streamingTasks.map(t => t.id)
        }
      }
    );

    activeStreams.set(streamId, streamConfig);
    activeStreamsGauge.set(activeStreams.size);
    broadcastsCounter.inc();

    // Notify subscribers
    io.emit('stream_started', { streamId, title: streamConfig.title });

    res.json({ success: true, message: 'Stream started', streamingTasks });

  } catch (error) {
    logger.error('Start stream error:', error);
    res.status(500).json({ error: 'Failed to start stream' });
  }
});

app.post('/streams/:streamId/stop', authenticateToken, async (req, res) => {
  try {
    const { streamId } = req.params;
    const streamConfig = activeStreams.get(streamId);

    if (!streamConfig) {
      return res.status(404).json({ error: 'Stream not found' });
    }

    if (streamConfig.userId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Stop all streaming tasks
    if (streamConfig.streamingTasks) {
      for (const task of streamConfig.streamingTasks) {
        if (task.process) {
          task.process.kill('SIGTERM');
        }
      }
    }

    // Update stream status
    streamConfig.status = 'ended';
    streamConfig.endedAt = new Date();
    streamConfig.duration = Date.now() - streamConfig.startedAt.getTime();

    await db.collection('streams').updateOne(
      { id: streamId },
      { 
        $set: { 
          status: 'ended',
          endedAt: new Date(),
          duration: streamConfig.duration
        }
      }
    );

    activeStreams.delete(streamId);
    activeStreamsGauge.set(activeStreams.size);

    // Notify subscribers
    io.emit('stream_ended', { streamId });

    res.json({ success: true, message: 'Stream stopped' });

  } catch (error) {
    logger.error('Stop stream error:', error);
    res.status(500).json({ error: 'Failed to stop stream' });
  }
});

// Overlay Management
app.post('/streams/:streamId/overlays', authenticateToken, upload.single('image'), [
  body('type').isIn(['text', 'image', 'webcam', 'alert', 'chat']),
  body('position').isObject(),
  body('content').optional().isString()
], async (req, res) => {
  try {
    const { streamId } = req.params;
    const { type, position, content, settings = {} } = req.body;
    const overlayId = `overlay_${Date.now()}`;

    const streamConfig = activeStreams.get(streamId);
    if (!streamConfig) {
      return res.status(404).json({ error: 'Stream not found' });
    }

    let overlayData = {
      id: overlayId,
      type,
      position,
      content,
      settings,
      createdAt: new Date()
    };

    // Handle image upload
    if (req.file && type === 'image') {
      const fileName = `overlays/${streamId}/${overlayId}.${req.file.originalname.split('.').pop()}`;
      
      const uploadParams = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: fileName,
        Body: req.file.buffer,
        ContentType: req.file.mimetype
      };

      const uploadResult = await s3.upload(uploadParams).promise();
      overlayData.imageUrl = uploadResult.Location;
    }

    // Add overlay to stream
    if (!streamConfig.overlays) streamConfig.overlays = [];
    streamConfig.overlays.push(overlayData);

    // Update database
    await db.collection('streams').updateOne(
      { id: streamId },
      { $push: { overlays: overlayData } }
    );

    // Broadcast to viewers
    io.to(`stream_${streamId}`).emit('overlay_added', overlayData);

    res.json({ success: true, overlay: overlayData });

  } catch (error) {
    logger.error('Add overlay error:', error);
    res.status(500).json({ error: 'Failed to add overlay' });
  }
});

// Scene Management
app.post('/streams/:streamId/scenes', authenticateToken, [
  body('name').isLength({ min: 1, max: 100 }),
  body('sources').isArray()
], async (req, res) => {
  try {
    const { streamId } = req.params;
    const { name, sources, settings = {} } = req.body;
    const sceneId = `scene_${Date.now()}`;

    const streamConfig = streamConfigs.get(streamId);
    if (!streamConfig) {
      return res.status(404).json({ error: 'Stream not found' });
    }

    const scene = {
      id: sceneId,
      name,
      sources,
      settings,
      isActive: false,
      createdAt: new Date()
    };

    // Add scene to stream
    if (!streamConfig.scenes) streamConfig.scenes = [];
    streamConfig.scenes.push(scene);

    // Update database
    await db.collection('streams').updateOne(
      { id: streamId },
      { $push: { scenes: scene } }
    );

    res.json({ success: true, scene });

  } catch (error) {
    logger.error('Create scene error:', error);
    res.status(500).json({ error: 'Failed to create scene' });
  }
});

app.post('/streams/:streamId/scenes/:sceneId/activate', authenticateToken, async (req, res) => {
  try {
    const { streamId, sceneId } = req.params;
    const streamConfig = activeStreams.get(streamId);

    if (!streamConfig) {
      return res.status(404).json({ error: 'Stream not found' });
    }

    // Deactivate all scenes
    if (streamConfig.scenes) {
      streamConfig.scenes.forEach(scene => scene.isActive = false);
    }

    // Activate selected scene
    const scene = streamConfig.scenes?.find(s => s.id === sceneId);
    if (scene) {
      scene.isActive = true;
      streamConfig.activeScene = sceneId;

      // Update database
      await db.collection('streams').updateOne(
        { id: streamId },
        { 
          $set: { 
            'scenes.$[].isActive': false,
            activeScene: sceneId
          }
        }
      );

      await db.collection('streams').updateOne(
        { id: streamId, 'scenes.id': sceneId },
        { $set: { 'scenes.$.isActive': true } }
      );

      // Broadcast scene change
      io.to(`stream_${streamId}`).emit('scene_changed', { sceneId, scene });

      res.json({ success: true, message: 'Scene activated' });
    } else {
      res.status(404).json({ error: 'Scene not found' });
    }

  } catch (error) {
    logger.error('Activate scene error:', error);
    res.status(500).json({ error: 'Failed to activate scene' });
  }
});

// Multi-platform streaming function
async function startPlatformStream(streamConfig, platform) {
  try {
    const platformConfigs = {
      youtube: {
        rtmpUrl: `rtmp://a.rtmp.youtube.com/live2/${process.env.YOUTUBE_STREAM_KEY}`,
        name: 'YouTube Live'
      },
      twitch: {
        rtmpUrl: `rtmp://live.twitch.tv/app/${process.env.TWITCH_STREAM_KEY}`,
        name: 'Twitch'
      },
      facebook: {
        rtmpUrl: `rtmp://live-api-s.facebook.com:80/rtmp/${process.env.FACEBOOK_STREAM_KEY}`,
        name: 'Facebook Live'
      }
    };

    const config = platformConfigs[platform];
    if (!config) return null;

    const taskId = `task_${platform}_${Date.now()}`;
    
    // Create FFmpeg process for platform streaming
    const ffmpegProcess = ffmpeg()
      .input(`rtmp://localhost:1935/live/${streamConfig.streamKey}`)
      .inputOptions(['-re'])
      .output(config.rtmpUrl)
      .videoCodec('libx264')
      .audioCodec('aac')
      .videoBitrate(streamConfig.quality.bitrate)
      .size(`${streamConfig.quality.width}x${streamConfig.quality.height}`)
      .fps(streamConfig.quality.fps)
      .outputOptions([
        '-preset fast',
        '-tune zerolatency',
        '-f flv'
      ]);

    ffmpegProcess.on('start', () => {
      logger.info(`Started streaming to ${config.name}`);
    });

    ffmpegProcess.on('error', (err) => {
      logger.error(`${config.name} streaming error:`, err);
    });

    ffmpegProcess.run();

    return {
      id: taskId,
      platform,
      name: config.name,
      process: ffmpegProcess,
      startedAt: new Date()
    };

  } catch (error) {
    logger.error(`Failed to start ${platform} stream:`, error);
    return null;
  }
}

// Get user streams
app.get('/streams', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const streams = await db.collection('streams')
      .find({ userId })
      .sort({ createdAt: -1 })
      .limit(50)
      .toArray();

    res.json({ streams });
  } catch (error) {
    logger.error('Get streams error:', error);
    res.status(500).json({ error: 'Failed to fetch streams' });
  }
});

// Get live streams
app.get('/streams/live', async (req, res) => {
  try {
    const liveStreams = Array.from(activeStreams.values()).map(stream => ({
      id: stream.id,
      title: stream.title,
      description: stream.description,
      category: stream.category,
      viewers: stream.viewers,
      startedAt: stream.startedAt,
      hlsUrl: stream.hlsUrl
    }));

    res.json({ streams: liveStreams });
  } catch (error) {
    logger.error('Get live streams error:', error);
    res.status(500).json({ error: 'Failed to fetch live streams' });
  }
});

// Socket.IO for real-time features
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_stream', async (data) => {
    const { streamId, token } = data;
    
    try {
      if (token) {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        socket.userId = decoded.id;
      }

      const stream = activeStreams.get(streamId);
      if (stream) {
        socket.join(`stream_${streamId}`);
        stream.viewers++;
        viewersGauge.inc();

        socket.emit('stream_joined', { 
          streamId,
          stream: {
            title: stream.title,
            description: stream.description,
            viewers: stream.viewers,
            overlays: stream.overlays || []
          }
        });

        socket.to(`stream_${streamId}`).emit('viewer_joined', { 
          viewers: stream.viewers 
        });
      }
    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('chat_message', async (data) => {
    const { streamId, message } = data;
    
    if (socket.userId) {
      const user = await db.collection('users').findOne({ _id: socket.userId });
      
      const chatMessage = {
        id: `msg_${Date.now()}`,
        userId: socket.userId,
        username: user?.username || 'Anonymous',
        message,
        timestamp: new Date()
      };

      // Save to database
      await db.collection('chat_messages').insertOne({
        ...chatMessage,
        streamId
      });

      // Broadcast to stream viewers
      io.to(`stream_${streamId}`).emit('chat_message', chatMessage);
    }
  });

  socket.on('donation', async (data) => {
    const { streamId, amount, message } = data;
    
    if (socket.userId) {
      const donation = {
        id: `donation_${Date.now()}`,
        streamId,
        userId: socket.userId,
        amount,
        message,
        timestamp: new Date()
      };

      // Save to database
      await db.collection('donations').insertOne(donation);

      // Broadcast donation alert
      io.to(`stream_${streamId}`).emit('donation_alert', donation);
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
    
    // Update viewer count for all streams
    activeStreams.forEach((stream) => {
      if (stream.viewers > 0) {
        stream.viewers--;
        viewersGauge.dec();
        io.to(`stream_${stream.id}`).emit('viewer_left', { 
          viewers: stream.viewers 
        });
      }
    });
  });
});

// Node Media Server events
nms.on('preConnect', (id, args) => {
  logger.info(`[NodeMediaServer] Preconnect: ${id} ${JSON.stringify(args)}`);
});

nms.on('postConnect', (id, args) => {
  logger.info(`[NodeMediaServer] Postconnect: ${id} ${JSON.stringify(args)}`);
});

nms.on('prePublish', (id, StreamPath, args) => {
  logger.info(`[NodeMediaServer] Prepublish: ${id} ${StreamPath} ${JSON.stringify(args)}`);
  
  // Validate stream key
  const streamKey = StreamPath.split('/').pop();
  const isValidKey = Array.from(streamConfigs.values()).some(config => config.streamKey === streamKey);
  
  if (!isValidKey) {
    logger.warn(`Invalid stream key: ${streamKey}`);
    return false;
  }
});

nms.on('postPublish', (id, StreamPath, args) => {
  logger.info(`[NodeMediaServer] Postpublish: ${id} ${StreamPath} ${JSON.stringify(args)}`);
});

nms.on('donePublish', (id, StreamPath, args) => {
  logger.info(`[NodeMediaServer] Donepublish: ${id} ${StreamPath} ${JSON.stringify(args)}`);
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'v-caster-pro',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeStreams: activeStreams.size,
    totalViewers: Array.from(activeStreams.values()).reduce((sum, stream) => sum + stream.viewers, 0)
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

// Start servers
const PORT = process.env.PORT || 3047;

async function startServer() {
  await connectDatabases();
  initializeOverlayTemplates();
  
  // Start Node Media Server
  nms.run();
  logger.info('Node Media Server started');
  
  // Start Express server
  server.listen(PORT, () => {
    logger.info(`V-Caster Pro service running on port ${PORT}`);
  });
}

startServer().catch(error => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Stop all active streams
  activeStreams.forEach((stream) => {
    if (stream.streamingTasks) {
      stream.streamingTasks.forEach(task => {
        if (task.process) task.process.kill('SIGTERM');
      });
    }
  });
  
  // Stop Node Media Server
  nms.stop();
  
  // Close database connections
  if (redisClient) await redisClient.quit();
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
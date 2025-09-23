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
const screenshot = require('screenshot-desktop');
const robot = require('robotjs');
const WebSocket = require('ws');
const { MongoClient } = require('mongodb');
const redis = require('redis');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const winston = require('winston');
const promClient = require('prom-client');

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

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const screenRecordingCounter = new promClient.Counter({
  name: 'screen_recordings_total',
  help: 'Total number of screen recordings started'
});

const activeScreenShares = new promClient.Gauge({
  name: 'active_screen_shares',
  help: 'Number of active screen sharing sessions'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(screenRecordingCounter);
register.registerMetric(activeScreenShares);

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
    fileSize: 100 * 1024 * 1024 // 100MB
  }
});

// Screen recording state
const activeRecordings = new Map();
const activeScreenShares = new Map();

// Screen Recording Routes
app.post('/start-recording', authenticateToken, [
  body('quality').optional().isIn(['low', 'medium', 'high']),
  body('fps').optional().isInt({ min: 10, max: 60 }),
  body('audio').optional().isBoolean()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { quality = 'medium', fps = 30, audio = true } = req.body;
    const userId = req.user.id;
    const recordingId = `recording_${userId}_${Date.now()}`;

    // Check if user already has an active recording
    if (activeRecordings.has(userId)) {
      return res.status(400).json({ error: 'Recording already in progress' });
    }

    // Quality settings
    const qualitySettings = {
      low: { width: 1280, height: 720, bitrate: '1000k' },
      medium: { width: 1920, height: 1080, bitrate: '2500k' },
      high: { width: 2560, height: 1440, bitrate: '5000k' }
    };

    const settings = qualitySettings[quality];
    const outputPath = `/app/recordings/${recordingId}.mp4`;

    // Start screen recording
    const recording = ffmpeg()
      .input('screen')
      .inputOptions([
        '-f gdigrab',
        '-framerate', fps.toString(),
        '-video_size', `${settings.width}x${settings.height}`
      ]);

    if (audio) {
      recording.input('audio=Microphone')
        .inputOptions(['-f dshow']);
    }

    recording
      .output(outputPath)
      .videoCodec('libx264')
      .videoBitrate(settings.bitrate)
      .audioCodec('aac')
      .audioBitrate('128k')
      .outputOptions([
        '-preset fast',
        '-crf 23',
        '-pix_fmt yuv420p'
      ]);

    recording.on('start', () => {
      logger.info(`Screen recording started: ${recordingId}`);
      screenRecordingCounter.inc();
    });

    recording.on('error', (err) => {
      logger.error(`Recording error: ${err.message}`);
      activeRecordings.delete(userId);
    });

    recording.on('end', () => {
      logger.info(`Screen recording completed: ${recordingId}`);
      activeRecordings.delete(userId);
    });

    recording.run();

    // Store recording info
    activeRecordings.set(userId, {
      id: recordingId,
      process: recording,
      startTime: new Date(),
      settings: { quality, fps, audio }
    });

    // Save to database
    await db.collection('screen_recordings').insertOne({
      id: recordingId,
      userId,
      startTime: new Date(),
      status: 'recording',
      settings: { quality, fps, audio },
      filePath: outputPath
    });

    res.json({
      success: true,
      recordingId,
      message: 'Screen recording started'
    });

  } catch (error) {
    logger.error('Start recording error:', error);
    res.status(500).json({ error: 'Failed to start recording' });
  }
});

app.post('/stop-recording', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const recording = activeRecordings.get(userId);

    if (!recording) {
      return res.status(400).json({ error: 'No active recording found' });
    }

    // Stop the recording
    recording.process.kill('SIGTERM');
    activeRecordings.delete(userId);

    // Update database
    await db.collection('screen_recordings').updateOne(
      { id: recording.id },
      {
        $set: {
          status: 'completed',
          endTime: new Date(),
          duration: Date.now() - recording.startTime.getTime()
        }
      }
    );

    res.json({
      success: true,
      recordingId: recording.id,
      message: 'Screen recording stopped'
    });

  } catch (error) {
    logger.error('Stop recording error:', error);
    res.status(500).json({ error: 'Failed to stop recording' });
  }
});

// Screen Sharing Routes
app.post('/start-screen-share', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const shareId = `share_${userId}_${Date.now()}`;

    // Check if user already has an active share
    if (activeScreenShares.has(userId)) {
      return res.status(400).json({ error: 'Screen share already active' });
    }

    // Create WebRTC peer connection for screen sharing
    const shareSession = {
      id: shareId,
      userId,
      startTime: new Date(),
      viewers: new Set(),
      isActive: true
    };

    activeScreenShares.set(userId, shareSession);
    activeScreenShares.set(shareSession.viewers.size);

    // Save to database
    await db.collection('screen_shares').insertOne({
      id: shareId,
      userId,
      startTime: new Date(),
      status: 'active',
      viewerCount: 0
    });

    res.json({
      success: true,
      shareId,
      message: 'Screen sharing started'
    });

  } catch (error) {
    logger.error('Start screen share error:', error);
    res.status(500).json({ error: 'Failed to start screen sharing' });
  }
});

app.post('/stop-screen-share', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const shareSession = activeScreenShares.get(userId);

    if (!shareSession) {
      return res.status(400).json({ error: 'No active screen share found' });
    }

    shareSession.isActive = false;
    activeScreenShares.delete(userId);
    activeScreenShares.set(0);

    // Notify all viewers
    io.to(`share_${shareSession.id}`).emit('screen_share_ended');

    // Update database
    await db.collection('screen_shares').updateOne(
      { id: shareSession.id },
      {
        $set: {
          status: 'ended',
          endTime: new Date(),
          duration: Date.now() - shareSession.startTime.getTime()
        }
      }
    );

    res.json({
      success: true,
      shareId: shareSession.id,
      message: 'Screen sharing stopped'
    });

  } catch (error) {
    logger.error('Stop screen share error:', error);
    res.status(500).json({ error: 'Failed to stop screen sharing' });
  }
});

// Screenshot Routes
app.post('/take-screenshot', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const screenshotId = `screenshot_${userId}_${Date.now()}`;

    // Take screenshot
    const img = await screenshot({ format: 'png' });
    
    // Process with Sharp
    const processedImg = await sharp(img)
      .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
      .png({ quality: 90 })
      .toBuffer();

    // Save to database
    await db.collection('screenshots').insertOne({
      id: screenshotId,
      userId,
      timestamp: new Date(),
      data: processedImg,
      size: processedImg.length
    });

    res.json({
      success: true,
      screenshotId,
      data: processedImg.toString('base64'),
      message: 'Screenshot captured'
    });

  } catch (error) {
    logger.error('Screenshot error:', error);
    res.status(500).json({ error: 'Failed to take screenshot' });
  }
});

// Remote Control Routes (with proper security)
app.post('/remote-control', authenticateToken, [
  body('action').isIn(['click', 'type', 'key', 'scroll']),
  body('x').optional().isInt(),
  body('y').optional().isInt(),
  body('text').optional().isString(),
  body('key').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { action, x, y, text, key } = req.body;
    const userId = req.user.id;

    // Check if user has remote control permission
    const user = await db.collection('users').findOne({ _id: userId });
    if (!user || !user.permissions?.remoteControl) {
      return res.status(403).json({ error: 'Remote control permission denied' });
    }

    switch (action) {
      case 'click':
        if (x !== undefined && y !== undefined) {
          robot.moveMouse(x, y);
          robot.mouseClick();
        }
        break;
      case 'type':
        if (text) {
          robot.typeString(text);
        }
        break;
      case 'key':
        if (key) {
          robot.keyTap(key);
        }
        break;
      case 'scroll':
        robot.scrollMouse(x || 0, y || 0);
        break;
    }

    // Log the action
    await db.collection('remote_control_logs').insertOne({
      userId,
      action,
      parameters: { x, y, text, key },
      timestamp: new Date()
    });

    res.json({ success: true, message: 'Remote control action executed' });

  } catch (error) {
    logger.error('Remote control error:', error);
    res.status(500).json({ error: 'Failed to execute remote control action' });
  }
});

// Get user recordings
app.get('/recordings', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const recordings = await db.collection('screen_recordings')
      .find({ userId })
      .sort({ startTime: -1 })
      .limit(50)
      .toArray();

    res.json({ recordings });
  } catch (error) {
    logger.error('Get recordings error:', error);
    res.status(500).json({ error: 'Failed to fetch recordings' });
  }
});

// Socket.IO for real-time features
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_screen_share', async (data) => {
    const { shareId, token } = data;
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const shareSession = Array.from(activeScreenShares.values())
        .find(session => session.id === shareId);

      if (shareSession && shareSession.isActive) {
        socket.join(`share_${shareId}`);
        shareSession.viewers.add(socket.id);
        
        socket.emit('screen_share_joined', { shareId });
        socket.to(`share_${shareId}`).emit('viewer_joined', { 
          viewerId: socket.id,
          viewerCount: shareSession.viewers.size 
        });
      } else {
        socket.emit('error', { message: 'Screen share not found or inactive' });
      }
    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('screen_frame', (data) => {
    // Broadcast screen frame to viewers
    socket.to(`share_${data.shareId}`).emit('screen_frame', data);
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
    
    // Remove from all screen shares
    activeScreenShares.forEach((session) => {
      if (session.viewers.has(socket.id)) {
        session.viewers.delete(socket.id);
        socket.to(`share_${session.id}`).emit('viewer_left', {
          viewerId: socket.id,
          viewerCount: session.viewers.size
        });
      }
    });
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'v-screen',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeRecordings: activeRecordings.size,
    activeScreenShares: activeScreenShares.size
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
const PORT = process.env.PORT || 3045;

async function startServer() {
  await connectDatabases();
  
  server.listen(PORT, () => {
    logger.info(`V-Screen service running on port ${PORT}`);
  });
}

startServer().catch(error => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Stop all active recordings
  activeRecordings.forEach((recording) => {
    recording.process.kill('SIGTERM');
  });
  
  // Close database connections
  if (redisClient) await redisClient.quit();
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
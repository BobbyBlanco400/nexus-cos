const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const NodeMediaServer = require('node-media-server');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const { Pool } = require('pg');
const redis = require('redis');
const winston = require('winston');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs').promises;
require('dotenv').config();

// Set FFmpeg path
ffmpeg.setFfmpegPath(ffmpegStatic);

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/streaming-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/streaming-combined.log' }),
    new winston.transports.Console()
  ]
});

// Database connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://nexus_user:password@localhost:5432/nexus_cos'
});

// Redis connection
const redisClient = redis.createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});
redisClient.connect();

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3043;
const RTMP_PORT = process.env.RTMP_PORT || 1935;
const HLS_PORT = process.env.HLS_PORT || 8000;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests from this IP'
});
app.use(limiter);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve HLS files
app.use('/hls', express.static(path.join(__dirname, 'hls')));

// JWT middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'nexus-cos-secret', (err, user) => {
    if (err) {
      return res.status(403).json({ message: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Socket.io authentication
io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  if (!token) {
    return next(new Error('Authentication error'));
  }

  jwt.verify(token, process.env.JWT_SECRET || 'nexus-cos-secret', (err, user) => {
    if (err) {
      return next(new Error('Authentication error'));
    }
    socket.user = user;
    next();
  });
});

// Node Media Server configuration
const nms = new NodeMediaServer({
  rtmp: {
    port: RTMP_PORT,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: HLS_PORT,
    mediaroot: './media',
    allow_origin: '*'
  },
  relay: {
    ffmpeg: ffmpegStatic,
    tasks: []
  }
});

// RTMP events
nms.on('preConnect', (id, args) => {
  logger.info(`[NodeEvent on preConnect] id=${id} args=${JSON.stringify(args)}`);
});

nms.on('postConnect', (id, args) => {
  logger.info(`[NodeEvent on postConnect] id=${id} args=${JSON.stringify(args)}`);
});

nms.on('doneConnect', (id, args) => {
  logger.info(`[NodeEvent on doneConnect] id=${id} args=${JSON.stringify(args)}`);
});

nms.on('prePublish', async (id, StreamPath, args) => {
  logger.info(`[NodeEvent on prePublish] id=${id} StreamPath=${StreamPath} args=${JSON.stringify(args)}`);
  
  // Extract stream key from path
  const streamKey = StreamPath.split('/').pop();
  
  try {
    // Verify stream key
    const result = await pool.query(
      'SELECT * FROM streams WHERE stream_key = $1 AND status = $2',
      [streamKey, 'active']
    );

    if (result.rows.length === 0) {
      logger.warn(`Invalid stream key: ${streamKey}`);
      return;
    }

    const stream = result.rows[0];
    
    // Update stream status
    await pool.query(
      'UPDATE streams SET status = $1, started_at = NOW() WHERE id = $2',
      ['live', stream.id]
    );

    // Notify viewers
    io.to(`stream_${stream.id}`).emit('stream_started', { streamId: stream.id });
    
    logger.info(`Stream started: ${stream.title} by user ${stream.user_id}`);
  } catch (error) {
    logger.error('Stream verification error:', error);
  }
});

nms.on('postPublish', (id, StreamPath, args) => {
  logger.info(`[NodeEvent on postPublish] id=${id} StreamPath=${StreamPath} args=${JSON.stringify(args)}`);
});

nms.on('donePublish', async (id, StreamPath, args) => {
  logger.info(`[NodeEvent on donePublish] id=${id} StreamPath=${StreamPath} args=${JSON.stringify(args)}`);
  
  const streamKey = StreamPath.split('/').pop();
  
  try {
    // Update stream status
    const result = await pool.query(
      'UPDATE streams SET status = $1, ended_at = NOW() WHERE stream_key = $2 RETURNING *',
      ['ended', streamKey]
    );

    if (result.rows.length > 0) {
      const stream = result.rows[0];
      
      // Notify viewers
      io.to(`stream_${stream.id}`).emit('stream_ended', { streamId: stream.id });
      
      logger.info(`Stream ended: ${stream.title}`);
    }
  } catch (error) {
    logger.error('Stream end error:', error);
  }
});

// Create stream
app.post('/streams', authenticateToken, async (req, res) => {
  try {
    const { title, description, category, isPrivate = false } = req.body;
    
    if (!title) {
      return res.status(400).json({ message: 'Title is required' });
    }

    const streamId = uuidv4();
    const streamKey = uuidv4();

    const result = await pool.query(
      `INSERT INTO streams (id, user_id, title, description, category, stream_key, is_private, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
      [streamId, req.user.id, title, description, category, streamKey, isPrivate, 'created']
    );

    const stream = result.rows[0];
    
    // Cache stream info
    await redisClient.setEx(`stream:${streamId}`, 3600, JSON.stringify(stream));

    logger.info(`Stream created: ${title} by user ${req.user.id}`);
    res.status(201).json({ stream });
  } catch (error) {
    logger.error('Create stream error:', error);
    res.status(500).json({ message: 'Failed to create stream' });
  }
});

// Get user streams
app.get('/streams', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM streams WHERE user_id = $1';
    let params = [req.user.id];
    let paramIndex = 2;

    if (status) {
      query += ` AND status = $${paramIndex}`;
      params.push(status);
      paramIndex++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({ streams: result.rows });
  } catch (error) {
    logger.error('Get streams error:', error);
    res.status(500).json({ message: 'Failed to fetch streams' });
  }
});

// Get public streams
app.get('/streams/public', async (req, res) => {
  try {
    const { page = 1, limit = 20, category, search } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT s.*, u.username FROM streams s JOIN users u ON s.user_id = u.id WHERE s.is_private = false AND s.status = $1';
    let params = ['live'];
    let paramIndex = 2;

    if (category) {
      query += ` AND s.category = $${paramIndex}`;
      params.push(category);
      paramIndex++;
    }

    if (search) {
      query += ` AND (s.title ILIKE $${paramIndex} OR s.description ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` ORDER BY s.viewer_count DESC, s.started_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    res.json({ streams: result.rows });
  } catch (error) {
    logger.error('Get public streams error:', error);
    res.status(500).json({ message: 'Failed to fetch streams' });
  }
});

// Get specific stream
app.get('/streams/:id', async (req, res) => {
  try {
    // Try cache first
    const cached = await redisClient.get(`stream:${req.params.id}`);
    if (cached) {
      return res.json({ stream: JSON.parse(cached) });
    }

    const result = await pool.query(
      'SELECT s.*, u.username FROM streams s JOIN users u ON s.user_id = u.id WHERE s.id = $1',
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Stream not found' });
    }

    const stream = result.rows[0];
    
    // Cache for 5 minutes
    await redisClient.setEx(`stream:${req.params.id}`, 300, JSON.stringify(stream));

    res.json({ stream });
  } catch (error) {
    logger.error('Get stream error:', error);
    res.status(500).json({ message: 'Failed to fetch stream' });
  }
});

// Update stream
app.put('/streams/:id', authenticateToken, async (req, res) => {
  try {
    const { title, description, category, isPrivate } = req.body;

    const result = await pool.query(
      `UPDATE streams SET title = COALESCE($1, title), description = COALESCE($2, description),
       category = COALESCE($3, category), is_private = COALESCE($4, is_private), updated_at = NOW()
       WHERE id = $5 AND user_id = $6 RETURNING *`,
      [title, description, category, isPrivate, req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Stream not found' });
    }

    // Update cache
    await redisClient.del(`stream:${req.params.id}`);

    res.json({ stream: result.rows[0] });
  } catch (error) {
    logger.error('Update stream error:', error);
    res.status(500).json({ message: 'Failed to update stream' });
  }
});

// Delete stream
app.delete('/streams/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'DELETE FROM streams WHERE id = $1 AND user_id = $2 RETURNING *',
      [req.params.id, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Stream not found' });
    }

    // Clear cache
    await redisClient.del(`stream:${req.params.id}`);

    res.json({ message: 'Stream deleted successfully' });
  } catch (error) {
    logger.error('Delete stream error:', error);
    res.status(500).json({ message: 'Failed to delete stream' });
  }
});

// Socket.io connection handling
io.on('connection', (socket) => {
  logger.info(`User connected: ${socket.user.id}`);

  // Join stream room
  socket.on('join_stream', async (streamId) => {
    try {
      socket.join(`stream_${streamId}`);
      
      // Increment viewer count
      await pool.query(
        'UPDATE streams SET viewer_count = viewer_count + 1 WHERE id = $1',
        [streamId]
      );

      // Notify other viewers
      socket.to(`stream_${streamId}`).emit('viewer_joined', {
        userId: socket.user.id,
        username: socket.user.username
      });

      logger.info(`User ${socket.user.id} joined stream ${streamId}`);
    } catch (error) {
      logger.error('Join stream error:', error);
    }
  });

  // Leave stream room
  socket.on('leave_stream', async (streamId) => {
    try {
      socket.leave(`stream_${streamId}`);
      
      // Decrement viewer count
      await pool.query(
        'UPDATE streams SET viewer_count = GREATEST(viewer_count - 1, 0) WHERE id = $1',
        [streamId]
      );

      // Notify other viewers
      socket.to(`stream_${streamId}`).emit('viewer_left', {
        userId: socket.user.id,
        username: socket.user.username
      });

      logger.info(`User ${socket.user.id} left stream ${streamId}`);
    } catch (error) {
      logger.error('Leave stream error:', error);
    }
  });

  // Chat message
  socket.on('chat_message', async (data) => {
    try {
      const { streamId, message } = data;
      
      // Save message to database
      await pool.query(
        'INSERT INTO chat_messages (stream_id, user_id, message) VALUES ($1, $2, $3)',
        [streamId, socket.user.id, message]
      );

      // Broadcast to stream room
      io.to(`stream_${streamId}`).emit('chat_message', {
        userId: socket.user.id,
        username: socket.user.username,
        message,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Chat message error:', error);
    }
  });

  socket.on('disconnect', () => {
    logger.info(`User disconnected: ${socket.user.id}`);
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'streaming', 
    timestamp: new Date().toISOString() 
  });
});

// Error handling
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

// Start servers
nms.run();
server.listen(PORT, () => {
  logger.info(`Streaming Service running on port ${PORT}`);
  logger.info(`RTMP Server running on port ${RTMP_PORT}`);
  logger.info(`HLS Server running on port ${HLS_PORT}`);
});

module.exports = app;
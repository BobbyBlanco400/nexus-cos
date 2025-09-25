const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const multer = require('multer');
const sharp = require('sharp');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const AWS = require('aws-sdk');
const { Pool } = require('pg');
const redis = require('redis');
const winston = require('winston');
const { v4: uuidv4 } = require('uuid');
const mime = require('mime-types');
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
    new winston.transports.File({ filename: 'logs/content-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/content-combined.log' }),
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

// AWS S3 setup
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

const app = express();
const PORT = process.env.PORT || 3042;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: 'Too many requests from this IP'
});
app.use(limiter);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Multer configuration for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'image/jpeg', 'image/png', 'image/gif', 'image/webp',
      'video/mp4', 'video/avi', 'video/mov', 'video/wmv',
      'audio/mp3', 'audio/wav', 'audio/aac', 'audio/ogg',
      'application/pdf', 'text/plain'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'), false);
    }
  }
});

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

// Content upload endpoint
app.post('/upload', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const { originalname, mimetype, buffer, size } = req.file;
    const fileId = uuidv4();
    const fileExtension = path.extname(originalname);
    const fileName = `${fileId}${fileExtension}`;
    
    let processedBuffer = buffer;
    let thumbnailUrl = null;

    // Process images
    if (mimetype.startsWith('image/')) {
      processedBuffer = await sharp(buffer)
        .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 85 })
        .toBuffer();

      // Create thumbnail
      const thumbnailBuffer = await sharp(buffer)
        .resize(300, 200, { fit: 'cover' })
        .jpeg({ quality: 80 })
        .toBuffer();

      // Upload thumbnail to S3
      const thumbnailKey = `thumbnails/${fileId}_thumb.jpg`;
      await s3.upload({
        Bucket: process.env.S3_BUCKET,
        Key: thumbnailKey,
        Body: thumbnailBuffer,
        ContentType: 'image/jpeg'
      }).promise();

      thumbnailUrl = `https://${process.env.S3_BUCKET}.s3.amazonaws.com/${thumbnailKey}`;
    }

    // Upload main file to S3
    const uploadParams = {
      Bucket: process.env.S3_BUCKET,
      Key: `content/${fileName}`,
      Body: processedBuffer,
      ContentType: mimetype
    };

    const uploadResult = await s3.upload(uploadParams).promise();

    // Save to database
    const result = await pool.query(
      `INSERT INTO content (id, user_id, original_name, file_name, file_type, file_size, url, thumbnail_url, status)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [fileId, req.user.id, originalname, fileName, mimetype, size, uploadResult.Location, thumbnailUrl, 'active']
    );

    logger.info(`File uploaded: ${originalname} by user ${req.user.id}`);
    res.status(201).json({ content: result.rows[0] });
  } catch (error) {
    logger.error('Upload error:', error);
    res.status(500).json({ message: 'Upload failed' });
  }
});

// Get user content
app.get('/content', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 20, type, search } = req.query;
    const offset = (page - 1) * limit;

    let query = 'SELECT * FROM content WHERE user_id = $1 AND status = $2';
    let params = [req.user.id, 'active'];
    let paramIndex = 3;

    if (type) {
      query += ` AND file_type LIKE $${paramIndex}`;
      params.push(`${type}%`);
      paramIndex++;
    }

    if (search) {
      query += ` AND original_name ILIKE $${paramIndex}`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM content WHERE user_id = $1 AND status = $2';
    let countParams = [req.user.id, 'active'];
    
    if (type) {
      countQuery += ' AND file_type LIKE $3';
      countParams.push(`${type}%`);
    }
    
    const countResult = await pool.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      content: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    logger.error('Get content error:', error);
    res.status(500).json({ message: 'Failed to fetch content' });
  }
});

// Get specific content
app.get('/content/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM content WHERE id = $1 AND user_id = $2 AND status = $3',
      [req.params.id, req.user.id, 'active']
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Content not found' });
    }

    res.json({ content: result.rows[0] });
  } catch (error) {
    logger.error('Get content error:', error);
    res.status(500).json({ message: 'Failed to fetch content' });
  }
});

// Delete content
app.delete('/content/:id', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM content WHERE id = $1 AND user_id = $2 AND status = $3',
      [req.params.id, req.user.id, 'active']
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Content not found' });
    }

    const content = result.rows[0];

    // Delete from S3
    const deleteParams = {
      Bucket: process.env.S3_BUCKET,
      Key: `content/${content.file_name}`
    };
    await s3.deleteObject(deleteParams).promise();

    // Delete thumbnail if exists
    if (content.thumbnail_url) {
      const thumbnailKey = `thumbnails/${content.id}_thumb.jpg`;
      await s3.deleteObject({
        Bucket: process.env.S3_BUCKET,
        Key: thumbnailKey
      }).promise();
    }

    // Mark as deleted in database
    await pool.query(
      'UPDATE content SET status = $1, deleted_at = NOW() WHERE id = $2',
      ['deleted', req.params.id]
    );

    logger.info(`Content deleted: ${content.original_name} by user ${req.user.id}`);
    res.json({ message: 'Content deleted successfully' });
  } catch (error) {
    logger.error('Delete content error:', error);
    res.status(500).json({ message: 'Failed to delete content' });
  }
});

// Video transcoding endpoint
app.post('/transcode/:id', authenticateToken, async (req, res) => {
  try {
    const { quality = '720p' } = req.body;
    
    const result = await pool.query(
      'SELECT * FROM content WHERE id = $1 AND user_id = $2 AND file_type LIKE $3',
      [req.params.id, req.user.id, 'video%']
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Video not found' });
    }

    const content = result.rows[0];
    
    // Start transcoding job (this would typically be queued)
    const jobId = uuidv4();
    
    // Update content status
    await pool.query(
      'UPDATE content SET processing_status = $1, processing_job_id = $2 WHERE id = $3',
      ['transcoding', jobId, req.params.id]
    );

    logger.info(`Transcoding started for video ${content.original_name}`);
    res.json({ message: 'Transcoding started', jobId });
  } catch (error) {
    logger.error('Transcoding error:', error);
    res.status(500).json({ message: 'Transcoding failed' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'content-management', 
    timestamp: new Date().toISOString() 
  });
});

// Error handling
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

app.listen(PORT, () => {
  logger.info(`Content Management Service running on port ${PORT}`);
});

module.exports = app;
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const winston = require('winston');
const promClient = require('prom-client');
const sharp = require('sharp');
const archiver = require('archiver');

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
    new winston.transports.File({ filename: 'logs/creator-hub-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/creator-hub.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'creator_hub_http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const projectCounter = new promClient.Counter({
  name: 'creator_hub_projects_total',
  help: 'Total number of projects created'
});

const assetCounter = new promClient.Counter({
  name: 'creator_hub_assets_total',
  help: 'Total number of assets uploaded'
});

const activeCollaborationsGauge = new promClient.Gauge({
  name: 'creator_hub_active_collaborations',
  help: 'Number of active collaboration sessions'
});

register.registerMetric(httpRequestDuration);
register.registerMetric(projectCounter);
register.registerMetric(assetCounter);
register.registerMetric(activeCollaborationsGauge);

// Middleware
app.use(helmet());
app.use(compression());
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200 // limit each IP to 200 requests per windowMs
});
app.use('/api/', limiter);

// File upload configuration
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = path.join(__dirname, 'uploads', req.body.projectId || 'general');
    await fs.mkdir(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|mp4|mov|avi|mp3|wav|pdf|doc|docx|txt|zip|rar/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  }
});

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

// Project Management System
class ProjectManager {
  constructor() {
    this.projects = new Map();
    this.templates = new Map();
    this.collaborations = new Map();
    this.initializeTemplates();
  }

  initializeTemplates() {
    const defaultTemplates = [
      {
        id: 'video-production',
        name: 'Video Production',
        description: 'Complete video production workflow',
        category: 'video',
        assets: ['storyboard', 'script', 'footage', 'audio', 'graphics']
      },
      {
        id: 'podcast-series',
        name: 'Podcast Series',
        description: 'Podcast creation and management',
        category: 'audio',
        assets: ['episodes', 'intro-outro', 'show-notes', 'artwork']
      },
      {
        id: 'social-media-campaign',
        name: 'Social Media Campaign',
        description: 'Multi-platform social media content',
        category: 'marketing',
        assets: ['posts', 'stories', 'reels', 'graphics', 'captions']
      }
    ];

    defaultTemplates.forEach(template => {
      this.templates.set(template.id, template);
    });
  }

  async createProject(config) {
    const projectId = `proj_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const project = {
      id: projectId,
      name: config.name,
      description: config.description || '',
      template: config.template || null,
      owner: config.owner,
      collaborators: config.collaborators || [],
      status: 'active',
      created: new Date(),
      lastModified: new Date(),
      assets: [],
      metadata: config.metadata || {}
    };

    this.projects.set(projectId, project);
    projectCounter.inc();

    return project;
  }

  async getProject(projectId) {
    return this.projects.get(projectId);
  }

  async listProjects(ownerId) {
    return Array.from(this.projects.values()).filter(
      project => project.owner === ownerId || project.collaborators.includes(ownerId)
    );
  }

  async updateProject(projectId, updates) {
    const project = this.projects.get(projectId);
    if (project) {
      Object.assign(project, updates, { lastModified: new Date() });
      return project;
    }
    return null;
  }

  async deleteProject(projectId) {
    return this.projects.delete(projectId);
  }

  async addAsset(projectId, asset) {
    const project = this.projects.get(projectId);
    if (project) {
      project.assets.push(asset);
      project.lastModified = new Date();
      assetCounter.inc();
      return asset;
    }
    return null;
  }

  getTemplates() {
    return Array.from(this.templates.values());
  }

  startCollaboration(projectId, userId) {
    const sessionId = `collab_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    this.collaborations.set(sessionId, {
      id: sessionId,
      projectId: projectId,
      userId: userId,
      started: new Date()
    });
    activeCollaborationsGauge.inc();
    return sessionId;
  }

  endCollaboration(sessionId) {
    const deleted = this.collaborations.delete(sessionId);
    if (deleted) {
      activeCollaborationsGauge.dec();
    }
    return deleted;
  }
}

const projectManager = new ProjectManager();

// Asset Management System
class AssetManager {
  constructor() {
    this.assets = new Map();
  }

  async processAsset(file, projectId) {
    const assetId = `asset_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    
    const asset = {
      id: assetId,
      originalName: file.originalname,
      filename: file.filename,
      path: file.path,
      size: file.size,
      mimetype: file.mimetype,
      projectId: projectId,
      uploaded: new Date(),
      processed: false,
      metadata: {}
    };

    // Process different asset types
    if (file.mimetype.startsWith('image/')) {
      await this.processImage(asset);
    } else if (file.mimetype.startsWith('video/')) {
      await this.processVideo(asset);
    }

    this.assets.set(assetId, asset);
    return asset;
  }

  async processImage(asset) {
    try {
      const image = sharp(asset.path);
      const metadata = await image.metadata();
      
      asset.metadata = {
        width: metadata.width,
        height: metadata.height,
        format: metadata.format,
        channels: metadata.channels
      };

      // Generate thumbnail
      const thumbnailPath = asset.path.replace(/\.[^/.]+$/, '_thumb.jpg');
      await image
        .resize(300, 300, { fit: 'inside', withoutEnlargement: true })
        .jpeg({ quality: 80 })
        .toFile(thumbnailPath);
      
      asset.thumbnail = thumbnailPath;
      asset.processed = true;
    } catch (error) {
      logger.error('Error processing image:', error);
    }
  }

  async processVideo(asset) {
    try {
      // Basic video metadata (would use ffprobe in production)
      asset.metadata = {
        type: 'video',
        duration: 'unknown' // Would extract with ffprobe
      };
      asset.processed = true;
    } catch (error) {
      logger.error('Error processing video:', error);
    }
  }

  async getAsset(assetId) {
    return this.assets.get(assetId);
  }

  async listAssets(projectId) {
    return Array.from(this.assets.values()).filter(asset => asset.projectId === projectId);
  }

  async deleteAsset(assetId) {
    const asset = this.assets.get(assetId);
    if (asset) {
      try {
        await fs.unlink(asset.path);
        if (asset.thumbnail) {
          await fs.unlink(asset.thumbnail);
        }
      } catch (error) {
        logger.error('Error deleting asset files:', error);
      }
      return this.assets.delete(assetId);
    }
    return false;
  }
}

const assetManager = new AssetManager();

// API Routes
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'Creator Hub Content Creation Platform',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    projects: projectManager.projects.size,
    assets: assetManager.assets.size
  });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Project Management API
app.post('/api/projects', [
  body('name').isLength({ min: 1 }).withMessage('Project name is required'),
  body('owner').isLength({ min: 1 }).withMessage('Owner is required')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const project = await projectManager.createProject(req.body);
    res.status(201).json({
      success: true,
      project: project
    });
  } catch (error) {
    logger.error('Error creating project:', error);
    res.status(500).json({ error: 'Failed to create project' });
  }
});

app.get('/api/projects', async (req, res) => {
  try {
    const ownerId = req.query.owner;
    if (!ownerId) {
      return res.status(400).json({ error: 'Owner ID is required' });
    }

    const projects = await projectManager.listProjects(ownerId);
    res.json({
      success: true,
      projects: projects
    });
  } catch (error) {
    logger.error('Error listing projects:', error);
    res.status(500).json({ error: 'Failed to list projects' });
  }
});

app.get('/api/projects/:id', async (req, res) => {
  try {
    const project = await projectManager.getProject(req.params.id);
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }

    const assets = await assetManager.listAssets(req.params.id);
    res.json({
      success: true,
      project: project,
      assets: assets
    });
  } catch (error) {
    logger.error('Error getting project:', error);
    res.status(500).json({ error: 'Failed to get project' });
  }
});

app.put('/api/projects/:id', async (req, res) => {
  try {
    const project = await projectManager.updateProject(req.params.id, req.body);
    if (!project) {
      return res.status(404).json({ error: 'Project not found' });
    }

    res.json({
      success: true,
      project: project
    });
  } catch (error) {
    logger.error('Error updating project:', error);
    res.status(500).json({ error: 'Failed to update project' });
  }
});

app.delete('/api/projects/:id', async (req, res) => {
  try {
    const deleted = await projectManager.deleteProject(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Project not found' });
    }

    res.json({
      success: true,
      message: 'Project deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting project:', error);
    res.status(500).json({ error: 'Failed to delete project' });
  }
});

// Asset Management API
app.post('/api/assets/upload', upload.array('files', 10), async (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ error: 'No files uploaded' });
    }

    const projectId = req.body.projectId;
    if (!projectId) {
      return res.status(400).json({ error: 'Project ID is required' });
    }

    const assets = [];
    for (const file of req.files) {
      const asset = await assetManager.processAsset(file, projectId);
      await projectManager.addAsset(projectId, asset);
      assets.push(asset);
    }

    res.status(201).json({
      success: true,
      assets: assets
    });
  } catch (error) {
    logger.error('Error uploading assets:', error);
    res.status(500).json({ error: 'Failed to upload assets' });
  }
});

app.get('/api/assets/:id', async (req, res) => {
  try {
    const asset = await assetManager.getAsset(req.params.id);
    if (!asset) {
      return res.status(404).json({ error: 'Asset not found' });
    }

    res.json({
      success: true,
      asset: asset
    });
  } catch (error) {
    logger.error('Error getting asset:', error);
    res.status(500).json({ error: 'Failed to get asset' });
  }
});

app.delete('/api/assets/:id', async (req, res) => {
  try {
    const deleted = await assetManager.deleteAsset(req.params.id);
    if (!deleted) {
      return res.status(404).json({ error: 'Asset not found' });
    }

    res.json({
      success: true,
      message: 'Asset deleted successfully'
    });
  } catch (error) {
    logger.error('Error deleting asset:', error);
    res.status(500).json({ error: 'Failed to delete asset' });
  }
});

// Template Library API
app.get('/api/templates', async (req, res) => {
  try {
    const templates = projectManager.getTemplates();
    res.json({
      success: true,
      templates: templates
    });
  } catch (error) {
    logger.error('Error getting templates:', error);
    res.status(500).json({ error: 'Failed to get templates' });
  }
});

// Collaboration API
app.post('/api/collaboration/start', async (req, res) => {
  try {
    const { projectId, userId } = req.body;
    if (!projectId || !userId) {
      return res.status(400).json({ error: 'Project ID and User ID are required' });
    }

    const sessionId = projectManager.startCollaboration(projectId, userId);
    res.json({
      success: true,
      sessionId: sessionId
    });
  } catch (error) {
    logger.error('Error starting collaboration:', error);
    res.status(500).json({ error: 'Failed to start collaboration' });
  }
});

app.post('/api/collaboration/end', async (req, res) => {
  try {
    const { sessionId } = req.body;
    if (!sessionId) {
      return res.status(400).json({ error: 'Session ID is required' });
    }

    const ended = projectManager.endCollaboration(sessionId);
    if (!ended) {
      return res.status(404).json({ error: 'Collaboration session not found' });
    }

    res.json({
      success: true,
      message: 'Collaboration ended successfully'
    });
  } catch (error) {
    logger.error('Error ending collaboration:', error);
    res.status(500).json({ error: 'Failed to end collaboration' });
  }
});

// WebSocket connection handling
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_project', (projectId) => {
    socket.join(`project_${projectId}`);
    logger.info(`Client ${socket.id} joined project ${projectId}`);
  });

  socket.on('leave_project', (projectId) => {
    socket.leave(`project_${projectId}`);
    logger.info(`Client ${socket.id} left project ${projectId}`);
  });

  socket.on('project_update', (data) => {
    socket.to(`project_${data.projectId}`).emit('project_updated', data);
  });

  socket.on('asset_update', (data) => {
    socket.to(`project_${data.projectId}`).emit('asset_updated', data);
  });

  socket.on('disconnect', () => {
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

const PORT = process.env.PORT || 3020;
const HOST = process.env.HOST || '0.0.0.0';

server.listen(PORT, HOST, () => {
  logger.info(`Creator Hub Content Creation Platform running on ${HOST}:${PORT}`);
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
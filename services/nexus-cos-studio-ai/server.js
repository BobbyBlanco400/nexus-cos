const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const { body, validationResult } = require('express-validator');
const multer = require('multer');
const { MongoClient } = require('mongodb');
const redis = require('redis');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const winston = require('winston');
const promClient = require('prom-client');
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const moment = require('moment');
const { OpenAI } = require('openai');
const Anthropic = require('@anthropic-ai/sdk');
const { VertexAI } = require('@google-cloud/aiplatform');
const { CohereClient } = require('cohere-ai');
const Replicate = require('replicate');
const StabilityAI = require('stability-ai');
const { ElevenLabsAPI } = require('elevenlabs');
const textToSpeech = require('@google-cloud/text-to-speech');
const speech = require('@google-cloud/speech');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const sharp = require('sharp');
const Canvas = require('canvas');
const { fabric } = require('fabric');
const THREE = require('three');
const BABYLON = require('babylonjs');
const Tone = require('tone');
const fetch = require('node-fetch');
const axios = require('axios');
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');
const { chromium } = require('playwright');
const WebSocket = require('ws');
const cron = require('node-cron');
const Queue = require('bull');
const IORedis = require('ioredis');
const archiver = require('archiver');
const unzipper = require('unzipper');
const PDFLib = require('pdf-lib');
const { Document, Packer, Paragraph, TextRun } = require('docx');
const XLSX = require('xlsx');
const csv = require('csv-parser');
const { Parser } = require('json2csv');
const MarkdownIt = require('markdown-it');
const TurndownService = require('turndown');
const hljs = require('highlight.js');
const Prism = require('prismjs');
const d3 = require('d3');

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

// AI Services initialization
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

const cohere = new CohereClient({
  token: process.env.COHERE_API_KEY
});

const replicate = new Replicate({
  auth: process.env.REPLICATE_API_TOKEN
});

const stabilityAI = new StabilityAI({
  apiKey: process.env.STABILITY_API_KEY
});

const elevenLabs = new ElevenLabsAPI({
  apiKey: process.env.ELEVENLABS_API_KEY
});

// Google Cloud services
const ttsClient = new textToSpeech.TextToSpeechClient({
  keyFilename: process.env.GOOGLE_CLOUD_KEY_FILE
});

const speechClient = new speech.SpeechClient({
  keyFilename: process.env.GOOGLE_CLOUD_KEY_FILE
});

// AWS S3 configuration
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// Redis for job queues
const redisConfig = {
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD
};

// Job queues
const contentGenerationQueue = new Queue('content generation', redisConfig);
const mediaProcessingQueue = new Queue('media processing', redisConfig);
const aiAnalysisQueue = new Queue('ai analysis', redisConfig);
const automationQueue = new Queue('automation', redisConfig);

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const aiRequestsCounter = new promClient.Counter({
  name: 'ai_requests_total',
  help: 'Total number of AI requests',
  labelNames: ['service', 'type', 'model']
});

const contentGeneratedCounter = new promClient.Counter({
  name: 'content_generated_total',
  help: 'Total number of content pieces generated',
  labelNames: ['type', 'format']
});

const activeProjectsGauge = new promClient.Gauge({
  name: 'active_projects',
  help: 'Number of active studio projects'
});

const queueSizeGauge = new promClient.Gauge({
  name: 'queue_size',
  help: 'Size of processing queues',
  labelNames: ['queue_name']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(aiRequestsCounter);
register.registerMetric(contentGeneratedCounter);
register.registerMetric(activeProjectsGauge);
register.registerMetric(queueSizeGauge);

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
app.use(express.json({ limit: '100mb' }));
app.use(express.urlencoded({ extended: true, limit: '100mb' }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200 // limit each IP to 200 requests per windowMs
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

// Studio project management
const activeProjects = new Map();
const aiModels = new Map();
const contentTemplates = new Map();

// Initialize AI models and templates
const initializeAIModels = () => {
  const models = [
    {
      id: 'gpt-4',
      name: 'GPT-4',
      provider: 'openai',
      type: 'text',
      capabilities: ['generation', 'analysis', 'editing', 'translation'],
      maxTokens: 8192,
      costPerToken: 0.00003
    },
    {
      id: 'claude-3-opus',
      name: 'Claude 3 Opus',
      provider: 'anthropic',
      type: 'text',
      capabilities: ['generation', 'analysis', 'reasoning', 'coding'],
      maxTokens: 200000,
      costPerToken: 0.000015
    },
    {
      id: 'dall-e-3',
      name: 'DALL-E 3',
      provider: 'openai',
      type: 'image',
      capabilities: ['generation', 'editing'],
      maxResolution: '1024x1024',
      costPerImage: 0.04
    },
    {
      id: 'stable-diffusion-xl',
      name: 'Stable Diffusion XL',
      provider: 'stability',
      type: 'image',
      capabilities: ['generation', 'upscaling', 'inpainting'],
      maxResolution: '1024x1024',
      costPerImage: 0.02
    },
    {
      id: 'eleven-labs-v1',
      name: 'ElevenLabs Voice',
      provider: 'elevenlabs',
      type: 'audio',
      capabilities: ['tts', 'voice-cloning', 'dubbing'],
      languages: 29,
      costPerCharacter: 0.0001
    }
  ];

  models.forEach(model => {
    aiModels.set(model.id, model);
  });
};

const initializeContentTemplates = () => {
  const templates = [
    {
      id: 'blog_post',
      name: 'Blog Post',
      category: 'content',
      structure: {
        title: 'string',
        introduction: 'text',
        sections: 'array',
        conclusion: 'text',
        cta: 'string'
      },
      aiPrompt: 'Write a comprehensive blog post about {topic} targeting {audience}. Include an engaging introduction, well-structured sections, and a compelling conclusion.'
    },
    {
      id: 'social_media_campaign',
      name: 'Social Media Campaign',
      category: 'marketing',
      structure: {
        platform: 'string',
        posts: 'array',
        hashtags: 'array',
        schedule: 'object'
      },
      aiPrompt: 'Create a {duration} social media campaign for {platform} about {topic}. Include engaging posts, relevant hashtags, and optimal posting schedule.'
    },
    {
      id: 'video_script',
      name: 'Video Script',
      category: 'video',
      structure: {
        hook: 'text',
        scenes: 'array',
        dialogue: 'array',
        visuals: 'array',
        cta: 'string'
      },
      aiPrompt: 'Write a {duration} minute video script about {topic} for {platform}. Include engaging hook, clear scenes, natural dialogue, and visual descriptions.'
    },
    {
      id: 'podcast_episode',
      name: 'Podcast Episode',
      category: 'audio',
      structure: {
        intro: 'text',
        segments: 'array',
        questions: 'array',
        outro: 'text'
      },
      aiPrompt: 'Create a podcast episode outline about {topic} for {duration} minutes. Include intro, main segments, discussion questions, and outro.'
    }
  ];

  templates.forEach(template => {
    contentTemplates.set(template.id, template);
  });
};

// AI Content Generation Routes
app.post('/ai/generate/text', authenticateToken, [
  body('prompt').isLength({ min: 1, max: 5000 }),
  body('model').optional().isString(),
  body('maxTokens').optional().isInt({ min: 1, max: 4000 }),
  body('temperature').optional().isFloat({ min: 0, max: 2 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      prompt, 
      model = 'gpt-3.5-turbo',
      maxTokens = 1000,
      temperature = 0.7,
      systemPrompt = '',
      context = ''
    } = req.body;

    const userId = req.user.id;
    const requestId = uuidv4();

    // Add to queue for processing
    const job = await contentGenerationQueue.add('generate-text', {
      requestId,
      userId,
      prompt,
      model,
      maxTokens,
      temperature,
      systemPrompt,
      context
    });

    aiRequestsCounter.labels('text-generation', model, 'openai').inc();

    res.json({
      success: true,
      requestId,
      jobId: job.id,
      status: 'queued',
      estimatedTime: '30-60 seconds'
    });

  } catch (error) {
    logger.error('Text generation error:', error);
    res.status(500).json({ error: 'Failed to generate text' });
  }
});

app.post('/ai/generate/image', authenticateToken, [
  body('prompt').isLength({ min: 1, max: 1000 }),
  body('model').optional().isString(),
  body('size').optional().isIn(['256x256', '512x512', '1024x1024']),
  body('style').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      prompt, 
      model = 'dall-e-3',
      size = '1024x1024',
      style = 'natural',
      negativePrompt = '',
      steps = 50
    } = req.body;

    const userId = req.user.id;
    const requestId = uuidv4();

    // Add to queue for processing
    const job = await contentGenerationQueue.add('generate-image', {
      requestId,
      userId,
      prompt,
      model,
      size,
      style,
      negativePrompt,
      steps
    });

    aiRequestsCounter.labels('image-generation', model, 'openai').inc();

    res.json({
      success: true,
      requestId,
      jobId: job.id,
      status: 'queued',
      estimatedTime: '1-3 minutes'
    });

  } catch (error) {
    logger.error('Image generation error:', error);
    res.status(500).json({ error: 'Failed to generate image' });
  }
});

app.post('/ai/generate/audio', authenticateToken, [
  body('text').isLength({ min: 1, max: 5000 }),
  body('voice').optional().isString(),
  body('model').optional().isString()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      text, 
      voice = 'alloy',
      model = 'tts-1',
      speed = 1.0,
      format = 'mp3'
    } = req.body;

    const userId = req.user.id;
    const requestId = uuidv4();

    // Add to queue for processing
    const job = await contentGenerationQueue.add('generate-audio', {
      requestId,
      userId,
      text,
      voice,
      model,
      speed,
      format
    });

    aiRequestsCounter.labels('audio-generation', model, 'openai').inc();

    res.json({
      success: true,
      requestId,
      jobId: job.id,
      status: 'queued',
      estimatedTime: '30-90 seconds'
    });

  } catch (error) {
    logger.error('Audio generation error:', error);
    res.status(500).json({ error: 'Failed to generate audio' });
  }
});

// Studio Project Management
app.post('/studio/projects', authenticateToken, [
  body('name').isLength({ min: 1, max: 200 }),
  body('type').isIn(['video', 'audio', 'image', 'text', 'mixed']),
  body('description').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      name, 
      type, 
      description = '',
      settings = {},
      collaborators = []
    } = req.body;

    const userId = req.user.id;
    const projectId = uuidv4();

    const project = {
      id: projectId,
      name,
      type,
      description,
      userId,
      collaborators,
      settings: {
        aiAssistance: true,
        autoSave: true,
        versionControl: true,
        realTimeSync: true,
        ...settings
      },
      assets: [],
      timeline: [],
      versions: [],
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Save to database
    await db.collection('studio_projects').insertOne(project);
    activeProjects.set(projectId, project);
    activeProjectsGauge.set(activeProjects.size);

    res.json({
      success: true,
      project
    });

  } catch (error) {
    logger.error('Create project error:', error);
    res.status(500).json({ error: 'Failed to create project' });
  }
});

app.get('/studio/projects', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { type, status, limit = 50, offset = 0 } = req.query;

    let query = { 
      $or: [
        { userId },
        { 'collaborators.userId': userId }
      ]
    };
    
    if (type) query.type = type;
    if (status) query.status = status;

    const projects = await db.collection('studio_projects')
      .find(query)
      .sort({ updatedAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .toArray();

    const total = await db.collection('studio_projects').countDocuments(query);

    res.json({ projects, total });
  } catch (error) {
    logger.error('Get projects error:', error);
    res.status(500).json({ error: 'Failed to fetch projects' });
  }
});

// AI-Powered Content Analysis
app.post('/ai/analyze/content', authenticateToken, upload.single('file'), [
  body('type').isIn(['text', 'image', 'audio', 'video']),
  body('analysisType').isArray()
], async (req, res) => {
  try {
    const { type, analysisType, text } = req.body;
    const userId = req.user.id;
    const requestId = uuidv4();

    let content = text;
    
    // Handle file upload
    if (req.file) {
      const fileName = `analysis/${userId}/${requestId}.${req.file.originalname.split('.').pop()}`;
      
      const uploadParams = {
        Bucket: process.env.AWS_S3_BUCKET,
        Key: fileName,
        Body: req.file.buffer,
        ContentType: req.file.mimetype
      };

      const uploadResult = await s3.upload(uploadParams).promise();
      content = uploadResult.Location;
    }

    // Add to analysis queue
    const job = await aiAnalysisQueue.add('analyze-content', {
      requestId,
      userId,
      type,
      analysisType,
      content
    });

    res.json({
      success: true,
      requestId,
      jobId: job.id,
      status: 'queued'
    });

  } catch (error) {
    logger.error('Content analysis error:', error);
    res.status(500).json({ error: 'Failed to analyze content' });
  }
});

// Automation Workflows
app.post('/automation/workflows', authenticateToken, [
  body('name').isLength({ min: 1, max: 200 }),
  body('trigger').isObject(),
  body('actions').isArray()
], async (req, res) => {
  try {
    const { name, trigger, actions, description = '' } = req.body;
    const userId = req.user.id;
    const workflowId = uuidv4();

    const workflow = {
      id: workflowId,
      name,
      description,
      userId,
      trigger,
      actions,
      status: 'active',
      executions: 0,
      lastRun: null,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    await db.collection('automation_workflows').insertOne(workflow);

    res.json({
      success: true,
      workflow
    });

  } catch (error) {
    logger.error('Create workflow error:', error);
    res.status(500).json({ error: 'Failed to create workflow' });
  }
});

// Job Processing
contentGenerationQueue.process('generate-text', async (job) => {
  const { requestId, userId, prompt, model, maxTokens, temperature, systemPrompt, context } = job.data;
  
  try {
    let result;
    
    if (model.startsWith('gpt')) {
      const messages = [];
      if (systemPrompt) messages.push({ role: 'system', content: systemPrompt });
      if (context) messages.push({ role: 'user', content: `Context: ${context}` });
      messages.push({ role: 'user', content: prompt });

      const response = await openai.chat.completions.create({
        model,
        messages,
        max_tokens: maxTokens,
        temperature
      });

      result = {
        text: response.choices[0].message.content,
        usage: response.usage,
        model: response.model
      };
    } else if (model.startsWith('claude')) {
      const response = await anthropic.messages.create({
        model,
        max_tokens: maxTokens,
        messages: [{ role: 'user', content: prompt }]
      });

      result = {
        text: response.content[0].text,
        usage: response.usage,
        model: response.model
      };
    }

    // Save result
    await db.collection('ai_generations').insertOne({
      requestId,
      userId,
      type: 'text',
      prompt,
      result,
      model,
      createdAt: new Date()
    });

    contentGeneratedCounter.labels('text', model).inc();
    
    // Notify via WebSocket
    io.to(`user_${userId}`).emit('generation_complete', {
      requestId,
      type: 'text',
      result
    });

    return result;
  } catch (error) {
    logger.error('Text generation job error:', error);
    throw error;
  }
});

contentGenerationQueue.process('generate-image', async (job) => {
  const { requestId, userId, prompt, model, size, style } = job.data;
  
  try {
    let result;
    
    if (model === 'dall-e-3') {
      const response = await openai.images.generate({
        model: 'dall-e-3',
        prompt,
        size,
        style,
        n: 1
      });

      result = {
        images: response.data,
        model: 'dall-e-3'
      };
    } else if (model.startsWith('stable-diffusion')) {
      const output = await replicate.run(
        "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478",
        {
          input: {
            prompt,
            width: parseInt(size.split('x')[0]),
            height: parseInt(size.split('x')[1])
          }
        }
      );

      result = {
        images: [{ url: output[0] }],
        model: 'stable-diffusion'
      };
    }

    // Save result
    await db.collection('ai_generations').insertOne({
      requestId,
      userId,
      type: 'image',
      prompt,
      result,
      model,
      createdAt: new Date()
    });

    contentGeneratedCounter.labels('image', model).inc();
    
    // Notify via WebSocket
    io.to(`user_${userId}`).emit('generation_complete', {
      requestId,
      type: 'image',
      result
    });

    return result;
  } catch (error) {
    logger.error('Image generation job error:', error);
    throw error;
  }
});

// Socket.IO for real-time collaboration
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_user_room', async (data) => {
    const { token } = data;
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.id;
      socket.join(`user_${decoded.id}`);
      
      socket.emit('joined_user_room', { userId: decoded.id });
    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('join_project', async (data) => {
    const { projectId, token } = data;
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const project = await db.collection('studio_projects').findOne({ 
        id: projectId,
        $or: [
          { userId: decoded.id },
          { 'collaborators.userId': decoded.id }
        ]
      });

      if (project) {
        socket.join(`project_${projectId}`);
        socket.projectId = projectId;
        
        socket.emit('joined_project', { projectId, project });
      }
    } catch (error) {
      socket.emit('error', { message: 'Access denied' });
    }
  });

  socket.on('project_update', async (data) => {
    const { projectId, updates } = data;
    
    if (socket.projectId === projectId) {
      // Broadcast to other project members
      socket.to(`project_${projectId}`).emit('project_updated', {
        projectId,
        updates,
        updatedBy: socket.userId
      });

      // Save to database
      await db.collection('studio_projects').updateOne(
        { id: projectId },
        { 
          $set: { 
            ...updates,
            updatedAt: new Date()
          }
        }
      );
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

// Get AI models
app.get('/ai/models', (req, res) => {
  const models = Array.from(aiModels.values());
  res.json({ models });
});

// Get content templates
app.get('/content/templates', (req, res) => {
  const templates = Array.from(contentTemplates.values());
  res.json({ templates });
});

// Get job status
app.get('/jobs/:jobId/status', authenticateToken, async (req, res) => {
  try {
    const { jobId } = req.params;
    
    // Check all queues for the job
    const queues = [contentGenerationQueue, mediaProcessingQueue, aiAnalysisQueue, automationQueue];
    
    for (const queue of queues) {
      const job = await queue.getJob(jobId);
      if (job) {
        const state = await job.getState();
        const progress = job.progress();
        
        return res.json({
          jobId,
          state,
          progress,
          data: job.data,
          result: job.returnvalue,
          failedReason: job.failedReason
        });
      }
    }
    
    res.status(404).json({ error: 'Job not found' });
  } catch (error) {
    logger.error('Get job status error:', error);
    res.status(500).json({ error: 'Failed to get job status' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'nexus-cos-studio-ai',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeProjects: activeProjects.size,
    queueSizes: {
      contentGeneration: contentGenerationQueue.waiting.length,
      mediaProcessing: mediaProcessingQueue.waiting.length,
      aiAnalysis: aiAnalysisQueue.waiting.length,
      automation: automationQueue.waiting.length
    }
  });
});

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  // Update queue size metrics
  queueSizeGauge.labels('content-generation').set(await contentGenerationQueue.waiting());
  queueSizeGauge.labels('media-processing').set(await mediaProcessingQueue.waiting());
  queueSizeGauge.labels('ai-analysis').set(await aiAnalysisQueue.waiting());
  queueSizeGauge.labels('automation').set(await automationQueue.waiting());

  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Error handling middleware
app.use((error, req, res, next) => {
  logger.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// Cleanup old jobs (run every hour)
cron.schedule('0 * * * *', async () => {
  try {
    const queues = [contentGenerationQueue, mediaProcessingQueue, aiAnalysisQueue, automationQueue];
    
    for (const queue of queues) {
      await queue.clean(24 * 60 * 60 * 1000, 'completed'); // Clean completed jobs older than 24 hours
      await queue.clean(7 * 24 * 60 * 60 * 1000, 'failed'); // Clean failed jobs older than 7 days
    }
    
    logger.info('Cleaned up old jobs');
  } catch (error) {
    logger.error('Job cleanup error:', error);
  }
});

// Start server
const PORT = process.env.PORT || 3049;

async function startServer() {
  await connectDatabases();
  initializeAIModels();
  initializeContentTemplates();
  
  server.listen(PORT, () => {
    logger.info(`Nexus COS Studio AI service running on port ${PORT}`);
  });
}

startServer().catch(error => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Close queues
  await contentGenerationQueue.close();
  await mediaProcessingQueue.close();
  await aiAnalysisQueue.close();
  await automationQueue.close();
  
  // Close database connections
  if (redisClient) await redisClient.quit();
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
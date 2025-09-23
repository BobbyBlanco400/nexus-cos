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
const natural = require('natural');
const compromise = require('compromise');
const pdfParse = require('pdf-parse');
const mammoth = require('mammoth');
const { Document, Packer, Paragraph, TextRun } = require('docx');
const { convert } = require('html-to-text');
const textToSpeech = require('@google-cloud/text-to-speech');
const speech = require('@google-cloud/speech');
const { OpenAI } = require('openai');
const Anthropic = require('@anthropic-ai/sdk');
const sharp = require('sharp');
const Canvas = require('canvas');
const { fabric } = require('fabric');
const puppeteer = require('puppeteer');
const WebSocket = require('ws');
const cron = require('node-cron');
const archiver = require('archiver');
const unzipper = require('unzipper');

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

// AI Services initialization
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
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

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeSessionsGauge = new promClient.Gauge({
  name: 'active_prompter_sessions',
  help: 'Number of active teleprompter sessions'
});

const scriptsProcessedCounter = new promClient.Counter({
  name: 'scripts_processed_total',
  help: 'Total number of scripts processed'
});

const aiRequestsCounter = new promClient.Counter({
  name: 'ai_requests_total',
  help: 'Total number of AI requests',
  labelNames: ['service', 'type']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(activeSessionsGauge);
register.registerMetric(scriptsProcessedCounter);
register.registerMetric(aiRequestsCounter);

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

// Teleprompter session management
const activeSessions = new Map();
const scriptTemplates = new Map();

// Initialize script templates
const initializeScriptTemplates = () => {
  const templates = [
    {
      id: 'news_broadcast',
      name: 'News Broadcast',
      category: 'news',
      structure: [
        { type: 'headline', placeholder: 'Breaking News Headline' },
        { type: 'intro', placeholder: 'Good evening, I\'m [Anchor Name]...' },
        { type: 'story', placeholder: 'Main story content...' },
        { type: 'transition', placeholder: 'In other news...' },
        { type: 'closing', placeholder: 'That\'s all for tonight...' }
      ]
    },
    {
      id: 'presentation',
      name: 'Business Presentation',
      category: 'business',
      structure: [
        { type: 'opening', placeholder: 'Good morning everyone...' },
        { type: 'agenda', placeholder: 'Today we\'ll cover...' },
        { type: 'main_points', placeholder: 'Key points...' },
        { type: 'conclusion', placeholder: 'In conclusion...' },
        { type: 'qa', placeholder: 'Questions and answers...' }
      ]
    },
    {
      id: 'interview',
      name: 'Interview Script',
      category: 'interview',
      structure: [
        { type: 'introduction', placeholder: 'Welcome to the show...' },
        { type: 'guest_intro', placeholder: 'Today we have...' },
        { type: 'questions', placeholder: 'Interview questions...' },
        { type: 'wrap_up', placeholder: 'Thank you for joining us...' }
      ]
    }
  ];

  templates.forEach(template => {
    scriptTemplates.set(template.id, template);
  });
};

// Script Management Routes
app.post('/scripts', authenticateToken, [
  body('title').isLength({ min: 1, max: 200 }),
  body('content').isLength({ min: 1 }),
  body('category').optional().isString(),
  body('tags').optional().isArray()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      title, 
      content, 
      category = 'general',
      tags = [],
      settings = {},
      templateId = null
    } = req.body;
    
    const userId = req.user.id;
    const scriptId = uuidv4();

    // Analyze script content
    const analysis = await analyzeScript(content);

    const script = {
      id: scriptId,
      userId,
      title,
      content,
      category,
      tags,
      templateId,
      settings: {
        fontSize: 24,
        fontFamily: 'Arial',
        lineHeight: 1.5,
        scrollSpeed: 50,
        backgroundColor: '#000000',
        textColor: '#ffffff',
        mirrorMode: false,
        ...settings
      },
      analysis,
      createdAt: new Date(),
      updatedAt: new Date(),
      version: 1
    };

    // Save to database
    await db.collection('scripts').insertOne(script);
    scriptsProcessedCounter.inc();

    res.json({
      success: true,
      script
    });

  } catch (error) {
    logger.error('Create script error:', error);
    res.status(500).json({ error: 'Failed to create script' });
  }
});

app.get('/scripts', authenticateToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const { category, search, limit = 50, offset = 0 } = req.query;

    let query = { userId };
    
    if (category) {
      query.category = category;
    }

    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { content: { $regex: search, $options: 'i' } },
        { tags: { $in: [new RegExp(search, 'i')] } }
      ];
    }

    const scripts = await db.collection('scripts')
      .find(query)
      .sort({ updatedAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .toArray();

    const total = await db.collection('scripts').countDocuments(query);

    res.json({ scripts, total });
  } catch (error) {
    logger.error('Get scripts error:', error);
    res.status(500).json({ error: 'Failed to fetch scripts' });
  }
});

app.get('/scripts/:scriptId', authenticateToken, async (req, res) => {
  try {
    const { scriptId } = req.params;
    const userId = req.user.id;

    const script = await db.collection('scripts').findOne({ 
      id: scriptId, 
      userId 
    });

    if (!script) {
      return res.status(404).json({ error: 'Script not found' });
    }

    res.json({ script });
  } catch (error) {
    logger.error('Get script error:', error);
    res.status(500).json({ error: 'Failed to fetch script' });
  }
});

app.put('/scripts/:scriptId', authenticateToken, [
  body('title').optional().isLength({ min: 1, max: 200 }),
  body('content').optional().isLength({ min: 1 }),
  body('category').optional().isString(),
  body('tags').optional().isArray()
], async (req, res) => {
  try {
    const { scriptId } = req.params;
    const userId = req.user.id;
    const updates = req.body;

    // Re-analyze content if changed
    if (updates.content) {
      updates.analysis = await analyzeScript(updates.content);
    }

    updates.updatedAt = new Date();
    updates.version = { $inc: { version: 1 } };

    const result = await db.collection('scripts').updateOne(
      { id: scriptId, userId },
      { $set: updates, $inc: { version: 1 } }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Script not found' });
    }

    const updatedScript = await db.collection('scripts').findOne({ 
      id: scriptId, 
      userId 
    });

    res.json({ success: true, script: updatedScript });
  } catch (error) {
    logger.error('Update script error:', error);
    res.status(500).json({ error: 'Failed to update script' });
  }
});

// Teleprompter Session Routes
app.post('/sessions', authenticateToken, [
  body('scriptId').isUUID(),
  body('settings').optional().isObject()
], async (req, res) => {
  try {
    const { scriptId, settings = {} } = req.body;
    const userId = req.user.id;
    const sessionId = uuidv4();

    // Get script
    const script = await db.collection('scripts').findOne({ 
      id: scriptId, 
      userId 
    });

    if (!script) {
      return res.status(404).json({ error: 'Script not found' });
    }

    const session = {
      id: sessionId,
      userId,
      scriptId,
      script,
      settings: {
        ...script.settings,
        ...settings
      },
      status: 'created',
      currentPosition: 0,
      startedAt: null,
      endedAt: null,
      duration: 0,
      createdAt: new Date()
    };

    // Save to database
    await db.collection('prompter_sessions').insertOne(session);
    activeSessions.set(sessionId, session);
    activeSessionsGauge.set(activeSessions.size);

    res.json({
      success: true,
      sessionId,
      session
    });

  } catch (error) {
    logger.error('Create session error:', error);
    res.status(500).json({ error: 'Failed to create session' });
  }
});

app.post('/sessions/:sessionId/start', authenticateToken, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = activeSessions.get(sessionId);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    if (session.userId !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    session.status = 'active';
    session.startedAt = new Date();

    await db.collection('prompter_sessions').updateOne(
      { id: sessionId },
      { 
        $set: { 
          status: 'active',
          startedAt: new Date()
        }
      }
    );

    // Notify connected clients
    io.to(`session_${sessionId}`).emit('session_started', { sessionId });

    res.json({ success: true, message: 'Session started' });

  } catch (error) {
    logger.error('Start session error:', error);
    res.status(500).json({ error: 'Failed to start session' });
  }
});

app.post('/sessions/:sessionId/pause', authenticateToken, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = activeSessions.get(sessionId);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    session.status = 'paused';

    await db.collection('prompter_sessions').updateOne(
      { id: sessionId },
      { $set: { status: 'paused' } }
    );

    io.to(`session_${sessionId}`).emit('session_paused', { sessionId });

    res.json({ success: true, message: 'Session paused' });

  } catch (error) {
    logger.error('Pause session error:', error);
    res.status(500).json({ error: 'Failed to pause session' });
  }
});

app.post('/sessions/:sessionId/stop', authenticateToken, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const session = activeSessions.get(sessionId);

    if (!session) {
      return res.status(404).json({ error: 'Session not found' });
    }

    session.status = 'completed';
    session.endedAt = new Date();
    session.duration = Date.now() - session.startedAt.getTime();

    await db.collection('prompter_sessions').updateOne(
      { id: sessionId },
      { 
        $set: { 
          status: 'completed',
          endedAt: new Date(),
          duration: session.duration
        }
      }
    );

    activeSessions.delete(sessionId);
    activeSessionsGauge.set(activeSessions.size);

    io.to(`session_${sessionId}`).emit('session_ended', { sessionId });

    res.json({ success: true, message: 'Session stopped' });

  } catch (error) {
    logger.error('Stop session error:', error);
    res.status(500).json({ error: 'Failed to stop session' });
  }
});

// AI-Powered Script Enhancement
app.post('/scripts/:scriptId/enhance', authenticateToken, [
  body('enhancementType').isIn(['grammar', 'clarity', 'tone', 'structure', 'length']),
  body('targetAudience').optional().isString(),
  body('tone').optional().isString()
], async (req, res) => {
  try {
    const { scriptId } = req.params;
    const { enhancementType, targetAudience, tone } = req.body;
    const userId = req.user.id;

    const script = await db.collection('scripts').findOne({ 
      id: scriptId, 
      userId 
    });

    if (!script) {
      return res.status(404).json({ error: 'Script not found' });
    }

    let enhancedContent;
    
    if (process.env.OPENAI_API_KEY) {
      enhancedContent = await enhanceWithOpenAI(script.content, enhancementType, targetAudience, tone);
      aiRequestsCounter.labels('openai', enhancementType).inc();
    } else if (process.env.ANTHROPIC_API_KEY) {
      enhancedContent = await enhanceWithAnthropic(script.content, enhancementType, targetAudience, tone);
      aiRequestsCounter.labels('anthropic', enhancementType).inc();
    } else {
      return res.status(500).json({ error: 'No AI service configured' });
    }

    // Save enhanced version
    const enhancedScript = {
      ...script,
      id: uuidv4(),
      title: `${script.title} (Enhanced - ${enhancementType})`,
      content: enhancedContent,
      parentScriptId: scriptId,
      enhancementType,
      createdAt: new Date(),
      version: 1
    };

    await db.collection('scripts').insertOne(enhancedScript);

    res.json({
      success: true,
      enhancedScript,
      originalContent: script.content,
      enhancedContent
    });

  } catch (error) {
    logger.error('Enhance script error:', error);
    res.status(500).json({ error: 'Failed to enhance script' });
  }
});

// Text-to-Speech Generation
app.post('/scripts/:scriptId/tts', authenticateToken, [
  body('voice').optional().isString(),
  body('speed').optional().isFloat({ min: 0.25, max: 4.0 }),
  body('pitch').optional().isFloat({ min: -20.0, max: 20.0 })
], async (req, res) => {
  try {
    const { scriptId } = req.params;
    const { voice = 'en-US-Standard-A', speed = 1.0, pitch = 0.0 } = req.body;
    const userId = req.user.id;

    const script = await db.collection('scripts').findOne({ 
      id: scriptId, 
      userId 
    });

    if (!script) {
      return res.status(404).json({ error: 'Script not found' });
    }

    // Generate TTS audio
    const request = {
      input: { text: script.content },
      voice: { 
        languageCode: voice.split('-').slice(0, 2).join('-'),
        name: voice 
      },
      audioConfig: {
        audioEncoding: 'MP3',
        speakingRate: speed,
        pitch: pitch
      }
    };

    const [response] = await ttsClient.synthesizeSpeech(request);
    
    // Upload to S3
    const fileName = `tts/${scriptId}/${Date.now()}.mp3`;
    const uploadParams = {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: fileName,
      Body: response.audioContent,
      ContentType: 'audio/mpeg'
    };

    const uploadResult = await s3.upload(uploadParams).promise();

    // Save TTS record
    const ttsRecord = {
      id: uuidv4(),
      scriptId,
      userId,
      audioUrl: uploadResult.Location,
      voice,
      speed,
      pitch,
      duration: null, // Could be calculated
      createdAt: new Date()
    };

    await db.collection('tts_audio').insertOne(ttsRecord);

    res.json({
      success: true,
      audioUrl: uploadResult.Location,
      ttsRecord
    });

  } catch (error) {
    logger.error('TTS generation error:', error);
    res.status(500).json({ error: 'Failed to generate TTS audio' });
  }
});

// File Import Routes
app.post('/scripts/import', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }

    const { originalname, buffer, mimetype } = req.file;
    const { title, category = 'imported' } = req.body;
    
    let content = '';

    // Parse different file types
    if (mimetype === 'application/pdf') {
      const pdfData = await pdfParse(buffer);
      content = pdfData.text;
    } else if (mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
      const docxData = await mammoth.extractRawText({ buffer });
      content = docxData.value;
    } else if (mimetype === 'text/plain') {
      content = buffer.toString('utf-8');
    } else if (mimetype === 'text/html') {
      content = convert(buffer.toString('utf-8'));
    } else {
      return res.status(400).json({ error: 'Unsupported file type' });
    }

    if (!content.trim()) {
      return res.status(400).json({ error: 'No text content found in file' });
    }

    // Create script from imported content
    const scriptId = uuidv4();
    const userId = req.user.id;
    const analysis = await analyzeScript(content);

    const script = {
      id: scriptId,
      userId,
      title: title || originalname.replace(/\.[^/.]+$/, ''),
      content,
      category,
      tags: ['imported'],
      settings: {
        fontSize: 24,
        fontFamily: 'Arial',
        lineHeight: 1.5,
        scrollSpeed: 50,
        backgroundColor: '#000000',
        textColor: '#ffffff',
        mirrorMode: false
      },
      analysis,
      importedFrom: originalname,
      createdAt: new Date(),
      updatedAt: new Date(),
      version: 1
    };

    await db.collection('scripts').insertOne(script);
    scriptsProcessedCounter.inc();

    res.json({
      success: true,
      script
    });

  } catch (error) {
    logger.error('Import script error:', error);
    res.status(500).json({ error: 'Failed to import script' });
  }
});

// Script analysis function
async function analyzeScript(content) {
  try {
    const doc = compromise(content);
    
    return {
      wordCount: content.split(/\s+/).length,
      characterCount: content.length,
      sentenceCount: doc.sentences().length,
      paragraphCount: content.split(/\n\s*\n/).length,
      estimatedReadingTime: Math.ceil(content.split(/\s+/).length / 200), // 200 WPM
      estimatedSpeakingTime: Math.ceil(content.split(/\s+/).length / 150), // 150 WPM
      complexity: calculateComplexity(content),
      keywords: extractKeywords(content),
      sentiment: analyzeSentiment(content)
    };
  } catch (error) {
    logger.error('Script analysis error:', error);
    return {
      wordCount: content.split(/\s+/).length,
      characterCount: content.length,
      estimatedReadingTime: Math.ceil(content.split(/\s+/).length / 200),
      estimatedSpeakingTime: Math.ceil(content.split(/\s+/).length / 150)
    };
  }
}

function calculateComplexity(text) {
  const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0);
  const words = text.split(/\s+/);
  const avgWordsPerSentence = words.length / sentences.length;
  
  // Simple complexity score based on sentence length
  if (avgWordsPerSentence < 15) return 'easy';
  if (avgWordsPerSentence < 25) return 'medium';
  return 'complex';
}

function extractKeywords(text) {
  const tokenizer = new natural.WordTokenizer();
  const tokens = tokenizer.tokenize(text.toLowerCase());
  const stopwords = natural.stopwords;
  
  const filteredTokens = tokens.filter(token => 
    token.length > 3 && !stopwords.includes(token)
  );
  
  const frequency = {};
  filteredTokens.forEach(token => {
    frequency[token] = (frequency[token] || 0) + 1;
  });
  
  return Object.entries(frequency)
    .sort(([,a], [,b]) => b - a)
    .slice(0, 10)
    .map(([word]) => word);
}

function analyzeSentiment(text) {
  const analyzer = new natural.SentimentAnalyzer('English', 
    natural.PorterStemmer, ['negation']);
  const tokenizer = new natural.WordTokenizer();
  const tokens = tokenizer.tokenize(text);
  const score = analyzer.getSentiment(tokens);
  
  if (score > 0.1) return 'positive';
  if (score < -0.1) return 'negative';
  return 'neutral';
}

// AI enhancement functions
async function enhanceWithOpenAI(content, enhancementType, targetAudience, tone) {
  const prompts = {
    grammar: `Please correct any grammar, spelling, and punctuation errors in the following text while maintaining its original meaning and style:`,
    clarity: `Please rewrite the following text to make it clearer and more concise while preserving all important information:`,
    tone: `Please adjust the tone of the following text to be more ${tone || 'professional'} while keeping the same content:`,
    structure: `Please improve the structure and flow of the following text, organizing it in a more logical and engaging way:`,
    length: `Please expand the following text with additional relevant details and examples while maintaining the same core message:`
  };

  const prompt = `${prompts[enhancementType]}${targetAudience ? ` The target audience is: ${targetAudience}.` : ''}\n\nText:\n${content}`;

  const response = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: [
      {
        role: 'system',
        content: 'You are a professional script editor and writing assistant. Provide high-quality improvements to scripts and presentations.'
      },
      {
        role: 'user',
        content: prompt
      }
    ],
    max_tokens: 2000,
    temperature: 0.7
  });

  return response.choices[0].message.content;
}

async function enhanceWithAnthropic(content, enhancementType, targetAudience, tone) {
  const prompts = {
    grammar: `Please correct any grammar, spelling, and punctuation errors in the following text while maintaining its original meaning and style:`,
    clarity: `Please rewrite the following text to make it clearer and more concise while preserving all important information:`,
    tone: `Please adjust the tone of the following text to be more ${tone || 'professional'} while keeping the same content:`,
    structure: `Please improve the structure and flow of the following text, organizing it in a more logical and engaging way:`,
    length: `Please expand the following text with additional relevant details and examples while maintaining the same core message:`
  };

  const prompt = `${prompts[enhancementType]}${targetAudience ? ` The target audience is: ${targetAudience}.` : ''}\n\nText:\n${content}`;

  const response = await anthropic.messages.create({
    model: 'claude-3-sonnet-20240229',
    max_tokens: 2000,
    messages: [
      {
        role: 'user',
        content: prompt
      }
    ]
  });

  return response.content[0].text;
}

// Socket.IO for real-time teleprompter control
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_session', async (data) => {
    const { sessionId, token } = data;
    
    try {
      if (token) {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        socket.userId = decoded.id;
      }

      const session = activeSessions.get(sessionId);
      if (session && session.userId === socket.userId) {
        socket.join(`session_${sessionId}`);
        socket.sessionId = sessionId;

        socket.emit('session_joined', { 
          sessionId,
          session
        });
      }
    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('update_position', (data) => {
    const { sessionId, position } = data;
    const session = activeSessions.get(sessionId);
    
    if (session && session.userId === socket.userId) {
      session.currentPosition = position;
      
      // Broadcast to other connected clients
      socket.to(`session_${sessionId}`).emit('position_updated', { 
        position 
      });
    }
  });

  socket.on('update_settings', (data) => {
    const { sessionId, settings } = data;
    const session = activeSessions.get(sessionId);
    
    if (session && session.userId === socket.userId) {
      session.settings = { ...session.settings, ...settings };
      
      // Broadcast to other connected clients
      socket.to(`session_${sessionId}`).emit('settings_updated', { 
        settings: session.settings 
      });
    }
  });

  socket.on('remote_control', (data) => {
    const { sessionId, action, value } = data;
    const session = activeSessions.get(sessionId);
    
    if (session) {
      // Broadcast remote control commands
      io.to(`session_${sessionId}`).emit('remote_command', { 
        action, 
        value 
      });
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
  });
});

// Get script templates
app.get('/templates', (req, res) => {
  const templates = Array.from(scriptTemplates.values());
  res.json({ templates });
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'v-prompter-pro',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeSessions: activeSessions.size
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

// Cleanup old sessions (run every hour)
cron.schedule('0 * * * *', async () => {
  try {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000); // 24 hours ago
    
    // Remove old inactive sessions
    for (const [sessionId, session] of activeSessions.entries()) {
      if (session.createdAt < cutoff && session.status !== 'active') {
        activeSessions.delete(sessionId);
      }
    }
    
    activeSessionsGauge.set(activeSessions.size);
    logger.info('Cleaned up old sessions');
  } catch (error) {
    logger.error('Session cleanup error:', error);
  }
});

// Start server
const PORT = process.env.PORT || 3048;

async function startServer() {
  await connectDatabases();
  initializeScriptTemplates();
  
  server.listen(PORT, () => {
    logger.info(`V-Prompter Pro service running on port ${PORT}`);
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
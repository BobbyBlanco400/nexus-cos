const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const multer = require('multer');
const sharp = require('sharp');
const OpenAI = require('openai');
const Anthropic = require('@anthropic-ai/sdk');
const { GoogleAuth } = require('google-auth-library');
const { google } = require('googleapis');
const { Pool } = require('pg');
const redis = require('redis');
const winston = require('winston');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const pdfParse = require('pdf-parse');
const mammoth = require('mammoth');
require('dotenv').config();

// Logger setup
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/kei-ai-error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/kei-ai-combined.log' }),
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

// AI Service configurations
const openai = new OpenAI({
  apiKey: process.env.KEI_AI_KEY,
  baseURL: process.env.KEI_AI_ENDPOINT
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

// Google AI setup
const googleAuth = new GoogleAuth({
  keyFile: process.env.GOOGLE_SERVICE_ACCOUNT_KEY,
  scopes: ['https://www.googleapis.com/auth/cloud-platform']
});

const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3044;

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Rate limiting for AI endpoints
const aiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50, // More restrictive for AI calls
  message: 'Too many AI requests from this IP'
});

const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: 'Too many requests from this IP'
});

app.use('/ai', aiLimiter);
app.use(generalLimiter);

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Multer configuration for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'text/plain', 'application/pdf', 
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'image/jpeg', 'image/png', 'image/gif', 'image/webp'
    ];
    
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type for AI processing'), false);
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

// Kei-AI Chat Completion
app.post('/ai/chat', authenticateToken, async (req, res) => {
  try {
    const { message, model = 'gpt-4', context = [], systemPrompt } = req.body;
    
    if (!message) {
      return res.status(400).json({ message: 'Message is required' });
    }

    // Check user's AI usage limits
    const usageKey = `ai_usage:${req.user.id}:${new Date().toDateString()}`;
    const currentUsage = await redisClient.get(usageKey) || 0;
    
    if (parseInt(currentUsage) >= 100) { // Daily limit
      return res.status(429).json({ message: 'Daily AI usage limit exceeded' });
    }

    let response;
    const conversationId = uuidv4();

    // Prepare messages
    const messages = [
      {
        role: 'system',
        content: systemPrompt || 'You are Kei-AI, an advanced AI assistant integrated into Nexus COS. You help users with content creation, streaming optimization, and platform management.'
      },
      ...context,
      { role: 'user', content: message }
    ];

    // Route to appropriate AI service based on model
    if (model.startsWith('gpt')) {
      response = await openai.chat.completions.create({
        model: model,
        messages: messages,
        max_tokens: 2000,
        temperature: 0.7
      });
    } else if (model.startsWith('claude')) {
      response = await anthropic.messages.create({
        model: model,
        max_tokens: 2000,
        messages: messages.slice(1), // Anthropic handles system message differently
        system: messages[0].content
      });
    }

    const aiResponse = model.startsWith('gpt') 
      ? response.choices[0].message.content
      : response.content[0].text;

    // Save conversation to database
    await pool.query(
      `INSERT INTO ai_conversations (id, user_id, model, user_message, ai_response, context)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [conversationId, req.user.id, model, message, aiResponse, JSON.stringify(context)]
    );

    // Update usage counter
    await redisClient.incr(usageKey);
    await redisClient.expire(usageKey, 86400); // 24 hours

    logger.info(`AI chat completed for user ${req.user.id} using ${model}`);
    res.json({ 
      response: aiResponse, 
      conversationId,
      usage: parseInt(currentUsage) + 1
    });
  } catch (error) {
    logger.error('AI chat error:', error);
    res.status(500).json({ message: 'AI service temporarily unavailable' });
  }
});

// Content Analysis
app.post('/ai/analyze-content', authenticateToken, upload.single('file'), async (req, res) => {
  try {
    const { text, analysisType = 'general' } = req.body;
    let contentToAnalyze = text;

    // Extract text from uploaded file if provided
    if (req.file) {
      const { mimetype, buffer } = req.file;
      
      if (mimetype === 'application/pdf') {
        const pdfData = await pdfParse(buffer);
        contentToAnalyze = pdfData.text;
      } else if (mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
        const docData = await mammoth.extractRawText({ buffer });
        contentToAnalyze = docData.value;
      } else if (mimetype.startsWith('image/')) {
        // For images, use OpenAI Vision API
        const base64Image = buffer.toString('base64');
        const response = await openai.chat.completions.create({
          model: "gpt-4-vision-preview",
          messages: [
            {
              role: "user",
              content: [
                { type: "text", text: `Analyze this image for ${analysisType} content analysis.` },
                { type: "image_url", image_url: { url: `data:${mimetype};base64,${base64Image}` } }
              ]
            }
          ],
          max_tokens: 1000
        });
        
        return res.json({ analysis: response.choices[0].message.content });
      }
    }

    if (!contentToAnalyze) {
      return res.status(400).json({ message: 'No content provided for analysis' });
    }

    // Perform analysis based on type
    let prompt;
    switch (analysisType) {
      case 'sentiment':
        prompt = 'Analyze the sentiment of this content. Provide a detailed sentiment analysis including overall tone, emotional indicators, and confidence score.';
        break;
      case 'seo':
        prompt = 'Analyze this content for SEO optimization. Provide keyword suggestions, content structure recommendations, and SEO score.';
        break;
      case 'engagement':
        prompt = 'Analyze this content for audience engagement potential. Suggest improvements for better engagement and virality.';
        break;
      case 'compliance':
        prompt = 'Analyze this content for platform compliance and content policy adherence. Flag any potential issues.';
        break;
      default:
        prompt = 'Provide a comprehensive analysis of this content including key themes, quality assessment, and improvement suggestions.';
    }

    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { role: 'system', content: 'You are Kei-AI, an expert content analyst for Nexus COS platform.' },
        { role: 'user', content: `${prompt}\n\nContent: ${contentToAnalyze}` }
      ],
      max_tokens: 1500,
      temperature: 0.3
    });

    const analysis = response.choices[0].message.content;

    // Save analysis to database
    await pool.query(
      `INSERT INTO content_analyses (user_id, analysis_type, content_preview, analysis_result)
       VALUES ($1, $2, $3, $4)`,
      [req.user.id, analysisType, contentToAnalyze.substring(0, 500), analysis]
    );

    logger.info(`Content analysis completed for user ${req.user.id}`);
    res.json({ analysis, analysisType });
  } catch (error) {
    logger.error('Content analysis error:', error);
    res.status(500).json({ message: 'Content analysis failed' });
  }
});

// AI-Powered Content Generation
app.post('/ai/generate-content', authenticateToken, async (req, res) => {
  try {
    const { 
      contentType, 
      topic, 
      tone = 'professional', 
      length = 'medium',
      targetAudience,
      keywords = []
    } = req.body;

    if (!contentType || !topic) {
      return res.status(400).json({ message: 'Content type and topic are required' });
    }

    let prompt = `Generate ${contentType} content about "${topic}" with a ${tone} tone for ${targetAudience || 'general audience'}.`;
    
    if (keywords.length > 0) {
      prompt += ` Include these keywords naturally: ${keywords.join(', ')}.`;
    }

    switch (length) {
      case 'short':
        prompt += ' Keep it concise (100-200 words).';
        break;
      case 'long':
        prompt += ' Make it comprehensive (800-1200 words).';
        break;
      default:
        prompt += ' Make it medium length (400-600 words).';
    }

    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'You are Kei-AI, a creative content generator for Nexus COS. Create engaging, original content that resonates with the target audience.' 
        },
        { role: 'user', content: prompt }
      ],
      max_tokens: length === 'long' ? 2000 : length === 'short' ? 500 : 1000,
      temperature: 0.8
    });

    const generatedContent = response.choices[0].message.content;

    // Save generated content
    await pool.query(
      `INSERT INTO generated_content (user_id, content_type, topic, generated_text, parameters)
       VALUES ($1, $2, $3, $4, $5)`,
      [req.user.id, contentType, topic, generatedContent, JSON.stringify({ tone, length, targetAudience, keywords })]
    );

    logger.info(`Content generated for user ${req.user.id}: ${contentType} about ${topic}`);
    res.json({ content: generatedContent, contentType, topic });
  } catch (error) {
    logger.error('Content generation error:', error);
    res.status(500).json({ message: 'Content generation failed' });
  }
});

// Stream Optimization Suggestions
app.post('/ai/optimize-stream', authenticateToken, async (req, res) => {
  try {
    const { streamData, metrics, goals } = req.body;

    if (!streamData) {
      return res.status(400).json({ message: 'Stream data is required' });
    }

    const prompt = `Analyze this streaming data and provide optimization suggestions:
    
Stream Info: ${JSON.stringify(streamData)}
Current Metrics: ${JSON.stringify(metrics || {})}
Goals: ${goals || 'Increase engagement and viewership'}

Provide specific, actionable recommendations for:
1. Content optimization
2. Streaming schedule
3. Audience engagement
4. Technical improvements
5. Growth strategies`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'You are Kei-AI, a streaming optimization expert for Nexus COS. Provide data-driven recommendations to improve streaming performance.' 
        },
        { role: 'user', content: prompt }
      ],
      max_tokens: 1500,
      temperature: 0.4
    });

    const suggestions = response.choices[0].message.content;

    // Save optimization suggestions
    await pool.query(
      `INSERT INTO stream_optimizations (user_id, stream_data, suggestions)
       VALUES ($1, $2, $3)`,
      [req.user.id, JSON.stringify(streamData), suggestions]
    );

    logger.info(`Stream optimization completed for user ${req.user.id}`);
    res.json({ suggestions });
  } catch (error) {
    logger.error('Stream optimization error:', error);
    res.status(500).json({ message: 'Stream optimization failed' });
  }
});

// Get AI conversation history
app.get('/ai/conversations', authenticateToken, async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const result = await pool.query(
      `SELECT id, model, user_message, ai_response, created_at 
       FROM ai_conversations 
       WHERE user_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2 OFFSET $3`,
      [req.user.id, limit, offset]
    );

    res.json({ conversations: result.rows });
  } catch (error) {
    logger.error('Get conversations error:', error);
    res.status(500).json({ message: 'Failed to fetch conversations' });
  }
});

// Get AI usage statistics
app.get('/ai/usage', authenticateToken, async (req, res) => {
  try {
    const today = new Date().toDateString();
    const usageKey = `ai_usage:${req.user.id}:${today}`;
    const dailyUsage = await redisClient.get(usageKey) || 0;

    // Get monthly usage from database
    const monthStart = new Date();
    monthStart.setDate(1);
    monthStart.setHours(0, 0, 0, 0);

    const monthlyResult = await pool.query(
      `SELECT COUNT(*) as monthly_usage FROM ai_conversations 
       WHERE user_id = $1 AND created_at >= $2`,
      [req.user.id, monthStart]
    );

    res.json({
      dailyUsage: parseInt(dailyUsage),
      dailyLimit: 100,
      monthlyUsage: parseInt(monthlyResult.rows[0].monthly_usage),
      remainingDaily: Math.max(0, 100 - parseInt(dailyUsage))
    });
  } catch (error) {
    logger.error('Get usage error:', error);
    res.status(500).json({ message: 'Failed to fetch usage statistics' });
  }
});

// Socket.io for real-time AI assistance
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

io.on('connection', (socket) => {
  logger.info(`AI client connected: ${socket.user.id}`);

  socket.on('ai_chat_stream', async (data) => {
    try {
      const { message, context = [] } = data;
      
      // Stream response using OpenAI streaming
      const stream = await openai.chat.completions.create({
        model: 'gpt-4',
        messages: [
          { role: 'system', content: 'You are Kei-AI, providing real-time assistance in Nexus COS.' },
          ...context,
          { role: 'user', content: message }
        ],
        stream: true,
        max_tokens: 1000
      });

      for await (const chunk of stream) {
        const content = chunk.choices[0]?.delta?.content || '';
        if (content) {
          socket.emit('ai_response_chunk', { content });
        }
      }

      socket.emit('ai_response_complete');
    } catch (error) {
      logger.error('AI stream error:', error);
      socket.emit('ai_error', { message: 'AI service temporarily unavailable' });
    }
  });

  socket.on('disconnect', () => {
    logger.info(`AI client disconnected: ${socket.user.id}`);
  });
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'kei-ai', 
    timestamp: new Date().toISOString() 
  });
});

// Error handling
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

server.listen(PORT, () => {
  logger.info(`Kei-AI Service running on port ${PORT}`);
});

module.exports = app;
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
const fetch = require('node-fetch');
const axios = require('axios');
const WebSocket = require('ws');
const SimplePeer = require('simple-peer');
const mediasoup = require('mediasoup');
const NodeMediaServer = require('node-media-server');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegStatic = require('ffmpeg-static');
const sharp = require('sharp');
const Canvas = require('canvas');
const { fabric } = require('fabric');
const THREE = require('three');
const BABYLON = require('babylonjs');
const Tone = require('tone');
const Stripe = require('stripe');
const PayPal = require('paypal-rest-sdk');
const { Client: SquareClient, Environment } = require('square');
const Pusher = require('pusher');
const Ably = require('ably');
const PubNub = require('pubnub');
const Bull = require('bull');
const cron = require('node-cron');
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');
const { chromium } = require('playwright');
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
const Chart = require('chart.js');
const QRCode = require('qrcode');
const emoji = require('node-emoji');
const Sentiment = require('sentiment');
const natural = require('natural');
const compromise = require('compromise');
const franc = require('franc');
const translate = require('translate');
const { OpenAI } = require('openai');
const Anthropic = require('@anthropic-ai/sdk');
const { CohereClient } = require('cohere-ai');
const Replicate = require('replicate');
const StabilityAI = require('stability-ai');
const { ElevenLabsAPI } = require('elevenlabs');
const textToSpeech = require('@google-cloud/text-to-speech');
const speech = require('@google-cloud/speech');
const SpotifyWebApi = require('spotify-web-api-node');
const youtubedl = require('youtube-dl-exec');
const ytdl = require('ytdl-core');
const scdl = require('soundcloud-downloader').default;
const { Client: DiscordClient, GatewayIntentBits } = require('discord.js');
const { App: SlackApp } = require('@slack/bolt');
const TelegramBot = require('node-telegram-bot-api');

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

// Payment processors
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

PayPal.configure({
  mode: process.env.PAYPAL_MODE || 'sandbox',
  client_id: process.env.PAYPAL_CLIENT_ID,
  client_secret: process.env.PAYPAL_CLIENT_SECRET
});

const squareClient = new SquareClient({
  accessToken: process.env.SQUARE_ACCESS_TOKEN,
  environment: process.env.SQUARE_ENVIRONMENT === 'production' ? Environment.Production : Environment.Sandbox
});

// Real-time messaging services
const pusher = new Pusher({
  appId: process.env.PUSHER_APP_ID,
  key: process.env.PUSHER_KEY,
  secret: process.env.PUSHER_SECRET,
  cluster: process.env.PUSHER_CLUSTER,
  useTLS: true
});

const ably = new Ably.Realtime(process.env.ABLY_API_KEY);

const pubnub = new PubNub({
  publishKey: process.env.PUBNUB_PUBLISH_KEY,
  subscribeKey: process.env.PUBNUB_SUBSCRIBE_KEY,
  userId: 'boom-boom-room-server'
});

// AI Services
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY
});

// Music services
const spotifyApi = new SpotifyWebApi({
  clientId: process.env.SPOTIFY_CLIENT_ID,
  clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
  redirectUri: process.env.SPOTIFY_REDIRECT_URI
});

// Social media bots
const discordBot = new DiscordClient({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent,
    GatewayIntentBits.GuildVoiceStates
  ]
});

const slackApp = new SlackApp({
  token: process.env.SLACK_BOT_TOKEN,
  signingSecret: process.env.SLACK_SIGNING_SECRET
});

const telegramBot = new TelegramBot(process.env.TELEGRAM_BOT_TOKEN, { polling: true });

// AWS S3 configuration
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1'
});

// Redis for job queues and caching
const redisConfig = {
  host: process.env.REDIS_HOST || 'redis',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD
};

// Job queues
const showProcessingQueue = new Bull('show processing', redisConfig);
const audienceEngagementQueue = new Bull('audience engagement', redisConfig);
const contentModerationQueue = new Bull('content moderation', redisConfig);
const analyticsQueue = new Bull('analytics', redisConfig);
const notificationQueue = new Bull('notifications', redisConfig);

// Prometheus metrics
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDuration = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});

const activeShowsGauge = new promClient.Gauge({
  name: 'active_shows',
  help: 'Number of active live shows'
});

const connectedAudienceGauge = new promClient.Gauge({
  name: 'connected_audience',
  help: 'Number of connected audience members'
});

const engagementEventsCounter = new promClient.Counter({
  name: 'engagement_events_total',
  help: 'Total number of audience engagement events',
  labelNames: ['type', 'show_id']
});

const revenueGauge = new promClient.Gauge({
  name: 'revenue_total',
  help: 'Total revenue generated',
  labelNames: ['currency', 'type']
});

const streamQualityGauge = new promClient.Gauge({
  name: 'stream_quality',
  help: 'Stream quality metrics',
  labelNames: ['show_id', 'metric']
});

register.registerMetric(httpRequestDuration);
register.registerMetric(activeShowsGauge);
register.registerMetric(connectedAudienceGauge);
register.registerMetric(engagementEventsCounter);
register.registerMetric(revenueGauge);
register.registerMetric(streamQualityGauge);

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
  max: 300 // limit each IP to 300 requests per windowMs
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
    fileSize: 1000 * 1024 * 1024 // 1GB
  }
});

// Live show management
const activeShows = new Map();
const audienceConnections = new Map();
const showRooms = new Map();

// MediaSoup workers for WebRTC
let mediasoupWorkers = [];
const createMediasoupWorkers = async () => {
  const numWorkers = require('os').cpus().length;
  
  for (let i = 0; i < numWorkers; i++) {
    const worker = await mediasoup.createWorker({
      logLevel: 'warn',
      rtcMinPort: 10000 + (i * 1000),
      rtcMaxPort: 10000 + (i * 1000) + 999
    });
    
    worker.on('died', () => {
      logger.error(`MediaSoup worker ${worker.pid} died`);
    });
    
    mediasoupWorkers.push(worker);
  }
  
  logger.info(`Created ${numWorkers} MediaSoup workers`);
};

// Node Media Server for RTMP streaming
const nms = new NodeMediaServer({
  rtmp: {
    port: 1935,
    chunk_size: 60000,
    gop_cache: true,
    ping: 30,
    ping_timeout: 60
  },
  http: {
    port: 8000,
    allow_origin: '*'
  },
  relay: {
    ffmpeg: ffmpegStatic,
    tasks: []
  }
});

// Live Show Routes
app.post('/shows', authenticateToken, [
  body('title').isLength({ min: 1, max: 200 }),
  body('description').optional().isLength({ max: 1000 }),
  body('category').isIn(['music', 'comedy', 'talk', 'gaming', 'education', 'entertainment', 'other']),
  body('scheduledAt').optional().isISO8601()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { 
      title, 
      description = '',
      category,
      scheduledAt,
      isPrivate = false,
      maxAudience = 1000,
      monetization = {},
      settings = {}
    } = req.body;

    const userId = req.user.id;
    const showId = uuidv4();

    const show = {
      id: showId,
      title,
      description,
      category,
      hostId: userId,
      scheduledAt: scheduledAt ? new Date(scheduledAt) : new Date(),
      isPrivate,
      maxAudience,
      monetization: {
        enabled: false,
        ticketPrice: 0,
        currency: 'USD',
        subscriptionRequired: false,
        donationsEnabled: true,
        ...monetization
      },
      settings: {
        chatEnabled: true,
        reactionsEnabled: true,
        pollsEnabled: true,
        gamesEnabled: true,
        moderationEnabled: true,
        recordingEnabled: false,
        ...settings
      },
      status: 'scheduled',
      audience: [],
      moderators: [],
      analytics: {
        views: 0,
        uniqueViewers: 0,
        peakAudience: 0,
        totalEngagement: 0,
        revenue: 0
      },
      createdAt: new Date(),
      updatedAt: new Date()
    };

    // Save to database
    await db.collection('live_shows').insertOne(show);
    
    res.json({
      success: true,
      show
    });

  } catch (error) {
    logger.error('Create show error:', error);
    res.status(500).json({ error: 'Failed to create show' });
  }
});

app.get('/shows', async (req, res) => {
  try {
    const { 
      category, 
      status = 'live', 
      limit = 20, 
      offset = 0,
      search = ''
    } = req.query;

    let query = {};
    
    if (category) query.category = category;
    if (status) query.status = status;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    // Only show public shows unless user is authenticated
    if (!req.user) {
      query.isPrivate = false;
    }

    const shows = await db.collection('live_shows')
      .find(query)
      .sort({ 'analytics.views': -1, createdAt: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset))
      .toArray();

    const total = await db.collection('live_shows').countDocuments(query);

    res.json({ shows, total });
  } catch (error) {
    logger.error('Get shows error:', error);
    res.status(500).json({ error: 'Failed to fetch shows' });
  }
});

app.post('/shows/:showId/start', authenticateToken, async (req, res) => {
  try {
    const { showId } = req.params;
    const userId = req.user.id;

    const show = await db.collection('live_shows').findOne({ 
      id: showId,
      hostId: userId 
    });

    if (!show) {
      return res.status(404).json({ error: 'Show not found' });
    }

    if (show.status === 'live') {
      return res.status(400).json({ error: 'Show is already live' });
    }

    // Create MediaSoup router for the show
    const worker = mediasoupWorkers[Math.floor(Math.random() * mediasoupWorkers.length)];
    const router = await worker.createRouter({
      mediaCodecs: [
        {
          kind: 'audio',
          mimeType: 'audio/opus',
          clockRate: 48000,
          channels: 2
        },
        {
          kind: 'video',
          mimeType: 'video/VP8',
          clockRate: 90000,
          parameters: {
            'x-google-start-bitrate': 1000
          }
        }
      ]
    });

    // Update show status
    await db.collection('live_shows').updateOne(
      { id: showId },
      { 
        $set: { 
          status: 'live',
          startedAt: new Date(),
          updatedAt: new Date()
        }
      }
    );

    // Store active show data
    activeShows.set(showId, {
      ...show,
      status: 'live',
      router,
      transports: new Map(),
      producers: new Map(),
      consumers: new Map(),
      startedAt: new Date()
    });

    activeShowsGauge.set(activeShows.size);

    // Notify followers
    await notificationQueue.add('show-started', {
      showId,
      hostId: userId,
      title: show.title
    });

    res.json({
      success: true,
      show: {
        ...show,
        status: 'live',
        startedAt: new Date()
      }
    });

  } catch (error) {
    logger.error('Start show error:', error);
    res.status(500).json({ error: 'Failed to start show' });
  }
});

app.post('/shows/:showId/join', authenticateToken, async (req, res) => {
  try {
    const { showId } = req.params;
    const userId = req.user.id;

    const show = await db.collection('live_shows').findOne({ id: showId });

    if (!show) {
      return res.status(404).json({ error: 'Show not found' });
    }

    if (show.status !== 'live') {
      return res.status(400).json({ error: 'Show is not live' });
    }

    // Check if show requires payment
    if (show.monetization.enabled && show.monetization.ticketPrice > 0) {
      const hasTicket = await db.collection('show_tickets').findOne({
        showId,
        userId,
        status: 'valid'
      });

      if (!hasTicket) {
        return res.status(402).json({ error: 'Ticket required' });
      }
    }

    // Check audience limit
    const currentAudience = audienceConnections.get(showId)?.size || 0;
    if (currentAudience >= show.maxAudience) {
      return res.status(429).json({ error: 'Show is at capacity' });
    }

    // Generate access token for the show
    const accessToken = jwt.sign(
      { userId, showId, role: 'audience' },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );

    // Update analytics
    await db.collection('live_shows').updateOne(
      { id: showId },
      { 
        $inc: { 
          'analytics.views': 1,
          'analytics.uniqueViewers': 1
        },
        $addToSet: { audience: userId }
      }
    );

    res.json({
      success: true,
      accessToken,
      show: {
        id: show.id,
        title: show.title,
        description: show.description,
        category: show.category,
        settings: show.settings
      }
    });

  } catch (error) {
    logger.error('Join show error:', error);
    res.status(500).json({ error: 'Failed to join show' });
  }
});

// Audience Engagement Routes
app.post('/shows/:showId/reactions', authenticateToken, [
  body('type').isIn(['like', 'love', 'laugh', 'wow', 'sad', 'angry', 'fire', 'clap']),
  body('intensity').optional().isInt({ min: 1, max: 5 })
], async (req, res) => {
  try {
    const { showId } = req.params;
    const { type, intensity = 1 } = req.body;
    const userId = req.user.id;

    const reaction = {
      id: uuidv4(),
      showId,
      userId,
      type,
      intensity,
      timestamp: new Date()
    };

    // Save reaction
    await db.collection('show_reactions').insertOne(reaction);

    // Broadcast to show room
    io.to(`show_${showId}`).emit('reaction', reaction);

    // Update engagement metrics
    engagementEventsCounter.labels('reaction', showId).inc();

    res.json({ success: true, reaction });
  } catch (error) {
    logger.error('Reaction error:', error);
    res.status(500).json({ error: 'Failed to send reaction' });
  }
});

app.post('/shows/:showId/chat', authenticateToken, [
  body('message').isLength({ min: 1, max: 500 }),
  body('type').optional().isIn(['text', 'emoji', 'gif', 'sticker'])
], async (req, res) => {
  try {
    const { showId } = req.params;
    const { message, type = 'text' } = req.body;
    const userId = req.user.id;

    // Content moderation
    const sentiment = new Sentiment();
    const analysis = sentiment.analyze(message);
    
    if (analysis.score < -5) {
      await contentModerationQueue.add('review-message', {
        showId,
        userId,
        message,
        sentiment: analysis
      });
    }

    const chatMessage = {
      id: uuidv4(),
      showId,
      userId,
      message,
      type,
      sentiment: analysis.score,
      timestamp: new Date()
    };

    // Save message
    await db.collection('show_chat').insertOne(chatMessage);

    // Broadcast to show room
    io.to(`show_${showId}`).emit('chat_message', chatMessage);

    // Update engagement metrics
    engagementEventsCounter.labels('chat', showId).inc();

    res.json({ success: true, message: chatMessage });
  } catch (error) {
    logger.error('Chat error:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});

app.post('/shows/:showId/polls', authenticateToken, [
  body('question').isLength({ min: 1, max: 200 }),
  body('options').isArray({ min: 2, max: 10 }),
  body('duration').optional().isInt({ min: 30, max: 3600 })
], async (req, res) => {
  try {
    const { showId } = req.params;
    const { question, options, duration = 300 } = req.body;
    const userId = req.user.id;

    // Check if user is host or moderator
    const show = await db.collection('live_shows').findOne({ id: showId });
    if (show.hostId !== userId && !show.moderators.includes(userId)) {
      return res.status(403).json({ error: 'Not authorized to create polls' });
    }

    const poll = {
      id: uuidv4(),
      showId,
      createdBy: userId,
      question,
      options: options.map((option, index) => ({
        id: index,
        text: option,
        votes: 0
      })),
      duration,
      votes: [],
      status: 'active',
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + duration * 1000)
    };

    // Save poll
    await db.collection('show_polls').insertOne(poll);

    // Broadcast to show room
    io.to(`show_${showId}`).emit('poll_created', poll);

    // Schedule poll closure
    setTimeout(async () => {
      await db.collection('show_polls').updateOne(
        { id: poll.id },
        { $set: { status: 'closed' } }
      );
      
      io.to(`show_${showId}`).emit('poll_closed', { pollId: poll.id });
    }, duration * 1000);

    res.json({ success: true, poll });
  } catch (error) {
    logger.error('Create poll error:', error);
    res.status(500).json({ error: 'Failed to create poll' });
  }
});

app.post('/shows/:showId/polls/:pollId/vote', authenticateToken, [
  body('optionId').isInt({ min: 0 })
], async (req, res) => {
  try {
    const { showId, pollId } = req.params;
    const { optionId } = req.body;
    const userId = req.user.id;

    const poll = await db.collection('show_polls').findOne({ 
      id: pollId,
      showId,
      status: 'active'
    });

    if (!poll) {
      return res.status(404).json({ error: 'Poll not found or closed' });
    }

    // Check if user already voted
    if (poll.votes.some(vote => vote.userId === userId)) {
      return res.status(400).json({ error: 'Already voted' });
    }

    // Add vote
    await db.collection('show_polls').updateOne(
      { id: pollId },
      { 
        $push: { votes: { userId, optionId, timestamp: new Date() } },
        $inc: { [`options.${optionId}.votes`]: 1 }
      }
    );

    // Broadcast vote update
    io.to(`show_${showId}`).emit('poll_vote', { pollId, optionId, userId });

    // Update engagement metrics
    engagementEventsCounter.labels('poll_vote', showId).inc();

    res.json({ success: true });
  } catch (error) {
    logger.error('Vote error:', error);
    res.status(500).json({ error: 'Failed to vote' });
  }
});

// Monetization Routes
app.post('/shows/:showId/tickets/purchase', authenticateToken, [
  body('paymentMethod').isIn(['stripe', 'paypal', 'square']),
  body('paymentToken').isString()
], async (req, res) => {
  try {
    const { showId } = req.params;
    const { paymentMethod, paymentToken } = req.body;
    const userId = req.user.id;

    const show = await db.collection('live_shows').findOne({ id: showId });

    if (!show || !show.monetization.enabled || show.monetization.ticketPrice <= 0) {
      return res.status(400).json({ error: 'Tickets not available for this show' });
    }

    let paymentResult;

    // Process payment based on method
    switch (paymentMethod) {
      case 'stripe':
        paymentResult = await stripe.paymentIntents.create({
          amount: show.monetization.ticketPrice * 100, // Convert to cents
          currency: show.monetization.currency.toLowerCase(),
          payment_method: paymentToken,
          confirm: true,
          metadata: {
            showId,
            userId,
            type: 'ticket'
          }
        });
        break;

      case 'paypal':
        // PayPal payment processing
        paymentResult = await new Promise((resolve, reject) => {
          PayPal.payment.execute(paymentToken, {
            payer_id: req.body.payerId
          }, (error, payment) => {
            if (error) reject(error);
            else resolve(payment);
          });
        });
        break;

      case 'square':
        const { paymentsApi } = squareClient;
        paymentResult = await paymentsApi.createPayment({
          sourceId: paymentToken,
          amountMoney: {
            amount: show.monetization.ticketPrice * 100,
            currency: show.monetization.currency
          },
          idempotencyKey: uuidv4()
        });
        break;
    }

    // Create ticket
    const ticket = {
      id: uuidv4(),
      showId,
      userId,
      price: show.monetization.ticketPrice,
      currency: show.monetization.currency,
      paymentMethod,
      paymentId: paymentResult.id,
      status: 'valid',
      purchasedAt: new Date()
    };

    await db.collection('show_tickets').insertOne(ticket);

    // Update revenue metrics
    revenueGauge.labels(show.monetization.currency, 'ticket').inc(show.monetization.ticketPrice);

    res.json({
      success: true,
      ticket: {
        id: ticket.id,
        showId: ticket.showId,
        status: ticket.status
      }
    });

  } catch (error) {
    logger.error('Ticket purchase error:', error);
    res.status(500).json({ error: 'Failed to purchase ticket' });
  }
});

app.post('/shows/:showId/donations', authenticateToken, [
  body('amount').isFloat({ min: 1 }),
  body('currency').isIn(['USD', 'EUR', 'GBP', 'CAD', 'AUD']),
  body('paymentMethod').isIn(['stripe', 'paypal', 'square']),
  body('paymentToken').isString(),
  body('message').optional().isLength({ max: 200 })
], async (req, res) => {
  try {
    const { showId } = req.params;
    const { amount, currency, paymentMethod, paymentToken, message = '' } = req.body;
    const userId = req.user.id;

    const show = await db.collection('live_shows').findOne({ id: showId });

    if (!show || !show.monetization.donationsEnabled) {
      return res.status(400).json({ error: 'Donations not enabled for this show' });
    }

    let paymentResult;

    // Process payment
    switch (paymentMethod) {
      case 'stripe':
        paymentResult = await stripe.paymentIntents.create({
          amount: amount * 100,
          currency: currency.toLowerCase(),
          payment_method: paymentToken,
          confirm: true,
          metadata: {
            showId,
            userId,
            type: 'donation'
          }
        });
        break;
    }

    // Create donation record
    const donation = {
      id: uuidv4(),
      showId,
      userId,
      amount,
      currency,
      message,
      paymentMethod,
      paymentId: paymentResult.id,
      timestamp: new Date()
    };

    await db.collection('show_donations').insertOne(donation);

    // Broadcast donation to show
    io.to(`show_${showId}`).emit('donation', {
      amount,
      currency,
      message,
      userId,
      timestamp: donation.timestamp
    });

    // Update revenue metrics
    revenueGauge.labels(currency, 'donation').inc(amount);

    res.json({ success: true, donation });

  } catch (error) {
    logger.error('Donation error:', error);
    res.status(500).json({ error: 'Failed to process donation' });
  }
});

// Socket.IO for real-time features
io.on('connection', (socket) => {
  logger.info(`Client connected: ${socket.id}`);

  socket.on('join_show', async (data) => {
    const { showId, token } = data;
    
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      if (decoded.showId !== showId) {
        socket.emit('error', { message: 'Invalid show token' });
        return;
      }

      socket.userId = decoded.userId;
      socket.showId = showId;
      socket.role = decoded.role;
      
      socket.join(`show_${showId}`);
      
      // Track audience connection
      if (!audienceConnections.has(showId)) {
        audienceConnections.set(showId, new Set());
      }
      audienceConnections.get(showId).add(socket.userId);
      
      connectedAudienceGauge.set(
        Array.from(audienceConnections.values())
          .reduce((total, set) => total + set.size, 0)
      );

      socket.emit('joined_show', { showId, role: decoded.role });
      
      // Notify others of new audience member
      socket.to(`show_${showId}`).emit('audience_joined', { 
        userId: decoded.userId,
        audienceCount: audienceConnections.get(showId).size
      });

    } catch (error) {
      socket.emit('error', { message: 'Invalid token' });
    }
  });

  socket.on('webrtc_offer', async (data) => {
    const { showId, offer } = data;
    
    if (socket.showId === showId && socket.role === 'host') {
      // Handle WebRTC offer from host
      const activeShow = activeShows.get(showId);
      if (activeShow) {
        // Create WebRTC transport
        const transport = await activeShow.router.createWebRtcTransport({
          listenIps: [{ ip: '0.0.0.0', announcedIp: process.env.MEDIASOUP_ANNOUNCED_IP }],
          enableUdp: true,
          enableTcp: true,
          preferUdp: true
        });

        activeShow.transports.set(socket.id, transport);

        socket.emit('webrtc_transport_created', {
          id: transport.id,
          iceParameters: transport.iceParameters,
          iceCandidates: transport.iceCandidates,
          dtlsParameters: transport.dtlsParameters
        });
      }
    }
  });

  socket.on('start_producing', async (data) => {
    const { showId, kind, rtpParameters } = data;
    
    if (socket.showId === showId && socket.role === 'host') {
      const activeShow = activeShows.get(showId);
      const transport = activeShow?.transports.get(socket.id);
      
      if (transport) {
        const producer = await transport.produce({ kind, rtpParameters });
        activeShow.producers.set(producer.id, producer);
        
        socket.emit('producer_created', { id: producer.id });
        
        // Notify all audience members
        socket.to(`show_${showId}`).emit('new_producer', { 
          producerId: producer.id,
          kind 
        });
      }
    }
  });

  socket.on('disconnect', () => {
    logger.info(`Client disconnected: ${socket.id}`);
    
    // Clean up audience tracking
    if (socket.showId && socket.userId) {
      const audienceSet = audienceConnections.get(socket.showId);
      if (audienceSet) {
        audienceSet.delete(socket.userId);
        if (audienceSet.size === 0) {
          audienceConnections.delete(socket.showId);
        }
      }
      
      connectedAudienceGauge.set(
        Array.from(audienceConnections.values())
          .reduce((total, set) => total + set.size, 0)
      );
    }
  });
});

// Analytics and reporting
app.get('/shows/:showId/analytics', authenticateToken, async (req, res) => {
  try {
    const { showId } = req.params;
    const userId = req.user.id;

    const show = await db.collection('live_shows').findOne({ 
      id: showId,
      hostId: userId 
    });

    if (!show) {
      return res.status(404).json({ error: 'Show not found' });
    }

    // Get detailed analytics
    const [reactions, chatMessages, polls, donations] = await Promise.all([
      db.collection('show_reactions').find({ showId }).toArray(),
      db.collection('show_chat').find({ showId }).toArray(),
      db.collection('show_polls').find({ showId }).toArray(),
      db.collection('show_donations').find({ showId }).toArray()
    ]);

    const analytics = {
      overview: show.analytics,
      engagement: {
        totalReactions: reactions.length,
        reactionsByType: reactions.reduce((acc, r) => {
          acc[r.type] = (acc[r.type] || 0) + 1;
          return acc;
        }, {}),
        totalChatMessages: chatMessages.length,
        averageSentiment: chatMessages.reduce((sum, msg) => sum + msg.sentiment, 0) / chatMessages.length || 0,
        totalPolls: polls.length,
        totalVotes: polls.reduce((sum, poll) => sum + poll.votes.length, 0)
      },
      revenue: {
        totalDonations: donations.reduce((sum, d) => sum + d.amount, 0),
        donationCount: donations.length,
        averageDonation: donations.length > 0 ? donations.reduce((sum, d) => sum + d.amount, 0) / donations.length : 0
      },
      timeline: {
        reactions: reactions.map(r => ({ type: 'reaction', timestamp: r.timestamp, data: r })),
        messages: chatMessages.map(m => ({ type: 'message', timestamp: m.timestamp, data: m })),
        donations: donations.map(d => ({ type: 'donation', timestamp: d.timestamp, data: d }))
      }.timeline.sort((a, b) => a.timestamp - b.timestamp)
    };

    res.json({ analytics });
  } catch (error) {
    logger.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'boom-boom-room-live',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    activeShows: activeShows.size,
    connectedAudience: Array.from(audienceConnections.values())
      .reduce((total, set) => total + set.size, 0)
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
const PORT = process.env.PORT || 3050;

async function startServer() {
  await connectDatabases();
  await createMediasoupWorkers();
  
  // Start Node Media Server
  nms.run();
  logger.info('Node Media Server started on port 1935 (RTMP) and 8000 (HTTP)');
  
  server.listen(PORT, () => {
    logger.info(`Boom Boom Room Live service running on port ${PORT}`);
  });
}

startServer().catch(error => {
  logger.error('Failed to start server:', error);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  
  // Close MediaSoup workers
  for (const worker of mediasoupWorkers) {
    worker.close();
  }
  
  // Close Node Media Server
  nms.stop();
  
  // Close database connections
  if (redisClient) await redisClient.quit();
  
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});
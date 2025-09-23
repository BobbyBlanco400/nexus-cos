const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const xss = require('xss-clean');
const hpp = require('hpp');
const cookieParser = require('cookie-parser');
const path = require('path');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const subscriptionRoutes = require('./routes/subscriptions');
const streamRoutes = require('./routes/streams');
const tipRoutes = require('./routes/tips');
const walletRoutes = require('./routes/wallet');

// Import middleware
const { errorHandler, notFound } = require('./middleware/errorHandler');
const { authenticate } = require('./middleware/auth');

// Import services
const socketService = require('./services/socketService');
const logger = require('./utils/logger');

const app = express();

// Trust proxy for accurate IP addresses
app.set('trust proxy', 1);

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      imgSrc: ["'self'", 'data:', 'https:'],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      connectSrc: ["'self'", 'wss:', 'ws:'],
      mediaSrc: ["'self'", 'blob:', 'data:'],
      frameSrc: ["'self'"],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: []
    }
  },
  crossOriginEmbedderPolicy: false
}));

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, etc.)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001',
      'http://localhost:5173',
      'http://localhost:5174',
      'https://nexus-cos.com',
      'https://www.nexus-cos.com',
      'https://app.nexus-cos.com'
    ];
    
    if (process.env.NODE_ENV === 'development') {
      allowedOrigins.push('http://localhost:8080');
      allowedOrigins.push('http://127.0.0.1:3000');
    }
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'Cache-Control',
    'X-Forwarded-For'
  ]
};

app.use(cors(corsOptions));

// Compression middleware
app.use(compression());

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());

// Data sanitization against NoSQL query injection
app.use(mongoSanitize());

// Data sanitization against XSS
app.use(xss());

// Prevent parameter pollution
app.use(hpp({
  whitelist: [
    'sort',
    'fields',
    'page',
    'limit',
    'category',
    'type',
    'status'
  ]
}));

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined', {
    stream: {
      write: (message) => logger.info(message.trim())
    }
  }));
}

// Global rate limiting
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === 'development' ? 1000 : 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Skip rate limiting for health checks and static files
    return req.path === '/health' || req.path.startsWith('/static/');
  }
});

app.use(globalLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Da Boom Boom Room API is healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    version: process.env.npm_package_version || '1.0.0'
  });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/streams', streamRoutes);
app.use('/api/tips', tipRoutes);
app.use('/api/wallet', walletRoutes);

// Serve static files in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../frontend/dist')));
  
  // Handle React Router (return all requests to React app)
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/dist/index.html'));
  });
}

// API documentation endpoint
app.get('/api', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to Da Boom Boom Room API',
    version: '1.0.0',
    documentation: {
      auth: '/api/auth',
      users: '/api/users',
      subscriptions: '/api/subscriptions',
      streams: '/api/streams',
      tips: '/api/tips',
      wallet: '/api/wallet'
    },
    features: [
      '5-tier subscription system (Floor Pass to Black Card)',
      'Live streaming with VR/360° support',
      'Virtual tipping wallet system',
      'Tier-based access control',
      'Real-time notifications',
      'Stripe payment integration',
      'Advanced analytics and leaderboards'
    ],
    support: {
      email: 'support@nexus-cos.com',
      documentation: 'https://docs.nexus-cos.com'
    }
  });
});

// Webhook endpoints (before error handlers)
app.post('/webhooks/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const sig = req.headers['stripe-signature'];
    const stripeService = require('./services/stripeService');
    
    await stripeService.handleWebhook(req.body, sig);
    
    res.status(200).json({ received: true });
  } catch (error) {
    logger.error('Stripe webhook error:', error);
    res.status(400).json({ error: 'Webhook signature verification failed' });
  }
});

// Socket.IO integration
const server = require('http').createServer(app);
const io = socketService.init(server, {
  cors: corsOptions,
  transports: ['websocket', 'polling'],
  allowEIO3: true
});

// Socket.IO authentication middleware
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token || socket.handshake.headers.authorization;
    
    if (!token) {
      return next(new Error('Authentication token required'));
    }
    
    // Verify token (implement your JWT verification logic)
    const jwt = require('jsonwebtoken');
    const decoded = jwt.verify(token.replace('Bearer ', ''), process.env.JWT_SECRET);
    
    const User = require('./models/User');
    const user = await User.findById(decoded.id).select('-password');
    
    if (!user) {
      return next(new Error('User not found'));
    }
    
    socket.userId = user._id.toString();
    socket.user = user;
    
    next();
  } catch (error) {
    next(new Error('Invalid authentication token'));
  }
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info(`User connected: ${socket.userId}`);
  
  // Join user to their personal room
  socket.join(`user:${socket.userId}`);
  
  // Handle stream joining
  socket.on('join-stream', (streamId) => {
    socket.join(`stream:${streamId}`);
    logger.info(`User ${socket.userId} joined stream ${streamId}`);
    
    // Notify stream of new viewer
    socket.to(`stream:${streamId}`).emit('viewer-joined', {
      userId: socket.userId,
      username: socket.user.username,
      avatar: socket.user.avatar
    });
  });
  
  // Handle stream leaving
  socket.on('leave-stream', (streamId) => {
    socket.leave(`stream:${streamId}`);
    logger.info(`User ${socket.userId} left stream ${streamId}`);
    
    // Notify stream of viewer leaving
    socket.to(`stream:${streamId}`).emit('viewer-left', {
      userId: socket.userId
    });
  });
  
  // Handle VR room joining
  socket.on('join-vr-room', (roomId) => {
    socket.join(`vr:${roomId}`);
    logger.info(`User ${socket.userId} joined VR room ${roomId}`);
  });
  
  // Handle VR room leaving
  socket.on('leave-vr-room', (roomId) => {
    socket.leave(`vr:${roomId}`);
    logger.info(`User ${socket.userId} left VR room ${roomId}`);
  });
  
  // Handle chat messages
  socket.on('chat-message', (data) => {
    const { streamId, message, type = 'text' } = data;
    
    // Broadcast message to stream
    io.to(`stream:${streamId}`).emit('chat-message', {
      id: Date.now(),
      userId: socket.userId,
      username: socket.user.username,
      avatar: socket.user.avatar,
      message,
      type,
      timestamp: new Date()
    });
  });
  
  // Handle tip animations
  socket.on('tip-animation', (data) => {
    const { streamId, animation, amount } = data;
    
    // Broadcast animation to stream viewers
    socket.to(`stream:${streamId}`).emit('tip-animation', {
      animation,
      amount,
      sender: socket.user.username,
      timestamp: new Date()
    });
  });
  
  // Handle VR interactions
  socket.on('vr-interaction', (data) => {
    const { roomId, interaction, position, rotation } = data;
    
    // Broadcast VR interaction to room
    socket.to(`vr:${roomId}`).emit('vr-interaction', {
      userId: socket.userId,
      interaction,
      position,
      rotation,
      timestamp: new Date()
    });
  });
  
  // Handle disconnection
  socket.on('disconnect', (reason) => {
    logger.info(`User disconnected: ${socket.userId}, reason: ${reason}`);
  });
  
  // Handle errors
  socket.on('error', (error) => {
    logger.error(`Socket error for user ${socket.userId}:`, error);
  });
});

// Error handling middleware (must be last)
app.use(notFound);
app.use(errorHandler);

// Graceful shutdown handling
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

// Unhandled promise rejection handler
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  server.close(() => {
    process.exit(1);
  });
});

// Uncaught exception handler
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

module.exports = { app, server, io };
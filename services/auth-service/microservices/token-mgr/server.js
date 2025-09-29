const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

// Import routes
const adminRoutes = require('./routes/admin');

const app = express();
const PORT = process.env.PORT || 3102;

// MongoDB connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/nexus-cos-admin';

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'token-mgr',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    port: PORT,
    environment: process.env.NODE_ENV || 'development',
    database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
  });
});

// API routes
app.use('/api/admin', adminRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Nexus COS Token Manager - Admin Auth Service',
    service: 'token-mgr',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      admin: {
        register: 'POST /api/admin/register',
        create: 'POST /api/admin/create',
        login: 'POST /api/admin/login',
        refresh: 'POST /api/admin/refresh',
        profile: 'GET /api/admin/profile',
        logout: 'POST /api/admin/logout'
      },
      health: 'GET /health'
    }
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);

  // Handle JSON parsing errors
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      status: 'error',
      message: 'Invalid JSON format in request body',
      details: err.message
    });
  }

  // Handle Mongoose validation errors
  if (err.name === 'ValidationError') {
    const validationErrors = Object.keys(err.errors).map(key => ({
      field: key,
      message: err.errors[key].message
    }));

    return res.status(400).json({
      status: 'error',
      message: 'Validation failed',
      errors: validationErrors
    });
  }

  // Handle Mongoose cast errors
  if (err.name === 'CastError') {
    return res.status(400).json({
      status: 'error',
      message: 'Invalid data format',
      field: err.path,
      details: err.message
    });
  }

  // Default error response
  res.status(500).json({
    status: 'error',
    message: 'Internal server error',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Route not found',
    path: req.originalUrl,
    method: req.method,
    availableEndpoints: {
      admin: {
        register: 'POST /api/admin/register',
        create: 'POST /api/admin/create',
        login: 'POST /api/admin/login',
        refresh: 'POST /api/admin/refresh',
        profile: 'GET /api/admin/profile',
        logout: 'POST /api/admin/logout'
      },
      health: 'GET /health'
    }
  });
});

// Database connection
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => {
  console.log('✅ Connected to MongoDB');
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error.message);
  console.log('⚠️  Service will continue without database connection for testing');
});

// Graceful shutdown handling
process.on('SIGINT', async () => {
  console.log('\n🔄 Graceful shutdown initiated...');
  
  try {
    await mongoose.connection.close();
    console.log('✅ MongoDB connection closed');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Token Manager (Admin Auth) running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🔐 Admin endpoints: http://localhost:${PORT}/api/admin/`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
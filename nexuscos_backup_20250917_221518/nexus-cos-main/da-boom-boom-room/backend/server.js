/**
 * Da Boom Boom Room Live! - Virtual Strip Club Backend
 * Main server entry point with Express.js and MongoDB
 * Integrated with Nexus COS architecture
 */

const mongoose = require('mongoose');
const { server } = require('./app');
const logger = require('./utils/logger');
require('dotenv').config();

// Database connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      bufferMaxEntries: 0,
      bufferCommands: false,
    });

    logger.info(`MongoDB Connected: ${conn.connection.host}`);
    
    mongoose.connection.on('error', (err) => {
      logger.error('MongoDB connection error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });
    
    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });
    
  } catch (error) {
    logger.error('Database connection failed:', error);
    process.exit(1);
  }
};

// Initialize database and start server
const startServer = async () => {
  try {
    await connectDB();
    
    const PORT = process.env.PORT || 5000;
    
    server.listen(PORT, () => {
      logger.info(`🚀 Da Boom Boom Room API Server running on port ${PORT}`);
      logger.info(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📊 Health check: http://localhost:${PORT}/health`);
      logger.info(`📚 API docs: http://localhost:${PORT}/api`);
      
      if (process.env.NODE_ENV === 'development') {
        logger.info(`🔧 Development mode - CORS enabled for localhost`);
        logger.info(`💳 Stripe webhooks: http://localhost:${PORT}/webhooks/stripe`);
      }
      
      logger.info('📍 Available API routes:');
      logger.info('   🔐 Auth: /api/auth');
      logger.info('   👥 Users: /api/users');
      logger.info('   💎 Subscriptions: /api/subscriptions');
      logger.info('   📺 Streams: /api/streams');
      logger.info('   💰 Tips: /api/tips');
      logger.info('   👛 Wallet: /api/wallet');
      
      logger.info('🎭 Da Boom Boom Room - Premium Adult Entertainment Platform');
      logger.info('🔥 Features: 5-tier subscriptions, VR streaming, virtual tipping');
    });
    
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  logger.error('Uncaught Exception:', err);
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  logger.error('Unhandled Promise Rejection:', err);
  server.close(() => {
    process.exit(1);
  });
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully...');
  try {
    await mongoose.connection.close();
    logger.info('MongoDB connection closed');
    process.exit(0);
  } catch (err) {
    logger.error('Error during shutdown:', err);
    process.exit(1);
  }
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully...');
  try {
    await mongoose.connection.close();
    logger.info('MongoDB connection closed');
    process.exit(0);
  } catch (err) {
    logger.error('Error during shutdown:', err);
    process.exit(1);
  }
});

// Start the server
startServer();

// Export for testing
module.exports = { startServer };
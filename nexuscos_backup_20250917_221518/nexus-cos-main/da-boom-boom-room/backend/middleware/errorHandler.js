/**
 * Error Handler Middleware
 * Centralized error handling for Da Boom Boom Room API
 */

const logger = require('../utils/logger');

/**
 * Custom error class for application errors
 */
class AppError extends Error {
  constructor(message, statusCode, isOperational = true) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';

    Error.captureStackTrace(this, this.constructor);
  }
}

/**
 * Handle MongoDB/Mongoose database errors
 */
const handleMongoError = (error) => {
  let message = 'Database operation failed';
  let statusCode = 500;

  // MongoDB duplicate key error
  if (error.code === 11000) {
    const field = Object.keys(error.keyValue)[0];
    message = `${field} already exists`;
    statusCode = 409;
  }
  // Mongoose validation error
  else if (error.name === 'ValidationError') {
    const errors = Object.values(error.errors).map(err => err.message);
    message = `Validation failed: ${errors.join(', ')}`;
    statusCode = 400;
  }
  // Mongoose cast error (invalid ObjectId)
  else if (error.name === 'CastError') {
    message = `Invalid ${error.path}: ${error.value}`;
    statusCode = 400;
  }
  // Document not found
  else if (error.name === 'DocumentNotFoundError') {
    message = 'Document not found';
    statusCode = 404;
  }
  else {
    message = 'Database operation failed';
    statusCode = 500;
  }

  return new AppError(message, statusCode);
};

/**
 * Handle JWT errors
 */
const handleJWTError = (error) => {
  if (error.name === 'JsonWebTokenError') {
    return new AppError('Invalid token', 401);
  }
  if (error.name === 'TokenExpiredError') {
    return new AppError('Token expired', 401);
  }
  return new AppError('Authentication failed', 401);
};

/**
 * Handle Stripe errors
 */
const handleStripeError = (error) => {
  let message = 'Payment processing failed';
  let statusCode = 400;

  switch (error.type) {
    case 'StripeCardError':
      message = error.message || 'Card was declined';
      statusCode = 402;
      break;
    case 'StripeRateLimitError':
      message = 'Too many requests to Stripe API';
      statusCode = 429;
      break;
    case 'StripeInvalidRequestError':
      message = 'Invalid payment request';
      statusCode = 400;
      break;
    case 'StripeAPIError':
      message = 'Payment service temporarily unavailable';
      statusCode = 503;
      break;
    case 'StripeConnectionError':
      message = 'Payment service connection failed';
      statusCode = 503;
      break;
    case 'StripeAuthenticationError':
      message = 'Payment service authentication failed';
      statusCode = 500;
      break;
    default:
      message = error.message || 'Payment processing error';
      statusCode = 500;
  }

  return new AppError(message, statusCode);
};

/**
 * Handle validation errors
 */
const handleValidationError = (error) => {
  if (error.name === 'ValidationError') {
    const errors = Object.values(error.errors).map(err => err.message);
    const message = `Validation failed: ${errors.join(', ')}`;
    return new AppError(message, 400);
  }
  return new AppError('Validation failed', 400);
};

/**
 * Send error response in development
 */
const sendErrorDev = (err, res) => {
  res.status(err.statusCode).json({
    status: err.status,
    error: err,
    message: err.message,
    stack: err.stack,
    timestamp: new Date().toISOString()
  });
};

/**
 * Send error response in production
 */
const sendErrorProd = (err, res) => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    res.status(err.statusCode).json({
      status: err.status,
      message: err.message,
      timestamp: new Date().toISOString()
    });
  } else {
    // Programming or other unknown error: don't leak error details
    logger.error('ERROR:', err);
    
    res.status(500).json({
      status: 'error',
      message: 'Something went wrong!',
      timestamp: new Date().toISOString()
    });
  }
};

/**
 * Global error handling middleware
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;
  error.statusCode = err.statusCode || 500;
  error.status = err.status || 'error';

  // Log error
  logger.error(`${req.method} ${req.path} - ${error.statusCode} - ${error.message}`, {
    error: error.message,
    stack: error.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.id
  });

  // Handle specific error types
  if (error.code === 11000 || error.name === 'ValidationError' || error.name === 'CastError' || error.name === 'DocumentNotFoundError') {
    error = handleMongoError(error);
  } else if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
    error = handleJWTError(error);
  } else if (error.type && error.type.startsWith('Stripe')) {
    error = handleStripeError(error);
  } else if (error.name === 'ValidationError') {
    error = handleValidationError(error);
  } else if (error.name === 'CastError') {
    error = new AppError('Invalid data format', 400);
  } else if (error.code === 11000) {
    error = new AppError('Duplicate field value', 409);
  }

  // Send error response
  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(error, res);
  } else {
    sendErrorProd(error, res);
  }
};

/**
 * Async error wrapper
 */
const catchAsync = (fn) => {
  return (req, res, next) => {
    fn(req, res, next).catch(next);
  };
};

/**
 * Handle unhandled routes
 */
const notFound = (req, res, next) => {
  const err = new AppError(`Route ${req.originalUrl} not found`, 404);
  next(err);
};

/**
 * Rate limit error handler
 */
const rateLimitHandler = (req, res) => {
  logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
  res.status(429).json({
    status: 'error',
    message: 'Too many requests, please try again later',
    retryAfter: Math.round(req.rateLimit.resetTime / 1000) || 900,
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  AppError,
  errorHandler,
  catchAsync,
  notFound,
  rateLimitHandler
};
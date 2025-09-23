/**
 * Logger Utility
 * Winston-based logging system for Da Boom Boom Room
 */

const winston = require('winston');
const path = require('path');
const fs = require('fs');

// Create logs directory if it doesn't exist
const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4
};

// Define colors for each level
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white'
};

// Add colors to winston
winston.addColors(colors);

// Define log format
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: true }),
  winston.format.printf((info) => {
    const { timestamp, level, message, ...meta } = info;
    const metaStr = Object.keys(meta).length ? JSON.stringify(meta, null, 2) : '';
    return `${timestamp} [${level}]: ${message} ${metaStr}`;
  })
);

// Define file format (without colors)
const fileFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.errors({ stack: true }),
  winston.format.json()
);

// Define transports
const transports = [
  // Console transport
  new winston.transports.Console({
    format: format,
    level: process.env.LOG_LEVEL || 'info'
  }),
  
  // File transport for errors
  new winston.transports.File({
    filename: path.join(logsDir, 'error.log'),
    level: 'error',
    format: fileFormat,
    maxsize: 5242880, // 5MB
    maxFiles: 5
  }),
  
  // File transport for all logs
  new winston.transports.File({
    filename: path.join(logsDir, 'combined.log'),
    format: fileFormat,
    maxsize: 5242880, // 5MB
    maxFiles: 5
  })
];

// Add daily rotate file transport for production
if (process.env.NODE_ENV === 'production') {
  const DailyRotateFile = require('winston-daily-rotate-file');
  
  transports.push(
    new DailyRotateFile({
      filename: path.join(logsDir, 'application-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      zippedArchive: true,
      maxSize: '20m',
      maxFiles: '14d',
      format: fileFormat
    })
  );
}

// Create logger instance
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  levels,
  format: fileFormat,
  transports,
  exitOnError: false
});

// Stream for Morgan HTTP logging
logger.stream = {
  write: (message) => {
    logger.http(message.trim());
  }
};

// Custom logging methods
logger.logRequest = (req, res, responseTime) => {
  const logData = {
    method: req.method,
    url: req.url,
    statusCode: res.statusCode,
    responseTime: `${responseTime}ms`,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    userId: req.user?.id,
    timestamp: new Date().toISOString()
  };
  
  if (res.statusCode >= 400) {
    logger.warn('HTTP Request', logData);
  } else {
    logger.http('HTTP Request', logData);
  }
};

logger.logError = (error, req = null, additionalInfo = {}) => {
  const errorData = {
    message: error.message,
    stack: error.stack,
    name: error.name,
    ...additionalInfo
  };
  
  if (req) {
    errorData.request = {
      method: req.method,
      url: req.url,
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: req.user?.id
    };
  }
  
  logger.error('Application Error', errorData);
};

logger.logAuth = (action, userId, success, additionalInfo = {}) => {
  const logData = {
    action,
    userId,
    success,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  if (success) {
    logger.info('Auth Success', logData);
  } else {
    logger.warn('Auth Failure', logData);
  }
};

logger.logPayment = (action, userId, amount, status, additionalInfo = {}) => {
  const logData = {
    action,
    userId,
    amount,
    status,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  if (status === 'success') {
    logger.info('Payment Success', logData);
  } else {
    logger.warn('Payment Issue', logData);
  }
};

logger.logStream = (action, streamId, userId, additionalInfo = {}) => {
  const logData = {
    action,
    streamId,
    userId,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  logger.info('Stream Activity', logData);
};

logger.logTip = (tipId, userId, performerId, amount, status, additionalInfo = {}) => {
  const logData = {
    tipId,
    userId,
    performerId,
    amount,
    status,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  logger.info('Tip Activity', logData);
};

logger.logSecurity = (event, severity, details = {}) => {
  const logData = {
    event,
    severity,
    timestamp: new Date().toISOString(),
    ...details
  };
  
  if (severity === 'high') {
    logger.error('Security Event', logData);
  } else if (severity === 'medium') {
    logger.warn('Security Event', logData);
  } else {
    logger.info('Security Event', logData);
  }
};

// Performance logging
logger.logPerformance = (operation, duration, additionalInfo = {}) => {
  const logData = {
    operation,
    duration: `${duration}ms`,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  if (duration > 1000) {
    logger.warn('Slow Operation', logData);
  } else {
    logger.debug('Performance', logData);
  }
};

// Database operation logging
logger.logDatabase = (operation, table, duration, success, additionalInfo = {}) => {
  const logData = {
    operation,
    table,
    duration: `${duration}ms`,
    success,
    timestamp: new Date().toISOString(),
    ...additionalInfo
  };
  
  if (!success) {
    logger.error('Database Error', logData);
  } else if (duration > 500) {
    logger.warn('Slow Database Query', logData);
  } else {
    logger.debug('Database Operation', logData);
  }
};

module.exports = logger;
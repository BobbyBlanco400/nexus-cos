/**
 * Authentication Middleware
 * Handles JWT token verification and user authentication
 */

const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { promisify } = require('util');
const { AppError, AuthenticationError, AuthorizationError } = require('./errorHandler');
const logger = require('../utils/logger');

/**
 * Middleware to authenticate JWT tokens
 */
const authMiddleware = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: { isActive: true, isVerified: true }
    });

    if (!user) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'User not found'
      });
    }

    if (!user.isActive) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Account is deactivated'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    logger.error('Auth middleware error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Invalid token'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Token expired'
      });
    }

    res.status(500).json({
      error: 'Internal server error',
      message: 'Authentication failed'
    });
  }
};

/**
 * Middleware to check if user has required subscription tier
 */
const requireSubscriptionTier = (requiredTier) => {
  const tierHierarchy = {
     'NONE': 0,
     'floor-pass': 1,
     'backstage-pass': 2,
     'vip-lounge': 3,
     'champagne-room': 4,
     'black-card': 5
   };

  return async (req, res, next) => {
    try {
      if (!req.user) {
        return res.status(401).json({
          error: 'Access denied',
          message: 'Authentication required'
        });
      }
      
      const subscription = await UserSubscription.findOne({
        userId: req.user._id,
        status: 'active'
      });
      
      const userTier = subscription?.tier || 'NONE';
      const userTierLevel = tierHierarchy[userTier] || 0;
      const requiredTierLevel = tierHierarchy[requiredTier] || 0;

      if (userTierLevel < requiredTierLevel) {
        return res.status(403).json({
          error: 'Insufficient subscription tier',
          message: `${requiredTier} subscription required`,
          currentTier: userTier,
          requiredTier: requiredTier
        });
      }

      // Check if subscription is active
      if (!subscription && requiredTierLevel > 0) {
        return res.status(403).json({
          error: 'No active subscription',
          message: 'Active subscription required'
        });
      }

      req.subscription = subscription;
      next();
    } catch (error) {
      logger.error('Subscription check error:', error);
      return res.status(500).json({
        error: 'Internal server error',
        message: 'Failed to verify subscription'
      });
    }
  };
};

/**
 * Middleware to check if user has required role
 */
const requireRole = (roles) => {
  const roleArray = Array.isArray(roles) ? roles : [roles];
  
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        error: 'Access denied',
        message: 'Authentication required'
      });
    }

    if (!roleArray.includes(req.user.role)) {
      return res.status(403).json({
        error: 'Access denied',
        message: 'Insufficient permissions',
        requiredRoles: roleArray,
        userRole: req.user.role
      });
    }

    next();
  };
};

/**
 * Middleware to check if user is verified
 */
const requireVerification = (req, res, next) => {
  if (!req.user?.isVerified) {
    return res.status(403).json({
      error: 'Account verification required',
      message: 'Please verify your email address to access this feature'
    });
  }
  next();
};

/**
 * Optional authentication middleware (doesn't fail if no token)
 */
const optionalAuth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      req.user = null;
      return next();
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    const user = await User.findById(decoded.userId).select('+active +isVerified');

    req.user = user && user.active ? user : null;
    next();
  } catch (error) {
    // If token is invalid, just continue without user
    req.user = null;
    next();
  }
};

/**
 * Middleware to check stream access permissions
 */
const checkStreamAccess = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    
    const Stream = require('../models/Stream');
    const stream = await Stream.findById(streamId);

    if (!stream) {
      return res.status(404).json({
        error: 'Stream not found',
        message: 'The requested stream does not exist'
      });
    }

    if (!stream.isLive) {
      return res.status(403).json({
        error: 'Stream offline',
        message: 'This stream is currently offline'
      });
    }

    // Check subscription tier requirement
    const tierHierarchy = {
      'NONE': 0,
      'floor-pass': 1,
      'backstage-pass': 2,
      'vip-lounge': 3,
      'champagne-room': 4,
      'black-card': 5
    };

    let userTier = 'NONE';
    let subscription = null;
    
    if (req.user) {
      subscription = await UserSubscription.findOne({
        userId: req.user._id,
        status: 'active'
      });
      userTier = subscription?.tier || 'NONE';
    }
    
    const userTierLevel = tierHierarchy[userTier] || 0;
    const requiredTierLevel = tierHierarchy[stream.minimumTier] || 0;

    if (userTierLevel < requiredTierLevel) {
      return res.status(403).json({
        error: 'Insufficient subscription tier',
        message: `${stream.minimumTier} subscription required to access this stream`,
        currentTier: userTier,
        requiredTier: stream.minimumTier
      });
    }

    // Check if subscription is active (for paid tiers)
    if (!subscription && requiredTierLevel > 0) {
      return res.status(403).json({
        error: 'No active subscription',
        message: 'Active subscription required to access this stream'
      });
    }

    req.stream = stream;
    next();
  } catch (error) {
    logger.error('Stream access check error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: 'Failed to verify stream access'
    });
  }
};

module.exports = {
  authMiddleware,
  requireSubscriptionTier,
  requireRole,
  requireVerification,
  optionalAuth,
  checkStreamAccess
};
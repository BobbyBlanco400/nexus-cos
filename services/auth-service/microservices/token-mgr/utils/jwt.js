const jwt = require('jsonwebtoken');

// JWT configuration
const JWT_SECRET = process.env.JWT_SECRET || 'nexus-cos-admin-secret-key-change-in-production';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'nexus-cos-refresh-secret-key-change-in-production';
const JWT_REFRESH_EXPIRES_IN = process.env.JWT_REFRESH_EXPIRES_IN || '7d';

/**
 * Generate access token for admin user
 * @param {Object} payload - Admin user data
 * @returns {String} JWT token
 */
const generateAccessToken = (payload) => {
  return jwt.sign(
    {
      id: payload.id,
      email: payload.email,
      username: payload.username,
      role: payload.role,
      permissions: payload.permissions,
      type: 'access'
    },
    JWT_SECRET,
    {
      expiresIn: JWT_EXPIRES_IN,
      issuer: 'nexus-cos-admin-auth',
      subject: payload.id.toString()
    }
  );
};

/**
 * Generate refresh token for admin user
 * @param {Object} payload - Admin user data  
 * @returns {String} JWT refresh token
 */
const generateRefreshToken = (payload) => {
  return jwt.sign(
    {
      id: payload.id,
      email: payload.email,
      type: 'refresh'
    },
    JWT_REFRESH_SECRET,
    {
      expiresIn: JWT_REFRESH_EXPIRES_IN,
      issuer: 'nexus-cos-admin-auth',
      subject: payload.id.toString()
    }
  );
};

/**
 * Generate both access and refresh tokens
 * @param {Object} adminUser - Admin user object
 * @returns {Object} Object containing access and refresh tokens
 */
const generateTokenPair = (adminUser) => {
  const payload = {
    id: adminUser._id,
    email: adminUser.email,
    username: adminUser.username,
    role: adminUser.role,
    permissions: adminUser.permissions
  };

  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken(payload),
    expiresIn: JWT_EXPIRES_IN,
    tokenType: 'Bearer'
  };
};

/**
 * Verify access token
 * @param {String} token - JWT token to verify
 * @returns {Object} Decoded token payload
 */
const verifyAccessToken = (token) => {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch (error) {
    throw new Error(`Invalid access token: ${error.message}`);
  }
};

/**
 * Verify refresh token
 * @param {String} token - JWT refresh token to verify
 * @returns {Object} Decoded token payload
 */
const verifyRefreshToken = (token) => {
  try {
    return jwt.verify(token, JWT_REFRESH_SECRET);
  } catch (error) {
    throw new Error(`Invalid refresh token: ${error.message}`);
  }
};

/**
 * Extract token from Authorization header
 * @param {String} authHeader - Authorization header value
 * @returns {String|null} Extracted token or null
 */
const extractTokenFromHeader = (authHeader) => {
  if (!authHeader) return null;
  
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return null;
  }
  
  return parts[1];
};

/**
 * Middleware to authenticate admin users
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const authenticateAdmin = (req, res, next) => {
  try {
    const token = extractTokenFromHeader(req.headers.authorization);
    
    if (!token) {
      return res.status(401).json({
        status: 'error',
        message: 'Access token required'
      });
    }

    const decoded = verifyAccessToken(token);
    
    if (decoded.type !== 'access') {
      return res.status(401).json({
        status: 'error',
        message: 'Invalid token type'
      });
    }

    req.admin = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid or expired token',
      details: error.message
    });
  }
};

/**
 * Middleware to check admin permissions
 * @param {Array} requiredPermissions - Array of required permissions
 * @returns {Function} Express middleware function
 */
const requirePermissions = (requiredPermissions = []) => {
  return (req, res, next) => {
    if (!req.admin) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required'
      });
    }

    const userPermissions = req.admin.permissions || [];
    const hasAllPermissions = requiredPermissions.every(permission => 
      userPermissions.includes(permission)
    );

    if (!hasAllPermissions) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient permissions',
        required: requiredPermissions,
        current: userPermissions
      });
    }

    next();
  };
};

/**
 * Middleware to check admin role
 * @param {Array} requiredRoles - Array of required roles
 * @returns {Function} Express middleware function
 */
const requireRole = (requiredRoles = []) => {
  return (req, res, next) => {
    if (!req.admin) {
      return res.status(401).json({
        status: 'error',
        message: 'Authentication required'
      });
    }

    if (!requiredRoles.includes(req.admin.role)) {
      return res.status(403).json({
        status: 'error',
        message: 'Insufficient role access',
        required: requiredRoles,
        current: req.admin.role
      });
    }

    next();
  };
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  generateTokenPair,
  verifyAccessToken,
  verifyRefreshToken,
  extractTokenFromHeader,
  authenticateAdmin,
  requirePermissions,
  requireRole
};
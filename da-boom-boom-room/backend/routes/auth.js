/**
 * Authentication Routes
 * Handles user registration, login, JWT tokens, and account management
 */

const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { authMiddleware } = require('../middleware/auth');
const { catchAsync, AppError } = require('../middleware/errorHandler');
const { logger } = require('../utils/logger');
const { body, validationResult } = require('express-validator');

const router = express.Router();

/**
 * Generate JWT tokens
 */
const generateTokens = (userId) => {
  const accessToken = jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

  const refreshToken = jwt.sign(
    { userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
  );

  return { accessToken, refreshToken };
};

/**
 * Validation middleware
 */
const validateRegistration = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('username')
    .isLength({ min: 3, max: 30 })
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username must be 3-30 characters and contain only letters, numbers, and underscores'),
  body('password')
    .isLength({ min: 8 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('Password must be at least 8 characters with uppercase, lowercase, number, and special character'),
  body('firstName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name must be 1-50 characters'),
  body('lastName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name must be 1-50 characters'),
  body('dateOfBirth')
    .isISO8601()
    .custom((value) => {
      const age = new Date().getFullYear() - new Date(value).getFullYear();
      if (age < 18) {
        throw new Error('Must be at least 18 years old');
      }
      return true;
    })
];

const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

/**
 * POST /api/auth/register
 * Register a new user
 */
router.post('/register', validateRegistration, catchAsync(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation failed', 400, true);
  }

  const { email, username, password, firstName, lastName, dateOfBirth } = req.body;

  // Check if user already exists
  const existingUser = await User.findOne({
    $or: [{ email }, { username }]
  });

  if (existingUser) {
    const field = existingUser.email === email ? 'email' : 'username';
    throw new AppError(`User with this ${field} already exists`, 409);
  }

  // Hash password
  const saltRounds = 12;
  const hashedPassword = await bcrypt.hash(password, saltRounds);

  // Create user
  const user = await User.create({
    email,
    username,
    password: hashedPassword,
    firstName,
    lastName,
    dateOfBirth: new Date(dateOfBirth),
    role: 'MEMBER',
    subscriptionTier: 'NONE',
    subscriptionStatus: 'INACTIVE'
  });

  const userResponse = {
    id: user._id,
    email: user.email,
    username: user.username,
    firstName: user.firstName,
    lastName: user.lastName,
    role: user.role,
    subscriptionTier: user.subscriptionTier,
    isVerified: user.isVerified,
    createdAt: user.createdAt
  };

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user._id);

  logger.logAuth('register', user._id, true, {
    email: user.email,
    username: user.username
  });

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    data: {
      user: userResponse,
      tokens: {
        accessToken,
        refreshToken
      }
    }
  });
}));

/**
 * POST /api/auth/login
 * User login
 */
router.post('/login', validateLogin, catchAsync(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation failed', 400);
  }

  const { email, password } = req.body;

  // Find user
  const user = await User.findOne({ email }).select('+password +id +email +username +firstName +lastName +role +subscriptionTier +subscriptionStatus +isVerified +active +createdAt');

  if (!user) {
    logger.logAuth('login', null, false, { email, reason: 'user_not_found' });
    throw new AppError('Invalid email or password', 401);
  }

  if (!user.active) {
    logger.logAuth('login', user._id, false, { email, reason: 'account_deactivated' });
    throw new AppError('Account is deactivated', 401);
  }

  // Verify password
  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    logger.logAuth('login', user._id, false, { email, reason: 'invalid_password' });
    throw new AppError('Invalid email or password', 401);
  }

  // Update last login
  await User.findByIdAndUpdate(user._id, { lastLogin: new Date() });

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user._id);

  // Remove password from response
  const { password: _, ...userWithoutPassword } = user.toObject();

  logger.logAuth('login', user._id, true, {
    email: user.email,
    username: user.username
  });

  res.json({
    success: true,
    message: 'Login successful',
    data: {
      user: userWithoutPassword,
      tokens: {
        accessToken,
        refreshToken
      }
    }
  });
}));

/**
 * POST /api/auth/refresh
 * Refresh access token
 */
router.post('/refresh', catchAsync(async (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    throw new AppError('Refresh token is required', 400);
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    
    // Verify user still exists and is active
    const user = await User.findById(decoded.userId).select('id active');

    if (!user || !user.active) {
      throw new AppError('Invalid refresh token', 401);
    }

    // Generate new tokens
    const tokens = generateTokens(user._id);

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      data: {
        tokens
      }
    });
  } catch (error) {
    if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
      throw new AppError('Invalid refresh token', 401);
    }
    throw error;
  }
}));

/**
 * GET /api/auth/me
 * Get current user profile
 */
router.get('/me', authMiddleware, catchAsync(async (req, res) => {
  const user = await User.findById(req.user._id).select('id email username firstName lastName avatar role subscriptionTier subscriptionStatus subscriptionStart subscriptionEnd walletBalance totalSpent totalTipped isVerified active createdAt lastLogin');

  res.json({
    success: true,
    data: { user }
  });
}));

/**
 * PUT /api/auth/profile
 * Update user profile
 */
router.put('/profile', authMiddleware, [
  body('firstName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name must be 1-50 characters'),
  body('lastName')
    .optional()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name must be 1-50 characters'),
  body('username')
    .optional()
    .isLength({ min: 3, max: 30 })
    .matches(/^[a-zA-Z0-9_]+$/)
    .withMessage('Username must be 3-30 characters and contain only letters, numbers, and underscores')
], catchAsync(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation failed', 400);
  }

  const { firstName, lastName, username } = req.body;
  const updateData = {};

  if (firstName !== undefined) updateData.firstName = firstName;
  if (lastName !== undefined) updateData.lastName = lastName;
  if (username !== undefined) {
    // Check if username is already taken
    const existingUser = await User.findOne({
      username,
      _id: { $ne: req.user._id }
    });

    if (existingUser) {
      throw new AppError('Username is already taken', 409);
    }
    updateData.username = username;
  }

  const updatedUser = await User.findByIdAndUpdate(
    req.user._id,
    updateData,
    { new: true }
  ).select('id email username firstName lastName avatar updatedAt');

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: { user: updatedUser }
  });
}));

/**
 * POST /api/auth/change-password
 * Change user password
 */
router.post('/change-password', authMiddleware, [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
    .withMessage('New password must be at least 8 characters with uppercase, lowercase, number, and special character')
], catchAsync(async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new AppError('Validation failed', 400);
  }

  const { currentPassword, newPassword } = req.body;

  // Get user with password
  const user = await User.findById(req.user._id).select('password');

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password);
  if (!isCurrentPasswordValid) {
    throw new AppError('Current password is incorrect', 400);
  }

  // Hash new password
  const saltRounds = 12;
  const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

  // Update password
  user.password = hashedNewPassword;
  await user.save();

  logger.logAuth('password_change', req.user._id, true);

  res.json({
    success: true,
    message: 'Password changed successfully'
  });
}));

/**
 * POST /api/auth/logout
 * Logout user (client-side token removal)
 */
router.post('/logout', authMiddleware, catchAsync(async (req, res) => {
  logger.logAuth('logout', req.user.id, true);
  
  res.json({
    success: true,
    message: 'Logged out successfully'
  });
}));

module.exports = router;
/**
 * Performer Routes
 * Handles performer-related endpoints
 */

const express = require('express');
const { authMiddleware, requireRole, requireSubscription } = require('../middleware/auth');
const {
  getPerformers,
  getPerformerById,
  getPerformerStats,
  updatePerformerProfile,
  setOnlineStatus,
  getPerformerStreams,
  createStream,
  endStream,
  getPerformerEarnings
} = require('../controllers/performerController');
const { body, param, query } = require('express-validator');

const router = express.Router();

/**
 * GET /api/performers
 * Get all performers with filtering and pagination
 * Public endpoint with optional authentication for favorites
 */
router.get('/', [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('category')
    .optional()
    .isIn(['MAIN_STAGE', 'BACKSTAGE', 'VIP_LOUNGE', 'CHAMPAGNE_ROOM', 'PRIVATE'])
    .withMessage('Invalid category'),
  query('isOnline')
    .optional()
    .isBoolean()
    .withMessage('isOnline must be a boolean'),
  query('minRating')
    .optional()
    .isFloat({ min: 0, max: 5 })
    .withMessage('Rating must be between 0 and 5'),
  query('sortBy')
    .optional()
    .isIn(['rating', 'totalEarnings', 'viewerCount', 'createdAt'])
    .withMessage('Invalid sort field'),
  query('sortOrder')
    .optional()
    .isIn(['asc', 'desc'])
    .withMessage('Sort order must be asc or desc')
], getPerformers);

/**
 * GET /api/performers/:performerId
 * Get performer by ID
 * Public endpoint with optional authentication for favorites
 */
router.get('/:performerId', [
  param('performerId')
    .isUUID()
    .withMessage('Invalid performer ID')
], getPerformerById);

// Protected routes - require authentication
router.use(authMiddleware);

/**
 * GET /api/performers/dashboard/stats
 * Get performer statistics (performer only)
 */
router.get('/dashboard/stats', requireRole(['PERFORMER', 'ADMIN']), getPerformerStats);

/**
 * PUT /api/performers/dashboard/profile
 * Update performer profile (performer only)
 */
router.put('/dashboard/profile', requireRole(['PERFORMER', 'ADMIN']), [
  body('displayName')
    .optional()
    .isLength({ min: 1, max: 100 })
    .withMessage('Display name must be 1-100 characters'),
  body('bio')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Bio must be less than 1000 characters'),
  body('category')
    .optional()
    .isIn(['MAIN_STAGE', 'BACKSTAGE', 'VIP_LOUNGE', 'CHAMPAGNE_ROOM', 'PRIVATE'])
    .withMessage('Invalid category'),
  body('tags')
    .optional()
    .isArray()
    .withMessage('Tags must be an array'),
  body('tags.*')
    .optional()
    .isString()
    .isLength({ min: 1, max: 50 })
    .withMessage('Each tag must be 1-50 characters'),
  body('avatar')
    .optional()
    .isURL()
    .withMessage('Avatar must be a valid URL'),
  body('socialLinks')
    .optional()
    .isObject()
    .withMessage('Social links must be an object')
], updatePerformerProfile);

/**
 * PUT /api/performers/dashboard/status
 * Set performer online/offline status (performer only)
 */
router.put('/dashboard/status', requireRole(['PERFORMER', 'ADMIN']), [
  body('isOnline')
    .isBoolean()
    .withMessage('isOnline must be a boolean')
], setOnlineStatus);

/**
 * GET /api/performers/dashboard/streams
 * Get performer's streams (performer only)
 */
router.get('/dashboard/streams', requireRole(['PERFORMER', 'ADMIN']), [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  query('status')
    .optional()
    .isIn(['all', 'active', 'ended'])
    .withMessage('Status must be all, active, or ended')
], getPerformerStreams);

/**
 * POST /api/performers/dashboard/streams
 * Create new stream (performer only)
 */
router.post('/dashboard/streams', requireRole(['PERFORMER', 'ADMIN']), [
  body('title')
    .notEmpty()
    .isLength({ min: 1, max: 200 })
    .withMessage('Title is required and must be 1-200 characters'),
  body('description')
    .optional()
    .isLength({ max: 1000 })
    .withMessage('Description must be less than 1000 characters'),
  body('type')
    .optional()
    .isIn(['LIVE', 'VR_360', 'PRIVATE'])
    .withMessage('Type must be LIVE, VR_360, or PRIVATE'),
  body('category')
    .optional()
    .isIn(['MAIN_STAGE', 'BACKSTAGE', 'VIP_LOUNGE', 'CHAMPAGNE_ROOM', 'PRIVATE'])
    .withMessage('Invalid category'),
  body('requiredTier')
    .optional()
    .isIn(['FLOOR_PASS', 'BACKSTAGE_PASS', 'VIP_LOUNGE', 'CHAMPAGNE_ROOM', 'BLACK_CARD'])
    .withMessage('Invalid required tier'),
  body('isPrivate')
    .optional()
    .isBoolean()
    .withMessage('isPrivate must be a boolean'),
  body('maxViewers')
    .optional()
    .isInt({ min: 1, max: 10000 })
    .withMessage('Max viewers must be between 1 and 10000'),
  body('tags')
    .optional()
    .isArray()
    .withMessage('Tags must be an array')
], createStream);

/**
 * PUT /api/performers/dashboard/streams/:streamId/end
 * End stream (performer only)
 */
router.put('/dashboard/streams/:streamId/end', requireRole(['PERFORMER', 'ADMIN']), [
  param('streamId')
    .isUUID()
    .withMessage('Invalid stream ID')
], endStream);

/**
 * GET /api/performers/dashboard/earnings
 * Get performer earnings (performer only)
 */
router.get('/dashboard/earnings', requireRole(['PERFORMER', 'ADMIN']), [
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid ISO 8601 date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid ISO 8601 date'),
  query('groupBy')
    .optional()
    .isIn(['day', 'week', 'month'])
    .withMessage('Group by must be day, week, or month')
], getPerformerEarnings);

module.exports = router;
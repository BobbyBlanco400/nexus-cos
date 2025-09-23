const express = require('express');
const { body, param, query } = require('express-validator');
const router = express.Router();

// Import middleware
const { authenticate, authorize } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const rateLimiter = require('../middleware/rateLimiter');
const { requireSubscription } = require('../middleware/subscription');
const upload = require('../middleware/upload');

// Import controllers
const streamController = require('../controllers/streamController');

// Validation schemas
const createStreamValidation = [
  body('title')
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('Title must be between 3 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description cannot exceed 500 characters'),
  body('category')
    .isIn(['main-stage', 'backstage', 'vip-lounge', 'champagne-room', 'private'])
    .withMessage('Invalid stream category'),
  body('isVREnabled')
    .optional()
    .isBoolean()
    .withMessage('VR enabled must be a boolean'),
  body('is360')
    .optional()
    .isBoolean()
    .withMessage('360 mode must be a boolean'),
  body('tags')
    .optional()
    .isArray({ max: 10 })
    .withMessage('Maximum 10 tags allowed'),
  body('tags.*')
    .optional()
    .trim()
    .isLength({ min: 2, max: 20 })
    .withMessage('Each tag must be between 2 and 20 characters'),
  body('scheduledFor')
    .optional()
    .isISO8601()
    .withMessage('Scheduled time must be a valid date'),
  body('maxViewers')
    .optional()
    .isInt({ min: 1, max: 10000 })
    .withMessage('Max viewers must be between 1 and 10000'),
  body('isPrivate')
    .optional()
    .isBoolean()
    .withMessage('Private flag must be a boolean'),
  body('requiresSubscription')
    .optional()
    .isBoolean()
    .withMessage('Subscription requirement must be a boolean'),
  body('minimumTier')
    .optional()
    .isIn(['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card'])
    .withMessage('Invalid minimum tier')
];

const updateStreamValidation = [
  body('title')
    .optional()
    .trim()
    .isLength({ min: 3, max: 100 })
    .withMessage('Title must be between 3 and 100 characters'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description cannot exceed 500 characters'),
  body('tags')
    .optional()
    .isArray({ max: 10 })
    .withMessage('Maximum 10 tags allowed'),
  body('isVREnabled')
    .optional()
    .isBoolean()
    .withMessage('VR enabled must be a boolean'),
  body('is360')
    .optional()
    .isBoolean()
    .withMessage('360 mode must be a boolean')
];

const joinStreamValidation = [
  body('vrMode')
    .optional()
    .isBoolean()
    .withMessage('VR mode must be a boolean'),
  body('quality')
    .optional()
    .isIn(['low', 'medium', 'high', 'ultra'])
    .withMessage('Invalid quality setting')
];

// Public routes

// Get all public streams
router.get('/',
  rateLimiter.general,
  query('category')
    .optional()
    .isIn(['main-stage', 'backstage', 'vip-lounge', 'champagne-room', 'private'])
    .withMessage('Invalid category'),
  query('status')
    .optional()
    .isIn(['live', 'scheduled', 'ended'])
    .withMessage('Invalid status'),
  query('hasVR')
    .optional()
    .isBoolean()
    .withMessage('VR filter must be a boolean'),
  query('is360')
    .optional()
    .isBoolean()
    .withMessage('360 filter must be a boolean'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  query('sortBy')
    .optional()
    .isIn(['viewers', 'created', 'title', 'category'])
    .withMessage('Invalid sort field'),
  query('sortOrder')
    .optional()
    .isIn(['asc', 'desc'])
    .withMessage('Sort order must be asc or desc'),
  validateRequest,
  streamController.getStreams
);

// Get stream by ID (public info only)
router.get('/:streamId',
  rateLimiter.general,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.getStreamById
);

// Get stream categories and their requirements
router.get('/categories/info',
  rateLimiter.general,
  streamController.getStreamCategories
);

// Protected routes (require authentication)

// Create new stream
router.post('/',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.streaming,
  createStreamValidation,
  validateRequest,
  streamController.createStream
);

// Update stream
router.put('/:streamId',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  updateStreamValidation,
  validateRequest,
  streamController.updateStream
);

// Start stream
router.post('/:streamId/start',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.startStream
);

// End stream
router.post('/:streamId/end',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.endStream
);

// Join stream as viewer
router.post('/:streamId/join',
  authenticate,
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  joinStreamValidation,
  validateRequest,
  streamController.joinStream
);

// Leave stream
router.post('/:streamId/leave',
  authenticate,
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.leaveStream
);

// Get user's streams (as performer)
router.get('/my/streams',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  query('status')
    .optional()
    .isIn(['live', 'scheduled', 'ended'])
    .withMessage('Invalid status'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  validateRequest,
  streamController.getMyStreams
);

// Get viewing history
router.get('/my/history',
  authenticate,
  rateLimiter.authenticated,
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  validateRequest,
  streamController.getViewingHistory
);

// Upload stream thumbnail
router.post('/:streamId/thumbnail',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.upload,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  upload.single('thumbnail'),
  streamController.uploadThumbnail
);

// Delete stream
router.delete('/:streamId',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.deleteStream
);

// VR-specific routes

// Get VR stream data
router.get('/:streamId/vr',
  authenticate,
  requireSubscription(['backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.getVRStreamData
);

// Join VR session
router.post('/:streamId/vr/join',
  authenticate,
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  body('vrDevice')
    .optional()
    .isIn(['oculus', 'vive', 'pico', 'quest', 'other'])
    .withMessage('Invalid VR device'),
  body('capabilities')
    .optional()
    .isArray()
    .withMessage('Capabilities must be an array'),
  validateRequest,
  streamController.joinVRSession
);

// Leave VR session
router.post('/:streamId/vr/leave',
  authenticate,
  rateLimiter.streaming,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.leaveVRSession
);

// Subscription-gated routes

// Backstage access (requires Backstage Pass or higher)
router.get('/backstage/streams',
  authenticate,
  requireSubscription(['backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.authenticated,
  streamController.getBackstageStreams
);

// VIP Lounge access (requires VIP Lounge or higher)
router.get('/vip/streams',
  authenticate,
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.authenticated,
  streamController.getVIPStreams
);

// Champagne Room access (requires Champagne Room or higher)
router.get('/champagne/streams',
  authenticate,
  requireSubscription(['champagne-room', 'black-card']),
  rateLimiter.authenticated,
  streamController.getChampagneStreams
);

// Black Card exclusive access
router.get('/exclusive/streams',
  authenticate,
  requireSubscription(['black-card']),
  rateLimiter.authenticated,
  streamController.getExclusiveStreams
);

// Admin routes

// Get all streams (admin view)
router.get('/admin/all',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  query('status')
    .optional()
    .isIn(['live', 'scheduled', 'ended', 'suspended'])
    .withMessage('Invalid status'),
  query('performer')
    .optional()
    .isMongoId()
    .withMessage('Invalid performer ID'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validateRequest,
  streamController.getAllStreamsAdmin
);

// Suspend stream
router.post('/:streamId/suspend',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  body('reason')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Suspension reason must be between 10 and 500 characters'),
  validateRequest,
  streamController.suspendStream
);

// Unsuspend stream
router.post('/:streamId/unsuspend',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.unsuspendStream
);

// Get stream analytics
router.get('/:streamId/analytics',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  param('streamId')
    .isMongoId()
    .withMessage('Invalid stream ID'),
  validateRequest,
  streamController.getStreamAnalytics
);

// Get platform analytics
router.get('/admin/analytics',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  query('category')
    .optional()
    .isIn(['main-stage', 'backstage', 'vip-lounge', 'champagne-room', 'private'])
    .withMessage('Invalid category'),
  validateRequest,
  streamController.getPlatformAnalytics
);

module.exports = router;
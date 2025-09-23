/**
 * User Routes
 * Handles user-related endpoints
 */

const express = require('express');
const { authMiddleware, requireSubscription } = require('../middleware/auth');
const {
  getUserStats,
  getUserPreferences,
  updateUserPreferences,
  getFavoritePerformers,
  addFavoritePerformer,
  removeFavoritePerformer,
  getViewingHistory,
  clearViewingHistory,
  getTipLeaderboardPosition,
  deactivateAccount,
  getNotifications,
  markNotificationsRead
} = require('../controllers/userController');
const { body } = require('express-validator');

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

/**
 * GET /api/users/stats
 * Get user statistics and activity
 */
router.get('/stats', getUserStats);

/**
 * GET /api/users/preferences
 * Get user preferences
 */
router.get('/preferences', getUserPreferences);

/**
 * PUT /api/users/preferences
 * Update user preferences
 */
router.put('/preferences', [
  body('notifications')
    .optional()
    .isBoolean()
    .withMessage('Notifications must be a boolean'),
  body('autoRenewSubscription')
    .optional()
    .isBoolean()
    .withMessage('Auto renew subscription must be a boolean'),
  body('preferredStreamQuality')
    .optional()
    .isIn(['SD', 'HD', '4K'])
    .withMessage('Stream quality must be SD, HD, or 4K'),
  body('vrEnabled')
    .optional()
    .isBoolean()
    .withMessage('VR enabled must be a boolean'),
  body('darkMode')
    .optional()
    .isBoolean()
    .withMessage('Dark mode must be a boolean'),
  body('language')
    .optional()
    .isIn(['en', 'es', 'fr', 'de', 'ja', 'ko'])
    .withMessage('Language must be a supported language code')
], updateUserPreferences);

/**
 * GET /api/users/favorites
 * Get user's favorite performers
 */
router.get('/favorites', getFavoritePerformers);

/**
 * POST /api/users/favorites/:performerId
 * Add performer to favorites
 */
router.post('/favorites/:performerId', addFavoritePerformer);

/**
 * DELETE /api/users/favorites/:performerId
 * Remove performer from favorites
 */
router.delete('/favorites/:performerId', removeFavoritePerformer);

/**
 * GET /api/users/history
 * Get user's viewing history
 */
router.get('/history', getViewingHistory);

/**
 * DELETE /api/users/history
 * Clear user's viewing history
 */
router.delete('/history', clearViewingHistory);

/**
 * GET /api/users/leaderboard
 * Get user's tip leaderboard position
 */
router.get('/leaderboard', getTipLeaderboardPosition);

/**
 * GET /api/users/notifications
 * Get user notifications
 */
router.get('/notifications', getNotifications);

/**
 * PUT /api/users/notifications/read
 * Mark notifications as read
 */
router.put('/notifications/read', [
  body('notificationIds')
    .optional()
    .isArray()
    .withMessage('Notification IDs must be an array')
], markNotificationsRead);

/**
 * POST /api/users/deactivate
 * Deactivate user account
 */
router.post('/deactivate', [
  body('password')
    .notEmpty()
    .withMessage('Password is required to deactivate account')
], deactivateAccount);

module.exports = router;
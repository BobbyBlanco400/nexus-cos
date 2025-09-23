const express = require('express');
const { body, param, query } = require('express-validator');
const router = express.Router();

// Import middleware
const { authenticate, authorize } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const rateLimiter = require('../middleware/rateLimiter');
const { requireSubscription } = require('../middleware/subscription');

// Import controllers
const tipController = require('../controllers/tipController');
const walletController = require('../controllers/walletController');

// Validation schemas
const sendTipValidation = [
  body('recipientId')
    .isMongoId()
    .withMessage('Invalid recipient ID'),
  body('amount')
    .isFloat({ min: 0.01, max: 10000 })
    .withMessage('Tip amount must be between $0.01 and $10,000'),
  body('message')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Tip message cannot exceed 200 characters'),
  body('isAnonymous')
    .optional()
    .isBoolean()
    .withMessage('Anonymous flag must be a boolean'),
  body('streamId')
    .optional()
    .isMongoId()
    .withMessage('Invalid stream ID'),
  body('animation')
    .optional()
    .isIn(['none', 'hearts', 'fireworks', 'rain', 'explosion', 'vr-special'])
    .withMessage('Invalid animation type'),
  body('vrEffect')
    .optional()
    .isIn(['none', 'sparkles', 'confetti', 'spotlight', 'front-row'])
    .withMessage('Invalid VR effect')
];

const depositValidation = [
  body('amount')
    .isFloat({ min: 5, max: 5000 })
    .withMessage('Deposit amount must be between $5 and $5,000'),
  body('paymentMethodId')
    .isString()
    .trim()
    .matches(/^pm_[a-zA-Z0-9]+$/)
    .withMessage('Invalid payment method ID'),
  body('savePaymentMethod')
    .optional()
    .isBoolean()
    .withMessage('Save payment method flag must be a boolean')
];

const withdrawValidation = [
  body('amount')
    .isFloat({ min: 10 })
    .withMessage('Minimum withdrawal amount is $10'),
  body('bankAccountId')
    .optional()
    .isString()
    .trim()
    .withMessage('Invalid bank account ID'),
  body('cryptoAddress')
    .optional()
    .isString()
    .trim()
    .withMessage('Invalid crypto address'),
  body('withdrawalMethod')
    .isIn(['bank', 'paypal', 'crypto', 'stripe'])
    .withMessage('Invalid withdrawal method')
];

const tipGoalValidation = [
  body('amount')
    .isFloat({ min: 1, max: 50000 })
    .withMessage('Goal amount must be between $1 and $50,000'),
  body('description')
    .trim()
    .isLength({ min: 5, max: 100 })
    .withMessage('Goal description must be between 5 and 100 characters'),
  body('deadline')
    .optional()
    .isISO8601()
    .withMessage('Deadline must be a valid date'),
  body('isPublic')
    .optional()
    .isBoolean()
    .withMessage('Public flag must be a boolean')
];

// Public routes

// Get tip leaderboard
router.get('/leaderboard',
  rateLimiter.general,
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'all-time'])
    .withMessage('Invalid period'),
  query('category')
    .optional()
    .isIn(['tippers', 'receivers', 'streams'])
    .withMessage('Invalid category'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validateRequest,
  tipController.getLeaderboard
);

// Get public tip statistics
router.get('/stats',
  rateLimiter.general,
  tipController.getPublicStats
);

// Protected routes (require authentication)

// Wallet management

// Get wallet balance and info
router.get('/wallet',
  authenticate,
  rateLimiter.authenticated,
  walletController.getWallet
);

// Get wallet transaction history
router.get('/wallet/transactions',
  authenticate,
  rateLimiter.authenticated,
  query('type')
    .optional()
    .isIn(['deposit', 'withdrawal', 'tip-sent', 'tip-received', 'refund'])
    .withMessage('Invalid transaction type'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  validateRequest,
  walletController.getTransactionHistory
);

// Deposit funds to wallet
router.post('/wallet/deposit',
  authenticate,
  rateLimiter.payment,
  depositValidation,
  validateRequest,
  walletController.depositFunds
);

// Withdraw funds from wallet (performers only)
router.post('/wallet/withdraw',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.payment,
  withdrawValidation,
  validateRequest,
  walletController.withdrawFunds
);

// Get payment methods
router.get('/wallet/payment-methods',
  authenticate,
  rateLimiter.authenticated,
  walletController.getPaymentMethods
);

// Add payment method
router.post('/wallet/payment-methods',
  authenticate,
  rateLimiter.payment,
  body('paymentMethodId')
    .isString()
    .trim()
    .matches(/^pm_[a-zA-Z0-9]+$/)
    .withMessage('Invalid payment method ID'),
  body('setAsDefault')
    .optional()
    .isBoolean()
    .withMessage('Default flag must be a boolean'),
  validateRequest,
  walletController.addPaymentMethod
);

// Remove payment method
router.delete('/wallet/payment-methods/:paymentMethodId',
  authenticate,
  rateLimiter.authenticated,
  param('paymentMethodId')
    .isString()
    .trim()
    .withMessage('Invalid payment method ID'),
  validateRequest,
  walletController.removePaymentMethod
);

// Tipping functionality

// Send tip
router.post('/send',
  authenticate,
  rateLimiter.tipping,
  sendTipValidation,
  validateRequest,
  tipController.sendTip
);

// Get user's tip history (sent)
router.get('/sent',
  authenticate,
  rateLimiter.authenticated,
  query('recipientId')
    .optional()
    .isMongoId()
    .withMessage('Invalid recipient ID'),
  query('streamId')
    .optional()
    .isMongoId()
    .withMessage('Invalid stream ID'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  validateRequest,
  tipController.getSentTips
);

// Get user's tip history (received) - performers only
router.get('/received',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  query('senderId')
    .optional()
    .isMongoId()
    .withMessage('Invalid sender ID'),
  query('streamId')
    .optional()
    .isMongoId()
    .withMessage('Invalid stream ID'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  validateRequest,
  tipController.getReceivedTips
);

// Get tip details
router.get('/:tipId',
  authenticate,
  rateLimiter.authenticated,
  param('tipId')
    .isMongoId()
    .withMessage('Invalid tip ID'),
  validateRequest,
  tipController.getTipDetails
);

// Quick tip presets
router.get('/presets/quick',
  authenticate,
  rateLimiter.authenticated,
  tipController.getQuickTipPresets
);

// Update quick tip presets
router.put('/presets/quick',
  authenticate,
  rateLimiter.authenticated,
  body('presets')
    .isArray({ min: 1, max: 8 })
    .withMessage('Must provide 1-8 preset amounts'),
  body('presets.*')
    .isFloat({ min: 0.01, max: 1000 })
    .withMessage('Each preset must be between $0.01 and $1,000'),
  validateRequest,
  tipController.updateQuickTipPresets
);

// Tip goals (performers only)

// Get current tip goals
router.get('/goals/current',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  tipController.getCurrentTipGoals
);

// Create tip goal
router.post('/goals',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  tipGoalValidation,
  validateRequest,
  tipController.createTipGoal
);

// Update tip goal
router.put('/goals/:goalId',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  param('goalId')
    .isMongoId()
    .withMessage('Invalid goal ID'),
  body('description')
    .optional()
    .trim()
    .isLength({ min: 5, max: 100 })
    .withMessage('Goal description must be between 5 and 100 characters'),
  body('deadline')
    .optional()
    .isISO8601()
    .withMessage('Deadline must be a valid date'),
  validateRequest,
  tipController.updateTipGoal
);

// Delete tip goal
router.delete('/goals/:goalId',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  param('goalId')
    .isMongoId()
    .withMessage('Invalid goal ID'),
  validateRequest,
  tipController.deleteTipGoal
);

// VR and premium features (subscription-gated)

// Send VR tip with special effects (VIP+ only)
router.post('/vr/send',
  authenticate,
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.tipping,
  sendTipValidation,
  body('vrEffect')
    .isIn(['sparkles', 'confetti', 'spotlight', 'front-row'])
    .withMessage('VR effect is required for VR tips'),
  validateRequest,
  tipController.sendVRTip
);

// Get VR tip animations (VIP+ only)
router.get('/vr/animations',
  authenticate,
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  rateLimiter.authenticated,
  tipController.getVRAnimations
);

// Tip rain feature (Champagne Room+ only)
router.post('/rain',
  authenticate,
  requireSubscription(['champagne-room', 'black-card']),
  rateLimiter.tipping,
  body('totalAmount')
    .isFloat({ min: 10, max: 1000 })
    .withMessage('Tip rain amount must be between $10 and $1,000'),
  body('duration')
    .isInt({ min: 5, max: 60 })
    .withMessage('Duration must be between 5 and 60 seconds'),
  body('streamId')
    .isMongoId()
    .withMessage('Stream ID is required for tip rain'),
  validateRequest,
  tipController.createTipRain
);

// Premium tip reactions (Black Card only)
router.post('/premium-reaction',
  authenticate,
  requireSubscription(['black-card']),
  rateLimiter.tipping,
  body('tipId')
    .isMongoId()
    .withMessage('Invalid tip ID'),
  body('reactionType')
    .isIn(['golden-shower', 'diamond-rain', 'exclusive-access', 'private-message'])
    .withMessage('Invalid premium reaction type'),
  validateRequest,
  tipController.addPremiumReaction
);

// Tip menu (performers only)

// Get performer's tip menu
router.get('/menu/:performerId',
  rateLimiter.general,
  param('performerId')
    .isMongoId()
    .withMessage('Invalid performer ID'),
  validateRequest,
  tipController.getTipMenu
);

// Create/update tip menu (performers only)
router.put('/menu',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  body('items')
    .isArray({ max: 20 })
    .withMessage('Maximum 20 tip menu items allowed'),
  body('items.*.title')
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage('Item title must be between 3 and 50 characters'),
  body('items.*.description')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Item description cannot exceed 200 characters'),
  body('items.*.amount')
    .isFloat({ min: 1, max: 10000 })
    .withMessage('Item amount must be between $1 and $10,000'),
  body('items.*.category')
    .optional()
    .isIn(['request', 'action', 'content', 'interaction', 'vr-special'])
    .withMessage('Invalid item category'),
  validateRequest,
  tipController.updateTipMenu
);

// Analytics and reporting

// Get tip analytics (performers only)
router.get('/analytics/earnings',
  authenticate,
  authorize(['performer', 'admin']),
  rateLimiter.authenticated,
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('Invalid period'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  validateRequest,
  tipController.getEarningsAnalytics
);

// Get spending analytics (users)
router.get('/analytics/spending',
  authenticate,
  rateLimiter.authenticated,
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('Invalid period'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  validateRequest,
  tipController.getSpendingAnalytics
);

// Admin routes

// Get platform tip analytics
router.get('/admin/analytics',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('Invalid period'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('End date must be a valid date'),
  validateRequest,
  tipController.getPlatformAnalytics
);

// Get all transactions (admin)
router.get('/admin/transactions',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  query('type')
    .optional()
    .isIn(['tip', 'deposit', 'withdrawal', 'refund'])
    .withMessage('Invalid transaction type'),
  query('status')
    .optional()
    .isIn(['pending', 'completed', 'failed', 'cancelled'])
    .withMessage('Invalid status'),
  query('userId')
    .optional()
    .isMongoId()
    .withMessage('Invalid user ID'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validateRequest,
  tipController.getAllTransactions
);

// Refund tip (admin only)
router.post('/:tipId/refund',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  param('tipId')
    .isMongoId()
    .withMessage('Invalid tip ID'),
  body('reason')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Refund reason must be between 10 and 500 characters'),
  validateRequest,
  tipController.refundTip
);

// Suspend user from tipping (admin only)
router.post('/admin/suspend/:userId',
  authenticate,
  authorize(['admin']),
  rateLimiter.admin,
  param('userId')
    .isMongoId()
    .withMessage('Invalid user ID'),
  body('reason')
    .trim()
    .isLength({ min: 10, max: 500 })
    .withMessage('Suspension reason must be between 10 and 500 characters'),
  body('duration')
    .optional()
    .isInt({ min: 1, max: 365 })
    .withMessage('Suspension duration must be between 1 and 365 days'),
  validateRequest,
  tipController.suspendUserFromTipping
);

module.exports = router;
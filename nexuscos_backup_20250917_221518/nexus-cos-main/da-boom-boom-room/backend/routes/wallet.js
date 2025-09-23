const express = require('express');
const { body, query, param } = require('express-validator');
const rateLimit = require('express-rate-limit');
const walletController = require('../controllers/walletController');
const { authenticate, authorize } = require('../middleware/auth');
const { validate } = require('../middleware/validation');
const { requireSubscription } = require('../middleware/subscription');

const router = express.Router();

// Rate limiting
const depositLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 deposits per 15 minutes
  message: { success: false, message: 'Too many deposit attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false
});

const withdrawalLimit = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // 3 withdrawals per hour
  message: { success: false, message: 'Too many withdrawal attempts. Please try again later.' },
  standardHeaders: true,
  legacyHeaders: false
});

const payoutLimit = rateLimit({
  windowMs: 24 * 60 * 60 * 1000, // 24 hours
  max: 2, // 2 payout requests per day
  message: { success: false, message: 'Too many payout requests. Please try again tomorrow.' },
  standardHeaders: true,
  legacyHeaders: false
});

// Validation schemas
const depositValidation = [
  body('amount')
    .isFloat({ min: 1, max: 1000 })
    .withMessage('Deposit amount must be between $1 and $1,000'),
  body('paymentMethodId')
    .isString()
    .notEmpty()
    .withMessage('Payment method is required'),
  body('savePaymentMethod')
    .optional()
    .isBoolean()
    .withMessage('Save payment method must be a boolean')
];

const withdrawalValidation = [
  body('amount')
    .isFloat({ min: 10, max: 5000 })
    .withMessage('Withdrawal amount must be between $10 and $5,000'),
  body('method')
    .isIn(['bank-transfer', 'paypal', 'stripe'])
    .withMessage('Invalid withdrawal method'),
  body('details')
    .isObject()
    .withMessage('Withdrawal details are required')
];

const payoutValidation = [
  body('amount')
    .isFloat({ min: 50, max: 10000 })
    .withMessage('Payout amount must be between $50 and $10,000'),
  body('method')
    .isIn(['bank-transfer', 'paypal', 'stripe', 'crypto'])
    .withMessage('Invalid payout method'),
  body('details')
    .isObject()
    .withMessage('Payout details are required')
];

const payoutSettingsValidation = [
  body('minimumPayout')
    .optional()
    .isFloat({ min: 10, max: 500 })
    .withMessage('Minimum payout must be between $10 and $500'),
  body('autoPayoutEnabled')
    .optional()
    .isBoolean()
    .withMessage('Auto payout enabled must be a boolean'),
  body('autoPayoutThreshold')
    .optional()
    .isFloat({ min: 50, max: 1000 })
    .withMessage('Auto payout threshold must be between $50 and $1,000'),
  body('preferredPayoutMethod')
    .optional()
    .isIn(['bank-transfer', 'paypal', 'stripe', 'crypto'])
    .withMessage('Invalid preferred payout method'),
  body('payoutSchedule')
    .optional()
    .isIn(['weekly', 'bi-weekly', 'monthly'])
    .withMessage('Invalid payout schedule')
];

const limitsValidation = [
  body('dailyDepositLimit')
    .optional()
    .isFloat({ min: 100, max: 5000 })
    .withMessage('Daily deposit limit must be between $100 and $5,000'),
  body('dailyWithdrawalLimit')
    .optional()
    .isFloat({ min: 50, max: 2000 })
    .withMessage('Daily withdrawal limit must be between $50 and $2,000'),
  body('monthlyDepositLimit')
    .optional()
    .isFloat({ min: 1000, max: 50000 })
    .withMessage('Monthly deposit limit must be between $1,000 and $50,000'),
  body('monthlyWithdrawalLimit')
    .optional()
    .isFloat({ min: 500, max: 20000 })
    .withMessage('Monthly withdrawal limit must be between $500 and $20,000')
];

const transactionQueryValidation = [
  query('type')
    .optional()
    .isIn(['deposit', 'withdrawal', 'tip-sent', 'tip-received', 'refund', 'payout', 'bonus'])
    .withMessage('Invalid transaction type'),
  query('startDate')
    .optional()
    .isISO8601()
    .withMessage('Invalid start date format'),
  query('endDate')
    .optional()
    .isISO8601()
    .withMessage('Invalid end date format'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100')
];

// Public routes (no authentication required)

// Get platform wallet statistics
router.get('/stats/platform',
  walletController.getPlatformStats
);

// Protected routes (authentication required)
router.use(authenticate);

// Get current user's wallet
router.get('/',
  walletController.getWallet
);

// Get wallet balance
router.get('/balance',
  walletController.getBalance
);

// Get transaction history
router.get('/transactions',
  transactionQueryValidation,
  validate,
  walletController.getTransactions
);

// Get specific transaction
router.get('/transactions/:transactionId',
  param('transactionId').isMongoId().withMessage('Invalid transaction ID'),
  validate,
  walletController.getTransaction
);

// Deposit funds
router.post('/deposit',
  depositLimit,
  depositValidation,
  validate,
  walletController.deposit
);

// Create deposit intent (for Stripe)
router.post('/deposit/intent',
  body('amount')
    .isFloat({ min: 1, max: 1000 })
    .withMessage('Deposit amount must be between $1 and $1,000'),
  validate,
  walletController.createDepositIntent
);

// Confirm deposit
router.post('/deposit/confirm',
  body('paymentIntentId')
    .isString()
    .notEmpty()
    .withMessage('Payment intent ID is required'),
  validate,
  walletController.confirmDeposit
);

// Withdraw funds (requires VIP+ subscription)
router.post('/withdraw',
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  withdrawalLimit,
  withdrawalValidation,
  validate,
  walletController.withdraw
);

// Get payout requests
router.get('/payouts',
  query('status')
    .optional()
    .isIn(['pending', 'processing', 'completed', 'failed', 'cancelled'])
    .withMessage('Invalid payout status'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 50 })
    .withMessage('Limit must be between 1 and 50'),
  validate,
  walletController.getPayouts
);

// Request payout (for performers)
router.post('/payout',
  payoutLimit,
  payoutValidation,
  validate,
  walletController.requestPayout
);

// Cancel payout request
router.delete('/payout/:payoutId',
  param('payoutId').isMongoId().withMessage('Invalid payout ID'),
  validate,
  walletController.cancelPayout
);

// Get payout settings
router.get('/settings/payout',
  walletController.getPayoutSettings
);

// Update payout settings
router.put('/settings/payout',
  payoutSettingsValidation,
  validate,
  walletController.updatePayoutSettings
);

// Get wallet limits
router.get('/limits',
  walletController.getLimits
);

// Update wallet limits (VIP+ only)
router.put('/limits',
  requireSubscription(['vip-lounge', 'champagne-room', 'black-card']),
  limitsValidation,
  validate,
  walletController.updateLimits
);

// Get payment methods
router.get('/payment-methods',
  walletController.getPaymentMethods
);

// Add payment method
router.post('/payment-methods',
  body('type')
    .isIn(['card', 'bank', 'paypal'])
    .withMessage('Invalid payment method type'),
  body('token')
    .isString()
    .notEmpty()
    .withMessage('Payment method token is required'),
  validate,
  walletController.addPaymentMethod
);

// Remove payment method
router.delete('/payment-methods/:methodId',
  param('methodId').isString().notEmpty().withMessage('Invalid payment method ID'),
  validate,
  walletController.removePaymentMethod
);

// Set default payment method
router.put('/payment-methods/:methodId/default',
  param('methodId').isString().notEmpty().withMessage('Invalid payment method ID'),
  validate,
  walletController.setDefaultPaymentMethod
);

// Get wallet analytics
router.get('/analytics',
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('Invalid analytics period'),
  query('type')
    .optional()
    .isIn(['earnings', 'spending', 'both'])
    .withMessage('Invalid analytics type'),
  validate,
  walletController.getAnalytics
);

// Get spending breakdown
router.get('/analytics/spending',
  query('period')
    .optional()
    .isIn(['monthly', 'yearly'])
    .withMessage('Invalid period'),
  validate,
  walletController.getSpendingBreakdown
);

// Get earnings breakdown (for performers)
router.get('/analytics/earnings',
  query('period')
    .optional()
    .isIn(['monthly', 'yearly'])
    .withMessage('Invalid period'),
  validate,
  walletController.getEarningsBreakdown
);

// Verification routes

// Get verification status
router.get('/verification',
  walletController.getVerificationStatus
);

// Upload verification document
router.post('/verification/upload',
  body('documentType')
    .isIn(['id', 'passport', 'drivers-license', 'utility-bill', 'bank-statement'])
    .withMessage('Invalid document type'),
  body('documentUrl')
    .isURL()
    .withMessage('Valid document URL is required'),
  validate,
  walletController.uploadVerificationDocument
);

// Submit for verification
router.post('/verification/submit',
  walletController.submitForVerification
);

// Notification settings

// Get notification preferences
router.get('/notifications',
  walletController.getNotificationPreferences
);

// Update notification preferences
router.put('/notifications',
  body('emailOnDeposit')
    .optional()
    .isBoolean()
    .withMessage('Email on deposit must be a boolean'),
  body('emailOnWithdrawal')
    .optional()
    .isBoolean()
    .withMessage('Email on withdrawal must be a boolean'),
  body('emailOnTipReceived')
    .optional()
    .isBoolean()
    .withMessage('Email on tip received must be a boolean'),
  body('emailOnPayoutProcessed')
    .optional()
    .isBoolean()
    .withMessage('Email on payout processed must be a boolean'),
  body('pushNotifications')
    .optional()
    .isBoolean()
    .withMessage('Push notifications must be a boolean'),
  validate,
  walletController.updateNotificationPreferences
);

// Admin routes (admin access required)
router.use('/admin', authorize(['admin', 'moderator']));

// Get all wallets (admin)
router.get('/admin/wallets',
  query('status')
    .optional()
    .isIn(['active', 'suspended', 'frozen', 'closed'])
    .withMessage('Invalid wallet status'),
  query('verified')
    .optional()
    .isBoolean()
    .withMessage('Verified must be a boolean'),
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validate,
  walletController.getAllWallets
);

// Get specific user's wallet (admin)
router.get('/admin/wallets/:userId',
  param('userId').isMongoId().withMessage('Invalid user ID'),
  validate,
  walletController.getUserWallet
);

// Process payout (admin)
router.put('/admin/payouts/:payoutId/process',
  param('payoutId').isMongoId().withMessage('Invalid payout ID'),
  body('status')
    .isIn(['completed', 'failed'])
    .withMessage('Status must be completed or failed'),
  body('externalReference')
    .optional()
    .isString()
    .withMessage('External reference must be a string'),
  body('failureReason')
    .optional()
    .isString()
    .withMessage('Failure reason must be a string'),
  validate,
  walletController.processPayout
);

// Suspend wallet (admin)
router.put('/admin/wallets/:userId/suspend',
  param('userId').isMongoId().withMessage('Invalid user ID'),
  body('reason')
    .isString()
    .notEmpty()
    .withMessage('Suspension reason is required'),
  body('expiresAt')
    .optional()
    .isISO8601()
    .withMessage('Invalid expiration date'),
  body('notes')
    .optional()
    .isString()
    .withMessage('Notes must be a string'),
  validate,
  walletController.suspendWallet
);

// Unsuspend wallet (admin)
router.put('/admin/wallets/:userId/unsuspend',
  param('userId').isMongoId().withMessage('Invalid user ID'),
  validate,
  walletController.unsuspendWallet
);

// Adjust wallet balance (admin)
router.post('/admin/wallets/:userId/adjust',
  param('userId').isMongoId().withMessage('Invalid user ID'),
  body('amount')
    .isFloat()
    .withMessage('Amount must be a number'),
  body('reason')
    .isString()
    .notEmpty()
    .withMessage('Adjustment reason is required'),
  body('type')
    .isIn(['bonus', 'penalty', 'adjustment'])
    .withMessage('Invalid adjustment type'),
  validate,
  walletController.adjustBalance
);

// Review verification documents (admin)
router.put('/admin/verification/:userId/:documentId',
  param('userId').isMongoId().withMessage('Invalid user ID'),
  param('documentId').isMongoId().withMessage('Invalid document ID'),
  body('status')
    .isIn(['approved', 'rejected'])
    .withMessage('Status must be approved or rejected'),
  body('rejectionReason')
    .optional()
    .isString()
    .withMessage('Rejection reason must be a string'),
  validate,
  walletController.reviewVerificationDocument
);

// Get platform analytics (admin)
router.get('/admin/analytics',
  query('period')
    .optional()
    .isIn(['daily', 'weekly', 'monthly', 'yearly'])
    .withMessage('Invalid analytics period'),
  validate,
  walletController.getPlatformAnalytics
);

// Get top earners (admin)
router.get('/admin/top-earners',
  query('period')
    .optional()
    .isIn(['monthly', 'yearly', 'all-time'])
    .withMessage('Invalid period'),
  query('limit')
    .optional()
    .isInt({ min: 1, max: 100 })
    .withMessage('Limit must be between 1 and 100'),
  validate,
  walletController.getTopEarners
);

// Export transaction data (admin)
router.get('/admin/export/transactions',
  query('startDate')
    .isISO8601()
    .withMessage('Valid start date is required'),
  query('endDate')
    .isISO8601()
    .withMessage('Valid end date is required'),
  query('format')
    .optional()
    .isIn(['csv', 'json'])
    .withMessage('Format must be csv or json'),
  validate,
  walletController.exportTransactions
);

module.exports = router;
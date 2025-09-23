/**
 * Subscription Routes
 * Handles subscription tiers, Stripe integration, and tier-based access
 */

const express = require('express');
const { body, param, query } = require('express-validator');
const subscriptionController = require('../controllers/subscriptionController');
const { authenticate, authorize } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

// Validation schemas
const createCheckoutValidation = [
  body('tierSlug')
    .isIn(['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card'])
    .withMessage('Invalid subscription tier'),
  body('billingCycle')
    .isIn(['monthly', 'yearly'])
    .withMessage('Billing cycle must be monthly or yearly'),
  body('successUrl')
    .optional()
    .isURL()
    .withMessage('Success URL must be valid'),
  body('cancelUrl')
    .optional()
    .isURL()
    .withMessage('Cancel URL must be valid'),
  body('promoCode')
    .optional()
    .isString()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Promo code must be 1-50 characters')
];

const changeTierValidation = [
  body('newTierSlug')
    .isIn(['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card'])
    .withMessage('Invalid subscription tier'),
  body('billingCycle')
    .optional()
    .isIn(['monthly', 'yearly'])
    .withMessage('Billing cycle must be monthly or yearly')
];

const cancelSubscriptionValidation = [
  body('reason')
    .optional()
    .isString()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Cancellation reason must be less than 500 characters'),
  body('immediate')
    .optional()
    .isBoolean()
    .withMessage('Immediate must be a boolean')
];

const updatePaymentMethodValidation = [
  body('paymentMethodId')
    .isString()
    .trim()
    .matches(/^pm_[a-zA-Z0-9]+$/)
    .withMessage('Invalid payment method ID')
];

// Public routes

// Get all subscription tiers
router.get('/tiers', 
  rateLimiter.general,
  subscriptionController.getTiers
);

// Get specific tier details
router.get('/tiers/:tierSlug', 
  rateLimiter.general,
  param('tierSlug')
    .isIn(['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card'])
    .withMessage('Invalid tier slug'),
  validateRequest,
  subscriptionController.getTierDetails
);

// Protected routes (require authentication)

// Get current user's subscription
router.get('/current',
  authenticate,
  rateLimiter.authenticated,
  subscriptionController.getCurrentSubscription
);

// Create checkout session
router.post('/checkout',
  authenticate,
  rateLimiter.payment,
  createCheckoutValidation,
  validateRequest,
  subscriptionController.createCheckoutSession
);

// Handle successful subscription (called after Stripe checkout)
router.post('/success/:sessionId',
  authenticate,
  rateLimiter.payment,
  param('sessionId')
    .isString()
    .trim()
    .matches(/^cs_[a-zA-Z0-9]+$/)
    .withMessage('Invalid session ID'),
  validateRequest,
  subscriptionController.handleSubscriptionSuccess
);

// Cancel subscription
router.post('/cancel',
  authenticate,
  rateLimiter.authenticated,
  cancelSubscriptionValidation,
  validateRequest,
  subscriptionController.cancelSubscription
);

// Reactivate cancelled subscription
router.post('/reactivate',
  authenticate,
  rateLimiter.authenticated,
  subscriptionController.reactivateSubscription
);

// Change subscription tier
router.put('/tier',
  authenticate,
  rateLimiter.payment,
  changeTierValidation,
  validateRequest,
  subscriptionController.changeTier
);

// Get subscription history
router.get('/history',
  authenticate,
  rateLimiter.authenticated,
  subscriptionController.getSubscriptionHistory
);

// Get billing information
router.get('/billing',
  authenticate,
  rateLimiter.authenticated,
  subscriptionController.getBillingInfo
);

// Update payment method
router.put('/payment-method',
  authenticate,
  rateLimiter.payment,
  updatePaymentMethodValidation,
  validateRequest,
  subscriptionController.updatePaymentMethod
);

// Check feature access
router.get('/access/:feature',
  authenticate,
  rateLimiter.authenticated,
  param('feature')
    .isString()
    .trim()
    .matches(/^[a-zA-Z0-9_.]+$/)
    .withMessage('Invalid feature path'),
  validateRequest,
  subscriptionController.checkFeatureAccess
);

// Admin routes

// Get subscription analytics
router.get('/analytics',
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
  validateRequest,
  subscriptionController.getSubscriptionAnalytics
);

// Middleware for subscription-based access control
router.use('/protected', authenticate, async (req, res, next) => {
  try {
    const UserSubscription = require('../models/UserSubscription');
    const subscription = await UserSubscription.findActiveForUser(req.user.id);
    
    if (!subscription || !subscription.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Active subscription required',
        code: 'SUBSCRIPTION_REQUIRED'
      });
    }
    
    req.subscription = subscription;
    next();
  } catch (error) {
    next(error);
  }
});

// Protected subscription routes (require active subscription)

// Get subscription benefits
router.get('/protected/benefits',
  rateLimiter.authenticated,
  async (req, res, next) => {
    try {
      const subscription = req.subscription;
      const tier = subscription.subscriptionTier;
      
      res.status(200).json({
        success: true,
        data: {
          tier: {
            name: tier.name,
            level: tier.level,
            features: tier.features,
            benefits: tier.benefits,
            color: tier.color
          },
          subscription: subscription.getSummary(),
          usage: subscription.usage
        }
      });
    } catch (error) {
      next(error);
    }
  }
);

module.exports = router;
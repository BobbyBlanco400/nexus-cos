const express = require('express');
const { body, param, query } = require('express-validator');
const subscriptionController = require('../controllers/subscriptionController');
const { authenticate, authorize } = require('../middleware/auth');
const { validateRequest } = require('../middleware/validation');
const { rateLimiter } = require('../middleware/rateLimiter');

const router = express.Router();

// fallback no-op middleware if rateLimiter.general is undefined
const noop = (req, res, next) => next();
const safeRateLimiter = (rateLimiter && rateLimiter.general) ? rateLimiter.general : noop;

// Public routes
router.get('/tiers', safeRateLimiter, subscriptionController.getTiers);

// Get specific tier details
router.get('/tiers/:tierSlug',
  safeRateLimiter,
  param('tierSlug')
    .isIn(['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card'])
    .withMessage('Invalid tier slug'),
  validateRequest,
  subscriptionController.getTierDetails
);

module.exports = router;
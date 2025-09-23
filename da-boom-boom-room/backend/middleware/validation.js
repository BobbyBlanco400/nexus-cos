const { body, validationResult } = require('express-validator');

// Validation middleware for subscription-related requests
const validateSubscription = [
  body('tier').isIn(['FLOOR_PASS', 'VIP_PASS', 'PREMIUM_PASS']).withMessage('Invalid subscription tier'),
  body('paymentMethod').isIn(['card', 'crypto']).optional().withMessage('Invalid payment method'),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  }
];

module.exports = {
  validateSubscription
};
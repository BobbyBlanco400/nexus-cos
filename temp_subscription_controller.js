/**
 * subscriptionController.js
 *
 * Handles subscription tier logic for Da Boom Boom Room
 */

const SubscriptionTier = require('../models/SubscriptionTier');
const { AppError } = require('../middleware/errorHandler');
const logger = require('../utils/logger');

/**
 * GET /tiers
 * Returns all subscription tiers
 */
exports.getTiers = async (req, res, next) => {
  try {
    const tiers = await SubscriptionTier.find({ isActive: true }).sort({ level: 1 });
    res.status(200).json({
      success: true,
      data: { tiers }
    });
  } catch (error) {
    logger.error('Error fetching subscription tiers:', error);
    next(new AppError('Failed to fetch subscription tiers', 500));
  }
};

/**
 * GET /tiers/:tierSlug
 * Returns details for a specific tier
 */
exports.getTierDetails = async (req, res, next) => {
  try {
    const { tierSlug } = req.params;
    
    const tier = await SubscriptionTier.findOne({ slug: tierSlug, isActive: true });
    if (!tier) {
      return next(new AppError('Subscription tier not found', 404));
    }
    
    res.status(200).json({
      success: true,
      data: { tier }
    });
  } catch (error) {
    logger.error('Error fetching tier details:', error);
    next(new AppError('Failed to fetch tier details', 500));
  }
};
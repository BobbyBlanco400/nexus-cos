const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const SubscriptionTier = require('../models/SubscriptionTier');
const UserSubscription = require('../models/UserSubscription');
const User = require('../models/User');
const { validationResult } = require('express-validator');
const { AppError } = require('../utils/errorHandler');
const logger = require('../utils/logger');

// Get all subscription tiers
exports.getTiers = async (req, res, next) => {
  try {
    const tiers = await SubscriptionTier.getActiveTiers();
    
    res.status(200).json({
      success: true,
      data: {
        tiers: tiers.map(tier => tier.getComparisonData())
      }
    });
  } catch (error) {
    logger.error('Error fetching subscription tiers:', error);
    next(new AppError('Failed to fetch subscription tiers', 500));
  }
};

// Get specific tier details
exports.getTierDetails = async (req, res, next) => {
  try {
    const { tierSlug } = req.params;
    
    const tier = await SubscriptionTier.findBySlug(tierSlug);
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

// Get user's current subscription
exports.getCurrentSubscription = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const subscription = await UserSubscription.findActiveForUser(userId);
    
    if (!subscription) {
      return res.status(200).json({
        success: true,
        data: {
          subscription: null,
          hasActiveSubscription: false
        }
      });
    }
    
    res.status(200).json({
      success: true,
      data: {
        subscription: subscription.getSummary(),
        hasActiveSubscription: true
      }
    });
  } catch (error) {
    logger.error('Error fetching current subscription:', error);
    next(new AppError('Failed to fetch subscription', 500));
  }
};

// Create Stripe checkout session
exports.createCheckoutSession = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return next(new AppError('Validation failed', 400, errors.array()));
    }
    
    const { tierSlug, billingCycle, successUrl, cancelUrl, promoCode } = req.body;
    const userId = req.user.id;
    
    // Get subscription tier
    const tier = await SubscriptionTier.findBySlug(tierSlug);
    if (!tier) {
      return next(new AppError('Invalid subscription tier', 400));
    }
    
    // Check if user already has active subscription
    const existingSubscription = await UserSubscription.findActiveForUser(userId);
    if (existingSubscription) {
      return next(new AppError('User already has an active subscription', 400));
    }
    
    // Get or create Stripe customer
    let stripeCustomer;
    const user = await User.findById(userId);
    
    if (user.stripeCustomerId) {
      stripeCustomer = await stripe.customers.retrieve(user.stripeCustomerId);
    } else {
      stripeCustomer = await stripe.customers.create({
        email: user.email,
        name: user.username,
        metadata: {
          userId: userId.toString()
        }
      });
      
      // Update user with Stripe customer ID
      user.stripeCustomerId = stripeCustomer.id;
      await user.save();
    }
    
    // Prepare checkout session parameters
    const sessionParams = {
      customer: stripeCustomer.id,
      payment_method_types: ['card'],
      line_items: [{
        price: tier.stripePriceId[billingCycle],
        quantity: 1
      }],
      mode: 'subscription',
      success_url: successUrl || `${process.env.FRONTEND_URL}/subscription/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl || `${process.env.FRONTEND_URL}/subscription/cancel`,
      metadata: {
        userId: userId.toString(),
        tierSlug: tierSlug,
        billingCycle: billingCycle
      },
      subscription_data: {
        metadata: {
          userId: userId.toString(),
          tierSlug: tierSlug,
          billingCycle: billingCycle
        },
        trial_period_days: tier.level === 1 ? 7 : 0 // 7-day trial for Floor Pass
      },
      allow_promotion_codes: true
    };
    
    // Apply promo code if provided
    if (promoCode) {
      try {
        const promotionCodes = await stripe.promotionCodes.list({
          code: promoCode,
          active: true,
          limit: 1
        });
        
        if (promotionCodes.data.length > 0) {
          sessionParams.discounts = [{
            promotion_code: promotionCodes.data[0].id
          }];
        }
      } catch (promoError) {
        logger.warn('Invalid promo code provided:', promoCode);
        // Continue without promo code rather than failing
      }
    }
    
    // Create checkout session
    const session = await stripe.checkout.sessions.create(sessionParams);
    
    logger.info(`Checkout session created for user ${userId}, tier ${tierSlug}`);
    
    res.status(200).json({
      success: true,
      data: {
        sessionId: session.id,
        sessionUrl: session.url
      }
    });
  } catch (error) {
    logger.error('Error creating checkout session:', error);
    next(new AppError('Failed to create checkout session', 500));
  }
};

// Handle successful subscription
exports.handleSubscriptionSuccess = async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    
    // Retrieve checkout session
    const session = await stripe.checkout.sessions.retrieve(sessionId, {
      expand: ['subscription', 'subscription.items.data.price']
    });
    
    if (!session.subscription) {
      return next(new AppError('No subscription found in session', 400));
    }
    
    const subscription = session.subscription;
    const userId = session.metadata.userId;
    const tierSlug = session.metadata.tierSlug;
    
    // Get subscription tier
    const tier = await SubscriptionTier.findBySlug(tierSlug);
    if (!tier) {
      return next(new AppError('Invalid subscription tier', 400));
    }
    
    // Create user subscription record
    const userSubscription = new UserSubscription({
      user: userId,
      subscriptionTier: tier._id,
      stripeSubscriptionId: subscription.id,
      stripeCustomerId: subscription.customer,
      stripePriceId: subscription.items.data[0].price.id,
      stripeProductId: subscription.items.data[0].price.product,
      status: subscription.status,
      billingCycle: session.metadata.billingCycle,
      currentPeriodStart: new Date(subscription.current_period_start * 1000),
      currentPeriodEnd: new Date(subscription.current_period_end * 1000),
      trialStart: subscription.trial_start ? new Date(subscription.trial_start * 1000) : null,
      trialEnd: subscription.trial_end ? new Date(subscription.trial_end * 1000) : null,
      metadata: {
        source: 'checkout',
        sessionId: sessionId
      }
    });
    
    await userSubscription.save();
    
    logger.info(`Subscription created for user ${userId}, tier ${tierSlug}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: 'Subscription activated successfully'
      }
    });
  } catch (error) {
    logger.error('Error handling subscription success:', error);
    next(new AppError('Failed to process subscription', 500));
  }
};

// Cancel subscription
exports.cancelSubscription = async (req, res, next) => {
  try {
    const { reason, immediate } = req.body;
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return next(new AppError('No active subscription found', 404));
    }
    
    // Cancel in Stripe
    if (immediate) {
      await stripe.subscriptions.cancel(userSubscription.stripeSubscriptionId);
    } else {
      await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
        cancel_at_period_end: true
      });
    }
    
    // Update local subscription
    await userSubscription.cancelSubscription(reason, immediate);
    
    logger.info(`Subscription cancelled for user ${userId}, immediate: ${immediate}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: immediate ? 'Subscription cancelled immediately' : 'Subscription will cancel at period end'
      }
    });
  } catch (error) {
    logger.error('Error cancelling subscription:', error);
    next(new AppError('Failed to cancel subscription', 500));
  }
};

// Reactivate cancelled subscription
exports.reactivateSubscription = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findOne({
      user: userId,
      cancelAtPeriodEnd: true,
      status: 'active'
    });
    
    if (!userSubscription) {
      return next(new AppError('No subscription to reactivate', 404));
    }
    
    // Reactivate in Stripe
    await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
      cancel_at_period_end: false
    });
    
    // Update local subscription
    userSubscription.cancelAtPeriodEnd = false;
    userSubscription.cancellationReason = null;
    await userSubscription.save();
    
    logger.info(`Subscription reactivated for user ${userId}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: 'Subscription reactivated successfully'
      }
    });
  } catch (error) {
    logger.error('Error reactivating subscription:', error);
    next(new AppError('Failed to reactivate subscription', 500));
  }
};

// Change subscription tier
exports.changeTier = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return next(new AppError('Validation failed', 400, errors.array()));
    }
    
    const { newTierSlug, billingCycle } = req.body;
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return next(new AppError('No active subscription found', 404));
    }
    
    const newTier = await SubscriptionTier.findBySlug(newTierSlug);
    if (!newTier) {
      return next(new AppError('Invalid subscription tier', 400));
    }
    
    // Check if it's actually a change
    if (userSubscription.subscriptionTier._id.toString() === newTier._id.toString()) {
      return next(new AppError('Already subscribed to this tier', 400));
    }
    
    // Update subscription in Stripe
    const stripeSubscription = await stripe.subscriptions.retrieve(userSubscription.stripeSubscriptionId);
    
    await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
      items: [{
        id: stripeSubscription.items.data[0].id,
        price: newTier.stripePriceId[billingCycle || userSubscription.billingCycle]
      }],
      proration_behavior: 'create_prorations'
    });
    
    // Update local subscription
    await userSubscription.changeTier(newTier._id, 'user_upgrade');
    
    logger.info(`Subscription tier changed for user ${userId} to ${newTierSlug}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: 'Subscription tier updated successfully'
      }
    });
  } catch (error) {
    logger.error('Error changing subscription tier:', error);
    next(new AppError('Failed to change subscription tier', 500));
  }
};

// Get subscription history
exports.getSubscriptionHistory = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const subscriptions = await UserSubscription.getSubscriptionHistory(userId);
    
    res.status(200).json({
      success: true,
      data: {
        subscriptions: subscriptions.map(sub => sub.getSummary())
      }
    });
  } catch (error) {
    logger.error('Error fetching subscription history:', error);
    next(new AppError('Failed to fetch subscription history', 500));
  }
};

// Get billing information
exports.getBillingInfo = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return next(new AppError('No active subscription found', 404));
    }
    
    // Get payment methods from Stripe
    const paymentMethods = await stripe.paymentMethods.list({
      customer: userSubscription.stripeCustomerId,
      type: 'card'
    });
    
    // Get upcoming invoice
    let upcomingInvoice = null;
    try {
      upcomingInvoice = await stripe.invoices.retrieveUpcoming({
        customer: userSubscription.stripeCustomerId
      });
    } catch (invoiceError) {
      // No upcoming invoice
    }
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        paymentMethods: paymentMethods.data,
        upcomingInvoice: upcomingInvoice ? {
          amount: upcomingInvoice.amount_due,
          currency: upcomingInvoice.currency,
          periodStart: new Date(upcomingInvoice.period_start * 1000),
          periodEnd: new Date(upcomingInvoice.period_end * 1000)
        } : null
      }
    });
  } catch (error) {
    logger.error('Error fetching billing info:', error);
    next(new AppError('Failed to fetch billing information', 500));
  }
};

// Update payment method
exports.updatePaymentMethod = async (req, res, next) => {
  try {
    const { paymentMethodId } = req.body;
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return next(new AppError('No active subscription found', 404));
    }
    
    // Attach payment method to customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: userSubscription.stripeCustomerId
    });
    
    // Update default payment method
    await stripe.customers.update(userSubscription.stripeCustomerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId
      }
    });
    
    // Update subscription default payment method
    await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
      default_payment_method: paymentMethodId
    });
    
    logger.info(`Payment method updated for user ${userId}`);
    
    res.status(200).json({
      success: true,
      data: {
        message: 'Payment method updated successfully'
      }
    });
  } catch (error) {
    logger.error('Error updating payment method:', error);
    next(new AppError('Failed to update payment method', 500));
  }
};

// Check feature access
exports.checkFeatureAccess = async (req, res, next) => {
  try {
    const { feature } = req.params;
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    
    let hasAccess = false;
    let tierLevel = 0;
    
    if (userSubscription && userSubscription.isActive) {
      hasAccess = userSubscription.hasFeatureAccess(feature);
      tierLevel = userSubscription.subscriptionTier.level;
    }
    
    res.status(200).json({
      success: true,
      data: {
        hasAccess,
        tierLevel,
        feature,
        subscription: userSubscription ? userSubscription.getSummary() : null
      }
    });
  } catch (error) {
    logger.error('Error checking feature access:', error);
    next(new AppError('Failed to check feature access', 500));
  }
};

// Pause subscription
exports.pauseSubscription = async (req, res, next) => {
  try {
    const { reason, resumeDate } = req.body;
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return next(new AppError('No active subscription found', 404));
    }
    
    // Pause in Stripe (if supported by plan)
    try {
      await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
        pause_collection: {
          behavior: 'keep_as_draft'
        }
      });
    } catch (stripeError) {
      logger.warn('Stripe pause not supported, handling locally:', stripeError.message);
    }
    
    // Update local subscription
    await userSubscription.pauseSubscription(reason, resumeDate);
    
    logger.info(`Subscription paused for user ${userId}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: 'Subscription paused successfully'
      }
    });
  } catch (error) {
    logger.error('Error pausing subscription:', error);
    next(new AppError('Failed to pause subscription', 500));
  }
};

// Resume subscription
exports.resumeSubscription = async (req, res, next) => {
  try {
    const userId = req.user.id;
    
    const userSubscription = await UserSubscription.findOne({
      user: userId,
      status: 'paused'
    });
    
    if (!userSubscription) {
      return next(new AppError('No paused subscription found', 404));
    }
    
    // Resume in Stripe
    try {
      await stripe.subscriptions.update(userSubscription.stripeSubscriptionId, {
        pause_collection: null
      });
    } catch (stripeError) {
      logger.warn('Stripe resume not supported, handling locally:', stripeError.message);
    }
    
    // Update local subscription
    await userSubscription.resumeSubscription();
    
    logger.info(`Subscription resumed for user ${userId}`);
    
    res.status(200).json({
      success: true,
      data: {
        subscription: userSubscription.getSummary(),
        message: 'Subscription resumed successfully'
      }
    });
  } catch (error) {
    logger.error('Error resuming subscription:', error);
    next(new AppError('Failed to resume subscription', 500));
  }
};

// Get subscription analytics (for admin)
exports.getSubscriptionAnalytics = async (req, res, next) => {
  try {
    // Check admin permissions
    if (req.user.role !== 'admin') {
      return next(new AppError('Access denied', 403));
    }
    
    const { startDate, endDate } = req.query;
    
    const matchStage = {};
    if (startDate || endDate) {
      matchStage.createdAt = {};
      if (startDate) matchStage.createdAt.$gte = new Date(startDate);
      if (endDate) matchStage.createdAt.$lte = new Date(endDate);
    }
    
    const analytics = await UserSubscription.aggregate([
      { $match: matchStage },
      {
        $lookup: {
          from: 'subscriptiontiers',
          localField: 'subscriptionTier',
          foreignField: '_id',
          as: 'tier'
        }
      },
      { $unwind: '$tier' },
      {
        $group: {
          _id: {
            tierName: '$tier.name',
            status: '$status',
            billingCycle: '$billingCycle'
          },
          count: { $sum: 1 },
          totalRevenue: {
            $sum: {
              $cond: {
                if: { $eq: ['$billingCycle', 'monthly'] },
                then: '$tier.price.monthly',
                else: '$tier.price.yearly'
              }
            }
          }
        }
      },
      {
        $group: {
          _id: '$_id.tierName',
          subscriptions: {
            $push: {
              status: '$_id.status',
              billingCycle: '$_id.billingCycle',
              count: '$count',
              revenue: '$totalRevenue'
            }
          },
          totalSubscriptions: { $sum: '$count' },
          totalRevenue: { $sum: '$totalRevenue' }
        }
      }
    ]);
    
    res.status(200).json({
      success: true,
      data: { analytics }
    });
  } catch (error) {
    logger.error('Error fetching subscription analytics:', error);
    next(new AppError('Failed to fetch analytics', 500));
  }
};
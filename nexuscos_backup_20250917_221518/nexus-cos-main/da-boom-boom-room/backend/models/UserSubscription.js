const mongoose = require('mongoose');

// User subscription schema
const userSubscriptionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  subscriptionTier: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SubscriptionTier',
    required: true
  },
  // Stripe subscription details
  stripeSubscriptionId: {
    type: String,
    required: true,
    unique: true
  },
  stripeCustomerId: {
    type: String,
    required: true
  },
  stripePriceId: {
    type: String,
    required: true
  },
  stripeProductId: {
    type: String,
    required: true
  },
  // Subscription status
  status: {
    type: String,
    enum: [
      'active',
      'canceled',
      'incomplete',
      'incomplete_expired',
      'past_due',
      'trialing',
      'unpaid',
      'paused'
    ],
    required: true,
    default: 'incomplete'
  },
  // Billing details
  billingCycle: {
    type: String,
    enum: ['monthly', 'yearly'],
    required: true
  },
  currentPeriodStart: {
    type: Date,
    required: true
  },
  currentPeriodEnd: {
    type: Date,
    required: true
  },
  // Trial information
  trialStart: {
    type: Date
  },
  trialEnd: {
    type: Date
  },
  // Cancellation details
  cancelAtPeriodEnd: {
    type: Boolean,
    default: false
  },
  canceledAt: {
    type: Date
  },
  cancellationReason: {
    type: String
  },
  // Payment details
  lastPaymentDate: {
    type: Date
  },
  nextPaymentDate: {
    type: Date
  },
  paymentMethod: {
    type: {
      type: String,
      enum: ['card', 'bank_account', 'paypal']
    },
    last4: String,
    brand: String,
    expiryMonth: Number,
    expiryYear: Number
  },
  // Usage tracking
  usage: {
    streamHours: {
      type: Number,
      default: 0
    },
    tipsGiven: {
      type: Number,
      default: 0
    },
    messagesPosted: {
      type: Number,
      default: 0
    },
    vrSessionMinutes: {
      type: Number,
      default: 0
    },
    lastActivity: {
      type: Date,
      default: Date.now
    }
  },
  // Subscription history
  previousTiers: [{
    tier: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SubscriptionTier'
    },
    startDate: Date,
    endDate: Date,
    reason: String
  }],
  // Promotional details
  promoCode: {
    type: String
  },
  discount: {
    amount: Number,
    percentage: Number,
    validUntil: Date
  },
  // Metadata
  metadata: {
    source: {
      type: String,
      default: 'web'
    },
    referrer: String,
    campaign: String,
    userAgent: String,
    ipAddress: String
  },
  // Auto-renewal settings
  autoRenew: {
    type: Boolean,
    default: true
  },
  // Pause/resume functionality
  pausedAt: {
    type: Date
  },
  pauseReason: {
    type: String
  },
  resumeAt: {
    type: Date
  },
  // Notifications
  notifications: {
    renewalReminder: {
      type: Boolean,
      default: true
    },
    paymentFailed: {
      type: Boolean,
      default: true
    },
    tierUpgrade: {
      type: Boolean,
      default: true
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for checking if subscription is active
userSubscriptionSchema.virtual('isActive').get(function() {
  return this.status === 'active' && 
         new Date() >= this.currentPeriodStart && 
         new Date() <= this.currentPeriodEnd;
});

// Virtual for checking if subscription is in trial
userSubscriptionSchema.virtual('isInTrial').get(function() {
  return this.status === 'trialing' && 
         this.trialEnd && 
         new Date() <= this.trialEnd;
});

// Virtual for days remaining in current period
userSubscriptionSchema.virtual('daysRemaining').get(function() {
  const now = new Date();
  const endDate = this.currentPeriodEnd;
  const diffTime = endDate - now;
  return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
});

// Virtual for subscription age in days
userSubscriptionSchema.virtual('subscriptionAge').get(function() {
  const now = new Date();
  const startDate = this.createdAt;
  const diffTime = now - startDate;
  return Math.floor(diffTime / (1000 * 60 * 60 * 24));
});

// Virtual for checking if payment is overdue
userSubscriptionSchema.virtual('isOverdue').get(function() {
  return this.status === 'past_due' || 
         (this.nextPaymentDate && new Date() > this.nextPaymentDate);
});

// Static method to find active subscription for user
userSubscriptionSchema.statics.findActiveForUser = function(userId) {
  return this.findOne({
    user: userId,
    status: 'active',
    currentPeriodStart: { $lte: new Date() },
    currentPeriodEnd: { $gte: new Date() }
  }).populate('subscriptionTier');
};

// Static method to find subscription by Stripe ID
userSubscriptionSchema.statics.findByStripeId = function(stripeSubscriptionId) {
  return this.findOne({ stripeSubscriptionId }).populate(['user', 'subscriptionTier']);
};

// Static method to get user's subscription history
userSubscriptionSchema.statics.getSubscriptionHistory = function(userId) {
  return this.find({ user: userId })
    .populate('subscriptionTier')
    .sort({ createdAt: -1 });
};

// Static method to get expiring subscriptions
userSubscriptionSchema.statics.getExpiringSubscriptions = function(days = 7) {
  const futureDate = new Date();
  futureDate.setDate(futureDate.getDate() + days);
  
  return this.find({
    status: 'active',
    currentPeriodEnd: { $lte: futureDate },
    cancelAtPeriodEnd: false,
    autoRenew: true
  }).populate(['user', 'subscriptionTier']);
};

// Static method to get failed payment subscriptions
userSubscriptionSchema.statics.getFailedPaymentSubscriptions = function() {
  return this.find({
    status: { $in: ['past_due', 'unpaid'] }
  }).populate(['user', 'subscriptionTier']);
};

// Instance method to check tier access
userSubscriptionSchema.methods.hasTierAccess = function(requiredLevel) {
  if (!this.isActive) return false;
  return this.subscriptionTier.level >= requiredLevel;
};

// Instance method to check feature access
userSubscriptionSchema.methods.hasFeatureAccess = function(featurePath) {
  if (!this.isActive) return false;
  
  const pathParts = featurePath.split('.');
  let current = this.subscriptionTier.features;
  
  for (const part of pathParts) {
    if (current[part] === undefined) return false;
    current = current[part];
  }
  
  return Boolean(current);
};

// Instance method to check stream access
userSubscriptionSchema.methods.hasStreamAccess = function(streamType) {
  return this.hasFeatureAccess(`streamAccess.${streamType}`);
};

// Instance method to check VR access
userSubscriptionSchema.methods.hasVrAccess = function(vrFeature = 'enabled') {
  return this.hasFeatureAccess(`vrAccess.${vrFeature}`);
};

// Instance method to get remaining tip credits
userSubscriptionSchema.methods.getRemainingTipCredits = function() {
  if (!this.isActive) return 0;
  
  const monthlyCredits = this.subscriptionTier.features.limits.monthlyTipCredits;
  const usedCredits = this.usage.tipsGiven || 0;
  
  // Reset usage if new billing period
  const now = new Date();
  const periodStart = this.currentPeriodStart;
  
  if (now.getMonth() !== periodStart.getMonth() || now.getFullYear() !== periodStart.getFullYear()) {
    return monthlyCredits;
  }
  
  return Math.max(0, monthlyCredits - usedCredits);
};

// Instance method to update usage
userSubscriptionSchema.methods.updateUsage = function(usageType, amount = 1) {
  if (!this.usage[usageType]) {
    this.usage[usageType] = 0;
  }
  this.usage[usageType] += amount;
  this.usage.lastActivity = new Date();
  return this.save();
};

// Instance method to cancel subscription
userSubscriptionSchema.methods.cancelSubscription = function(reason, immediate = false) {
  this.cancelAtPeriodEnd = !immediate;
  this.cancellationReason = reason;
  
  if (immediate) {
    this.status = 'canceled';
    this.canceledAt = new Date();
  }
  
  return this.save();
};

// Instance method to pause subscription
userSubscriptionSchema.methods.pauseSubscription = function(reason, resumeDate) {
  this.status = 'paused';
  this.pausedAt = new Date();
  this.pauseReason = reason;
  
  if (resumeDate) {
    this.resumeAt = resumeDate;
  }
  
  return this.save();
};

// Instance method to resume subscription
userSubscriptionSchema.methods.resumeSubscription = function() {
  this.status = 'active';
  this.pausedAt = null;
  this.pauseReason = null;
  this.resumeAt = null;
  
  return this.save();
};

// Instance method to upgrade/downgrade tier
userSubscriptionSchema.methods.changeTier = function(newTierId, reason = 'user_request') {
  // Add current tier to history
  this.previousTiers.push({
    tier: this.subscriptionTier,
    startDate: this.currentPeriodStart,
    endDate: new Date(),
    reason: reason
  });
  
  // Update to new tier
  this.subscriptionTier = newTierId;
  
  return this.save();
};

// Instance method to get subscription summary
userSubscriptionSchema.methods.getSummary = function() {
  return {
    id: this._id,
    tier: this.subscriptionTier,
    status: this.status,
    billingCycle: this.billingCycle,
    isActive: this.isActive,
    isInTrial: this.isInTrial,
    daysRemaining: this.daysRemaining,
    currentPeriodEnd: this.currentPeriodEnd,
    cancelAtPeriodEnd: this.cancelAtPeriodEnd,
    autoRenew: this.autoRenew,
    usage: this.usage
  };
};

// Pre-save middleware to update next payment date
userSubscriptionSchema.pre('save', function(next) {
  if (this.isModified('currentPeriodEnd') && this.status === 'active') {
    this.nextPaymentDate = this.currentPeriodEnd;
  }
  next();
});

// Post-save middleware to log tier changes
userSubscriptionSchema.post('save', function(doc) {
  if (this.isModified('subscriptionTier')) {
    console.log(`User ${doc.user} changed subscription tier to ${doc.subscriptionTier}`);
  }
});

// Indexes for efficient queries
userSubscriptionSchema.index({ user: 1, status: 1 });
userSubscriptionSchema.index({ stripeSubscriptionId: 1 }, { unique: true });
userSubscriptionSchema.index({ stripeCustomerId: 1 });
userSubscriptionSchema.index({ status: 1, currentPeriodEnd: 1 });
userSubscriptionSchema.index({ currentPeriodEnd: 1, cancelAtPeriodEnd: 1 });
userSubscriptionSchema.index({ 'usage.lastActivity': 1 });

const UserSubscription = mongoose.model('UserSubscription', userSubscriptionSchema);

module.exports = UserSubscription;
const mongoose = require('mongoose');
const { Schema } = mongoose;

// Tip schema for virtual wallet system
const tipSchema = new Schema({
  // Core tip information
  sender: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  recipient: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  amount: {
    type: Number,
    required: true,
    min: [0.01, 'Minimum tip amount is $0.01'],
    max: [10000, 'Maximum tip amount is $10,000']
  },
  platformFee: {
    type: Number,
    required: true,
    min: 0
  },
  recipientAmount: {
    type: Number,
    required: true,
    min: 0
  },
  
  // Message and interaction
  message: {
    type: String,
    maxlength: [500, 'Tip message cannot exceed 500 characters'],
    trim: true,
    default: ''
  },
  isAnonymous: {
    type: Boolean,
    default: false
  },
  
  // Stream context
  streamId: {
    type: Schema.Types.ObjectId,
    ref: 'Stream',
    index: true
  },
  
  // Visual effects and animations
  animation: {
    type: String,
    enum: ['none', 'sparkles', 'confetti', 'fireworks', 'hearts', 'stars'],
    default: 'none'
  },
  vrEffect: {
    type: String,
    enum: ['none', 'sparkles', 'confetti', 'spotlight', 'front-row', 'golden-shower'],
    default: 'none'
  },
  
  // Status and processing
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'completed',
    index: true
  },
  
  // Transaction tracking
  transactionId: {
    type: String,
    unique: true,
    sparse: true
  },
  
  // Tip goals and campaigns
  tipGoalId: {
    type: Schema.Types.ObjectId,
    ref: 'TipGoal'
  },
  
  // Metadata and analytics
  metadata: {
    senderTier: {
      type: String,
      enum: ['free', 'floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']
    },
    recipientTier: {
      type: String,
      enum: ['free', 'floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']
    },
    streamCategory: {
      type: String,
      enum: ['main-stage', 'backstage', 'vip-lounge', 'champagne-room', 'black-card-exclusive']
    },
    isVRStream: {
      type: Boolean,
      default: false
    },
    deviceType: {
      type: String,
      enum: ['web', 'mobile', 'vr', 'tablet']
    },
    location: {
      country: String,
      region: String,
      timezone: String
    },
    sessionId: String,
    userAgent: String
  },
  
  // Special tip types
  tipType: {
    type: String,
    enum: ['regular', 'rain', 'goal', 'menu-item', 'private-show', 'vr-experience'],
    default: 'regular'
  },
  
  // Menu item reference (for tip menu items)
  menuItemId: {
    type: Schema.Types.ObjectId,
    ref: 'TipMenuItem'
  },
  
  // Reactions and responses
  reactions: [{
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    type: {
      type: String,
      enum: ['like', 'love', 'wow', 'laugh', 'fire']
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  
  // Performer response
  performerResponse: {
    message: {
      type: String,
      maxlength: 500
    },
    mediaUrl: String, // Image/video response
    respondedAt: Date
  },
  
  // Moderation
  isHidden: {
    type: Boolean,
    default: false
  },
  hiddenReason: {
    type: String,
    enum: ['inappropriate', 'spam', 'harassment', 'other']
  },
  moderatedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  moderatedAt: Date,
  
  // Refund information
  refund: {
    reason: {
      type: String,
      enum: ['user-request', 'technical-issue', 'policy-violation', 'chargeback']
    },
    processedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    processedAt: Date,
    refundAmount: Number
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
tipSchema.index({ sender: 1, createdAt: -1 });
tipSchema.index({ recipient: 1, createdAt: -1 });
tipSchema.index({ streamId: 1, createdAt: -1 });
tipSchema.index({ amount: -1, createdAt: -1 });
tipSchema.index({ status: 1, createdAt: -1 });
tipSchema.index({ tipType: 1, createdAt: -1 });
tipSchema.index({ 'metadata.senderTier': 1, createdAt: -1 });
tipSchema.index({ 'metadata.streamCategory': 1, createdAt: -1 });

// Compound indexes for leaderboards and analytics
tipSchema.index({ recipient: 1, amount: -1, createdAt: -1 });
tipSchema.index({ sender: 1, amount: -1, createdAt: -1 });
tipSchema.index({ streamId: 1, amount: -1, createdAt: -1 });

// Virtual for display amount (formatted)
tipSchema.virtual('displayAmount').get(function() {
  return `$${this.amount.toFixed(2)}`;
});

// Virtual for display recipient amount
tipSchema.virtual('displayRecipientAmount').get(function() {
  return `$${this.recipientAmount.toFixed(2)}`;
});

// Virtual for platform fee percentage
tipSchema.virtual('platformFeePercentage').get(function() {
  return Math.round((this.platformFee / this.amount) * 100);
});

// Virtual for time since tip
tipSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  
  if (days > 0) return `${days}d ago`;
  if (hours > 0) return `${hours}h ago`;
  if (minutes > 0) return `${minutes}m ago`;
  return 'Just now';
});

// Instance methods

// Check if tip can be refunded
tipSchema.methods.canRefund = function() {
  const hoursSinceCreated = (new Date() - this.createdAt) / (1000 * 60 * 60);
  return this.status === 'completed' && 
         !this.refund && 
         hoursSinceCreated <= 24; // 24-hour refund window
};

// Process refund
tipSchema.methods.processRefund = async function(reason, processedBy) {
  if (!this.canRefund()) {
    throw new Error('Tip cannot be refunded');
  }
  
  this.status = 'refunded';
  this.refund = {
    reason,
    processedBy,
    processedAt: new Date(),
    refundAmount: this.amount
  };
  
  return this.save();
};

// Add reaction to tip
tipSchema.methods.addReaction = function(userId, reactionType) {
  // Remove existing reaction from this user
  this.reactions = this.reactions.filter(
    reaction => reaction.userId.toString() !== userId.toString()
  );
  
  // Add new reaction
  this.reactions.push({
    userId,
    type: reactionType,
    createdAt: new Date()
  });
  
  return this.save();
};

// Remove reaction
tipSchema.methods.removeReaction = function(userId) {
  this.reactions = this.reactions.filter(
    reaction => reaction.userId.toString() !== userId.toString()
  );
  
  return this.save();
};

// Add performer response
tipSchema.methods.addPerformerResponse = function(message, mediaUrl = null) {
  this.performerResponse = {
    message,
    mediaUrl,
    respondedAt: new Date()
  };
  
  return this.save();
};

// Hide tip (moderation)
tipSchema.methods.hide = function(reason, moderatorId) {
  this.isHidden = true;
  this.hiddenReason = reason;
  this.moderatedBy = moderatorId;
  this.moderatedAt = new Date();
  
  return this.save();
};

// Unhide tip
tipSchema.methods.unhide = function() {
  this.isHidden = false;
  this.hiddenReason = undefined;
  this.moderatedBy = undefined;
  this.moderatedAt = undefined;
  
  return this.save();
};

// Static methods

// Get leaderboard for a specific period
tipSchema.statics.getLeaderboard = function(period = 'weekly', category = 'tippers', limit = 10) {
  const now = new Date();
  let startDate;
  
  switch (period) {
    case 'daily':
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case 'weekly':
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case 'monthly':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    default:
      startDate = null; // all-time
  }
  
  const matchStage = {
    status: 'completed',
    ...(startDate && { createdAt: { $gte: startDate } })
  };
  
  if (category === 'tippers') {
    return this.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$sender',
          totalAmount: { $sum: '$amount' },
          tipCount: { $sum: 1 },
          lastTip: { $max: '$createdAt' }
        }
      },
      { $sort: { totalAmount: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user'
        }
      },
      { $unwind: '$user' }
    ]);
  } else if (category === 'receivers') {
    return this.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$recipient',
          totalAmount: { $sum: '$recipientAmount' },
          tipCount: { $sum: 1 },
          uniqueTippers: { $addToSet: '$sender' },
          lastTip: { $max: '$createdAt' }
        }
      },
      {
        $addFields: {
          uniqueTippersCount: { $size: '$uniqueTippers' }
        }
      },
      { $sort: { totalAmount: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user'
        }
      },
      { $unwind: '$user' }
    ]);
  }
};

// Get tip statistics
tipSchema.statics.getStats = function(period = 'weekly') {
  const now = new Date();
  let startDate;
  
  switch (period) {
    case 'daily':
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case 'weekly':
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case 'monthly':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    default:
      startDate = null; // all-time
  }
  
  const matchStage = {
    status: 'completed',
    ...(startDate && { createdAt: { $gte: startDate } })
  };
  
  return this.aggregate([
    { $match: matchStage },
    {
      $group: {
        _id: null,
        totalAmount: { $sum: '$amount' },
        totalRecipientAmount: { $sum: '$recipientAmount' },
        totalPlatformFees: { $sum: '$platformFee' },
        tipCount: { $sum: 1 },
        uniqueTippers: { $addToSet: '$sender' },
        uniqueReceivers: { $addToSet: '$recipient' },
        avgTipAmount: { $avg: '$amount' },
        maxTipAmount: { $max: '$amount' },
        minTipAmount: { $min: '$amount' }
      }
    },
    {
      $addFields: {
        uniqueTippersCount: { $size: '$uniqueTippers' },
        uniqueReceiversCount: { $size: '$uniqueReceivers' }
      }
    }
  ]);
};

// Get user's tip summary
tipSchema.statics.getUserTipSummary = function(userId, period = 'monthly') {
  const now = new Date();
  let startDate;
  
  switch (period) {
    case 'daily':
      startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
      break;
    case 'weekly':
      startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case 'monthly':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    default:
      startDate = null; // all-time
  }
  
  const matchStage = {
    status: 'completed',
    ...(startDate && { createdAt: { $gte: startDate } })
  };
  
  return Promise.all([
    // Tips sent
    this.aggregate([
      { $match: { ...matchStage, sender: userId } },
      {
        $group: {
          _id: null,
          totalSent: { $sum: '$amount' },
          tipsSentCount: { $sum: 1 },
          uniqueReceivers: { $addToSet: '$recipient' },
          avgTipSent: { $avg: '$amount' },
          maxTipSent: { $max: '$amount' }
        }
      }
    ]),
    // Tips received
    this.aggregate([
      { $match: { ...matchStage, recipient: userId } },
      {
        $group: {
          _id: null,
          totalReceived: { $sum: '$recipientAmount' },
          tipsReceivedCount: { $sum: 1 },
          uniqueSenders: { $addToSet: '$sender' },
          avgTipReceived: { $avg: '$recipientAmount' },
          maxTipReceived: { $max: '$recipientAmount' }
        }
      }
    ])
  ]);
};

// Pre-save middleware
tipSchema.pre('save', function(next) {
  // Generate transaction ID if not exists
  if (!this.transactionId) {
    this.transactionId = `tip_${this._id}_${Date.now()}`;
  }
  
  // Calculate recipient amount if not set
  if (!this.recipientAmount && this.amount && this.platformFee) {
    this.recipientAmount = this.amount - this.platformFee;
  }
  
  next();
});

// Post-save middleware for real-time updates
tipSchema.post('save', function(doc) {
  // Emit socket events for real-time updates
  if (doc.isNew) {
    // New tip created - notify relevant parties
    const socketService = require('../services/socketService');
    
    // Notify recipient
    socketService.notifyUser(doc.recipient, 'tip_received', {
      tipId: doc._id,
      amount: doc.amount,
      sender: doc.isAnonymous ? null : doc.sender,
      message: doc.message
    });
    
    // Notify stream viewers if applicable
    if (doc.streamId) {
      socketService.broadcastToStream(doc.streamId, 'tip_sent', {
        tipId: doc._id,
        amount: doc.amount,
        animation: doc.animation,
        vrEffect: doc.vrEffect,
        isAnonymous: doc.isAnonymous
      });
    }
  }
});

module.exports = mongoose.model('Tip', tipSchema);
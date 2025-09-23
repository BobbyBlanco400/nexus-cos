const Tip = require('../models/Tip');
const Wallet = require('../models/Wallet');
const User = require('../models/User');
const Stream = require('../models/Stream');
const UserSubscription = require('../models/UserSubscription');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');
const socketService = require('../services/socketService');
const stripeService = require('../services/stripeService');
const vrService = require('../services/vrService');
const analyticsService = require('../services/analyticsService');

// Quick tip presets by subscription tier
const QUICK_TIP_PRESETS = {
  'floor-pass': [1, 5, 10, 25],
  'backstage-pass': [1, 5, 10, 25, 50],
  'vip-lounge': [5, 10, 25, 50, 100],
  'champagne-room': [10, 25, 50, 100, 250],
  'black-card': [25, 50, 100, 250, 500, 1000]
};

// VR tip animations by tier
const VR_ANIMATIONS = {
  'vip-lounge': ['sparkles', 'confetti'],
  'champagne-room': ['sparkles', 'confetti', 'spotlight'],
  'black-card': ['sparkles', 'confetti', 'spotlight', 'front-row', 'golden-shower']
};

/**
 * Get tip leaderboard
 */
const getLeaderboard = async (req, res, next) => {
  try {
    const { 
      period = 'weekly', 
      category = 'tippers', 
      limit = 10 
    } = req.query;

    // Calculate date range
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

    let leaderboard = [];

    if (category === 'tippers') {
      // Top tippers leaderboard
      const pipeline = [
        ...(startDate ? [{ $match: { createdAt: { $gte: startDate } } }] : []),
        {
          $group: {
            _id: '$sender',
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            lastTip: { $max: '$createdAt' }
          }
        },
        { $sort: { totalAmount: -1 } },
        { $limit: parseInt(limit) },
        {
          $lookup: {
            from: 'users',
            localField: '_id',
            foreignField: '_id',
            as: 'user'
          }
        },
        { $unwind: '$user' },
        {
          $project: {
            userId: '$_id',
            username: '$user.username',
            displayName: '$user.displayName',
            avatar: '$user.avatar',
            isVerified: '$user.isVerified',
            totalAmount: 1,
            tipCount: 1,
            lastTip: 1
          }
        }
      ];

      leaderboard = await Tip.aggregate(pipeline);
    } else if (category === 'receivers') {
      // Top receivers leaderboard
      const pipeline = [
        ...(startDate ? [{ $match: { createdAt: { $gte: startDate } } }] : []),
        {
          $group: {
            _id: '$recipient',
            totalAmount: { $sum: '$amount' },
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
        { $limit: parseInt(limit) },
        {
          $lookup: {
            from: 'users',
            localField: '_id',
            foreignField: '_id',
            as: 'user'
          }
        },
        { $unwind: '$user' },
        {
          $project: {
            userId: '$_id',
            username: '$user.username',
            displayName: '$user.displayName',
            avatar: '$user.avatar',
            isVerified: '$user.isVerified',
            totalAmount: 1,
            tipCount: 1,
            uniqueTippersCount: 1,
            lastTip: 1
          }
        }
      ];

      leaderboard = await Tip.aggregate(pipeline);
    } else if (category === 'streams') {
      // Top streams by tips
      const pipeline = [
        { $match: { streamId: { $exists: true, $ne: null } } },
        ...(startDate ? [{ $match: { createdAt: { $gte: startDate } } }] : []),
        {
          $group: {
            _id: '$streamId',
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            uniqueTippers: { $addToSet: '$sender' }
          }
        },
        {
          $addFields: {
            uniqueTippersCount: { $size: '$uniqueTippers' }
          }
        },
        { $sort: { totalAmount: -1 } },
        { $limit: parseInt(limit) },
        {
          $lookup: {
            from: 'streams',
            localField: '_id',
            foreignField: '_id',
            as: 'stream'
          }
        },
        { $unwind: '$stream' },
        {
          $lookup: {
            from: 'users',
            localField: 'stream.performer',
            foreignField: '_id',
            as: 'performer'
          }
        },
        { $unwind: '$performer' },
        {
          $project: {
            streamId: '$_id',
            title: '$stream.title',
            category: '$stream.category',
            performer: {
              username: '$performer.username',
              displayName: '$performer.displayName',
              avatar: '$performer.avatar'
            },
            totalAmount: 1,
            tipCount: 1,
            uniqueTippersCount: 1
          }
        }
      ];

      leaderboard = await Tip.aggregate(pipeline);
    }

    res.status(200).json({
      success: true,
      data: {
        leaderboard,
        period,
        category,
        generatedAt: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get public tip statistics
 */
const getPublicStats = async (req, res, next) => {
  try {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const startOfWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
    const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [dailyStats, weeklyStats, monthlyStats, allTimeStats] = await Promise.all([
      Tip.aggregate([
        { $match: { createdAt: { $gte: startOfDay } } },
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            uniqueTippers: { $addToSet: '$sender' },
            uniqueReceivers: { $addToSet: '$recipient' }
          }
        }
      ]),
      Tip.aggregate([
        { $match: { createdAt: { $gte: startOfWeek } } },
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            uniqueTippers: { $addToSet: '$sender' },
            uniqueReceivers: { $addToSet: '$recipient' }
          }
        }
      ]),
      Tip.aggregate([
        { $match: { createdAt: { $gte: startOfMonth } } },
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            uniqueTippers: { $addToSet: '$sender' },
            uniqueReceivers: { $addToSet: '$recipient' }
          }
        }
      ]),
      Tip.aggregate([
        {
          $group: {
            _id: null,
            totalAmount: { $sum: '$amount' },
            tipCount: { $sum: 1 },
            uniqueTippers: { $addToSet: '$sender' },
            uniqueReceivers: { $addToSet: '$recipient' }
          }
        }
      ])
    ]);

    const formatStats = (stats) => {
      if (!stats || stats.length === 0) {
        return {
          totalAmount: 0,
          tipCount: 0,
          uniqueTippers: 0,
          uniqueReceivers: 0
        };
      }
      
      const stat = stats[0];
      return {
        totalAmount: stat.totalAmount || 0,
        tipCount: stat.tipCount || 0,
        uniqueTippers: stat.uniqueTippers ? stat.uniqueTippers.length : 0,
        uniqueReceivers: stat.uniqueReceivers ? stat.uniqueReceivers.length : 0
      };
    };

    res.status(200).json({
      success: true,
      data: {
        daily: formatStats(dailyStats),
        weekly: formatStats(weeklyStats),
        monthly: formatStats(monthlyStats),
        allTime: formatStats(allTimeStats),
        generatedAt: new Date()
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Send tip
 */
const sendTip = async (req, res, next) => {
  try {
    const {
      recipientId,
      amount,
      message = '',
      isAnonymous = false,
      streamId,
      animation = 'none',
      vrEffect = 'none'
    } = req.body;

    // Validate recipient
    const recipient = await User.findById(recipientId);
    if (!recipient) {
      throw new AppError('Recipient not found', 404);
    }

    // Prevent self-tipping
    if (recipientId === req.user.id) {
      throw new AppError('Cannot tip yourself', 400);
    }

    // Check if recipient accepts tips
    if (!recipient.acceptsTips) {
      throw new AppError('Recipient does not accept tips', 400);
    }

    // Get sender's wallet
    const senderWallet = await Wallet.findOne({ userId: req.user.id });
    if (!senderWallet) {
      throw new AppError('Wallet not found', 404);
    }

    // Check sufficient balance
    if (senderWallet.balance < amount) {
      throw new AppError('Insufficient wallet balance', 400);
    }

    // Validate stream if provided
    let stream = null;
    if (streamId) {
      stream = await Stream.findById(streamId);
      if (!stream) {
        throw new AppError('Stream not found', 404);
      }
      
      // Check if stream is live
      if (stream.status !== 'live') {
        throw new AppError('Can only tip during live streams', 400);
      }
      
      // Check if recipient is the stream performer
      if (stream.performer.toString() !== recipientId) {
        throw new AppError('Can only tip the stream performer', 400);
      }
    }

    // Check VR effect permissions
    if (vrEffect !== 'none') {
      const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
      if (!userSubscription || !['vip-lounge', 'champagne-room', 'black-card'].includes(userSubscription.subscriptionTier.slug)) {
        throw new AppError('VIP subscription required for VR effects', 403);
      }
      
      const allowedEffects = VR_ANIMATIONS[userSubscription.subscriptionTier.slug] || [];
      if (!allowedEffects.includes(vrEffect)) {
        throw new AppError('VR effect not available for your subscription tier', 403);
      }
    }

    // Calculate platform fee (5% for regular users, 3% for VIP+)
    const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
    const isVIP = userSubscription && ['vip-lounge', 'champagne-room', 'black-card'].includes(userSubscription.subscriptionTier.slug);
    const platformFeeRate = isVIP ? 0.03 : 0.05;
    const platformFee = Math.round(amount * platformFeeRate * 100) / 100;
    const recipientAmount = amount - platformFee;

    // Create tip record
    const tip = new Tip({
      sender: req.user.id,
      recipient: recipientId,
      amount,
      platformFee,
      recipientAmount,
      message,
      isAnonymous,
      streamId,
      animation,
      vrEffect,
      metadata: {
        senderTier: userSubscription ? userSubscription.subscriptionTier.slug : 'free',
        streamCategory: stream ? stream.category : null,
        isVRStream: stream ? stream.isVREnabled : false
      }
    });

    // Process transaction
    await Promise.all([
      // Deduct from sender's wallet
      Wallet.findOneAndUpdate(
        { userId: req.user.id },
        { 
          $inc: { balance: -amount },
          $push: {
            transactions: {
              type: 'tip-sent',
              amount: -amount,
              description: `Tip to ${isAnonymous ? 'Anonymous' : recipient.username}`,
              relatedTip: tip._id,
              createdAt: new Date()
            }
          }
        }
      ),
      
      // Add to recipient's wallet
      Wallet.findOneAndUpdate(
        { userId: recipientId },
        { 
          $inc: { balance: recipientAmount },
          $push: {
            transactions: {
              type: 'tip-received',
              amount: recipientAmount,
              description: `Tip from ${isAnonymous ? 'Anonymous' : req.user.username}`,
              relatedTip: tip._id,
              createdAt: new Date()
            }
          }
        },
        { upsert: true }
      ),
      
      // Save tip
      tip.save()
    ]);

    // Update stream analytics if applicable
    if (stream) {
      await stream.updateAnalytics({ tipAmount: amount });
    }

    // Populate tip data for response
    await tip.populate([
      { path: 'sender', select: 'username displayName avatar isVerified' },
      { path: 'recipient', select: 'username displayName avatar isVerified' }
    ]);

    // Real-time notifications
    const tipData = {
      tipId: tip._id,
      amount,
      message,
      isAnonymous,
      animation,
      vrEffect,
      sender: isAnonymous ? null : {
        id: req.user.id,
        username: req.user.username,
        displayName: req.user.displayName,
        avatar: req.user.avatar
      },
      timestamp: tip.createdAt
    };

    // Notify recipient
    socketService.notifyUser(recipientId, 'tip_received', tipData);

    // Notify stream viewers if applicable
    if (stream) {
      socketService.broadcastToStream(streamId, 'tip_sent', tipData);
      
      // Trigger VR effects if applicable
      if (vrEffect !== 'none' && stream.isVREnabled) {
        await vrService.triggerVREffect(streamId, vrEffect, {
          tipAmount: amount,
          senderId: req.user.id,
          duration: Math.min(amount * 2, 30) // Effect duration based on tip amount
        });
      }
    }

    logger.info(`Tip sent: ${amount} from ${req.user.id} to ${recipientId}`);

    res.status(201).json({
      success: true,
      data: {
        tip: {
          id: tip._id,
          amount: tip.amount,
          recipientAmount: tip.recipientAmount,
          platformFee: tip.platformFee,
          message: tip.message,
          isAnonymous: tip.isAnonymous,
          animation: tip.animation,
          vrEffect: tip.vrEffect,
          createdAt: tip.createdAt,
          sender: tip.sender,
          recipient: tip.recipient
        },
        walletBalance: senderWallet.balance - amount
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get sent tips
 */
const getSentTips = async (req, res, next) => {
  try {
    const {
      recipientId,
      streamId,
      page = 1,
      limit = 20
    } = req.query;

    const filter = { sender: req.user.id };
    
    if (recipientId) {
      filter.recipient = recipientId;
    }
    
    if (streamId) {
      filter.streamId = streamId;
    }

    const skip = (page - 1) * limit;
    
    const [tips, total] = await Promise.all([
      Tip.find(filter)
        .populate('recipient', 'username displayName avatar isVerified')
        .populate('streamId', 'title category')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Tip.countDocuments(filter)
    ]);

    res.status(200).json({
      success: true,
      data: {
        tips,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get received tips
 */
const getReceivedTips = async (req, res, next) => {
  try {
    const {
      senderId,
      streamId,
      page = 1,
      limit = 20
    } = req.query;

    const filter = { recipient: req.user.id };
    
    if (senderId) {
      filter.sender = senderId;
    }
    
    if (streamId) {
      filter.streamId = streamId;
    }

    const skip = (page - 1) * limit;
    
    const [tips, total] = await Promise.all([
      Tip.find(filter)
        .populate('sender', 'username displayName avatar isVerified')
        .populate('streamId', 'title category')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Tip.countDocuments(filter)
    ]);

    res.status(200).json({
      success: true,
      data: {
        tips,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get tip details
 */
const getTipDetails = async (req, res, next) => {
  try {
    const { tipId } = req.params;

    const tip = await Tip.findById(tipId)
      .populate('sender', 'username displayName avatar isVerified')
      .populate('recipient', 'username displayName avatar isVerified')
      .populate('streamId', 'title category performer')
      .lean();

    if (!tip) {
      throw new AppError('Tip not found', 404);
    }

    // Check if user has permission to view this tip
    if (tip.sender._id.toString() !== req.user.id && 
        tip.recipient._id.toString() !== req.user.id &&
        req.user.role !== 'admin') {
      throw new AppError('Not authorized to view this tip', 403);
    }

    res.status(200).json({
      success: true,
      data: {
        tip
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get quick tip presets
 */
const getQuickTipPresets = async (req, res, next) => {
  try {
    // Get user's subscription tier
    const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
    const tierSlug = userSubscription ? userSubscription.subscriptionTier.slug : 'floor-pass';
    
    // Get user's custom presets or use defaults
    const user = await User.findById(req.user.id).select('tipPresets');
    const presets = user.tipPresets && user.tipPresets.length > 0 
      ? user.tipPresets 
      : QUICK_TIP_PRESETS[tierSlug] || QUICK_TIP_PRESETS['floor-pass'];

    res.status(200).json({
      success: true,
      data: {
        presets,
        tier: tierSlug,
        isCustom: user.tipPresets && user.tipPresets.length > 0
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update quick tip presets
 */
const updateQuickTipPresets = async (req, res, next) => {
  try {
    const { presets } = req.body;

    // Validate presets
    const uniquePresets = [...new Set(presets)].sort((a, b) => a - b);
    
    if (uniquePresets.length !== presets.length) {
      throw new AppError('Duplicate preset amounts not allowed', 400);
    }

    // Update user's tip presets
    await User.findByIdAndUpdate(req.user.id, {
      tipPresets: uniquePresets
    });

    logger.info(`Tip presets updated for user ${req.user.id}`);

    res.status(200).json({
      success: true,
      data: {
        presets: uniquePresets
      }
    });
  } catch (error) {
    next(error);
  }
};

// Export all controller functions
module.exports = {
  getLeaderboard,
  getPublicStats,
  sendTip,
  getSentTips,
  getReceivedTips,
  getTipDetails,
  getQuickTipPresets,
  updateQuickTipPresets,
  
  // Additional functions would be implemented here:
  getCurrentTipGoals: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  createTipGoal: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  updateTipGoal: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  deleteTipGoal: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  sendVRTip: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getVRAnimations: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  createTipRain: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  addPremiumReaction: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getTipMenu: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  updateTipMenu: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getEarningsAnalytics: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getSpendingAnalytics: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getPlatformAnalytics: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getAllTransactions: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  refundTip: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  suspendUserFromTipping: async (req, res, next) => {
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  }
};
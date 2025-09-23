/**
 * Tipping Routes
 * Handles virtual wallet, tipping system, and performer payouts
 */

const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { authenticate, requireVerification } = require('../middleware/auth');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');
const User = require('../models/User');
const Wallet = require('../models/Wallet');
const Tip = require('../models/Tip');
const Stream = require('../models/Stream');

const router = express.Router();

// Tipping configuration
const TIPPING_CONFIG = {
  minTipAmount: parseFloat(process.env.MIN_TIP_AMOUNT) || 1,
  maxTipAmount: parseFloat(process.env.MAX_TIP_AMOUNT) || 1000,
  processingFeeRate: parseFloat(process.env.TIP_PROCESSING_FEE) || 0.029,
  performerPercentage: parseFloat(process.env.PERFORMER_PAYOUT_PERCENTAGE) || 0.70,
  platformPercentage: parseFloat(process.env.PLATFORM_FEE_PERCENTAGE) || 0.30
};

/**
 * GET /api/tipping/wallet
 * Get user's wallet information
 */
router.get('/wallet', authenticate, async (req, res, next) => {
  try {
    const wallet = await Wallet.findOne({ userId: req.user.id })
      .populate('userId', 'username displayName');

    if (!wallet) {
      return next(new AppError('Wallet not found', 404));
    }

    // Get recent transactions
    const recentTransactions = wallet.transactions
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, 10);

    // Get monthly spending
    const startOfMonth = new Date();
  startOfMonth.setDate(1);
  startOfMonth.setHours(0, 0, 0, 0);

    // Calculate monthly spending
    const monthlyTransactions = wallet.transactions.filter(t => 
      t.type === 'tip-sent' && t.createdAt >= startOfMonth
    );
    const monthlySpending = monthlyTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);

    res.json({
      success: true,
      data: {
        balance: wallet.balance,
        totalSpent: wallet.totalSpent,
        totalTipped: wallet.totalTipped,
        monthlySpending,
        recentTransactions,
        config: {
          minTipAmount: TIPPING_CONFIG.minTipAmount,
          maxTipAmount: TIPPING_CONFIG.maxTipAmount
        }
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/tipping/wallet/deposit
 * Add credits to wallet via Stripe
 */
router.post('/wallet/deposit', authenticate, requireVerification, async (req, res, next) => {
  try {
    const { amount } = req.body;

    if (!amount || amount < 5 || amount > 1000) {
      throw new AppError('Deposit amount must be between $5 and $1000', 400);
    }

    // Get or create Stripe customer
    let customer;
    const user = await User.findById(req.user.id)
      .select('stripeCustomerId email username');

    if (user.stripeCustomerId) {
      customer = await stripe.customers.retrieve(user.stripeCustomerId);
    } else {
      customer = await stripe.customers.create({
        email: user.email,
        name: user.username,
        metadata: {
          userId: req.user.id
        }
      });

      await User.findByIdAndUpdate(req.user.id, {
        stripeCustomerId: customer.id
      });
    }

  // Create payment intent
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(amount * 100), // Convert to cents
    currency: 'usd',
    customer: customer.id,
    metadata: {
      userId: req.user.id,
      type: 'wallet_deposit'
    },
    description: `Wallet deposit for ${user.username}`
  });

    // Get or create wallet
    let wallet = await Wallet.findOne({ userId: req.user.id });
    if (!wallet) {
      wallet = new Wallet({ userId: req.user.id });
      await wallet.save();
    }

    // Add pending transaction
    const transactionId = wallet.addTransaction({
      type: 'deposit',
      amount: amount,
      description: `Wallet deposit via Stripe`,
      stripePaymentId: paymentIntent.id,
      status: 'pending'
    });

    await wallet.save();

    logger.info('Wallet deposit initiated', {
      userId: req.user.id,
      amount,
      paymentIntentId: paymentIntent.id,
      transactionId
    });

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        transactionId,
        amount
      }
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/tipping/send
 * Send tip to performer
 */
router.post('/send', authenticate, requireVerification, async (req, res, next) => {
  try {
    const { performerId, amount, message, isAnonymous = false, streamId } = req.body;

    // Validate tip amount
    if (!amount || amount < TIPPING_CONFIG.minTipAmount || amount > TIPPING_CONFIG.maxTipAmount) {
      throw new AppError(
        `Tip amount must be between $${TIPPING_CONFIG.minTipAmount} and $${TIPPING_CONFIG.maxTipAmount}`,
        400
      );
    }

    // Check user wallet balance
    const wallet = await Wallet.findOne({ userId: req.user.id });
    if (!wallet || wallet.balance < amount) {
      throw new AppError('Insufficient wallet balance', 400);
    }

    // Verify performer exists
    const performer = await User.findById(performerId)
      .select('username displayName isOnline role');

    if (!performer || !['performer', 'admin'].includes(performer.role)) {
      throw new AppError('Performer not found', 404);
    }

    // Verify stream if provided
    if (streamId) {
      const stream = await Stream.findById(streamId)
        .select('performer status');

      if (!stream || stream.performer.toString() !== performerId) {
        throw new AppError('Invalid stream for this performer', 400);
      }

      if (stream.status !== 'live') {
        throw new AppError('Cannot tip on offline stream', 400);
      }
    }

  // Calculate fees and amounts
  const processingFee = amount * TIPPING_CONFIG.processingFeeRate;
  const netAmount = amount - processingFee;
  const performerAmount = netAmount * TIPPING_CONFIG.performerPercentage;
  const platformAmount = netAmount * TIPPING_CONFIG.platformPercentage;

  // Process tip in transaction
  const result = await prisma.$transaction(async (tx) => {
    // Deduct from user wallet
    await tx.user.update({
      where: { id: req.user.id },
      data: {
        walletBalance: { decrement: amount },
        totalTipped: { increment: amount }
      }
    });

    // Create wallet transaction for user
    await tx.walletTransaction.create({
      data: {
        userId: req.user.id,
        amount: -amount,
        type: 'TIP',
        description: `Tip to ${performer.stageName}${message ? `: ${message}` : ''}`,
        status: 'COMPLETED'
      }
    });

    // Add to performer earnings
    await tx.performer.update({
      where: { id: performerId },
      data: {
        totalEarnings: { increment: performerAmount },
        pendingPayout: { increment: performerAmount },
        totalTips: { increment: 1 }
      }
    });

    // Create tip record
    const tip = await tx.tip.create({
      data: {
        userId: req.user.id,
        performerId,
        streamId,
        amount,
        message,
        isAnonymous,
        processingFee,
        performerAmount,
        platformAmount,
        status: 'PROCESSED',
        processedAt: new Date()
      },
      include: {
        user: {
          select: {
            username: true,
            avatar: true
          }
        },
        performer: {
          select: {
            stageName: true
          }
        }
      }
    });

    return tip;
  });

  logger.logTip(result.id, req.user.id, performerId, amount, 'processed', {
    streamId,
    message: message ? 'with_message' : 'no_message',
    isAnonymous,
    performerAmount,
    platformAmount
  });

  res.json({
    success: true,
    message: 'Tip sent successfully',
    data: {
      tip: {
        id: result.id,
        amount: result.amount,
        message: result.message,
        isAnonymous: result.isAnonymous,
        createdAt: result.createdAt,
        performer: result.performer
      },
      newBalance: user.walletBalance - amount
    }
  });
}));

/**
 * GET /api/tipping/history
 * Get user's tipping history
 */
router.get('/history', authMiddleware, catchAsync(async (req, res) => {
  const { page = 1, limit = 20, performerId } = req.query;
  const skip = (page - 1) * limit;

  const whereClause = {
    userId: req.user.id,
    ...(performerId && { performerId })
  };

  const [tips, totalCount] = await Promise.all([
    prisma.tip.findMany({
      where: whereClause,
      include: {
        performer: {
          select: {
            stageName: true,
            avatar: true
          }
        },
        stream: {
          select: {
            title: true,
            streamType: true
          }
        }
      },
      orderBy: { createdAt: 'desc' },
      skip: parseInt(skip),
      take: parseInt(limit)
    }),
    prisma.tip.count({ where: whereClause })
  ]);

  res.json({
    success: true,
    data: {
      tips,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        totalCount,
        totalPages: Math.ceil(totalCount / limit)
      }
    }
  });
}));

/**
 * GET /api/tipping/leaderboard
 * Get tipping leaderboard
 */
router.get('/leaderboard', catchAsync(async (req, res) => {
  const { period = 'monthly', limit = 10 } = req.query;
  
  let startDate;
  switch (period) {
    case 'daily':
      startDate = new Date();
      startDate.setHours(0, 0, 0, 0);
      break;
    case 'weekly':
      startDate = new Date();
      startDate.setDate(startDate.getDate() - 7);
      break;
    case 'monthly':
      startDate = new Date();
      startDate.setDate(1);
      startDate.setHours(0, 0, 0, 0);
      break;
    default:
      startDate = null; // All time
  }

  const whereClause = startDate ? { createdAt: { gte: startDate } } : {};

  const topTippers = await prisma.tip.groupBy({
    by: ['userId'],
    where: whereClause,
    _sum: {
      amount: true
    },
    _count: {
      id: true
    },
    orderBy: {
      _sum: {
        amount: 'desc'
      }
    },
    take: parseInt(limit)
  });

  // Get user details for top tippers
  const userIds = topTippers.map(t => t.userId);
  const users = await prisma.user.findMany({
    where: { id: { in: userIds } },
    select: {
      id: true,
      username: true,
      avatar: true
    }
  });

  const leaderboard = topTippers.map((tipper, index) => {
    const user = users.find(u => u.id === tipper.userId);
    return {
      rank: index + 1,
      user,
      totalAmount: tipper._sum.amount,
      tipCount: tipper._count.id
    };
  });

  res.json({
    success: true,
    data: {
      leaderboard,
      period,
      generatedAt: new Date().toISOString()
    }
  });
}));

/**
 * GET /api/tipping/stats
 * Get tipping statistics
 */
router.get('/stats', authMiddleware, catchAsync(async (req, res) => {
  const startOfMonth = new Date();
  startOfMonth.setDate(1);
  startOfMonth.setHours(0, 0, 0, 0);

  const [userStats, monthlyStats, allTimeStats] = await Promise.all([
    // User's personal stats
    prisma.tip.aggregate({
      where: { userId: req.user.id },
      _sum: { amount: true },
      _count: true,
      _avg: { amount: true }
    }),
    // User's monthly stats
    prisma.tip.aggregate({
      where: {
        userId: req.user.id,
        createdAt: { gte: startOfMonth }
      },
      _sum: { amount: true },
      _count: true
    }),
    // Platform-wide stats
    prisma.tip.aggregate({
      _sum: { amount: true },
      _count: true,
      _avg: { amount: true }
    })
  ]);

  res.json({
    success: true,
    data: {
      user: {
        totalTipped: userStats._sum.amount || 0,
        totalTips: userStats._count,
        averageTip: userStats._avg.amount || 0,
        monthlyTipped: monthlyStats._sum.amount || 0,
        monthlyTips: monthlyStats._count
      },
      platform: {
        totalTipped: allTimeStats._sum.amount || 0,
        totalTips: allTimeStats._count,
        averageTip: allTimeStats._avg.amount || 0
      },
      config: TIPPING_CONFIG
    }
  });
}));

module.exports = router;
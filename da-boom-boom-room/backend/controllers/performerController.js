/**
 * Performer Controller
 * Handles performer management and streaming business logic
 */

const { PrismaClient } = require('@prisma/client');
const { catchAsync, AppError } = require('../middleware/errorHandler');
const { logger } = require('../utils/logger');
const bcrypt = require('bcryptjs');
const { validationResult } = require('express-validator');

const prisma = new PrismaClient();

/**
 * Get all performers with filtering and pagination
 */
const getPerformers = catchAsync(async (req, res) => {
  const {
    page = 1,
    limit = 20,
    category,
    isOnline,
    minRating,
    sortBy = 'rating',
    sortOrder = 'desc',
    search
  } = req.query;

  const skip = (page - 1) * limit;
  const where = {};

  // Apply filters
  if (category) where.category = category;
  if (isOnline !== undefined) where.isOnline = isOnline === 'true';
  if (minRating) where.rating = { gte: parseFloat(minRating) };
  if (search) {
    where.OR = [
      { username: { contains: search, mode: 'insensitive' } },
      { displayName: { contains: search, mode: 'insensitive' } },
      { bio: { contains: search, mode: 'insensitive' } }
    ];
  }

  // Build orderBy
  const orderBy = {};
  orderBy[sortBy] = sortOrder;

  const performers = await prisma.performer.findMany({
    where,
    select: {
      id: true,
      username: true,
      displayName: true,
      avatar: true,
      bio: true,
      category: true,
      isOnline: true,
      rating: true,
      totalEarnings: true,
      viewerCount: true,
      tags: true,
      createdAt: true,
      _count: {
        select: {
          streams: true,
          tips: true,
          favorites: true
        }
      }
    },
    orderBy,
    skip,
    take: parseInt(limit)
  });

  const total = await prisma.performer.count({ where });

  res.json({
    success: true,
    data: {
      performers,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    }
  });
});

/**
 * Get performer by ID
 */
const getPerformerById = catchAsync(async (req, res) => {
  const { performerId } = req.params;
  const userId = req.user?.id;

  const performer = await prisma.performer.findUnique({
    where: { id: performerId },
    include: {
      _count: {
        select: {
          streams: true,
          tips: true,
          favorites: true
        }
      }
    }
  });

  if (!performer) {
    throw new AppError('Performer not found', 404);
  }

  // Check if user has favorited this performer
  let isFavorited = false;
  if (userId) {
    const favorite = await prisma.favoritePerformer.findUnique({
      where: {
        userId_performerId: {
          userId,
          performerId
        }
      }
    });
    isFavorited = !!favorite;
  }

  // Get recent streams
  const recentStreams = await prisma.stream.findMany({
    where: { performerId },
    orderBy: { createdAt: 'desc' },
    take: 5,
    select: {
      id: true,
      title: true,
      type: true,
      category: true,
      thumbnail: true,
      isActive: true,
      viewerCount: true,
      createdAt: true
    }
  });

  res.json({
    success: true,
    data: {
      performer: {
        ...performer,
        isFavorited,
        recentStreams
      }
    }
  });
});

/**
 * Get performer statistics (for performer dashboard)
 */
const getPerformerStats = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const performer = await prisma.performer.findUnique({
    where: { id: performerId },
    select: {
      totalEarnings: true,
      rating: true,
      viewerCount: true,
      _count: {
        select: {
          streams: true,
          tips: true,
          favorites: true
        }
      }
    }
  });

  // Get earnings by month (last 12 months)
  const twelveMonthsAgo = new Date();
  twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

  const monthlyEarnings = await prisma.tip.groupBy({
    by: ['createdAt'],
    where: {
      performerId,
      createdAt: {
        gte: twelveMonthsAgo
      }
    },
    _sum: {
      amount: true
    }
  });

  // Get recent tips
  const recentTips = await prisma.tip.findMany({
    where: { performerId },
    include: {
      user: {
        select: {
          username: true,
          subscriptionTier: true
        }
      }
    },
    orderBy: { createdAt: 'desc' },
    take: 10
  });

  // Get top tippers
  const topTippers = await prisma.tip.groupBy({
    by: ['userId'],
    where: { performerId },
    _sum: {
      amount: true
    },
    _count: {
      amount: true
    },
    orderBy: {
      _sum: {
        amount: 'desc'
      }
    },
    take: 10
  });

  // Get user details for top tippers
  const topTipperDetails = await Promise.all(
    topTippers.map(async (tipper) => {
      const user = await prisma.user.findUnique({
        where: { id: tipper.userId },
        select: {
          username: true,
          subscriptionTier: true
        }
      });
      return {
        ...user,
        totalTipped: tipper._sum.amount,
        tipCount: tipper._count.amount
      };
    })
  );

  res.json({
    success: true,
    data: {
      stats: performer,
      monthlyEarnings,
      recentTips,
      topTippers: topTipperDetails
    }
  });
});

/**
 * Update performer profile
 */
const updatePerformerProfile = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const {
    displayName,
    bio,
    category,
    tags,
    avatar,
    socialLinks
  } = req.body;

  const updateData = {};
  if (displayName !== undefined) updateData.displayName = displayName;
  if (bio !== undefined) updateData.bio = bio;
  if (category !== undefined) updateData.category = category;
  if (tags !== undefined) updateData.tags = tags;
  if (avatar !== undefined) updateData.avatar = avatar;
  if (socialLinks !== undefined) updateData.socialLinks = socialLinks;

  const updatedPerformer = await prisma.performer.update({
    where: { id: performerId },
    data: updateData,
    select: {
      id: true,
      username: true,
      displayName: true,
      bio: true,
      category: true,
      tags: true,
      avatar: true,
      socialLinks: true,
      updatedAt: true
    }
  });

  logger.logPerformer('profile_updated', performerId, {
    changes: Object.keys(updateData)
  });

  res.json({
    success: true,
    message: 'Profile updated successfully',
    data: { performer: updatedPerformer }
  });
});

/**
 * Set performer online/offline status
 */
const setOnlineStatus = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;
  const { isOnline } = req.body;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const performer = await prisma.performer.update({
    where: { id: performerId },
    data: {
      isOnline,
      lastSeen: isOnline ? new Date() : undefined
    },
    select: {
      id: true,
      username: true,
      isOnline: true,
      lastSeen: true
    }
  });

  logger.logPerformer('status_change', performerId, {
    isOnline,
    timestamp: new Date()
  });

  res.json({
    success: true,
    message: `Status updated to ${isOnline ? 'online' : 'offline'}`,
    data: { performer }
  });
});

/**
 * Get performer's streams
 */
const getPerformerStreams = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;
  const {
    page = 1,
    limit = 20,
    status = 'all'
  } = req.query;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const skip = (page - 1) * limit;
  const where = { performerId };

  if (status === 'active') where.isActive = true;
  if (status === 'ended') where.isActive = false;

  const streams = await prisma.stream.findMany({
    where,
    include: {
      _count: {
        select: {
          views: true,
          tips: true
        }
      }
    },
    orderBy: { createdAt: 'desc' },
    skip,
    take: parseInt(limit)
  });

  const total = await prisma.stream.count({ where });

  res.json({
    success: true,
    data: {
      streams,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    }
  });
});

/**
 * Create new stream
 */
const createStream = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;
  const {
    title,
    description,
    type,
    category,
    requiredTier,
    isPrivate,
    maxViewers,
    tags
  } = req.body;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  // Check if performer already has an active stream
  const activeStream = await prisma.stream.findFirst({
    where: {
      performerId,
      isActive: true
    }
  });

  if (activeStream) {
    throw new AppError('You already have an active stream', 409);
  }

  const stream = await prisma.stream.create({
    data: {
      performerId,
      title,
      description,
      type: type || 'LIVE',
      category,
      requiredTier: requiredTier || 'FLOOR_PASS',
      isPrivate: isPrivate || false,
      maxViewers: maxViewers || 1000,
      tags: tags || [],
      isActive: true,
      startedAt: new Date()
    },
    include: {
      performer: {
        select: {
          username: true,
          displayName: true,
          avatar: true
        }
      }
    }
  });

  // Set performer as online
  await prisma.performer.update({
    where: { id: performerId },
    data: { isOnline: true }
  });

  logger.logStream('stream_started', stream.id, {
    performerId,
    title,
    type,
    category
  });

  res.status(201).json({
    success: true,
    message: 'Stream created successfully',
    data: { stream }
  });
});

/**
 * End stream
 */
const endStream = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;
  const { streamId } = req.params;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const stream = await prisma.stream.findFirst({
    where: {
      id: streamId,
      performerId,
      isActive: true
    }
  });

  if (!stream) {
    throw new AppError('Active stream not found', 404);
  }

  const updatedStream = await prisma.stream.update({
    where: { id: streamId },
    data: {
      isActive: false,
      endedAt: new Date(),
      viewerCount: 0
    }
  });

  logger.logStream('stream_ended', streamId, {
    performerId,
    duration: new Date() - stream.startedAt
  });

  res.json({
    success: true,
    message: 'Stream ended successfully',
    data: { stream: updatedStream }
  });
});

/**
 * Get performer earnings
 */
const getPerformerEarnings = catchAsync(async (req, res) => {
  const performerId = req.user.performerId;
  const {
    startDate,
    endDate,
    groupBy = 'day'
  } = req.query;

  if (!performerId) {
    throw new AppError('Not authorized as performer', 403);
  }

  const where = { performerId };
  if (startDate) where.createdAt = { gte: new Date(startDate) };
  if (endDate) {
    where.createdAt = {
      ...where.createdAt,
      lte: new Date(endDate)
    };
  }

  // Get total earnings
  const totalEarnings = await prisma.tip.aggregate({
    where,
    _sum: {
      amount: true
    },
    _count: {
      amount: true
    }
  });

  // Get earnings grouped by time period
  const earnings = await prisma.tip.findMany({
    where,
    select: {
      amount: true,
      createdAt: true,
      user: {
        select: {
          username: true,
          subscriptionTier: true
        }
      }
    },
    orderBy: { createdAt: 'desc' }
  });

  res.json({
    success: true,
    data: {
      totalEarnings: totalEarnings._sum.amount || 0,
      totalTips: totalEarnings._count.amount || 0,
      earnings
    }
  });
});

module.exports = {
  getPerformers,
  getPerformerById,
  getPerformerStats,
  updatePerformerProfile,
  setOnlineStatus,
  getPerformerStreams,
  createStream,
  endStream,
  getPerformerEarnings
};
/**
 * User Controller
 * Handles user management business logic
 */

const { PrismaClient } = require('@prisma/client');
const { catchAsync, AppError } = require('../middleware/errorHandler');
const { logger } = require('../utils/logger');
const bcrypt = require('bcryptjs');
const { validationResult } = require('express-validator');

const prisma = new PrismaClient();

/**
 * Get user statistics
 */
const getUserStats = catchAsync(async (req, res) => {
  const userId = req.user.id;

  const stats = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      walletBalance: true,
      totalSpent: true,
      totalTipped: true,
      subscriptionTier: true,
      subscriptionStatus: true,
      subscriptionStart: true,
      subscriptionEnd: true,
      createdAt: true,
      _count: {
        select: {
          tips: true,
          walletTransactions: true,
          streamViews: true
        }
      }
    }
  });

  // Get recent activity
  const recentTips = await prisma.tip.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: 5,
    include: {
      performer: {
        select: {
          username: true,
          displayName: true
        }
      }
    }
  });

  const recentTransactions = await prisma.walletTransaction.findMany({
    where: { userId },
    orderBy: { createdAt: 'desc' },
    take: 5
  });

  res.json({
    success: true,
    data: {
      stats,
      recentActivity: {
        tips: recentTips,
        transactions: recentTransactions
      }
    }
  });
});

/**
 * Get user preferences
 */
const getUserPreferences = catchAsync(async (req, res) => {
  const userId = req.user.id;

  const preferences = await prisma.userPreference.findUnique({
    where: { userId }
  });

  res.json({
    success: true,
    data: { preferences }
  });
});

/**
 * Update user preferences
 */
const updateUserPreferences = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const {
    notifications,
    autoRenewSubscription,
    preferredStreamQuality,
    vrEnabled,
    darkMode,
    language
  } = req.body;

  const preferences = await prisma.userPreference.upsert({
    where: { userId },
    update: {
      notifications,
      autoRenewSubscription,
      preferredStreamQuality,
      vrEnabled,
      darkMode,
      language
    },
    create: {
      userId,
      notifications: notifications || true,
      autoRenewSubscription: autoRenewSubscription || false,
      preferredStreamQuality: preferredStreamQuality || 'HD',
      vrEnabled: vrEnabled || false,
      darkMode: darkMode || true,
      language: language || 'en'
    }
  });

  res.json({
    success: true,
    message: 'Preferences updated successfully',
    data: { preferences }
  });
});

/**
 * Get user's favorite performers
 */
const getFavoritePerformers = catchAsync(async (req, res) => {
  const userId = req.user.id;

  const favorites = await prisma.favoritePerformer.findMany({
    where: { userId },
    include: {
      performer: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatar: true,
          isOnline: true,
          category: true,
          rating: true,
          totalEarnings: true
        }
      }
    },
    orderBy: { createdAt: 'desc' }
  });

  res.json({
    success: true,
    data: { favorites }
  });
});

/**
 * Add performer to favorites
 */
const addFavoritePerformer = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { performerId } = req.params;

  // Check if performer exists
  const performer = await prisma.performer.findUnique({
    where: { id: performerId }
  });

  if (!performer) {
    throw new AppError('Performer not found', 404);
  }

  // Check if already favorited
  const existingFavorite = await prisma.favoritePerformer.findUnique({
    where: {
      userId_performerId: {
        userId,
        performerId
      }
    }
  });

  if (existingFavorite) {
    throw new AppError('Performer already in favorites', 409);
  }

  const favorite = await prisma.favoritePerformer.create({
    data: {
      userId,
      performerId
    },
    include: {
      performer: {
        select: {
          id: true,
          username: true,
          displayName: true,
          avatar: true
        }
      }
    }
  });

  res.status(201).json({
    success: true,
    message: 'Performer added to favorites',
    data: { favorite }
  });
});

/**
 * Remove performer from favorites
 */
const removeFavoritePerformer = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { performerId } = req.params;

  const favorite = await prisma.favoritePerformer.findUnique({
    where: {
      userId_performerId: {
        userId,
        performerId
      }
    }
  });

  if (!favorite) {
    throw new AppError('Favorite not found', 404);
  }

  await prisma.favoritePerformer.delete({
    where: {
      userId_performerId: {
        userId,
        performerId
      }
    }
  });

  res.json({
    success: true,
    message: 'Performer removed from favorites'
  });
});

/**
 * Get user's viewing history
 */
const getViewingHistory = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { page = 1, limit = 20 } = req.query;
  const skip = (page - 1) * limit;

  const history = await prisma.streamView.findMany({
    where: { userId },
    include: {
      stream: {
        select: {
          id: true,
          title: true,
          type: true,
          category: true,
          thumbnail: true,
          performer: {
            select: {
              username: true,
              displayName: true,
              avatar: true
            }
          }
        }
      }
    },
    orderBy: { viewedAt: 'desc' },
    skip,
    take: parseInt(limit)
  });

  const total = await prisma.streamView.count({
    where: { userId }
  });

  res.json({
    success: true,
    data: {
      history,
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
 * Clear viewing history
 */
const clearViewingHistory = catchAsync(async (req, res) => {
  const userId = req.user.id;

  await prisma.streamView.deleteMany({
    where: { userId }
  });

  res.json({
    success: true,
    message: 'Viewing history cleared successfully'
  });
});

/**
 * Get user's tip leaderboard position
 */
const getTipLeaderboardPosition = catchAsync(async (req, res) => {
  const userId = req.user.id;

  // Get user's total tips
  const userStats = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      totalTipped: true,
      username: true
    }
  });

  // Get user's rank
  const usersWithMoreTips = await prisma.user.count({
    where: {
      totalTipped: {
        gt: userStats.totalTipped
      }
    }
  });

  const rank = usersWithMoreTips + 1;

  // Get top 10 leaderboard
  const topTippers = await prisma.user.findMany({
    where: {
      totalTipped: {
        gt: 0
      }
    },
    select: {
      id: true,
      username: true,
      totalTipped: true,
      subscriptionTier: true
    },
    orderBy: {
      totalTipped: 'desc'
    },
    take: 10
  });

  res.json({
    success: true,
    data: {
      userPosition: {
        rank,
        totalTipped: userStats.totalTipped,
        username: userStats.username
      },
      leaderboard: topTippers
    }
  });
});

/**
 * Deactivate user account
 */
const deactivateAccount = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { password } = req.body;

  if (!password) {
    throw new AppError('Password is required to deactivate account', 400);
  }

  // Verify password
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { password: true }
  });

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    throw new AppError('Invalid password', 400);
  }

  // Deactivate account
  await prisma.user.update({
    where: { id: userId },
    data: {
      isActive: false,
      deactivatedAt: new Date()
    }
  });

  logger.logAuth('account_deactivated', userId, true);

  res.json({
    success: true,
    message: 'Account deactivated successfully'
  });
});

/**
 * Get user notifications
 */
const getNotifications = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { page = 1, limit = 20, unreadOnly = false } = req.query;
  const skip = (page - 1) * limit;

  const where = { userId };
  if (unreadOnly === 'true') {
    where.isRead = false;
  }

  const notifications = await prisma.notification.findMany({
    where,
    orderBy: { createdAt: 'desc' },
    skip,
    take: parseInt(limit)
  });

  const total = await prisma.notification.count({ where });
  const unreadCount = await prisma.notification.count({
    where: { userId, isRead: false }
  });

  res.json({
    success: true,
    data: {
      notifications,
      unreadCount,
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
 * Mark notifications as read
 */
const markNotificationsRead = catchAsync(async (req, res) => {
  const userId = req.user.id;
  const { notificationIds } = req.body;

  if (notificationIds && notificationIds.length > 0) {
    // Mark specific notifications as read
    await prisma.notification.updateMany({
      where: {
        id: { in: notificationIds },
        userId
      },
      data: { isRead: true }
    });
  } else {
    // Mark all notifications as read
    await prisma.notification.updateMany({
      where: { userId },
      data: { isRead: true }
    });
  }

  res.json({
    success: true,
    message: 'Notifications marked as read'
  });
});

module.exports = {
  getUserStats,
  getUserPreferences,
  updateUserPreferences,
  getFavoritePerformers,
  addFavoritePerformer,
  removeFavoritePerformer,
  getViewingHistory,
  clearViewingHistory,
  getTipLeaderboardPosition,
  deactivateAccount,
  getNotifications,
  markNotificationsRead
};
/**
 * Streaming Routes
 * Handles live streaming, VR integration, and tier-based access control
 */

const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware, requireSubscriptionTier, checkStreamAccess, optionalAuth } = require('../middleware/auth');
const { catchAsync, AppError } = require('../middleware/errorHandler');
const { logger } = require('../utils/logger');

const router = express.Router();
const prisma = new PrismaClient();

// Stream type configurations
const STREAM_CONFIGS = {
  MAIN_STAGE: {
    name: 'Main Stage',
    requiredTier: 'FLOOR_PASS',
    maxViewers: 500,
    vrEnabled: false,
    description: 'Main stage performances for all members'
  },
  BACKSTAGE: {
    name: 'Backstage',
    requiredTier: 'BACKSTAGE_PASS',
    maxViewers: 200,
    vrEnabled: true,
    description: 'Exclusive backstage content and behind-the-scenes'
  },
  VIP_LOUNGE: {
    name: 'VIP Lounge',
    requiredTier: 'VIP_LOUNGE',
    maxViewers: 100,
    vrEnabled: true,
    description: 'Premium VIP experiences with enhanced interaction'
  },
  CHAMPAGNE_ROOM: {
    name: 'Champagne Room',
    requiredTier: 'CHAMPAGNE_ROOM',
    maxViewers: 50,
    vrEnabled: true,
    description: 'Ultra-premium intimate experiences'
  },
  PRIVATE: {
    name: 'Private Show',
    requiredTier: 'BLACK_CARD',
    maxViewers: 1,
    vrEnabled: true,
    description: 'Exclusive one-on-one private performances'
  }
};

/**
 * GET /api/streaming/streams
 * Get all available streams with user access info
 */
router.get('/streams', optionalAuth, catchAsync(async (req, res) => {
  const { type, isLive } = req.query;
  
  const whereClause = {
    ...(type && { streamType: type }),
    ...(isLive !== undefined && { isLive: isLive === 'true' })
  };

  const streams = await prisma.stream.findMany({
    where: whereClause,
    include: {
      performer: {
        select: {
          id: true,
          stageName: true,
          avatar: true,
          isOnline: true,
          totalViews: true,
          averageRating: true
        }
      },
      _count: {
        select: {
          views: true,
          tips: true
        }
      }
    },
    orderBy: [
      { isLive: 'desc' },
      { viewerCount: 'desc' },
      { createdAt: 'desc' }
    ]
  });

  // Add access information for authenticated users
  const streamsWithAccess = streams.map(stream => {
    const config = STREAM_CONFIGS[stream.streamType];
    const userTier = req.user?.subscriptionTier || 'NONE';
    
    // Check tier access
    const tierHierarchy = {
      'NONE': 0,
      'FLOOR_PASS': 1,
      'BACKSTAGE_PASS': 2,
      'VIP_LOUNGE': 3,
      'CHAMPAGNE_ROOM': 4,
      'BLACK_CARD': 5
    };
    
    const userTierLevel = tierHierarchy[userTier] || 0;
    const requiredTierLevel = tierHierarchy[config.requiredTier] || 0;
    const hasAccess = userTierLevel >= requiredTierLevel && 
                     req.user?.subscriptionStatus === 'ACTIVE';

    return {
      ...stream,
      config,
      access: {
        hasAccess,
        requiredTier: config.requiredTier,
        userTier,
        isSubscriptionActive: req.user?.subscriptionStatus === 'ACTIVE'
      }
    };
  });

  res.json({
    success: true,
    data: {
      streams: streamsWithAccess,
      totalCount: streams.length,
      liveCount: streams.filter(s => s.isLive).length
    }
  });
}));

/**
 * GET /api/streaming/streams/:streamId
 * Get specific stream details
 */
router.get('/streams/:streamId', optionalAuth, catchAsync(async (req, res) => {
  const { streamId } = req.params;

  const stream = await prisma.stream.findUnique({
    where: { id: streamId },
    include: {
      performer: {
        select: {
          id: true,
          stageName: true,
          bio: true,
          avatar: true,
          coverImage: true,
          isOnline: true,
          totalViews: true,
          totalTips: true,
          averageRating: true
        }
      },
      _count: {
        select: {
          views: true,
          tips: true
        }
      }
    }
  });

  if (!stream) {
    throw new AppError('Stream not found', 404);
  }

  const config = STREAM_CONFIGS[stream.streamType];
  const userTier = req.user?.subscriptionTier || 'NONE';
  
  // Check access
  const tierHierarchy = {
    'NONE': 0,
    'FLOOR_PASS': 1,
    'BACKSTAGE_PASS': 2,
    'VIP_LOUNGE': 3,
    'CHAMPAGNE_ROOM': 4,
    'BLACK_CARD': 5
  };
  
  const userTierLevel = tierHierarchy[userTier] || 0;
  const requiredTierLevel = tierHierarchy[config.requiredTier] || 0;
  const hasAccess = userTierLevel >= requiredTierLevel && 
                   req.user?.subscriptionStatus === 'ACTIVE';

  res.json({
    success: true,
    data: {
      ...stream,
      config,
      access: {
        hasAccess,
        requiredTier: config.requiredTier,
        userTier,
        isSubscriptionActive: req.user?.subscriptionStatus === 'ACTIVE'
      }
    }
  });
}));

/**
 * POST /api/streaming/streams/:streamId/join
 * Join a stream (with access control)
 */
router.post('/streams/:streamId/join', authMiddleware, checkStreamAccess, catchAsync(async (req, res) => {
  const { streamId } = req.params;
  const { vrMode = false } = req.body;

  const stream = req.stream; // Set by checkStreamAccess middleware
  const config = STREAM_CONFIGS[stream.streamType];

  // Check VR access
  if (vrMode && !config.vrEnabled) {
    throw new AppError('VR mode not available for this stream type', 400);
  }

  // Check viewer limit
  if (stream.viewerCount >= config.maxViewers) {
    throw new AppError('Stream is at maximum capacity', 429);
  }

  // Check if user is already viewing
  const existingView = await prisma.streamView.findUnique({
    where: {
      userId_streamId: {
        userId: req.user.id,
        streamId: streamId
      }
    }
  });

  if (existingView && !existingView.leftAt) {
    return res.json({
      success: true,
      message: 'Already viewing this stream',
      data: {
        streamUrl: stream.streamUrl,
        vrMode: vrMode && config.vrEnabled,
        joinedAt: existingView.joinedAt
      }
    });
  }

  // Create or update stream view
  const streamView = await prisma.streamView.upsert({
    where: {
      userId_streamId: {
        userId: req.user.id,
        streamId: streamId
      }
    },
    update: {
      joinedAt: new Date(),
      leftAt: null
    },
    create: {
      userId: req.user.id,
      streamId: streamId,
      joinedAt: new Date()
    }
  });

  // Update stream viewer count
  await prisma.stream.update({
    where: { id: streamId },
    data: {
      viewerCount: { increment: 1 },
      totalViews: { increment: existingView ? 0 : 1 }
    }
  });

  logger.logStream('join', streamId, req.user.id, {
    streamType: stream.streamType,
    vrMode,
    viewerCount: stream.viewerCount + 1
  });

  res.json({
    success: true,
    message: 'Successfully joined stream',
    data: {
      streamUrl: stream.streamUrl,
      vrMode: vrMode && config.vrEnabled,
      joinedAt: streamView.joinedAt,
      viewerCount: stream.viewerCount + 1
    }
  });
}));

/**
 * POST /api/streaming/streams/:streamId/leave
 * Leave a stream
 */
router.post('/streams/:streamId/leave', authMiddleware, catchAsync(async (req, res) => {
  const { streamId } = req.params;

  const streamView = await prisma.streamView.findUnique({
    where: {
      userId_streamId: {
        userId: req.user.id,
        streamId: streamId
      }
    }
  });

  if (!streamView || streamView.leftAt) {
    throw new AppError('Not currently viewing this stream', 400);
  }

  const leftAt = new Date();
  const duration = Math.floor((leftAt - streamView.joinedAt) / 1000); // in seconds

  // Update stream view
  await prisma.streamView.update({
    where: {
      userId_streamId: {
        userId: req.user.id,
        streamId: streamId
      }
    },
    data: {
      leftAt,
      duration
    }
  });

  // Update stream viewer count
  await prisma.stream.update({
    where: { id: streamId },
    data: {
      viewerCount: { decrement: 1 }
    }
  });

  logger.logStream('leave', streamId, req.user.id, {
    duration,
    leftAt
  });

  res.json({
    success: true,
    message: 'Successfully left stream',
    data: {
      duration,
      leftAt
    }
  });
}));

/**
 * GET /api/streaming/vr-streams
 * Get VR-enabled streams
 */
router.get('/vr-streams', authMiddleware, requireSubscriptionTier('VIP_LOUNGE'), catchAsync(async (req, res) => {
  const vrStreams = await prisma.stream.findMany({
    where: {
      isVREnabled: true,
      isLive: true
    },
    include: {
      performer: {
        select: {
          id: true,
          stageName: true,
          avatar: true,
          isOnline: true
        }
      }
    },
    orderBy: {
      viewerCount: 'desc'
    }
  });

  res.json({
    success: true,
    data: {
      streams: vrStreams,
      vrEnabled: process.env.VR_ENABLED === 'true'
    }
  });
}));

/**
 * GET /api/streaming/my-views
 * Get user's viewing history
 */
router.get('/my-views', authMiddleware, catchAsync(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const skip = (page - 1) * limit;

  const [views, totalCount] = await Promise.all([
    prisma.streamView.findMany({
      where: { userId: req.user.id },
      include: {
        stream: {
          include: {
            performer: {
              select: {
                stageName: true,
                avatar: true
              }
            }
          }
        }
      },
      orderBy: { joinedAt: 'desc' },
      skip: parseInt(skip),
      take: parseInt(limit)
    }),
    prisma.streamView.count({
      where: { userId: req.user.id }
    })
  ]);

  res.json({
    success: true,
    data: {
      views,
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
 * GET /api/streaming/stats
 * Get streaming statistics
 */
router.get('/stats', catchAsync(async (req, res) => {
  const [totalStreams, liveStreams, totalViewers, vrStreams] = await Promise.all([
    prisma.stream.count(),
    prisma.stream.count({ where: { isLive: true } }),
    prisma.stream.aggregate({
      where: { isLive: true },
      _sum: { viewerCount: true }
    }),
    prisma.stream.count({ where: { isVREnabled: true, isLive: true } })
  ]);

  res.json({
    success: true,
    data: {
      totalStreams,
      liveStreams,
      totalViewers: totalViewers._sum.viewerCount || 0,
      vrStreams,
      streamTypes: Object.keys(STREAM_CONFIGS)
    }
  });
}));

module.exports = router;
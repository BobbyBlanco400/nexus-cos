const Stream = require('../models/Stream');
const User = require('../models/User');
const UserSubscription = require('../models/UserSubscription');
const SubscriptionTier = require('../models/SubscriptionTier');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');
const { uploadToCloudinary, deleteFromCloudinary } = require('../utils/cloudinary');
const socketService = require('../services/socketService');
const streamingService = require('../services/streamingService');
const vrService = require('../services/vrService');
const analyticsService = require('../services/analyticsService');

// Stream categories with access requirements
const STREAM_CATEGORIES = {
  'main-stage': {
    name: 'Main Stage',
    description: 'Public streams accessible to all users',
    requiredTier: null,
    maxViewers: 1000,
    vrSupported: false,
    features: ['chat', 'tips', 'reactions']
  },
  'backstage': {
    name: 'Backstage',
    description: 'Behind-the-scenes content for subscribers',
    requiredTier: 'backstage-pass',
    maxViewers: 500,
    vrSupported: true,
    features: ['chat', 'tips', 'reactions', 'exclusive-content']
  },
  'vip-lounge': {
    name: 'VIP Lounge',
    description: 'Premium content for VIP members',
    requiredTier: 'vip-lounge',
    maxViewers: 200,
    vrSupported: true,
    features: ['chat', 'tips', 'reactions', 'exclusive-content', 'vr-front-row']
  },
  'champagne-room': {
    name: 'Champagne Room',
    description: 'Ultra-premium intimate experiences',
    requiredTier: 'champagne-room',
    maxViewers: 50,
    vrSupported: true,
    features: ['chat', 'tips', 'reactions', 'exclusive-content', 'vr-front-row', 'private-requests']
  },
  'private': {
    name: 'Private Show',
    description: 'One-on-one private sessions',
    requiredTier: 'black-card',
    maxViewers: 1,
    vrSupported: true,
    features: ['chat', 'tips', 'reactions', 'exclusive-content', 'vr-front-row', 'private-requests', 'cam2cam']
  }
};

/**
 * Get all streams with filtering and pagination
 */
const getStreams = async (req, res, next) => {
  try {
    const {
      category,
      status = 'live',
      hasVR,
      is360,
      page = 1,
      limit = 20,
      sortBy = 'viewers',
      sortOrder = 'desc'
    } = req.query;

    // Build filter object
    const filter = {
      status,
      isPrivate: false
    };

    if (category) {
      filter.category = category;
    }

    if (hasVR !== undefined) {
      filter.isVREnabled = hasVR === 'true';
    }

    if (is360 !== undefined) {
      filter.is360 = is360 === 'true';
    }

    // Only show streams user has access to
    if (req.user) {
      const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
      const userTierLevel = userSubscription ? userSubscription.subscriptionTier.level : 0;
      
      // Filter streams based on subscription tier
      const accessibleCategories = Object.entries(STREAM_CATEGORIES)
        .filter(([key, cat]) => {
          if (!cat.requiredTier) return true;
          const requiredTier = await SubscriptionTier.findOne({ slug: cat.requiredTier });
          return requiredTier && userTierLevel >= requiredTier.level;
        })
        .map(([key]) => key);
      
      filter.category = { $in: accessibleCategories };
    } else {
      // Non-authenticated users can only see main-stage
      filter.category = 'main-stage';
    }

    // Build sort object
    const sort = {};
    sort[sortBy] = sortOrder === 'desc' ? -1 : 1;

    // Execute query with pagination
    const skip = (page - 1) * limit;
    const [streams, total] = await Promise.all([
      Stream.find(filter)
        .populate('performer', 'username displayName avatar isVerified')
        .sort(sort)
        .skip(skip)
        .limit(parseInt(limit))
        .lean(),
      Stream.countDocuments(filter)
    ]);

    // Add category info to each stream
    const streamsWithInfo = streams.map(stream => ({
      ...stream,
      categoryInfo: STREAM_CATEGORIES[stream.category],
      canAccess: true // Already filtered above
    }));

    res.status(200).json({
      success: true,
      data: {
        streams: streamsWithInfo,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        },
        filters: {
          category,
          status,
          hasVR,
          is360
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get stream by ID
 */
const getStreamById = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findById(streamId)
      .populate('performer', 'username displayName avatar isVerified subscriptionTiers')
      .lean();

    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Check access permissions
    let canAccess = true;
    let accessMessage = null;
    
    if (stream.category !== 'main-stage') {
      const categoryInfo = STREAM_CATEGORIES[stream.category];
      
      if (!req.user) {
        canAccess = false;
        accessMessage = 'Authentication required';
      } else if (categoryInfo.requiredTier) {
        const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
        const requiredTier = await SubscriptionTier.findOne({ slug: categoryInfo.requiredTier });
        
        if (!userSubscription || userSubscription.subscriptionTier.level < requiredTier.level) {
          canAccess = false;
          accessMessage = `${requiredTier.name} subscription required`;
        }
      }
    }

    // Add category and access info
    const streamWithInfo = {
      ...stream,
      categoryInfo: STREAM_CATEGORIES[stream.category],
      canAccess,
      accessMessage
    };

    // Hide sensitive data if user can't access
    if (!canAccess) {
      delete streamWithInfo.streamKey;
      delete streamWithInfo.rtmpUrl;
      delete streamWithInfo.playbackUrl;
    }

    res.status(200).json({
      success: true,
      data: {
        stream: streamWithInfo
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get stream categories info
 */
const getStreamCategories = async (req, res, next) => {
  try {
    // Get tier information for each category
    const categoriesWithTiers = {};
    
    for (const [key, category] of Object.entries(STREAM_CATEGORIES)) {
      categoriesWithTiers[key] = {
        ...category,
        requiredTierInfo: null
      };
      
      if (category.requiredTier) {
        const tier = await SubscriptionTier.findOne({ slug: category.requiredTier });
        if (tier) {
          categoriesWithTiers[key].requiredTierInfo = {
            name: tier.name,
            level: tier.level,
            price: tier.price,
            color: tier.color
          };
        }
      }
    }

    res.status(200).json({
      success: true,
      data: {
        categories: categoriesWithTiers
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Create new stream
 */
const createStream = async (req, res, next) => {
  try {
    const {
      title,
      description,
      category,
      isVREnabled = false,
      is360 = false,
      tags = [],
      scheduledFor,
      maxViewers,
      isPrivate = false,
      requiresSubscription = false,
      minimumTier
    } = req.body;

    // Validate category access for performer
    const categoryInfo = STREAM_CATEGORIES[category];
    if (!categoryInfo) {
      throw new AppError('Invalid stream category', 400);
    }

    // Check if performer can create streams in this category
    if (category !== 'main-stage' && req.user.role !== 'admin') {
      const performerSubscription = await UserSubscription.findActiveForUser(req.user.id);
      if (categoryInfo.requiredTier) {
        const requiredTier = await SubscriptionTier.findOne({ slug: categoryInfo.requiredTier });
        if (!performerSubscription || performerSubscription.subscriptionTier.level < requiredTier.level) {
          throw new AppError(`${requiredTier.name} subscription required to stream in ${categoryInfo.name}`, 403);
        }
      }
    }

    // Generate streaming credentials
    const streamingCredentials = await streamingService.generateStreamCredentials(req.user.id);

    // Create stream
    const stream = new Stream({
      title,
      description,
      category,
      performer: req.user.id,
      isVREnabled: isVREnabled && categoryInfo.vrSupported,
      is360: is360 && categoryInfo.vrSupported,
      tags,
      scheduledFor: scheduledFor ? new Date(scheduledFor) : null,
      maxViewers: Math.min(maxViewers || categoryInfo.maxViewers, categoryInfo.maxViewers),
      isPrivate,
      requiresSubscription,
      minimumTier,
      streamKey: streamingCredentials.streamKey,
      rtmpUrl: streamingCredentials.rtmpUrl,
      playbackUrl: streamingCredentials.playbackUrl,
      status: scheduledFor ? 'scheduled' : 'created'
    });

    await stream.save();

    // Populate performer info
    await stream.populate('performer', 'username displayName avatar isVerified');

    logger.info(`Stream created: ${stream.id} by user ${req.user.id}`);

    // Notify followers if scheduled
    if (scheduledFor) {
      socketService.notifyFollowers(req.user.id, 'stream_scheduled', {
        streamId: stream.id,
        title: stream.title,
        scheduledFor: stream.scheduledFor
      });
    }

    res.status(201).json({
      success: true,
      data: {
        stream: {
          ...stream.toObject(),
          categoryInfo: categoryInfo
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update stream
 */
const updateStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const updates = req.body;

    const stream = await Stream.findById(streamId);
    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Check ownership
    if (stream.performer.toString() !== req.user.id && req.user.role !== 'admin') {
      throw new AppError('Not authorized to update this stream', 403);
    }

    // Prevent updates to live streams
    if (stream.status === 'live') {
      throw new AppError('Cannot update live stream', 400);
    }

    // Update allowed fields
    const allowedUpdates = ['title', 'description', 'tags', 'isVREnabled', 'is360'];
    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        stream[field] = updates[field];
      }
    });

    // Validate VR settings against category
    const categoryInfo = STREAM_CATEGORIES[stream.category];
    if ((stream.isVREnabled || stream.is360) && !categoryInfo.vrSupported) {
      stream.isVREnabled = false;
      stream.is360 = false;
    }

    stream.updatedAt = new Date();
    await stream.save();

    await stream.populate('performer', 'username displayName avatar isVerified');

    logger.info(`Stream updated: ${stream.id} by user ${req.user.id}`);

    res.status(200).json({
      success: true,
      data: {
        stream: {
          ...stream.toObject(),
          categoryInfo: categoryInfo
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Start stream
 */
const startStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findById(streamId);
    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Check ownership
    if (stream.performer.toString() !== req.user.id && req.user.role !== 'admin') {
      throw new AppError('Not authorized to start this stream', 403);
    }

    // Check if stream can be started
    if (!['created', 'scheduled'].includes(stream.status)) {
      throw new AppError('Stream cannot be started', 400);
    }

    // Start streaming service
    await streamingService.startStream(stream.id);

    // Update stream status
    stream.status = 'live';
    stream.startedAt = new Date();
    stream.currentViewers = 0;
    await stream.save();

    await stream.populate('performer', 'username displayName avatar isVerified');

    logger.info(`Stream started: ${stream.id} by user ${req.user.id}`);

    // Notify platform about new live stream
    socketService.broadcastToCategory(stream.category, 'stream_started', {
      streamId: stream.id,
      title: stream.title,
      performer: stream.performer,
      category: stream.category,
      isVREnabled: stream.isVREnabled
    });

    // Initialize VR session if enabled
    if (stream.isVREnabled) {
      await vrService.initializeVRSession(stream.id);
    }

    res.status(200).json({
      success: true,
      data: {
        stream: {
          ...stream.toObject(),
          categoryInfo: STREAM_CATEGORIES[stream.category]
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * End stream
 */
const endStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findById(streamId);
    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Check ownership
    if (stream.performer.toString() !== req.user.id && req.user.role !== 'admin') {
      throw new AppError('Not authorized to end this stream', 403);
    }

    // Check if stream is live
    if (stream.status !== 'live') {
      throw new AppError('Stream is not live', 400);
    }

    // Stop streaming service
    await streamingService.stopStream(stream.id);

    // Update stream status
    stream.status = 'ended';
    stream.endedAt = new Date();
    stream.duration = Math.floor((stream.endedAt - stream.startedAt) / 1000); // in seconds
    await stream.save();

    // Clean up VR session if enabled
    if (stream.isVREnabled) {
      await vrService.cleanupVRSession(stream.id);
    }

    // Notify viewers
    socketService.broadcastToStream(stream.id, 'stream_ended', {
      streamId: stream.id,
      duration: stream.duration
    });

    // Generate analytics
    await analyticsService.generateStreamReport(stream.id);

    logger.info(`Stream ended: ${stream.id} by user ${req.user.id}`);

    res.status(200).json({
      success: true,
      data: {
        stream: {
          ...stream.toObject(),
          categoryInfo: STREAM_CATEGORIES[stream.category]
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Join stream as viewer
 */
const joinStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { vrMode = false, quality = 'medium' } = req.body;

    const stream = await Stream.findById(streamId)
      .populate('performer', 'username displayName avatar isVerified');
    
    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Check if stream is live
    if (stream.status !== 'live') {
      throw new AppError('Stream is not live', 400);
    }

    // Check access permissions
    const categoryInfo = STREAM_CATEGORIES[stream.category];
    if (categoryInfo.requiredTier) {
      const userSubscription = await UserSubscription.findActiveForUser(req.user.id);
      const requiredTier = await SubscriptionTier.findOne({ slug: categoryInfo.requiredTier });
      
      if (!userSubscription || userSubscription.subscriptionTier.level < requiredTier.level) {
        throw new AppError(`${requiredTier.name} subscription required`, 403);
      }
    }

    // Check viewer limit
    if (stream.currentViewers >= stream.maxViewers) {
      throw new AppError('Stream is at maximum capacity', 429);
    }

    // Validate VR mode
    if (vrMode && !stream.isVREnabled) {
      throw new AppError('VR mode not available for this stream', 400);
    }

    // Join streaming service
    const viewerToken = await streamingService.joinStream(stream.id, req.user.id, {
      vrMode,
      quality
    });

    // Update viewer count
    await Stream.findByIdAndUpdate(streamId, {
      $inc: { currentViewers: 1, totalViews: 1 },
      $addToSet: { viewers: req.user.id }
    });

    // Join VR session if requested
    let vrSessionData = null;
    if (vrMode && stream.isVREnabled) {
      vrSessionData = await vrService.joinVRSession(stream.id, req.user.id);
    }

    // Notify stream about new viewer
    socketService.joinStreamRoom(req.user.id, stream.id);
    socketService.broadcastToStream(stream.id, 'viewer_joined', {
      userId: req.user.id,
      username: req.user.username,
      currentViewers: stream.currentViewers + 1,
      vrMode
    });

    logger.info(`User ${req.user.id} joined stream ${stream.id}`);

    res.status(200).json({
      success: true,
      data: {
        stream: {
          id: stream.id,
          title: stream.title,
          performer: stream.performer,
          category: stream.category,
          isVREnabled: stream.isVREnabled,
          is360: stream.is360,
          currentViewers: stream.currentViewers + 1
        },
        viewerToken,
        playbackUrl: stream.playbackUrl,
        vrSessionData,
        categoryInfo
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Leave stream
 */
const leaveStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findById(streamId);
    if (!stream) {
      throw new AppError('Stream not found', 404);
    }

    // Leave streaming service
    await streamingService.leaveStream(stream.id, req.user.id);

    // Update viewer count
    await Stream.findByIdAndUpdate(streamId, {
      $inc: { currentViewers: -1 },
      $pull: { viewers: req.user.id }
    });

    // Leave VR session if active
    if (stream.isVREnabled) {
      await vrService.leaveVRSession(stream.id, req.user.id);
    }

    // Notify stream about viewer leaving
    socketService.leaveStreamRoom(req.user.id, stream.id);
    socketService.broadcastToStream(stream.id, 'viewer_left', {
      userId: req.user.id,
      currentViewers: Math.max(0, stream.currentViewers - 1)
    });

    logger.info(`User ${req.user.id} left stream ${stream.id}`);

    res.status(200).json({
      success: true,
      message: 'Left stream successfully'
    });
  } catch (error) {
    next(error);
  }
};

// Export all controller functions
module.exports = {
  getStreams,
  getStreamById,
  getStreamCategories,
  createStream,
  updateStream,
  startStream,
  endStream,
  joinStream,
  leaveStream,
  
  // Additional functions would be implemented here:
  getMyStreams: async (req, res, next) => {
    // Implementation for getting performer's streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getViewingHistory: async (req, res, next) => {
    // Implementation for getting user's viewing history
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  uploadThumbnail: async (req, res, next) => {
    // Implementation for uploading stream thumbnails
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  deleteStream: async (req, res, next) => {
    // Implementation for deleting streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getVRStreamData: async (req, res, next) => {
    // Implementation for VR stream data
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  joinVRSession: async (req, res, next) => {
    // Implementation for joining VR sessions
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  leaveVRSession: async (req, res, next) => {
    // Implementation for leaving VR sessions
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getBackstageStreams: async (req, res, next) => {
    // Implementation for backstage streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getVIPStreams: async (req, res, next) => {
    // Implementation for VIP streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getChampagneStreams: async (req, res, next) => {
    // Implementation for champagne room streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getExclusiveStreams: async (req, res, next) => {
    // Implementation for exclusive streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getAllStreamsAdmin: async (req, res, next) => {
    // Implementation for admin stream view
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  suspendStream: async (req, res, next) => {
    // Implementation for suspending streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  unsuspendStream: async (req, res, next) => {
    // Implementation for unsuspending streams
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getStreamAnalytics: async (req, res, next) => {
    // Implementation for stream analytics
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  },
  
  getPlatformAnalytics: async (req, res, next) => {
    // Implementation for platform analytics
    res.status(501).json({ success: false, message: 'Not implemented yet' });
  }
};
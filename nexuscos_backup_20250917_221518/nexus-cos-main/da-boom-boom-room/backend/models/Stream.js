const mongoose = require('mongoose');
const { Schema } = mongoose;

// Stream analytics subdocument
const streamAnalyticsSchema = new Schema({
  totalViews: {
    type: Number,
    default: 0
  },
  uniqueViewers: {
    type: Number,
    default: 0
  },
  peakViewers: {
    type: Number,
    default: 0
  },
  averageViewTime: {
    type: Number,
    default: 0 // in seconds
  },
  totalTips: {
    type: Number,
    default: 0
  },
  tipCount: {
    type: Number,
    default: 0
  },
  chatMessages: {
    type: Number,
    default: 0
  },
  vrViewers: {
    type: Number,
    default: 0
  },
  vrViewTime: {
    type: Number,
    default: 0
  },
  engagement: {
    likes: { type: Number, default: 0 },
    shares: { type: Number, default: 0 },
    reactions: { type: Number, default: 0 }
  },
  demographics: {
    countries: [{
      country: String,
      count: Number
    }],
    subscriptionTiers: [{
      tier: String,
      count: Number
    }]
  }
}, { _id: false });

// VR session data subdocument
const vrSessionSchema = new Schema({
  isEnabled: {
    type: Boolean,
    default: false
  },
  sessionId: {
    type: String,
    sparse: true
  },
  maxVRViewers: {
    type: Number,
    default: 50
  },
  currentVRViewers: {
    type: Number,
    default: 0
  },
  vrViewers: [{
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    device: {
      type: String,
      enum: ['oculus', 'vive', 'pico', 'quest', 'other'],
      default: 'other'
    },
    position: {
      x: { type: Number, default: 0 },
      y: { type: Number, default: 0 },
      z: { type: Number, default: 0 }
    },
    rotation: {
      x: { type: Number, default: 0 },
      y: { type: Number, default: 0 },
      z: { type: Number, default: 0 }
    }
  }],
  vrSettings: {
    environment: {
      type: String,
      enum: ['club', 'stage', 'private-room', 'vip-lounge', 'champagne-room'],
      default: 'club'
    },
    lighting: {
      type: String,
      enum: ['ambient', 'spotlight', 'neon', 'intimate'],
      default: 'ambient'
    },
    interactionLevel: {
      type: String,
      enum: ['view-only', 'basic', 'interactive', 'immersive'],
      default: 'view-only'
    }
  }
}, { _id: false });

// Stream quality settings subdocument
const qualitySettingsSchema = new Schema({
  resolutions: [{
    name: {
      type: String,
      enum: ['480p', '720p', '1080p', '1440p', '4K']
    },
    width: Number,
    height: Number,
    bitrate: Number,
    fps: Number,
    isDefault: Boolean
  }],
  adaptiveBitrate: {
    type: Boolean,
    default: true
  },
  maxBitrate: {
    type: Number,
    default: 6000 // kbps
  },
  audioQuality: {
    type: String,
    enum: ['standard', 'high', 'lossless'],
    default: 'high'
  }
}, { _id: false });

// Main stream schema
const streamSchema = new Schema({
  title: {
    type: String,
    required: [true, 'Stream title is required'],
    trim: true,
    minlength: [3, 'Title must be at least 3 characters'],
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  
  description: {
    type: String,
    trim: true,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  
  performer: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Performer is required'],
    index: true
  },
  
  category: {
    type: String,
    required: [true, 'Stream category is required'],
    enum: {
      values: ['main-stage', 'backstage', 'vip-lounge', 'champagne-room', 'private'],
      message: 'Invalid stream category'
    },
    index: true
  },
  
  status: {
    type: String,
    enum: {
      values: ['created', 'scheduled', 'live', 'ended', 'suspended'],
      message: 'Invalid stream status'
    },
    default: 'created',
    index: true
  },
  
  // VR and 360 support
  isVREnabled: {
    type: Boolean,
    default: false,
    index: true
  },
  
  is360: {
    type: Boolean,
    default: false,
    index: true
  },
  
  vrSession: vrSessionSchema,
  
  // Access control
  isPrivate: {
    type: Boolean,
    default: false,
    index: true
  },
  
  requiresSubscription: {
    type: Boolean,
    default: false
  },
  
  minimumTier: {
    type: String,
    enum: ['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']
  },
  
  allowedUsers: [{
    type: Schema.Types.ObjectId,
    ref: 'User'
  }],
  
  blockedUsers: [{
    type: Schema.Types.ObjectId,
    ref: 'User'
  }],
  
  // Streaming technical details
  streamKey: {
    type: String,
    required: true,
    unique: true,
    select: false // Don't include in queries by default
  },
  
  rtmpUrl: {
    type: String,
    required: true,
    select: false
  },
  
  playbackUrl: {
    type: String,
    required: true
  },
  
  qualitySettings: qualitySettingsSchema,
  
  // Viewer management
  currentViewers: {
    type: Number,
    default: 0,
    min: 0
  },
  
  maxViewers: {
    type: Number,
    default: 1000,
    min: 1
  },
  
  viewers: [{
    type: Schema.Types.ObjectId,
    ref: 'User'
  }],
  
  // Timing
  scheduledFor: {
    type: Date,
    index: true
  },
  
  startedAt: {
    type: Date,
    index: true
  },
  
  endedAt: {
    type: Date,
    index: true
  },
  
  duration: {
    type: Number, // in seconds
    default: 0
  },
  
  // Content metadata
  tags: [{
    type: String,
    trim: true,
    maxlength: 20
  }],
  
  thumbnail: {
    url: String,
    publicId: String // Cloudinary public ID
  },
  
  language: {
    type: String,
    default: 'en',
    maxlength: 5
  },
  
  // Analytics
  analytics: streamAnalyticsSchema,
  
  totalViews: {
    type: Number,
    default: 0,
    index: true
  },
  
  // Moderation
  moderationFlags: [{
    type: {
      type: String,
      enum: ['inappropriate-content', 'copyright', 'harassment', 'spam', 'other']
    },
    reason: String,
    reportedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    reportedAt: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['pending', 'reviewed', 'resolved', 'dismissed'],
      default: 'pending'
    }
  }],
  
  // Recording settings
  recordingEnabled: {
    type: Boolean,
    default: false
  },
  
  recordingUrl: {
    type: String,
    select: false
  },
  
  // Chat settings
  chatEnabled: {
    type: Boolean,
    default: true
  },
  
  chatMode: {
    type: String,
    enum: ['open', 'subscribers-only', 'followers-only', 'disabled'],
    default: 'open'
  },
  
  // Tipping settings
  tippingEnabled: {
    type: Boolean,
    default: true
  },
  
  minimumTip: {
    type: Number,
    default: 1,
    min: 0
  },
  
  tipGoal: {
    amount: {
      type: Number,
      min: 0
    },
    description: String,
    reached: {
      type: Boolean,
      default: false
    }
  },
  
  // Metadata
  metadata: {
    serverRegion: String,
    encodingSettings: {
      codec: String,
      preset: String,
      crf: Number
    },
    networkStats: {
      avgBitrate: Number,
      droppedFrames: Number,
      latency: Number
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for performance
streamSchema.index({ performer: 1, status: 1 });
streamSchema.index({ category: 1, status: 1 });
streamSchema.index({ status: 1, scheduledFor: 1 });
streamSchema.index({ isVREnabled: 1, status: 1 });
streamSchema.index({ createdAt: -1 });
streamSchema.index({ totalViews: -1 });
streamSchema.index({ currentViewers: -1 });

// Compound indexes
streamSchema.index({ category: 1, isVREnabled: 1, status: 1 });
streamSchema.index({ performer: 1, createdAt: -1 });

// Virtual fields
streamSchema.virtual('isLive').get(function() {
  return this.status === 'live';
});

streamSchema.virtual('isScheduled').get(function() {
  return this.status === 'scheduled' && this.scheduledFor > new Date();
});

streamSchema.virtual('viewerCapacityPercentage').get(function() {
  return Math.round((this.currentViewers / this.maxViewers) * 100);
});

streamSchema.virtual('durationFormatted').get(function() {
  if (!this.duration) return '0:00';
  const hours = Math.floor(this.duration / 3600);
  const minutes = Math.floor((this.duration % 3600) / 60);
  const seconds = this.duration % 60;
  
  if (hours > 0) {
    return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
});

// Instance methods
streamSchema.methods.canUserAccess = async function(userId) {
  // Check if user is blocked
  if (this.blockedUsers.includes(userId)) {
    return { canAccess: false, reason: 'User is blocked' };
  }
  
  // Check if stream is private and user is not in allowed list
  if (this.isPrivate && !this.allowedUsers.includes(userId)) {
    return { canAccess: false, reason: 'Private stream access required' };
  }
  
  // Check subscription requirements
  if (this.requiresSubscription && this.minimumTier) {
    const UserSubscription = require('./UserSubscription');
    const SubscriptionTier = require('./SubscriptionTier');
    
    const userSubscription = await UserSubscription.findActiveForUser(userId);
    if (!userSubscription) {
      return { canAccess: false, reason: 'Subscription required' };
    }
    
    const requiredTier = await SubscriptionTier.findOne({ slug: this.minimumTier });
    if (userSubscription.subscriptionTier.level < requiredTier.level) {
      return { canAccess: false, reason: `${requiredTier.name} subscription required` };
    }
  }
  
  return { canAccess: true };
};

streamSchema.methods.addViewer = async function(userId, vrMode = false) {
  if (!this.viewers.includes(userId)) {
    this.viewers.push(userId);
    this.currentViewers += 1;
    this.analytics.uniqueViewers += 1;
    
    if (this.currentViewers > this.analytics.peakViewers) {
      this.analytics.peakViewers = this.currentViewers;
    }
    
    if (vrMode && this.isVREnabled) {
      this.analytics.vrViewers += 1;
      this.vrSession.currentVRViewers += 1;
    }
    
    await this.save();
  }
};

streamSchema.methods.removeViewer = async function(userId) {
  const viewerIndex = this.viewers.indexOf(userId);
  if (viewerIndex > -1) {
    this.viewers.splice(viewerIndex, 1);
    this.currentViewers = Math.max(0, this.currentViewers - 1);
    
    // Remove from VR session if present
    if (this.vrSession.vrViewers) {
      const vrViewerIndex = this.vrSession.vrViewers.findIndex(v => v.userId.toString() === userId.toString());
      if (vrViewerIndex > -1) {
        this.vrSession.vrViewers.splice(vrViewerIndex, 1);
        this.vrSession.currentVRViewers = Math.max(0, this.vrSession.currentVRViewers - 1);
      }
    }
    
    await this.save();
  }
};

streamSchema.methods.updateAnalytics = async function(data) {
  if (data.tipAmount) {
    this.analytics.totalTips += data.tipAmount;
    this.analytics.tipCount += 1;
  }
  
  if (data.chatMessage) {
    this.analytics.chatMessages += 1;
  }
  
  if (data.engagement) {
    Object.keys(data.engagement).forEach(key => {
      if (this.analytics.engagement[key] !== undefined) {
        this.analytics.engagement[key] += data.engagement[key];
      }
    });
  }
  
  await this.save();
};

// Static methods
streamSchema.statics.findLiveStreams = function(category = null) {
  const filter = { status: 'live' };
  if (category) filter.category = category;
  
  return this.find(filter)
    .populate('performer', 'username displayName avatar isVerified')
    .sort({ currentViewers: -1 });
};

streamSchema.statics.findVRStreams = function() {
  return this.find({ 
    status: 'live', 
    isVREnabled: true 
  })
    .populate('performer', 'username displayName avatar isVerified')
    .sort({ 'vrSession.currentVRViewers': -1 });
};

streamSchema.statics.findByPerformer = function(performerId, status = null) {
  const filter = { performer: performerId };
  if (status) filter.status = status;
  
  return this.find(filter)
    .sort({ createdAt: -1 });
};

streamSchema.statics.getPopularStreams = function(limit = 10) {
  return this.find({ status: 'live' })
    .sort({ currentViewers: -1, totalViews: -1 })
    .limit(limit)
    .populate('performer', 'username displayName avatar isVerified');
};

// Pre-save middleware
streamSchema.pre('save', function(next) {
  // Initialize VR session if VR is enabled
  if (this.isVREnabled && !this.vrSession.isEnabled) {
    this.vrSession.isEnabled = true;
    if (!this.vrSession.sessionId) {
      this.vrSession.sessionId = `vr_${this._id}_${Date.now()}`;
    }
  }
  
  // Set quality settings based on category
  if (!this.qualitySettings.resolutions || this.qualitySettings.resolutions.length === 0) {
    const defaultResolutions = [
      { name: '480p', width: 854, height: 480, bitrate: 1000, fps: 30, isDefault: false },
      { name: '720p', width: 1280, height: 720, bitrate: 2500, fps: 30, isDefault: true },
      { name: '1080p', width: 1920, height: 1080, bitrate: 4500, fps: 30, isDefault: false }
    ];
    
    // Add higher quality for premium categories
    if (['vip-lounge', 'champagne-room', 'private'].includes(this.category)) {
      defaultResolutions.push(
        { name: '1440p', width: 2560, height: 1440, bitrate: 8000, fps: 30, isDefault: false },
        { name: '4K', width: 3840, height: 2160, bitrate: 15000, fps: 30, isDefault: false }
      );
    }
    
    this.qualitySettings.resolutions = defaultResolutions;
  }
  
  next();
});

// Post-save middleware
streamSchema.post('save', function(doc) {
  // Emit socket events for real-time updates
  if (doc.isModified('status') || doc.isModified('currentViewers')) {
    const socketService = require('../services/socketService');
    socketService.broadcastStreamUpdate(doc._id, {
      status: doc.status,
      currentViewers: doc.currentViewers,
      isVREnabled: doc.isVREnabled
    });
  }
});

module.exports = mongoose.model('Stream', streamSchema);
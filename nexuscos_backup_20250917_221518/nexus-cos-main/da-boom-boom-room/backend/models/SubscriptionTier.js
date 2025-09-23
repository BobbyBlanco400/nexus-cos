const mongoose = require('mongoose');

// Subscription tier schema
const subscriptionTierSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true,
    enum: ['Floor Pass', 'Backstage Pass', 'VIP Lounge', 'Champagne Room', 'Black Card']
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    enum: ['floor-pass', 'backstage-pass', 'vip-lounge', 'champagne-room', 'black-card']
  },
  level: {
    type: Number,
    required: true,
    unique: true,
    min: 1,
    max: 5
  },
  price: {
    monthly: {
      type: Number,
      required: true,
      min: 0
    },
    yearly: {
      type: Number,
      required: true,
      min: 0
    }
  },
  stripeProductId: {
    monthly: {
      type: String,
      required: true
    },
    yearly: {
      type: String,
      required: true
    }
  },
  stripePriceId: {
    monthly: {
      type: String,
      required: true
    },
    yearly: {
      type: String,
      required: true
    }
  },
  features: {
    streamAccess: {
      mainStage: { type: Boolean, default: false },
      backstage: { type: Boolean, default: false },
      vipLounge: { type: Boolean, default: false },
      champagneRoom: { type: Boolean, default: false },
      privateShows: { type: Boolean, default: false }
    },
    vrAccess: {
      enabled: { type: Boolean, default: false },
      frontRow: { type: Boolean, default: false },
      immersive360: { type: Boolean, default: false },
      exclusiveVrShows: { type: Boolean, default: false }
    },
    tipping: {
      enabled: { type: Boolean, default: true },
      maxTipAmount: { type: Number, default: 100 },
      priorityTips: { type: Boolean, default: false },
      customTipAnimations: { type: Boolean, default: false }
    },
    chat: {
      enabled: { type: Boolean, default: true },
      priorityMessages: { type: Boolean, default: false },
      privateMessages: { type: Boolean, default: false },
      customEmotes: { type: Boolean, default: false }
    },
    content: {
      hdStreams: { type: Boolean, default: false },
      uhd4kStreams: { type: Boolean, default: false },
      exclusiveContent: { type: Boolean, default: false },
      downloadableContent: { type: Boolean, default: false }
    },
    perks: {
      adFree: { type: Boolean, default: false },
      earlyAccess: { type: Boolean, default: false },
      memberBadge: { type: Boolean, default: false },
      customProfile: { type: Boolean, default: false },
      conciergeService: { type: Boolean, default: false }
    },
    limits: {
      simultaneousStreams: { type: Number, default: 1 },
      monthlyTipCredits: { type: Number, default: 0 },
      storageSpace: { type: Number, default: 0 }, // in GB
      supportPriority: { type: String, enum: ['low', 'medium', 'high', 'premium'], default: 'low' }
    }
  },
  description: {
    type: String,
    required: true
  },
  shortDescription: {
    type: String,
    required: true
  },
  benefits: [{
    type: String,
    required: true
  }],
  color: {
    primary: { type: String, required: true },
    secondary: { type: String, required: true },
    accent: { type: String, required: true }
  },
  badge: {
    icon: { type: String, required: true },
    animation: { type: String, default: 'none' }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isPopular: {
    type: Boolean,
    default: false
  },
  sortOrder: {
    type: Number,
    default: 0
  },
  metadata: {
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    updatedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for calculating yearly savings
subscriptionTierSchema.virtual('yearlySavings').get(function() {
  const monthlyTotal = this.price.monthly * 12;
  return monthlyTotal - this.price.yearly;
});

// Virtual for calculating yearly savings percentage
subscriptionTierSchema.virtual('yearlySavingsPercentage').get(function() {
  const monthlyTotal = this.price.monthly * 12;
  if (monthlyTotal === 0) return 0;
  return Math.round(((monthlyTotal - this.price.yearly) / monthlyTotal) * 100);
});

// Virtual for checking if tier has VR access
subscriptionTierSchema.virtual('hasVrAccess').get(function() {
  return this.features.vrAccess.enabled;
});

// Virtual for checking if tier has premium features
subscriptionTierSchema.virtual('isPremium').get(function() {
  return this.level >= 3; // VIP Lounge and above
});

// Static method to get tier by level
subscriptionTierSchema.statics.findByLevel = function(level) {
  return this.findOne({ level, isActive: true });
};

// Static method to get tier by slug
subscriptionTierSchema.statics.findBySlug = function(slug) {
  return this.findOne({ slug, isActive: true });
};

// Static method to get all active tiers sorted by level
subscriptionTierSchema.statics.getActiveTiers = function() {
  return this.find({ isActive: true }).sort({ level: 1 });
};

// Static method to check if user has access to specific feature
subscriptionTierSchema.statics.hasFeatureAccess = function(userTierLevel, featurePath) {
  return this.findByLevel(userTierLevel).then(tier => {
    if (!tier) return false;
    
    const pathParts = featurePath.split('.');
    let current = tier.features;
    
    for (const part of pathParts) {
      if (current[part] === undefined) return false;
      current = current[part];
    }
    
    return Boolean(current);
  });
};

// Instance method to check if this tier has access to stream type
subscriptionTierSchema.methods.hasStreamAccess = function(streamType) {
  return this.features.streamAccess[streamType] || false;
};

// Instance method to check if this tier has VR feature
subscriptionTierSchema.methods.hasVrFeature = function(vrFeature) {
  return this.features.vrAccess[vrFeature] || false;
};

// Instance method to get tier comparison data
subscriptionTierSchema.methods.getComparisonData = function() {
  return {
    name: this.name,
    level: this.level,
    price: this.price,
    features: this.features,
    benefits: this.benefits,
    color: this.color,
    isPopular: this.isPopular
  };
};

// Pre-save middleware to ensure proper tier hierarchy
subscriptionTierSchema.pre('save', function(next) {
  // Ensure tier features follow hierarchy (higher tiers include lower tier features)
  if (this.level > 1) {
    // Logic to inherit features from lower tiers can be added here
    // For now, we'll rely on manual configuration
  }
  next();
});

// Index for efficient queries
subscriptionTierSchema.index({ level: 1 });
subscriptionTierSchema.index({ slug: 1 });
subscriptionTierSchema.index({ isActive: 1, level: 1 });
subscriptionTierSchema.index({ 'stripeProductId.monthly': 1 });
subscriptionTierSchema.index({ 'stripeProductId.yearly': 1 });

const SubscriptionTier = mongoose.model('SubscriptionTier', subscriptionTierSchema);

module.exports = SubscriptionTier;

// Default tier configurations (for seeding)
const defaultTiers = [
  {
    name: 'Floor Pass',
    slug: 'floor-pass',
    level: 1,
    price: { monthly: 9.99, yearly: 99.99 },
    description: 'Basic access to the main stage with standard features',
    shortDescription: 'Basic access to main stage',
    benefits: [
      'Main Stage access',
      'Standard definition streams',
      'Basic chat features',
      'Standard tipping (up to $50)'
    ],
    features: {
      streamAccess: {
        mainStage: true,
        backstage: false,
        vipLounge: false,
        champagneRoom: false,
        privateShows: false
      },
      vrAccess: {
        enabled: false,
        frontRow: false,
        immersive360: false,
        exclusiveVrShows: false
      },
      tipping: {
        enabled: true,
        maxTipAmount: 50,
        priorityTips: false,
        customTipAnimations: false
      },
      chat: {
        enabled: true,
        priorityMessages: false,
        privateMessages: false,
        customEmotes: false
      },
      content: {
        hdStreams: false,
        uhd4kStreams: false,
        exclusiveContent: false,
        downloadableContent: false
      },
      perks: {
        adFree: false,
        earlyAccess: false,
        memberBadge: true,
        customProfile: false,
        conciergeService: false
      },
      limits: {
        simultaneousStreams: 1,
        monthlyTipCredits: 10,
        storageSpace: 1,
        supportPriority: 'low'
      }
    },
    color: {
      primary: '#8B5CF6',
      secondary: '#A78BFA',
      accent: '#C4B5FD'
    },
    badge: {
      icon: '🎫',
      animation: 'none'
    },
    isPopular: false
  },
  {
    name: 'Backstage Pass',
    slug: 'backstage-pass',
    level: 2,
    price: { monthly: 19.99, yearly: 199.99 },
    description: 'Enhanced access with backstage content and HD streaming',
    shortDescription: 'Main stage + backstage access',
    benefits: [
      'All Floor Pass features',
      'Backstage access',
      'HD streaming',
      'Priority chat messages',
      'Enhanced tipping (up to $100)'
    ],
    features: {
      streamAccess: {
        mainStage: true,
        backstage: true,
        vipLounge: false,
        champagneRoom: false,
        privateShows: false
      },
      vrAccess: {
        enabled: true,
        frontRow: false,
        immersive360: false,
        exclusiveVrShows: false
      },
      tipping: {
        enabled: true,
        maxTipAmount: 100,
        priorityTips: true,
        customTipAnimations: false
      },
      chat: {
        enabled: true,
        priorityMessages: true,
        privateMessages: false,
        customEmotes: true
      },
      content: {
        hdStreams: true,
        uhd4kStreams: false,
        exclusiveContent: false,
        downloadableContent: false
      },
      perks: {
        adFree: true,
        earlyAccess: false,
        memberBadge: true,
        customProfile: true,
        conciergeService: false
      },
      limits: {
        simultaneousStreams: 2,
        monthlyTipCredits: 25,
        storageSpace: 5,
        supportPriority: 'medium'
      }
    },
    color: {
      primary: '#EC4899',
      secondary: '#F472B6',
      accent: '#F9A8D4'
    },
    badge: {
      icon: '🎭',
      animation: 'pulse'
    },
    isPopular: true
  },
  {
    name: 'VIP Lounge',
    slug: 'vip-lounge',
    level: 3,
    price: { monthly: 39.99, yearly: 399.99 },
    description: 'Premium VIP experience with exclusive content and VR access',
    shortDescription: 'Premium VIP experience',
    benefits: [
      'All Backstage Pass features',
      'VIP Lounge access',
      'VR front-row experience',
      'Private messaging',
      'Exclusive content',
      'Custom tip animations'
    ],
    features: {
      streamAccess: {
        mainStage: true,
        backstage: true,
        vipLounge: true,
        champagneRoom: false,
        privateShows: false
      },
      vrAccess: {
        enabled: true,
        frontRow: true,
        immersive360: true,
        exclusiveVrShows: false
      },
      tipping: {
        enabled: true,
        maxTipAmount: 250,
        priorityTips: true,
        customTipAnimations: true
      },
      chat: {
        enabled: true,
        priorityMessages: true,
        privateMessages: true,
        customEmotes: true
      },
      content: {
        hdStreams: true,
        uhd4kStreams: true,
        exclusiveContent: true,
        downloadableContent: false
      },
      perks: {
        adFree: true,
        earlyAccess: true,
        memberBadge: true,
        customProfile: true,
        conciergeService: false
      },
      limits: {
        simultaneousStreams: 3,
        monthlyTipCredits: 50,
        storageSpace: 15,
        supportPriority: 'high'
      }
    },
    color: {
      primary: '#F59E0B',
      secondary: '#FBBF24',
      accent: '#FDE68A'
    },
    badge: {
      icon: '👑',
      animation: 'glow'
    },
    isPopular: false
  },
  {
    name: 'Champagne Room',
    slug: 'champagne-room',
    level: 4,
    price: { monthly: 79.99, yearly: 799.99 },
    description: 'Ultra-premium experience with private shows and concierge service',
    shortDescription: 'Ultra-premium private experience',
    benefits: [
      'All VIP Lounge features',
      'Champagne Room access',
      'Private shows',
      'Downloadable content',
      'Concierge service',
      'Priority support'
    ],
    features: {
      streamAccess: {
        mainStage: true,
        backstage: true,
        vipLounge: true,
        champagneRoom: true,
        privateShows: true
      },
      vrAccess: {
        enabled: true,
        frontRow: true,
        immersive360: true,
        exclusiveVrShows: true
      },
      tipping: {
        enabled: true,
        maxTipAmount: 500,
        priorityTips: true,
        customTipAnimations: true
      },
      chat: {
        enabled: true,
        priorityMessages: true,
        privateMessages: true,
        customEmotes: true
      },
      content: {
        hdStreams: true,
        uhd4kStreams: true,
        exclusiveContent: true,
        downloadableContent: true
      },
      perks: {
        adFree: true,
        earlyAccess: true,
        memberBadge: true,
        customProfile: true,
        conciergeService: true
      },
      limits: {
        simultaneousStreams: 5,
        monthlyTipCredits: 100,
        storageSpace: 50,
        supportPriority: 'premium'
      }
    },
    color: {
      primary: '#EF4444',
      secondary: '#F87171',
      accent: '#FCA5A5'
    },
    badge: {
      icon: '🥂',
      animation: 'sparkle'
    },
    isPopular: false
  },
  {
    name: 'Black Card',
    slug: 'black-card',
    level: 5,
    price: { monthly: 149.99, yearly: 1499.99 },
    description: 'The ultimate elite experience with unlimited access and exclusive privileges',
    shortDescription: 'Ultimate elite experience',
    benefits: [
      'All Champagne Room features',
      'Unlimited access to everything',
      'Exclusive Black Card events',
      'Personal performer relationships',
      'Custom content requests',
      'White-glove concierge service'
    ],
    features: {
      streamAccess: {
        mainStage: true,
        backstage: true,
        vipLounge: true,
        champagneRoom: true,
        privateShows: true
      },
      vrAccess: {
        enabled: true,
        frontRow: true,
        immersive360: true,
        exclusiveVrShows: true
      },
      tipping: {
        enabled: true,
        maxTipAmount: 1000,
        priorityTips: true,
        customTipAnimations: true
      },
      chat: {
        enabled: true,
        priorityMessages: true,
        privateMessages: true,
        customEmotes: true
      },
      content: {
        hdStreams: true,
        uhd4kStreams: true,
        exclusiveContent: true,
        downloadableContent: true
      },
      perks: {
        adFree: true,
        earlyAccess: true,
        memberBadge: true,
        customProfile: true,
        conciergeService: true
      },
      limits: {
        simultaneousStreams: 999,
        monthlyTipCredits: 250,
        storageSpace: 200,
        supportPriority: 'premium'
      }
    },
    color: {
      primary: '#000000',
      secondary: '#374151',
      accent: '#9CA3AF'
    },
    badge: {
      icon: '♠️',
      animation: 'elite'
    },
    isPopular: false
  }
];

module.exports.defaultTiers = defaultTiers;
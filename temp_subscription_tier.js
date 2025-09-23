const mongoose = require('mongoose');

const subscriptionTierSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  slug: {
    type: String,
    required: true,
    unique: true
  },
  level: {
    type: Number,
    required: true
  },
  price: {
    monthly: {
      type: Number,
      required: true
    },
    yearly: {
      type: Number,
      required: true
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
  features: {
    streamAccess: {
      mainStage: Boolean,
      backstage: Boolean,
      vipLounge: Boolean,
      champagneRoom: Boolean,
      privateShows: Boolean
    },
    vrAccess: {
      enabled: Boolean,
      frontRow: Boolean,
      immersive360: Boolean,
      exclusiveVrShows: Boolean
    },
    tipping: {
      enabled: Boolean,
      maxTipAmount: Number,
      priorityTips: Boolean,
      customTipAnimations: Boolean
    },
    chat: {
      enabled: Boolean,
      priorityMessages: Boolean,
      privateMessages: Boolean,
      customEmotes: Boolean
    },
    content: {
      hdStreams: Boolean,
      uhd4kStreams: Boolean,
      exclusiveContent: Boolean,
      downloadableContent: Boolean
    },
    perks: {
      adFree: Boolean,
      earlyAccess: Boolean,
      memberBadge: Boolean,
      customProfile: Boolean,
      conciergeService: Boolean
    },
    limits: {
      simultaneousStreams: Number,
      monthlyTipCredits: Number,
      storageSpace: Number,
      supportPriority: String
    }
  },
  color: {
    primary: String,
    secondary: String,
    accent: String
  },
  badge: {
    icon: String,
    animation: String
  },
  isPopular: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

const SubscriptionTier = mongoose.model('SubscriptionTier', subscriptionTierSchema);

module.exports = SubscriptionTier;
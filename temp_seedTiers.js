const mongoose = require('mongoose');
const SubscriptionTier = require('./models/SubscriptionTier');

mongoose.connect('mongodb://127.0.0.1:27017/nexus-cos')
  .then(() => console.log('Connected to MongoDB ✅'))
  .catch(err => console.error('MongoDB connection error:', err));

const tiers = [
  {
    name: 'Floor Pass',
    slug: 'floor-pass',
    level: 1,
    price: { monthly: 9.99, yearly: 99.99 },
    description: 'Basic access to main stage streams and chat',
    shortDescription: 'Basic main stage access',
    benefits: [
      'Main stage streams',
      'Basic chat access',
      'HD quality',
      'Standard tipping'
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
        maxTipAmount: 100,
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
        hdStreams: true,
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
        monthlyTipCredits: 50,
        storageSpace: 5,
        supportPriority: 'standard'
      }
    },
    color: {
      primary: '#4B5563',
      secondary: '#6B7280',
      accent: '#9CA3AF'
    },
    badge: {
      icon: '♣️',
      animation: 'basic'
    },
    isPopular: true,
    isActive: true
  },
  {
    name: 'Backstage Pass',
    slug: 'backstage-pass',
    level: 2,
    price: { monthly: 19.99, yearly: 199.99 },
    description: 'Enhanced access with backstage content and premium features',
    shortDescription: 'Enhanced backstage access',
    benefits: [
      'All Floor Pass features',
      'Backstage access',
      'Priority chat',
      'VR streams'
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
        maxTipAmount: 200,
        priorityTips: false,
        customTipAnimations: false
      },
      chat: {
        enabled: true,
        priorityMessages: true,
        privateMessages: false,
        customEmotes: false
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
        customProfile: false,
        conciergeService: false
      },
      limits: {
        simultaneousStreams: 2,
        monthlyTipCredits: 100,
        storageSpace: 10,
        supportPriority: 'priority'
      }
    },
    color: {
      primary: '#1F2937',
      secondary: '#374151',
      accent: '#6B7280'
    },
    badge: {
      icon: '♦️',
      animation: 'premium'
    },
    isPopular: false,
    isActive: true
  },
  {
    name: 'VIP Lounge',
    slug: 'vip-lounge',
    level: 3,
    price: { monthly: 49.99, yearly: 499.99 },
    description: 'Premium experience with VIP lounge access and exclusive perks',
    shortDescription: 'Premium VIP experience',
    benefits: [
      'All Backstage Pass features',
      'VIP lounge access',
      'Private messaging',
      'Custom emotes'
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
        immersive360: false,
        exclusiveVrShows: false
      },
      tipping: {
        enabled: true,
        maxTipAmount: 500,
        priorityTips: true,
        customTipAnimations: false
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
        exclusiveContent: false,
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
        monthlyTipCredits: 150,
        storageSpace: 50,
        supportPriority: 'vip'
      }
    },
    color: {
      primary: '#4F46E5',
      secondary: '#6366F1',
      accent: '#818CF8'
    },
    badge: {
      icon: '♥️',
      animation: 'vip'
    },
    isPopular: true,
    isActive: true
  },
  {
    name: 'Champagne Room',
    slug: 'champagne-room',
    level: 4,
    price: { monthly: 99.99, yearly: 999.99 },
    description: 'Elite access with champagne room privileges and premium content',
    shortDescription: 'Elite champagne privileges',
    benefits: [
      'All VIP Lounge features',
      'Champagne room access',
      'Private shows',
      'Exclusive content'
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
        exclusiveVrShows: false
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
        conciergeService: false
      },
      limits: {
        simultaneousStreams: 5,
        monthlyTipCredits: 200,
        storageSpace: 100,
        supportPriority: 'elite'
      }
    },
    color: {
      primary: '#7C3AED',
      secondary: '#8B5CF6',
      accent: '#A78BFA'
    },
    badge: {
      icon: '👑',
      animation: 'elite'
    },
    isPopular: false,
    isActive: true
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
    isPopular: false,
    isActive: true
  }
];

const seed = async () => {
  try {
    await SubscriptionTier.deleteMany({});
    await SubscriptionTier.insertMany(tiers);
    console.log('✅ Subscription tiers seeded successfully');
  } catch (error) {
    console.error('❌ Error seeding subscription tiers:', error);
  } finally {
    mongoose.disconnect();
  }
};

seed();
const mongoose = require('mongoose');
const SubscriptionTier = require('../models/SubscriptionTier');
require('dotenv').config();

async function seedSubscriptionTiers() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Delete existing tiers
    await SubscriptionTier.deleteMany({});
    console.log('Cleared existing subscription tiers');

    // Create Stripe products and prices for each tier
    const tiers = [
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
          'Public chat access',
          'Basic tipping'
        ],
        stripeProductId: {
          monthly: 'prod_floor_pass_monthly',
          yearly: 'prod_floor_pass_yearly'
        },
        stripePriceId: {
          monthly: 'price_floor_pass_monthly',
          yearly: 'price_floor_pass_yearly'
        },
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
            hdStreams: false,
            uhd4kStreams: false,
            exclusiveContent: false,
            downloadableContent: false
          },
          perks: {
            adFree: false,
            earlyAccess: false,
            memberBadge: false,
            customProfile: false,
            conciergeService: false
          },
          limits: {
            simultaneousStreams: 1,
            monthlyTipCredits: 50,
            storageSpace: 0,
            supportPriority: 'low'
          }
        },
        color: {
          primary: '#4B5563',
          secondary: '#6B7280',
          accent: '#9CA3AF'
        },
        badge: {
          icon: '♣️',
          animation: 'none'
        },
        isActive: true,
        isPopular: true
      },
      {
        name: 'Backstage Pass',
        slug: 'backstage-pass',
        level: 2,
        price: { monthly: 19.99, yearly: 199.99 },
        description: 'Enhanced access with HD streaming and backstage features',
        shortDescription: 'HD streaming & backstage access',
        benefits: [
          'All Floor Pass features',
          'HD quality streams',
          'Backstage access',
          'Priority chat',
          'Custom emotes',
          'Ad-free experience'
        ],
        stripeProductId: {
          monthly: 'prod_backstage_monthly',
          yearly: 'prod_backstage_yearly'
        },
        stripePriceId: {
          monthly: 'price_backstage_monthly',
          yearly: 'price_backstage_yearly'
        },
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
            frontRow: true,
            immersive360: false,
            exclusiveVrShows: false
          },
          tipping: {
            enabled: true,
            maxTipAmount: 250,
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
            customProfile: false,
            conciergeService: false
          },
          limits: {
            simultaneousStreams: 2,
            monthlyTipCredits: 100,
            storageSpace: 5,
            supportPriority: 'medium'
          }
        },
        color: {
          primary: '#7C3AED',
          secondary: '#8B5CF6',
          accent: '#A78BFA'
        },
        badge: {
          icon: '♦️',
          animation: 'pulse'
        },
        isActive: true,
        isPopular: false
      },
      {
        name: 'VIP Lounge',
        slug: 'vip-lounge',
        level: 3,
        price: { monthly: 49.99, yearly: 499.99 },
        description: 'Premium experience with 4K streaming and VIP features',
        shortDescription: '4K streaming & VIP features',
        benefits: [
          'All Backstage Pass features',
          '4K Ultra HD streams',
          'VIP Lounge access',
          'Private messaging',
          'Exclusive content',
          'Priority support'
        ],
        stripeProductId: {
          monthly: 'prod_vip_monthly',
          yearly: 'prod_vip_yearly'
        },
        stripePriceId: {
          monthly: 'price_vip_monthly',
          yearly: 'price_vip_yearly'
        },
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
            storageSpace: 20,
            supportPriority: 'high'
          }
        },
        color: {
          primary: '#D97706',
          secondary: '#F59E0B',
          accent: '#FBBF24'
        },
        badge: {
          icon: '♥️',
          animation: 'shine'
        },
        isActive: true,
        isPopular: false
      },
      {
        name: 'Champagne Room',
        slug: 'champagne-room',
        level: 4,
        price: { monthly: 99.99, yearly: 999.99 },
        description: 'Elite access with private shows and premium perks',
        shortDescription: 'Private shows & premium perks',
        benefits: [
          'All VIP Lounge features',
          'Champagne Room access',
          'Private show access',
          'Downloadable content',
          'Custom profile features',
          'Concierge service'
        ],
        stripeProductId: {
          monthly: 'prod_champagne_monthly',
          yearly: 'prod_champagne_yearly'
        },
        stripePriceId: {
          monthly: 'price_champagne_monthly',
          yearly: 'price_champagne_yearly'
        },
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
            simultaneousStreams: 5,
            monthlyTipCredits: 200,
            storageSpace: 50,
            supportPriority: 'premium'
          }
        },
        color: {
          primary: '#BE185D',
          secondary: '#DB2777',
          accent: '#F472B6'
        },
        badge: {
          icon: '👑',
          animation: 'sparkle'
        },
        isActive: true,
        isPopular: false
      },
      {
        name: 'Black Card',
        slug: 'black-card',
        level: 5,
        price: { monthly: 199.99, yearly: 1999.99 },
        description: 'Ultimate VIP experience with unlimited everything',
        shortDescription: 'Unlimited everything & elite status',
        benefits: [
          'All Champagne Room features',
          'Unlimited private shows',
          'Custom content requests',
          'Exclusive events',
          'Personal concierge',
          'Elite member status'
        ],
        stripeProductId: {
          monthly: 'prod_black_card_monthly',
          yearly: 'prod_black_card_yearly'
        },
        stripePriceId: {
          monthly: 'price_black_card_monthly',
          yearly: 'price_black_card_yearly'
        },
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
            maxTipAmount: 5000,
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
        isActive: true,
        isPopular: false
      }
    ];

    // Insert tiers
    await SubscriptionTier.insertMany(tiers);
    console.log('Successfully seeded subscription tiers');

    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  } catch (error) {
    console.error('Error seeding subscription tiers:', error);
    process.exit(1);
  }
}

seedSubscriptionTiers();
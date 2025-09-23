export interface SubscriptionTier {
  id: string
  name: string
  price: number
  interval: 'month' | 'year'
  stripePriceId?: string
  features: string[]
  accessLevel: number
  color: string
  gradient: string
  icon: string
  description: string
  popular?: boolean
}

export const SUBSCRIPTION_TIERS: SubscriptionTier[] = [
  {
    id: 'floor-pass',
    name: 'Floor Pass',
    price: 9.99,
    interval: 'month',
    stripePriceId: process.env.NEXT_PUBLIC_STRIPE_FLOOR_PASS_PRICE_ID,
    features: [
      'Access to Main Stage streams',
      'Basic chat participation',
      'Standard video quality (720p)',
      'Mobile app access',
      'Community forums'
    ],
    accessLevel: 1,
    color: '#8B5CF6',
    gradient: 'from-purple-500 to-purple-700',
    icon: '🎫',
    description: 'Entry-level access to the main entertainment'
  },
  {
    id: 'backstage-pass',
    name: 'Backstage Pass',
    price: 24.99,
    interval: 'month',
    stripePriceId: process.env.NEXT_PUBLIC_STRIPE_BACKSTAGE_PASS_PRICE_ID,
    features: [
      'All Floor Pass features',
      'Backstage stream access',
      'HD video quality (1080p)',
      'Priority chat messages',
      'Exclusive performer content',
      'Monthly virtual meet & greets'
    ],
    accessLevel: 2,
    color: '#F59E0B',
    gradient: 'from-amber-500 to-orange-600',
    icon: '🎭',
    description: 'Behind-the-scenes access and premium content',
    popular: true
  },
  {
    id: 'vip-lounge',
    name: 'VIP Lounge',
    price: 49.99,
    interval: 'month',
    stripePriceId: process.env.NEXT_PUBLIC_STRIPE_VIP_LOUNGE_PRICE_ID,
    features: [
      'All Backstage Pass features',
      'VIP Lounge exclusive streams',
      '4K video quality',
      'VR/360° stream access',
      'Direct messaging with performers',
      'Custom emoji reactions',
      'Ad-free experience',
      'Early access to new features'
    ],
    accessLevel: 3,
    color: '#EF4444',
    gradient: 'from-red-500 to-pink-600',
    icon: '👑',
    description: 'Premium VIP experience with exclusive perks'
  },
  {
    id: 'champagne-room',
    name: 'Champagne Room',
    price: 99.99,
    interval: 'month',
    stripePriceId: process.env.NEXT_PUBLIC_STRIPE_CHAMPAGNE_ROOM_PRICE_ID,
    features: [
      'All VIP Lounge features',
      'Private show requests',
      'Ultra HD 8K streaming',
      'Personalized content recommendations',
      'Weekly 1-on-1 video calls',
      'Custom profile badges',
      'Priority customer support',
      'Exclusive merchandise discounts',
      'Advanced VR features'
    ],
    accessLevel: 4,
    color: '#10B981',
    gradient: 'from-emerald-500 to-teal-600',
    icon: '🥂',
    description: 'Ultra-premium experience with personalized attention'
  },
  {
    id: 'black-card',
    name: 'Black Card',
    price: 199.99,
    interval: 'month',
    stripePriceId: process.env.NEXT_PUBLIC_STRIPE_BLACK_CARD_PRICE_ID,
    features: [
      'All Champagne Room features',
      'Unlimited private shows',
      'Custom content creation requests',
      'Exclusive events and parties',
      'Personal concierge service',
      'NFT membership benefits',
      'Lifetime achievement badges',
      'Beta access to new platforms',
      'Annual in-person meet & greet',
      'Custom VR experiences'
    ],
    accessLevel: 5,
    color: '#1F2937',
    gradient: 'from-gray-900 to-black',
    icon: '♠️',
    description: 'The ultimate elite membership with unlimited access'
  }
]

export const getTierById = (id: string): SubscriptionTier | undefined => {
  return SUBSCRIPTION_TIERS.find(tier => tier.id === id)
}

export const getTierByAccessLevel = (level: number): SubscriptionTier | undefined => {
  return SUBSCRIPTION_TIERS.find(tier => tier.accessLevel === level)
}

export const canAccessContent = (userTier: number, requiredTier: number): boolean => {
  return userTier >= requiredTier
}

export const getUpgradeTiers = (currentTierLevel: number): SubscriptionTier[] => {
  return SUBSCRIPTION_TIERS.filter(tier => tier.accessLevel > currentTierLevel)
}

export const formatPrice = (price: number): string => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
  }).format(price)
}
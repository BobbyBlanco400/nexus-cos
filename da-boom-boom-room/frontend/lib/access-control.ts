import { type SubscriptionTier, SUBSCRIPTION_TIERS, canAccessContent } from './subscription-tiers'

export interface User {
  id: string
  name: string
  email?: string
  tier: number
  customerId?: string
  subscriptionId?: string
  subscriptionStatus?: 'active' | 'canceled' | 'past_due' | 'incomplete'
}

export interface StreamAccess {
  streamId: string
  name: string
  requiredTier: number
  isVREnabled: boolean
  maxViewers?: number
  description: string
}

export const STREAM_ACCESS_LEVELS: StreamAccess[] = [
  {
    streamId: 'main-stage',
    name: 'Main Stage',
    requiredTier: 1, // Floor Pass
    isVREnabled: false,
    description: 'Main entertainment stage with live performances'
  },
  {
    streamId: 'backstage',
    name: 'Backstage',
    requiredTier: 2, // Backstage Pass
    isVREnabled: false,
    description: 'Behind-the-scenes exclusive content'
  },
  {
    streamId: 'vip-lounge',
    name: 'VIP Lounge',
    requiredTier: 3, // VIP Lounge
    isVREnabled: true,
    maxViewers: 50,
    description: 'Exclusive VIP area with premium interactions'
  },
  {
    streamId: 'champagne-room',
    name: 'Champagne Room',
    requiredTier: 4, // Champagne Room
    isVREnabled: true,
    maxViewers: 20,
    description: 'Ultra-premium private entertainment space'
  },
  {
    streamId: 'black-card-exclusive',
    name: 'Black Card Exclusive',
    requiredTier: 5, // Black Card
    isVREnabled: true,
    maxViewers: 10,
    description: 'Elite members only - unlimited access'
  }
]

export class AccessControlService {
  static checkStreamAccess(user: User | null, streamId: string): {
    hasAccess: boolean
    reason?: string
    upgradeRequired?: SubscriptionTier
  } {
    if (!user) {
      return {
        hasAccess: false,
        reason: 'Authentication required',
        upgradeRequired: SUBSCRIPTION_TIERS[0]
      }
    }

    const stream = STREAM_ACCESS_LEVELS.find(s => s.streamId === streamId)
    if (!stream) {
      return {
        hasAccess: false,
        reason: 'Stream not found'
      }
    }

    if (!canAccessContent(user.tier, stream.requiredTier)) {
      const requiredTier = SUBSCRIPTION_TIERS.find(t => t.accessLevel === stream.requiredTier)
      return {
        hasAccess: false,
        reason: `${requiredTier?.name || 'Higher tier'} subscription required`,
        upgradeRequired: requiredTier
      }
    }

    // Check subscription status
    if (user.subscriptionStatus && user.subscriptionStatus !== 'active') {
      return {
        hasAccess: false,
        reason: 'Subscription is not active'
      }
    }

    return { hasAccess: true }
  }

  static checkVRAccess(user: User | null, streamId: string): {
    hasVRAccess: boolean
    reason?: string
  } {
    const streamAccess = this.checkStreamAccess(user, streamId)
    if (!streamAccess.hasAccess) {
      return {
        hasVRAccess: false,
        reason: streamAccess.reason
      }
    }

    const stream = STREAM_ACCESS_LEVELS.find(s => s.streamId === streamId)
    if (!stream?.isVREnabled) {
      return {
        hasVRAccess: false,
        reason: 'VR not available for this stream'
      }
    }

    return { hasVRAccess: true }
  }

  static getAccessibleStreams(user: User | null): StreamAccess[] {
    if (!user) return []
    
    return STREAM_ACCESS_LEVELS.filter(stream => 
      canAccessContent(user.tier, stream.requiredTier)
    )
  }

  static getUpgradeOptions(user: User | null, targetStreamId?: string): {
    currentTier?: SubscriptionTier
    availableUpgrades: SubscriptionTier[]
    recommendedTier?: SubscriptionTier
  } {
    const currentTier = user ? SUBSCRIPTION_TIERS.find(t => t.accessLevel === user.tier) : undefined
    const availableUpgrades = SUBSCRIPTION_TIERS.filter(tier => 
      tier.accessLevel > (user?.tier || 0)
    )

    let recommendedTier: SubscriptionTier | undefined
    if (targetStreamId) {
      const stream = STREAM_ACCESS_LEVELS.find(s => s.streamId === targetStreamId)
      if (stream) {
        recommendedTier = SUBSCRIPTION_TIERS.find(t => t.accessLevel === stream.requiredTier)
      }
    }

    return {
      currentTier,
      availableUpgrades,
      recommendedTier
    }
  }

  static canTip(user: User | null): boolean {
    return user !== null && user.tier >= 1
  }

  static getTipLimits(user: User | null): {
    canTip: boolean
    dailyLimit?: number
    perTipLimit?: number
  } {
    if (!user) {
      return { canTip: false }
    }

    // Tip limits based on tier
    const limits = {
      1: { dailyLimit: 100, perTipLimit: 10 },   // Floor Pass
      2: { dailyLimit: 250, perTipLimit: 25 },   // Backstage Pass
      3: { dailyLimit: 500, perTipLimit: 50 },   // VIP Lounge
      4: { dailyLimit: 1000, perTipLimit: 100 }, // Champagne Room
      5: { dailyLimit: -1, perTipLimit: -1 }     // Black Card (unlimited)
    }

    const userLimits = limits[user.tier as keyof typeof limits] || limits[1]
    
    return {
      canTip: true,
      dailyLimit: userLimits.dailyLimit === -1 ? undefined : userLimits.dailyLimit,
      perTipLimit: userLimits.perTipLimit === -1 ? undefined : userLimits.perTipLimit
    }
  }
}
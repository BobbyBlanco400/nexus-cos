export interface TipWallet {
  userId: string
  balance: number
  currency: 'USD' | 'EUR' | 'GBP'
  transactions: TipTransaction[]
  dailySpent: number
  lastResetDate: string
}

export interface TipTransaction {
  id: string
  fromUserId: string
  toPerformerId?: string
  amount: number
  type: 'deposit' | 'tip' | 'refund'
  status: 'pending' | 'completed' | 'failed'
  timestamp: string
  message?: string
  streamId?: string
}

export interface Performer {
  id: string
  name: string
  displayName: string
  avatar?: string
  isOnline: boolean
  currentStreamId?: string
  tipGoal?: number
  tipGoalProgress?: number
  walletAddress?: string
}

export interface TipOption {
  amount: number
  emoji: string
  message: string
  animation?: string
}

export const TIP_OPTIONS: TipOption[] = [
  { amount: 1, emoji: '👏', message: 'Nice!', animation: 'bounce' },
  { amount: 5, emoji: '💖', message: 'Love it!', animation: 'pulse' },
  { amount: 10, emoji: '🔥', message: 'Hot!', animation: 'shake' },
  { amount: 25, emoji: '💎', message: 'Amazing!', animation: 'sparkle' },
  { amount: 50, emoji: '👑', message: 'Royalty!', animation: 'crown' },
  { amount: 100, emoji: '🚀', message: 'To the moon!', animation: 'rocket' },
  { amount: 250, emoji: '💰', message: 'Big spender!', animation: 'money-rain' },
  { amount: 500, emoji: '🎆', message: 'Spectacular!', animation: 'fireworks' }
]

export class TippingService {
  private static wallets = new Map<string, TipWallet>()
  private static performers = new Map<string, Performer>()

  // Initialize mock data
  static {
    // Mock performers
    this.performers.set('performer1', {
      id: 'performer1',
      name: 'Luna Star',
      displayName: '🌟 Luna',
      isOnline: true,
      currentStreamId: 'main-stage',
      tipGoal: 1000,
      tipGoalProgress: 650,
      walletAddress: '0x1234...5678'
    })
    
    this.performers.set('performer2', {
      id: 'performer2',
      name: 'Neon Dreams',
      displayName: '💫 Neon',
      isOnline: true,
      currentStreamId: 'vip-lounge',
      tipGoal: 500,
      tipGoalProgress: 200,
      walletAddress: '0xabcd...efgh'
    })
  }

  static getWallet(userId: string): TipWallet {
    if (!this.wallets.has(userId)) {
      this.wallets.set(userId, {
        userId,
        balance: 0,
        currency: 'USD',
        transactions: [],
        dailySpent: 0,
        lastResetDate: new Date().toISOString().split('T')[0]
      })
    }
    return this.wallets.get(userId)!
  }

  static async addCredits(userId: string, amount: number, paymentMethodId?: string): Promise<{
    success: boolean
    transactionId?: string
    error?: string
  }> {
    try {
      // Simulate payment processing
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      const wallet = this.getWallet(userId)
      const transaction: TipTransaction = {
        id: `dep_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        fromUserId: userId,
        amount,
        type: 'deposit',
        status: 'completed',
        timestamp: new Date().toISOString()
      }
      
      wallet.balance += amount
      wallet.transactions.unshift(transaction)
      
      return {
        success: true,
        transactionId: transaction.id
      }
    } catch (error) {
      return {
        success: false,
        error: 'Payment processing failed'
      }
    }
  }

  static async sendTip({
    fromUserId,
    toPerformerId,
    amount,
    message,
    streamId
  }: {
    fromUserId: string
    toPerformerId: string
    amount: number
    message?: string
    streamId?: string
  }): Promise<{
    success: boolean
    transactionId?: string
    error?: string
    animation?: string
  }> {
    const wallet = this.getWallet(fromUserId)
    const performer = this.performers.get(toPerformerId)
    
    if (!performer) {
      return { success: false, error: 'Performer not found' }
    }
    
    if (!performer.isOnline) {
      return { success: false, error: 'Performer is offline' }
    }
    
    if (wallet.balance < amount) {
      return { success: false, error: 'Insufficient balance' }
    }
    
    // Check daily limits
    const today = new Date().toISOString().split('T')[0]
    if (wallet.lastResetDate !== today) {
      wallet.dailySpent = 0
      wallet.lastResetDate = today
    }
    
    const tipOption = TIP_OPTIONS.find(opt => opt.amount === amount)
    const transaction: TipTransaction = {
      id: `tip_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      fromUserId,
      toPerformerId,
      amount,
      type: 'tip',
      status: 'completed',
      timestamp: new Date().toISOString(),
      message: message || tipOption?.message,
      streamId
    }
    
    wallet.balance -= amount
    wallet.dailySpent += amount
    wallet.transactions.unshift(transaction)
    
    // Update performer tip goal
    if (performer.tipGoal && performer.tipGoalProgress !== undefined) {
      performer.tipGoalProgress = Math.min(
        performer.tipGoal,
        performer.tipGoalProgress + amount
      )
    }
    
    return {
      success: true,
      transactionId: transaction.id,
      animation: tipOption?.animation
    }
  }

  static getPerformer(performerId: string): Performer | undefined {
    return this.performers.get(performerId)
  }

  static getPerformersInStream(streamId: string): Performer[] {
    return Array.from(this.performers.values())
      .filter(p => p.currentStreamId === streamId && p.isOnline)
  }

  static getAllPerformers(): Performer[] {
    return Array.from(this.performers.values())
  }

  static getRecentTips(streamId?: string, limit: number = 10): TipTransaction[] {
    const allTransactions: TipTransaction[] = []
    
    for (const wallet of this.wallets.values()) {
      allTransactions.push(...wallet.transactions.filter(t => 
        t.type === 'tip' && 
        t.status === 'completed' &&
        (!streamId || t.streamId === streamId)
      ))
    }
    
    return allTransactions
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, limit)
  }

  static getTipLeaderboard(streamId?: string, period: 'daily' | 'weekly' | 'monthly' = 'daily'): {
    userId: string
    totalTipped: number
    tipCount: number
  }[] {
    const now = new Date()
    const cutoff = new Date()
    
    switch (period) {
      case 'daily':
        cutoff.setHours(0, 0, 0, 0)
        break
      case 'weekly':
        cutoff.setDate(now.getDate() - 7)
        break
      case 'monthly':
        cutoff.setMonth(now.getMonth() - 1)
        break
    }
    
    const userStats = new Map<string, { totalTipped: number; tipCount: number }>()
    
    for (const wallet of this.wallets.values()) {
      const relevantTips = wallet.transactions.filter(t => 
        t.type === 'tip' && 
        t.status === 'completed' &&
        new Date(t.timestamp) >= cutoff &&
        (!streamId || t.streamId === streamId)
      )
      
      if (relevantTips.length > 0) {
        const totalTipped = relevantTips.reduce((sum, t) => sum + t.amount, 0)
        userStats.set(wallet.userId, {
          totalTipped,
          tipCount: relevantTips.length
        })
      }
    }
    
    return Array.from(userStats.entries())
      .map(([userId, stats]) => ({ userId, ...stats }))
      .sort((a, b) => b.totalTipped - a.totalTipped)
      .slice(0, 10)
  }

  static getQuickTipAmounts(userTier: number): number[] {
    const baseTips = [1, 5, 10, 25]
    
    switch (userTier) {
      case 1: return baseTips
      case 2: return [...baseTips, 50]
      case 3: return [...baseTips, 50, 100]
      case 4: return [...baseTips, 50, 100, 250]
      case 5: return [...baseTips, 50, 100, 250, 500]
      default: return baseTips
    }
  }
}
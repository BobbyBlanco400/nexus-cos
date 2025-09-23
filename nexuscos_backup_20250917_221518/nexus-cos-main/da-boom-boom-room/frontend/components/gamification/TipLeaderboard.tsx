'use client'

import { useState, useEffect } from 'react'
import { TippingService } from '@/lib/tipping-system'
import { SUBSCRIPTION_TIERS } from '@/lib/subscription-tiers'

interface LeaderboardEntry {
  userId: string
  totalTipped: number
  tipCount: number
  rank: number
  tier: number
  nftBadges?: string[]
  vrFrontRowTime?: number
  achievements?: string[]
}

interface TipLeaderboardProps {
  streamId?: string
  period?: 'daily' | 'weekly' | 'monthly'
  showVRFeatures?: boolean
  currentUserId?: string
}

const ACHIEVEMENT_BADGES = {
  'first-tip': { emoji: '🎯', name: 'First Tip', description: 'Sent your first tip' },
  'big-spender': { emoji: '💰', name: 'Big Spender', description: 'Tipped over $100 in one session' },
  'vr-pioneer': { emoji: '🥽', name: 'VR Pioneer', description: 'Used VR mode for 1+ hours' },
  'front-row-vip': { emoji: '👑', name: 'Front Row VIP', description: 'Earned VR front row access' },
  'tip-streak': { emoji: '🔥', name: 'Tip Streak', description: '7 days of consecutive tipping' },
  'nft-collector': { emoji: '🎨', name: 'NFT Collector', description: 'Owns exclusive membership NFT' },
  'whale': { emoji: '🐋', name: 'Whale', description: 'Top 1% tipper this month' },
  'supporter': { emoji: '❤️', name: 'Loyal Supporter', description: 'Supported 10+ different performers' }
}

const NFT_COLLECTIONS = {
  'genesis': { name: 'Genesis Member', emoji: '💎', rarity: 'Legendary' },
  'vip-access': { name: 'VIP Access Pass', emoji: '🎫', rarity: 'Epic' },
  'performer-special': { name: 'Performer Special', emoji: '⭐', rarity: 'Rare' },
  'anniversary': { name: 'Anniversary Edition', emoji: '🎉', rarity: 'Limited' }
}

export default function TipLeaderboard({ 
  streamId, 
  period = 'daily', 
  showVRFeatures = true,
  currentUserId 
}: TipLeaderboardProps) {
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([])
  const [selectedPeriod, setSelectedPeriod] = useState(period)
  const [showAchievements, setShowAchievements] = useState(false)
  const [vrAnimationActive, setVrAnimationActive] = useState(false)
  const [frontRowQueue, setFrontRowQueue] = useState<string[]>([])

  useEffect(() => {
    const rawLeaderboard = TippingService.getTipLeaderboard(streamId, selectedPeriod)
    
    // Enhance with gamification data
    const enhancedLeaderboard: LeaderboardEntry[] = rawLeaderboard.map((entry, index) => {
      const userTier = Math.floor(Math.random() * 5) + 1 // Mock tier data
      const achievements = generateAchievements(entry.totalTipped, entry.tipCount, userTier)
      const nftBadges = generateNFTBadges(userTier, entry.totalTipped)
      
      return {
        ...entry,
        rank: index + 1,
        tier: userTier,
        achievements,
        nftBadges,
        vrFrontRowTime: entry.totalTipped > 100 ? Math.floor(entry.totalTipped / 10) : 0
      }
    })
    
    setLeaderboard(enhancedLeaderboard)
    
    // Update VR front row queue
    const vrEligible = enhancedLeaderboard
      .filter(entry => entry.vrFrontRowTime && entry.vrFrontRowTime > 0)
      .slice(0, 5)
      .map(entry => entry.userId)
    setFrontRowQueue(vrEligible)
  }, [streamId, selectedPeriod])

  const generateAchievements = (totalTipped: number, tipCount: number, tier: number): string[] => {
    const achievements: string[] = []
    
    if (tipCount > 0) achievements.push('first-tip')
    if (totalTipped > 100) achievements.push('big-spender')
    if (tier >= 3) achievements.push('vr-pioneer')
    if (totalTipped > 500) achievements.push('front-row-vip')
    if (tipCount > 20) achievements.push('tip-streak')
    if (tier === 5) achievements.push('nft-collector')
    if (totalTipped > 1000) achievements.push('whale')
    if (tipCount > 50) achievements.push('supporter')
    
    return achievements
  }

  const generateNFTBadges = (tier: number, totalTipped: number): string[] => {
    const badges: string[] = []
    
    if (tier === 5) badges.push('genesis')
    if (tier >= 3) badges.push('vip-access')
    if (totalTipped > 250) badges.push('performer-special')
    if (Math.random() > 0.8) badges.push('anniversary') // 20% chance for demo
    
    return badges
  }

  const triggerVRAnimation = () => {
    setVrAnimationActive(true)
    setTimeout(() => setVrAnimationActive(false), 3000)
  }

  const getRankColor = (rank: number) => {
    switch (rank) {
      case 1: return 'from-yellow-400 to-yellow-600'
      case 2: return 'from-gray-300 to-gray-500'
      case 3: return 'from-orange-400 to-orange-600'
      default: return 'from-purple-400 to-purple-600'
    }
  }

  const getRankEmoji = (rank: number) => {
    switch (rank) {
      case 1: return '🥇'
      case 2: return '🥈'
      case 3: return '🥉'
      default: return '🏆'
    }
  }

  return (
    <div className="bg-gray-900 rounded-xl border border-yellow-500/30 overflow-hidden">
      {/* Header */}
      <div className="bg-gradient-to-r from-yellow-600 to-orange-600 p-4">
        <div className="flex justify-between items-center">
          <h3 className="text-xl font-bold text-white flex items-center gap-2">
            🏆 Tip Leaderboard
            {showVRFeatures && (
              <button
                onClick={triggerVRAnimation}
                className={`ml-2 px-3 py-1 rounded-full text-sm transition-all ${
                  vrAnimationActive 
                    ? 'bg-cyan-500 text-white animate-pulse' 
                    : 'bg-cyan-500/20 text-cyan-400 hover:bg-cyan-500/30'
                }`}
              >
                🥽 VR Mode
              </button>
            )}
          </h3>
          
          <div className="flex gap-2">
            {(['daily', 'weekly', 'monthly'] as const).map((p) => (
              <button
                key={p}
                onClick={() => setSelectedPeriod(p)}
                className={`px-3 py-1 rounded-full text-sm font-bold transition-all ${
                  selectedPeriod === p
                    ? 'bg-white text-yellow-600'
                    : 'bg-white/20 text-white hover:bg-white/30'
                }`}
              >
                {p.charAt(0).toUpperCase() + p.slice(1)}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* VR Front Row Queue */}
      {showVRFeatures && frontRowQueue.length > 0 && (
        <div className={`bg-cyan-900/50 border-b border-cyan-500/30 p-4 transition-all ${
          vrAnimationActive ? 'animate-pulse bg-cyan-500/20' : ''
        }`}>
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="text-cyan-400 font-bold">🥽 VR Front Row Queue:</span>
              <div className="flex gap-1">
                {frontRowQueue.slice(0, 3).map((userId, index) => (
                  <span 
                    key={userId} 
                    className={`px-2 py-1 rounded text-xs font-bold ${
                      userId === currentUserId ? 'bg-cyan-500 text-white' : 'bg-cyan-500/20 text-cyan-400'
                    }`}
                  >
                    #{index + 1}
                  </span>
                ))}
              </div>
            </div>
            <button
              onClick={triggerVRAnimation}
              className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white px-3 py-1 rounded-full text-xs font-bold hover:from-cyan-600 hover:to-blue-600 transition-all"
            >
              Join VR Front Row
            </button>
          </div>
        </div>
      )}

      {/* Leaderboard Entries */}
      <div className="p-4 space-y-3 max-h-96 overflow-y-auto">
        {leaderboard.map((entry) => {
          const tierInfo = SUBSCRIPTION_TIERS.find(t => t.accessLevel === entry.tier)
          const isCurrentUser = entry.userId === currentUserId
          
          return (
            <div
              key={entry.userId}
              className={`border-2 rounded-lg p-4 transition-all ${
                isCurrentUser
                  ? 'border-yellow-500 bg-yellow-500/10 shadow-lg'
                  : 'border-gray-600 bg-gray-800/50 hover:border-gray-500'
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  {/* Rank Badge */}
                  <div className={`w-10 h-10 rounded-full bg-gradient-to-r ${getRankColor(entry.rank)} flex items-center justify-center text-white font-bold`}>
                    {entry.rank <= 3 ? getRankEmoji(entry.rank) : entry.rank}
                  </div>
                  
                  <div className="flex-1">
                    <div className="flex items-center gap-2">
                      <span className="text-white font-bold">
                        {isCurrentUser ? 'You' : `User ${entry.userId.slice(-4)}`}
                      </span>
                      
                      {/* Tier Badge */}
                      <span className={`px-2 py-1 rounded text-xs font-bold ${
                        tierInfo?.accessLevel === 5 ? 'bg-black text-yellow-400' :
                        tierInfo?.accessLevel === 4 ? 'bg-purple-500/20 text-purple-400' :
                        tierInfo?.accessLevel === 3 ? 'bg-blue-500/20 text-blue-400' :
                        tierInfo?.accessLevel === 2 ? 'bg-green-500/20 text-green-400' :
                        'bg-gray-500/20 text-gray-400'
                      }`}>
                        {tierInfo?.name || 'Free'}
                      </span>
                      
                      {/* VR Front Row Indicator */}
                      {showVRFeatures && frontRowQueue.includes(entry.userId) && (
                        <span className="bg-cyan-500/20 text-cyan-400 px-2 py-1 rounded text-xs font-bold">
                          🥽 Front Row
                        </span>
                      )}
                    </div>
                    
                    <div className="text-gray-400 text-sm">
                      {entry.tipCount} tips • {entry.vrFrontRowTime || 0} VR minutes
                    </div>
                  </div>
                </div>
                
                <div className="text-right">
                  <div className="text-green-400 font-bold text-lg">
                    ${entry.totalTipped}
                  </div>
                  
                  {/* NFT Badges */}
                  {entry.nftBadges && entry.nftBadges.length > 0 && (
                    <div className="flex gap-1 mt-1 justify-end">
                      {entry.nftBadges.slice(0, 3).map((badge) => {
                        const nft = NFT_COLLECTIONS[badge as keyof typeof NFT_COLLECTIONS]
                        return nft ? (
                          <span
                            key={badge}
                            title={`${nft.name} (${nft.rarity})`}
                            className="text-lg hover:scale-110 transition-transform cursor-help"
                          >
                            {nft.emoji}
                          </span>
                        ) : null
                      })}
                    </div>
                  )}
                </div>
              </div>
              
              {/* Achievements */}
              {entry.achievements && entry.achievements.length > 0 && (
                <div className="mt-3 pt-3 border-t border-gray-700">
                  <div className="flex flex-wrap gap-1">
                    {entry.achievements.slice(0, 4).map((achievement) => {
                      const badge = ACHIEVEMENT_BADGES[achievement as keyof typeof ACHIEVEMENT_BADGES]
                      return badge ? (
                        <span
                          key={achievement}
                          title={badge.description}
                          className="bg-purple-500/20 text-purple-400 px-2 py-1 rounded text-xs font-bold flex items-center gap-1 hover:bg-purple-500/30 transition-all cursor-help"
                        >
                          {badge.emoji} {badge.name}
                        </span>
                      ) : null
                    })}
                    
                    {entry.achievements.length > 4 && (
                      <span className="bg-gray-500/20 text-gray-400 px-2 py-1 rounded text-xs">
                        +{entry.achievements.length - 4} more
                      </span>
                    )}
                  </div>
                </div>
              )}
            </div>
          )
        })}
        
        {leaderboard.length === 0 && (
          <div className="text-center text-gray-500 py-8">
            <div className="text-4xl mb-2">🏆</div>
            <div>No tips yet for this period</div>
            <div className="text-sm mt-1">Be the first to tip and claim the top spot!</div>
          </div>
        )}
      </div>

      {/* NFT Integration Footer */}
      <div className="bg-gradient-to-r from-purple-900/50 to-pink-900/50 border-t border-purple-500/30 p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="text-purple-400 font-bold">🎨 NFT Rewards:</span>
            <span className="text-gray-300 text-sm">Earn exclusive NFTs by climbing the leaderboard</span>
          </div>
          <button
            onClick={() => setShowAchievements(!showAchievements)}
            className="bg-purple-500/20 text-purple-400 px-3 py-1 rounded hover:bg-purple-500/30 transition-all text-sm font-bold"
          >
            {showAchievements ? 'Hide' : 'Show'} Achievements
          </button>
        </div>
        
        {showAchievements && (
          <div className="mt-3 grid grid-cols-2 md:grid-cols-4 gap-2">
            {Object.entries(ACHIEVEMENT_BADGES).map(([key, badge]) => (
              <div
                key={key}
                className="bg-black/30 rounded p-2 text-center hover:bg-black/50 transition-all cursor-help"
                title={badge.description}
              >
                <div className="text-lg">{badge.emoji}</div>
                <div className="text-xs text-gray-400">{badge.name}</div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { AccessControlService, STREAM_ACCESS_LEVELS, type User } from '@/lib/access-control'
import { SUBSCRIPTION_TIERS } from '@/lib/subscription-tiers'
import { redirectToCheckout } from '@/lib/stripe-checkout'
import TipLeaderboard from '@/components/gamification/TipLeaderboard'

// Mock user - in real app, this would come from auth context
const mockUser: User = {
  id: '1',
  name: 'Demo User',
  email: 'demo@example.com',
  tier: 1, // Floor Pass
  subscriptionStatus: 'active'
}

export default function StreamsPage() {
  const [user, setUser] = useState<User | null>(null)
  const [selectedStream, setSelectedStream] = useState<string | null>(null)
  const [vrMode, setVrMode] = useState(false)

  useEffect(() => {
    // Simulate loading user data
    setUser(mockUser)
  }, [])

  const handleStreamAccess = (streamId: string) => {
    const access = AccessControlService.checkStreamAccess(user, streamId)
    
    if (access.hasAccess) {
      setSelectedStream(streamId)
    } else {
      alert(`Access denied: ${access.reason}`)
      if (access.upgradeRequired) {
        const upgrade = confirm(`Upgrade to ${access.upgradeRequired.name} for $${access.upgradeRequired.price.monthly}/month?`)
        if (upgrade) {
          redirectToCheckout(access.upgradeRequired, 'monthly')
        }
      }
    }
  }

  const handleVRToggle = (streamId: string) => {
    const vrAccess = AccessControlService.checkVRAccess(user, streamId)
    
    if (vrAccess.hasVRAccess) {
      setVrMode(!vrMode)
    } else {
      alert(`VR Access denied: ${vrAccess.reason}`)
    }
  }

  const accessibleStreams = AccessControlService.getAccessibleStreams(user)
  const upgradeOptions = AccessControlService.getUpgradeOptions(user)

  return (
    <div className="min-h-screen bg-black text-white">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-900 via-pink-900 to-red-900 p-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-4xl font-bold bg-gradient-to-r from-pink-400 to-purple-400 bg-clip-text text-transparent">
                🎭 Live Streams
              </h1>
              <p className="text-gray-300 mt-2">
                {user ? `Welcome back, ${user.name}` : 'Please sign in to access streams'}
              </p>
            </div>
            <div className="text-right">
              {user && (
                <div className="bg-black/30 rounded-lg p-3">
                  <div className="text-sm text-gray-300">Current Tier</div>
                  <div className="text-lg font-bold text-pink-400">
                    {SUBSCRIPTION_TIERS.find(t => t.accessLevel === user.tier)?.name || 'Unknown'}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto p-6">
        <div className="grid lg:grid-cols-3 gap-8">
          {/* Stream Selection */}
          <div className="lg:col-span-2">
            <h2 className="text-2xl font-bold mb-6 text-pink-400">🎪 Available Streams</h2>
            
            <div className="grid gap-4">
              {STREAM_ACCESS_LEVELS.map((stream) => {
                const access = AccessControlService.checkStreamAccess(user, stream.streamId)
                const vrAccess = AccessControlService.checkVRAccess(user, stream.streamId)
                const isSelected = selectedStream === stream.streamId
                
                return (
                  <div
                    key={stream.streamId}
                    className={`border-2 rounded-xl p-6 transition-all duration-300 cursor-pointer ${
                      access.hasAccess
                        ? isSelected
                          ? 'border-pink-500 bg-pink-500/10 shadow-lg shadow-pink-500/20'
                          : 'border-purple-500/50 bg-purple-500/5 hover:border-purple-400 hover:bg-purple-500/10'
                        : 'border-gray-600 bg-gray-800/50 opacity-60'
                    }`}
                    onClick={() => access.hasAccess && handleStreamAccess(stream.streamId)}
                  >
                    <div className="flex justify-between items-start mb-4">
                      <div>
                        <h3 className="text-xl font-bold text-white mb-2">{stream.name}</h3>
                        <p className="text-gray-300 text-sm">{stream.description}</p>
                      </div>
                      <div className="flex flex-col items-end gap-2">
                        {stream.isVREnabled && (
                          <span className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white px-3 py-1 rounded-full text-xs font-bold">
                            🥽 VR Ready
                          </span>
                        )}
                        {stream.maxViewers && (
                          <span className="bg-yellow-500/20 text-yellow-400 px-3 py-1 rounded-full text-xs">
                            Max {stream.maxViewers} viewers
                          </span>
                        )}
                      </div>
                    </div>
                    
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2">
                        <span className="text-sm text-gray-400">Required:</span>
                        <span className={`px-2 py-1 rounded text-xs font-bold ${
                          access.hasAccess ? 'bg-green-500/20 text-green-400' : 'bg-red-500/20 text-red-400'
                        }`}>
                          {SUBSCRIPTION_TIERS.find(t => t.accessLevel === stream.requiredTier)?.name}
                        </span>
                      </div>
                      
                      {access.hasAccess ? (
                        <div className="flex gap-2">
                          {stream.isVREnabled && vrAccess.hasVRAccess && (
                            <button
                              onClick={(e) => {
                                e.stopPropagation()
                                handleVRToggle(stream.streamId)
                              }}
                              className={`px-4 py-2 rounded-lg text-sm font-bold transition-all ${
                                vrMode && isSelected
                                  ? 'bg-cyan-500 text-white'
                                  : 'bg-cyan-500/20 text-cyan-400 hover:bg-cyan-500/30'
                              }`}
                            >
                              🥽 VR Mode
                            </button>
                          )}
                          <span className="text-green-400 font-bold">✓ Access Granted</span>
                        </div>
                      ) : (
                        <button
                          onClick={(e) => {
                            e.stopPropagation()
                            if (access.upgradeRequired) {
                              redirectToCheckout(access.upgradeRequired, 'monthly')
                            }
                          }}
                          className="bg-gradient-to-r from-pink-500 to-purple-500 text-white px-4 py-2 rounded-lg text-sm font-bold hover:from-pink-600 hover:to-purple-600 transition-all"
                        >
                          🔓 Upgrade Access
                        </button>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Stream Player & Controls */}
          <div className="lg:col-span-1">
            <div className="sticky top-6">
              {selectedStream ? (
                <div className="bg-gray-900 rounded-xl p-6 border border-purple-500/30">
                  <h3 className="text-xl font-bold mb-4 text-pink-400">
                    🎬 Now Streaming
                  </h3>
                  
                  {/* Mock Video Player */}
                  <div className={`bg-black rounded-lg mb-4 flex items-center justify-center ${
                    vrMode ? 'aspect-square' : 'aspect-video'
                  }`}>
                    <div className="text-center">
                      <div className="text-4xl mb-2">
                        {vrMode ? '🥽' : '📹'}
                      </div>
                      <div className="text-white font-bold">
                        {STREAM_ACCESS_LEVELS.find(s => s.streamId === selectedStream)?.name}
                      </div>
                      <div className="text-gray-400 text-sm mt-1">
                        {vrMode ? '360° VR Stream' : 'Live Stream'}
                      </div>
                      <div className="mt-4">
                        <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse inline-block mr-2"></div>
                        <span className="text-red-400 text-sm font-bold">LIVE</span>
                      </div>
                    </div>
                  </div>
                  
                  {/* Stream Controls */}
                  <div className="space-y-3">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-400">Viewers:</span>
                      <span className="text-white font-bold">1,234</span>
                    </div>
                    
                    {vrMode && (
                      <div className="bg-cyan-500/10 border border-cyan-500/30 rounded-lg p-3">
                        <div className="text-cyan-400 font-bold text-sm mb-2">🥽 VR Controls</div>
                        <div className="grid grid-cols-2 gap-2 text-xs">
                          <button className="bg-cyan-500/20 text-cyan-400 p-2 rounded hover:bg-cyan-500/30">
                            Reset View
                          </button>
                          <button className="bg-cyan-500/20 text-cyan-400 p-2 rounded hover:bg-cyan-500/30">
                            Front Row
                          </button>
                        </div>
                      </div>
                    )}
                    
                    <Link
                      href={`/streams/${selectedStream}/tips`}
                      className="block w-full bg-gradient-to-r from-green-500 to-emerald-500 text-white text-center py-3 rounded-lg font-bold hover:from-green-600 hover:to-emerald-600 transition-all"
                    >
                      💰 Send Tips
                    </Link>
                  </div>
                </div>
              ) : (
                <div className="bg-gray-900 rounded-xl p-6 border border-gray-600 text-center">
                  <div className="text-4xl mb-4">🎭</div>
                  <h3 className="text-xl font-bold mb-2 text-gray-400">
                    Select a Stream
                  </h3>
                  <p className="text-gray-500 text-sm">
                    Choose from the available streams to start watching
                  </p>
                </div>
              )}
              
              {/* Gamified Leaderboard */}
              <div className="mt-6">
                <TipLeaderboard 
                  streamId={selectedStream || undefined}
                  period="daily"
                  showVRFeatures={true}
                  currentUserId={user?.id}
                />
              </div>
              
              {/* Upgrade Prompt */}
              {upgradeOptions.availableUpgrades.length > 0 && (
                <div className="mt-6 bg-gradient-to-r from-purple-900/50 to-pink-900/50 rounded-xl p-6 border border-purple-500/30">
                  <h3 className="text-lg font-bold mb-3 text-pink-400">
                    🚀 Unlock More Streams
                  </h3>
                  <p className="text-gray-300 text-sm mb-4">
                    Upgrade your membership to access exclusive content
                  </p>
                  <Link
                    href="/subscription"
                    className="block w-full bg-gradient-to-r from-pink-500 to-purple-500 text-white text-center py-3 rounded-lg font-bold hover:from-pink-600 hover:to-purple-600 transition-all"
                  >
                    View Membership Tiers
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
'use client'

import React, { useState, useEffect } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { useStream } from '@/contexts/StreamContext'
import { useQuery } from 'react-query'
import { api } from '@/lib/api'
import { cn } from '@/lib/utils'
import VRStreamViewer from './VRStreamViewer'
import TippingInterface from './TippingInterface'
import SubscriptionTiers from './SubscriptionTiers'
import { toast } from 'react-hot-toast'

interface Stream {
  id: string
  title: string
  description: string
  category: 'main-stage' | 'backstage' | 'vip-lounge' | 'champagne-room' | 'black-card'
  performer: {
    id: string
    username: string
    displayName: string
    avatar?: string
    isOnline: boolean
    tier: string
  }
  thumbnail?: string
  viewerCount: number
  isLive: boolean
  streamUrl?: string
  requiredTier: string
  tags: string[]
  startedAt: string
  duration?: number
  isVREnabled: boolean
  is360: boolean
}

interface StreamCategory {
  id: string
  name: string
  description: string
  requiredTier: string
  icon: string
  color: string
  bgGradient: string
}

const streamCategories: StreamCategory[] = [
  {
    id: 'main-stage',
    name: 'Main Stage',
    description: 'Public performances for all members',
    requiredTier: 'floor-pass',
    icon: '🎭',
    color: 'text-green-400',
    bgGradient: 'from-green-500/20 to-emerald-600/20'
  },
  {
    id: 'backstage',
    name: 'Backstage',
    description: 'Behind the scenes exclusive content',
    requiredTier: 'backstage-pass',
    icon: '🎪',
    color: 'text-blue-400',
    bgGradient: 'from-blue-500/20 to-cyan-600/20'
  },
  {
    id: 'vip-lounge',
    name: 'VIP Lounge',
    description: 'Premium VR experiences',
    requiredTier: 'vip-lounge',
    icon: '👑',
    color: 'text-purple-400',
    bgGradient: 'from-purple-500/20 to-violet-600/20'
  },
  {
    id: 'champagne-room',
    name: 'Champagne Room',
    description: 'Intimate private shows',
    requiredTier: 'champagne-room',
    icon: '🥂',
    color: 'text-yellow-400',
    bgGradient: 'from-yellow-500/20 to-orange-600/20'
  },
  {
    id: 'black-card',
    name: 'Black Card',
    description: 'Ultra-exclusive NFT member content',
    requiredTier: 'black-card',
    icon: '💎',
    color: 'text-gray-300',
    bgGradient: 'from-gray-700/20 to-black/40'
  }
]

export function StreamsPage() {
  const { user } = useAuth()
  const { currentStream, joinStream, leaveStream } = useStream()
  const [selectedCategory, setSelectedCategory] = useState<string>('main-stage')
  const [selectedStream, setSelectedStream] = useState<Stream | null>(null)
  const [showSubscriptionModal, setShowSubscriptionModal] = useState(false)
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid')
  const [sortBy, setSortBy] = useState<'viewers' | 'recent' | 'alphabetical'>('viewers')

  const { data: streams, isLoading } = useQuery<Stream[]>(
    ['streams', selectedCategory],
    () => api.get(`/streams?category=${selectedCategory}&live=true`).then(res => res.data),
    {
      refetchInterval: 30000, // Refetch every 30 seconds
      staleTime: 10000, // Consider data stale after 10 seconds
    }
  )

  const { data: userSubscription } = useQuery(
    'current-subscription',
    () => api.get('/subscriptions/current').then(res => res.data),
    {
      enabled: !!user,
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  )

  const canAccessCategory = (requiredTier: string) => {
    if (!user) return requiredTier === 'floor-pass'
    if (!userSubscription) return requiredTier === 'floor-pass'
    
    const tierHierarchy = {
      'floor-pass': 1,
      'backstage-pass': 2,
      'vip-lounge': 3,
      'champagne-room': 4,
      'black-card': 5
    }
    
    const userTierLevel = tierHierarchy[userSubscription.tier as keyof typeof tierHierarchy] || 0
    const requiredTierLevel = tierHierarchy[requiredTier as keyof typeof tierHierarchy] || 0
    
    return userTierLevel >= requiredTierLevel
  }

  const handleStreamSelect = (stream: Stream) => {
    if (!canAccessCategory(stream.requiredTier)) {
      toast.error(`This stream requires ${stream.requiredTier.replace('-', ' ')} subscription or higher`)
      setShowSubscriptionModal(true)
      return
    }

    setSelectedStream(stream)
    joinStream(stream.id)
  }

  const handleCloseStream = () => {
    if (selectedStream) {
      leaveStream(selectedStream.id)
    }
    setSelectedStream(null)
  }

  const sortedStreams = streams?.sort((a, b) => {
    switch (sortBy) {
      case 'viewers':
        return b.viewerCount - a.viewerCount
      case 'recent':
        return new Date(b.startedAt).getTime() - new Date(a.startedAt).getTime()
      case 'alphabetical':
        return a.title.localeCompare(b.title)
      default:
        return 0
    }
  }) || []

  const formatDuration = (startedAt: string) => {
    const start = new Date(startedAt)
    const now = new Date()
    const diff = now.getTime() - start.getTime()
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
    return `${hours}h ${minutes}m`
  }

  if (selectedStream) {
    return (
      <div className="min-h-screen bg-club-dark">
        {/* Stream Header */}
        <div className="bg-black/50 backdrop-blur-sm border-b border-white/10 p-4">
          <div className="max-w-7xl mx-auto flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <button
                onClick={handleCloseStream}
                className="p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
              >
                ← Back
              </button>
              <div>
                <h1 className="text-xl font-display font-bold text-white">
                  {selectedStream.title}
                </h1>
                <p className="text-gray-400 text-sm">
                  {selectedStream.performer.displayName} • {selectedStream.viewerCount} viewers
                </p>
              </div>
            </div>
            <div className="flex items-center space-x-2">
              <span className="px-3 py-1 bg-red-500 text-white text-sm font-semibold rounded-full">
                LIVE
              </span>
              {selectedStream.isVREnabled && (
                <span className="px-3 py-1 bg-blue-500 text-white text-sm font-semibold rounded-full">
                  VR
                </span>
              )}
              {selectedStream.is360 && (
                <span className="px-3 py-1 bg-purple-500 text-white text-sm font-semibold rounded-full">
                  360°
                </span>
              )}
            </div>
          </div>
        </div>

        {/* Stream Content */}
        <div className="max-w-7xl mx-auto p-4">
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
            {/* Video Player */}
            <div className="lg:col-span-3">
              <div className="aspect-video bg-black rounded-lg overflow-hidden">
                {selectedStream.streamUrl ? (
                  <VRStreamViewer
                    streamId={selectedStream.id}
                    streamUrl={selectedStream.streamUrl}
                    isVREnabled={selectedStream.isVREnabled}
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gray-900">
                    <div className="text-center">
                      <div className="loading-spinner w-12 h-12 mx-auto mb-4" />
                      <p className="text-white">Connecting to stream...</p>
                    </div>
                  </div>
                )}
              </div>

              {/* Stream Info */}
              <div className="mt-6 glass-dark rounded-lg p-6">
                <h2 className="text-2xl font-display font-bold text-white mb-2">
                  {selectedStream.title}
                </h2>
                <p className="text-gray-300 mb-4">{selectedStream.description}</p>
                <div className="flex flex-wrap gap-2">
                  {selectedStream.tags.map((tag) => (
                    <span
                      key={tag}
                      className="px-3 py-1 bg-neon-pink/20 text-neon-pink text-sm rounded-full"
                    >
                      #{tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Sidebar */}
            <div className="space-y-6">
              {/* Performer Info */}
              <div className="glass-dark rounded-lg p-4">
                <div className="flex items-center space-x-3 mb-4">
                  {selectedStream.performer.avatar ? (
                    <img
                      src={selectedStream.performer.avatar}
                      alt={selectedStream.performer.displayName}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                  ) : (
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-neon-pink to-neon-purple flex items-center justify-center text-white font-bold">
                      {selectedStream.performer.displayName.charAt(0)}
                    </div>
                  )}
                  <div>
                    <h3 className="text-white font-semibold">
                      {selectedStream.performer.displayName}
                    </h3>
                    <p className="text-gray-400 text-sm">
                      @{selectedStream.performer.username}
                    </p>
                  </div>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-400">Live for:</span>
                  <span className="text-white">{formatDuration(selectedStream.startedAt)}</span>
                </div>
              </div>

              {/* Tipping Interface */}
              <TippingInterface
                performerId={selectedStream.performer.id}
                streamId={selectedStream.id}
              />
            </div>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-club-dark">
      {/* Header */}
      <div className="bg-black/50 backdrop-blur-sm border-b border-white/10">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="text-4xl font-display font-bold gradient-text mb-2">
                Live Streams
              </h1>
              <p className="text-gray-300">
                Experience the future of adult entertainment with VR and 360° streaming
              </p>
            </div>
            <div className="flex items-center space-x-4">
              {/* View Mode Toggle */}
              <div className="flex bg-gray-800 rounded-lg p-1">
                <button
                  onClick={() => setViewMode('grid')}
                  className={cn(
                    'px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200',
                    viewMode === 'grid'
                      ? 'bg-neon-pink text-white'
                      : 'text-gray-400 hover:text-white'
                  )}
                >
                  Grid
                </button>
                <button
                  onClick={() => setViewMode('list')}
                  className={cn(
                    'px-3 py-2 rounded-md text-sm font-medium transition-colors duration-200',
                    viewMode === 'list'
                      ? 'bg-neon-pink text-white'
                      : 'text-gray-400 hover:text-white'
                  )}
                >
                  List
                </button>
              </div>

              {/* Sort Options */}
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as any)}
                className="bg-gray-800 text-white rounded-lg px-3 py-2 text-sm border border-gray-700 focus:border-neon-pink focus:outline-none"
              >
                <option value="viewers">Most Viewers</option>
                <option value="recent">Recently Started</option>
                <option value="alphabetical">Alphabetical</option>
              </select>
            </div>
          </div>

          {/* Category Tabs */}
          <div className="flex space-x-1 overflow-x-auto pb-2">
            {streamCategories.map((category) => {
              const hasAccess = canAccessCategory(category.requiredTier)
              return (
                <button
                  key={category.id}
                  onClick={() => {
                    if (hasAccess) {
                      setSelectedCategory(category.id)
                    } else {
                      toast.error(`Requires ${category.requiredTier.replace('-', ' ')} subscription`)
                      setShowSubscriptionModal(true)
                    }
                  }}
                  className={cn(
                    'flex items-center space-x-2 px-4 py-3 rounded-lg font-semibold transition-all duration-300 whitespace-nowrap',
                    selectedCategory === category.id
                      ? `bg-gradient-to-r ${category.bgGradient} border border-white/20 text-white`
                      : hasAccess
                      ? 'bg-gray-800 text-gray-300 hover:text-white hover:bg-gray-700'
                      : 'bg-gray-900 text-gray-500 cursor-not-allowed opacity-50'
                  )}
                >
                  <span className="text-xl">{category.icon}</span>
                  <div className="text-left">
                    <div className={cn('font-semibold', category.color)}>
                      {category.name}
                    </div>
                    <div className="text-xs text-gray-400">
                      {category.description}
                    </div>
                  </div>
                  {!hasAccess && (
                    <span className="text-xs bg-red-500 text-white px-2 py-1 rounded-full">
                      🔒
                    </span>
                  )}
                </button>
              )
            })}
          </div>
        </div>
      </div>

      {/* Streams Grid/List */}
      <div className="max-w-7xl mx-auto px-4 py-8">
        {isLoading ? (
          <div className="flex items-center justify-center min-h-[400px]">
            <div className="loading-spinner w-12 h-12" />
          </div>
        ) : sortedStreams.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-6xl mb-4">🎭</div>
            <h3 className="text-xl font-display font-bold text-white mb-2">
              No live streams in this category
            </h3>
            <p className="text-gray-400">
              Check back later or explore other categories
            </p>
          </div>
        ) : (
          <div className={cn(
            viewMode === 'grid'
              ? 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'
              : 'space-y-4'
          )}>
            {sortedStreams.map((stream) => (
              <div
                key={stream.id}
                onClick={() => handleStreamSelect(stream)}
                className={cn(
                  'stream-card cursor-pointer group',
                  viewMode === 'list' && 'flex items-center space-x-4 p-4'
                )}
              >
                {/* Thumbnail */}
                <div className={cn(
                  'relative overflow-hidden',
                  viewMode === 'grid' ? 'aspect-video' : 'w-32 h-20 flex-shrink-0',
                  'bg-gray-900 rounded-lg'
                )}>
                  {stream.thumbnail ? (
                    <img
                      src={stream.thumbnail}
                      alt={stream.title}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center bg-gradient-to-br from-gray-800 to-gray-900">
                      <span className="text-4xl">{streamCategories.find(c => c.id === stream.category)?.icon}</span>
                    </div>
                  )}
                  
                  {/* Live Badge */}
                  <div className="absolute top-2 left-2 flex space-x-1">
                    <span className="px-2 py-1 bg-red-500 text-white text-xs font-semibold rounded">
                      LIVE
                    </span>
                    {stream.isVREnabled && (
                      <span className="px-2 py-1 bg-blue-500 text-white text-xs font-semibold rounded">
                        VR
                      </span>
                    )}
                    {stream.is360 && (
                      <span className="px-2 py-1 bg-purple-500 text-white text-xs font-semibold rounded">
                        360°
                      </span>
                    )}
                  </div>
                  
                  {/* Viewer Count */}
                  <div className="absolute bottom-2 right-2 bg-black/70 text-white text-xs px-2 py-1 rounded">
                    👥 {stream.viewerCount}
                  </div>
                </div>

                {/* Stream Info */}
                <div className={cn(
                  viewMode === 'grid' ? 'p-4' : 'flex-1'
                )}>
                  <h3 className="text-white font-semibold mb-1 group-hover:text-neon-pink transition-colors duration-200">
                    {stream.title}
                  </h3>
                  <p className="text-gray-400 text-sm mb-2 line-clamp-2">
                    {stream.description}
                  </p>
                  <div className="flex items-center justify-between">
                    <span className="text-neon-pink text-sm font-semibold">
                      {stream.performer.displayName}
                    </span>
                    <span className="text-gray-500 text-xs">
                      {formatDuration(stream.startedAt)}
                    </span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Subscription Modal */}
      {showSubscriptionModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm">
          <div className="max-w-6xl w-full mx-4 max-h-[90vh] overflow-y-auto">
            <div className="relative">
              <button
                onClick={() => setShowSubscriptionModal(false)}
                className="absolute top-4 right-4 z-10 p-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-white transition-colors duration-200"
              >
                ✕
              </button>
              <SubscriptionTiers />
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

export default StreamsPage
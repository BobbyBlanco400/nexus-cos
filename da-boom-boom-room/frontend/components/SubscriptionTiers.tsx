'use client'

import React, { useState } from 'react'
import { useAuth } from '@/contexts/AuthContext'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { api } from '@/lib/api'
import { loadStripe } from '@stripe/stripe-js'
import { toast } from 'react-hot-toast'
import { cn } from '@/lib/utils'

interface SubscriptionTier {
  id: string
  name: string
  price: number
  interval: 'month' | 'year'
  features: string[]
  stripePriceId: string
  description: string
  popular?: boolean
  tier: 'floor-pass' | 'backstage-pass' | 'vip-lounge' | 'champagne-room' | 'black-card'
}

const tierStyles = {
  'floor-pass': 'tier-floor',
  'backstage-pass': 'tier-backstage', 
  'vip-lounge': 'tier-vip',
  'champagne-room': 'tier-champagne',
  'black-card': 'tier-black'
}

const tierIcons = {
  'floor-pass': '🎫',
  'backstage-pass': '🎭',
  'vip-lounge': '👑',
  'champagne-room': '🥂',
  'black-card': '💎'
}

export function SubscriptionTiers() {
  const { user } = useAuth()
  const queryClient = useQueryClient()
  const [selectedInterval, setSelectedInterval] = useState<'month' | 'year'>('month')
  const [loading, setLoading] = useState<string | null>(null)

  const { data: tiers, isLoading } = useQuery<SubscriptionTier[]>(
    'subscription-tiers',
    () => api.get('/subscriptions/tiers').then(res => res.data),
    {
      staleTime: 10 * 60 * 1000, // 10 minutes
    }
  )

  const { data: currentSubscription } = useQuery(
    'current-subscription',
    () => api.get('/subscriptions/current').then(res => res.data),
    {
      enabled: !!user,
      staleTime: 5 * 60 * 1000, // 5 minutes
    }
  )

  const checkoutMutation = useMutation(
    async (priceId: string) => {
      const response = await api.post('/subscriptions/checkout', {
        priceId,
        successUrl: `${window.location.origin}/subscription/success`,
        cancelUrl: `${window.location.origin}/subscription/cancel`
      })
      return response.data
    },
    {
      onSuccess: async (data) => {
        const stripe = await loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
        if (stripe && data.sessionId) {
          await stripe.redirectToCheckout({ sessionId: data.sessionId })
        }
      },
      onError: (error: any) => {
        toast.error(error.response?.data?.message || 'Failed to start checkout')
        setLoading(null)
      }
    }
  )

  const handleSubscribe = async (tier: SubscriptionTier) => {
    if (!user) {
      toast.error('Please sign in to subscribe')
      return
    }

    setLoading(tier.id)
    await checkoutMutation.mutateAsync(tier.stripePriceId)
  }

  const filteredTiers = tiers?.filter(tier => tier.interval === selectedInterval) || []

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="loading-spinner w-12 h-12" />
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-4 py-12">
      {/* Header */}
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-6xl font-display font-bold gradient-text mb-4">
          Choose Your Experience
        </h1>
        <p className="text-xl text-gray-300 max-w-3xl mx-auto">
          Unlock exclusive content, VR experiences, and premium features with our subscription tiers
        </p>
      </div>

      {/* Interval Toggle */}
      <div className="flex justify-center mb-12">
        <div className="glass-dark rounded-lg p-1 flex">
          <button
            onClick={() => setSelectedInterval('month')}
            className={cn(
              'px-6 py-3 rounded-md font-semibold transition-all duration-300',
              selectedInterval === 'month'
                ? 'bg-neon-pink text-white shadow-lg'
                : 'text-gray-400 hover:text-white'
            )}
          >
            Monthly
          </button>
          <button
            onClick={() => setSelectedInterval('year')}
            className={cn(
              'px-6 py-3 rounded-md font-semibold transition-all duration-300 relative',
              selectedInterval === 'year'
                ? 'bg-neon-pink text-white shadow-lg'
                : 'text-gray-400 hover:text-white'
            )}
          >
            Yearly
            <span className="absolute -top-2 -right-2 bg-neon-yellow text-black text-xs px-2 py-1 rounded-full font-bold">
              Save 20%
            </span>
          </button>
        </div>
      </div>

      {/* Subscription Tiers */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
        {filteredTiers.map((tier) => {
          const isCurrentTier = currentSubscription?.tier === tier.tier
          const isUpgrade = currentSubscription && !isCurrentTier
          
          return (
            <div
              key={tier.id}
              className={cn(
                'tier-card relative',
                tierStyles[tier.tier],
                tier.popular && 'ring-2 ring-neon-pink ring-opacity-50',
                isCurrentTier && 'ring-2 ring-neon-green ring-opacity-75'
              )}
            >
              {tier.popular && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                  <span className="bg-neon-pink text-white px-4 py-1 rounded-full text-sm font-bold">
                    Most Popular
                  </span>
                </div>
              )}
              
              {isCurrentTier && (
                <div className="absolute -top-3 right-4">
                  <span className="bg-neon-green text-black px-3 py-1 rounded-full text-sm font-bold">
                    Current
                  </span>
                </div>
              )}

              <div className="text-center mb-6">
                <div className="text-4xl mb-2">{tierIcons[tier.tier]}</div>
                <h3 className="text-xl font-display font-bold text-white mb-2">
                  {tier.name}
                </h3>
                <p className="text-gray-400 text-sm mb-4">{tier.description}</p>
                <div className="text-3xl font-bold text-white mb-1">
                  ${tier.price}
                  <span className="text-lg text-gray-400">/{tier.interval}</span>
                </div>
              </div>

              <ul className="space-y-3 mb-8">
                {tier.features.map((feature, index) => (
                  <li key={index} className="flex items-center text-sm text-gray-300">
                    <svg className="w-4 h-4 text-neon-green mr-3 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                    {feature}
                  </li>
                ))}
              </ul>

              <button
                onClick={() => handleSubscribe(tier)}
                disabled={loading === tier.id || isCurrentTier}
                className={cn(
                  'w-full py-3 rounded-lg font-semibold transition-all duration-300 transform hover:scale-105',
                  isCurrentTier
                    ? 'bg-gray-600 text-gray-400 cursor-not-allowed'
                    : 'club-button hover:shadow-lg',
                  loading === tier.id && 'opacity-50 cursor-not-allowed'
                )}
              >
                {loading === tier.id ? (
                  <div className="flex items-center justify-center">
                    <div className="loading-spinner w-5 h-5 mr-2" />
                    Processing...
                  </div>
                ) : isCurrentTier ? (
                  'Current Plan'
                ) : isUpgrade ? (
                  'Upgrade'
                ) : (
                  'Subscribe'
                )}
              </button>
            </div>
          )
        })}
      </div>

      {/* Features Comparison */}
      <div className="mt-16">
        <h2 className="text-3xl font-display font-bold text-center gradient-text mb-8">
          Feature Comparison
        </h2>
        <div className="glass-dark rounded-lg p-6 overflow-x-auto">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-white/10">
                <th className="text-left py-4 px-4 text-white font-semibold">Features</th>
                {filteredTiers.map(tier => (
                  <th key={tier.id} className="text-center py-4 px-4 text-white font-semibold">
                    {tierIcons[tier.tier]} {tier.name}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="text-gray-300">
              <tr className="border-b border-white/5">
                <td className="py-3 px-4">Live Stream Access</td>
                {filteredTiers.map(tier => (
                  <td key={tier.id} className="text-center py-3 px-4">
                    <svg className="w-5 h-5 text-neon-green mx-auto" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                  </td>
                ))}
              </tr>
              <tr className="border-b border-white/5">
                <td className="py-3 px-4">VR Experience</td>
                {filteredTiers.map(tier => (
                  <td key={tier.id} className="text-center py-3 px-4">
                    {['vip-lounge', 'champagne-room', 'black-card'].includes(tier.tier) ? (
                      <svg className="w-5 h-5 text-neon-green mx-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    ) : (
                      <span className="text-gray-500">—</span>
                    )}
                  </td>
                ))}
              </tr>
              <tr className="border-b border-white/5">
                <td className="py-3 px-4">Private Shows</td>
                {filteredTiers.map(tier => (
                  <td key={tier.id} className="text-center py-3 px-4">
                    {['champagne-room', 'black-card'].includes(tier.tier) ? (
                      <svg className="w-5 h-5 text-neon-green mx-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    ) : (
                      <span className="text-gray-500">—</span>
                    )}
                  </td>
                ))}
              </tr>
              <tr>
                <td className="py-3 px-4">NFT Membership</td>
                {filteredTiers.map(tier => (
                  <td key={tier.id} className="text-center py-3 px-4">
                    {tier.tier === 'black-card' ? (
                      <svg className="w-5 h-5 text-neon-green mx-auto" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    ) : (
                      <span className="text-gray-500">—</span>
                    )}
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}

export default SubscriptionTiers
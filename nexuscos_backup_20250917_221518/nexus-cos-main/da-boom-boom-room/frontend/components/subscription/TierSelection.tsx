'use client'

import React, { useState } from 'react'
import { SUBSCRIPTION_TIERS, formatPrice, type SubscriptionTier } from '@/lib/subscription-tiers'
import { redirectToCheckout } from '@/lib/stripe-checkout'
import { cn } from '@/lib/utils'

interface TierSelectionProps {
  onSelectTier?: (tier: SubscriptionTier) => void
  currentTierLevel?: number
}

export function TierSelection({ onSelectTier, currentTierLevel = 0 }: TierSelectionProps) {
  const [selectedTier, setSelectedTier] = useState<string | null>(null)
  const [isAnnual, setIsAnnual] = useState(false)

  const handleSelectTier = async (tier: SubscriptionTier) => {
    setSelectedTier(tier.id)
    onSelectTier?.(tier)
    
    // Redirect to Stripe checkout
    try {
      await redirectToCheckout(tier, isAnnual)
    } catch (error) {
      console.error('Checkout failed:', error)
      alert('Checkout failed. Please try again.')
      setSelectedTier(null)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-purple-900 to-black p-4">
      {/* Header */}
      <div className="text-center mb-12">
        <h1 className="text-5xl font-bold bg-gradient-to-r from-pink-500 via-purple-500 to-cyan-500 bg-clip-text text-transparent mb-4">
          Choose Your Experience
        </h1>
        <p className="text-xl text-gray-300 max-w-2xl mx-auto">
          Unlock exclusive content, VR experiences, and premium features with our membership tiers
        </p>
        
        {/* Billing Toggle */}
        <div className="flex items-center justify-center mt-8 space-x-4">
          <span className={cn('text-lg', !isAnnual ? 'text-white' : 'text-gray-400')}>Monthly</span>
          <button
            onClick={() => setIsAnnual(!isAnnual)}
            className="relative inline-flex h-6 w-11 items-center rounded-full bg-gray-600 transition-colors focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2"
          >
            <span
              className={cn(
                'inline-block h-4 w-4 transform rounded-full bg-white transition-transform',
                isAnnual ? 'translate-x-6' : 'translate-x-1'
              )}
            />
          </button>
          <span className={cn('text-lg', isAnnual ? 'text-white' : 'text-gray-400')}>Annual</span>
          {isAnnual && (
            <span className="bg-gradient-to-r from-green-400 to-emerald-500 text-black px-3 py-1 rounded-full text-sm font-semibold">
              Save 20%
            </span>
          )}
        </div>
      </div>

      {/* Tier Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6 max-w-7xl mx-auto">
        {SUBSCRIPTION_TIERS.map((tier, index) => {
          const isSelected = selectedTier === tier.id
          const isCurrent = tier.accessLevel === currentTierLevel
          const isUpgrade = tier.accessLevel > currentTierLevel
          const price = isAnnual ? tier.price * 12 * 0.8 : tier.price
          
          return (
            <div
              key={tier.id}
              className={cn(
                'relative rounded-2xl p-6 transition-all duration-300 cursor-pointer transform hover:scale-105',
                'border-2 backdrop-blur-sm',
                isSelected
                  ? 'border-white shadow-2xl shadow-purple-500/50'
                  : 'border-gray-700 hover:border-gray-500',
                isCurrent && 'ring-2 ring-green-500',
                tier.popular && 'ring-2 ring-yellow-400',
                `bg-gradient-to-br ${tier.gradient} bg-opacity-20`
              )}
              onClick={() => handleSelectTier(tier)}
            >
              {/* Popular Badge */}
              {tier.popular && (
                <div className="absolute -top-3 left-1/2 transform -translate-x-1/2">
                  <span className="bg-gradient-to-r from-yellow-400 to-orange-500 text-black px-4 py-1 rounded-full text-sm font-bold">
                    MOST POPULAR
                  </span>
                </div>
              )}

              {/* Current Tier Badge */}
              {isCurrent && (
                <div className="absolute -top-3 right-4">
                  <span className="bg-green-500 text-white px-3 py-1 rounded-full text-xs font-bold">
                    CURRENT
                  </span>
                </div>
              )}

              {/* Tier Header */}
              <div className="text-center mb-6">
                <div className="text-4xl mb-2">{tier.icon}</div>
                <h3 className="text-2xl font-bold text-white mb-2">{tier.name}</h3>
                <p className="text-gray-300 text-sm">{tier.description}</p>
              </div>

              {/* Pricing */}
              <div className="text-center mb-6">
                <div className="text-4xl font-bold text-white mb-1">
                  {formatPrice(price)}
                </div>
                <div className="text-gray-400 text-sm">
                  per {isAnnual ? 'year' : 'month'}
                  {isAnnual && (
                    <span className="block text-green-400 text-xs">
                      (Save {formatPrice(tier.price * 12 * 0.2)}/year)
                    </span>
                  )}
                </div>
              </div>

              {/* Features */}
              <div className="space-y-3 mb-6">
                {tier.features.map((feature, featureIndex) => (
                  <div key={featureIndex} className="flex items-start space-x-2">
                    <div className="w-5 h-5 rounded-full bg-gradient-to-r from-green-400 to-emerald-500 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <svg className="w-3 h-3 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                      </svg>
                    </div>
                    <span className="text-gray-300 text-sm">{feature}</span>
                  </div>
                ))}
              </div>

              {/* Action Button */}
              <button
                className={cn(
                  'w-full py-3 px-4 rounded-lg font-semibold transition-all duration-200',
                  isCurrent
                    ? 'bg-gray-600 text-gray-300 cursor-not-allowed'
                    : isUpgrade
                    ? `bg-gradient-to-r ${tier.gradient} text-white hover:shadow-lg hover:shadow-purple-500/50`
                    : 'bg-gray-700 text-gray-400 cursor-not-allowed',
                  isSelected && 'ring-2 ring-white'
                )}
                disabled={isCurrent || (!isUpgrade && currentTierLevel > 0)}
              >
                {isCurrent
                  ? 'Current Plan'
                  : isUpgrade
                  ? 'Upgrade Now'
                  : 'Downgrade'}
              </button>
            </div>
          )
        })}
      </div>

      {/* Bottom CTA */}
      <div className="text-center mt-12">
        <p className="text-gray-400 mb-4">
          All plans include 24/7 support and a 30-day money-back guarantee
        </p>
        <div className="flex justify-center space-x-4">
          <span className="text-2xl">🔒</span>
          <span className="text-2xl">💳</span>
          <span className="text-2xl">🎯</span>
          <span className="text-2xl">🚀</span>
        </div>
      </div>
    </div>
  )
}
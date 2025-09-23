'use client'

import React from 'react'
import { TierSelection } from '@/components/subscription/TierSelection'
import { type SubscriptionTier } from '@/lib/subscription-tiers'

export default function SubscriptionPage() {
  const handleSelectTier = (tier: SubscriptionTier) => {
    console.log('Selected tier:', tier)
    // TODO: Implement Stripe checkout
    alert(`Selected ${tier.name} - Stripe integration coming soon!`)
  }

  return (
    <div className="min-h-screen">
      <TierSelection onSelectTier={handleSelectTier} currentTierLevel={0} />
    </div>
  )
}
import { loadStripe } from '@stripe/stripe-js'
import { type SubscriptionTier } from './subscription-tiers'

const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY || ''
)

export interface CheckoutSessionData {
  tierId: string
  tierName: string
  price: number
  interval: 'month' | 'year'
  userId?: string
  successUrl?: string
  cancelUrl?: string
}

export async function createCheckoutSession(data: CheckoutSessionData) {
  try {
    const response = await fetch('/api/stripe/create-checkout-session', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    })

    if (!response.ok) {
      throw new Error('Failed to create checkout session')
    }

    const { sessionId } = await response.json()
    
    const stripe = await stripePromise
    if (!stripe) {
      throw new Error('Stripe failed to load')
    }

    const { error } = await stripe.redirectToCheckout({ sessionId })
    
    if (error) {
      throw error
    }
  } catch (error) {
    console.error('Checkout error:', error)
    throw error
  }
}

export async function createPortalSession(customerId: string) {
  try {
    const response = await fetch('/api/stripe/create-portal-session', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ customerId }),
    })

    if (!response.ok) {
      throw new Error('Failed to create portal session')
    }

    const { url } = await response.json()
    window.location.href = url
  } catch (error) {
    console.error('Portal error:', error)
    throw error
  }
}

export function redirectToCheckout(tier: SubscriptionTier, isAnnual = false) {
  const checkoutData: CheckoutSessionData = {
    tierId: tier.id,
    tierName: tier.name,
    price: isAnnual ? tier.price * 12 * 0.8 : tier.price,
    interval: isAnnual ? 'year' : 'month',
    successUrl: `${window.location.origin}/subscription/success?tier=${tier.id}`,
    cancelUrl: `${window.location.origin}/subscription?canceled=true`,
  }

  return createCheckoutSession(checkoutData)
}
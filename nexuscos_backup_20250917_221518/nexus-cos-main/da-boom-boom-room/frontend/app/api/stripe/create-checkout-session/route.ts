import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { SUBSCRIPTION_TIERS } from '@/lib/subscription-tiers'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-06-20',
})

export async function POST(request: NextRequest) {
  try {
    const { tierId, tierName, price, interval, userId, successUrl, cancelUrl } = await request.json()

    // Find the tier to get the Stripe price ID
    const tier = SUBSCRIPTION_TIERS.find(t => t.id === tierId)
    if (!tier) {
      return NextResponse.json(
        { error: 'Invalid tier ID' },
        { status: 400 }
      )
    }

    // Create checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: {
              name: tierName,
              description: tier.description,
              images: [], // Add tier images if available
            },
            unit_amount: Math.round(price * 100), // Convert to cents
            recurring: {
              interval: interval as 'month' | 'year',
            },
          },
          quantity: 1,
        },
      ],
      mode: 'subscription',
      success_url: successUrl || `${process.env.NEXT_PUBLIC_BASE_URL}/subscription/success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: cancelUrl || `${process.env.NEXT_PUBLIC_BASE_URL}/subscription?canceled=true`,
      metadata: {
        tierId,
        userId: userId || 'anonymous',
      },
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      customer_creation: 'always',
    })

    return NextResponse.json({ sessionId: session.id })
  } catch (error) {
    console.error('Stripe checkout error:', error)
    return NextResponse.json(
      { error: 'Failed to create checkout session' },
      { status: 500 }
    )
  }
}
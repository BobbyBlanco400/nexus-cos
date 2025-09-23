import { NextRequest, NextResponse } from 'next/server'
import Stripe from 'stripe'
import { headers } from 'next/headers'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2024-06-20',
})

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || ''

export async function POST(request: NextRequest) {
  try {
    const body = await request.text()
    const headersList = headers()
    const signature = headersList.get('stripe-signature')

    if (!signature) {
      return NextResponse.json(
        { error: 'Missing stripe-signature header' },
        { status: 400 }
      )
    }

    let event: Stripe.Event

    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
    } catch (err) {
      console.error('Webhook signature verification failed:', err)
      return NextResponse.json(
        { error: 'Invalid signature' },
        { status: 400 }
      )
    }

    // Handle the event
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session
        console.log('Checkout session completed:', session.id)
        
        // TODO: Update user subscription in database
        // const { tierId, userId } = session.metadata || {}
        // await updateUserSubscription(userId, tierId, session.customer)
        
        break
      }
      
      case 'customer.subscription.created': {
        const subscription = event.data.object as Stripe.Subscription
        console.log('Subscription created:', subscription.id)
        
        // TODO: Handle new subscription
        // await handleSubscriptionCreated(subscription)
        
        break
      }
      
      case 'customer.subscription.updated': {
        const subscription = event.data.object as Stripe.Subscription
        console.log('Subscription updated:', subscription.id)
        
        // TODO: Handle subscription update
        // await handleSubscriptionUpdated(subscription)
        
        break
      }
      
      case 'customer.subscription.deleted': {
        const subscription = event.data.object as Stripe.Subscription
        console.log('Subscription deleted:', subscription.id)
        
        // TODO: Handle subscription cancellation
        // await handleSubscriptionCanceled(subscription)
        
        break
      }
      
      case 'invoice.payment_succeeded': {
        const invoice = event.data.object as Stripe.Invoice
        console.log('Payment succeeded:', invoice.id)
        
        // TODO: Handle successful payment
        // await handlePaymentSucceeded(invoice)
        
        break
      }
      
      case 'invoice.payment_failed': {
        const invoice = event.data.object as Stripe.Invoice
        console.log('Payment failed:', invoice.id)
        
        // TODO: Handle failed payment
        // await handlePaymentFailed(invoice)
        
        break
      }
      
      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    return NextResponse.json({ received: true })
  } catch (error) {
    console.error('Webhook error:', error)
    return NextResponse.json(
      { error: 'Webhook handler failed' },
      { status: 500 }
    )
  }
}

// TODO: Implement these functions when database is set up
/*
async function updateUserSubscription(userId: string, tierId: string, customerId: string) {
  // Update user's subscription tier in database
}

async function handleSubscriptionCreated(subscription: Stripe.Subscription) {
  // Handle new subscription logic
}

async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  // Handle subscription update logic
}

async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  // Handle subscription cancellation logic
}

async function handlePaymentSucceeded(invoice: Stripe.Invoice) {
  // Handle successful payment logic
}

async function handlePaymentFailed(invoice: Stripe.Invoice) {
  // Handle failed payment logic
}
*/
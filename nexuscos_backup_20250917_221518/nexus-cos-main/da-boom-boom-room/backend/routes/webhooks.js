/**
 * Webhook Routes
 * Handles Stripe webhooks for payments and subscription updates
 */

const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { PrismaClient } = require('@prisma/client');
const { logger } = require('../utils/logger');

const router = express.Router();
const prisma = new PrismaClient();

const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

/**
 * POST /webhooks/stripe
 * Handle Stripe webhook events
 */
router.post('/stripe', express.raw({ type: 'application/json' }), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
  } catch (err) {
    logger.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  logger.info('Stripe webhook received:', {
    type: event.type,
    id: event.id,
    created: event.created
  });

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;
      
      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object);
        break;
      
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      
      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object);
        break;
      
      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object);
        break;
      
      default:
        logger.info(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    logger.error('Webhook processing error:', error);
    res.status(500).json({ error: 'Webhook processing failed' });
  }
});

/**
 * Handle successful checkout session
 */
async function handleCheckoutCompleted(session) {
  logger.info('Processing checkout completion:', {
    sessionId: session.id,
    customerId: session.customer,
    mode: session.mode
  });

  const userId = session.metadata?.userId;
  if (!userId) {
    logger.error('No userId in checkout session metadata');
    return;
  }

  if (session.mode === 'subscription') {
    // Handle subscription checkout
    const subscription = await stripe.subscriptions.retrieve(session.subscription);
    await updateUserSubscription(userId, subscription, session.metadata?.tier);
  }
}

/**
 * Handle subscription creation
 */
async function handleSubscriptionCreated(subscription) {
  logger.info('Processing subscription creation:', {
    subscriptionId: subscription.id,
    customerId: subscription.customer,
    status: subscription.status
  });

  const userId = subscription.metadata?.userId;
  const tier = subscription.metadata?.tier;
  
  if (userId && tier) {
    await updateUserSubscription(userId, subscription, tier);
  }
}

/**
 * Handle subscription updates
 */
async function handleSubscriptionUpdated(subscription) {
  logger.info('Processing subscription update:', {
    subscriptionId: subscription.id,
    status: subscription.status,
    cancelAtPeriodEnd: subscription.cancel_at_period_end
  });

  const userId = subscription.metadata?.userId;
  const tier = subscription.metadata?.tier;
  
  if (userId) {
    await updateUserSubscription(userId, subscription, tier);
  }
}

/**
 * Handle subscription deletion
 */
async function handleSubscriptionDeleted(subscription) {
  logger.info('Processing subscription deletion:', {
    subscriptionId: subscription.id,
    customerId: subscription.customer
  });

  const userId = subscription.metadata?.userId;
  
  if (userId) {
    await prisma.user.update({
      where: { id: userId },
      data: {
        subscriptionTier: 'NONE',
        subscriptionStatus: 'CANCELED',
        subscriptionEnd: new Date(),
        subscriptionId: null
      }
    });

    logger.logPayment('subscription_deleted', userId, 0, 'canceled', {
      subscriptionId: subscription.id
    });
  }
}

/**
 * Handle successful payment
 */
async function handlePaymentSucceeded(invoice) {
  logger.info('Processing payment success:', {
    invoiceId: invoice.id,
    subscriptionId: invoice.subscription,
    amountPaid: invoice.amount_paid / 100
  });

  if (invoice.subscription) {
    // Subscription payment
    const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
    const userId = subscription.metadata?.userId;
    
    if (userId) {
      // Ensure subscription is active
      await prisma.user.update({
        where: { id: userId },
        data: {
          subscriptionStatus: 'ACTIVE'
        }
      });

      logger.logPayment('subscription_payment_success', userId, invoice.amount_paid / 100, 'success', {
        invoiceId: invoice.id,
        subscriptionId: invoice.subscription
      });
    }
  }
}

/**
 * Handle failed payment
 */
async function handlePaymentFailed(invoice) {
  logger.warn('Processing payment failure:', {
    invoiceId: invoice.id,
    subscriptionId: invoice.subscription,
    attemptCount: invoice.attempt_count
  });

  if (invoice.subscription) {
    const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
    const userId = subscription.metadata?.userId;
    
    if (userId) {
      // Update subscription status to past due
      await prisma.user.update({
        where: { id: userId },
        data: {
          subscriptionStatus: 'PAST_DUE'
        }
      });

      logger.logPayment('subscription_payment_failed', userId, invoice.amount_due / 100, 'failed', {
        invoiceId: invoice.id,
        subscriptionId: invoice.subscription,
        attemptCount: invoice.attempt_count
      });
    }
  }
}

/**
 * Handle successful payment intent (wallet deposits)
 */
async function handlePaymentIntentSucceeded(paymentIntent) {
  logger.info('Processing payment intent success:', {
    paymentIntentId: paymentIntent.id,
    amount: paymentIntent.amount / 100,
    type: paymentIntent.metadata?.type
  });

  if (paymentIntent.metadata?.type === 'wallet_deposit') {
    const userId = paymentIntent.metadata?.userId;
    const amount = paymentIntent.amount / 100;
    
    if (userId) {
      await prisma.$transaction(async (tx) => {
        // Update user wallet balance
        await tx.user.update({
          where: { id: userId },
          data: {
            walletBalance: { increment: amount }
          }
        });

        // Update transaction status
        await tx.walletTransaction.updateMany({
          where: {
            stripePaymentId: paymentIntent.id,
            status: 'PENDING'
          },
          data: {
            status: 'COMPLETED',
            processedAt: new Date()
          }
        });
      });

      logger.logPayment('wallet_deposit_success', userId, amount, 'success', {
        paymentIntentId: paymentIntent.id
      });
    }
  }
}

/**
 * Handle failed payment intent
 */
async function handlePaymentIntentFailed(paymentIntent) {
  logger.warn('Processing payment intent failure:', {
    paymentIntentId: paymentIntent.id,
    amount: paymentIntent.amount / 100,
    type: paymentIntent.metadata?.type
  });

  if (paymentIntent.metadata?.type === 'wallet_deposit') {
    const userId = paymentIntent.metadata?.userId;
    
    if (userId) {
      // Update transaction status to failed
      await prisma.walletTransaction.updateMany({
        where: {
          stripePaymentId: paymentIntent.id,
          status: 'PENDING'
        },
        data: {
          status: 'FAILED'
        }
      });

      logger.logPayment('wallet_deposit_failed', userId, paymentIntent.amount / 100, 'failed', {
        paymentIntentId: paymentIntent.id
      });
    }
  }
}

/**
 * Update user subscription in database
 */
async function updateUserSubscription(userId, subscription, tier) {
  const subscriptionStatus = mapStripeStatus(subscription.status);
  const subscriptionStart = new Date(subscription.current_period_start * 1000);
  const subscriptionEnd = new Date(subscription.current_period_end * 1000);

  await prisma.user.update({
    where: { id: userId },
    data: {
      subscriptionTier: tier || 'FLOOR_PASS',
      subscriptionStatus,
      subscriptionStart,
      subscriptionEnd,
      subscriptionId: subscription.id
    }
  });

  logger.logPayment('subscription_updated', userId, 0, 'updated', {
    tier: tier || 'FLOOR_PASS',
    status: subscriptionStatus,
    subscriptionId: subscription.id,
    periodStart: subscriptionStart,
    periodEnd: subscriptionEnd
  });
}

/**
 * Map Stripe subscription status to our internal status
 */
function mapStripeStatus(stripeStatus) {
  const statusMap = {
    'active': 'ACTIVE',
    'past_due': 'PAST_DUE',
    'canceled': 'CANCELED',
    'unpaid': 'UNPAID',
    'incomplete': 'INACTIVE',
    'incomplete_expired': 'INACTIVE',
    'trialing': 'ACTIVE'
  };

  return statusMap[stripeStatus] || 'INACTIVE';
}

/**
 * GET /webhooks/test
 * Test endpoint for webhook functionality (development only)
 */
if (process.env.NODE_ENV === 'development') {
  router.get('/test', async (req, res) => {
    res.json({
      message: 'Webhook endpoint is working',
      environment: process.env.NODE_ENV,
      timestamp: new Date().toISOString()
    });
  });
}

module.exports = router;
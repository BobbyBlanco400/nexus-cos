const Wallet = require('../models/Wallet');
const User = require('../models/User');
const UserSubscription = require('../models/UserSubscription');
const { AppError } = require('../utils/errors');
const logger = require('../utils/logger');
const stripeService = require('../services/stripeService');
const emailService = require('../services/emailService');
const socketService = require('../services/socketService');
const analyticsService = require('../services/analyticsService');

/**
 * Get current user's wallet
 */
const getWallet = async (req, res, next) => {
  try {
    let wallet = await Wallet.findByUserId(req.user.id);
    
    // Create wallet if it doesn't exist
    if (!wallet) {
      wallet = await Wallet.createForUser(req.user.id);
    }
    
    res.status(200).json({
      success: true,
      data: {
        wallet: {
          id: wallet._id,
          balance: wallet.balance,
          availableBalance: wallet.availableBalance,
          pendingBalance: wallet.pendingBalance,
          lifetimeEarnings: wallet.lifetimeEarnings,
          lifetimeSpending: wallet.lifetimeSpending,
          currency: wallet.currency,
          status: wallet.status,
          isVerified: wallet.isVerified,
          verificationLevel: wallet.verificationLevel,
          limits: wallet.limits,
          payoutSettings: wallet.payoutSettings,
          lastActivity: wallet.lastActivity
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get wallet balance
 */
const getBalance = async (req, res, next) => {
  try {
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    res.status(200).json({
      success: true,
      data: {
        balance: wallet.balance,
        availableBalance: wallet.availableBalance,
        pendingBalance: wallet.pendingBalance,
        formattedBalance: wallet.formattedBalance,
        formattedAvailableBalance: wallet.formattedAvailableBalance
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get transaction history
 */
const getTransactions = async (req, res, next) => {
  try {
    const {
      type,
      startDate,
      endDate,
      page = 1,
      limit = 20
    } = req.query;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    let transactions = wallet.transactions;
    
    // Apply filters
    if (type) {
      transactions = transactions.filter(t => t.type === type);
    }
    
    if (startDate || endDate) {
      const start = startDate ? new Date(startDate) : new Date(0);
      const end = endDate ? new Date(endDate) : new Date();
      
      transactions = transactions.filter(t => 
        t.createdAt >= start && t.createdAt <= end
      );
    }
    
    // Sort by date (newest first)
    transactions.sort((a, b) => b.createdAt - a.createdAt);
    
    // Pagination
    const skip = (page - 1) * limit;
    const paginatedTransactions = transactions.slice(skip, skip + parseInt(limit));
    
    res.status(200).json({
      success: true,
      data: {
        transactions: paginatedTransactions,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: transactions.length,
          pages: Math.ceil(transactions.length / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get specific transaction
 */
const getTransaction = async (req, res, next) => {
  try {
    const { transactionId } = req.params;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    const transaction = wallet.transactions.id(transactionId);
    
    if (!transaction) {
      throw new AppError('Transaction not found', 404);
    }
    
    res.status(200).json({
      success: true,
      data: {
        transaction
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Create deposit intent
 */
const createDepositIntent = async (req, res, next) => {
  try {
    const { amount } = req.body;
    
    let wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      wallet = await Wallet.createForUser(req.user.id);
    }
    
    // Check daily and monthly limits
    if (!wallet.checkDailyLimits('deposit', amount)) {
      throw new AppError('Daily deposit limit exceeded', 400);
    }
    
    if (!wallet.checkMonthlyLimits('deposit', amount)) {
      throw new AppError('Monthly deposit limit exceeded', 400);
    }
    
    // Create Stripe payment intent
    const paymentIntent = await stripeService.createPaymentIntent({
      amount: Math.round(amount * 100), // Convert to cents
      currency: wallet.currency.toLowerCase(),
      customer: wallet.stripeCustomerId,
      metadata: {
        userId: req.user.id,
        walletId: wallet._id.toString(),
        type: 'wallet-deposit'
      }
    });
    
    logger.info(`Deposit intent created: ${paymentIntent.id} for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        amount
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Deposit funds
 */
const deposit = async (req, res, next) => {
  try {
    const { amount, paymentMethodId, savePaymentMethod = false } = req.body;
    
    let wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      wallet = await Wallet.createForUser(req.user.id);
    }
    
    // Check limits
    if (!wallet.checkDailyLimits('deposit', amount)) {
      throw new AppError('Daily deposit limit exceeded', 400);
    }
    
    if (!wallet.checkMonthlyLimits('deposit', amount)) {
      throw new AppError('Monthly deposit limit exceeded', 400);
    }
    
    // Process payment with Stripe
    const paymentResult = await stripeService.processPayment({
      amount: Math.round(amount * 100),
      currency: wallet.currency.toLowerCase(),
      paymentMethodId,
      customerId: wallet.stripeCustomerId,
      savePaymentMethod,
      metadata: {
        userId: req.user.id,
        type: 'wallet-deposit'
      }
    });
    
    if (paymentResult.status === 'succeeded') {
      // Add funds to wallet
      await wallet.deposit(amount, 'Credit card deposit', {
        stripePaymentId: paymentResult.id,
        paymentMethod: 'card'
      });
      
      // Send confirmation email
      await emailService.sendDepositConfirmation(req.user.email, {
        amount,
        transactionId: paymentResult.id,
        newBalance: wallet.balance
      });
      
      logger.info(`Deposit successful: $${amount} for user ${req.user.id}`);
      
      res.status(200).json({
        success: true,
        data: {
          transaction: {
            id: paymentResult.id,
            amount,
            status: 'completed',
            method: 'card'
          },
          wallet: {
            balance: wallet.balance,
            availableBalance: wallet.availableBalance
          }
        }
      });
    } else {
      throw new AppError('Payment failed', 400);
    }
  } catch (error) {
    next(error);
  }
};

/**
 * Confirm deposit (for Stripe webhooks)
 */
const confirmDeposit = async (req, res, next) => {
  try {
    const { paymentIntentId } = req.body;
    
    // Retrieve payment intent from Stripe
    const paymentIntent = await stripeService.retrievePaymentIntent(paymentIntentId);
    
    if (paymentIntent.status === 'succeeded') {
      const userId = paymentIntent.metadata.userId;
      const amount = paymentIntent.amount / 100; // Convert from cents
      
      const wallet = await Wallet.findByUserId(userId);
      
      if (!wallet) {
        throw new AppError('Wallet not found', 404);
      }
      
      // Add funds to wallet
      await wallet.deposit(amount, 'Credit card deposit', {
        stripePaymentId: paymentIntent.id,
        paymentMethod: 'card'
      });
      
      logger.info(`Deposit confirmed: $${amount} for user ${userId}`);
      
      res.status(200).json({
        success: true,
        data: {
          amount,
          newBalance: wallet.balance
        }
      });
    } else {
      throw new AppError('Payment not successful', 400);
    }
  } catch (error) {
    next(error);
  }
};

/**
 * Withdraw funds
 */
const withdraw = async (req, res, next) => {
  try {
    const { amount, method, details } = req.body;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    // Check if wallet is verified for withdrawals
    if (!wallet.isVerified) {
      throw new AppError('Wallet verification required for withdrawals', 403);
    }
    
    // Check limits
    if (!wallet.checkDailyLimits('withdrawal', amount)) {
      throw new AppError('Daily withdrawal limit exceeded', 400);
    }
    
    if (!wallet.checkMonthlyLimits('withdrawal', amount)) {
      throw new AppError('Monthly withdrawal limit exceeded', 400);
    }
    
    // Process withdrawal
    await wallet.withdraw(amount, `Withdrawal via ${method}`, {
      method,
      details
    });
    
    // Send confirmation email
    await emailService.sendWithdrawalConfirmation(req.user.email, {
      amount,
      method,
      newBalance: wallet.balance
    });
    
    logger.info(`Withdrawal processed: $${amount} for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        amount,
        method,
        newBalance: wallet.balance,
        availableBalance: wallet.availableBalance
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get payout requests
 */
const getPayouts = async (req, res, next) => {
  try {
    const {
      status,
      page = 1,
      limit = 20
    } = req.query;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    let payouts = wallet.payoutRequests;
    
    // Filter by status
    if (status) {
      payouts = payouts.filter(p => p.status === status);
    }
    
    // Sort by date (newest first)
    payouts.sort((a, b) => b.requestedAt - a.requestedAt);
    
    // Pagination
    const skip = (page - 1) * limit;
    const paginatedPayouts = payouts.slice(skip, skip + parseInt(limit));
    
    res.status(200).json({
      success: true,
      data: {
        payouts: paginatedPayouts,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: payouts.length,
          pages: Math.ceil(payouts.length / limit)
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Request payout
 */
const requestPayout = async (req, res, next) => {
  try {
    const { amount, method, details } = req.body;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    // Check if wallet is verified
    if (!wallet.isVerified) {
      throw new AppError('Wallet verification required for payouts', 403);
    }
    
    // Request payout
    await wallet.requestPayout(amount, method, details);
    
    // Send confirmation email
    await emailService.sendPayoutRequestConfirmation(req.user.email, {
      amount,
      method,
      estimatedProcessingTime: '1-3 business days'
    });
    
    logger.info(`Payout requested: $${amount} for user ${req.user.id}`);
    
    res.status(201).json({
      success: true,
      data: {
        message: 'Payout request submitted successfully',
        amount,
        method,
        estimatedProcessingTime: '1-3 business days'
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Cancel payout request
 */
const cancelPayout = async (req, res, next) => {
  try {
    const { payoutId } = req.params;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    const payout = wallet.payoutRequests.id(payoutId);
    
    if (!payout) {
      throw new AppError('Payout request not found', 404);
    }
    
    if (payout.status !== 'pending') {
      throw new AppError('Can only cancel pending payout requests', 400);
    }
    
    // Cancel payout
    await wallet.processPayout(payoutId, 'cancelled', null, req.user.id, 'Cancelled by user');
    
    logger.info(`Payout cancelled: ${payoutId} for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        message: 'Payout request cancelled successfully'
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get payout settings
 */
const getPayoutSettings = async (req, res, next) => {
  try {
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    res.status(200).json({
      success: true,
      data: {
        payoutSettings: wallet.payoutSettings
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update payout settings
 */
const updatePayoutSettings = async (req, res, next) => {
  try {
    const updates = req.body;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    // Update payout settings
    Object.assign(wallet.payoutSettings, updates);
    await wallet.save();
    
    logger.info(`Payout settings updated for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        payoutSettings: wallet.payoutSettings
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get wallet limits
 */
const getLimits = async (req, res, next) => {
  try {
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    res.status(200).json({
      success: true,
      data: {
        limits: wallet.limits
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update wallet limits
 */
const updateLimits = async (req, res, next) => {
  try {
    const updates = req.body;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      throw new AppError('Wallet not found', 404);
    }
    
    // Update limits
    Object.assign(wallet.limits, updates);
    await wallet.save();
    
    logger.info(`Wallet limits updated for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        limits: wallet.limits
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get payment methods
 */
const getPaymentMethods = async (req, res, next) => {
  try {
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet || !wallet.stripeCustomerId) {
      return res.status(200).json({
        success: true,
        data: {
          paymentMethods: []
        }
      });
    }
    
    // Get payment methods from Stripe
    const paymentMethods = await stripeService.getCustomerPaymentMethods(wallet.stripeCustomerId);
    
    res.status(200).json({
      success: true,
      data: {
        paymentMethods
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add payment method
 */
const addPaymentMethod = async (req, res, next) => {
  try {
    const { type, token } = req.body;
    
    let wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet) {
      wallet = await Wallet.createForUser(req.user.id);
    }
    
    // Create Stripe customer if needed
    if (!wallet.stripeCustomerId) {
      const customer = await stripeService.createCustomer({
        email: req.user.email,
        name: req.user.displayName || req.user.username,
        metadata: {
          userId: req.user.id
        }
      });
      
      wallet.stripeCustomerId = customer.id;
      await wallet.save();
    }
    
    // Add payment method
    const paymentMethod = await stripeService.attachPaymentMethod(token, wallet.stripeCustomerId);
    
    logger.info(`Payment method added for user ${req.user.id}`);
    
    res.status(201).json({
      success: true,
      data: {
        paymentMethod
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Remove payment method
 */
const removePaymentMethod = async (req, res, next) => {
  try {
    const { methodId } = req.params;
    
    // Detach payment method from Stripe
    await stripeService.detachPaymentMethod(methodId);
    
    logger.info(`Payment method removed for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        message: 'Payment method removed successfully'
      }
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Set default payment method
 */
const setDefaultPaymentMethod = async (req, res, next) => {
  try {
    const { methodId } = req.params;
    
    const wallet = await Wallet.findByUserId(req.user.id);
    
    if (!wallet || !wallet.stripeCustomerId) {
      throw new AppError('Wallet or Stripe customer not found', 404);
    }
    
    // Update default payment method in Stripe
    await stripeService.updateCustomerDefaultPaymentMethod(wallet.stripeCustomerId, methodId);
    
    logger.info(`Default payment method updated for user ${req.user.id}`);
    
    res.status(200).json({
      success: true,
      data: {
        message: 'Default payment method updated successfully'
      }
    });
  } catch (error) {
    next(error);
  }
};

// Additional controller functions would be implemented here:
// - getAnalytics
// - getSpendingBreakdown
// - getEarningsBreakdown
// - getVerificationStatus
// - uploadVerificationDocument
// - submitForVerification
// - getNotificationPreferences
// - updateNotificationPreferences
// - getAllWallets (admin)
// - getUserWallet (admin)
// - processPayout (admin)
// - suspendWallet (admin)
// - unsuspendWallet (admin)
// - adjustBalance (admin)
// - reviewVerificationDocument (admin)
// - getPlatformAnalytics (admin)
// - getTopEarners (admin)
// - exportTransactions (admin)
// - getPlatformStats

// Placeholder implementations for remaining functions
const getAnalytics = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getSpendingBreakdown = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getEarningsBreakdown = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getVerificationStatus = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const uploadVerificationDocument = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const submitForVerification = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getNotificationPreferences = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const updateNotificationPreferences = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getAllWallets = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getUserWallet = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const processPayout = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const suspendWallet = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const unsuspendWallet = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const adjustBalance = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const reviewVerificationDocument = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getPlatformAnalytics = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getTopEarners = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const exportTransactions = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

const getPlatformStats = async (req, res, next) => {
  res.status(501).json({ success: false, message: 'Not implemented yet' });
};

module.exports = {
  getWallet,
  getBalance,
  getTransactions,
  getTransaction,
  createDepositIntent,
  deposit,
  confirmDeposit,
  withdraw,
  getPayouts,
  requestPayout,
  cancelPayout,
  getPayoutSettings,
  updatePayoutSettings,
  getLimits,
  updateLimits,
  getPaymentMethods,
  addPaymentMethod,
  removePaymentMethod,
  setDefaultPaymentMethod,
  getAnalytics,
  getSpendingBreakdown,
  getEarningsBreakdown,
  getVerificationStatus,
  uploadVerificationDocument,
  submitForVerification,
  getNotificationPreferences,
  updateNotificationPreferences,
  getAllWallets,
  getUserWallet,
  processPayout,
  suspendWallet,
  unsuspendWallet,
  adjustBalance,
  reviewVerificationDocument,
  getPlatformAnalytics,
  getTopEarners,
  exportTransactions,
  getPlatformStats
};
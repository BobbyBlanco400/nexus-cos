const mongoose = require('mongoose');
const { Schema } = mongoose;

// Transaction subdocument schema
const transactionSchema = new Schema({
  type: {
    type: String,
    enum: [
      'deposit',
      'withdrawal',
      'tip-sent',
      'tip-received',
      'refund',
      'platform-fee',
      'subscription-payment',
      'payout',
      'bonus',
      'penalty',
      'adjustment'
    ],
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  description: {
    type: String,
    required: true,
    maxlength: 500
  },
  reference: {
    type: String, // External reference (Stripe payment ID, etc.)
    sparse: true
  },
  relatedTip: {
    type: Schema.Types.ObjectId,
    ref: 'Tip'
  },
  relatedStream: {
    type: Schema.Types.ObjectId,
    ref: 'Stream'
  },
  metadata: {
    stripePaymentId: String,
    stripeChargeId: String,
    paymentMethod: String,
    currency: {
      type: String,
      default: 'USD'
    },
    exchangeRate: Number,
    originalAmount: Number,
    originalCurrency: String,
    processingFee: Number,
    taxAmount: Number,
    location: {
      country: String,
      region: String
    }
  },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'completed'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  _id: true
});

// Payout request subdocument schema
const payoutRequestSchema = new Schema({
  amount: {
    type: Number,
    required: true,
    min: [10, 'Minimum payout amount is $10']
  },
  method: {
    type: String,
    enum: ['bank-transfer', 'paypal', 'stripe', 'crypto'],
    required: true
  },
  details: {
    // Bank transfer details
    bankName: String,
    accountNumber: String,
    routingNumber: String,
    accountHolderName: String,
    
    // PayPal details
    paypalEmail: String,
    
    // Crypto details
    walletAddress: String,
    cryptocurrency: String,
    
    // Additional verification
    taxId: String,
    address: {
      street: String,
      city: String,
      state: String,
      zipCode: String,
      country: String
    }
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed', 'cancelled'],
    default: 'pending'
  },
  requestedAt: {
    type: Date,
    default: Date.now
  },
  processedAt: Date,
  processedBy: {
    type: Schema.Types.ObjectId,
    ref: 'User'
  },
  externalReference: String, // Stripe transfer ID, PayPal transaction ID, etc.
  failureReason: String,
  notes: String
}, {
  _id: true
});

// Main wallet schema
const walletSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
    index: true
  },
  
  // Balance information
  balance: {
    type: Number,
    default: 0,
    min: [0, 'Wallet balance cannot be negative'],
    set: v => Math.round(v * 100) / 100 // Round to 2 decimal places
  },
  
  // Pending balance (tips/earnings not yet available for withdrawal)
  pendingBalance: {
    type: Number,
    default: 0,
    min: 0,
    set: v => Math.round(v * 100) / 100
  },
  
  // Total lifetime earnings (for performers)
  lifetimeEarnings: {
    type: Number,
    default: 0,
    min: 0,
    set: v => Math.round(v * 100) / 100
  },
  
  // Total lifetime spending (for users)
  lifetimeSpending: {
    type: Number,
    default: 0,
    min: 0,
    set: v => Math.round(v * 100) / 100
  },
  
  // Currency
  currency: {
    type: String,
    default: 'USD',
    enum: ['USD', 'EUR', 'GBP', 'CAD', 'AUD']
  },
  
  // Transaction history
  transactions: [transactionSchema],
  
  // Payout information (for performers)
  payoutRequests: [payoutRequestSchema],
  
  // Payout settings
  payoutSettings: {
    minimumPayout: {
      type: Number,
      default: 50,
      min: 10
    },
    autoPayoutEnabled: {
      type: Boolean,
      default: false
    },
    autoPayoutThreshold: {
      type: Number,
      default: 100,
      min: 50
    },
    preferredPayoutMethod: {
      type: String,
      enum: ['bank-transfer', 'paypal', 'stripe', 'crypto'],
      default: 'stripe'
    },
    payoutSchedule: {
      type: String,
      enum: ['weekly', 'bi-weekly', 'monthly'],
      default: 'weekly'
    }
  },
  
  // Security and verification
  isVerified: {
    type: Boolean,
    default: false
  },
  verificationLevel: {
    type: String,
    enum: ['none', 'basic', 'enhanced', 'premium'],
    default: 'none'
  },
  verificationDocuments: [{
    type: {
      type: String,
      enum: ['id', 'passport', 'drivers-license', 'utility-bill', 'bank-statement']
    },
    url: String,
    status: {
      type: String,
      enum: ['pending', 'approved', 'rejected'],
      default: 'pending'
    },
    uploadedAt: {
      type: Date,
      default: Date.now
    },
    reviewedAt: Date,
    reviewedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    rejectionReason: String
  }],
  
  // Limits and restrictions
  limits: {
    dailyDepositLimit: {
      type: Number,
      default: 1000
    },
    dailyWithdrawalLimit: {
      type: Number,
      default: 500
    },
    monthlyDepositLimit: {
      type: Number,
      default: 10000
    },
    monthlyWithdrawalLimit: {
      type: Number,
      default: 5000
    },
    singleTransactionLimit: {
      type: Number,
      default: 500
    }
  },
  
  // Spending tracking (for analytics)
  monthlySpending: {
    type: Map,
    of: Number,
    default: new Map()
  },
  
  // Earnings tracking (for performers)
  monthlyEarnings: {
    type: Map,
    of: Number,
    default: new Map()
  },
  
  // Wallet status
  status: {
    type: String,
    enum: ['active', 'suspended', 'frozen', 'closed'],
    default: 'active',
    index: true
  },
  
  // Suspension/freeze information
  suspension: {
    reason: String,
    suspendedBy: {
      type: Schema.Types.ObjectId,
      ref: 'User'
    },
    suspendedAt: Date,
    expiresAt: Date,
    notes: String
  },
  
  // Tax information
  taxInfo: {
    taxId: String,
    taxForm: {
      type: String,
      enum: ['W9', '1099', 'W8BEN', 'other']
    },
    taxYear: Number,
    isBusinessAccount: {
      type: Boolean,
      default: false
    },
    businessName: String,
    businessType: String
  },
  
  // Notification preferences
  notifications: {
    emailOnDeposit: {
      type: Boolean,
      default: true
    },
    emailOnWithdrawal: {
      type: Boolean,
      default: true
    },
    emailOnTipReceived: {
      type: Boolean,
      default: true
    },
    emailOnPayoutProcessed: {
      type: Boolean,
      default: true
    },
    pushNotifications: {
      type: Boolean,
      default: true
    }
  },
  
  // Metadata
  lastActivity: {
    type: Date,
    default: Date.now
  },
  
  // Stripe customer information
  stripeCustomerId: {
    type: String,
    sparse: true
  },
  stripeAccountId: {
    type: String,
    sparse: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
walletSchema.index({ userId: 1 }, { unique: true });
walletSchema.index({ status: 1 });
walletSchema.index({ 'transactions.createdAt': -1 });
walletSchema.index({ 'transactions.type': 1 });
walletSchema.index({ 'payoutRequests.status': 1 });
walletSchema.index({ 'payoutRequests.requestedAt': -1 });
walletSchema.index({ balance: -1 });
walletSchema.index({ lifetimeEarnings: -1 });

// Virtuals

// Available balance (balance - pending)
walletSchema.virtual('availableBalance').get(function() {
  return Math.max(0, this.balance - this.pendingBalance);
});

// Total balance (balance + pending)
walletSchema.virtual('totalBalance').get(function() {
  return this.balance + this.pendingBalance;
});

// Formatted balance
walletSchema.virtual('formattedBalance').get(function() {
  return `$${this.balance.toFixed(2)}`;
});

// Formatted available balance
walletSchema.virtual('formattedAvailableBalance').get(function() {
  return `$${this.availableBalance.toFixed(2)}`;
});

// Recent transactions (last 10)
walletSchema.virtual('recentTransactions').get(function() {
  return this.transactions
    .sort((a, b) => b.createdAt - a.createdAt)
    .slice(0, 10);
});

// Pending payout requests
walletSchema.virtual('pendingPayouts').get(function() {
  return this.payoutRequests.filter(request => 
    ['pending', 'processing'].includes(request.status)
  );
});

// Instance methods

// Add transaction
walletSchema.methods.addTransaction = function(transactionData) {
  const transaction = {
    ...transactionData,
    createdAt: new Date()
  };
  
  this.transactions.push(transaction);
  this.lastActivity = new Date();
  
  // Update monthly tracking
  const monthKey = new Date().toISOString().substring(0, 7); // YYYY-MM
  
  if (transaction.amount > 0 && ['tip-received', 'bonus'].includes(transaction.type)) {
    // Earnings
    const currentEarnings = this.monthlyEarnings.get(monthKey) || 0;
    this.monthlyEarnings.set(monthKey, currentEarnings + transaction.amount);
    this.lifetimeEarnings += transaction.amount;
  } else if (transaction.amount < 0 && ['tip-sent', 'withdrawal'].includes(transaction.type)) {
    // Spending
    const currentSpending = this.monthlySpending.get(monthKey) || 0;
    this.monthlySpending.set(monthKey, currentSpending + Math.abs(transaction.amount));
    this.lifetimeSpending += Math.abs(transaction.amount);
  }
  
  return this.save();
};

// Deposit funds
walletSchema.methods.deposit = function(amount, description, metadata = {}) {
  this.balance += amount;
  
  return this.addTransaction({
    type: 'deposit',
    amount,
    description,
    metadata,
    status: 'completed'
  });
};

// Withdraw funds
walletSchema.methods.withdraw = function(amount, description, metadata = {}) {
  if (this.availableBalance < amount) {
    throw new Error('Insufficient available balance');
  }
  
  this.balance -= amount;
  
  return this.addTransaction({
    type: 'withdrawal',
    amount: -amount,
    description,
    metadata,
    status: 'completed'
  });
};

// Send tip
walletSchema.methods.sendTip = function(amount, recipientId, tipId, description) {
  if (this.balance < amount) {
    throw new Error('Insufficient balance');
  }
  
  this.balance -= amount;
  
  return this.addTransaction({
    type: 'tip-sent',
    amount: -amount,
    description,
    relatedTip: tipId,
    status: 'completed'
  });
};

// Receive tip
walletSchema.methods.receiveTip = function(amount, senderId, tipId, description) {
  this.balance += amount;
  
  return this.addTransaction({
    type: 'tip-received',
    amount,
    description,
    relatedTip: tipId,
    status: 'completed'
  });
};

// Request payout
walletSchema.methods.requestPayout = function(amount, method, details) {
  if (this.availableBalance < amount) {
    throw new Error('Insufficient available balance');
  }
  
  if (amount < this.payoutSettings.minimumPayout) {
    throw new Error(`Minimum payout amount is $${this.payoutSettings.minimumPayout}`);
  }
  
  const payoutRequest = {
    amount,
    method,
    details,
    status: 'pending',
    requestedAt: new Date()
  };
  
  this.payoutRequests.push(payoutRequest);
  this.pendingBalance += amount;
  this.balance -= amount;
  
  return this.save();
};

// Process payout
walletSchema.methods.processPayout = function(payoutId, status, externalReference, processedBy, failureReason) {
  const payout = this.payoutRequests.id(payoutId);
  if (!payout) {
    throw new Error('Payout request not found');
  }
  
  payout.status = status;
  payout.processedAt = new Date();
  payout.processedBy = processedBy;
  payout.externalReference = externalReference;
  
  if (status === 'completed') {
    // Remove from pending balance
    this.pendingBalance -= payout.amount;
    
    // Add transaction record
    this.addTransaction({
      type: 'payout',
      amount: -payout.amount,
      description: `Payout via ${payout.method}`,
      reference: externalReference,
      status: 'completed'
    });
  } else if (status === 'failed' || status === 'cancelled') {
    // Return funds to available balance
    this.balance += payout.amount;
    this.pendingBalance -= payout.amount;
    payout.failureReason = failureReason;
  }
  
  return this.save();
};

// Check daily limits
walletSchema.methods.checkDailyLimits = function(type, amount) {
  const today = new Date();
  const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  
  const todayTransactions = this.transactions.filter(t => 
    t.createdAt >= startOfDay && t.type === type
  );
  
  const todayTotal = todayTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
  
  const limit = type === 'deposit' ? this.limits.dailyDepositLimit : this.limits.dailyWithdrawalLimit;
  
  return (todayTotal + amount) <= limit;
};

// Check monthly limits
walletSchema.methods.checkMonthlyLimits = function(type, amount) {
  const today = new Date();
  const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
  
  const monthTransactions = this.transactions.filter(t => 
    t.createdAt >= startOfMonth && t.type === type
  );
  
  const monthTotal = monthTransactions.reduce((sum, t) => sum + Math.abs(t.amount), 0);
  
  const limit = type === 'deposit' ? this.limits.monthlyDepositLimit : this.limits.monthlyWithdrawalLimit;
  
  return (monthTotal + amount) <= limit;
};

// Suspend wallet
walletSchema.methods.suspend = function(reason, suspendedBy, expiresAt, notes) {
  this.status = 'suspended';
  this.suspension = {
    reason,
    suspendedBy,
    suspendedAt: new Date(),
    expiresAt,
    notes
  };
  
  return this.save();
};

// Unsuspend wallet
walletSchema.methods.unsuspend = function() {
  this.status = 'active';
  this.suspension = undefined;
  
  return this.save();
};

// Static methods

// Find wallet by user ID
walletSchema.statics.findByUserId = function(userId) {
  return this.findOne({ userId });
};

// Create wallet for user
walletSchema.statics.createForUser = function(userId, initialData = {}) {
  return this.create({
    userId,
    ...initialData
  });
};

// Get top earners
walletSchema.statics.getTopEarners = function(period = 'monthly', limit = 10) {
  const monthKey = new Date().toISOString().substring(0, 7);
  
  if (period === 'monthly') {
    return this.find({
      [`monthlyEarnings.${monthKey}`]: { $exists: true, $gt: 0 }
    })
    .sort({ [`monthlyEarnings.${monthKey}`]: -1 })
    .limit(limit)
    .populate('userId', 'username displayName avatar isVerified');
  } else {
    return this.find({ lifetimeEarnings: { $gt: 0 } })
      .sort({ lifetimeEarnings: -1 })
      .limit(limit)
      .populate('userId', 'username displayName avatar isVerified');
  }
};

// Get platform statistics
walletSchema.statics.getPlatformStats = function() {
  return this.aggregate([
    {
      $group: {
        _id: null,
        totalWallets: { $sum: 1 },
        totalBalance: { $sum: '$balance' },
        totalPendingBalance: { $sum: '$pendingBalance' },
        totalLifetimeEarnings: { $sum: '$lifetimeEarnings' },
        totalLifetimeSpending: { $sum: '$lifetimeSpending' },
        activeWallets: {
          $sum: {
            $cond: [{ $eq: ['$status', 'active'] }, 1, 0]
          }
        },
        verifiedWallets: {
          $sum: {
            $cond: ['$isVerified', 1, 0]
          }
        }
      }
    }
  ]);
};

// Pre-save middleware
walletSchema.pre('save', function(next) {
  // Ensure balance precision
  this.balance = Math.round(this.balance * 100) / 100;
  this.pendingBalance = Math.round(this.pendingBalance * 100) / 100;
  this.lifetimeEarnings = Math.round(this.lifetimeEarnings * 100) / 100;
  this.lifetimeSpending = Math.round(this.lifetimeSpending * 100) / 100;
  
  // Update last activity
  this.lastActivity = new Date();
  
  next();
});

// Post-save middleware
walletSchema.post('save', function(doc) {
  // Emit socket events for real-time balance updates
  const socketService = require('../services/socketService');
  
  socketService.notifyUser(doc.userId, 'wallet_updated', {
    balance: doc.balance,
    availableBalance: doc.availableBalance,
    pendingBalance: doc.pendingBalance,
    lastTransaction: doc.recentTransactions[0]
  });
});

module.exports = mongoose.model('Wallet', walletSchema);
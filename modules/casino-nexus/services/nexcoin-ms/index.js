const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 9501;

// Load purchase tiers configuration
const TIERS_CONFIG_PATH = path.join(__dirname, '../../../config/nexcoin-purchase-tiers.json');
let purchaseTiersConfig = {};
try {
  purchaseTiersConfig = JSON.parse(fs.readFileSync(TIERS_CONFIG_PATH, 'utf8'));
} catch (error) {
  console.error('Warning: Could not load purchase tiers config:', error.message);
  purchaseTiersConfig = { founder_beta_tiers: { enabled: false }, standard_tiers: { enabled: true, packages: [] } };
}

app.use(cors());
app.use(express.json());

// Wallet metadata configuration (read-only)
const WALLET_METADATA = Object.freeze({
  wallet_type: 'closed_loop',
  redeemable: false,
  platform_credit: true,
  cash_value: false
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'nexcoin-ms',
    timestamp: new Date().toISOString(),
    wallet_metadata: WALLET_METADATA
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'NEXCOIN Token Management Service',
    version: '1.0.0',
    wallet_metadata: WALLET_METADATA
  });
});

// Wallet metadata endpoint (read-only)
app.get('/api/wallet/metadata', (req, res) => {
  res.json({
    ...WALLET_METADATA,
    description: 'NexCoin Wallet is a closed-loop platform credit system',
    legal_notice: 'NexCoin has no cash value and is not redeemable for fiat currency'
  });
});

// Tokenomics info
app.get('/api/tokenomics', (req, res) => {
  res.json({
    ticker: '$NEXCOIN',
    totalSupply: 1000000000,
    distribution: {
      playerRewards: { percentage: 50, amount: 500000000 },
      ecosystemFund: { percentage: 25, amount: 250000000 },
      foundersStaff: { percentage: 15, amount: 150000000, vesting: true },
      liquidityReserve: { percentage: 10, amount: 100000000 }
    },
    utility: [
      'Entry fees for tournaments',
      'NFT marketplace purchases',
      'Exclusive tournament access',
      'VR experiences',
      'Metaverse property'
    ],
    deflationMechanism: 'Small percentage of every transaction is burned',
    blockchain: 'Polygon/Solana (low-gas, high-speed)'
  });
});

// Balance check (placeholder)
app.get('/api/balance/:userId', (req, res) => {
  res.json({
    userId: req.params.userId,
    balance: 0,
    message: 'Wallet integration coming soon'
  });
});

// Transaction history (placeholder)
app.get('/api/transactions/:userId', (req, res) => {
  res.json({
    userId: req.params.userId,
    transactions: [],
    message: 'Transaction history coming soon'
  });
});

// Purchase tiers endpoint
app.get('/api/purchase-tiers', (req, res) => {
  const userRole = req.query.role || null;
  const currentDate = new Date();
  const betaEndDate = new Date(purchaseTiersConfig.founder_beta_tiers?.beta_end_date || '2025-01-01');
  
  let availableTiers = {
    standard: purchaseTiersConfig.standard_tiers?.packages || []
  };
  
  // Add founder tiers if user has founder_beta role and beta is active
  if (userRole === 'founder_beta' && 
      purchaseTiersConfig.founder_beta_tiers?.enabled && 
      currentDate < betaEndDate) {
    availableTiers.founder_beta = purchaseTiersConfig.founder_beta_tiers.packages;
    availableTiers.beta_info = {
      active: true,
      end_date: purchaseTiersConfig.founder_beta_tiers.beta_end_date,
      restrictions: purchaseTiersConfig.founder_beta_tiers.restrictions
    };
  }
  
  res.json({
    available_tiers: availableTiers,
    user_role: userRole,
    message: 'Available purchase tiers for your account'
  });
});

// Purchase validation endpoint
app.post('/api/purchase/validate', (req, res) => {
  const { userId, tierId, userRole } = req.body;
  
  if (!userId || !tierId) {
    return res.status(400).json({
      valid: false,
      error: 'Missing required fields: userId, tierId'
    });
  }
  
  const currentDate = new Date();
  const betaEndDate = new Date(purchaseTiersConfig.founder_beta_tiers?.beta_end_date || '2025-01-01');
  
  // Check if tier exists in founder beta packages
  const founderTier = purchaseTiersConfig.founder_beta_tiers?.packages?.find(
    pkg => pkg.tier === tierId
  );
  
  if (founderTier) {
    // Validate founder beta requirements
    if (!purchaseTiersConfig.founder_beta_tiers.enabled) {
      return res.json({
        valid: false,
        error: 'Founder beta program is not currently active'
      });
    }
    
    if (currentDate >= betaEndDate) {
      return res.json({
        valid: false,
        error: 'Founder beta period has ended'
      });
    }
    
    if (userRole !== 'founder_beta') {
      return res.json({
        valid: false,
        error: 'This tier requires founder_beta role'
      });
    }
    
    return res.json({
      valid: true,
      tier: founderTier,
      restrictions: purchaseTiersConfig.founder_beta_tiers.restrictions
    });
  }
  
  // Check if tier exists in standard packages
  const standardTier = purchaseTiersConfig.standard_tiers?.packages?.find(
    pkg => pkg.tier === tierId
  );
  
  if (standardTier) {
    return res.json({
      valid: true,
      tier: standardTier,
      restrictions: null
    });
  }
  
  res.json({
    valid: false,
    error: 'Invalid tier ID'
  });
});

app.listen(PORT, () => {
  console.log(`💰 NEXCOIN Token Management Service running on port ${PORT}`);
});

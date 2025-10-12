const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9501;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'nexcoin-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'NEXCOIN Token Management Service',
    version: '1.0.0'
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

app.listen(PORT, () => {
  console.log(`💰 NEXCOIN Token Management Service running on port ${PORT}`);
});

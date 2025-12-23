const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9101;

// Wallet metadata configuration (read-only)
const WALLET_METADATA = Object.freeze({
  wallet_type: 'closed_loop',
  redeemable: false,
  platform_credit: true,
  cash_value: false
});

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'wallet-ms',
    timestamp: new Date().toISOString(),
    wallet_metadata: WALLET_METADATA
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'wallet-ms - Nexus COS Service',
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

app.listen(PORT, () => {
  console.log(`wallet-ms running on port ${PORT}`);
});

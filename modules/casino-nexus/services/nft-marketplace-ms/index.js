const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9502;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'nft-marketplace-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'NFT Marketplace Service - Casino-Nexus',
    version: '1.0.0'
  });
});

// NFT Categories
app.get('/api/categories', (req, res) => {
  res.json({
    categories: [
      {
        id: 'avatars',
        name: 'Avatars',
        description: 'Exclusive player avatars and skins'
      },
      {
        id: 'tables',
        name: 'Gaming Tables',
        description: 'Premium poker and blackjack tables'
      },
      {
        id: 'lounges',
        name: 'Private Lounges',
        description: 'User-owned private casino spaces'
      },
      {
        id: 'collectibles',
        name: 'Collectibles',
        description: 'Limited edition Casino-Nexus items'
      },
      {
        id: 'cosmetics',
        name: 'Cosmetic Skins',
        description: 'Visual upgrades and decorations'
      }
    ]
  });
});

// Featured NFTs (placeholder)
app.get('/api/nfts/featured', (req, res) => {
  res.json({
    featured: [],
    message: 'NFT listings coming soon'
  });
});

// NFT details (placeholder)
app.get('/api/nfts/:nftId', (req, res) => {
  res.json({
    nftId: req.params.nftId,
    message: 'NFT details coming soon'
  });
});

// User NFTs (placeholder)
app.get('/api/nfts/user/:userId', (req, res) => {
  res.json({
    userId: req.params.userId,
    nfts: [],
    message: 'User NFT collection coming soon'
  });
});

app.listen(PORT, () => {
  console.log(`🖼️  NFT Marketplace Service running on port ${PORT}`);
});

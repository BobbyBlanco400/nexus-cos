const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9500;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'casino-nexus-api',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'Casino-Nexus API - Virtual Crypto-Integrated Casino Universe',
    tagline: 'The Future of Immersive Web3 Gaming',
    version: '1.0.0',
    endpoints: {
      health: '/health',
      tokens: '/api/nexcoin',
      marketplace: '/api/marketplace',
      games: '/api/games',
      rewards: '/api/rewards',
      metaverse: '/api/metaverse'
    }
  });
});

// Casino-Nexus Info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    name: 'Casino-Nexus',
    description: 'Virtual Reality and browser-based online casino ecosystem',
    token: '$NEXCOIN',
    features: [
      'Skill-Based Games',
      'NFT Marketplace',
      'Play-to-Earn Rewards',
      'VR Metaverse (Casino-Nexus City)',
      'Blockchain Transparency',
      'Compliance-First Design'
    ],
    games: [
      'Nexus Poker (Skill-Based Tournaments)',
      '21X (Blackjack with Strategy Mechanics)',
      'Crypto Spin (Algorithmic Skill Wheel)',
      'Trivia Royale',
      'Metaverse Sportsbook'
    ],
    status: 'Phase 1 - Prototype'
  });
});

// Placeholder API routes
app.get('/api/nexcoin', (req, res) => {
  res.json({ message: 'NEXCOIN token service - Coming soon' });
});

app.get('/api/marketplace', (req, res) => {
  res.json({ message: 'NFT Marketplace - Coming soon' });
});

app.get('/api/games', (req, res) => {
  res.json({ message: 'Skill-based games - Coming soon' });
});

app.get('/api/rewards', (req, res) => {
  res.json({ message: 'Rewards & Leaderboards - Coming soon' });
});

app.get('/api/metaverse', (req, res) => {
  res.json({ message: 'VR Metaverse - Coming soon' });
});

app.listen(PORT, () => {
  console.log(`🎰 Casino-Nexus API running on port ${PORT}`);
  console.log(`🌐 Casino-Nexus: The Future of Immersive Web3 Gaming`);
});

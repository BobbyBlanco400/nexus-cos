const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 9505;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'vr-world-ms',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({ 
    message: 'VR Metaverse World Engine - Casino-Nexus City',
    version: '1.0.0'
  });
});

// Metaverse worlds
app.get('/api/worlds', (req, res) => {
  res.json({
    worlds: [
      {
        id: 'casino-nexus-city',
        name: 'Casino-Nexus City',
        description: 'Futuristic Las Vegas-style VR world',
        theme: 'Neon Cyberpunk Casino',
        capacity: 10000,
        features: [
          '3D Casino environments',
          'Interactive NPC dealers',
          'Live shows and events',
          'Social gathering spaces',
          'Private VIP areas'
        ],
        status: 'Phase 3 - In Development'
      },
      {
        id: 'nexus-clubs',
        name: 'Nexus Clubs',
        description: 'User-owned private lounges',
        theme: 'Premium VIP Experience',
        capacity: 50,
        features: [
          'Host private tournaments',
          'Customizable decor',
          'Exclusive member access',
          'Poker nights',
          'Event streaming'
        ],
        status: 'Phase 3 - Planned'
      },
      {
        id: 'crypto-tables',
        name: 'Crypto Tables',
        description: 'Blockchain-recorded gaming tables',
        theme: 'Transparent Gaming',
        capacity: 100,
        features: [
          'Fast-paced gameplay',
          'Blockchain transparency',
          'Provable fairness',
          'Transaction history',
          'Real-time verification'
        ],
        status: 'Phase 2 - Early Access'
      }
    ]
  });
});

// World status
app.get('/api/worlds/:worldId', (req, res) => {
  res.json({
    worldId: req.params.worldId,
    message: 'World details coming soon'
  });
});

// Active players in world
app.get('/api/worlds/:worldId/players', (req, res) => {
  res.json({
    worldId: req.params.worldId,
    players: [],
    message: 'Player tracking coming soon'
  });
});

app.listen(PORT, () => {
  console.log(`🌐 VR Metaverse World Engine running on port ${PORT}`);
});

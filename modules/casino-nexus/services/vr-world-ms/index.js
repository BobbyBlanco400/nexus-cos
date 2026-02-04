const express = require('express');
const cors = require('cors');
const { spawn } = require('child_process');
const path = require('path');

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
        status: 'Phase 3 - LIVE & ACTIVE'
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
        status: 'Phase 3 - LIVE & ACTIVE'
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
        status: 'Phase 2 - LIVE & ACTIVE'
      }
    ]
  });
});

// In-memory world state
const worlds = new Map();
const players = new Map();

// Initialize World State
const initWorld = (id) => {
  if (!worlds.has(id)) {
    worlds.set(id, {
      id,
      activePlayers: 0,
      status: 'active'
    });
  }
};

initWorld('casino-nexus-city');

// Join World
app.post('/api/worlds/join', (req, res) => {
  const { worldId, userId } = req.body;
  if (!worldId || !userId) return res.status(400).json({ error: 'Missing fields' });

  initWorld(worldId);
  players.set(userId, { userId, worldId, timestamp: new Date().toISOString() });
  
  const world = worlds.get(worldId);
  world.activePlayers++;
  
  res.json({
    success: true,
    message: `Joined ${worldId}`,
    worldState: world
  });
});

// World status
app.get('/api/worlds/:worldId', (req, res) => {
  const worldId = req.params.worldId;
  const world = worlds.get(worldId);
  
  if (!world) {
    // Return simulated state for uninitialized worlds (Mock Data for Frontend)
    return res.json({ 
      id: worldId, 
      activePlayers: Math.floor(Math.random() * 50) + 20, // Random 20-70
      status: 'active' 
    });
  }
  res.json(world);
});

// Active players in world
app.get('/api/worlds/:worldId/players', (req, res) => {
  const worldPlayers = Array.from(players.values()).filter(p => p.worldId === req.params.worldId);
  res.json({
    worldId: req.params.worldId,
    players: worldPlayers,
    count: worldPlayers.length
  });
});

// Launch VR Client
app.post('/api/client/launch', (req, res) => {
  console.log('🚀 Request received to launch VR Client...');
  
  const scriptPath = path.resolve(__dirname, '../../Launch-VR-Client.ps1');
  console.log(`Executing: powershell.exe -ExecutionPolicy Bypass -File "${scriptPath}"`);

  const child = spawn('powershell.exe', [
    '-ExecutionPolicy', 'Bypass',
    '-NoExit', // Keep window open so user can see it
    '-File', scriptPath
  ], {
    detached: true,
    stdio: 'ignore',
    shell: true
  });

  child.unref(); // Allow parent to continue without waiting

  res.json({
    success: true,
    message: 'VR Client Launched Successfully',
    path: scriptPath
  });
});

app.listen(PORT, () => {
  console.log(`🌐 VR Metaverse World Engine running on port ${PORT}`);
});

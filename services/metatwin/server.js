// Nexus COS - META-TWIN v2.5 Service
// Port: 3403
// AI Personality Engine for Nexus COS Platform
// N3XUS Handshake 55-45-17 Compliant

const express = require('express');
const WebSocket = require('ws');
const http = require('http');
const path = require('path');

const app = express();
const port = process.env.PORT || 3403;

// N3XUS Handshake Middleware (55-45-17)
const { setHandshakeResponse, validateHandshakeConditional } = require(path.join(__dirname, '../../middleware/handshake-validator'));

app.use(express.json());

// N3XUS Governance: Apply handshake to all responses and validate on all non-health endpoints
app.use(setHandshakeResponse);
app.use(validateHandshakeConditional);

// In-memory storage for MetaTwins (in production, use database)
const metaTwins = new Map();
const meshData = {
  activeConnections: 0,
  totalTwins: 0,
  lastSync: new Date().toISOString()
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'metatwin',
    version: '2.5.0',
    port: port,
    timestamp: new Date().toISOString(),
    activeTwins: metaTwins.size,
    meshStatus: 'online'
  });
});

// Service info endpoint
app.get('/', (req, res) => {
  res.json({
    service: 'META-TWIN v2.5',
    description: 'AI Personality Engine for Nexus COS',
    platform: 'Nexus COS PF v2025.10.01',
    framework: 'PUABO OS',
    integrationClass: 'System-Core Layer',
    endpoints: {
      create: 'POST /api/metatwin/create',
      train: 'POST /api/metatwin/train',
      link: 'POST /api/metatwin/link',
      deploy: 'POST /api/metatwin/deploy',
      streamConnect: 'WS /api/metatwin/live',
      meshSync: 'GET /api/metatwin/mesh',
      economyRegister: 'POST /api/metatwin/economy/register',
      list: 'GET /api/metatwin/list',
      get: 'GET /api/metatwin/:id'
    },
    modules: [
      'GC Live',
      'PUABO UNSIGNED',
      'PUABO TV',
      'Casino-Nexus',
      'Faith Through Fitness',
      'V-Screen Hollywood',
      'Club Saditty'
    ],
    port: port
  });
});

// Create MetaTwin
app.post('/api/metatwin/create', (req, res) => {
  try {
    const { name, voiceprint, behaviorMode, avatarType } = req.body;
    
    if (!name) {
      return res.status(400).json({ error: 'Name is required' });
    }

    const mtid = `MTID#${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
    
    const metaTwin = {
      id: mtid,
      name,
      voiceprint: voiceprint || null,
      behaviorMode: behaviorMode || 'default',
      avatarType: avatarType || '3D',
      status: 'created',
      createdAt: new Date().toISOString(),
      trainingStatus: 'pending',
      deploymentStatus: 'inactive',
      emotionSensitivity: 5,
      contextSwitching: true
    };

    metaTwins.set(mtid, metaTwin);
    meshData.totalTwins = metaTwins.size;

    res.status(201).json({
      success: true,
      message: 'MetaTwin created successfully',
      data: metaTwin
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Train MetaTwin
app.post('/api/metatwin/train', (req, res) => {
  try {
    const { mtid, voiceSample, behaviorPreset } = req.body;
    
    if (!mtid) {
      return res.status(400).json({ error: 'MTID is required' });
    }

    const metaTwin = metaTwins.get(mtid);
    if (!metaTwin) {
      return res.status(404).json({ error: 'MetaTwin not found' });
    }

    // Simulate training process
    metaTwin.trainingStatus = 'in-progress';
    metaTwin.voiceSample = voiceSample || null;
    metaTwin.behaviorPreset = behaviorPreset || metaTwin.behaviorMode;
    
    // Simulate completion
    setTimeout(() => {
      metaTwin.trainingStatus = 'completed';
      metaTwin.trainedAt = new Date().toISOString();
    }, 1000);

    metaTwins.set(mtid, metaTwin);

    res.json({
      success: true,
      message: 'MetaTwin training initiated',
      data: metaTwin
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Link MetaTwin to Module
app.post('/api/metatwin/link', (req, res) => {
  try {
    const { mtid, module, mode, context } = req.body;
    
    if (!mtid || !module) {
      return res.status(400).json({ error: 'MTID and module are required' });
    }

    const metaTwin = metaTwins.get(mtid);
    if (!metaTwin) {
      return res.status(404).json({ error: 'MetaTwin not found' });
    }

    const linkUrl = `mt-link://${module}/${mtid}?mode=${mode || 'default'}`;
    
    metaTwin.linkedModule = module;
    metaTwin.linkMode = mode || 'default';
    metaTwin.linkContext = context || {};
    metaTwin.linkUrl = linkUrl;
    metaTwin.linkedAt = new Date().toISOString();

    metaTwins.set(mtid, metaTwin);

    res.json({
      success: true,
      message: 'MetaTwin linked to module successfully',
      linkUrl: linkUrl,
      data: metaTwin
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Deploy MetaTwin
app.post('/api/metatwin/deploy', (req, res) => {
  try {
    const { mtid, environment } = req.body;
    
    if (!mtid) {
      return res.status(400).json({ error: 'MTID is required' });
    }

    const metaTwin = metaTwins.get(mtid);
    if (!metaTwin) {
      return res.status(404).json({ error: 'MetaTwin not found' });
    }

    if (metaTwin.trainingStatus !== 'completed') {
      return res.status(400).json({ 
        error: 'MetaTwin must be trained before deployment' 
      });
    }

    metaTwin.deploymentStatus = 'active';
    metaTwin.environment = environment || 'production';
    metaTwin.deployedAt = new Date().toISOString();

    metaTwins.set(mtid, metaTwin);

    res.json({
      success: true,
      message: 'MetaTwin deployed successfully',
      data: metaTwin
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get MetaTwin Intelligence Mesh status
app.get('/api/metatwin/mesh', (req, res) => {
  try {
    const activeTwins = Array.from(metaTwins.values())
      .filter(twin => twin.deploymentStatus === 'active');

    meshData.activeConnections = activeTwins.length;
    meshData.totalTwins = metaTwins.size;
    meshData.lastSync = new Date().toISOString();

    res.json({
      success: true,
      mesh: {
        status: 'online',
        network: 'MT-IM (MetaTwin Intelligence Mesh)',
        ...meshData,
        activeTwins: activeTwins.map(t => ({
          id: t.id,
          name: t.name,
          module: t.linkedModule,
          mode: t.linkMode
        })),
        capabilities: [
          'Linguistic data sharing',
          'Behavioral pattern sync',
          'Cultural trend adaptation',
          'Tone and style adaptation',
          'Real-time updates'
        ],
        encryption: 'AES-256 via PUABO OS CloudLayer'
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Register MetaTwin in Economy System
app.post('/api/metatwin/economy/register', (req, res) => {
  try {
    const { mtid, creatorWallet, licensingOptions } = req.body;
    
    if (!mtid) {
      return res.status(400).json({ error: 'MTID is required' });
    }

    const metaTwin = metaTwins.get(mtid);
    if (!metaTwin) {
      return res.status(404).json({ error: 'MetaTwin not found' });
    }

    metaTwin.economy = {
      registered: true,
      nftId: `NFT-${mtid}`,
      creatorWallet: creatorWallet || 'pending',
      royaltySplit: { creator: 80, puabo: 20 },
      licensingHub: licensingOptions || {},
      registeredAt: new Date().toISOString()
    };

    metaTwins.set(mtid, metaTwin);

    res.json({
      success: true,
      message: 'MetaTwin registered in economy system',
      data: {
        mtid: mtid,
        nftId: metaTwin.economy.nftId,
        royaltySplit: metaTwin.economy.royaltySplit
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// List all MetaTwins
app.get('/api/metatwin/list', (req, res) => {
  try {
    const twins = Array.from(metaTwins.values());
    res.json({
      success: true,
      count: twins.length,
      data: twins
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get specific MetaTwin
app.get('/api/metatwin/:id', (req, res) => {
  try {
    const metaTwin = metaTwins.get(req.params.id);
    if (!metaTwin) {
      return res.status(404).json({ error: 'MetaTwin not found' });
    }
    res.json({
      success: true,
      data: metaTwin
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Status endpoint
app.get('/status', (req, res) => {
  res.json({
    service: 'metatwin',
    version: '2.5.0',
    status: 'running',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    port: port,
    stats: {
      totalTwins: metaTwins.size,
      activeTwins: Array.from(metaTwins.values())
        .filter(t => t.deploymentStatus === 'active').length,
      meshStatus: 'online'
    }
  });
});

// Create HTTP server
const server = http.createServer(app);

// WebSocket server for live streaming connections
const wss = new WebSocket.Server({ server, path: '/api/metatwin/live' });

wss.on('connection', (ws) => {
  console.log('MetaTwin live stream connection established');
  meshData.activeConnections++;

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      console.log('Received message:', data);
      
      // Echo back with MetaTwin processing
      ws.send(JSON.stringify({
        type: 'ack',
        message: 'MetaTwin processing your request',
        timestamp: new Date().toISOString()
      }));
    } catch (error) {
      ws.send(JSON.stringify({ error: 'Invalid message format' }));
    }
  });

  ws.on('close', () => {
    console.log('MetaTwin live stream connection closed');
    meshData.activeConnections--;
  });

  // Send welcome message
  ws.send(JSON.stringify({
    type: 'connected',
    service: 'META-TWIN v2.5',
    message: 'Connected to MetaTwin live stream',
    timestamp: new Date().toISOString()
  }));
});

// Start server
server.listen(port, () => {
  console.log(`✓ META-TWIN v2.5 service running on port ${port}`);
  console.log(`  Health check: http://localhost:${port}/health`);
  console.log(`  WebSocket: ws://localhost:${port}/api/metatwin/live`);
  console.log(`  Integration Class: System-Core Layer`);
  console.log(`  Framework: PUABO OS`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = { app, server };

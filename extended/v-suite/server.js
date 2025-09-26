const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const WebSocket = require('ws');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3010;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', module: 'V-Suite', version: '1.0.0' });
});

// V-Suite API endpoints
app.get('/api/v-suite/status', (req, res) => {
  res.json({
    status: 'active',
    features: [
      'Virtual Environment Management',
      'Resource Virtualization',
      'System Optimization',
      'Performance Monitoring'
    ],
    uptime: process.uptime()
  });
});

app.get('/api/v-suite/environments', (req, res) => {
  res.json({
    environments: [
      {
        id: 'env-001',
        name: 'Development Environment',
        status: 'active',
        resources: { cpu: 75, memory: 60, storage: 45 }
      },
      {
        id: 'env-002', 
        name: 'Testing Environment',
        status: 'standby',
        resources: { cpu: 20, memory: 30, storage: 25 }
      },
      {
        id: 'env-003',
        name: 'Production Environment',
        status: 'active',
        resources: { cpu: 90, memory: 85, storage: 70 }
      }
    ]
  });
});

app.post('/api/v-suite/environments', (req, res) => {
  const { name, type } = req.body;
  const newEnv = {
    id: `env-${Date.now()}`,
    name: name || 'New Environment',
    type: type || 'development',
    status: 'initializing',
    resources: { cpu: 0, memory: 0, storage: 0 }
  };
  res.status(201).json({ success: true, environment: newEnv });
});

// WebSocket server for real-time updates
const server = app.listen(PORT, () => {
  console.log(`🔧 V-Suite Module running on port ${PORT}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('New V-Suite WebSocket connection');
  
  // Send initial data
  ws.send(JSON.stringify({
    type: 'connection',
    message: 'Connected to V-Suite real-time updates'
  }));

  // Send periodic updates
  const interval = setInterval(() => {
    ws.send(JSON.stringify({
      type: 'resource_update',
      timestamp: new Date().toISOString(),
      data: {
        cpu: Math.floor(Math.random() * 100),
        memory: Math.floor(Math.random() * 100),
        storage: Math.floor(Math.random() * 100)
      }
    }));
  }, 5000);

  ws.on('close', () => {
    clearInterval(interval);
    console.log('V-Suite WebSocket connection closed');
  });
});

module.exports = app;
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// V-Suite Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'V-Suite',
    modules: ['V-Hollywood Studio', 'V-Caster', 'V-Screen', 'V-Stage'],
    timestamp: new Date().toISOString()
  });
});

// V-Hollywood Studio
app.get('/hollywood', (req, res) => {
  res.json({
    service: 'V-Hollywood Studio',
    status: 'active',
    features: ['Video Production', 'Virtual Sets', 'Real-time Rendering']
  });
});

// V-Caster
app.get('/caster', (req, res) => {
  res.json({
    service: 'V-Caster',
    status: 'active',
    features: ['Live Streaming', 'Multi-platform Broadcasting', 'Stream Management']
  });
});

// V-Screen
app.get('/screen', (req, res) => {
  res.json({
    service: 'V-Screen',
    status: 'active',
    features: ['Screen Recording', 'Live Capture', 'Multi-monitor Support']
  });
});

// V-Stage
app.get('/stage', (req, res) => {
  res.json({
    service: 'V-Stage',
    status: 'active',
    features: ['Virtual Staging', '3D Environments', 'AR/VR Integration']
  });
});

app.listen(PORT, () => {
  console.log(`🎬 V-Suite running on port ${PORT}`);
  console.log(`📍 Health: http://localhost:${PORT}/health`);
});
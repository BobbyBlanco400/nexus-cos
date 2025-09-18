const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3201;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// PUABO COS Integration Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'PUABO COS Integration',
    features: ['Core PUABO System', 'User Management', 'System Integration'],
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/puabo/system/info', (req, res) => {
  res.json({
    system: 'PUABO COS',
    version: '2.0.0',
    status: 'operational',
    components: [
      'User Authentication',
      'System Management', 
      'Integration Layer',
      'Core Services'
    ]
  });
});

app.listen(PORT, () => {
  console.log(`🔗 PUABO COS Integration running on port ${PORT}`);
});
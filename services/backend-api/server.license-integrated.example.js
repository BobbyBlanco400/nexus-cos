// Example: backend-api with license integration
// This demonstrates how to integrate the license service

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const dotenv = require('dotenv');

// Import license client
const { 
  verifyLicense, 
  licenseMiddleware, 
  updateGatingMiddleware 
} = require('../license-service/client');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;
const SERVICE_ID = process.env.SERVICE_ID || 'backend-api';

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// Add license middleware to all routes (non-blocking)
app.use(licenseMiddleware(SERVICE_ID));

// Health check endpoint
app.get('/health', async (req, res) => {
  res.json({
    status: 'ok',
    service: SERVICE_ID,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0',
    license: req.license // License info from middleware
  });
});

// Normal API endpoints work regardless of license
app.get('/api/status', (req, res) => {
  res.json({
    service: SERVICE_ID,
    status: 'healthy',
    licensed: req.license.licensed
  });
});

// UPDATE ENDPOINT - This is the ONLY place where license is enforced
app.post('/api/admin/update', 
  updateGatingMiddleware(SERVICE_ID),  // License check here
  async (req, res) => {
    const { version } = req.body;
    
    // If we reach here, update is authorized
    console.log(`Updating to version ${version}...`);
    
    // Perform actual update logic here
    // ...
    
    res.json({
      success: true,
      message: `Updated to version ${version}`,
      service: SERVICE_ID
    });
  }
);

// Other endpoints (no license blocking)
app.get('/api', (req, res) => {
  res.json({
    name: 'Nexus COS Backend API',
    version: '1.0.0',
    service: SERVICE_ID,
    status: 'running',
    licensed: req.license.licensed
  });
});

// Initialize service with runtime verification
async function initialize() {
  console.log(`Initializing ${SERVICE_ID}...`);
  
  // Runtime verification (non-blocking)
  const licenseInfo = await verifyLicense(SERVICE_ID);
  
  if (licenseInfo.licensed) {
    console.log(`✓ ${SERVICE_ID} is licensed`);
    if (licenseInfo.offline) {
      console.log('  (Operating in offline mode)');
    }
  } else {
    console.warn(`⚠ License verification failed for ${SERVICE_ID}`);
    console.warn('  Continuing anyway (perpetual license allows offline operation)');
  }
  
  // Start server (happens regardless of license status)
  const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 ${SERVICE_ID} running on http://0.0.0.0:${PORT}`);
    console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  });
  
  // Graceful shutdown
  process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
    });
  });
}

// Start the service
initialize().catch(error => {
  console.error('Failed to initialize service:', error);
  process.exit(1);
});

module.exports = app;

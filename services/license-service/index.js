const express = require('express');
const jwt = require('jsonwebtoken');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3099;
const JWT_SECRET = process.env.JWT_SECRET || 'nexus-cos-license-secret-change-in-production';

// Middleware
app.use(cors());
app.use(express.json());

// License configuration
const LICENSE_CONFIG = {
  licensee: 'THIIO',
  licenseId: 'THIIO-NEXUS-COS-2025-001',
  type: 'perpetual',
  issueDate: '2025-12-13',
  features: {
    coreServices: true,
    nexusVision: true,
    puaboverse: true,
    allModules: true,
    updates: true
  },
  restrictions: {
    offlineMode: true,
    updateGatingOnly: true,
    noForcedOnlineChecks: true
  }
};

// Generate license token
function generateLicenseToken(serviceId) {
  const payload = {
    serviceId,
    licensee: LICENSE_CONFIG.licensee,
    licenseId: LICENSE_CONFIG.licenseId,
    type: LICENSE_CONFIG.type,
    features: LICENSE_CONFIG.features,
    issuedAt: Date.now(),
    expiresAt: null // Perpetual license
  };
  
  return jwt.sign(payload, JWT_SECRET, { noTimestamp: true });
}

// Verify license token
function verifyLicenseToken(token) {
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    return { valid: true, payload: decoded };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'license-service',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// License status endpoint
app.get('/api/license/status', (req, res) => {
  res.json({
    status: 'active',
    licensee: LICENSE_CONFIG.licensee,
    licenseId: LICENSE_CONFIG.licenseId,
    type: LICENSE_CONFIG.type,
    features: LICENSE_CONFIG.features,
    offlineSupported: true
  });
});

// Runtime verification endpoint (for Core Services, Nexus Vision, PUABOverse)
app.post('/api/license/verify', (req, res) => {
  const { serviceId, token } = req.body;
  
  if (!serviceId) {
    return res.status(400).json({ error: 'Service ID required' });
  }
  
  // If no token provided, generate one for perpetual license
  if (!token) {
    const newToken = generateLicenseToken(serviceId);
    return res.json({
      valid: true,
      licensed: true,
      serviceId,
      token: newToken,
      features: LICENSE_CONFIG.features,
      message: 'License verified - perpetual license active'
    });
  }
  
  // Verify existing token
  const verification = verifyLicenseToken(token);
  
  if (verification.valid) {
    return res.json({
      valid: true,
      licensed: true,
      serviceId,
      payload: verification.payload,
      message: 'License token valid'
    });
  } else {
    // Even if token is invalid, generate new one (offline support)
    const newToken = generateLicenseToken(serviceId);
    return res.json({
      valid: true,
      licensed: true,
      serviceId,
      token: newToken,
      message: 'New license token generated',
      note: 'Previous token invalid, new perpetual token issued'
    });
  }
});

// Update gating endpoint - Only place where license can block
app.post('/api/license/update-check', (req, res) => {
  const { serviceId, version, updateVersion } = req.body;
  
  if (!serviceId || !updateVersion) {
    return res.status(400).json({ 
      error: 'Service ID and update version required',
      updateAllowed: false 
    });
  }
  
  // Check if updates are allowed
  if (LICENSE_CONFIG.features.updates) {
    return res.json({
      updateAllowed: true,
      serviceId,
      currentVersion: version,
      updateVersion,
      message: 'Update authorized - perpetual license with update rights'
    });
  } else {
    return res.json({
      updateAllowed: false,
      serviceId,
      message: 'Updates not included in license',
      contactSupport: true
    });
  }
});

// Generate new license token for a service
app.post('/api/license/generate', (req, res) => {
  const { serviceId, adminKey } = req.body;
  
  // Simple admin check (in production, use proper authentication)
  if (adminKey !== process.env.ADMIN_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  const token = generateLicenseToken(serviceId);
  
  res.json({
    success: true,
    serviceId,
    token,
    licenseId: LICENSE_CONFIG.licenseId,
    message: 'License token generated'
  });
});

// Offline license check - always returns valid for perpetual license
app.post('/api/license/offline-verify', (req, res) => {
  const { serviceId } = req.body;
  
  // Offline mode always succeeds for perpetual license
  res.json({
    valid: true,
    licensed: true,
    serviceId,
    offline: true,
    message: 'Offline verification successful - perpetual license',
    features: LICENSE_CONFIG.features
  });
});

// Cross-module license recognition
app.post('/api/license/module-check', (req, res) => {
  const { moduleId, serviceId } = req.body;
  
  res.json({
    valid: true,
    moduleId,
    serviceId,
    licensed: true,
    allModules: LICENSE_CONFIG.features.allModules,
    message: 'Module access granted - all modules included'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log('===========================================');
  console.log('Nexus COS License Service');
  console.log('===========================================');
  console.log(`Server running on port ${PORT}`);
  console.log(`Licensee: ${LICENSE_CONFIG.licensee}`);
  console.log(`License ID: ${LICENSE_CONFIG.licenseId}`);
  console.log(`License Type: ${LICENSE_CONFIG.type}`);
  console.log(`Offline Support: ${LICENSE_CONFIG.restrictions.offlineMode}`);
  console.log('===========================================');
});

module.exports = app;

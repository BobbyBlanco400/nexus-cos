// Feature Flag Service - Simple Implementation Example
// This is a minimal example to demonstrate the overlay approach
// Integrate this into your existing backend API

const fs = require('fs');
const path = require('path');

class FeatureFlagService {
  constructor(configPath = './config/feature-flags.json') {
    this.configPath = configPath;
    this.flags = {};
    this.load();
  }

  load() {
    try {
      const data = fs.readFileSync(this.configPath, 'utf8');
      const config = JSON.parse(data);
      this.flags = config.feature_flags || {};
      this.accessModes = config.access_modes || {};
      console.log('Feature flags loaded successfully');
    } catch (error) {
      console.error('Error loading feature flags:', error.message);
      this.flags = {};
      this.accessModes = {};
    }
  }

  reload() {
    this.load();
    return { success: true, message: 'Feature flags reloaded' };
  }

  isEnabled(flagName) {
    const flag = this.flags[flagName];
    if (!flag) return false;
    
    // Check dependencies
    if (flag.requires && flag.requires.length > 0) {
      for (const requiredFlag of flag.requires) {
        if (!this.isEnabled(requiredFlag)) {
          return false;
        }
      }
    }
    
    return flag.enabled === true;
  }

  getFlag(flagName) {
    return this.flags[flagName] || null;
  }

  getAllFlags() {
    return Object.keys(this.flags).map(name => ({
      name,
      ...this.flags[name]
    }));
  }

  getAccessMode(mode) {
    return this.accessModes[mode] || null;
  }

  getCurrentAccessMode() {
    if (this.isEnabled('PUBLIC_FULL_LAUNCH_MODE')) {
      return 'public_full';
    }
    if (this.isEnabled('PUBLIC_SOFT_LAUNCH_MODE')) {
      return 'public_soft';
    }
    if (this.isEnabled('FOUNDER_BETA_MODE')) {
      return 'founder_beta';
    }
    return 'none';
  }

  // Enable/disable flags (for admin use only)
  setFlag(flagName, enabled) {
    if (!this.flags[flagName]) {
      throw new Error(`Flag ${flagName} does not exist`);
    }
    
    // Check dependencies if enabling
    if (enabled && this.flags[flagName].requires) {
      for (const requiredFlag of this.flags[flagName].requires) {
        if (!this.isEnabled(requiredFlag)) {
          throw new Error(`Cannot enable ${flagName}: ${requiredFlag} must be enabled first`);
        }
      }
    }
    
    this.flags[flagName].enabled = enabled;
    this.save();
    return { success: true, flag: flagName, enabled };
  }

  save() {
    try {
      const config = {
        version: "1.0.0",
        updated: new Date().toISOString(),
        feature_flags: this.flags,
        access_modes: this.accessModes
      };
      fs.writeFileSync(this.configPath, JSON.stringify(config, null, 2));
    } catch (error) {
      console.error('Error saving feature flags:', error.message);
    }
  }
}

// Express.js route handlers example
function createFeatureFlagRoutes(app, featureFlagService) {
  
  // Get all feature flags
  app.get('/api/feature-flags', (req, res) => {
    res.json({
      flags: featureFlagService.getAllFlags(),
      currentMode: featureFlagService.getCurrentAccessMode()
    });
  });

  // Get specific flag
  app.get('/api/feature-flags/:name', (req, res) => {
    const flag = featureFlagService.getFlag(req.params.name);
    if (!flag) {
      return res.status(404).json({ error: 'Flag not found' });
    }
    res.json({ name: req.params.name, ...flag });
  });

  // Check if flag is enabled
  app.get('/api/feature-flags/:name/enabled', (req, res) => {
    const enabled = featureFlagService.isEnabled(req.params.name);
    res.json({ name: req.params.name, enabled });
  });

  // Reload feature flags from config file
  app.post('/api/feature-flags/reload', (req, res) => {
    const result = featureFlagService.reload();
    res.json(result);
  });

  // Set flag (admin only - add authentication)
  app.put('/api/feature-flags/:name', (req, res) => {
    // TODO: Add authentication/authorization check
    try {
      const result = featureFlagService.setFlag(req.params.name, req.body.enabled);
      res.json(result);
    } catch (error) {
      res.status(400).json({ error: error.message });
    }
  });

  // Health check endpoints for overlay features
  app.get('/api/pf/jurisdiction/health', (req, res) => {
    const enabled = featureFlagService.isEnabled('JURISDICTION_ENGINE_ENABLED');
    res.status(enabled ? 200 : 503).json({
      service: 'jurisdiction_engine',
      status: enabled ? 'active' : 'disabled',
      overlay: true
    });
  });

  app.get('/api/pf/marketplace/health', (req, res) => {
    const phase2 = featureFlagService.isEnabled('MARKETPLACE_PHASE2_ENABLED');
    const phase3 = featureFlagService.isEnabled('MARKETPLACE_PHASE3_ENABLED');
    const enabled = phase2 || phase3;
    res.status(enabled ? 200 : 503).json({
      service: 'marketplace',
      status: enabled ? 'active' : 'disabled',
      phase: phase3 ? 3 : (phase2 ? 2 : 0),
      overlay: true
    });
  });

  app.get('/api/pf/ai-dealers/health', (req, res) => {
    const enabled = featureFlagService.isEnabled('AI_DEALERS_ENABLED');
    res.status(enabled ? 200 : 503).json({
      service: 'ai_dealers',
      status: enabled ? 'active' : 'disabled',
      overlay: true
    });
  });

  app.get('/api/pf/federation/health', (req, res) => {
    const enabled = featureFlagService.isEnabled('CASINO_FEDERATION_ENABLED');
    res.status(enabled ? 200 : 503).json({
      service: 'casino_federation',
      status: enabled ? 'active' : 'disabled',
      overlay: true
    });
  });

  app.get('/api/pf/creator/health', (req, res) => {
    const enabled = featureFlagService.isEnabled('CREATOR_MONETIZATION_ENABLED');
    res.status(enabled ? 200 : 503).json({
      service: 'creator_monetization',
      status: enabled ? 'active' : 'disabled',
      overlay: true
    });
  });
}

// Middleware to check feature flags
function featureFlagMiddleware(flagName) {
  return (req, res, next) => {
    if (!req.app.locals.featureFlagService.isEnabled(flagName)) {
      return res.status(403).json({ 
        error: 'Feature not available',
        feature: flagName 
      });
    }
    next();
  };
}

// Export for use in your application
module.exports = {
  FeatureFlagService,
  createFeatureFlagRoutes,
  featureFlagMiddleware
};

// Example usage:
// const { FeatureFlagService, createFeatureFlagRoutes } = require('./feature-flag-service');
// const featureFlagService = new FeatureFlagService('./config/feature-flags.json');
// app.locals.featureFlagService = featureFlagService;
// createFeatureFlagRoutes(app, featureFlagService);

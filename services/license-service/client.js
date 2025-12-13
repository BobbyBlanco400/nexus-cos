/**
 * Nexus COS License Client
 * 
 * Integration library for services to verify licenses with the license service.
 * Supports offline mode and graceful degradation.
 */

const axios = require('axios');

const LICENSE_SERVICE_URL = process.env.LICENSE_SERVICE_URL || 'http://localhost:3099';
const SERVICE_ID = process.env.SERVICE_ID || 'unknown-service';

/**
 * Verify license at runtime (non-blocking)
 * Services continue to operate even if license service is unavailable
 */
async function verifyLicense(serviceId = SERVICE_ID) {
  try {
    const response = await axios.post(
      `${LICENSE_SERVICE_URL}/api/license/verify`,
      { serviceId },
      { timeout: 3000 }
    );
    
    if (response.data.licensed) {
      console.log(`[License] ✓ Service ${serviceId} is licensed`);
      return {
        licensed: true,
        token: response.data.token
      };
    } else {
      console.warn(`[License] ⚠ Service ${serviceId} license verification failed`);
      return { licensed: false };
    }
  } catch (error) {
    // Offline mode or service unavailable - allow operation (perpetual license)
    console.warn(`[License] ⚠ License service unavailable (${error.message}), continuing in offline mode`);
    return {
      licensed: true,
      offline: true,
      message: 'Operating in offline mode with perpetual license'
    };
  }
}

/**
 * Check if an update is allowed (blocking)
 * This is the ONLY place where license can block operations
 */
async function checkUpdateAllowed(updateVersion, serviceId = SERVICE_ID) {
  try {
    const response = await axios.post(
      `${LICENSE_SERVICE_URL}/api/license/update-check`,
      {
        serviceId,
        updateVersion
      },
      { timeout: 5000 }
    );
    
    if (response.data.updateAllowed) {
      console.log(`[License] ✓ Update to ${updateVersion} is authorized`);
      return true;
    } else {
      console.error(`[License] ✗ Update to ${updateVersion} is not authorized`);
      return false;
    }
  } catch (error) {
    console.error(`[License] ✗ Cannot verify update authorization: ${error.message}`);
    // Block updates if license service unavailable
    return false;
  }
}

/**
 * Offline license verification
 * Always succeeds for perpetual license
 */
async function offlineVerify(serviceId = SERVICE_ID) {
  try {
    const response = await axios.post(
      `${LICENSE_SERVICE_URL}/api/license/offline-verify`,
      { serviceId },
      { timeout: 2000 }
    );
    
    return response.data.licensed;
  } catch (error) {
    // Offline mode - always allow for perpetual license
    console.log(`[License] ✓ Offline verification successful (perpetual license)`);
    return true;
  }
}

/**
 * Verify module access
 * Checks if a module is included in the license
 */
async function verifyModuleAccess(moduleId, serviceId = SERVICE_ID) {
  try {
    const response = await axios.post(
      `${LICENSE_SERVICE_URL}/api/license/module-check`,
      { moduleId, serviceId },
      { timeout: 3000 }
    );
    
    if (response.data.licensed) {
      console.log(`[License] ✓ Module ${moduleId} is licensed`);
      return true;
    } else {
      console.warn(`[License] ⚠ Module ${moduleId} is not licensed`);
      return false;
    }
  } catch (error) {
    // Offline mode - allow all modules for perpetual license
    console.warn(`[License] ⚠ License service unavailable, allowing module ${moduleId} (perpetual license)`);
    return true;
  }
}

/**
 * Get license status
 */
async function getLicenseStatus() {
  try {
    const response = await axios.get(
      `${LICENSE_SERVICE_URL}/api/license/status`,
      { timeout: 3000 }
    );
    
    return response.data;
  } catch (error) {
    return {
      status: 'offline',
      message: 'License service unavailable',
      offlineMode: true
    };
  }
}

/**
 * Express middleware for runtime license verification
 * Adds license info to request but doesn't block
 */
function licenseMiddleware(serviceId = SERVICE_ID) {
  return async (req, res, next) => {
    try {
      const licenseInfo = await verifyLicense(serviceId);
      req.license = licenseInfo;
    } catch (error) {
      req.license = { 
        licensed: true, 
        offline: true,
        message: 'Operating in offline mode'
      };
    }
    next();
  };
}

/**
 * Express middleware for update endpoint protection
 * BLOCKS if license doesn't allow updates
 */
function updateGatingMiddleware(serviceId = SERVICE_ID) {
  return async (req, res, next) => {
    const updateVersion = req.body.version || req.query.version;
    
    if (!updateVersion) {
      return res.status(400).json({
        error: 'Update version required'
      });
    }
    
    const allowed = await checkUpdateAllowed(updateVersion, serviceId);
    
    if (!allowed) {
      return res.status(403).json({
        error: 'Update not authorized',
        message: 'Your license does not include update rights',
        contactSupport: true
      });
    }
    
    next();
  };
}

module.exports = {
  verifyLicense,
  checkUpdateAllowed,
  offlineVerify,
  verifyModuleAccess,
  getLicenseStatus,
  licenseMiddleware,
  updateGatingMiddleware
};

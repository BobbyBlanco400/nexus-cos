# License Service Integration Guide

This guide shows how to integrate the license service with Nexus COS services.

## Installation

The license client is included in the license-service package. Services can either:

1. Copy `services/license-service/client.js` to their project
2. Use it as a shared module via symlink or npm link
3. Include it directly with a relative path

## Integration Examples

### Example 1: Runtime Verification (Non-Blocking)

Add to service startup (e.g., `backend-api/server.js`):

```javascript
const { verifyLicense, licenseMiddleware } = require('../license-service/client');

// At service startup
async function initialize() {
  console.log('Initializing service...');
  
  // Verify license (non-blocking)
  const licenseInfo = await verifyLicense('backend-api');
  
  if (licenseInfo.licensed) {
    console.log('✓ Service is licensed');
  } else {
    console.warn('⚠ License verification failed, continuing anyway (perpetual license)');
  }
  
  // Service continues regardless of license status
  startServer();
}

initialize();
```

### Example 2: Express Middleware

Add license info to all requests:

```javascript
const { licenseMiddleware } = require('../license-service/client');

// Apply to all routes
app.use(licenseMiddleware('backend-api'));

// Now all routes have access to req.license
app.get('/api/status', (req, res) => {
  res.json({
    status: 'healthy',
    licensed: req.license.licensed,
    licenseInfo: req.license
  });
});
```

### Example 3: Update Endpoint Gating

Protect update endpoints (the ONLY place where license blocks):

```javascript
const { updateGatingMiddleware } = require('../license-service/client');

// Apply ONLY to update endpoints
app.post('/api/admin/update', 
  updateGatingMiddleware('backend-api'),
  async (req, res) => {
    // This code only runs if update is authorized
    const { version } = req.body;
    
    // Perform update
    await performUpdate(version);
    
    res.json({
      success: true,
      message: `Updated to version ${version}`
    });
  }
);
```

### Example 4: Module Access Verification

For services that load modules dynamically:

```javascript
const { verifyModuleAccess } = require('../license-service/client');

async function loadModule(moduleId) {
  const hasAccess = await verifyModuleAccess(moduleId, 'backend-api');
  
  if (!hasAccess) {
    console.warn(`Module ${moduleId} is not licensed, skipping...`);
    return null;
  }
  
  console.log(`Loading module ${moduleId}...`);
  return require(`./modules/${moduleId}`);
}
```

### Example 5: Offline Verification

For services that may run completely offline:

```javascript
const { offlineVerify } = require('../license-service/client');

async function startOfflineMode() {
  const isLicensed = await offlineVerify('backend-api');
  
  if (isLicensed) {
    console.log('✓ Offline license valid');
    // Continue operation
  } else {
    console.warn('⚠ Offline verification failed');
    // For perpetual license, this should never fail
  }
}
```

## Integration Checklist

For each core service (Core Services, Nexus Vision, PUABOverse):

- [ ] Copy or link the license client
- [ ] Add runtime verification at service startup
- [ ] Add license middleware to Express app (optional)
- [ ] Protect update endpoints with updateGatingMiddleware
- [ ] Test offline operation
- [ ] Test update gating

## Services to Integrate

### Core Services
1. **backend-api** (Port 3001)
   - Add runtime verification
   - Protect `/api/admin/update` endpoint

2. **auth-service** (Port 3002)
   - Add runtime verification
   - No update endpoint needed (auth managed centrally)

3. **auth-service-v2** (Port 3003)
   - Add runtime verification
   - Protect `/api/v2/admin/update`

### Nexus Vision
4. **v-screen-pro** (Port 3030)
   - Add runtime verification
   - Protect video update endpoints

5. **v-caster-pro** (Port 3031)
   - Add runtime verification
   - Protect streaming update endpoints

6. **v-prompter-pro** (Port 3032)
   - Add runtime verification

### PUABOverse
7. **puaboverse-v2** (Port 3040)
   - Add runtime verification
   - Protect world update endpoints

8. **metatwin** (Port 3041)
   - Add runtime verification
   - Protect digital twin updates

## Environment Variables

Add to each service's `.env`:

```env
# License Service Configuration
LICENSE_SERVICE_URL=http://localhost:3099
SERVICE_ID=backend-api  # Change per service
```

## Testing

### Test Runtime Verification

```bash
# Start license service
cd services/license-service
npm start

# In another terminal, test from a service
cd services/backend-api
node -e "
const { verifyLicense } = require('../license-service/client');
verifyLicense('backend-api').then(console.log);
"
```

### Test Offline Mode

```bash
# Stop license service
pm2 stop license-service

# Service should still start and operate
cd services/backend-api
npm start

# Should see: "Operating in offline mode with perpetual license"
```

### Test Update Gating

```bash
# With license service running
curl -X POST http://localhost:3001/api/admin/update \
  -H "Content-Type: application/json" \
  -d '{"version": "2.0.0"}'

# Should return: {"updateAllowed": true, ...}
```

## Architecture Preservation

The license integration follows these principles:

✅ **No Refactoring**: Minimal changes to existing code  
✅ **Non-Blocking**: Services start and run even if license service is down  
✅ **Offline Support**: Full operation without internet  
✅ **Update Gating Only**: License only enforced at update endpoints  
✅ **Graceful Degradation**: Falls back to offline mode automatically  

## VPS Deployment

1. Deploy license service first:
   ```bash
   cd services/license-service
   npm install
   pm2 start index.js --name license-service
   ```

2. Verify it's running:
   ```bash
   curl http://localhost:3099/health
   ```

3. Deploy other services with license integration
   - They will automatically connect to license service
   - If license service is unavailable, they continue in offline mode

4. Test cross-module recognition:
   ```bash
   curl -X POST http://localhost:3099/api/license/module-check \
     -H "Content-Type: application/json" \
     -d '{"moduleId": "casino-nexus", "serviceId": "backend-api"}'
   ```

## Troubleshooting

### License service not reachable

Services will log:
```
[License] ⚠ License service unavailable (ECONNREFUSED), continuing in offline mode
```

This is expected behavior. Services continue to operate with the perpetual license.

### Update endpoint returns 403

Check license service logs:
```bash
pm2 logs license-service
```

Verify LICENSE_SERVICE_URL is correct in the service's `.env`.

### Module access denied

Check license configuration in `services/license-service/index.js`:
```javascript
features: {
  allModules: true  // Should be true
}
```

## Summary

The license integration is designed to be:
- **Minimal**: Few changes to existing services
- **Non-intrusive**: Services work normally
- **Offline-friendly**: No internet required
- **Update-focused**: Only gates updates, not normal operation
- **Developer-friendly**: Clear error messages and logging

For questions, see `services/license-service/README.md`.

# License Service

Self-hosted license verification service for Nexus COS platform.

## Purpose

Provides runtime license verification for:
- Core Services
- Nexus Vision
- PUABOverse
- All platform modules

## Features

- **Perpetual License**: No expiration, no recurring fees
- **Offline Support**: Works without internet connection
- **Update Gating**: Only enforces license at update endpoints
- **Cross-Module Recognition**: Single license for all modules
- **No Forced Checks**: No mandatory online verification

## Installation

```bash
cd services/license-service
npm install
cp .env.example .env
# Edit .env with your configuration
npm start
```

## Environment Variables

See `.env.example` for configuration options.

**Important Security Requirements**:

⚠️ **PRODUCTION DEPLOYMENT**: You MUST set these environment variables:
- `JWT_SECRET` - Strong random secret for JWT signing (required in production)
- `ADMIN_KEY` - Strong random secret for admin operations (required in production)

If not set in production, the service will refuse to start.

**Generate secure secrets**:
```bash
# Generate JWT_SECRET
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Generate ADMIN_KEY
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

## API Endpoints

### Health Check
```
GET /health
```

### License Status
```
GET /api/license/status
```

### Runtime Verification
```
POST /api/license/verify
Body: { "serviceId": "core-service-1" }
```

### Update Check (Gating Point)
```
POST /api/license/update-check
Body: { 
  "serviceId": "core-service-1",
  "version": "1.0.0",
  "updateVersion": "1.1.0"
}
```

### Offline Verification
```
POST /api/license/offline-verify
Body: { "serviceId": "core-service-1" }
```

### Module Check
```
POST /api/license/module-check
Body: { 
  "moduleId": "casino-nexus",
  "serviceId": "core-service-1"
}
```

## Integration Example

```javascript
const axios = require('axios');

// Runtime verification (non-blocking)
async function verifyLicense(serviceId) {
  try {
    const response = await axios.post('http://localhost:3099/api/license/verify', {
      serviceId
    });
    return response.data.licensed;
  } catch (error) {
    // Offline or service unavailable - continue operation
    console.warn('License service unavailable, continuing in offline mode');
    return true; // Perpetual license allows offline operation
  }
}

// Update gating (blocking)
async function checkUpdateAllowed(serviceId, updateVersion) {
  try {
    const response = await axios.post('http://localhost:3099/api/license/update-check', {
      serviceId,
      updateVersion
    });
    return response.data.updateAllowed;
  } catch (error) {
    console.error('Cannot verify update license:', error.message);
    return false; // Block updates if license service unavailable
  }
}
```

## Deployment

### Standalone
```bash
npm start
```

### PM2
```bash
pm2 start index.js --name license-service
```

### Docker
```bash
docker build -t nexus-license-service .
docker run -p 3099:3099 --env-file .env nexus-license-service
```

### VPS Deployment
1. Copy service to VPS
2. Install dependencies: `npm install`
3. Configure `.env` file
4. Start with PM2: `pm2 start index.js --name license-service`
5. Configure nginx reverse proxy (optional)

## Security Notes

- Change `JWT_SECRET` in production
- Change `ADMIN_KEY` in production
- Use HTTPS in production
- Restrict admin endpoints to internal network
- Keep `.env` file secure (never commit to git)

## Architecture

- **No External Dependencies**: Runs completely self-hosted
- **Stateless**: No database required (configuration-based)
- **Graceful Degradation**: Services continue if license service unavailable
- **Update Gating Only**: Only blocks at designated update endpoints

## License Configuration

Edit `LICENSE_CONFIG` in `index.js` to modify:
- Licensee name
- License ID
- Enabled features
- Restrictions

## Support

This service is included in the THIIO handoff package. For issues:
1. Check logs: `pm2 logs license-service`
2. Verify configuration in `.env`
3. Test endpoints with curl or Postman
4. Review integration code in calling services

# Nexus COS Pre-Beta Verification

## Overview

The Nexus COS Pre-Beta Verification system provides comprehensive automated testing of the platform's domains, SSL certificates, API endpoints, and performance metrics. This system integrates with GitHub Actions for CI/CD automation and generates TRAE SOLO compatible reports.

## Files

### 1. GitHub Workflow
- **File**: `.github/workflows/nexuscos_prebeta_check.yml`
- **Purpose**: Automated CI/CD verification workflow
- **Triggers**: Manual (`workflow_dispatch`) and daily schedule (`cron: '0 0 * * *'`)

### 2. Puppeteer Script  
- **File**: `deployment/nginx/nexuscos_prebeta_check.js`
- **Purpose**: Comprehensive verification engine
- **Executable**: Yes (`chmod +x`)

## Verification Scope

### Domain Checks
- `nexuscos.online`
- `www.nexuscos.online`

### SSL Validation
- Certificate validity
- HTTPS accessibility  
- Response times

### Event Pages & API Endpoints
- `/admin/` - Admin Panel
- `/creator-hub/` - Creator Hub
- `/api/health` - Health Check
- `/api/backend/status` - Backend Status
- `/api/auth-service/status` - Authentication Service
- `/api/trae-solo/status` - TRAE SOLO Status
- `/api/v-suite/status` - V-Suite Status
- `/api/puaboverse/status` - PuaboVerse Status
- `/diagram/` - Module Map

### Performance Metrics
- Page load times
- First Contentful Paint (FCP)
- Network request counting
- SSL handshake performance

## Usage

### Manual Execution
```bash
# Install dependencies
npm install puppeteer

# Run verification
node ./deployment/nginx/nexuscos_prebeta_check.js

# Check results
cat /tmp/nexuscos_prebeta_pf.json
```

### GitHub Actions
1. **Manual Trigger**: Go to Actions → "Nexus COS Pre-Beta Verification" → "Run workflow"
2. **Automatic**: Runs daily at midnight UTC
3. **Artifacts**: Download `nexuscos_prebeta_pf` artifact containing the JSON report

## Output Format

The verification generates a JSON report at `/tmp/nexuscos_prebeta_pf.json` with the following structure:

```json
{
  "timestamp": "2025-09-27T06:41:26.338Z",
  "version": "1.0.0", 
  "platform": "Nexus COS",
  "status": "healthy|warning|critical|error",
  "summary": {
    "totalChecks": 21,
    "passedChecks": 21,
    "failedChecks": 0,
    "warningChecks": 0,
    "successRate": 100
  },
  "domains": {
    "nexuscos.online": {
      "accessible": true,
      "responseTime": 1000,
      "statusCode": 200,
      "ssl": { /* SSL details */ }
    }
  },
  "eventPages": {
    "nexuscos.online/admin/": {
      "accessible": true,
      "statusCode": 200,
      "contentType": "text/html",
      "hasContent": true,
      "apiResponse": null
    }
  },
  "performance": {
    "nexuscos.online": {
      "loadTime": 2500,
      "firstContentfulPaint": 1200,
      "networkRequests": 25
    }
  },
  "errors": [],
  "warnings": []
}
```

## Status Levels

- **healthy**: ≥90% success rate
- **warning**: 70-89% success rate  
- **critical**: <70% success rate
- **error**: Script execution failure

## TRAE SOLO Integration

The JSON output is fully compatible with TRAE SOLO for:
- Automated PF verification consumption
- Failure detection and alerting
- Performance monitoring integration
- CI/CD pipeline integration

## Troubleshooting

### Common Issues

1. **Puppeteer Installation Fails**
   - The script includes a test mode fallback
   - GitHub Actions handles Puppeteer installation automatically

2. **Domain Not Accessible**
   - Check DNS resolution
   - Verify SSL certificates
   - Review firewall settings

3. **API Endpoints Failing**
   - Ensure backend services are running
   - Check PM2 process status
   - Verify nginx configuration

### Debug Mode
Add debugging by setting environment variables:
```bash
DEBUG=1 node ./deployment/nginx/nexuscos_prebeta_check.js
```

## Contributing

When updating the verification script:
1. Test in both full and test modes
2. Validate JSON output format
3. Ensure TRAE SOLO compatibility
4. Update this documentation

---

**Note**: This verification system is designed for pre-beta launch readiness and ongoing platform monitoring. It provides comprehensive coverage of all critical Nexus COS components and integrations.
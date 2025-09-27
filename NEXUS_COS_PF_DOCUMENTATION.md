# Nexus COS PF (Platform Framework) Verification System

## Overview

The Nexus COS PF Verification System is a comprehensive monitoring and testing framework designed to continuously validate the health and performance of the Nexus COS platform. It provides 24/7 monitoring through GitHub Actions and supports both automated and manual execution.

## 🎯 Key Features

- **Continuous Monitoring**: Automated checks every 5 minutes via GitHub Actions
- **Domain Health Checks**: Validates SSL certificates and domain accessibility
- **Endpoint Verification**: Tests critical API endpoints and frontend routes
- **Performance Metrics**: Collects browser performance data
- **Comprehensive Reporting**: JSON reports with detailed status information
- **Mock Testing Support**: Fallback mode for environments without Puppeteer

## 🏗️ Architecture

### Core Components

1. **GitHub Actions Workflow** (`.github/workflows/nexuscos_pf.yml`)
   - Scheduled execution every 5 minutes
   - Manual trigger support
   - Artifact upload for reports
   - Node.js and Puppeteer environment setup

2. **Puppeteer Verification Script** (`deployment/nginx/nexuscos_pf.js`)
   - Domain accessibility testing
   - Endpoint health validation
   - Performance metrics collection
   - SSL certificate verification
   - Fallback mock testing mode

3. **Validation Script** (`validate-prebeta-setup.sh`)
   - Pre-deployment validation
   - Dependency verification
   - Environment readiness check

## 🚀 Usage

### Manual Execution

```bash
# Validate setup
./validate-prebeta-setup.sh

# Run PF verification
node ./deployment/nginx/nexuscos_pf.js

# View generated report
cat /tmp/nexuscos_pf.json

# Run complete example with summary
./nexus-pf-usage-example.sh
```

### GitHub Actions Integration

The system automatically runs via GitHub Actions:
- **Trigger**: Every 5 minutes (continuous monitoring)
- **Manual**: `workflow_dispatch` event
- **Artifacts**: Reports uploaded as `nexuscos_pf_report`
- **Logs**: Full execution logs available in Actions tab

## 📊 Monitoring Targets

### Domains
- `https://nexuscos.online`
- `https://www.nexuscos.online`

### Critical Endpoints
- `/admin/` - Admin Panel
- `/creator-hub/` - Creator Hub
- `/diagram/` - Interactive Module Map
- `/api/health` - General Health Check
- `/api/backend/status` - Backend Service Status
- `/api/auth-service/status` - Authentication Service
- `/api/trae-solo/status` - TRAE Solo Status
- `/api/v-suite/status` - V-Suite Status
- `/api/puaboverse/status` - PuaboVerse Status

## 📈 Report Format

```json
{
  "timestamp": "2025-09-27T07:10:01.401Z",
  "platform": "Nexus COS",
  "status": "healthy|warning|critical",
  "summary": {
    "totalChecks": 11,
    "passedChecks": 10,
    "successRate": 91
  },
  "domains": {
    "https://nexuscos.online": {
      "status": 200,
      "url": "https://nexuscos.online",
      "sslValid": true
    }
  },
  "eventPages": {
    "/admin/": {
      "status": 200,
      "url": "https://nexuscos.online/admin/"
    }
  },
  "performance": {
    "https://nexuscos.online": {
      "Timestamp": 1758957001401,
      "Documents": 1,
      "Frames": 1,
      "JSEventListeners": 1,
      "Nodes": 148,
      "LayoutCount": 3,
      "RecalcStyleCount": 2
    }
  }
}
```

## 🔧 Configuration

### Status Thresholds
- **Healthy**: ≥90% success rate
- **Warning**: 70-89% success rate  
- **Critical**: <70% success rate

### Timeout Settings
- **Page Load**: 30 seconds
- **Network Idle**: Wait for 2 seconds of network inactivity

### Mock Mode
When Puppeteer is unavailable, the system automatically falls back to mock mode:
- Simulates realistic test scenarios
- Provides sample performance metrics
- Maintains report format compatibility
- Useful for local development and testing

## 🛠️ Development

### Prerequisites
- Node.js 20.x
- Puppeteer (installed automatically via npm)
- Write access to `/tmp/` directory

### Local Testing
```bash
# Install dependencies
npm install

# Run validation
./validate-prebeta-setup.sh

# Execute PF verification
node deployment/nginx/nexuscos_pf.js

# Run usage example with summary
./nexus-pf-usage-example.sh
```

### Environment Variables
The system can be configured via environment variables:
- `PUPPETEER_SKIP_DOWNLOAD`: Skip Chromium download (enables mock mode)
- `PF_OUTPUT_FILE`: Custom output file path (default: `/tmp/nexuscos_pf.json`)

## 🔐 Security Considerations

- SSL certificate validation included
- No sensitive data in reports
- Read-only operations on target systems
- Secure artifact handling in GitHub Actions
- Network timeout protections

## 📞 Troubleshooting

### Common Issues

1. **Puppeteer Installation Fails**
   - System automatically falls back to mock mode
   - Verify network connectivity for Chromium download
   - Use `PUPPETEER_SKIP_DOWNLOAD=true` to force mock mode

2. **Timeout Errors**
   - Check target domain accessibility
   - Verify SSL certificates are valid
   - Increase timeout values if needed

3. **Permission Errors**
   - Ensure write access to `/tmp/` directory
   - Verify script execution permissions

### Mock Mode Indicators
- Console message: "🧪 Running in mock mode for local testing..."
- Report field: `"mockMode": true`
- Test data includes `"mockTest": true` markers

## 🤝 Integration with Existing Systems

The PF system integrates seamlessly with:
- **TRAE Solo**: Monitors TRAE Solo status endpoints
- **Existing Health Checks**: Complements existing monitoring
- **Deployment Pipeline**: Can be integrated into CI/CD workflows
- **PM2 Ecosystem**: Compatible with PM2 service management

## 📋 Maintenance

### Regular Tasks
- Monitor GitHub Actions execution logs
- Review success rate trends
- Update endpoint list as platform evolves
- Verify SSL certificate renewal detection

### Updates
To add new monitoring targets:
1. Update `domains` or `endpoints` arrays in `nexuscos_pf.js`
2. Test locally with mock mode
3. Deploy via GitHub Actions

## 🎉 Benefits

- **Proactive Monitoring**: Detect issues before users do
- **Performance Insights**: Track platform performance over time
- **Deployment Validation**: Verify deployments are successful
- **Historical Data**: Maintain monitoring history via artifacts
- **Automated Alerting**: GitHub Actions notifications for failures
- **Zero Configuration**: Works out-of-the-box with sensible defaults

This PF system represents the foundation for the "World's First Creative Operating System" monitoring infrastructure, providing the reliability and insights needed for a platform of Nexus COS's scope and ambition.
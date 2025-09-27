# Nexus COS PF Master Script Usage Guide - Global Launch Implementation

## Overview

The `nexus-cos-pf-master.js` script provides final Puppeteer readiness verification for the NEXUS COS Global Launch. It supports multi-phase launch detection and validation for both Beta and Production environments.

## Launch Phases

### Beta Phase (Starting 2025-10-01)
- **Domain:** beta.nexuscos.online
- **SSL Provider:** IONOS
- **CDN Provider:** CloudFlare (Full Strict)
- **Features:** Basic SSL, compression, security headers

### Production Phase (Starting 2025-11-17)
- **Domain:** nexuscos.online
- **SSL Provider:** IONOS
- **CDN Provider:** CloudFlare (Full Strict)
- **Features:** Enhanced SSL, rate limiting, IP restrictions, advanced security

## Purpose

- **Phase-aware verification** based on current date
- **Multi-domain support** for beta and production environments
- **IONOS SSL certificate validation**
- **CloudFlare CDN detection and verification**
- **Infrastructure readiness verification**
- **Comprehensive JSON + PDF summary reports with phase information**
- **Screenshot capture for visual verification**

## Requirements

- Node.js (tested with v18+)
- Puppeteer dependency (automatically installed)
- Chrome browser (optional - falls back to mock mode if unavailable)

## Usage

### Basic Execution

```bash
node nexus-cos-pf-master.js
```

### Output

The script creates an `output/` directory with phase-specific files:

1. **nexuscos_pf_report_[phase].json** - Complete verification report in JSON format with phase information
2. **nexuscos_pf_screenshot_[phase].png** - Screenshot of the homepage for the current phase
3. **nexuscos_pf_summary_[phase].pdf** - PDF summary report for the current phase

Where `[phase]` is one of: `pre-beta`, `beta`, or `production`.

### Phase Detection

The script automatically detects the current launch phase based on the system date:

- **Pre-Beta** (Before 2025-10-01): Uses nexuscos.online with Let's Encrypt SSL
- **Beta** (2025-10-01 to 2025-11-16): Uses beta.nexuscos.online with IONOS SSL
- **Production** (From 2025-11-17): Uses nexuscos.online with IONOS SSL and enhanced features

### Example Output Structure

```json
{
  "timestamp": "2025-10-15T10:30:00.000Z",
  "launchPhase": {
    "phase": "beta",
    "domain": "https://beta.nexuscos.online",
    "environment": "beta",
    "sslProvider": "IONOS",
    "cdnProvider": "CloudFlare",
    "startDate": "2025-10-01T00:00:00.000Z"
  },
  "domain": "https://beta.nexuscos.online",
  "status": "HEALTHY",
  "checks": [
    {
      "step": "Launch Phase Detection",
      "result": "PASS",
      "phase": "beta"
    },
    {
      "step": "SSL Configuration",
      "result": "PASS",
      "provider": "IONOS"
    },
    {
      "step": "CDN Configuration",
      "result": "PASS",
      "provider": "CloudFlare"
    }
  ],
  "infrastructure": {
    "ssl": {
      "provider": "IONOS",
      "protocols": ["TLSv1.2", "TLSv1.3"]
    },
    "cdn": {
      "provider": "CloudFlare",
      "mode": "Full (Strict)"
    }
  },
  "performance": {
    "JSHeapUsed": 15678901,
    "Nodes": 200,
    "environment": "beta"
  }
}
```

## Status Values

- **HEALTHY** - All checks passed successfully
- **CRITICAL** - One or more critical errors occurred
- **UNKNOWN** - Initial state before checks begin

## Operating Modes

### Production Mode
When Chrome browser is available, runs full Puppeteer verification:
- Real website navigation
- Actual screenshot capture
- Live performance metrics
- Real PDF generation

### Mock Mode
When Chrome browser is unavailable, creates test data:
- Simulated health checks
- Mock PNG screenshot (1x1 pixel placeholder)
- Mock PDF document
- Simulated performance metrics

## Testing

Run the included test script to verify functionality:

```bash
./test-nexus-pf-master.sh
```

## Integration

This script is designed for:
- CI/CD pipelines
- Pre-deployment verification
- TRAE SOLO integration
- Beta launch readiness checks

## File Management

- Output files are automatically excluded from git (via .gitignore)
- Each run overwrites previous output files
- No cleanup is required between runs

## Troubleshooting

### Puppeteer Issues
If you see Chrome browser errors:
- The script automatically falls back to mock mode
- Install Chrome browser for full functionality: `npx puppeteer browsers install chrome`

### Permission Issues
- Ensure write permissions to current directory
- Script creates `output/` directory automatically

### Network Issues
- In production mode, requires network access to nexuscos.online
- Mock mode works offline for testing purposes
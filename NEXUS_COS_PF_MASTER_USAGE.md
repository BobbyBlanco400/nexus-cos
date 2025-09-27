# Nexus COS PF Master Script Usage Guide

## Overview

The `nexus-cos-pf-master.js` script provides final Puppeteer readiness verification for nexuscos.online. It's designed for single-run execution with no background daemons or cronjobs.

## Purpose

- Final verification before TRAE SOLO & Beta Launch
- Core health checks (homepage, SSL/200, title, performance metrics)
- Generate comprehensive JSON + PDF summary reports
- Screenshot capture for visual verification

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

The script creates an `output/` directory with three files:

1. **nexuscos_pf_report.json** - Complete verification report in JSON format
2. **nexuscos_pf_screenshot.png** - Screenshot of the homepage
3. **nexuscos_pf_summary.pdf** - PDF summary report

### Example Output Structure

```json
{
  "timestamp": "2025-09-27T15:08:52.083Z",
  "domain": "https://nexuscos.online",
  "status": "HEALTHY",
  "checks": [
    {
      "step": "Homepage Load",
      "result": "PASS"
    },
    {
      "step": "HTTP 200 Response", 
      "result": "PASS"
    },
    {
      "step": "Page Title",
      "result": "PASS",
      "title": "Nexus COS - Production Site"
    },
    {
      "step": "Screenshot",
      "result": "CAPTURED",
      "path": "/path/to/output/nexuscos_pf_screenshot.png"
    },
    {
      "step": "PDF Summary",
      "result": "EXPORTED", 
      "path": "/path/to/output/nexuscos_pf_summary.pdf"
    }
  ],
  "performance": {
    "JSHeapUsed": 12345678,
    "Nodes": 150
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
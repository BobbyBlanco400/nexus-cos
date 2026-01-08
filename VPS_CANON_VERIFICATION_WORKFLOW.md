# N3XUS COS VPS Canon-Verification & Launch Workflow

## Overview

This document provides the complete VPS-ready workflow for N3XUS COS deployment, including canon-verification and atomic execution.

## 🎯 Atomic One-Line Bash Command (VPS Ready)

```bash
cd /home/youruser/nexus-cos && \
mkdir -p branding/official && \
cp /home/youruser/Downloads/Official\ logo.svg branding/official/N3XUS-vCOS.svg && \
[ -f branding/official/N3XUS-vCOS.svg ] || { echo "Canonization failed — logo missing"; exit 1; } && \
CANON_CONFIG="canon-verifier/config/canon_assets.json" && \
mkdir -p "$(dirname "$CANON_CONFIG")" && \
[ -f "$CANON_CONFIG" ] || echo "{}" > "$CANON_CONFIG" && \
jq '.OfficialLogo = "/home/youruser/nexus-cos/branding/official/N3XUS-vCOS.svg"' "$CANON_CONFIG" > "$CANON_CONFIG.tmp" && mv "$CANON_CONFIG.tmp" "$CANON_CONFIG" && \
TIMESTAMP=$(date +%Y%m%d_%H%M%S) && \
LOG_DIR="canon-verifier/logs/run_$TIMESTAMP" && mkdir -p "$LOG_DIR" && export CANON_LOG_DIR="$LOG_DIR" && \
python3 canon-verifier/trae_go_nogo.py && \
pm2 start ecosystem.config.js --only n3xus-platform && \
docker-compose -f docker-compose.yml up -d && \
echo "GO: Official logo canonized, verification passed, N3XUS COS fully live. Logs saved to $LOG_DIR"
```

### Prerequisites

- `jq` must be installed: `sudo apt-get install jq`
- `pm2` must be installed: `npm install -g pm2`
- `docker` and `docker-compose` must be installed
- Python 3 must be available

## 📊 Execution Flow Diagram (VPS)

```
[Start] 
   |
   v
[Canonical Branding Directory Check]
   |
   v
[Copy Official Logo → branding/official/N3XUS-vCOS.svg]
   |
   v
[Verify Logo Exists] --fail--> [Abort Execution]
   |
   v
[Update canon-verifier Config (JSON)]
   |
   v
[Create Timestamped Logging Folder]
   |
   v
[Run Full canon-verifier Harness]
   |--fail--> [Abort Launch, Logs Retained]
   |
   v
[Verification Passed?]
   |
   +--> Yes --> [Launch PM2 Services]
   |           [Launch Docker Services]
   |           |
   |           v
   |       [Final GO Confirmation]
   |
   +--> No  --> [Stop Execution, Output Logs]
```

## 🎯 Artifact Outputs

After successful execution, the following artifacts are created:

### 1. Canonical Logo
**Location:** `branding/official/N3XUS-vCOS.svg`  
**Purpose:** Official canonical logo for N3XUS COS

### 2. Verification Config
**Location:** `canon-verifier/config/canon_assets.json`  
**Purpose:** Configuration file with official logo path and verification rules

**Example:**
```json
{
  "OfficialLogo": "/home/youruser/nexus-cos/branding/official/N3XUS-vCOS.svg",
  "VerificationTimestamp": "2026-01-08T20:14:30Z",
  "AssetRegistry": {
    "logos": {
      "official": "/home/youruser/nexus-cos/branding/official/N3XUS-vCOS.svg",
      "alternate": []
    },
    "branding": {
      "colors": "branding/colors.env",
      "theme": "branding/theme.css"
    }
  },
  "VerificationRules": {
    "logoRequired": true,
    "logoFormats": ["svg", "png"],
    "minLogoSize": 1024,
    "maxLogoSize": 10485760
  }
}
```

### 3. Timestamped Logs
**Location:** `canon-verifier/logs/run_YYYYMMDD_HHMMSS/`  
**Contents:**
- `verification.log` - Detailed execution log
- `verification_report.json` - Structured verification report

**Example Log Directory:**
```
canon-verifier/logs/run_20260108_201430/
├── verification.log
└── verification_report.json
```

## 🔍 Canon-Verifier: TRAE GO/NO-GO Harness

The `canon-verifier/trae_go_nogo.py` script performs comprehensive verification:

### Verification Phases

1. **Directory Structure Verification**
   - Checks required directories exist
   - Validates canonical paths

2. **Configuration Verification**
   - Validates `canon_assets.json` format
   - Checks required configuration keys

3. **Canonical Logo Verification**
   - Verifies official logo exists at canonical path
   - Validates file size (1KB - 10MB)
   - Checks file format (SVG or PNG)

4. **Service Readiness Check**
   - Verifies PM2 availability
   - Verifies Docker availability
   - Checks docker-compose availability

5. **Canon-Verifier Harness** (Optional)
   - Runs existing `run_verification.py` orchestration
   - Executes all canon-verifier phases

### GO/NO-GO Decision

**GO Status:**
- All critical verifications passed
- Canonical logo verified
- Configuration valid
- System ready for launch

**NO-GO Status:**
- Critical verification failed
- Logo missing or invalid
- Configuration errors
- Logs saved for debugging

### Exit Codes

- `0` - GO: All verifications passed
- `1` - NO-GO: Verification failed

## 🚀 Manual Execution (Step-by-Step)

If you prefer to run the workflow step-by-step:

### 1. Navigate to Repository
```bash
cd /home/youruser/nexus-cos
```

### 2. Create Canonical Directory
```bash
mkdir -p branding/official
```

### 3. Copy Official Logo
```bash
cp /home/youruser/Downloads/Official\ logo.svg branding/official/N3XUS-vCOS.svg
```

### 4. Verify Logo Copied
```bash
if [ ! -f branding/official/N3XUS-vCOS.svg ]; then
    echo "ERROR: Logo not copied"
    exit 1
fi
```

### 5. Update Configuration
```bash
jq '.OfficialLogo = "/home/youruser/nexus-cos/branding/official/N3XUS-vCOS.svg"' \
   canon-verifier/config/canon_assets.json > \
   canon-verifier/config/canon_assets.json.tmp

mv canon-verifier/config/canon_assets.json.tmp \
   canon-verifier/config/canon_assets.json
```

### 6. Create Log Directory
```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_DIR="canon-verifier/logs/run_$TIMESTAMP"
mkdir -p "$LOG_DIR"
export CANON_LOG_DIR="$LOG_DIR"
```

### 7. Run Canon-Verifier
```bash
python3 canon-verifier/trae_go_nogo.py
```

### 8. Launch Services (if verification passes)
```bash
# Launch PM2 services
pm2 start ecosystem.config.js --only n3xus-platform

# Launch Docker services
docker-compose -f docker-compose.yml up -d
```

### 9. Verify Launch
```bash
# Check PM2 services
pm2 list

# Check Docker services
docker-compose ps
```

## 📝 Verification Report

After running the canon-verifier, check the verification report:

```bash
cat canon-verifier/logs/run_YYYYMMDD_HHMMSS/verification_report.json
```

**Example Report:**
```json
{
  "timestamp": "2026-01-08T20:14:30Z",
  "phases": {
    "directory_structure": {
      "status": "PASS",
      "directories_checked": [
        "branding/official",
        "canon-verifier/config",
        "canon-verifier/logs",
        "canon-verifier/output"
      ]
    },
    "configuration": {
      "status": "PASS",
      "config_file": "canon-verifier/config/canon_assets.json"
    },
    "canonical_logo": {
      "status": "PASS",
      "logo_path": "/home/youruser/nexus-cos/branding/official/N3XUS-vCOS.svg",
      "file_size": 2048,
      "format": "svg"
    },
    "service_readiness": {
      "status": "PASS"
    },
    "canon_verifier_harness": {
      "status": "PASS",
      "exit_code": 0
    }
  },
  "overall_status": "GO",
  "verdict": "PASS",
  "message": "All critical verifications passed. System is GO for launch."
}
```

## 🔧 Troubleshooting

### Logo Not Found
```bash
# Check if logo exists
ls -lh branding/official/N3XUS-vCOS.svg

# Verify path in config
cat canon-verifier/config/canon_assets.json | jq '.OfficialLogo'
```

### Verification Failed
```bash
# Check logs
tail -100 canon-verifier/logs/run_YYYYMMDD_HHMMSS/verification.log

# Check report
cat canon-verifier/logs/run_YYYYMMDD_HHMMSS/verification_report.json | jq '.phases'
```

### Service Launch Failed
```bash
# Check PM2 status
pm2 list
pm2 logs

# Check Docker status
docker-compose ps
docker-compose logs
```

## 📚 Related Documentation

- [Canon-Verifier README](canon-verifier/README.md)
- [Branding Assets](branding/official/README.md)
- [Configuration Guide](canon-verifier/config/README.md)
- [Log Directory](canon-verifier/logs/README.md)

## 🎯 Quick Reference Card

```bash
# One-line deployment (update paths for your environment)
cd ~/nexus-cos && \
mkdir -p branding/official && \
cp ~/Downloads/Official\ logo.svg branding/official/N3XUS-vCOS.svg && \
[ -f branding/official/N3XUS-vCOS.svg ] || { echo "Canonization failed"; exit 1; } && \
jq '.OfficialLogo = "'$(pwd)'/branding/official/N3XUS-vCOS.svg"' \
   canon-verifier/config/canon_assets.json > canon-verifier/config/canon_assets.json.tmp && \
mv canon-verifier/config/canon_assets.json.tmp canon-verifier/config/canon_assets.json && \
TIMESTAMP=$(date +%Y%m%d_%H%M%S) && \
LOG_DIR="canon-verifier/logs/run_$TIMESTAMP" && \
mkdir -p "$LOG_DIR" && export CANON_LOG_DIR="$LOG_DIR" && \
python3 canon-verifier/trae_go_nogo.py && \
pm2 start ecosystem.config.js --only n3xus-platform && \
docker-compose up -d && \
echo "GO: N3XUS COS fully live. Logs: $LOG_DIR"
```

## 🔒 Security Notes

- Ensure official logo is from a trusted source
- Verify file integrity before canonization
- Store canon-verifier logs securely
- Review verification reports regularly
- Keep configuration files under version control

## ✅ Success Criteria

A successful deployment requires:
- ✅ Official logo canonized at `branding/official/N3XUS-vCOS.svg`
- ✅ Configuration updated with logo path
- ✅ All verification phases pass
- ✅ GO verdict from canon-verifier
- ✅ PM2 services started
- ✅ Docker services running
- ✅ Logs saved to timestamped directory

---

**Version:** 1.0  
**Last Updated:** 2026-01-08  
**Status:** Production Ready

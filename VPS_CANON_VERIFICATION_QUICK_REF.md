# N3XUS COS VPS Canon-Verification - Quick Reference

## 🚀 One-Line Deployment (VPS Ready)

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

## 📋 Prerequisites

```bash
# Install jq (JSON processor)
sudo apt-get update && sudo apt-get install -y jq

# Install PM2 (process manager)
npm install -g pm2

# Install Docker & docker-compose
# Follow official Docker installation guide for your OS
```

## 🧪 Test Run (Example Script)

```bash
cd /path/to/nexus-cos
./vps-canon-verification-example.sh
```

## 🔍 Verify Installation

```bash
# Check verification passed
cat canon-verifier/logs/run_YYYYMMDD_HHMMSS/verification_report.json

# Expected output should include:
# "overall_status": "GO"
# "verdict": "PASS"
```

## 📂 Directory Structure

```
nexus-cos/
├── branding/
│   └── official/
│       ├── N3XUS-vCOS.svg      # Official canonical logo
│       └── README.md
├── canon-verifier/
│   ├── config/
│   │   ├── canon_assets.json   # Configuration
│   │   └── README.md
│   ├── logs/
│   │   ├── run_YYYYMMDD_HHMMSS/
│   │   │   ├── verification.log
│   │   │   └── verification_report.json
│   │   └── README.md
│   ├── trae_go_nogo.py         # Main verification script
│   └── run_verification.py     # Orchestrator
└── VPS_CANON_VERIFICATION_WORKFLOW.md
```

## ⚡ Quick Commands

```bash
# Run verification only
python3 canon-verifier/trae_go_nogo.py

# Check latest verification result
cat canon-verifier/logs/run_*/verification_report.json | tail -1 | jq '.overall_status'

# View latest logs
tail -100 canon-verifier/logs/run_*/verification.log | tail -100

# Check logo is in place
ls -lh branding/official/N3XUS-vCOS.svg

# Verify configuration
cat canon-verifier/config/canon_assets.json | jq '.OfficialLogo'
```

## 🎯 Exit Codes

- `0` - GO: All verifications passed
- `1` - NO-GO: Verification failed (check logs)
- `130` - User interrupted (Ctrl+C)

## 🔧 Troubleshooting

### Logo Verification Failed
```bash
# Check logo exists
ls -lh branding/official/N3XUS-vCOS.svg

# Check logo size (must be >= 1KB and <= 10MB)
stat -c%s branding/official/N3XUS-vCOS.svg
```

### Configuration Error
```bash
# Validate JSON
cat canon-verifier/config/canon_assets.json | jq '.'

# Reset configuration
cat > canon-verifier/config/canon_assets.json << 'EOF'
{
  "OfficialLogo": "",
  "VerificationTimestamp": "",
  "AssetRegistry": {
    "logos": {
      "official": "",
      "alternate": []
    }
  },
  "VerificationRules": {
    "logoRequired": true,
    "logoFormats": ["svg", "png"],
    "minLogoSize": 1024,
    "maxLogoSize": 10485760
  }
}
EOF
```

### Services Not Starting
```bash
# Check PM2
pm2 list
pm2 logs

# Check Docker
docker-compose ps
docker-compose logs --tail=50
```

## 📚 Documentation

- Full Workflow: [VPS_CANON_VERIFICATION_WORKFLOW.md](VPS_CANON_VERIFICATION_WORKFLOW.md)
- Canon-Verifier: [canon-verifier/README.md](canon-verifier/README.md)
- Example Script: [vps-canon-verification-example.sh](vps-canon-verification-example.sh)

## 🔒 Security Notes

1. Verify logo source before canonization
2. Keep configuration files under version control
3. Review logs for security warnings
4. Store verification reports securely

## ✅ Success Indicators

```json
{
  "overall_status": "GO",
  "verdict": "PASS",
  "message": "All critical verifications passed. System is GO for launch.",
  "phases": {
    "directory_structure": {"status": "PASS"},
    "configuration": {"status": "PASS"},
    "canonical_logo": {"status": "PASS"},
    "service_readiness": {"status": "WARNING"},
    "canon_verifier_harness": {"status": "PASS"}
  }
}
```

---

**Quick Start:** Run `./vps-canon-verification-example.sh`  
**Full Docs:** [VPS_CANON_VERIFICATION_WORKFLOW.md](VPS_CANON_VERIFICATION_WORKFLOW.md)  
**Version:** 1.0  
**Last Updated:** 2026-01-08

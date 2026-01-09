# TRAE Quick Start - N3XUS COS Canon-Verification

**Target:** VPS 72.62.86.217  
**Status:** ✅ READY TO EXECUTE  
**Handshake:** 55-45-17

---

## 🚀 3-Step Quick Start

### Step 1: Run Preflight Check (Optional but Recommended)

```bash
cd ~/nexus-cos
./trae_preflight_check.sh
```

**Expected:** All checks pass (warnings for missing services in CI are OK)

---

### Step 2: Run Verification

Choose ONE of the following:

#### Option A: Quick Verification (Fastest - Recommended)
```bash
cd ~/nexus-cos
python3 canon-verifier/trae_go_nogo.py
```
**Time:** ~5 seconds  
**Best for:** Quick health check on operational system

#### Option B: Full Verification + Launch (Complete)
```bash
cd ~/nexus-cos/canon-verifier
./trae_one_shot_launch.sh
```
**Time:** ~30 seconds  
**Best for:** Complete verification with service launch

---

### Step 3: Verify Success

```bash
# Check services
pm2 list
docker-compose ps

# View latest log
tail -50 $(ls -t canon-verifier/logs/run_*/verification.log | head -1)

# Check verdict
cat canon-verifier/output/canon-verdict.json | jq '.verdict.executive_truth'
```

**Expected Output:**
- Services: ACTIVE
- Verdict: "Fully operational operating system"
- Status: GO

---

## ✅ Success Indicators

You'll see:
```
✅ ✅ ✅  GO: N3XUS COS FULLY VERIFIED AND LAUNCHED  ✅ ✅ ✅

System Status:
  ✓ Verification: PASSED
  ✓ PM2 Services: ACTIVE
  ✓ Docker Services: ACTIVE
  ✓ N3XUS COS: OPERATIONAL
```

---

## 📁 Generated Artifacts

All artifacts saved to:
- **Logs:** `canon-verifier/logs/run_TIMESTAMP/`
- **Artifacts:** `canon-verifier/output/`
- **Report:** `verification_report.json`

---

## 🔧 Troubleshooting

### Issue: "Logo not found"
```bash
ls -lh branding/official/N3XUS-vCOS.svg
# If missing, copy: cp ~/Downloads/Official\ logo.svg branding/official/N3XUS-vCOS.svg
```

### Issue: "Services not starting"
```bash
pm2 restart all
docker-compose restart
```

### Issue: "Verification failed"
```bash
# Check logs
tail -100 canon-verifier/logs/run_*/verification.log

# Check report
cat canon-verifier/logs/run_*/verification_report.json | jq '.'
```

---

## 📚 Full Documentation

For complete details, see:
- **Complete Guide:** `TRAE_COMPLETE_EXECUTION_GUIDE.md`
- **Verification Report:** `BULLETPROOF_VERIFICATION_REPORT.md`
- **Workflow Guide:** `VPS_CANON_VERIFICATION_WORKFLOW.md`

---

## 🎯 One-Line Commands

```bash
# Preflight check
./trae_preflight_check.sh

# Quick verification
python3 canon-verifier/trae_go_nogo.py

# Full launch
cd canon-verifier && ./trae_one_shot_launch.sh

# Check status
pm2 list && docker-compose ps

# View logs
tail -100 $(ls -t canon-verifier/logs/run_*/verification.log | head -1)
```

---

**That's it! The system is ready for your execution on VPS 72.62.86.217.**

**Handshake:** 55-45-17 | **Status:** ✅ GO

# Nexus COS Franchise Scripts - Quick Start Guide

## ⚠️ Prerequisites & Blockers

Before running the franchise installation, be aware of current system blockers:

**Known Blockers:**
- Outbound VPS access to Debian mirrors is refused (affects apt-dependent services)
- Host NGINX config needs /stream and /streaming route injection
- Some containers blocked by legacy naming conflicts

The installer will display blocker status and resolution options at startup.

---

## 🚀 One-Command Installation

Install all three franchises (RICO, HIGH STAKES, DA YAY) with a single command:

```bash
# Navigate to the franchises directory in your nexus-cos repository
cd franchises
sudo bash install-all-franchises.sh
```

**Installation Time:** ~5 seconds  
**Output:** 29 files + master registry

---

## 📦 What Gets Installed

### RICO (Legal Thriller)
- 13-episode series + 25-min short film
- Courtroom drama meets street crime
- AI-ready text-to-video prompts

### HIGH STAKES (Crime Thriller)
- 8-episode series + 45-min pilot
- Underground betting empire
- Festival-ready content

### DA YAY (Bay Area Flagship) ⭐
- 13-episode series + 45-min film
- Music integration + NFT-enabled
- Regional spinoffs (Vallejo, SF)
- Investor pitch ready

---

## 📂 Installation Location

```
/opt/nexus-cos/franchises/
├── rico/               (7 files)
├── high-stakes/        (7 files)
├── da-yay/            (13 files)
└── franchise-registry.json
```

---

## ✅ Verify Installation

```bash
# Quick check
ls -la /opt/nexus-cos/franchises/

# View registry
cat /opt/nexus-cos/franchises/franchise-registry.json

# Check specific franchise
ls -la /opt/nexus-cos/franchises/da-yay/
```

---

## 🎬 Next Steps

After installation, franchises are ready for:

1. **AI Content Generation** → Use text-to-video prompts
2. **Pipeline Integration** → Auto-inject to Nexus Studio
3. **Streaming Deploy** → Nexus Stream ready
4. **Festival Submission** → Short films packaged
5. **Music Sync** → DA YAY music integration
6. **Regional Expansion** → DA YAY spinoffs

---

## 🛠️ Individual Installation

Install one franchise at a time:

```bash
# RICO only
sudo bash install-rico.sh

# HIGH STAKES only
sudo bash install-high-stakes.sh

# DA YAY only
sudo bash install-da-yay.sh
```

---

## 📋 Requirements

- **OS:** Linux/Unix
- **Permissions:** sudo/root access
- **Disk Space:** ~1MB
- **Dependencies:** bash, cat, mkdir, touch

---

## 🎯 Launch Information

**Launch Date:** January 1, 2026  
**Status:** Production Ready  
**Monetization:** Enabled  
**Platform:** Nexus COS

---

## 📖 Full Documentation

For complete details, see:
- `franchises/README.md` - Full documentation
- `FRANCHISE_IMPLEMENTATION_SUMMARY.md` - Technical details

---

**Created by Bobby Blanco | PUABO Music -N- Media Group**

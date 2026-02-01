# REMOTE MIC BRIDGE & V-PROMPTER LITE: LOCKED CONFIGURATION

**Date:** 2026-01-28  
**Status:** ACTIVE & LOCKED  
**Author:** Trae AI (Emergent Protocol)

---

## 1. System Architecture

This module provides a low-latency audio bridge from a mobile device (Android/iOS) to the N3XUS v-COS streaming engine, coupled with a lightweight teleprompter for remote operation.

### **A. Remote Mic Bridge (Port 8081)**
*   **Role:** Audio Input & Processing
*   **Engine:** Web Audio API (Client-Side)
*   **Processing Chain:** "Shure MV7 Profile"
    *   **Noise Gate:** Threshold -50dB, Ratio 12:1
    *   **High-Pass Filter:** 80Hz (Rumble removal)
    *   **Presence Boost:** 3kHz, +3dB (Vocal clarity)
    *   **De-Esser:** 7kHz Shelf, -2dB
    *   **Compressor:** Threshold -24dB, Ratio 3:1
*   **File Path:** `C:\Users\wecon\Downloads\nexus-cos-main\index.html` (Served via Python HTTP)

### **B. V-Prompter Lite (Port 3504)**
*   **Role:** Teleprompter & Remote Control
*   **Engine:** Node.js / Express
*   **Features:** Auto-scroll, Speed Control, Voice Cue Ready
*   **File Path:** `C:\Users\wecon\Downloads\nexus-cos-main\services\v-prompter-lite\server.js`

---

## 2. Mobile Connection Guide

**Prerequisite:** Ensure your mobile device is on the same Wi-Fi network as this PC.

### **Step 1: Connect Microphone**
1.  Open Chrome on Android.
2.  Navigate to: **`http://<YOUR_PC_IP>:8081/index.html`** (e.g., `http://10.0.0.145:8081/index.html`)
3.  Tap **"1. START SYSTEM"**.
4.  Tap **"2. CONNECT PHONE MIC"**.
5.  *Grant Microphone Permissions if asked.*

### **Step 2: Activate Prompter**
1.  Once the mic is active, a popup will ask to bridge.
2.  Tap **OK** to be redirected to **`http://<YOUR_PC_IP>:3504`**.
3.  Use the **START/PAUSE** buttons to control your script.

---

## 3. Verification & Maintenance

### **Automated Verification**
Run the Emergent Master Verification script to check system health:
```powershell
.\EMERGENT_MASTER_VERIFICATION.ps1
```

### **Manual Startup (If Rebooted)**
If the system is restarted, run these commands in separate terminals:

**Terminal 1 (Prompter Service):**
```bash
node services/v-prompter-lite/server.js
```

**Terminal 2 (Mic Bridge Server):**
```bash
python -m http.server 8081
```

---

**LOCKED IN FOR HANDOFF.** 🚀

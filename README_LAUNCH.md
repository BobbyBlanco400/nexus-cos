# 🚀 N3XUS v-COS: EMERGENCY LAUNCH PROTOCOL

**Target:** Hostinger VPS (72.62.86.217)
**Status:** 100% READY
**Action:** IMMEDIATE DEPLOYMENT

Since the platform files are verified locally, execute these steps on your VPS terminal **NOW** to go live.

---

### **OPTION 1: AUTOMATED ONE-LINER (RECOMMENDED)**
If you have `git` and the repository is already cloned on the server:

1.  **SSH into your VPS:**
    ```bash
    ssh root@72.62.86.217
    ```

2.  **Navigate to the project root:**
    ```bash
    cd /path/to/nexus-cos-main
    ```

3.  **Run the Launch Script:**
    *(Copy-paste this entire block)*
    ```bash
    chmod +x LAUNCH_PRODUCTION.sh
    ./LAUNCH_PRODUCTION.sh
    ```

---

### **OPTION 2: MANUAL LAUNCH (IF FILES ARE MISSING)**
If you need to upload the latest configuration first:

1.  **Upload the Critical Configs (From Local Machine):**
    ```powershell
    scp ecosystem.config.js root@72.62.86.217:/path/to/nexus-cos-main/
    scp docker-compose.full.yml root@72.62.86.217:/path/to/nexus-cos-main/
    scp LAUNCH_PRODUCTION.sh root@72.62.86.217:/path/to/nexus-cos-main/
    ```

2.  **Execute on Server:**
    ```bash
    ssh root@72.62.86.217 "cd /path/to/nexus-cos-main && chmod +x LAUNCH_PRODUCTION.sh && ./LAUNCH_PRODUCTION.sh"
    ```

---

### **VERIFICATION AFTER LAUNCH**
Once the script completes, verify access immediately:

*   **Public Portal:** [http://72.62.86.217](http://72.62.86.217)
*   **Remote Mic Bridge:** [http://72.62.86.217:8081](http://72.62.86.217:8081)
*   **V-Prompter Lite:** [http://72.62.86.217:3504](http://72.62.86.217:3504)

**GO FOR LAUNCH.** 🚀

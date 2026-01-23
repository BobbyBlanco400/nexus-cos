# 📘 TRAE OPERATOR RUNBOOK (Phase 5)

**AUTHORITY:** TRAE SOLO CODER
**TARGET:** N3XUS v-COS Sovereign Stack
**STATUS:** Code Verified | Deployment Pending Credentials

---

## 🚨 CRITICAL ACTION REQUIRED
The automated deployment to the Sovereign VPS (`72.62.86.217`) was paused because the SSH Private Key for `root` was not found in the workspace, and password authentication failed.

**To Unlock Deployment:**
1.  **Locate** your valid SSH Private Key for `root@72.62.86.217`.
2.  **Add** it to GitHub Secrets:
    *   Name: `SSH_PRIVATE_KEY` (or `VPS_SSH_PRIVATE_KEY`)
    *   Value: `(Paste content of your .pem or id_rsa)`
3.  **Trigger** the workflow:
    *   `gh workflow run "VPS Deploy - N3XUS v-COS" --ref main`

---

## ✅ VERIFICATION SUMMARY (COMPLETED)
1.  **Canonical Logic:** `scripts/verify-phases.js` PASSED.
    *   Phase 5 (CCF): **ACTIVE**
    *   Phases 6-9: **DISABLED** (Sovereign Lock)
2.  **CI Pipeline:** `n3xus-canon-verify.yml` PASSED.
    *   Genesis Lock: **SECURE**
    *   Mainnet Guard: **ACTIVE**
3.  **Codebase:** Merged to `main` (PR #243).

## 🛠️ MANUAL DEPLOYMENT (FALLBACK)
If you cannot add the secret, you can deploy manually from your local machine:

1.  **Bundle the Stack:**
    ```bash
    tar -czf phase5_deploy.tar.gz services n3xus-holofabric-core docker-compose.codespaces.yml launch_vps_stack.sh
    ```
2.  **Upload to VPS:**
    ```bash
    scp phase5_deploy.tar.gz root@72.62.86.217:/var/www/nexus-cos/
    ```
3.  **Execute on VPS:**
    ```bash
    ssh root@72.62.86.217
    cd /var/www/nexus-cos/
    tar -xzf phase5_deploy.tar.gz
    chmod +x launch_vps_stack.sh
    ./launch_vps_stack.sh
    ```

**SYSTEM IS READY FOR UPLOAD.**

# 🚀 SOVEREIGN DEPLOYMENT INSTRUCTIONS (v3.1)

**TARGET:** 72.62.86.217 (Sovereign VPS)
**PROTOCOL:** N3XUS LAW 55-45-17
**STATUS:** READY FOR UPLOAD

You have generated the Canonical Python Monorepo and the Final Verification Protocols locally. These must now be moved to your Sovereign VPS.

---

## 📦 STEP 1: CREATE THE PACKAGE

Please create a ZIP file named **`sovereign_deployment_v3.1.zip`** containing the following:

1.  📁 **`nexus-vcos/`** (The entire directory)
2.  📄 **`EMERGENT_VERIFICATION_V3.1.sh`**
3.  📄 **`EMERGENT_VERIFICATION_CERTIFICATE_V3.1.md`**
4.  📄 **`LAUNCH_STATUS.md`**
5.  📄 **`PRODUCTION_URL_MATRIX.md`**
6.  📄 **`OFFICIAL_LAUNCH_CERTIFICATE.md`**
7.  📄 **`FRANCHISE_MASTER_LIST.md`**
8.  📄 **`PYTHON_MONOREPO_MASTER.md`**

---

## 📤 STEP 2: UPLOAD TO VPS

Use your preferred SFTP client (FileZilla, Cyberduck) or Terminal to upload the package.

**Target Directory:** `/opt/nexus-cos/`

**Command Line Example:**
```bash
scp -r nexus-vcos EMERGENT_VERIFICATION_V3.1.sh *.md root@72.62.86.217:/opt/nexus-cos/
```

---

## ⚡ STEP 3: EXECUTE & VERIFY

Once uploaded, log in to your VPS and run the following commands to lock in the deployment:

```bash
# 1. Login
ssh root@72.62.86.217

# 2. Go to directory
cd /opt/nexus-cos/

# 3. Make script executable
chmod +x EMERGENT_VERIFICATION_V3.1.sh

# 4. Run the Final Sovereign Verification
./EMERGENT_VERIFICATION_V3.1.sh
```

---

## ✅ EXPECTED OUTCOME
The script will ping your Sovereign Domain (`n3xuscos.online`), verify the SSL certificates, and confirm the 100% operation of the stack.
Upon success, it will generate the final **`EMERGENT_FINAL_REPORT_V3.1.md`** on the server.

**Deployment Package Preparation Complete.**

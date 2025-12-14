# 🚀 Complete THIIO + Master PF Deployment - Quick Reference

## One-Line SSH Command (Copy & Paste)

```bash
ssh user@your-server 'bash -s' < deploy_complete_thiio_master_pf.sh
```

**Replace `user@your-server` with your actual server details.**

---

## What This Does

✅ Installs all dependencies (git, python3, etc.)  
✅ Clones/updates Nexus COS repository  
✅ Verifies THIIO handoff package (SHA256: `23E511A6...`)  
✅ Executes Master PF pipeline (5 steps)  
✅ Creates unified bundle combining both  

---

## Alternative Commands

### If you need to copy the script first:
```bash
scp deploy_complete_thiio_master_pf.sh user@your-server:/tmp/ && ssh user@your-server 'bash /tmp/deploy_complete_thiio_master_pf.sh'
```

### If you're already on the server:
```bash
cd /opt/nexus-cos
git clone -b copilot/setup-github-ready-repo-structure https://github.com/BobbyBlanco400/nexus-cos.git .
bash deploy_complete_thiio_master_pf.sh
```

---

## Output Files

After running, you'll find:

1. **THIIO Handoff Package**
   - Location: `/opt/nexus-cos/dist/Nexus-COS-THIIO-FullStack.zip`
   - SHA256: `23E511A6F52F17FE12DED43E32F71D748FBEF1B32CA339DBB60C253E03339AB4`
   - Size: 1.71 MB
   - Purpose: Deploy entire Nexus COS platform

2. **Master PF Output**
   - Location: `/opt/nexus-cos/output/`
   - Contains: Rendered segments, compliance reports
   - Purpose: Short film production output

3. **Unified Bundle**
   - Location: `/opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified.zip`
   - Contains: Both THIIO handoff + Master PF
   - Purpose: Complete package for download

---

## Download Results

```bash
# Download unified bundle
scp user@your-server:/opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified.zip .

# Download just THIIO handoff
scp user@your-server:/opt/nexus-cos/dist/Nexus-COS-THIIO-FullStack.zip .

# Download Master PF output
scp -r user@your-server:/opt/nexus-cos/output/ .
```

---

## Verification Commands

```bash
# Verify THIIO package
ssh user@your-server 'sha256sum /opt/nexus-cos/dist/Nexus-COS-THIIO-FullStack.zip'

# Check Master PF execution
ssh user@your-server 'ls -la /opt/nexus-cos/output/reports/'

# View unified manifest
ssh user@your-server 'cat /opt/nexus-cos/dist/Nexus-COS-THIIO-MasterPF-Unified-manifest.json | python3 -m json.tool'
```

---

## Requirements

- SSH access to server
- Sudo privileges (or root access)
- 5GB+ free disk space
- Internet connection

---

## Troubleshooting

**Permission denied?**
```bash
ssh root@your-server 'bash -s' < deploy_complete_thiio_master_pf.sh
```

**Already exists error?**
```bash
ssh user@your-server 'rm -rf /opt/nexus-cos && bash -s' < deploy_complete_thiio_master_pf.sh
```

**Check disk space:**
```bash
ssh user@your-server 'df -h /opt'
```

---

## Complete Documentation

See `SSH_DEPLOYMENT_GUIDE.md` for full details and all deployment methods.

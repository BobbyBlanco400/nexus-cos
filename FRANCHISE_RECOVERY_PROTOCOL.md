# 🕵️ FRANCHISE RECOVERY & RESTORATION PROTOCOL

**STATUS:** ACTIVE
**DETECTED:** 3/15 Franchises Fully Online
**MISSING:** 12 Franchises (Metadata/Assets Pending)

## 📋 Recovery Manifest
The following franchises have been detected in the "Deep Archive" or "Server Proofs" but require re-hydration into the active `nexus-cos` pipeline.

### ✅ ACTIVE (Fully Deployed)
1. **DA YAY** (Flagship / Urban)
2. **RICO** (Legal / Thriller)
3. **HIGH STAKES** (Crime / Pilot)

### ⚠️ PENDING RESTORATION (Awaiting Metadata)
*Please populate the `franchises/restoration_list.yaml` file with the names of the missing franchises to trigger auto-scaffold generation.*

---

## 🛠️ Restoration Instructions

1. **Edit the Restoration List:**
   Open `franchises/restoration_list.yaml` and add your 12-15 missing franchises.

2. **Run the Restoration Tool:**
   Execute the following command to generate the file structures, manifests, and AI prompts for all listed franchises:
   ```bash
   ./tools/restore-franchises.sh
   ```

3. **Verify:**
   The system will automatically register them in `franchise-registry.json` and prepare them for Day 1 Launch.

---

## 📦 What Will Be Restored?
For each franchise you list, we will generate:
- `franchise-config.yaml` (Registration)
- `content/series-manifest.json` (Episode Structure)
- `prompts/ai-generation.prompt` (Text-to-Video Setup)
- `pipeline/injection.yaml` (Studio Integration)

**This protocol ensures your full IP library is online and monetizable immediately.**

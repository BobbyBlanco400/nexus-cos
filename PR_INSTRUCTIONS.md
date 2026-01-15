# Pull Request: Official N3XUS v-COS Holographic Logo Update

**Description:**
This PR enforces N3XUS LAW by updating the entire stack to use the official holographic PNG logo (`6f65c21d-8980-4b14-ac6c-893cc6d7598b.png`). All deprecated SVG references have been removed.

**Changes:**
- 🗑️ **Removed:** `branding/logo.svg` and `branding/official/N3XUS-vCOS.svg` (SVG format is now deprecated).
- 🔄 **Updated:** `deploy-holographic-logo.sh` to handle PNG deployment and fix line-ending issues.
- 📝 **Updated:** `branding/README.md`, `assets/README.md`, and `branding/official/README.md` to reflect PNG usage.
- ⚙️ **Configured:** `canon-verifier/config/canon_assets.json` and `branding/colors.env` to point to the new PNG.
- 💻 **Codespaces:** Updated `scripts/bootstrap.sh` to automatically deploy the logo on environment creation.
- 🖼️ **Showcase:** Updated `logo-showcase.html` to reference `logo.png`.

**Action Required by Agent:**
1.  **Upload File:** Place the official logo file `6f65c21d-8980-4b14-ac6c-893cc6d7598b.png` into `branding/official/N3XUS-vCOS.png`.
2.  **Verify:** Run `bash deploy-holographic-logo.sh` to confirm stack-wide deployment.
3.  **Commit:** Add the new image file and push.

**Validation:**
- Run `scripts/bootstrap.sh` to verify automatic deployment logic.
- Check `branding/logo.png` exists after deployment.

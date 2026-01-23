```markdown
# TRAE Solo Coder — Phase 5: Create / Verify / Execute / Deploy / Launch (Sovereign VPS)

Purpose
- Instruct TRAE Solo Coder to create, verify, execute, and deploy Phase 5 (CCF) to the owner's sovereign VPS.
- Maintain canonical enforcement: Phase 5 enabled; Phases 6–9 scaffold-only; Phases 1–4 unchanged.
- Ensure legal-safe messaging and no claims of consciousness.

Prerequisites (for TRAE Solo Coder)
- Repo: Puabo20/puabo20.github.io (you have push & PR permissions for branch feat/trae-vps-deploy).
- SSH access to the sovereign VPS with a deploy key (private key in repository secrets: SSH_PRIVATE_KEY).
- Secrets configured in repository: SSH_USER, SSH_HOST, SSH_PORT (optional), REMOTE_PATH (optional).
- GitHub CLI (gh) authenticated as Puabo20 or maintainers.
- Basic sudo on the VPS or a deployment user with rights to restart services.

Primary Objectives (what TRAE Solo Coder must do)
1. Create branch feat/trae-vps-deploy (already present if PR created).
2. Add/verify the following in the branch:
   - .github/workflows/trae-vps-deploy.yml (CI + optional remote deploy)
   - scripts/trae-deploy-vps.sh (helper, included here as a fallback)
   - DEPLOY_TRAE_SOLO_CODER.md (this file)
   - PHASE5_CANON.md (full Phase 5 canon; ensure it matches Issue #1)
   - README.md (Canon Status section)
   - bootstrap.sh (boot/verification)
3. Open a single Pull Request with the title and body supplied below, request review from repository owners.
4. Run CI (PR triggers verification job automatically). Fix any CI failures.
5. After PR verification, run workflow_dispatch (manual dispatch) for optional-vps-deploy to push artifacts to the sovereign VPS using the provided repo secrets.
6. Validate remote service:
   - Check /var/log or remote path bootstrap.log
   - Verify systemd unit n3xus-phase5 (if configured) or verify process is running
   - Run health-check endpoint (if provided) or curl local health probe
7. Perform post-launch checks:
   - Confirm Phase 5 canonical verification output
   - Confirm Phases 6–9 are not active
   - Confirm Phases 1–4 unchanged
   - Run the canonical verifier locally on the VPS: node scripts/verify-phases.js
8. Finalize: Post a comment in the PR with deployment logs and confirm launch success.

Security & Legal
- Use repository secrets; do NOT hardcode private keys.
- Follow the Public Legal-Safe Framing in PHASE5_CANON.md
- Ensure disclosure banners are present before any user-facing interactions.

Rollback
- If verification fails or the VPS shows errors, restore previous release (tarball or git checkout of last stable commit).
- Document the rollback steps and notify maintainers.

Deliverables (from TRAE Solo Coder)
- A single PR: feat/trae-vps-deploy (with all files added)
- CI green verifying Phase 5 and Phases 6–9 inert
- Deploy artifact uploaded to the workflow
- Confirmation comment with logs and remote-check outputs

Contact
- Owner: Puabo20 (repo owner)
- Deploy access: configured via repo secrets before running the dispatch
```
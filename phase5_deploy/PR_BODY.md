```markdown
Title: TRAE: Create / Verify / Execute / Deploy / Launch — Phase 5 (Sovereign VPS)

Summary:
This PR instructs the TRAE Solo Coder to perform Phase 5 canonical deployment to the owner's sovereign VPS. It includes CI verification to ensure Phase 5 is active and Phases 6–9 remain scaffold-only. The repo contains artifacts, a verification workflow, and an optional deploy job triggered manually (workflow_dispatch) that will push verified artifacts to the provided SSH target.

Checklist for TRAE Solo Coder:
- [ ] Confirm branch: feat/trae-vps-deploy
- [ ] Confirm PHASE5_CANON.md matches Issue #1 canonical content
- [ ] Ensure repository secrets are configured:
  - SSH_PRIVATE_KEY (private key for deploy user)
  - SSH_USER
  - SSH_HOST
  - (optional) SSH_PORT, REMOTE_PATH
- [ ] Run CI (PR verifies Phase 5 via scripts/verify-phases.js)
- [ ] On success, perform manual run of "Optional: Deploy to Sovereign VPS" via Actions -> workflow_dispatch
- [ ] Validate remote boot and health checks
- [ ] Post deployment logs and verification results in this PR
- [ ] Close related Issue #1 if deployment validates Phase 5 fully

Notes:
- The optional deploy job only runs on manual dispatch and requires repo secrets to be configured.
- Do NOT enable Phases 6–9 on the VPS (verifier will fail CI if toggled).
- This PR is instructional and contains deploy helpers; adjust remote install/service steps to match the target OS and policies.

Related: Issue #1 (Phase 5 Canon)
```
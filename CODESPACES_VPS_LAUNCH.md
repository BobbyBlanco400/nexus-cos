# Codespaces -> VPS Launch (N3XUS v-COS)

This document describes the exact steps for a Codespaces user or GitHub Code Agent to verify the HOLOFABRIC Dockerfile fix, sync the workspace, and run the master VPS launch script.

Important: the canonical HOLOFABRIC Dockerfile has already been corrected in the repository at:
`services/holofabric-runtime/Dockerfile`

It enforces:
- Node 20
- Build-time and runtime handshake: `55-45-17`
- Port: `3700`
- Health endpoint: `/health` (the Dockerfile includes a HEALTHCHECK to port 3700)

## Files added by this PR
- `.github/scripts/master_vps_launch.sh` — master script to set secrets, trigger, and stream the workflow.
- `CODESPACES_VPS_LAUNCH.md` — this instruction file.

## Before you run anything (in Codespaces terminal)
1. Sync your Codespaces workspace to the repo:
   ```bash
   cd /workspaces/N3XUS-vCOS/nexus-cos-main
   git fetch origin
   git checkout main
   git pull origin main
   ```
2. Confirm the Dockerfile is the corrected Node 20 / handshake version:
   ```bash
   cat services/holofabric-runtime/Dockerfile | sed -n '1,40p'
   ```
   You should see `FROM node:20-alpine` and handshake validation for `55-45-17`.

## Environment variables to set (in Codespaces terminal)
Provide real values before running the master script:
```bash
export N3XUS_VPS_SSH_PRIVATE_KEY='-----BEGIN OPENSSH PRIVATE KEY----- ...'
export N3XUS_VPS_HOST='n3xuscos.online'
export N3XUS_VPS_USER='root'
export N3XUS_VPS_TARGET_DIR='/var/www/nexus-cos'
# Optional:
export BRANCH='main'
export ENVIRONMENT_LABEL='production'
export GITHUB_TOKEN='ghp_... (if you want non-interactive gh auth)'
```

## Run the master script
```bash
bash .github/scripts/master_vps_launch.sh
```

What the script does
- Installs `gh` if missing and authenticates (uses `GITHUB_TOKEN` if provided).
- Writes Actions secrets into the repository: `VPS_SSH_PRIVATE_KEY`, `VPS_HOST`, `VPS_USER`, `VPS_TARGET_DIR`.
- Triggers `vps-deploy.yml` on the specified branch, waits for the run, and streams logs.
- Exits with the workflow status code:
  - `0` -> success (look for `vps-launch-notarization` artifact)
  - non-zero -> failure (open the run for failing step logs)

## Troubleshooting
- If you still see "obsolete lines" in build logs:
  - Identify the actual Dockerfile path being used (paste the first 15-20 lines from the build log or the path it references).
  - Confirm the workflow is building from the workspace path you expect and the branch/ref you requested.
- If `gh run watch` fails to find the run:
  - Wait a moment and re-run:
    ```bash
    gh run list -R owner/repo \
      --workflow "vps-deploy.yml" \
      --limit 5 \
      --json databaseId,conclusion,createdAt -q '.'
    ```

## If you want me to create the PR branch and open the PR
Apply these file changes in a branch and open the PR with the title and body defined in the MASTER VPS Launch PR payload. Once merged, run the master script from Codespaces as described above to fully deploy N3XUS v-COS to the VPS.


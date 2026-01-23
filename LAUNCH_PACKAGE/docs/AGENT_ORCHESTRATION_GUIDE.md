# Nexus COS Agent Orchestration - Operator Guide

## Overview

The Nexus COS Agent Orchestration system provides automated full-stack reconstruction, build, and deployment capabilities for the complete Nexus COS platform.

## Quick Start

### Option 1: GitHub Actions (Recommended)

1. Navigate to the **Actions** tab in your GitHub repository
2. Select the **Nexus COS Agent Orchestration** workflow
3. Click **Run workflow**
4. Configure options:
   - `deploy_staging`: Check if you want to deploy to staging VPS
   - `version`: Leave empty for auto-versioning or specify (e.g., "1.2.0")
5. Click **Run workflow** button

The workflow will:
- Parse discovery data
- Check feature parity
- Auto-scaffold missing modules
- Run tests (lint, unit, integration)
- Build Docker images
- Generate compliance report
- Create verified release
- Push images to registry
- Create deployment package
- Generate GitHub Release

### Option 2: Local Execution

```bash
# Set environment
export WORKDIR=/tmp/nexus_agent
export REGISTRY=ghcr.io/yourusername
export VERSION=1.0.0

# Create workspace
mkdir -p "$WORKDIR"
cd /path/to/nexus-cos
cp -r . "$WORKDIR/"
cd "$WORKDIR"

# Run agent steps
bash scripts/agent/run_agent_local.sh
```

## Architecture

### Workflow Steps

1. **Workspace Preparation** (`A`)
   - Creates working directories
   - Extracts discovery archive (if available)
   - Sets up reports/artifacts/output directories

2. **Discovery Parsing** (`B`)
   - Parses system state and discovery archive
   - Generates `reports/discovery_parsed.json`
   - Inventories running services, compose files, environment

3. **Feature Parity Check** (`C`)
   - Compares current state vs. canonical investor synopsis
   - Generates `reports/discrepancy_report.json`
   - Identifies missing, partial, and present modules

4. **Auto-Scaffolding** (`D`)
   - Automatically scaffolds missing critical modules
   - Creates Dockerfile, healthcheck, tests, OpenAPI specs
   - Generates both Node.js and Python service templates

5. **Testing Pipeline** (`F`)
   - Lint stage
   - Unit tests
   - Integration tests
   - E2E tests (optional)
   - Deployment simulation

6. **Build & Push** (`H`)
   - Builds Docker images with buildx
   - Captures image digests
   - Pushes to container registry
   - Updates artifacts manifest

7. **Compliance Report** (`G`)
   - Generates comprehensive PDF report
   - Includes discovery summary, parity analysis, test results
   - Creates artifacts manifest
   - Documents build status

8. **Deployment Package** (`I`)
   - Creates production-ready tar.gz
94→   - Includes docker-compose.full.yml (100+ Services - Phases 1-4 Complete)
   - Bundles deployment scripts
   - Packages all reports and artifacts

9. **Release Creation**
   - Creates `verified_release` branch
   - Tags release (`verified_release_vX.Y.Z`)
   - Publishes GitHub Release
   - Attaches all artifacts

## Required Modules (103 Total - Full Canonical Stack)

The system validates against these canonical modules:

### Core Backend (3)
- backend-api, auth, users

### Content & Streaming (10)
- content-cms, transcoder, streaming-engine, drm-service, asset-pipeline
- thumbnailer, transcode-worker, ingest-worker, metadata-worker, manifest-builder

### Monetization (5)
- monetization, puabo-blac-financing, billing-worker, payments, wallet

### Analytics (3)
- analytics, analytics-worker, recommendation

### Marketplace (1)
- marketplace

### Frontend (3)
- frontend-app, creator-dashboard, ott-mini

### Nexus Stream (2)
- nexus-stream, player-api

### PUABO Universe (5)
- puabo-nexus-fleet-manager, puabo-nexus-ai-dispatch
- puabo-nexus-driver-app-backend, puabo-nexus-route-optimizer
- puaboverse-v2

### AI & Intelligence (3)
- puabo-ai-core, rtx-orchestrator, rtx-worker

### Notifications (5)
- notifications, email-worker, webhook-worker, thirdparty-connector, crm-sync

### Search (2)
- search, profiles

### Live Streaming (3)
- live-ingest, recorder, stream-monitor

### Upload (1)
- uploader

### Audit (1)
- audit-exporter

## Special Handling: PMMG N3XUS R3CORDINGS M3DIA 3NGIN3

**Primitive:** `N3XUS-SYSTEM-PMMG`
**Phase:** 11 (PMMG N3XUS R3CORDINGS M3DIA 3NGIN3)

### Agent Protocol
1. **Browser-Only Execution**: Agents must NEVER attempt to containerize or server-host the PMMG execution logic. It runs exclusively in the client browser via WebAudio/WebRTC.
2. **Static Serving Only**: The only server-side component permitted is the static file server (Node.js/Nginx) delivering the PMMG client assets.
3. **No Transcoding**: Agents must not schedule FFmpeg or server-side transcoding jobs for PMMG assets.
4. **Canonical Lock**: PMMG ownership is locked to **PUABO Holdings LLC**. Agents must verify this ownership in `CANONICAL_RATIFICATION_INDEX.md` before deployment.

## Acceptance Criteria

The agent validates these gates before creating verified_release:

✅ **Discovery Parsed**
- `reports/discovery_parsed.json` exists
- Contains parsed inventory

✅ **Feature Parity**
- `reports/discrepancy_report.json` generated
- ≤6 critical modules missing OR auto-scaffolded

✅ **Tests Pass**
- Lint stage completes
- Unit tests pass
- Integration tests pass
- E2E tests pass (if applicable)

✅ **Compliance Report**
- `reports/compliance_report_YYYYMMDD.pdf` generated
- Attached to GitHub Release

✅ **Artifacts Manifest**
- `artifacts/artifacts_manifest.json` exists
- Contains image digests (not empty)

✅ **Deployment Package**
- `reports/deployment_package_YYYYMMDD.tar.gz` created
- Passes tar integrity check

✅ **Optional Staging Deploy**
- If performed, passes post_deploy_audit
- Artifact captured

## Outputs

### Reports Directory
- `discovery_parsed.json` - System inventory
- `discrepancy_report.json` - Module parity analysis
- `compliance_report_YYYYMMDD.pdf` - Comprehensive compliance PDF
- `deployment_report_YYYYMMDD.json` - Deployment status
- `deployment_package_YYYYMMDD.tar.gz` - Production deployment bundle
- `test_results_*.log` - Test execution logs

### Artifacts Directory
- `artifacts_manifest.json` - Image registry manifest with digests

### GitHub Release
- Tag: `verified_release_vX.Y.Z`
- Branch: `verified_release`
- Attachments:
  - Compliance PDF
  - Artifacts manifest
  - Deployment package
  - Discovery data
  - Discrepancy report

## Deployment to Hostinger VPS

### Prerequisites
- Hostinger VPS with Ubuntu 24.04 LTS
- Docker and Docker Compose installed
- Certbot (Let's Encrypt) installed
- Minimum specs: 8GB RAM, 50GB disk
- SSH access configured
- Ports 80, 443, 22 open

### Steps

1. **Download Deployment Package**
   ```bash
   # From GitHub Release
   wget https://github.com/YourOrg/nexus-cos/releases/download/verified_release_vX.Y.Z/deployment_package_YYYYMMDD.tar.gz
   ```

2. **Upload to VPS**
   ```bash
   scp deployment_package_YYYYMMDD.tar.gz root@your-vps:/opt/
   ```

3. **Extract Package**
   ```bash
   ssh root@your-vps
   cd /opt
   tar -xzf deployment_package_YYYYMMDD.tar.gz
   cd deployment_package_YYYYMMDD
   ```

4. **Configure Environment**
   ```bash
   cp deployment/.env.template .env
   nano .env
   # Fill in:
   # - POSTGRES_PASSWORD
   # - JWT_SECRET
   # - DOMAIN
   # - SSL_EMAIL
   ```

5. **Deploy**
   ```bash
   bash scripts/remote_deploy_runner.sh
   ```

6. **Verify**
   ```bash
   bash scripts/post_deploy_audit.sh
   ```

### Rollback

If deployment fails or issues arise:

```bash
bash scripts/rollback_to_tag.sh verified_release_v1.0.0
```

## Troubleshooting

### Discovery Archive Missing
**Symptom:** No discovery archive at `/tmp/nexus-full-discovery.tar.gz`

**Solution:** Agent will proceed with current system discovery. This is normal if running without a pre-existing discovery archive.

### Feature Parity Failures
**Symptom:** Many critical modules missing

**Solution:** Agent will auto-scaffold missing modules. Review `reports/discrepancy_report.json` for details.

### Build Failures
**Symptom:** Docker image build fails

**Solution:** 
1. Check `/tmp/build_*.log` files
2. Verify Dockerfile exists in service directory
3. Check Docker daemon is running
4. Ensure sufficient disk space

### Test Failures
**Symptom:** Lint/unit/integration tests fail

**Solution:** Tests are non-blocking. Review `reports/test_results_*.log` for details. Critical failures will be noted in compliance report.

### Push Failures
**Symptom:** Cannot push images to registry

**Solution:**
1. Verify `DOCKER_REGISTRY_TOKEN` secret is set
2. Check registry URL is correct
3. Ensure sufficient registry quota

## Security

### Secrets Management
- Never commit secrets to git
- Use GitHub Secrets for CI/CD
- Store production secrets in VPS `/etc/nexus/secrets.env`
- Use `.env.template` as reference, never `.env`

### KYC/PII Handling
- All KYC flows remain in sandbox mode
- Manual legal/ops approval required for production
- PII data not logged or committed

### Registry Credentials
- Use short-lived tokens where possible
- Rotate credentials regularly
- Limit token scopes to minimum required

## Monitoring & Notifications

### Progress Updates
The agent posts updates to:
- GitHub Actions logs
- GitHub Step Summary
- Slack (via `$SLACK_WEBHOOK` - optional)

### GitHub Release
Created automatically with:
- Build status
- Module counts
- Artifact links
- Deployment instructions

## Maintenance

### Updating Canonical Synopsis
Edit `docs/investor_synopsis.md` to add/modify required modules.

### Adding New Services
1. Add to `deployment/service_list.txt`
2. Create service directory in `services/`
3. Add Dockerfile and code
4. Run agent orchestration

### Updating Templates
Edit scripts in `scripts/agent/` to modify:
- `agent_scaffold.sh` - Service templates
- `build_images.sh` - Build process
- `generate_compliance_pdf.sh` - Report format

## Support

For issues or questions:
1. Check `reports/` directory for logs
2. Review GitHub Actions workflow logs
3. Consult compliance PDF
4. Open GitHub Issue with details

---

**Version:** 1.1.0  
**Last Updated:** 2026-01-18  
**Maintainer:** GitHub Code Agent Team

## IDE Task Import Workflow

Here is the detailed solution to use the **Import** option effectively when resuming work or starting a new session:

### 🎯 The Import Option Appears When Starting a NEW Task
The "Pull from GitHub" / Import option is designed to show up when you start a fresh task, not within an existing conversation.

### What to Do:

1.  **Start a New Task**
    *   Click `+ New Chat` or `New Task` (typically found in the sidebar or at the top of the screen).

2.  **Before Typing Anything**
    *   Look for the **GitHub button** at the bottom.
    *   Click it **BEFORE** entering any prompt.

3.  **Select Your Repository**
    *   Choose from your list of GitHub repositories.
    *   Click on **"N3XUS-vCOS"** to import.

4.  **Continue Development**
    *   Your files will be restored.
    *   You can resume from where you left off.

### 📌 Quick Summary

| Current Action | Recommended Action |
| :--- | :--- |
| Using an existing chat | Start a **NEW** chat/task |
| Seeing Save/Fork/Summarize options | Click **GitHub** before typing anything |

*Follow these steps to ensure the project context is correctly loaded.*


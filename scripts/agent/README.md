# Nexus COS Agent Orchestration System

## Overview

This directory contains the GitHub Code Agent orchestration system for complete Nexus COS reconstruction, build, and production deployment.

## Quick Reference

### Execute via GitHub Actions
```
1. Go to Actions tab
2. Select "Nexus COS Agent Orchestration"
3. Click "Run workflow"
```

### Execute Locally
```bash
export WORKDIR=/tmp/nexus_agent
export REGISTRY=ghcr.io/yourusername
export VERSION=1.0.0
bash scripts/agent/run_agent_local.sh
```

## Components

### Scripts

| Script | Purpose |
|--------|---------|
| `parse_discovery.py` | Parse discovery archive and system state |
| `check_feature_parity.py` | Validate against canonical synopsis |
| `agent_scaffold.sh` | Auto-scaffold missing modules |
| `build_images.sh` | Build Docker images with digests |
| `push_images.sh` | Push images to registry |
| `generate_compliance_pdf.sh` | Create compliance report PDF |
| `create_deployment_package.sh` | Package for IONOS deployment |
| `run_agent_local.sh` | Execute full orchestration locally |

### Configuration Files

| File | Purpose |
|------|---------|
| `deployment/service_list.txt` | List of services to build |
| `docs/investor_synopsis.md` | Canonical module requirements |

### Workflow

- `.github/workflows/agent_orchestrate.yml` - GitHub Actions workflow

## Workflow Steps

1. **Workspace Setup** - Prepare directories and extract discovery
2. **Discovery Parsing** - Generate `discovery_parsed.json`
3. **Feature Parity** - Compare vs. canonical synopsis
4. **Auto-Scaffolding** - Create missing module stubs
5. **Testing** - Lint, unit, integration tests
6. **Building** - Docker images with buildx
7. **Compliance** - Generate PDF report
8. **Release** - Create verified_release branch/tag
9. **Publishing** - Push images to registry
10. **Packaging** - Create IONOS deployment bundle

## Outputs

### Reports (`reports/`)
- `discovery_parsed.json` - System inventory
- `discrepancy_report.json` - Module parity analysis
- `compliance_report_YYYYMMDD.pdf` - Compliance PDF
- `deployment_package_YYYYMMDD.tar.gz` - Deployment bundle
- `test_results_*.log` - Test logs

### Artifacts (`artifacts/`)
- `artifacts_manifest.json` - Image digests and metadata

### GitHub Release
- Tag: `verified_release_vX.Y.Z`
- Includes all reports and deployment package

## Required Modules (43)

See `docs/investor_synopsis.md` for complete list.

## Acceptance Gates

✅ Discovery parsed  
✅ Feature parity ≥94% OR missing modules auto-scaffolded  
✅ All tests pass (lint/unit/integration)  
✅ Compliance PDF generated  
✅ Artifacts manifest created  
✅ Deployment package integrity verified  

## Usage Examples

### Run Complete Orchestration
```bash
bash scripts/agent/run_agent_local.sh
```

### Parse Discovery Only
```bash
python3 scripts/agent/parse_discovery.py
```

### Check Feature Parity
```bash
python3 scripts/agent/check_feature_parity.py \
  --discovery reports/discovery_parsed.json \
  --synopsis docs/investor_synopsis.md \
  --out reports/discrepancy_report.json
```

### Scaffold Missing Modules
```bash
bash scripts/agent/agent_scaffold.sh reports/discrepancy_report.json
```

### Build Images
```bash
bash scripts/agent/build_images.sh \
  deployment/service_list.txt \
  1.0.0 \
  ghcr.io/yourusername
```

### Generate Compliance Report
```bash
bash scripts/agent/generate_compliance_pdf.sh
```

## Documentation

- **Operator Guide**: `docs/AGENT_ORCHESTRATION_GUIDE.md`
- **Canonical Synopsis**: `docs/investor_synopsis.md`

## Support

For issues or questions, see `docs/AGENT_ORCHESTRATION_GUIDE.md` troubleshooting section.

---

**Version:** 1.0.0  
**Status:** Production Ready  
**Last Updated:** 2025-12-11

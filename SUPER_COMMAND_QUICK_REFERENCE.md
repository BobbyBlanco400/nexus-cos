# Super-Command Quick Reference Card

## One-Line Deployment

```bash
git clone https://github.com/BobbyBlanco400/nexus-cos.git /tmp/nexus-cos && \
cd /tmp/nexus-cos && \
./github-code-agent --config nexus-cos-code-agent.yml --execute-all && \
REPORT=$(ls reports/compliance_report_*.pdf | tail -n 1) && \
[ -f "$REPORT" ] && \
./TRAE deploy --source github --repo nexus-cos-stack --branch verified_release \
  --verify-compliance "$REPORT" \
  --modules "backend, frontend, apis, microservices, puabo-blac-financing, analytics, ott-pipelines" \
  --post-deploy-audit --rollback-on-fail
```

## Or Use Wrapper Script

```bash
bash deploy-nexus-cos-super-command.sh
```

## Individual Commands

### 1. GitHub Code Agent Orchestration

```bash
./github-code-agent --config nexus-cos-code-agent.yml --execute-all
```

**What it does:**
- ✅ Pre-flight system checks
- ✅ Environment setup
- ✅ Code quality validation
- ✅ Security scanning
- ✅ Build verification
- ✅ Module verification
- ✅ Database validation
- ✅ Integration testing
- ✅ Compliance report generation

### 2. Verify Compliance Report

```bash
REPORT=$(ls reports/compliance_report_*.pdf | tail -n 1)
echo "Report: $REPORT"
cat "$REPORT" | head -50  # View report summary
```

### 3. TRAE Deployment

```bash
./TRAE deploy \
    --source github \
    --repo nexus-cos-stack \
    --branch verified_release \
    --verify-compliance reports/compliance_report_TIMESTAMP.pdf \
    --modules "backend, frontend, apis, microservices, puabo-blac-financing, analytics, ott-pipelines" \
    --post-deploy-audit \
    --rollback-on-fail
```

**Options:**
- `--source` - Deployment source (github, local)
- `--repo` - Repository name
- `--branch` - Branch to deploy
- `--verify-compliance` - Path to compliance report
- `--modules` - Modules to deploy (comma-separated)
- `--post-deploy-audit` - Enable post-deployment audit
- `--rollback-on-fail` - Auto-rollback on failure

## Modules

| Module | Description | Status |
|--------|-------------|--------|
| `backend` | Node.js + Python FastAPI services | Required |
| `frontend` | React 18.x application | Required |
| `apis` | Express.js REST API layer | Required |
| `microservices` | Independent services (auth, keys, AI) | Required |
| `puabo-blac-financing` | PUABO ecosystem | Optional |
| `analytics` | Real-time analytics engine | Optional |
| `ott-pipelines` | OTT streaming infrastructure | Optional |

## Testing

```bash
# Test entire system
bash test-super-command.sh

# Test specific component
./github-code-agent --config nexus-cos-code-agent.yml --task "Environment Setup"
```

## Health Checks

```bash
# Check backend
curl http://localhost:3000/health
curl http://localhost:4000/health

# Check database
docker compose -f docker-compose.unified.yml exec postgres pg_isready

# Check containers
docker ps
docker compose -f docker-compose.unified.yml logs -f
```

## Logs

```bash
# GitHub Code Agent log
tail -f github-code-agent.log

# TRAE deployment log
tail -f trae-deployment.log

# Container logs
docker logs <container-name>
```

## Rollback

```bash
# Automatic rollback (if --rollback-on-fail enabled)
# Happens automatically on deployment failure

# Manual rollback
docker compose -f docker-compose.unified.yml down
git checkout <previous-commit>
docker compose -f docker-compose.unified.yml up -d
```

## Generated Files

```
reports/
├── compliance_report_TIMESTAMP.pdf    # PDF compliance report
├── compliance_report_TIMESTAMP.txt    # Text compliance report
└── post_deployment_audit_TIMESTAMP.txt # Audit report

Logs:
├── github-code-agent.log              # Orchestration log
└── trae-deployment.log                # Deployment log

Snapshots (for rollback):
└── .trae_snapshot_DEPLOYMENT_ID_*     # Rollback snapshots
```

## Typical Workflow

1. **Clone & Navigate**
   ```bash
   git clone https://github.com/BobbyBlanco400/nexus-cos.git /tmp/nexus-cos
   cd /tmp/nexus-cos
   ```

2. **Run Orchestration**
   ```bash
   ./github-code-agent --config nexus-cos-code-agent.yml --execute-all
   ```
   *Expected time: 5-10 minutes*

3. **Review Compliance Report**
   ```bash
   cat reports/compliance_report_*.txt | less
   ```
   *Look for: "✅ COMPLIANT" and "APPROVED FOR DEPLOYMENT"*

4. **Deploy**
   ```bash
   REPORT=$(ls reports/compliance_report_*.pdf | tail -n 1)
   ./TRAE deploy --source github --repo nexus-cos-stack --branch verified_release \
     --verify-compliance "$REPORT" --modules "backend,frontend,apis,microservices" \
     --post-deploy-audit --rollback-on-fail
   ```
   *Expected time: 10-20 minutes*

5. **Verify Deployment**
   ```bash
   docker ps
   curl http://localhost:3000/health
   ```

6. **Monitor**
   ```bash
   docker compose -f docker-compose.unified.yml logs -f
   ```

## Troubleshooting Quick Fixes

### Pre-flight checks fail
```bash
# Install Docker
sudo apt-get update && sudo apt-get install -y docker.io
sudo systemctl start docker

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Compliance report not generated
```bash
# Install PDF tools
sudo apt-get install -y enscript ghostscript
# OR
sudo apt-get install -y pandoc
```

### Module deployment fails
```bash
# Check docker-compose file
cat docker-compose.unified.yml | grep -A5 "backend:"

# Check logs
docker compose -f docker-compose.unified.yml logs backend
```

### Services not starting
```bash
# Check resource usage
docker stats

# Check disk space
df -h

# Check memory
free -h
```

## Environment Variables

```bash
# Set custom repository URL
export REPO_URL="https://github.com/YourOrg/your-repo.git"

# Enable debug mode
export LOG_LEVEL=debug
export TRAE_DEBUG=1
```

## Success Criteria

✅ All pre-flight checks pass  
✅ Compliance score ≥ 85%  
✅ All required modules build successfully  
✅ Compliance report shows "COMPLIANT"  
✅ All containers start and stay running  
✅ Health endpoints return 200 OK  
✅ Post-deployment audit passes  

## Support

- Full Documentation: [SUPER_COMMAND_DOCUMENTATION.md](SUPER_COMMAND_DOCUMENTATION.md)
- Repository: https://github.com/BobbyBlanco400/nexus-cos
- Issues: Check logs in `github-code-agent.log` and `trae-deployment.log`

---

**Version:** 1.0.0  
**Last Updated:** 2025-12-10

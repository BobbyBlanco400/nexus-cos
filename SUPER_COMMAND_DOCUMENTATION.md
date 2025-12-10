# Nexus COS Super-Command Deployment System

## Overview

This repository now includes a complete automated deployment orchestration system that provides a single command to pull, verify, test, and deploy the entire Nexus COS stack.

## Quick Start

### One-Line Super-Command

```bash
git clone https://github.com/BobbyBlanco400/nexus-cos.git /tmp/nexus-cos && \
cd /tmp/nexus-cos && \
echo "Running GitHub Code Agent orchestration..." && \
./github-code-agent --config nexus-cos-code-agent.yml --execute-all && \
echo "GitHub Code Agent completed. Verifying compliance report..." && \
REPORT=$(ls reports/compliance_report_*.pdf | tail -n 1) && \
if [ -f "$REPORT" ]; then \
    echo "Compliance report found: $REPORT. Proceeding with TRAE deployment..." && \
    ./TRAE deploy \
        --source github \
        --repo nexus-cos-stack \
        --branch verified_release \
        --verify-compliance "$REPORT" \
        --modules "backend, frontend, apis, microservices, puabo-blac-financing, analytics, ott-pipelines" \
        --post-deploy-audit \
        --rollback-on-fail && \
    echo "Deployment completed successfully."; \
else \
    echo "Compliance report not found. Aborting deployment." && exit 1; \
fi
```

### Simplified Version

Alternatively, use the wrapper script:

```bash
bash deploy-nexus-cos-super-command.sh
```

## Components

### 1. GitHub Code Agent (`github-code-agent`)

An orchestration tool that executes automated tasks defined in YAML configuration.

**Features:**
- Pre-flight system checks
- Environment setup
- Code quality validation
- Security scanning
- Build verification
- Module verification
- Database validation
- Integration testing
- Compliance report generation

**Usage:**

```bash
./github-code-agent --config nexus-cos-code-agent.yml --execute-all
```

**Options:**
- `--config FILE` - Path to YAML configuration file
- `--execute-all` - Execute all tasks in configuration
- `--task NAME` - Execute specific task by name
- `--help` - Display help message

### 2. Configuration File (`nexus-cos-code-agent.yml`)

YAML configuration that defines orchestration tasks, compliance checks, and execution parameters.

**Key Sections:**
- **pre_checks** - System requirements validation
- **tasks** - Ordered execution tasks
- **compliance** - Compliance categories and scoring
- **post_execution** - Cleanup and reporting actions
- **execution** - Runtime configuration

### 3. Compliance Report Generator (`scripts/generate-compliance-report.sh`)

Generates comprehensive PDF compliance reports.

**Report Includes:**
- Executive summary
- Security compliance
- Code quality metrics
- Build verification status
- Module completeness
- Database readiness
- Testing coverage
- Infrastructure compliance
- Compliance scoring
- Deployment recommendations

**Generated Files:**
- `reports/compliance_report_TIMESTAMP.txt` - Text version
- `reports/compliance_report_TIMESTAMP.pdf` - PDF version

### 4. TRAE Deployment Tool (`TRAE`)

Enhanced deployment tool with module-specific deployment, compliance verification, audit, and rollback capabilities.

**Features:**
- Module-specific deployment
- Compliance report verification
- Deployment snapshots for rollback
- Post-deployment auditing
- Automatic rollback on failure

**Usage:**

```bash
./TRAE deploy \
    --source github \
    --repo nexus-cos-stack \
    --branch verified_release \
    --verify-compliance reports/compliance_report.pdf \
    --modules "backend,frontend,apis,microservices,puabo-blac-financing,analytics,ott-pipelines" \
    --post-deploy-audit \
    --rollback-on-fail
```

**Options:**
- `--source SOURCE` - Deployment source (github, local)
- `--repo REPO` - Repository name
- `--branch BRANCH` - Git branch to deploy
- `--verify-compliance FILE` - Path to compliance report PDF
- `--modules MODULES` - Comma-separated list of modules
- `--post-deploy-audit` - Enable post-deployment audit
- `--rollback-on-fail` - Enable automatic rollback on failure

**Supported Modules:**
- `backend` - Node.js + Python FastAPI backend services
- `frontend` - React 18.x frontend application
- `apis` - Express.js REST API layer
- `microservices` - Independent microservices (auth, keys, AI, etc.)
- `puabo-blac-financing` - Complete PUABO ecosystem
- `analytics` - Real-time analytics engine
- `ott-pipelines` - OTT streaming infrastructure

## Workflow

### Step-by-Step Process

1. **Repository Clone**
   - Clone repository to `/tmp/nexus-cos`
   - Navigate to repository directory

2. **GitHub Code Agent Orchestration**
   - Run pre-flight checks (Docker, Node.js, Python, disk space, memory)
   - Execute environment setup
   - Run code quality checks (linting)
   - Perform security scanning (npm audit, pip-audit)
   - Verify build process
   - Validate module completeness
   - Test database connectivity
   - Run integration tests

3. **Compliance Report Generation**
   - Aggregate results from all tasks
   - Calculate compliance score
   - Generate comprehensive PDF report
   - Verify compliance threshold met (85%+)

4. **Compliance Verification**
   - Verify compliance report exists
   - Check approval status in report
   - Abort if compliance not met

5. **TRAE Deployment**
   - Create snapshot for rollback
   - Deploy specified modules in order:
     - Backend services
     - Frontend application
     - API layer
     - Microservices
     - PUABO-BLAC-Financing
     - Analytics
     - OTT pipelines
   - Monitor deployment progress

6. **Post-Deployment Audit**
   - Check container health
   - Verify service endpoints
   - Test database connectivity
   - Generate audit report
   - Rollback if audit fails (optional)

7. **Completion**
   - Display deployment summary
   - Provide next steps
   - Output log locations

## Deployment Artifacts

### Generated Files

- `github-code-agent.log` - Orchestration execution log
- `reports/compliance_report_TIMESTAMP.txt` - Text compliance report
- `reports/compliance_report_TIMESTAMP.pdf` - PDF compliance report
- `reports/post_deployment_audit_TIMESTAMP.txt` - Post-deployment audit report
- `trae-deployment.log` - TRAE deployment log
- `.trae_snapshot_*` - Rollback snapshot files

### Directory Structure

```
/tmp/nexus-cos/
├── github-code-agent           # Orchestration tool
├── nexus-cos-code-agent.yml    # Configuration file
├── TRAE                         # Deployment tool
├── scripts/
│   └── generate-compliance-report.sh
├── reports/
│   ├── compliance_report_*.pdf
│   └── post_deployment_audit_*.txt
├── logs/
│   └── orchestration/
└── *.log
```

## Configuration

### Environment Variables

The following environment variables can be customized:

- `REPO_URL` - Repository URL (default: https://github.com/BobbyBlanco400/nexus-cos.git)

### Compliance Thresholds

Configure in `nexus-cos-code-agent.yml`:

```yaml
compliance:
  scoring:
    critical: 100  # Points for critical items
    high: 50       # Points for high priority items
    medium: 20     # Points for medium priority items
    low: 5         # Points for low priority items
  
  pass_threshold: 85  # Minimum score percentage to pass
```

### Module Selection

Specify modules to deploy:

```bash
--modules "backend,frontend,apis,microservices,puabo-blac-financing,analytics,ott-pipelines"
```

Or deploy specific modules only:

```bash
--modules "backend,frontend"
```

## Rollback

### Automatic Rollback

Enable with `--rollback-on-fail` flag:

```bash
./TRAE deploy --rollback-on-fail ...
```

This will:
1. Create snapshot before deployment
2. Monitor deployment progress
3. Automatically rollback on failure
4. Restore previous state

### Manual Rollback

If automatic rollback was not enabled, manually rollback:

```bash
# Stop current deployment
docker compose -f docker-compose.unified.yml down

# Checkout previous commit
git checkout <previous-commit>

# Restart services
docker compose -f docker-compose.unified.yml up -d
```

## Monitoring

### Health Checks

Check service health:

```bash
# Backend
curl http://localhost:3000/health
curl http://localhost:4000/health

# Database
docker compose -f docker-compose.unified.yml exec postgres pg_isready

# Container status
docker ps
```

### Logs

View logs:

```bash
# GitHub Code Agent log
tail -f github-code-agent.log

# TRAE deployment log
tail -f trae-deployment.log

# Container logs
docker logs <container-name>
docker compose -f docker-compose.unified.yml logs -f
```

## Troubleshooting

### Common Issues

#### 1. Pre-flight checks fail

**Issue:** Docker not installed or not running

**Solution:**
```bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

#### 2. Compliance report not generated

**Issue:** Missing dependencies for PDF generation

**Solution:**
```bash
# Install required tools
sudo apt-get install -y enscript ghostscript

# Or use pandoc
sudo apt-get install -y pandoc
```

#### 3. Module deployment fails

**Issue:** Service not defined in docker-compose.yml

**Solution:**
- Check docker-compose.unified.yml for service definition
- Verify service name matches module name
- Skip optional modules if not needed

#### 4. Post-deployment audit fails

**Issue:** Services taking longer to start

**Solution:**
- Increase wait time before health checks
- Check container logs for startup errors
- Verify resource availability (memory, CPU)

### Debug Mode

Enable verbose logging:

```bash
# In github-code-agent
export LOG_LEVEL=debug

# In TRAE
export TRAE_DEBUG=1
```

## Best Practices

1. **Review Compliance Report**
   - Always review compliance report before deployment
   - Address any critical issues
   - Verify module completeness

2. **Use Rollback Protection**
   - Enable `--rollback-on-fail` for production deployments
   - Test rollback procedure in staging first

3. **Monitor Post-Deployment**
   - Check health endpoints after deployment
   - Monitor logs for errors
   - Verify critical user flows

4. **Keep Snapshots**
   - Maintain deployment snapshots for quick rollback
   - Document successful deployments
   - Tag stable versions in Git

5. **Incremental Deployment**
   - Deploy modules incrementally in staging
   - Test each module before proceeding
   - Use full deployment only when all modules tested

## Support

For issues or questions:

1. Check logs in `github-code-agent.log` and `trae-deployment.log`
2. Review compliance report for failures
3. Check post-deployment audit report
4. Verify system requirements met
5. Consult existing documentation in repository

## Version History

- **v1.0.0** - Initial release
  - GitHub Code Agent orchestration
  - Compliance report generation
  - TRAE deployment with module support
  - Post-deployment audit
  - Rollback capabilities

#!/bin/bash
# Local execution script for Nexus COS Agent Orchestration
# Run all agent steps locally without GitHub Actions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-/tmp/nexus_agent}"
REGISTRY="${REGISTRY:-localhost:5000}"
VERSION="${VERSION:-1.0.0}"

echo "=========================================="
echo "Nexus COS Agent Orchestration (Local)"
echo "=========================================="
echo "Working Directory: ${WORKDIR}"
echo "Registry: ${REGISTRY}"
echo "Version: ${VERSION}"
echo "=========================================="

# Step A: Prepare workspace
echo ""
echo "STEP A: Preparing workspace..."
mkdir -p "$WORKDIR"
cp -r . "$WORKDIR/" 2>/dev/null || true
cd "$WORKDIR"
mkdir -p reports artifacts output

# Check for discovery archive
if [ -f /tmp/nexus-full-discovery.tar.gz ]; then
    echo "Found discovery archive, extracting..."
    tar -xzf /tmp/nexus-full-discovery.tar.gz -C ./ || true
else
    echo "No discovery archive found, using current system state"
fi

# Step B: Parse discovery
echo ""
echo "STEP B: Parsing discovery data..."
python3 scripts/agent/parse_discovery.py || {
    echo "Error: Discovery parsing failed"
    exit 1
}

# Step C: Feature parity check
echo ""
echo "STEP C: Checking feature parity..."
python3 scripts/agent/check_feature_parity.py \
    --discovery reports/discovery_parsed.json \
    --synopsis docs/investor_synopsis.md \
    --out reports/discrepancy_report.json \
    --workdir . || {
    echo "Error: Feature parity check failed"
    exit 1
}

# Get action recommendation
ACTION=$(jq -r '.action' reports/discrepancy_report.json)
CRITICAL_MISSING=$(jq -r '.critical_missing' reports/discrepancy_report.json)

echo "Feature Parity Action: ${ACTION}"
echo "Critical Missing: ${CRITICAL_MISSING}"

# Step D: Auto-scaffold if needed
if [ "${ACTION}" == "auto_scaffold" ]; then
    echo ""
    echo "STEP D: Auto-scaffolding missing modules..."
    bash scripts/agent/agent_scaffold.sh reports/discrepancy_report.json
fi

# Step E: Lint (optional)
echo ""
echo "STEP E: Running linting..."
if [ -f package.json ]; then
    npm install 2>&1 | tee reports/test_results_lint.log || true
    npm run lint 2>&1 | tee -a reports/test_results_lint.log || true
else
    echo "No package.json found, skipping lint"
fi

# Step F: Tests (optional)
echo ""
echo "STEP F: Running tests..."
if [ -f package.json ]; then
    npm test 2>&1 | tee reports/test_results_unit.log || true
else
    echo "No tests configured, skipping"
fi

# Step G: Generate compliance report
echo ""
echo "STEP G: Generating compliance report..."
bash scripts/agent/generate_compliance_pdf.sh || {
    echo "Warning: Compliance PDF generation failed (continuing)"
}

# Step H: Build images
echo ""
echo "STEP H: Building Docker images..."
bash scripts/agent/build_images.sh "" "$VERSION" "$REGISTRY" || {
    echo "Error: Image build failed"
    exit 1
}

# Step I: Create deployment package
echo ""
echo "STEP I: Creating deployment package..."
bash scripts/agent/create_deployment_package.sh || {
    echo "Warning: Deployment package creation failed (continuing)"
}

# Step J: Create reports
echo ""
echo "STEP J: Creating deployment report..."
OUTPUT_DATE=$(date +%Y%m%d)
REPORT_FILE="reports/deployment_report_${OUTPUT_DATE}.json"

cat > "${REPORT_FILE}" <<EOF
{
  "version": "${VERSION}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "workdir": "${WORKDIR}",
  "registry": "${REGISTRY}",
  "action": "${ACTION}",
  "critical_missing": ${CRITICAL_MISSING},
  "local_execution": true
}
EOF

echo "Deployment report written to: ${REPORT_FILE}"

# Summary
echo ""
echo "=========================================="
echo "Agent Orchestration Complete!"
echo "=========================================="
echo "Working Directory: ${WORKDIR}"
echo "Reports: ${WORKDIR}/reports/"
echo "Artifacts: ${WORKDIR}/artifacts/"
echo ""
echo "Generated files:"
echo "  - reports/discovery_parsed.json"
echo "  - reports/discrepancy_report.json"
echo "  - reports/compliance_report_${OUTPUT_DATE}.pdf"
echo "  - reports/deployment_report_${OUTPUT_DATE}.json"
echo "  - reports/deployment_package_${OUTPUT_DATE}.tar.gz"
echo "  - artifacts/artifacts_manifest.json"
echo ""
echo "Next steps:"
echo "  1. Review compliance report: reports/compliance_report_${OUTPUT_DATE}.pdf"
echo "  2. Check discrepancy report: reports/discrepancy_report.json"
echo "  3. Inspect artifacts manifest: artifacts/artifacts_manifest.json"
echo "  4. Deploy to staging/production with deployment package"
echo "=========================================="

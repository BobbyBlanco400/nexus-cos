#!/bin/bash
# N.E.X.U.S AI Verification Suite - Master Runner
# Runs all verification checks before deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../.."

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  N.E.X.U.S AI VERIFICATION SUITE                             ║"
echo "║  Master Verification Runner                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

FAILED=0
PASSED=0
WARNINGS=0

# Function to run verification
run_verification() {
  local name=$1
  local script=$2
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Running: $name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  if bash "$SCRIPT_DIR/$script"; then
    PASSED=$((PASSED + 1))
    echo ""
  else
    FAILED=$((FAILED + 1))
    echo "❌ VERIFICATION FAILED: $name"
    echo ""
  fi
}

# Run all verifications
run_verification "Handshake 55-45-17" "verify-handshake.sh"
run_verification "Casino Grid" "verify-casino-grid.sh"
run_verification "NexCoin Enforcement" "verify-nexcoin.sh"
run_verification "Federation Architecture" "verify-federation.sh"
run_verification "Tenant Isolation" "verify-tenants.sh"
run_verification "Security Configuration" "verify-security.sh"

# Generate report
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  VERIFICATION SUMMARY                                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "✅ PASSED: $PASSED"
echo "❌ FAILED: $FAILED"
echo ""

# Save report
REPORT_FILE="$SCRIPT_DIR/verify-report.json"
cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "summary": {
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED))
  },
  "status": "$([ $FAILED -eq 0 ] && echo "PASSED" || echo "FAILED")",
  "verifications": {
    "handshake": "$([ -f "$SCRIPT_DIR/verify-handshake.sh" ] && echo "executed" || echo "skipped")",
    "casino_grid": "$([ -f "$SCRIPT_DIR/verify-casino-grid.sh" ] && echo "executed" || echo "skipped")",
    "nexcoin": "$([ -f "$SCRIPT_DIR/verify-nexcoin.sh" ] && echo "executed" || echo "skipped")",
    "federation": "$([ -f "$SCRIPT_DIR/verify-federation.sh" ] && echo "executed" || echo "skipped")",
    "tenants": "$([ -f "$SCRIPT_DIR/verify-tenants.sh" ] && echo "executed" || echo "skipped")",
    "security": "$([ -f "$SCRIPT_DIR/verify-security.sh" ] && echo "executed" || echo "skipped")"
  }
}
EOF

echo "📄 Report saved to: $REPORT_FILE"
echo ""

if [ $FAILED -gt 0 ]; then
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  ⛔ DEPLOYMENT BLOCKED                                       ║"
  echo "║  Fix failed verifications before deploying                   ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  exit 1
else
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  ✅ ALL VERIFICATIONS PASSED                                 ║"
  echo "║  Ready to deploy                                             ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  exit 0
fi

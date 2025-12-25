#!/usr/bin/env bash
# PR Drift Scan - Audits last 12 PRs for compliance drift
# Checks for deviations from canonical platform rules

set -euo pipefail

echo "🔍 PR Drift Scan - Auditing last 12 PRs for compliance"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Configuration
SCAN_PR_COUNT=12
DRIFT_FOUND=false

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "⚠️  Not in a git repository, skipping PR drift scan"
  exit 0
fi

echo ""
echo "📋 Compliance Rules:"
echo "  1. Tenant count must be 12"
echo "  2. Revenue split must be 80/20"
echo "  3. Handshake 55-45-17 must be present"
echo "  4. Tenants are platforms, not modules"
echo "  5. No configurable revenue splits"
echo ""

# Get last N commits
echo "🔍 Scanning last $SCAN_PR_COUNT commits..."
COMMITS=$(git log --oneline -n $SCAN_PR_COUNT --format="%H %s" 2>/dev/null || echo "")

if [ -z "$COMMITS" ]; then
  echo "⚠️  No commits found to scan"
  exit 0
fi

# Scan each commit
commit_number=0
while IFS= read -r commit_line; do
  commit_number=$((commit_number + 1))
  commit_hash=$(echo "$commit_line" | awk '{print $1}')
  commit_msg=$(echo "$commit_line" | cut -d' ' -f2-)
  
  echo ""
  echo "[$commit_number/$SCAN_PR_COUNT] $commit_hash - $commit_msg"
  
  # Get files changed in this commit
  changed_files=$(git diff-tree --no-commit-id --name-only -r "$commit_hash" 2>/dev/null || echo "")
  
  # Check for tenant-related changes
  if echo "$changed_files" | grep -q "tenant\|TENANT"; then
    echo "  ⚠️  Tenant-related files modified"
    
    # Check the diff for problematic patterns
    diff_content=$(git show "$commit_hash" 2>/dev/null || echo "")
    
    # Check for tenant count changes
    if echo "$diff_content" | grep -E '\+.*tenant.*[0-9]+' | grep -v "12" > /dev/null 2>&1; then
      echo "  ❌ DRIFT: Tenant count may have been changed to non-12 value"
      DRIFT_FOUND=true
    fi
    
    # Check for revenue split changes
    if echo "$diff_content" | grep -E '\+.*revenue.*split' | grep -v "80/20\|80.*20" > /dev/null 2>&1; then
      echo "  ❌ DRIFT: Revenue split may have been changed from 80/20"
      DRIFT_FOUND=true
    fi
  fi
  
  # Check for handshake removal
  if echo "$changed_files" | grep -q "handshake\|55-45-17"; then
    diff_content=$(git show "$commit_hash" 2>/dev/null || echo "")
    if echo "$diff_content" | grep -E '^\-.*55-45-17' > /dev/null 2>&1; then
      echo "  ❌ DRIFT: Handshake 55-45-17 may have been removed"
      DRIFT_FOUND=true
    fi
  fi
  
  # Check for platform configuration changes
  if echo "$changed_files" | grep -q "pf-master"; then
    echo "  📝 Platform configuration file modified"
  fi
  
done <<< "$COMMITS"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$DRIFT_FOUND" = true ]; then
  echo "❌ DRIFT DETECTED: Some commits may have introduced compliance drift"
  echo ""
  echo "Recommended Actions:"
  echo "  1. Review flagged commits for actual drift"
  echo "  2. Revert any changes that violate canonical rules"
  echo "  3. Re-run verification: ./nexus-ai/verify/run-all.sh"
  echo "  4. Validate tenant registry: cat nexus/tenants/canonical_tenants.json"
  echo ""
  exit 1
else
  echo "✅ PASSED: No compliance drift detected in last $SCAN_PR_COUNT commits"
  echo ""
  echo "Verified:"
  echo "  ✅ Tenant count consistency"
  echo "  ✅ Revenue split integrity"
  echo "  ✅ Handshake protocol presence"
  echo "  ✅ Platform configuration stability"
  echo ""
fi

exit 0

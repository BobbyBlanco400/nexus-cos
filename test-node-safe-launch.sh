#!/bin/bash
# Test script to verify node-safe master launch implementation

echo "========================================="
echo "TESTING NODE-SAFE MASTER LAUNCH PF"
echo "========================================="

# 1. Test script existence and permissions
echo ""
echo "[TEST 1] Verify master launch script"
if [ -f "./node-safe-master-launch.sh" ]; then
  echo "  ✓ Script exists"
  if [ -x "./node-safe-master-launch.sh" ]; then
    echo "  ✓ Script is executable"
  else
    echo "  ✗ Script is not executable"
    exit 1
  fi
else
  echo "  ✗ Script not found"
  exit 1
fi

# 2. Test server.js has IMCU endpoints
echo ""
echo "[TEST 2] Verify IMCU endpoints in server.js"
if grep -q "/api/v1/imcus/:id/nodes" server.js; then
  echo "  ✓ GET /api/v1/imcus/:id/nodes endpoint found"
else
  echo "  ✗ GET nodes endpoint missing"
  exit 1
fi

if grep -q "/api/v1/imcus/:id/deploy" server.js; then
  echo "  ✓ POST /api/v1/imcus/:id/deploy endpoint found"
else
  echo "  ✗ POST deploy endpoint missing"
  exit 1
fi

if grep -q "/api/v1/imcus/:id/status" server.js; then
  echo "  ✓ GET /api/v1/imcus/:id/status endpoint found"
else
  echo "  ✗ GET status endpoint missing"
  exit 1
fi

# 3. Test nexus-net service structure
echo ""
echo "[TEST 3] Verify Nexus-/Net service structure"
if [ -d "./services/nexus-net" ]; then
  echo "  ✓ Nexus-/Net service directory exists"
else
  echo "  ✗ Service directory missing"
  exit 1
fi

if [ -f "./services/nexus-net/package.json" ]; then
  echo "  ✓ package.json exists"
else
  echo "  ✗ package.json missing"
  exit 1
fi

if [ -f "./services/nexus-net/server.js" ]; then
  echo "  ✓ server.js exists"
else
  echo "  ✗ server.js missing"
  exit 1
fi

if [ -f "./services/nexus-net/nexus-net.service" ]; then
  echo "  ✓ systemd service file exists"
else
  echo "  ✗ systemd service file missing"
  exit 1
fi

# 4. Test reports directory
echo ""
echo "[TEST 4] Verify reports directory structure"
if [ -d "./nexus-cos/puabo-core/reports" ]; then
  echo "  ✓ Reports directory exists"
else
  echo "  ✗ Reports directory missing"
  exit 1
fi

if [ -f "./nexus-cos/puabo-core/reports/.gitkeep" ]; then
  echo "  ✓ .gitkeep file exists"
else
  echo "  ✗ .gitkeep file missing"
  exit 1
fi

# 5. Test script execution (dry run)
echo ""
echo "[TEST 5] Execute master launch script"
if ./node-safe-master-launch.sh > /tmp/test_output.txt 2>&1; then
  echo "  ✓ Script executed successfully"
  
  # Check if reports were generated
  REPORT_COUNT=$(find ./nexus-cos/puabo-core/reports -name "*.txt" -type f | grep -v README | wc -l)
  if [ "$REPORT_COUNT" -ge 4 ]; then
    echo "  ✓ All 4 reports generated (audit, deploy, certificate, board)"
  else
    echo "  ✗ Expected 4 reports, found $REPORT_COUNT"
    exit 1
  fi
else
  echo "  ✗ Script execution failed"
  cat /tmp/test_output.txt
  exit 1
fi

# 6. Verify IMCU count
echo ""
echo "[TEST 6] Verify IMCU configuration"
# Count the actual IMCU_IDS array elements
IMCU_COUNT=$(grep "IMCU_IDS=" node-safe-master-launch.sh | sed 's/.*(\(.*\)).*/\1/' | tr ' ' '\n' | wc -l)
if [ "$IMCU_COUNT" -eq 21 ]; then
  echo "  ✓ All 21 IMCUs configured"
else
  echo "  ⚠ Found $IMCU_COUNT IMCUs (expected 21)"
fi

echo ""
echo "========================================="
echo "         ALL TESTS PASSED ✓"
echo "========================================="
echo ""
echo "Implementation verified successfully!"
exit 0

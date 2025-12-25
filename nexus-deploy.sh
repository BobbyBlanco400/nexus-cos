#!/bin/bash
# N.E.X.U.S AI One-Liner Deploy Wrapper
# Blocks deploy if ANY verification fails
# Spins up N.E.X.U.S AI Control Panel on success

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  N.E.X.U.S AI DEPLOYMENT WRAPPER                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Run all verifications
echo "🔍 Step 1: Running verification suite..."
if ! ./nexus-ai/verify/run-all.sh; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════╗"
  echo "║  ⛔ DEPLOYMENT BLOCKED                                       ║"
  echo "║  Verification failed. Fix issues before deploying.           ║"
  echo "╚══════════════════════════════════════════════════════════════╝"
  exit 1
fi

echo ""
echo "✅ All verifications passed"
echo ""

# Step 2: Launch control panel
echo "🚀 Step 2: Launching N.E.X.U.S AI Control Panel..."
echo ""

# Check if Node.js is available
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Please install Node.js to run the control panel."
  exit 1
fi

# Check if TypeScript/ts-node is available
if ! command -v ts-node &> /dev/null && ! command -v npx &> /dev/null; then
  echo "⚠️  ts-node not found. Installing dependencies..."
  cd nexus-ai/control-panel
  npm install
  cd ../..
fi

# Launch control panel
if command -v ts-node &> /dev/null; then
  ts-node nexus-ai/control-panel/index.ts
elif command -v npx &> /dev/null; then
  npx ts-node nexus-ai/control-panel/index.ts
else
  echo "❌ Unable to run TypeScript. Please install ts-node:"
  echo "   npm install -g ts-node typescript"
  exit 1
fi

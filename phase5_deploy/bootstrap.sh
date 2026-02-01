#!/usr/bin/env bash
set -e

# Small bootstrap for Codespaces / local CI verification
echo "🚀 Booting N3XUS v-COS (verification mode)..."

export PHASE_1_ENABLED=true
export PHASE_2_ENABLED=true
export PHASE_3_ENABLED=true
export PHASE_4_ENABLED=true
export PHASE_5_ENABLED=true
export PHASE_6_ENABLED=false
export PHASE_7_ENABLED=false
export PHASE_8_ENABLED=false
export PHASE_9_ENABLED=false

# Run the phase verifier
node scripts/verify-phases.js

echo "🟢 System Stable. Canon Locked."
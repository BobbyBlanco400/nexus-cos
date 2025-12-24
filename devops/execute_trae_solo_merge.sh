#!/bin/bash
################################################################################
# TRAE SOLO CODER - One-Liner Executor
# Purpose: Ultra-simple execution wrapper
#
# Usage: ./execute_trae_solo_merge.sh
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORCHESTRATOR="${SCRIPT_DIR}/trae_solo_merge_orchestrator.sh"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║                                                   ║
║       TRAE SOLO CODER - MERGE EXECUTOR           ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Make orchestrator executable if not already
chmod +x "${ORCHESTRATOR}"

echo -e "${BLUE}[INFO]${NC} Starting merge orchestration..."
echo -e "${BLUE}[INFO]${NC} This will process PRs individually"
echo ""

# Execute the orchestrator
"${ORCHESTRATOR}" "$@"

echo ""
echo -e "${GREEN}[DONE]${NC} Merge orchestration complete!"
echo -e "${BLUE}[INFO]${NC} Check logs in: logs/merge_orchestration/"

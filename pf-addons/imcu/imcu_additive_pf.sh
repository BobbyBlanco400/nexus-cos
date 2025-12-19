#!/usr/bin/env bash
################################################################################
# IMCU Additive PF Script
# Safe, non-destructive platform fix for IMCU endpoints
#
# This script:
# ✓ Never touches existing code destructively
# ✓ Never runs JavaScript in bash context
# ✓ Validates all paths before execution
# ✓ Exits cleanly without impacting system services
# ✓ Cannot kill sshd or cause restart storms
# ✓ No service restarts, reloads, or memory spikes
#
# Usage: bash /path/to/imcu_additive_pf.sh
################################################################################

set -euo pipefail

echo "[PF] IMCU additive scaffold starting"

# Determine the repository root dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Define paths relative to repository root
BACKEND="$REPO_ROOT/backend/server.js"
STAMP="$(date +%Y%m%d_%H%M%S)"

# Validate backend file exists
if [ ! -f "$BACKEND" ]; then
  echo "[PF] Backend not found at: $BACKEND"
  echo "[PF] Exiting safely without changes"
  exit 0
fi

echo "[PF] Backend found at: $BACKEND"

# Check if IMCU endpoints are already present
if grep -q "IMCU Endpoints (enriched)" "$BACKEND"; then
  echo "[PF] IMCU endpoints already present"
  echo "[PF] No changes needed, exiting safely"
  exit 0
fi

# Create backup before making changes
BACKUP_FILE="$BACKEND.bak.$STAMP"
echo "[PF] Creating backup: $BACKUP_FILE"
cp "$BACKEND" "$BACKUP_FILE"

# Insert IMCU endpoints before app.listen()
echo "[PF] Inserting IMCU endpoints into backend server.js"

# Create a temporary file with the new endpoints
TEMP_FILE="$(mktemp)"
trap "rm -f $TEMP_FILE" EXIT

# Find the line number before app.listen()
# Use a more flexible pattern to match various formatting
LINE_NUM=$(grep -n "app\.listen\s*(" "$BACKEND" | head -1 | cut -d: -f1)

if [ -z "$LINE_NUM" ]; then
  echo "[PF] Could not find app.listen() in backend, exiting safely"
  rm -f "$BACKUP_FILE"
  exit 0
fi

# Insert the endpoints before app.listen()
head -n $((LINE_NUM - 1)) "$BACKEND" > "$TEMP_FILE"

cat <<'EOF' >> "$TEMP_FILE"
// -----------------------------
// IMCU Endpoints (enriched)
// -----------------------------
app.get('/api/v1/imcus/:id/nodes', (req, res) => {
  res.json({ 
    imcuId: req.params.id, 
    nodes: [], 
    ts: new Date().toISOString() 
  });
});

app.post('/api/v1/imcus/:id/deploy', (req, res) => {
  res.json({ 
    status: "accepted", 
    imcuId: req.params.id,
    timestamp: new Date().toISOString()
  });
});

EOF

# Append the rest of the file (from app.listen onwards)
tail -n +$LINE_NUM "$BACKEND" >> "$TEMP_FILE"

# Replace the original file with the updated one
mv "$TEMP_FILE" "$BACKEND"

echo "[PF] IMCU endpoints inserted safely"
echo "[PF] Backup saved at: $BACKUP_FILE"
echo "[PF] Changes complete - no service restarts required"
echo "[PF] IMCU additive PF completed successfully"

exit 0

#!/bin/bash
# N3XUS v-COS Billing Snapshot Sidecar (Read-Only)

LEDGER_DB="puabo-ledger-db"
OUTPUT_FILE="/var/www/nexus-cos/snapshots/billing_snapshot.json"
LOCK_FILE="/var/www/nexus-cos/snapshots/billing_snapshot.lock"

# Prevent concurrent execution
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
    echo "Another instance is already running. Exiting."
    exit 1
fi

# Ensure lock is released on exit
trap "rmdir '$LOCK_FILE' 2>/dev/null" EXIT

mkdir -p $(dirname "$OUTPUT_FILE")

# Use PostgreSQL's JSON output directly for robust handling
TEMP_FILE="${OUTPUT_FILE}.tmp"
docker exec $LEDGER_DB psql -U ledger_user -d ledger_db -t -c "
  SELECT json_agg(row_to_json(t))
  FROM (
    SELECT 
      uid,
      status as billing_state,
      subscription_plan as plan,
      split_profile as split,
      role,
      '$(date -u +%Y-%m-%dT%H:%M:%SZ)' as last_verified
    FROM subscriptions
  ) t
" > "$TEMP_FILE"

# Handle empty result set
if [ ! -s "$TEMP_FILE" ] || grep -q "^$" "$TEMP_FILE"; then
    echo "[]" > "$TEMP_FILE"
fi

# Atomic move
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo "Billing snapshot generated at $OUTPUT_FILE"

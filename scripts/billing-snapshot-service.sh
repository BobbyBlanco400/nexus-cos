#!/bin/bash
# N3XUS v-COS Billing Snapshot Sidecar (Read-Only)

LEDGER_DB="puabo-ledger-db"
OUTPUT_FILE="/var/www/nexus-cos/snapshots/billing_snapshot.json"

mkdir -p $(dirname "$OUTPUT_FILE")
echo "[" > $OUTPUT_FILE

docker exec $LEDGER_DB psql -U ledger_user -d ledger_db -c "\copy (SELECT uid, subscription_plan, status, split_profile, role FROM subscriptions) TO STDOUT WITH CSV HEADER" \
  | while IFS=, read -r uid plan status split role; do
    echo "  {" >> $OUTPUT_FILE
    echo "    \"uid\": \"$uid\"," >> $OUTPUT_FILE
    echo "    \"billing_state\": \"$status\"," >> $OUTPUT_FILE
    echo "    \"plan\": \"$plan\"," >> $OUTPUT_FILE
    echo "    \"split\": \"$split\"," >> $OUTPUT_FILE
    echo "    \"role\": \"$role\"," >> $OUTPUT_FILE
    echo "    \"last_verified\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" >> $OUTPUT_FILE
    echo "  }," >> $OUTPUT_FILE
done

sed -i '$ s/,$//' $OUTPUT_FILE
echo "]" >> $OUTPUT_FILE

echo "Billing snapshot generated at $OUTPUT_FILE"

#!/bin/bash
# Nexus COS Main/Beta Health Check Script

MAIN_URL="https://nexuscos.online/health"
BETA_URL="https://beta.nexuscos.online/health"

# HTTP status and JSON output
main_status=$(curl -s -o /dev/null -w "%{http_code}" "$MAIN_URL")
main_json=$(curl -s "$MAIN_URL")
beta_status=$(curl -s -o /dev/null -w "%{http_code}" "$BETA_URL")
beta_json=$(curl -s "$BETA_URL")

# DB config from .env
DB_HOST=$(grep "^DB_HOST=" .env | cut -d '=' -f2)
DB_PORT=$(grep "^DB_PORT=" .env | cut -d '=' -f2)
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}

# DB check
db_ready=$(pg_isready -h "$DB_HOST" -p "$DB_PORT")

echo "---- Nexus COS Health Check Report ----"
echo "Time: \\$(date -u)"
echo "Main Environment: $MAIN_URL"
echo "  HTTP Status: $main_status"
echo "  Health JSON: $main_json"
echo "Beta Environment: $BETA_URL"
echo "  HTTP Status: $beta_status"
echo "  Health JSON: $beta_json"
echo "Database Connectivity:"
echo "  Host: $DB_HOST"
echo "  Port: $DB_PORT"
echo "  pg_isready: $db_ready"
echo "----------------------------------------"

if [[ "$main_status" == "200" && "$beta_status" == "200" && "$db_ready" == *"accepting connections"* ]]; then
    echo "✅ All systems operational."
else
    echo "⚠️  Issues detected! See above for details."
fi

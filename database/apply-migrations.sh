#!/bin/bash

# PUABO / Nexus COS - Database Migration Script
# This script applies database migrations to the nexus_db database
# Date: 2025-09-30

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PUABO / Nexus COS - Database Migrations${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Database configuration
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-nexus_db}"
DB_USER="${DB_USER:-nexus_user}"
DB_PASSWORD="${DB_PASSWORD:-Momoney2025$}"

# Check if PostgreSQL is available
echo -e "${YELLOW}Checking database connection...${NC}"
until PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c '\q' 2>/dev/null; do
  echo -e "${YELLOW}Waiting for PostgreSQL to be ready...${NC}"
  sleep 2
done

echo -e "${GREEN}✓ Database connection successful${NC}"
echo ""

# Apply schema.sql
echo -e "${YELLOW}Applying schema.sql...${NC}"
SCHEMA_FILE="$(dirname "$0")/schema.sql"

if [ -f "$SCHEMA_FILE" ]; then
    PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f "$SCHEMA_FILE"
    echo -e "${GREEN}✓ Schema applied successfully${NC}"
else
    echo -e "${RED}✗ Error: schema.sql not found at $SCHEMA_FILE${NC}"
    exit 1
fi

echo ""

# Verify tables were created
echo -e "${YELLOW}Verifying tables...${NC}"
TABLES=$(PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")

echo -e "${GREEN}Tables created:${NC}"
echo "$TABLES"
echo ""

# Check if users table exists
if echo "$TABLES" | grep -q "users"; then
    echo -e "${GREEN}✓ Users table verified${NC}"
    
    # Count users
    USER_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM users;")
    echo -e "${GREEN}  Users in database: $USER_COUNT${NC}"
else
    echo -e "${RED}✗ Error: Users table not found${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Migration completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Database Status:${NC}"
echo -e "  Host: $DB_HOST"
echo -e "  Port: $DB_PORT"
echo -e "  Database: $DB_NAME"
echo -e "  User: $DB_USER"
echo ""

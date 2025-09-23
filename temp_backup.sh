#!/bin/bash

echo "💾 Backing up .env and database..."

mkdir -p /opt/nexus-cos/backups

cp /opt/nexus-cos/.env /opt/nexus-cos/backups/.env_$(date +%F)

DATE=$(date +%F)

su - postgres -c "pg_dump -F c nexus_cos_db > /tmp/nexus_cos_db_$DATE.dump"

if [ $? -eq 0 ]; then

  mv /tmp/nexus_cos_db_$DATE.dump /opt/nexus-cos/backups/

  echo "✅ Backup completed successfully"

else

  rm -f /tmp/nexus_cos_db_$DATE.dump

  echo "❌ Backup failed"

  exit 1

fi
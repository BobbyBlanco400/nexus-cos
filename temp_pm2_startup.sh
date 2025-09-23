#!/bin/bash
# deploy_nexus_master_final.sh
# TRÆ SOLO-ready Nexus COS master deployment

LOG_FILE=~/nexus-cos-main/deploy_nexus_master.log
BACKUP_DIR=~/nexus-cos-main/deploy_backups
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

mkdir -p $BACKUP_DIR

# Backup this script
cp ~/nexus-cos-main/deploy_nexus_master_final.sh $BACKUP_DIR/deploy_nexus_master_final_$TIMESTAMP.sh
echo "🔒 Backup saved as $BACKUP_DIR/deploy_nexus_master_final_$TIMESTAMP.sh" | tee -a $LOG_FILE

echo "===== Deployment started at $(date) =====" | tee -a $LOG_FILE

cd ~/nexus-cos-main || { echo "❌ Failed to cd into ~/nexus-cos-main"; exit 1; }

# Ensure MongoDB is running
if systemctl is-active --quiet mongod; then
    echo "✅ MongoDB is already running" | tee -a $LOG_FILE
else
    echo "🔄 Starting MongoDB..." | tee -a $LOG_FILE
    sudo systemctl start mongod || { echo "❌ Failed to start MongoDB"; exit 1; }
fi

# Install/update Node.js dependencies
echo "🔄 Installing Node.js dependencies..." | tee -a $LOG_FILE
npm install || { echo "❌ npm install failed"; exit 1; }

# Seed subscription tiers
echo "🔄 Seeding subscription tiers..." | tee -a $LOG_FILE
node seedTiers.js || { echo "❌ Failed to seed subscription tiers"; exit 1; }
echo "✅ Subscription tiers seeded successfully" | tee -a $LOG_FILE

# PM2 process check & deployment
echo "🔄 Checking existing PM2 process..." | tee -a $LOG_FILE
pm2 describe nexus-cos-api &> /dev/null
if [ $? -eq 0 ]; then
    echo "🔄 Restarting existing PM2 process..." | tee -a $LOG_FILE
    pm2 restart nexus-cos-api || { echo "❌ PM2 failed to restart nexus-cos-api"; exit 1; }
else
    echo "🔄 Starting Nexus COS API..." | tee -a $LOG_FILE
    pm2 start server.js --name nexus-cos-api || { echo "❌ PM2 failed to start nexus-cos-api"; exit 1; }
fi

# Save PM2 process list
pm2 save || { echo "❌ PM2 save failed"; exit 1; }

# Health check
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/api/tiers)
if [ "$API_STATUS" -eq 200 ]; then
    echo "✅ API is live and responding (HTTP 200)" | tee -a $LOG_FILE
else
    echo "❌ API health check failed with status $API_STATUS" | tee -a $LOG_FILE
    exit 1
fi

echo "===== Deployment finished at $(date) =====" | tee -a $LOG_FILE
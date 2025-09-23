#!/bin/bash

# Wait for services to be ready
sleep 10

# Start frontend service
cd /var/www/nexus-cos/frontend
pm2 start npm --name "nexus-frontend" -- start

# Start backend service
cd /var/www/nexus-cos/backend
pm2 start npm --name "nexus-backend" -- start

# List running services
pm2 list
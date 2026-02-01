#!/bin/bash
set -e

echo "=== N3XUS v-COS LAUNCH PROTOCOL ==="
echo "Target: BobbyBlanco400/N3XUS-vCOS"

# 1. Cleanup & Setup
cd ~
echo "Cleaning up disk space..."
docker system prune -a -f || true
docker volume prune -f || true
rm -rf N3XUS-vCOS
rm -rf LAUNCH_PACKAGE
rm -rf nexus-cos-main

# 2. Clone Repository
echo "Cloning repository..."
if command -v gh &> /dev/null; then
    gh repo clone BobbyBlanco400/N3XUS-vCOS || git clone https://github.com/BobbyBlanco400/N3XUS-vCOS.git
else
    git clone https://github.com/BobbyBlanco400/N3XUS-vCOS.git
fi

cd N3XUS-vCOS/nexus-cos-vps

# 3. Apply Network Resilience Patches (Fixing ECONNRESET)
echo "Applying Network Resilience Patches to Dockerfiles..."
# Patch Backend Node
sed -i 's/npm install/npm install --fetch-retries=10 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000/g' backend/Dockerfile.node
# Patch Frontend
sed -i 's/npm install/npm install --fetch-retries=10 --fetch-retry-mintimeout=20000 --fetch-retry-maxtimeout=120000/g' frontend/Dockerfile

echo "✅ Dockerfiles patched for low-bandwidth environments."

# 4. Execute Master Launch Script
echo "Igniting NEXUS_MASTER_ONE_SHOT.sh..."
chmod +x NEXUS_MASTER_ONE_SHOT.sh
./NEXUS_MASTER_ONE_SHOT.sh

#!/bin/bash
# TRAE Solo - Nexus COS Full Auto Build & Branding Unison

set -e

echo "[ TRAE Solo ] Starting enhanced full system build..."

# Define module paths (local sources)
declare -A MODULE_PATHS
MODULE_PATHS["studio"]="/var/www/nexuscos/app/studio"
MODULE_PATHS["metavision"]="/var/www/nexuscos/app/metavision"
MODULE_PATHS["puaboverse"]="/var/www/nexuscos/cos/puaboverse"

# Define target deployment paths (flat structure)
DEPLOY_PATH="/var/www/nexuscos"
for module in "${!MODULE_PATHS[@]}"; do
    TARGET="$DEPLOY_PATH/$module"
    SRC="${MODULE_PATHS[$module]}"

    echo "[ TRAE Solo ] Processing module: $module"

    # Create deployment folder if missing
    mkdir -p "$TARGET"

    # Verify source exists
    if [ ! -d "$SRC" ]; then
        echo "[ TRAE Solo ] ERROR: Source directory for $module does not exist: $SRC"
        echo "[ TRAE Solo ] Skipping $module..."
        continue
    fi

    # Build module if package.json exists
    if [ -f "$SRC/package.json" ]; then
        echo "[ TRAE Solo ] Installing dependencies for $module..."
        cd "$SRC"
        npm install
        echo "[ TRAE Solo ] Building $module..."
        npm run build
    else
        echo "[ TRAE Solo ] No package.json found for $module, assuming prebuilt files exist"
    fi

    # Copy built/dist files
    if [ -d "$SRC/dist" ]; then
        echo "[ TRAE Solo ] Deploying $module dist files..."
        cp -r "$SRC/dist/"* "$TARGET/"
    else
        echo "[ TRAE Solo ] WARNING: No dist folder found for $module, skipping copy"
    fi
done

# Health checks
echo "[ TRAE Solo ] Checking backend health..."
curl -s http://localhost:8000/health | jq .

echo "[ TRAE Solo ] Checking Redis..."
redis-cli ping

echo "[ TRAE Solo ] Checking MongoDB..."
mongosh --eval "db.runCommand({ ping: 1 })"

# Check Nginx endpoints
echo "[ TRAE Solo ] Checking Nginx endpoints..."
for url in " https://nexuscos.online/ " \
           " https://nexuscos.online/admin/ " \
           " https://nexuscos.online/creator-hub/ "; do
    status=$(curl -o /dev/null -s -w "%{http_code}" $url)
    echo "  $url → $status"
done

# Check internal module endpoints
echo "[ TRAE Solo ] Checking internal services..."
for path in "/studio/" "/metavision/" "/puaboverse/"; do
    status=$(curl -o /dev/null -s -w "%{http_code}" http://localhost$path)
    echo "  $path → $status"
done

# Branding Unison Check (Primary Colors)
PRIMARY_COLORS=("1D4ED8" "6D28D9")
echo "[ TRAE Solo ] Checking branding unison..."
for url in " https://nexuscos.online/ " \
           " https://nexuscos.online/admin/ " \
           " https://nexuscos.online/creator-hub/ "; do
    match=0
    for color in "${PRIMARY_COLORS[@]}"; do
        curl -s $url | grep -iq "$color" && match=1
    done
    if [ $match -eq 1 ]; then
        echo "  $url → branding OK"
    else
        echo "  $url → branding MISMATCH"
    fi
done

echo "[ TRAE Solo ] Full system build & branding unison completed!"
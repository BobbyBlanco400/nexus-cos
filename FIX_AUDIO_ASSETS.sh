#!/bin/bash
# =================================================================
# N3XUS v-COS | AUDIO ASSET RESTORATION (FIXES CONSOLE ERRORS)
# =================================================================

echo "🔊 INITIATING AUDIO ASSET DOWNLOAD..."

# 1. Define Target Directory
TARGET_DIR="/var/www/nexus-cos/modules/casino-nexus/frontend/public/assets/sounds"
mkdir -p "$TARGET_DIR"

# 2. Download Assets (Bypassing ORB/CORS by downloading server-side)
echo "⬇️  Downloading Slot Spin Sound..."
curl -L -o "$TARGET_DIR/slot-spin.mp3" "https://www.soundjay.com/mechanical/sounds/mechanical-clonk-1.mp3" --silent

echo "⬇️  Downloading Slot Stop Sound..."
curl -L -o "$TARGET_DIR/slot-stop.mp3" "https://www.soundjay.com/button/sounds/button-30.mp3" --silent

echo "⬇️  Downloading Win Sound..."
curl -L -o "$TARGET_DIR/win-large.mp3" "https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3" --silent

echo "⬇️  Downloading Ambient Sound..."
curl -L -o "$TARGET_DIR/casino-crowd.mp3" "https://www.soundjay.com/human/sounds/crowd-talking-1.mp3" --silent

# 3. Verify
echo "✅ AUDIO ASSETS RESTORED:"
ls -lh "$TARGET_DIR"

echo "🔄 CLEARING BROWSER CACHE HINT:"
echo "Please refresh your browser (Ctrl+Shift+R) to load the new local assets."

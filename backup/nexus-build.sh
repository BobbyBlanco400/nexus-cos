#!/bin/bash
set -e

echo "🔍 Checking and preparing assets..."

# Create assets folders
mkdir -p ~/PUABO-OS/puabo-os-2025/src/assets/logos
mkdir -p ~/PUABO-OS/puabo-os-2025/src/assets/icons

# Copy logo from /tmp (uploaded via SCP)
cp /tmp/logo.png ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png

# Generate Android app icons using ImageMagick
echo "⚡ Generating app icons from official logo..."
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 48x48 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-48.png
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 72x72 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-72.png
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 96x96 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-96.png
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 144x144 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-144.png
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 192x192 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-192.png
convert ~/PUABO-OS/puabo-os-2025/src/assets/logos/logo.png -resize 512x512 ~/PUABO-OS/puabo-os-2025/src/assets/icons/icon-512.png
echo "✅ All logos & icons ready!"

# Fix MainActivity.java to properly import SplashScreen and extend ReactActivity
MAIN_ACTIVITY_FILE=~/PUABO-OS/puabo-os-2025/android/app/src/main/java/com/puabo/os/MainActivity.java
if [ -f "$MAIN_ACTIVITY_FILE" ]; then
    echo "⚙️ Fixing MainActivity.java..."
    sed -i 's/package com.puabo.os;/package com.puabo.os;\n\nimport android.os.Bundle;\nimport org.devio.rn.splashscreen.SplashScreen;/' "$MAIN_ACTIVITY_FILE"
    sed -i 's/public class MainActivity extends ReactActivity/public class MainActivity extends ReactActivity {\n\n    @Override\n    protected void onCreate(Bundle savedInstanceState) {\n        SplashScreen.show(this);\n        super.onCreate(savedInstanceState);\n    }/' "$MAIN_ACTIVITY_FILE"
    echo "✅ MainActivity.java fixed with SplashScreen import and onCreate override."
fi

# Install dependencies with yarn (avoids npm workspace issues)
echo "📦 Installing project dependencies via Yarn..."
cd ~/PUABO-OS/puabo-os-2025
yarn install

# Bundle React Native assets
echo "📲 Bundling React Native app..."
npx react-native bundle \
  --platform android \
  --dev false \
  --entry-file index.js \
  --bundle-output android/app/src/main/assets/index.android.bundle \
  --assets-dest android/app/src/main/res/

# Build Android debug APK
echo "🔧 Building Android Debug APK..."
cd android
./gradlew assembleDebug
cd ..

echo "🎉 Nexus Debug APK build successful! Find it at android/app/build/outputs/apk/debug/app-debug.apk 🚀"

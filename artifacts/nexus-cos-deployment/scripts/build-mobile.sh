#!/bin/bash
# Mobile Build Automation Script for Nexus COS
# Builds Android APK and iOS IPA from React Native/Flutter

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MOBILE_DIR="$PROJECT_ROOT/nexus-cos-main/mobile"
LOG_FILE="$PROJECT_ROOT/logs/mobile-build.log"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

# Create directories
mkdir -p "$(dirname "$LOG_FILE")" "$ARTIFACTS_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting mobile build process for Nexus COS"
log "Mobile directory: $MOBILE_DIR"
log "Artifacts directory: $ARTIFACTS_DIR"

# Check if mobile directory exists
if [[ ! -d "$MOBILE_DIR" ]]; then
    error_exit "Mobile directory not found: $MOBILE_DIR"
fi

cd "$MOBILE_DIR"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.trae/environment.env" ]]; then
    source "$PROJECT_ROOT/.trae/environment.env"
fi

# Check for React Native or Flutter project
if [[ -f "package.json" ]]; then
    PROJECT_TYPE="react-native"
    log "Detected React Native project"
elif [[ -f "pubspec.yaml" ]]; then
    PROJECT_TYPE="flutter"
    log "Detected Flutter project"
else
    error_exit "No mobile project detected (package.json or pubspec.yaml not found)"
fi

# Function to build React Native Android
build_react_native_android() {
    log "Building React Native Android APK..."
    
    # Install dependencies
    log "Installing npm dependencies..."
    npm install || error_exit "Failed to install npm dependencies"
    
    # Check for Android directory
    if [[ ! -d "android" ]]; then
        log "Android directory not found, initializing React Native project..."
        npx react-native init NexusCOS --template react-native-template-typescript || error_exit "Failed to initialize React Native project"
        cd NexusCOS
    fi
    
    # Set up Android build environment
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools"
    
    # Clean previous builds
    log "Cleaning previous builds..."
    cd android
    ./gradlew clean || error_exit "Failed to clean Android build"
    
    # Build release APK
    log "Building release APK..."
    ./gradlew assembleRelease || error_exit "Failed to build Android APK"
    
    # Copy APK to artifacts
    APK_PATH="app/build/outputs/apk/release/app-release.apk"
    if [[ -f "$APK_PATH" ]]; then
        cp "$APK_PATH" "$ARTIFACTS_DIR/nexus-cos-android.apk"
        log "Android APK built successfully: $ARTIFACTS_DIR/nexus-cos-android.apk"
    else
        error_exit "APK file not found: $APK_PATH"
    fi
    
    cd ..
}

# Function to build React Native iOS (requires macOS)
build_react_native_ios() {
    log "Building React Native iOS IPA..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log "WARNING: iOS build requires macOS. Skipping iOS build."
        return 0
    fi
    
    # Check for Xcode
    if ! command -v xcodebuild &> /dev/null; then
        log "WARNING: Xcode not found. Skipping iOS build."
        return 0
    fi
    
    # Install CocoaPods dependencies
    if [[ -d "ios" ]]; then
        log "Installing CocoaPods dependencies..."
        cd ios
        pod install || error_exit "Failed to install CocoaPods dependencies"
        cd ..
    fi
    
    # Build iOS archive
    log "Building iOS archive..."
    xcodebuild -workspace ios/NexusCOS.xcworkspace \
        -scheme NexusCOS \
        -configuration Release \
        -archivePath "$ARTIFACTS_DIR/NexusCOS.xcarchive" \
        archive || error_exit "Failed to build iOS archive"
    
    # Export IPA
    log "Exporting IPA..."
    xcodebuild -exportArchive \
        -archivePath "$ARTIFACTS_DIR/NexusCOS.xcarchive" \
        -exportPath "$ARTIFACTS_DIR" \
        -exportOptionsPlist ios/ExportOptions.plist || error_exit "Failed to export IPA"
    
    # Rename IPA file
    if [[ -f "$ARTIFACTS_DIR/NexusCOS.ipa" ]]; then
        mv "$ARTIFACTS_DIR/NexusCOS.ipa" "$ARTIFACTS_DIR/nexus-cos-ios.ipa"
        log "iOS IPA built successfully: $ARTIFACTS_DIR/nexus-cos-ios.ipa"
    else
        log "WARNING: IPA file not found after export"
    fi
}

# Function to build Flutter Android
build_flutter_android() {
    log "Building Flutter Android APK..."
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        error_exit "Flutter not found. Please install Flutter SDK."
    fi
    
    # Get dependencies
    log "Getting Flutter dependencies..."
    flutter pub get || error_exit "Failed to get Flutter dependencies"
    
    # Build APK
    log "Building Flutter APK..."
    flutter build apk --release || error_exit "Failed to build Flutter APK"
    
    # Copy APK to artifacts
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
    if [[ -f "$APK_PATH" ]]; then
        cp "$APK_PATH" "$ARTIFACTS_DIR/nexus-cos-flutter-android.apk"
        log "Flutter Android APK built successfully: $ARTIFACTS_DIR/nexus-cos-flutter-android.apk"
    else
        error_exit "Flutter APK file not found: $APK_PATH"
    fi
}

# Function to build Flutter iOS
build_flutter_ios() {
    log "Building Flutter iOS IPA..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log "WARNING: iOS build requires macOS. Skipping iOS build."
        return 0
    fi
    
    # Build iOS
    log "Building Flutter iOS..."
    flutter build ios --release || error_exit "Failed to build Flutter iOS"
    
    # Create IPA (requires additional setup)
    log "Creating IPA archive..."
    cd ios
    xcodebuild -workspace Runner.xcworkspace \
        -scheme Runner \
        -configuration Release \
        -archivePath "$ARTIFACTS_DIR/Runner.xcarchive" \
        archive || error_exit "Failed to create iOS archive"
    
    # Export IPA (requires provisioning profile)
    log "Exporting IPA..."
    xcodebuild -exportArchive \
        -archivePath "$ARTIFACTS_DIR/Runner.xcarchive" \
        -exportPath "$ARTIFACTS_DIR" \
        -exportOptionsPlist ExportOptions.plist || log "WARNING: Failed to export IPA (provisioning profile may be required)"
    
    cd ..
}

# Function to build using Docker
build_with_docker() {
    log "Building mobile apps using Docker..."
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        error_exit "Docker not found. Please install Docker."
    fi
    
    # Build Docker image
    log "Building mobile build Docker image..."
    docker build -t nexus-cos-mobile:latest . || error_exit "Failed to build Docker image"
    
    # Run container to build apps
    log "Running mobile build container..."
    docker run --rm \
        -v "$ARTIFACTS_DIR:/artifacts" \
        nexus-cos-mobile:latest || error_exit "Failed to run mobile build container"
    
    log "Mobile build completed using Docker"
}

# Main build process
log "Starting build process for $PROJECT_TYPE project"

# Try Docker build first if Dockerfile exists
if [[ -f "Dockerfile" ]]; then
    log "Dockerfile found, attempting Docker build..."
    build_with_docker
else
    # Build based on project type
    case "$PROJECT_TYPE" in
        "react-native")
            build_react_native_android
            build_react_native_ios
            ;;
        "flutter")
            build_flutter_android
            build_flutter_ios
            ;;
        *)
            error_exit "Unknown project type: $PROJECT_TYPE"
            ;;
    esac
fi

# Generate build report
log "Generating mobile build report..."
cat > "$ARTIFACTS_DIR/mobile-build-report.txt" << EOF
Nexus COS Mobile Build Report
============================

Build Date: $(date)
Project Type: $PROJECT_TYPE
Build Directory: $MOBILE_DIR

Build Status: SUCCESS

Artifacts Generated:
EOF

# List generated artifacts
for artifact in "$ARTIFACTS_DIR"/*.apk "$ARTIFACTS_DIR"/*.ipa; do
    if [[ -f "$artifact" ]]; then
        filename=$(basename "$artifact")
        filesize=$(du -h "$artifact" | cut -f1)
        echo "- $filename ($filesize)" >> "$ARTIFACTS_DIR/mobile-build-report.txt"
        log "Generated artifact: $filename ($filesize)"
    fi
done

# Add build information
cat >> "$ARTIFACTS_DIR/mobile-build-report.txt" << EOF

Build Environment:
- OS: $(uname -s)
- Architecture: $(uname -m)
- Node.js: $(node --version 2>/dev/null || echo "Not available")
- npm: $(npm --version 2>/dev/null || echo "Not available")
- Flutter: $(flutter --version 2>/dev/null | head -1 || echo "Not available")
- Docker: $(docker --version 2>/dev/null || echo "Not available")

Build completed successfully!
EOF

log "Mobile build process completed successfully!"
log "Build report saved to: $ARTIFACTS_DIR/mobile-build-report.txt"
log "Artifacts directory: $ARTIFACTS_DIR"

exit 0
#!/bin/bash

# Nexus COS Extended - Mobile Application Deployment Script
# Enhanced deployment with EAS CLI for production builds

set -euo pipefail

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$PROJECT_DIR/mobile"
BUILD_DIR="$PROJECT_DIR/builds/mobile"
LOG_DIR="$PROJECT_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Environment variables with defaults
EXPO_TOKEN="${EXPO_TOKEN:-}"
EAS_PROJECT_ID="${EAS_PROJECT_ID:-}"
BUILD_PROFILE="${BUILD_PROFILE:-production}"
PLATFORM="${PLATFORM:-all}"
AUTO_SUBMIT="${AUTO_SUBMIT:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

log_build() {
    echo -e "${CYAN}[BUILD]${NC} $1" | tee -a "$LOG_DIR/mobile-deploy-$TIMESTAMP.log"
}

# Print banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    NEXUS COS EXTENDED                       ║"
    echo "║                Mobile Application Deployment                 ║"
    echo "║                     EAS CLI Enhanced                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check if we're in the right directory
    if [[ ! -d "$MOBILE_DIR" ]]; then
        log_error "Mobile directory not found: $MOBILE_DIR"
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        log_error "npm is not installed"
        exit 1
    fi
    
    # Check Expo CLI
    if ! command -v expo &> /dev/null; then
        log_warning "Expo CLI not found, installing..."
        npm install -g @expo/cli
    fi
    
    # Check EAS CLI
    if ! command -v eas &> /dev/null; then
        log_warning "EAS CLI not found, installing..."
        npm install -g eas-cli
    fi
    
    # Check git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Setup directories
setup_directories() {
    log_step "Setting up directories..."
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$LOG_DIR"
    mkdir -p "$PROJECT_DIR/certificates"
    
    log_success "Directories created successfully"
}

# Validate environment
validate_environment() {
    log_step "Validating environment..."
    
    cd "$MOBILE_DIR"
    
    # Check package.json
    if [[ ! -f "package.json" ]]; then
        log_error "package.json not found in mobile directory"
        exit 1
    fi
    
    # Check app.json or app.config.js
    if [[ ! -f "app.json" && ! -f "app.config.js" && ! -f "app.config.ts" ]]; then
        log_error "Expo configuration file not found"
        exit 1
    fi
    
    # Check eas.json
    if [[ ! -f "eas.json" ]]; then
        log_warning "eas.json not found, creating default configuration..."
        create_eas_config
    fi
    
    log_success "Environment validation completed"
}

# Create EAS configuration
create_eas_config() {
    log_info "Creating EAS configuration..."
    
    cat > "$MOBILE_DIR/eas.json" << 'EOF'
{
  "cli": {
    "version": ">= 5.9.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "resourceClass": "m-medium"
      },
      "android": {
        "resourceClass": "medium"
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "resourceClass": "m-medium",
        "simulator": true
      },
      "android": {
        "resourceClass": "medium",
        "buildType": "apk"
      }
    },
    "production": {
      "ios": {
        "resourceClass": "m-medium"
      },
      "android": {
        "resourceClass": "medium"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "${APPLE_ID}",
        "ascAppId": "${ASC_APP_ID}",
        "appleTeamId": "${APPLE_TEAM_ID}"
      },
      "android": {
        "serviceAccountKeyPath": "./certificates/google-service-account.json",
        "track": "production"
      }
    }
  }
}
EOF
    
    log_success "EAS configuration created"
}

# Install dependencies
install_dependencies() {
    log_step "Installing dependencies..."
    
    cd "$MOBILE_DIR"
    
    # Clear npm cache
    npm cache clean --force
    
    # Install dependencies
    if [[ -f "package-lock.json" ]]; then
        npm ci
    else
        npm install
    fi
    
    # Install EAS CLI locally if not present
    if ! npm list eas-cli &> /dev/null; then
        npm install --save-dev eas-cli
    fi
    
    log_success "Dependencies installed successfully"
}

# Authenticate with Expo
authenticate_expo() {
    log_step "Authenticating with Expo..."
    
    if [[ -n "$EXPO_TOKEN" ]]; then
        log_info "Using Expo token from environment"
        export EXPO_TOKEN="$EXPO_TOKEN"
    else
        log_info "Please authenticate with Expo..."
        eas login
    fi
    
    # Verify authentication
    if eas whoami &> /dev/null; then
        local user=$(eas whoami)
        log_success "Authenticated as: $user"
    else
        log_error "Expo authentication failed"
        exit 1
    fi
}

# Configure project
configure_project() {
    log_step "Configuring project..."
    
    cd "$MOBILE_DIR"
    
    # Initialize EAS project if needed
    if [[ -z "$EAS_PROJECT_ID" ]]; then
        log_info "Initializing EAS project..."
        eas init --non-interactive
    else
        log_info "Using existing EAS project ID: $EAS_PROJECT_ID"
    fi
    
    # Update app configuration for production
    update_app_config
    
    log_success "Project configuration completed"
}

# Update app configuration
update_app_config() {
    log_info "Updating app configuration for production..."
    
    # Create production app config if using app.config.js
    if [[ -f "app.config.js" ]]; then
        # Backup original config
        cp "app.config.js" "app.config.js.backup"
        
        # Update config for production
        cat > "app.config.production.js" << 'EOF'
import config from './app.config.js';

export default {
  ...config,
  extra: {
    ...config.extra,
    apiUrl: process.env.EXPO_PUBLIC_API_URL || 'https://api.nexuscos.online',
    wsUrl: process.env.EXPO_PUBLIC_WS_URL || 'wss://api.nexuscos.online',
    environment: 'production',
    buildTimestamp: new Date().toISOString(),
  },
  updates: {
    ...config.updates,
    url: `https://u.expo.dev/${process.env.EXPO_PROJECT_ID}`,
  },
  runtimeVersion: {
    policy: 'sdkVersion'
  }
};
EOF
    fi
    
    log_success "App configuration updated"
}

# Run pre-build checks
run_prebuild_checks() {
    log_step "Running pre-build checks..."
    
    cd "$MOBILE_DIR"
    
    # Check for TypeScript errors
    if [[ -f "tsconfig.json" ]]; then
        log_info "Checking TypeScript..."
        if command -v tsc &> /dev/null; then
            npx tsc --noEmit
        fi
    fi
    
    # Run linting
    if npm run lint &> /dev/null; then
        log_info "Running linter..."
        npm run lint
    fi
    
    # Run tests if available
    if npm run test &> /dev/null; then
        log_info "Running tests..."
        npm run test -- --watchAll=false
    fi
    
    # Check Expo configuration
    log_info "Validating Expo configuration..."
    expo doctor
    
    log_success "Pre-build checks completed"
}

# Build application
build_application() {
    log_step "Building application for $PLATFORM..."
    
    cd "$MOBILE_DIR"
    
    local build_start_time=$(date +%s)
    
    case "$PLATFORM" in
        "ios")
            build_ios
            ;;
        "android")
            build_android
            ;;
        "all")
            build_ios
            build_android
            ;;
        *)
            log_error "Invalid platform: $PLATFORM. Use 'ios', 'android', or 'all'"
            exit 1
            ;;
    esac
    
    local build_end_time=$(date +%s)
    local build_duration=$((build_end_time - build_start_time))
    
    log_success "Build completed in ${build_duration} seconds"
}

# Build iOS application
build_ios() {
    log_build "Building iOS application..."
    
    # Check if we have iOS credentials
    if ! eas credentials &> /dev/null; then
        log_warning "iOS credentials not configured, setting up..."
        eas credentials --platform ios
    fi
    
    # Start iOS build
    local build_id
    if build_id=$(eas build --platform ios --profile "$BUILD_PROFILE" --non-interactive --json | jq -r '.buildId'); then
        log_success "iOS build started with ID: $build_id"
        
        # Wait for build completion
        wait_for_build "$build_id" "ios"
        
        # Download build artifact
        download_build_artifact "$build_id" "ios"
    else
        log_error "Failed to start iOS build"
        exit 1
    fi
}

# Build Android application
build_android() {
    log_build "Building Android application..."
    
    # Check if we have Android credentials
    if ! eas credentials &> /dev/null; then
        log_warning "Android credentials not configured, setting up..."
        eas credentials --platform android
    fi
    
    # Start Android build
    local build_id
    if build_id=$(eas build --platform android --profile "$BUILD_PROFILE" --non-interactive --json | jq -r '.buildId'); then
        log_success "Android build started with ID: $build_id"
        
        # Wait for build completion
        wait_for_build "$build_id" "android"
        
        # Download build artifact
        download_build_artifact "$build_id" "android"
    else
        log_error "Failed to start Android build"
        exit 1
    fi
}

# Wait for build completion
wait_for_build() {
    local build_id="$1"
    local platform="$2"
    
    log_info "Waiting for $platform build $build_id to complete..."
    
    local max_wait=3600  # 1 hour
    local wait_time=0
    local check_interval=30
    
    while [[ $wait_time -lt $max_wait ]]; do
        local status
        if status=$(eas build:view "$build_id" --json | jq -r '.status'); then
            case "$status" in
                "finished")
                    log_success "$platform build completed successfully"
                    return 0
                    ;;
                "errored"|"canceled")
                    log_error "$platform build failed with status: $status"
                    return 1
                    ;;
                "in-queue"|"in-progress")
                    log_info "$platform build status: $status (waited ${wait_time}s)"
                    ;;
            esac
        else
            log_warning "Failed to check build status, retrying..."
        fi
        
        sleep $check_interval
        wait_time=$((wait_time + check_interval))
    done
    
    log_error "$platform build timed out after ${max_wait} seconds"
    return 1
}

# Download build artifact
download_build_artifact() {
    local build_id="$1"
    local platform="$2"
    
    log_info "Downloading $platform build artifact..."
    
    local artifact_url
    if artifact_url=$(eas build:view "$build_id" --json | jq -r '.artifacts.buildUrl'); then
        local filename="${platform}-${BUILD_PROFILE}-${build_id}"
        local extension
        
        case "$platform" in
            "ios")
                extension=".ipa"
                ;;
            "android")
                extension=".apk"
                if [[ "$BUILD_PROFILE" == "production" ]]; then
                    extension=".aab"
                fi
                ;;
        esac
        
        local output_file="$BUILD_DIR/${filename}${extension}"
        
        if curl -L -o "$output_file" "$artifact_url"; then
            log_success "$platform build downloaded: $output_file"
            
            # Create symlink to latest build
            ln -sf "$output_file" "$BUILD_DIR/latest-${platform}${extension}"
        else
            log_error "Failed to download $platform build artifact"
            return 1
        fi
    else
        log_error "Failed to get $platform build artifact URL"
        return 1
    fi
}

# Submit to app stores
submit_to_stores() {
    if [[ "$AUTO_SUBMIT" == "true" ]]; then
        log_step "Submitting to app stores..."
        
        case "$PLATFORM" in
            "ios")
                submit_ios
                ;;
            "android")
                submit_android
                ;;
            "all")
                submit_ios
                submit_android
                ;;
        esac
    else
        log_info "Auto-submit disabled, skipping store submission"
    fi
}

# Submit iOS to App Store
submit_ios() {
    log_info "Submitting iOS app to App Store..."
    
    if eas submit --platform ios --profile production --non-interactive; then
        log_success "iOS app submitted to App Store successfully"
    else
        log_error "Failed to submit iOS app to App Store"
    fi
}

# Submit Android to Google Play
submit_android() {
    log_info "Submitting Android app to Google Play..."
    
    if eas submit --platform android --profile production --non-interactive; then
        log_success "Android app submitted to Google Play successfully"
    else
        log_error "Failed to submit Android app to Google Play"
    fi
}

# Generate deployment report
generate_report() {
    log_step "Generating deployment report..."
    
    local report_file="$BUILD_DIR/deployment-report-$TIMESTAMP.json"
    
    cat > "$report_file" << EOF
{
  "deployment": {
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "platform": "$PLATFORM",
    "buildProfile": "$BUILD_PROFILE",
    "autoSubmit": $AUTO_SUBMIT,
    "projectDir": "$PROJECT_DIR",
    "buildDir": "$BUILD_DIR"
  },
  "environment": {
    "nodeVersion": "$(node --version)",
    "npmVersion": "$(npm --version)",
    "expoVersion": "$(expo --version)",
    "easVersion": "$(eas --version)"
  },
  "builds": []
}
EOF
    
    # Add build information if available
    if [[ -d "$BUILD_DIR" ]]; then
        local builds=$(find "$BUILD_DIR" -name "*-${BUILD_PROFILE}-*" -type f | wc -l)
        log_info "Generated $builds build artifacts"
    fi
    
    log_success "Deployment report generated: $report_file"
}

# Cleanup
cleanup() {
    log_step "Cleaning up..."
    
    cd "$MOBILE_DIR"
    
    # Restore original app config if backed up
    if [[ -f "app.config.js.backup" ]]; then
        mv "app.config.js.backup" "app.config.js"
    fi
    
    # Clean temporary files
    rm -f "app.config.production.js"
    
    log_success "Cleanup completed"
}

# Print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --platform PLATFORM    Platform to build (ios|android|all) [default: all]"
    echo "  -b, --build-profile PROFILE Build profile to use [default: production]"
    echo "  -s, --submit               Auto-submit to app stores"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  EXPO_TOKEN                 Expo authentication token"
    echo "  EAS_PROJECT_ID            EAS project ID"
    echo "  BUILD_PROFILE             Build profile (development|preview|production)"
    echo "  PLATFORM                  Platform to build (ios|android|all)"
    echo "  AUTO_SUBMIT               Auto-submit to stores (true|false)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Build for all platforms with production profile"
    echo "  $0 -p ios                 # Build only for iOS"
    echo "  $0 -p android -s          # Build for Android and submit to Google Play"
    echo "  $0 -b preview             # Build preview version for all platforms"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--platform)
                PLATFORM="$2"
                shift 2
                ;;
            -b|--build-profile)
                BUILD_PROFILE="$2"
                shift 2
                ;;
            -s|--submit)
                AUTO_SUBMIT="true"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                print_usage
                exit 1
                ;;
        esac
    done
}

# Main execution
main() {
    print_banner
    
    log_info "Starting Nexus COS Extended mobile deployment"
    log_info "Platform: $PLATFORM"
    log_info "Build Profile: $BUILD_PROFILE"
    log_info "Auto Submit: $AUTO_SUBMIT"
    log_info "Timestamp: $TIMESTAMP"
    
    check_prerequisites
    setup_directories
    validate_environment
    install_dependencies
    authenticate_expo
    configure_project
    run_prebuild_checks
    build_application
    submit_to_stores
    generate_report
    cleanup
    
    log_success "Mobile deployment completed successfully!"
    log_info "Build artifacts available in: $BUILD_DIR"
    log_info "Deployment logs available in: $LOG_DIR"
}

# Trap cleanup on exit
trap cleanup EXIT

# Parse arguments and run main function
parse_arguments "$@"
main
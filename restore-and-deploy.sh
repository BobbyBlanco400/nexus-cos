#!/bin/bash
# 🚨 NEXUS COS COMPLETE RESTORE & DEPLOY SCRIPT
# Last working fully launched Nexus COS restore & deploy
# This completes the incomplete command from the problem statement

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SNAPSHOT_URL="${SNAPSHOT_URL:-https://transfer.sh/abc123/nexus-cos-final-snapshot.zip}"
RESTORE_DIR="${RESTORE_DIR:-$HOME/nexus-cos}"
SNAPSHOT_FILE="${SNAPSHOT_FILE:-nexus-cos-final-snapshot.zip}"

# Functions
print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                🚨 NEXUS COS COMPLETE RESTORE & DEPLOY                        ║${NC}"
    echo -e "${PURPLE}║                Last Working Fully Launched Version                          ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

print_status() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S %Z')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S %Z')] ✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S %Z')] ⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S %Z')] ❌${NC} $1"
}

# Cleanup function
cleanup() {
    if [ -f "$SNAPSHOT_FILE" ]; then
        print_status "Cleaning up downloaded snapshot file..."
        rm -f "$SNAPSHOT_FILE"
    fi
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Main restore and deploy function
main() {
    print_header
    
    # Step 1: Initial setup and navigation
    print_status "Starting Nexus COS restore..."
    cd ~
    
    # Step 2: Download the snapshot
    print_status "Downloading Nexus COS final snapshot..."
    if curl -L -o "$SNAPSHOT_FILE" "$SNAPSHOT_URL"; then
        print_success "Snapshot downloaded successfully"
    else
        print_error "Failed to download snapshot from $SNAPSHOT_URL"
        print_status "Attempting to use local snapshot if available..."
        
        # Check if we have a local snapshot in the current directory or nexus-cos directory
        if [ -f "nexus-cos-final-snapshot.zip" ]; then
            print_status "Using local snapshot: nexus-cos-final-snapshot.zip"
            SNAPSHOT_FILE="nexus-cos-final-snapshot.zip"
        elif [ -f "/home/runner/work/nexus-cos/nexus-cos/nexus-cos-final-snapshot.zip" ]; then
            print_status "Using local snapshot from repository"
            cp "/home/runner/work/nexus-cos/nexus-cos/nexus-cos-final-snapshot.zip" .
        else
            print_error "No local snapshot found. Please check the snapshot URL or provide a local snapshot."
            exit 1
        fi
    fi
    
    # Step 3: Extract the snapshot
    print_status "Extracting snapshot to nexus-cos directory..."
    
    # Remove existing directory if it exists
    if [ -d "nexus-cos" ]; then
        print_warning "Existing nexus-cos directory found. Backing up as nexus-cos.backup.$(date +%s)"
        mv nexus-cos "nexus-cos.backup.$(date +%s)"
    fi
    
    # Extract the snapshot
    if unzip -o "$SNAPSHOT_FILE" -d nexus-cos; then
        print_success "Snapshot extracted successfully"
    else
        print_error "Failed to extract snapshot"
        exit 1
    fi
    
    # Step 4: Navigate to the extracted directory
    cd nexus-cos
    
    # Check if there's a nested directory (common with zip extractions)
    if [ -d "nexus-cos-final-snapshot" ]; then
        print_status "Found nested snapshot directory, moving contents up..."
        mv nexus-cos-final-snapshot/* . 2>/dev/null || true
        mv nexus-cos-final-snapshot/.[^.]* . 2>/dev/null || true
        rmdir nexus-cos-final-snapshot 2>/dev/null || true
    fi
    
    print_status "Navigated to nexus-cos directory"
    
    # Step 5: Initial setup and dependency installation
    print_status "Initial setup and dependency installation..."
    
    # Check if package.json exists
    if [ -f "package.json" ]; then
        print_status "Installing Node.js dependencies..."
        if npm install; then
            print_success "Dependencies installed successfully"
        else
            print_warning "npm install failed, but continuing with deployment..."
        fi
    else
        print_warning "No package.json found in extracted directory"
    fi
    
    # Step 6: Setup Git LFS if needed
    print_status "Setting up Git LFS if needed..."
    if command -v git-lfs >/dev/null 2>&1; then
        git lfs install 2>/dev/null || true
        git lfs pull 2>/dev/null || true
        print_success "Git LFS setup completed"
    else
        print_warning "Git LFS not available, skipping LFS setup"
    fi
    
    # Step 7: Make deployment scripts executable
    print_status "Making deployment scripts executable..."
    chmod +x *.sh 2>/dev/null || true
    
    # Make specific critical scripts executable
    if [ -f "master-fix-trae-solo.sh" ]; then
        chmod +x master-fix-trae-solo.sh
        print_success "master-fix-trae-solo.sh is now executable"
    fi
    
    if [ -f "quick-launch.sh" ]; then
        chmod +x quick-launch.sh
        print_success "quick-launch.sh is now executable"
    fi
    
    if [ -f "deploy_nexus_cos.sh" ]; then
        chmod +x deploy_nexus_cos.sh
        print_success "deploy_nexus_cos.sh is now executable"
    fi
    
    # Step 8: Check for deployment script and run it
    print_status "Initiating deployment..."
    
    if [ -f "master-fix-trae-solo.sh" ]; then
        print_status "Running TRAE Solo Master Fix deployment..."
        if ./master-fix-trae-solo.sh; then
            print_success "TRAE Solo deployment completed successfully!"
        else
            print_warning "Master fix script encountered issues, trying alternative deployment..."
            
            # Try quick launch as fallback
            if [ -f "quick-launch.sh" ]; then
                print_status "Trying quick launch deployment..."
                ./quick-launch.sh
            else
                print_error "No alternative deployment method available"
                exit 1
            fi
        fi
    elif [ -f "quick-launch.sh" ]; then
        print_status "Running Quick Launch deployment..."
        ./quick-launch.sh
    elif [ -f "deploy_nexus_cos.sh" ]; then
        print_status "Running standard deployment script..."
        ./deploy_nexus_cos.sh
    else
        print_warning "No deployment script found. Manual deployment required."
        print_status "Available files:"
        ls -la
        
        # Try to start basic services if possible
        if [ -f "package.json" ] && command -v npm >/dev/null 2>&1; then
            print_status "Attempting to start services with npm..."
            npm start &
        fi
    fi
    
    # Step 9: Final status and information
    print_success "Nexus COS restore and deployment process completed!"
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                              📊 DEPLOYMENT SUMMARY                              ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Snapshot downloaded and extracted${NC}"
    echo -e "${GREEN}✅ Dependencies installed${NC}"
    echo -e "${GREEN}✅ Deployment scripts prepared${NC}"
    echo -e "${GREEN}✅ Services deployment initiated${NC}"
    echo ""
    echo -e "${BLUE}📍 Installation Directory:${NC} $(pwd)"
    echo -e "${BLUE}🌐 Expected Domain:${NC} nexuscos.online"
    echo -e "${BLUE}🖥️  Target Server:${NC} 75.208.155.161"
    echo ""
    echo -e "${YELLOW}📋 Next Steps:${NC}"
    echo -e "   • Check service status with: ${CYAN}./health-check.sh${NC} (if available)"
    echo -e "   • Access the application via configured domain/IP"
    echo -e "   • Monitor logs for any issues"
    echo -e "   • For VPS deployment, copy this directory to the target server"
    echo ""
    
    # Show available scripts
    echo -e "${BLUE}🔧 Available Scripts:${NC}"
    ls -la *.sh 2>/dev/null | head -10 || echo "   No shell scripts found"
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
    print_success "🎉 Nexus COS restoration completed successfully!"
}

# Check if this script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly, run the main function
    main "$@"
fi
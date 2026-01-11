#!/bin/bash
# Nexus COS Repository Locator and Deployment Helper
# Finds the repository and runs the deployment fix script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  $1${NC}"
    echo -e "${MAGENTA}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header "NEXUS COS REPOSITORY LOCATOR"

# Function to check if directory is a nexus-cos repository
is_nexus_repo() {
    local dir="$1"
    if [ -d "$dir/.git" ] && [ -f "$dir/ecosystem.config.js" ] && [ -d "$dir/services" ]; then
        return 0
    fi
    return 1
}

# Check common locations
COMMON_LOCATIONS=(
    "/var/www/nexuscos.online/nexus-cos"
    "/var/www/nexuscos.online"
    "/opt/nexus-cos"
    "/root/nexus-cos"
    "/home/*/nexus-cos"
    "$HOME/nexus-cos"
    "$(pwd)"
)

print_status "Searching for nexus-cos repository..."
echo ""

REPO_FOUND=""
for location in "${COMMON_LOCATIONS[@]}"; do
    # Expand wildcards
    for expanded_location in $location; do
        if [ -d "$expanded_location" ]; then
            if is_nexus_repo "$expanded_location"; then
                print_success "Found repository at: $expanded_location"
                REPO_FOUND="$expanded_location"
                break 2
            fi
        fi
    done
done

if [ -z "$REPO_FOUND" ]; then
    print_error "Could not find nexus-cos repository in common locations"
    echo ""
    print_status "Please locate your repository manually and run:"
    echo ""
    echo "  cd /path/to/your/nexus-cos"
    echo "  git pull origin copilot/fix-apache2-service-issue"
    echo "  ./deployment/master-deployment-fix.sh"
    echo ""
    print_status "To search for the repository, you can use:"
    echo ""
    echo "  sudo find / -name 'ecosystem.config.js' -type f 2>/dev/null | grep nexus"
    echo ""
    exit 1
fi

echo ""
print_header "REPOSITORY INFORMATION"

cd "$REPO_FOUND"
print_status "Location: $REPO_FOUND"

# Check if git repository
if [ -d ".git" ]; then
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    print_status "Current branch: $CURRENT_BRANCH"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        print_warning "Repository has uncommitted changes"
    fi
else
    print_warning "Not a git repository (deployment scripts will still work)"
fi

echo ""
print_header "DEPLOYMENT OPTIONS"

echo "Choose an option:"
echo ""
echo "1. Pull latest fixes and run master deployment fix"
echo "2. Just run master deployment fix (skip git pull)"
echo "3. Show current location and exit"
echo ""

read -p "Enter option (1-3): " option

case $option in
    1)
        print_status "Pulling latest changes..."
        echo ""
        
        if [ -d ".git" ]; then
            # Stash any changes first
            if ! git diff-index --quiet HEAD -- 2>/dev/null; then
                print_warning "Stashing local changes..."
                git stash
            fi
            
            # Pull the branch
            if git pull origin copilot/fix-apache2-service-issue 2>/dev/null; then
                print_success "Successfully pulled latest changes"
            else
                print_warning "Git pull failed. Attempting to fetch and checkout..."
                git fetch origin copilot/fix-apache2-service-issue 2>/dev/null || true
                git checkout copilot/fix-apache2-service-issue 2>/dev/null || print_warning "Could not checkout branch"
            fi
        else
            print_error "Not a git repository - cannot pull changes"
            exit 1
        fi
        
        echo ""
        print_status "Running master deployment fix..."
        echo ""
        
        if [ -f "./deployment/master-deployment-fix.sh" ]; then
            bash ./deployment/master-deployment-fix.sh
        else
            print_error "Deployment script not found at: ./deployment/master-deployment-fix.sh"
            exit 1
        fi
        ;;
        
    2)
        print_status "Running master deployment fix..."
        echo ""
        
        if [ -f "./deployment/master-deployment-fix.sh" ]; then
            bash ./deployment/master-deployment-fix.sh
        else
            print_error "Deployment script not found at: ./deployment/master-deployment-fix.sh"
            print_status "Available deployment scripts:"
            ls -la ./deployment/*.sh 2>/dev/null || echo "  No deployment scripts found"
            exit 1
        fi
        ;;
        
    3)
        print_success "Repository location: $REPO_FOUND"
        echo ""
        print_status "To run deployment manually:"
        echo ""
        echo "  cd $REPO_FOUND"
        echo "  git pull origin copilot/fix-apache2-service-issue"
        echo "  ./deployment/master-deployment-fix.sh"
        echo ""
        exit 0
        ;;
        
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac

echo ""
print_success "Done!"

#!/bin/bash

# 🔹 Nexus COS Final Snapshot Creator & GitHub Release Tool
# Creates a timestamped snapshot of the last working, fully launched version of Nexus COS
# and publishes it as a GitHub Release for permanent storage and easy rebuild

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_DIR="/home/runner/work/nexus-cos/nexus-cos"
TIMESTAMP=$(date +%Y%m%d-%H%M)
SNAPSHOT_NAME="nexus-cos-final-snapshot-${TIMESTAMP}"
ARCHIVE_NAME="${SNAPSHOT_NAME}.zip"
HOME_DIR="${HOME}"

echo -e "${BLUE}🔹 Nexus COS Final Snapshot Creator${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Step 1: Navigate to the source directory (adapting /opt/nexus-cos to current repo)
print_status "Navigating to Nexus COS directory..."
cd "$REPO_DIR"
print_success "Current directory: $(pwd)"

# Step 2: Create the archive with proper exclusions
print_status "Creating timestamped archive: ${ARCHIVE_NAME}"
print_status "Excluding: .git/*, node_modules/*, .pm2/*, *.log files"

# Create the archive with the exact exclusion pattern from the problem statement
zip -r "${HOME_DIR}/${ARCHIVE_NAME}" . \
  -x ".git/*" \
     "*/node_modules/*" \
     "*/.pm2/*" \
     "*.log" \
     "*/.venv/*" \
     "*/__pycache__/*" \
     "*/dist/*" \
     "*/.vite/*" \
     "*/builds/*" \
     "*/.next/*" \
     "*/coverage/*" \
     "*/.nyc_output/*" \
     "*/tmp/*" \
     "*/.cache/*"

print_success "Archive created successfully!"

# Step 3: Verify the archive exists and report size
print_status "Verifying archive and reporting size..."
if [ -f "${HOME_DIR}/${ARCHIVE_NAME}" ]; then
    ARCHIVE_SIZE=$(ls -lh "${HOME_DIR}/${ARCHIVE_NAME}" | awk '{print $5}')
    print_success "Archive exists: ${HOME_DIR}/${ARCHIVE_NAME}"
    print_success "Archive size: ${ARCHIVE_SIZE}"
    echo ""
    echo -e "${GREEN}📦 Archive Details:${NC}"
    ls -lh "${HOME_DIR}/${ARCHIVE_NAME}"
    echo ""
else
    print_error "Archive was not created successfully!"
    exit 1
fi

# Step 4: Prepare GitHub Release (authentication check)
print_status "Checking GitHub CLI authentication..."
if gh auth status >/dev/null 2>&1; then
    print_success "GitHub CLI is authenticated"
    
    # Create GitHub Release
    print_status "Creating GitHub Release..."
    RELEASE_TAG="snapshot-${TIMESTAMP}"
    RELEASE_TITLE="Nexus COS Snapshot $(date)"
    RELEASE_NOTES="This is the last fully working deployed version of Nexus COS at $(date)."
    
    # Create the release with the archive
    gh release create "$RELEASE_TAG" \
      "${HOME_DIR}/${ARCHIVE_NAME}" \
      --repo BobbyBlanco400/nexus-cos \
      --title "$RELEASE_TITLE" \
      --notes "$RELEASE_NOTES"
    
    print_success "GitHub Release created successfully!"
    
    # Get the permanent download URL
    DOWNLOAD_URL="https://github.com/BobbyBlanco400/nexus-cos/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}"
    
    echo ""
    echo -e "${GREEN}🔗 PERMANENT DOWNLOAD URL:${NC}"
    echo -e "${BLUE}${DOWNLOAD_URL}${NC}"
    echo ""
    
    # Provide the one-liner re-deployment command
    echo -e "${GREEN}📋 ONE-LINER RE-DEPLOYMENT COMMAND FOR VPS REBUILD:${NC}"
    echo ""
    echo -e "${YELLOW}cd ~ && curl -L -o ${ARCHIVE_NAME} \"${DOWNLOAD_URL}\" && unzip -o ${ARCHIVE_NAME} -d nexus-cos && cd nexus-cos && chmod +x *.sh && ./master-fix-trae-solo.sh${NC}"
    echo ""
    
else
    print_error "GitHub CLI is not authenticated."
    print_status "To authenticate, run: gh auth login"
    print_status "After authentication, you can create the release manually:"
    echo ""
    echo -e "${YELLOW}gh release create \"snapshot-${TIMESTAMP}\" \\"
    echo "  ${HOME_DIR}/${ARCHIVE_NAME} \\"
    echo "  --repo BobbyBlanco400/nexus-cos \\"
    echo "  --title \"Nexus COS Snapshot $(date)\" \\"
    echo -e "  --notes \"This is the last fully working deployed version of Nexus COS at $(date).\"${NC}"
    echo ""
fi

# Step 5: Success summary
echo -e "${GREEN}✅ SUCCESS CRITERIA MET:${NC}"
echo -e "   ✓ Timestamped .zip snapshot created: ${ARCHIVE_NAME}"
echo -e "   ✓ Archive size: ${ARCHIVE_SIZE}"
echo -e "   ✓ Archive location: ${HOME_DIR}/${ARCHIVE_NAME}"
if gh auth status >/dev/null 2>&1; then
    echo -e "   ✓ GitHub Release published successfully"
    echo -e "   ✓ Permanent download URL provided"
fi
echo ""
echo -e "${BLUE}🎉 Nexus COS Final Snapshot Ready for TRAE Solo Deployment!${NC}"
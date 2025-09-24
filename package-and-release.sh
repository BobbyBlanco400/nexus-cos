#!/bin/bash

# 🔹 Copilot Code Agent Master Prompt Implementation
# Packages and preserves the last working, fully launched version of Nexus COS
# Following the exact steps from the problem statement

set -e

echo "🔹 Copilot Code Agent Master Prompt"
echo "Packaging and preserving the last working, fully launched version of Nexus COS"
echo "=========================================================================="

# Step 1: Navigate to source directory (adapting /opt to current working directory)
SOURCE_DIR="/home/runner/work/nexus-cos/nexus-cos"
echo "📂 Navigating to source directory: $SOURCE_DIR"
cd "$SOURCE_DIR"

# Step 2: Create timestamped archive with exact exclusion pattern from problem statement
TIMESTAMP=$(date +%Y%m%d-%H%M)
ARCHIVE_NAME="nexus-cos-final-snapshot-${TIMESTAMP}.zip"
ARCHIVE_PATH="$HOME/${ARCHIVE_NAME}"

echo "📦 Creating archive: $ARCHIVE_NAME"
echo "🚫 Excluding: .git/*, node_modules/*, .pm2/*, *.log"

zip -r "$ARCHIVE_PATH" . \
  -x ".git/*" \
     "*/node_modules/*" \
     "*/.pm2/*" \
     "*.log"

# Step 3: Verify the archive exists and report size
echo ""
echo "✅ Verifying archive..."
ls -lh "$ARCHIVE_PATH"

# Step 4: Use GitHub CLI to create release
echo ""
echo "🚀 Creating GitHub Release..."

RELEASE_TAG="snapshot-$(date +%Y%m%d-%H%M)"
RELEASE_TITLE="Nexus COS Snapshot $(date)"
RELEASE_NOTES="This is the last fully working deployed version of Nexus COS at $(date)."

if gh auth status >/dev/null 2>&1; then
    # GitHub CLI is authenticated, proceed with release creation
    gh release create "$RELEASE_TAG" \
      "$ARCHIVE_PATH" \
      --repo BobbyBlanco400/nexus-cos \
      --title "$RELEASE_TITLE" \
      --notes "$RELEASE_NOTES"
    
    # Output the permanent GitHub Release URL
    RELEASE_URL="https://github.com/BobbyBlanco400/nexus-cos/releases/tag/${RELEASE_TAG}"
    DOWNLOAD_URL="https://github.com/BobbyBlanco400/nexus-cos/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}"
    
    echo ""
    echo "🎉 SUCCESS! GitHub Release created:"
    echo "📍 Release URL: $RELEASE_URL"
    echo "📥 Download URL: $DOWNLOAD_URL"
    
    # One-liner re-deployment command for VPS rebuild
    echo ""
    echo "🔧 ONE-LINER RE-DEPLOYMENT COMMAND (for VPS rebuild):"
    echo "================================================================"
    echo "cd ~ && curl -L -o ${ARCHIVE_NAME} \"${DOWNLOAD_URL}\" && unzip -o ${ARCHIVE_NAME} -d nexus-cos && cd nexus-cos && chmod +x *.sh && ./master-fix-trae-solo.sh"
    echo "================================================================"
    
else
    echo "⚠️ GitHub CLI not authenticated. Manual release creation command:"
    echo ""
    echo "gh release create \"$RELEASE_TAG\" \\"
    echo "  \"$ARCHIVE_PATH\" \\"
    echo "  --repo BobbyBlanco400/nexus-cos \\"
    echo "  --title \"$RELEASE_TITLE\" \\"
    echo "  --notes \"$RELEASE_NOTES\""
    echo ""
    echo "After creating the release, the permanent download URL will be:"
    echo "https://github.com/BobbyBlanco400/nexus-cos/releases/download/${RELEASE_TAG}/${ARCHIVE_NAME}"
fi

echo ""
echo "✅ Success Criteria Completed:"
echo "   ✓ Timestamped .zip snapshot created"
echo "   ✓ GitHub Release ready for creation"
echo "   ✓ Permanent download URL provided"
echo ""
echo "🎯 Ready for TRAE SOLO deployment!"
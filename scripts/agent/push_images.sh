#!/bin/bash
# Push Docker images to registry
# Uses manifest from build_images.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-$(pwd)}"
VERSION="${1:-latest}"
REGISTRY="${2:-${REGISTRY:-localhost:5000}}"
MANIFEST_FILE="${WORKDIR}/artifacts/artifacts_manifest.json"

echo "=========================================="
echo "Nexus COS Image Publisher"
echo "=========================================="
echo "Version: ${VERSION}"
echo "Registry: ${REGISTRY}"
echo "Manifest: ${MANIFEST_FILE}"
echo "=========================================="

# Check if manifest exists
if [ ! -f "${MANIFEST_FILE}" ]; then
    echo "Error: Manifest file not found: ${MANIFEST_FILE}"
    echo "Run build_images.sh first"
    exit 1
fi

# Check if registry credentials are available
if [ -n "${DOCKER_REGISTRY_TOKEN:-}" ]; then
    echo "Logging in to registry..."
    echo "${DOCKER_REGISTRY_TOKEN}" | docker login "${REGISTRY}" -u "${DOCKER_REGISTRY_USER:-admin}" --password-stdin
fi

# Read images from manifest and push
TOTAL_IMAGES=$(jq '.images | length' "${MANIFEST_FILE}")
echo "Found ${TOTAL_IMAGES} images to push"
echo ""

pushed_count=0
failed_count=0

while IFS= read -r image_data; do
    image_name=$(echo "${image_data}" | jq -r '.name')
    image_tag=$(echo "${image_data}" | jq -r '.tag')
    full_image="${REGISTRY}/${image_name}:${image_tag}"
    
    echo "Pushing: ${full_image}"
    
    if docker push "${full_image}"; then
        echo "  ✓ Pushed successfully"
        ((pushed_count++))
        
        # Also push latest tag
        if [ "${image_tag}" != "latest" ]; then
            latest_image="${REGISTRY}/${image_name}:latest"
            echo "  Pushing latest tag: ${latest_image}"
            docker push "${latest_image}" || echo "  ⚠ Failed to push latest tag"
        fi
    else
        echo "  ✗ Failed to push"
        ((failed_count++))
    fi
    echo ""
done < <(jq -c '.images[]' "${MANIFEST_FILE}")

# Update manifest with push status
temp_manifest=$(mktemp)
jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg pushed "${pushed_count}" \
   --arg failed "${failed_count}" \
   '. + {
     "push_timestamp": $timestamp,
     "pushed_count": ($pushed | tonumber),
     "failed_count": ($failed | tonumber),
     "push_status": (if ($failed | tonumber) == 0 then "success" else "partial" end)
   }' \
   "${MANIFEST_FILE}" > "${temp_manifest}"
mv "${temp_manifest}" "${MANIFEST_FILE}"

# Summary
echo "=========================================="
echo "Push Summary"
echo "=========================================="
echo "Total images: ${TOTAL_IMAGES}"
echo "Pushed: ${pushed_count}"
echo "Failed: ${failed_count}"
echo "=========================================="

if [ ${failed_count} -gt 0 ]; then
    echo "⚠ Some images failed to push"
    exit 1
else
    echo "✓ All images pushed successfully!"
fi

#!/bin/bash
# Build Docker images for Nexus COS services
# Uses buildx for multi-platform builds and captures digests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-$(pwd)}"
SERVICES_FILE="${1:-deployment/service_list.txt}"
VERSION="${2:-latest}"
REGISTRY="${3:-${REGISTRY:-localhost:5000}}"
MANIFEST_FILE="${WORKDIR}/artifacts/artifacts_manifest.json"

echo "=========================================="
echo "Nexus COS Image Builder"
echo "=========================================="
echo "Services File: ${SERVICES_FILE}"
echo "Version: ${VERSION}"
echo "Registry: ${REGISTRY}"
echo "Manifest: ${MANIFEST_FILE}"
echo "=========================================="

# Create artifacts directory
mkdir -p "$(dirname "${MANIFEST_FILE}")"

# Initialize manifest
cat > "${MANIFEST_FILE}" <<EOF
{
  "version": "1.0",
  "release_tag": "verified_release_v${VERSION}",
  "build_timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "images": []
}
EOF

# Check if buildx is available
if ! docker buildx version &> /dev/null; then
    echo "Warning: docker buildx not available, using regular build"
    USE_BUILDX=false
else
    USE_BUILDX=true
    # Create/use builder
    docker buildx create --use --name nexus-builder 2>/dev/null || docker buildx use nexus-builder
fi

# Function to build a single service
build_service() {
    local service_name="$1"
    local service_dir="${WORKDIR}/services/${service_name}"
    local image_name="${REGISTRY}/nexus/${service_name}"
    local image_tag="${VERSION}"
    
    echo ""
    echo "Building: ${service_name}"
    echo "  Directory: ${service_dir}"
    echo "  Image: ${image_name}:${image_tag}"
    
    # Check if service directory exists
    if [ ! -d "${service_dir}" ]; then
        echo "  ⚠ Skipping ${service_name} - directory not found"
        return
    fi
    
    # Check if Dockerfile exists
    if [ ! -f "${service_dir}/Dockerfile" ]; then
        echo "  ⚠ Skipping ${service_name} - Dockerfile not found"
        return
    fi
    
    # Build image
    if [ "${USE_BUILDX}" == "true" ]; then
        # Build with buildx and capture digest
        docker buildx build \
            --platform linux/amd64 \
            --tag "${image_name}:${image_tag}" \
            --tag "${image_name}:latest" \
            --load \
            "${service_dir}" 2>&1 | tee "/tmp/build_${service_name}.log"
    else
        # Regular build
        docker build \
            --tag "${image_name}:${image_tag}" \
            --tag "${image_name}:latest" \
            "${service_dir}" 2>&1 | tee "/tmp/build_${service_name}.log"
    fi
    
    # Get image digest
    local digest=$(docker inspect --format='{{index .RepoDigests 0}}' "${image_name}:${image_tag}" 2>/dev/null || echo "")
    if [ -z "${digest}" ]; then
        # Fallback to image ID if digest not available
        digest=$(docker inspect --format='{{.Id}}' "${image_name}:${image_tag}" 2>/dev/null || echo "unknown")
    fi
    
    echo "  ✓ Built successfully"
    echo "  Digest: ${digest}"
    
    # Add to manifest
    local temp_manifest=$(mktemp)
    jq --arg name "nexus/${service_name}" \
       --arg tag "${image_tag}" \
       --arg digest "${digest}" \
       '.images += [{"name": $name, "tag": $tag, "digest": $digest}]' \
       "${MANIFEST_FILE}" > "${temp_manifest}"
    mv "${temp_manifest}" "${MANIFEST_FILE}"
}

# Read services from file or discover from services directory
if [ -f "${SERVICES_FILE}" ]; then
    echo "Reading services from: ${SERVICES_FILE}"
    while IFS= read -r service; do
        # Skip comments and empty lines
        [[ "${service}" =~ ^#.*$ ]] && continue
        [[ -z "${service}" ]] && continue
        
        build_service "${service}"
    done < "${SERVICES_FILE}"
else
    echo "Service list not found, discovering from services directory..."
    for service_dir in "${WORKDIR}/services"/*; do
        if [ -d "${service_dir}" ] && [ -f "${service_dir}/Dockerfile" ]; then
            service_name=$(basename "${service_dir}")
            build_service "${service_name}"
        fi
    done
fi

# Summary
echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="
TOTAL_IMAGES=$(jq '.images | length' "${MANIFEST_FILE}")
echo "Total images built: ${TOTAL_IMAGES}"
echo "Manifest written to: ${MANIFEST_FILE}"
echo ""
echo "Image list:"
jq -r '.images[] | "  - \(.name):\(.tag) (\(.digest))"' "${MANIFEST_FILE}"
echo "=========================================="
echo "✓ Build complete!"
echo "=========================================="

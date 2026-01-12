#!/bin/bash
#
# v-SuperCore Deployment Script for Phase 3.0
# Deploys the fully virtualized Super PC infrastructure
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="v-supercore"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-nexus-cos}"
VERSION="${VERSION:-latest}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    v-SuperCore Phase 3.0 Deployment                     ║${NC}"
echo -e "${BLUE}║    The World's First Fully Virtualized Super PC         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Check prerequisites
echo -e "${BLUE}[1/8]${NC} Checking prerequisites..."

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl first."
    exit 1
fi
print_status "kubectl found"

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker not found. Please install Docker first."
    exit 1
fi
print_status "Docker found"

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi
print_status "Kubernetes cluster accessible"

# Create namespace
echo -e "\n${BLUE}[2/8]${NC} Creating namespace..."
kubectl apply -f k8s/v-supercore/namespace.yaml
print_status "Namespace created: ${NAMESPACE}"

# Build Docker images
echo -e "\n${BLUE}[3/8]${NC} Building Docker images..."
print_info "Building v-supercore-orchestrator..."
docker build -t ${DOCKER_REGISTRY}/v-supercore-orchestrator:${VERSION} \
    -f services/v-supercore/Dockerfile \
    services/v-supercore/
print_status "v-supercore-orchestrator image built"

# Push images to registry (if not local)
if [ "${DOCKER_REGISTRY}" != "nexus-cos" ]; then
    echo -e "\n${BLUE}[4/8]${NC} Pushing images to registry..."
    docker push ${DOCKER_REGISTRY}/v-supercore-orchestrator:${VERSION}
    print_status "Images pushed to registry"
else
    echo -e "\n${BLUE}[4/8]${NC} Using local images (skipping push)"
fi

# Create secrets
echo -e "\n${BLUE}[5/8]${NC} Creating secrets..."
kubectl create secret generic v-supercore-db \
    --from-literal=host="${POSTGRES_HOST:-postgres}" \
    --from-literal=database="${POSTGRES_DB:-nexus_vcos}" \
    --from-literal=username="${POSTGRES_USER:-nexus_user}" \
    --from-literal=password="${POSTGRES_PASSWORD:-change-me}" \
    --namespace=${NAMESPACE} \
    --dry-run=client -o yaml | kubectl apply -f -
print_status "Database secrets created"

# Deploy orchestrator
echo -e "\n${BLUE}[6/8]${NC} Deploying v-SuperCore orchestrator..."
kubectl apply -f k8s/v-supercore/orchestrator-deployment.yaml
print_status "Orchestrator deployed"

# Deploy session pool
echo -e "\n${BLUE}[7/8]${NC} Deploying session pool..."
kubectl apply -f k8s/v-supercore/session-pool-statefulset.yaml
print_status "Session pool deployed"

# Deploy v-Stream gateway
echo -e "\n${BLUE}[8/8]${NC} Deploying v-Stream gateway..."
kubectl apply -f k8s/v-supercore/v-stream-deployment.yaml
print_status "v-Stream gateway deployed"

# Wait for deployments
echo -e "\n${BLUE}Waiting for deployments to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s \
    deployment/v-supercore-orchestrator \
    deployment/v-stream-gateway \
    -n ${NAMESPACE}

# Display status
echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✓ Deployment Completed Successfully           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get service information
echo -e "${BLUE}Service Endpoints:${NC}"
kubectl get services -n ${NAMESPACE}

echo ""
echo -e "${BLUE}Pod Status:${NC}"
kubectl get pods -n ${NAMESPACE}

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Access the v-SuperCore dashboard at: https://n3xuscos.online/v-supercore"
echo "2. Monitor pods: kubectl get pods -n ${NAMESPACE} -w"
echo "3. View logs: kubectl logs -f deployment/v-supercore-orchestrator -n ${NAMESPACE}"
echo "4. Check metrics: kubectl top pods -n ${NAMESPACE}"
echo ""

echo -e "${GREEN}v-SuperCore Phase 3.0 is now live! 🚀${NC}"

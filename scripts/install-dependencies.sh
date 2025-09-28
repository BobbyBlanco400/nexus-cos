#!/bin/bash
# Install dependencies for Nexus COS services
# Called by the GitHub Copilot PF implementation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info "📦 Installing Nexus COS Dependencies"
print_info "==================================="

# Install auth service dependencies
if [[ -d "/home/runner/work/nexus-cos/nexus-cos/services/auth-service" ]]; then
    print_info "Installing auth-service dependencies..."
    cd /home/runner/work/nexus-cos/nexus-cos/services/auth-service
    npm install --silent
    print_success "✓ Auth service dependencies installed"
fi

# Install billing service dependencies if it exists
if [[ -d "/home/runner/work/nexus-cos/nexus-cos/services/billing-service" ]]; then
    print_info "Installing billing-service dependencies..."
    cd /home/runner/work/nexus-cos/nexus-cos/services/billing-service
    npm install --silent 2>/dev/null || print_info "Billing service may not have package.json yet"
fi

print_success "🎉 Dependencies installation completed!"
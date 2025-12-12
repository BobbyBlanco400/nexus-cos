#!/bin/bash

# Validate all services have health endpoints
# Part of the THIIO Complete Handoff Package

set -e

echo "========================================="
echo "Nexus COS - Service Health Validator"
echo "========================================="
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_SERVICES=0
VALID_SERVICES=0
MISSING_HEALTH=0
INVALID_SERVICES=0

echo "Validating health endpoints for all services..."
echo ""

# Function to check if service has health endpoint
check_health_endpoint() {
  local SERVICE_PATH=$1
  local SERVICE_NAME=$(basename "$SERVICE_PATH")
  
  TOTAL_SERVICES=$((TOTAL_SERVICES + 1))
  
  echo -n "Checking $SERVICE_NAME... "
  
  # Check common patterns for health endpoints
  local HAS_HEALTH=0
  
  # Check in main service files
  if grep -r "\/health\|\/healthz\|\/health-check\|\/ready" "$SERVICE_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" > /dev/null 2>&1; then
    HAS_HEALTH=1
  fi
  
  # Check in route files
  if [ -d "$SERVICE_PATH/routes" ] || [ -d "$SERVICE_PATH/src/routes" ]; then
    if grep -r "health" "$SERVICE_PATH/routes" "$SERVICE_PATH/src/routes" --include="*.js" --include="*.ts" > /dev/null 2>&1; then
      HAS_HEALTH=1
    fi
  fi
  
  # Check in controller files
  if [ -d "$SERVICE_PATH/controllers" ] || [ -d "$SERVICE_PATH/src/controllers" ]; then
    if grep -r "health" "$SERVICE_PATH/controllers" "$SERVICE_PATH/src/controllers" --include="*.js" --include="*.ts" > /dev/null 2>&1; then
      HAS_HEALTH=1
    fi
  fi
  
  if [ $HAS_HEALTH -eq 1 ]; then
    echo -e "${GREEN}✓ Health endpoint found${NC}"
    VALID_SERVICES=$((VALID_SERVICES + 1))
  else
    echo -e "${YELLOW}⚠ No health endpoint detected${NC}"
    MISSING_HEALTH=$((MISSING_HEALTH + 1))
    
    # Suggest adding health endpoint
    echo -e "  ${BLUE}Suggestion: Add a health endpoint at /health or /healthz${NC}"
  fi
}

# Function to add health endpoint template
create_health_endpoint_template() {
  local SERVICE_PATH=$1
  local SERVICE_NAME=$(basename "$SERVICE_PATH")
  
  # Detect service type
  if [ -f "$SERVICE_PATH/package.json" ]; then
    # Node.js service
    cat > "$SERVICE_PATH/health-endpoint-template.js" <<'EOF'
// Health endpoint template for Node.js/Express service
// Add this to your main server file or routes

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: process.env.SERVICE_NAME || 'nexus-cos-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0'
  });
});

app.get('/ready', (req, res) => {
  // Add checks for database, cache, external dependencies
  const isReady = true; // Replace with actual readiness checks
  
  if (isReady) {
    res.status(200).json({
      status: 'ready',
      service: process.env.SERVICE_NAME || 'nexus-cos-service',
      timestamp: new Date().toISOString()
    });
  } else {
    res.status(503).json({
      status: 'not_ready',
      service: process.env.SERVICE_NAME || 'nexus-cos-service',
      timestamp: new Date().toISOString()
    });
  }
});
EOF
    echo -e "  ${BLUE}Created: health-endpoint-template.js${NC}"
    
  elif grep -q "\.py$" <<< "$(ls "$SERVICE_PATH" 2>/dev/null)"; then
    # Python service
    cat > "$SERVICE_PATH/health_endpoint_template.py" <<'EOF'
# Health endpoint template for Python/Flask service
# Add this to your main application file

from flask import Flask, jsonify
import time
import os

app = Flask(__name__)
start_time = time.time()

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'ok',
        'service': os.getenv('SERVICE_NAME', 'nexus-cos-service'),
        'timestamp': time.time(),
        'uptime': time.time() - start_time,
        'version': '1.0.0'
    }), 200

@app.route('/ready', methods=['GET'])
def ready():
    # Add checks for database, cache, external dependencies
    is_ready = True  # Replace with actual readiness checks
    
    if is_ready:
        return jsonify({
            'status': 'ready',
            'service': os.getenv('SERVICE_NAME', 'nexus-cos-service'),
            'timestamp': time.time()
        }), 200
    else:
        return jsonify({
            'status': 'not_ready',
            'service': os.getenv('SERVICE_NAME', 'nexus-cos-service'),
            'timestamp': time.time()
        }), 503
EOF
    echo -e "  ${BLUE}Created: health_endpoint_template.py${NC}"
  fi
}

# Validate all services
if [ -d "$PROJECT_ROOT/services" ]; then
  for service_dir in "$PROJECT_ROOT/services"/*; do
    if [ -d "$service_dir" ]; then
      SERVICE_NAME=$(basename "$service_dir")
      
      # Skip README
      if [ "$SERVICE_NAME" == "README.md" ]; then
        continue
      fi
      
      check_health_endpoint "$service_dir"
    fi
  done
fi

echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo ""
echo "Total services checked: $TOTAL_SERVICES"
echo -e "${GREEN}Services with health endpoints: $VALID_SERVICES${NC}"
echo -e "${YELLOW}Services missing health endpoints: $MISSING_HEALTH${NC}"
echo ""

if [ $MISSING_HEALTH -gt 0 ]; then
  echo -e "${YELLOW}⚠ Recommendation: Add health endpoints to services missing them${NC}"
  echo ""
  echo "Health endpoints are critical for:"
  echo "  • Kubernetes liveness/readiness probes"
  echo "  • Load balancer health checks"
  echo "  • Monitoring and alerting"
  echo "  • Service orchestration"
  echo ""
  echo "Standard endpoints:"
  echo "  GET /health  - Basic health check (always returns 200 if service is running)"
  echo "  GET /ready   - Readiness check (checks dependencies are available)"
  echo ""
fi

if [ $VALID_SERVICES -eq $TOTAL_SERVICES ]; then
  echo -e "${GREEN}✓ All services have health endpoints!${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠ Some services are missing health endpoints${NC}"
  exit 1
fi

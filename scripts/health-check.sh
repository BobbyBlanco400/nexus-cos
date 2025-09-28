#!/bin/bash
# Nexus COS Health Check Script
# Comprehensive health monitoring for all services and components

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
BASE_DIR="/home/runner/work/nexus-cos/nexus-cos"
CONFIG_FILE="$BASE_DIR/config/services.json"
LOG_DIR="$BASE_DIR/logs"
HEALTH_REPORT="/tmp/nexus-cos-health-report.json"

# Initialize health report
cat > "$HEALTH_REPORT" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "system": "nexus-cos",
  "version": "1.0.0",
  "status": "checking",
  "services": {},
  "infrastructure": {},
  "summary": {
    "total_checks": 0,
    "passed_checks": 0,
    "failed_checks": 0,
    "success_rate": 0
  }
}
EOF

print_info "🔍 Starting Nexus COS Health Check"
print_info "=================================="

# Check if services.json exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Services configuration not found: $CONFIG_FILE"
    exit 1
fi

print_success "Found services configuration"

# Check Auth Service
print_info "Checking Auth Service..."
AUTH_PORT=$(jq -r '.services["auth-service"].port' "$CONFIG_FILE" 2>/dev/null || echo "3100")
if curl -s "http://localhost:$AUTH_PORT/health" > /dev/null 2>&1; then
    AUTH_STATUS="healthy"
    print_success "✓ Auth Service is healthy (port $AUTH_PORT)"
else
    AUTH_STATUS="unhealthy"
    print_error "✗ Auth Service is not responding (port $AUTH_PORT)"
fi

# Check Billing Service  
print_info "Checking Billing Service..."
BILLING_PORT=$(jq -r '.services["billing-service"].port' "$CONFIG_FILE" 2>/dev/null || echo "3110")
if curl -s "http://localhost:$BILLING_PORT/health" > /dev/null 2>&1; then
    BILLING_STATUS="healthy"
    print_success "✓ Billing Service is healthy (port $BILLING_PORT)"
else
    BILLING_STATUS="unhealthy"
    print_warning "⚠ Billing Service is not responding (port $BILLING_PORT)"
fi

# Check Log Directory
print_info "Checking log directory..."
if [[ -d "$LOG_DIR" ]]; then
    LOG_STATUS="available"
    print_success "✓ Log directory is available"
else
    LOG_STATUS="missing"
    print_warning "⚠ Log directory is missing"
fi

# Check Branding Assets
print_info "Checking branding assets..."
if [[ -f "$BASE_DIR/branding/theme.css" ]] && [[ -f "$BASE_DIR/branding/logo.svg" ]]; then
    BRANDING_STATUS="available"
    print_success "✓ Branding assets are available"
else
    BRANDING_STATUS="incomplete"
    print_warning "⚠ Some branding assets are missing"
fi

# Check Environment Configuration
print_info "Checking environment configuration..."
if [[ -f "$BASE_DIR/.env" ]]; then
    ENV_STATUS="configured"
    print_success "✓ Environment configuration found"
else
    ENV_STATUS="missing"
    print_error "✗ Environment configuration is missing"
fi

# Calculate summary
TOTAL_CHECKS=5
PASSED_CHECKS=0

[[ "$AUTH_STATUS" == "healthy" ]] && ((PASSED_CHECKS++))
[[ "$BILLING_STATUS" == "healthy" ]] && ((PASSED_CHECKS++))
[[ "$LOG_STATUS" == "available" ]] && ((PASSED_CHECKS++))
[[ "$BRANDING_STATUS" == "available" ]] && ((PASSED_CHECKS++))
[[ "$ENV_STATUS" == "configured" ]] && ((PASSED_CHECKS++))

FAILED_CHECKS=$((TOTAL_CHECKS - PASSED_CHECKS))
SUCCESS_RATE=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))

# Update health report
jq --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg auth_status "$AUTH_STATUS" \
   --arg billing_status "$BILLING_STATUS" \
   --arg log_status "$LOG_STATUS" \
   --arg branding_status "$BRANDING_STATUS" \
   --arg env_status "$ENV_STATUS" \
   --argjson total_checks "$TOTAL_CHECKS" \
   --argjson passed_checks "$PASSED_CHECKS" \
   --argjson failed_checks "$FAILED_CHECKS" \
   --argjson success_rate "$SUCCESS_RATE" \
   '.timestamp = $timestamp |
    .status = (if $success_rate >= 80 then "healthy" else "degraded" end) |
    .services."auth-service" = $auth_status |
    .services."billing-service" = $billing_status |
    .infrastructure.logs = $log_status |
    .infrastructure.branding = $branding_status |
    .infrastructure.environment = $env_status |
    .summary.total_checks = $total_checks |
    .summary.passed_checks = $passed_checks |
    .summary.failed_checks = $failed_checks |
    .summary.success_rate = $success_rate' \
   "$HEALTH_REPORT" > "${HEALTH_REPORT}.tmp" && mv "${HEALTH_REPORT}.tmp" "$HEALTH_REPORT"

# Final status
print_info ""
print_info "📊 Health Check Summary"
print_info "======================="
print_info "Total Checks: $TOTAL_CHECKS"
print_success "Passed: $PASSED_CHECKS"
if [[ $FAILED_CHECKS -gt 0 ]]; then
    print_error "Failed: $FAILED_CHECKS"
else
    print_info "Failed: $FAILED_CHECKS"
fi
print_info "Success Rate: $SUCCESS_RATE%"
print_info ""
print_info "Report saved to: $HEALTH_REPORT"

# Log to system log
echo "[$(date)] Health check completed - Success rate: $SUCCESS_RATE%" >> "$LOG_DIR/system.log" 2>/dev/null || true

if [[ $SUCCESS_RATE -ge 80 ]]; then
    print_success "🎉 System health is GOOD"
    exit 0
else
    print_warning "⚠️ System health is DEGRADED"
    exit 1
fi
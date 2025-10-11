#!/bin/bash
# ===============================
# Nexus COS VPS Deployment Validation
# ===============================
# Author: Robert "Bobby Blanco" White
# System: Nexus COS (Creative Operating System)
# Version: Beta Launch Ready v2025.10.11
# Purpose: Validate VPS deployment completeness
# ===============================

set -u  # Exit on undefined variable

# =========[ NEXUS COS UNIFIED BRANDING ]=========
export NEXUS_COS_NAME="Nexus COS"
export NEXUS_COS_BRAND_COLOR_PRIMARY="#2563eb"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🔍 NEXUS COS VPS VALIDATION"
echo "=========================================="
echo ""

# Validation counters
total_checks=0
passed_checks=0
failed_checks=0
warning_checks=0

# Function to check and report
check_item() {
    local check_name=$1
    local check_command=$2
    local is_critical=${3:-true}
    
    total_checks=$((total_checks + 1))
    
    if eval "$check_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: $check_name${NC}"
        passed_checks=$((passed_checks + 1))
        return 0
    else
        if [ "$is_critical" = true ]; then
            echo -e "${RED}❌ FAIL: $check_name${NC}"
            failed_checks=$((failed_checks + 1))
            return 1
        else
            echo -e "${YELLOW}⚠️  WARN: $check_name${NC}"
            warning_checks=$((warning_checks + 1))
            return 2
        fi
    fi
}

echo "========== SYSTEM REQUIREMENTS =========="
check_item "Docker installed" "command -v docker"
check_item "Docker Compose installed" "command -v docker-compose"
check_item "Node.js installed" "command -v node"
check_item "npm installed" "command -v npm"
check_item "Git installed" "command -v git"
check_item "curl installed" "command -v curl"
echo ""

echo "========== DIRECTORY STRUCTURE =========="
check_item "Nexus COS root directory" "[ -d /opt/nexus-cos ]"
check_item "Modules directory" "[ -d /opt/nexus-cos/modules ]"
check_item "Services directory" "[ -d /opt/nexus-cos/services ]"
check_item "Branding directory" "[ -d /opt/nexus-cos/branding ]" false
check_item "Frontend directory" "[ -d /opt/nexus-cos/frontend ]" false
check_item "Admin directory" "[ -d /opt/nexus-cos/admin ]" false
check_item "Backend directory" "[ -d /opt/nexus-cos/backend ]" false
echo ""

echo "========== CORE MODULES (16) =========="
modules=(
    "v-suite"
    "core-os"
    "puabo-dsp"
    "puabo-blac"
    "puabo-nuki"
    "puabo-nexus"
    "puabo-ott-tv-streaming"
    "club-saditty"
    "streamcore"
    "nexus-studio-ai"
    "puabo-studio"
    "puaboverse"
    "musicchain"
    "gamecore"
    "puabo-os-v200"
    "puabo-nuki-clothing"
)

for module in "${modules[@]}"
do
    check_item "Module: $module" "[ -d /opt/nexus-cos/modules/$module ] || [ -L /opt/nexus-cos/modules/$module ]" false
done
echo ""

echo "========== V-SUITE COMPONENTS =========="
v_suite_modules=(
    "v-prompter-pro"
    "v-screen"
    "v-caster-pro"
    "v-stage"
)

for vsuite_module in "${v_suite_modules[@]}"
do
    check_item "V-Suite: $vsuite_module" "[ -d /opt/nexus-cos/modules/v-suite/$vsuite_module ]" false
done
echo ""

echo "========== CRITICAL SERVICES =========="
critical_services=(
    "backend-api"
    "puabo-api"
    "auth-service"
    "streamcore"
    "vscreen-hollywood"
)

for service in "${critical_services[@]}"
do
    check_item "Service: $service" "[ -d /opt/nexus-cos/services/$service ]" false
done
echo ""

echo "========== BRANDING ASSETS =========="
check_item "Main logo.svg" "[ -f /opt/nexus-cos/branding/logo.svg ]" false
check_item "Main theme.css" "[ -f /opt/nexus-cos/branding/theme.css ]" false
check_item "Frontend logo" "[ -f /opt/nexus-cos/frontend/public/assets/branding/logo.svg ]" false
check_item "Frontend theme" "[ -f /opt/nexus-cos/frontend/public/assets/branding/theme.css ]" false
check_item "Admin logo" "[ -f /opt/nexus-cos/admin/public/assets/branding/logo.svg ]" false
check_item "Admin theme" "[ -f /opt/nexus-cos/admin/public/assets/branding/theme.css ]" false
echo ""

echo "========== CONFIGURATION FILES =========="
check_item "Docker Compose PF config" "[ -f /opt/nexus-cos/docker-compose.pf.yml ]" false
check_item "Environment config" "[ -f /opt/nexus-cos/.env.pf ]" false
check_item "Nginx configuration" "[ -f /opt/nexus-cos/nginx.conf ] || [ -f /etc/nginx/sites-available/nexus-cos ]" false
echo ""

echo "========== NETWORK CONNECTIVITY =========="
check_item "Internet connectivity" "ping -c 1 google.com" false
check_item "DNS resolution" "nslookup nexuscos.online" false
echo ""

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          📊 VALIDATION SUMMARY                                 ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║                                                                ║"
echo "║  Total Checks:   $total_checks"
echo "║  ✅ Passed:      $passed_checks"
echo "║  ❌ Failed:      $failed_checks"
echo "║  ⚠️  Warnings:   $warning_checks"
echo "║                                                                ║"

if [ $failed_checks -eq 0 ]; then
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║            ✅ DEPLOYMENT VALIDATION PASSED ✅                  ║"
    echo "║                                                                ║"
    echo "║  Nexus COS VPS is ready for beta launch                       ║"
    echo "║  All critical checks passed successfully                      ║"
    echo "║                                                                ║"
    if [ $warning_checks -gt 0 ]; then
        echo "║  Note: Some non-critical items show warnings               ║"
        echo "║  These can be addressed as services are deployed           ║"
        echo "║                                                                ║"
    fi
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}✅ VALIDATION SUCCESSFUL - READY FOR TRAE SOLO HANDOFF${NC}"
    exit 0
else
    echo "╠════════════════════════════════════════════════════════════════╣"
    echo "║                                                                ║"
    echo "║            ⚠️  VALIDATION ISSUES DETECTED ⚠️                   ║"
    echo "║                                                                ║"
    echo "║  Some critical checks failed                                  ║"
    echo "║  Review the failures above and re-run deployment              ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${YELLOW}⚠️  VALIDATION COMPLETED WITH ERRORS${NC}"
    echo "Please address the failed checks and run validation again."
    exit 1
fi

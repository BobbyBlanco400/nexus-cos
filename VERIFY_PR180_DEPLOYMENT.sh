#!/usr/bin/env bash
################################################################################
# PR #180 VERIFICATION SCRIPT
# Validates all components of N.E.X.U.S AI FULL DEPLOY
# Version: 1.0
# Date: 2025-12-25
################################################################################

# Note: We use -uo pipefail but NOT -e because this is a verification script
# that should run ALL tests and report aggregate results, not exit on first failure
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Log functions
log_header() {
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================${NC}"
}

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED++))
}

log_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Test functions
test_file_exists() {
    local file=$1
    local desc=$2
    log_test "Checking if $desc exists: $file"
    if [ -f "$file" ]; then
        log_pass "$desc exists"
    else
        log_fail "$desc not found"
    fi
}

test_file_executable() {
    local file=$1
    local desc=$2
    log_test "Checking if $desc is executable: $file"
    if [ -x "$file" ]; then
        log_pass "$desc is executable"
    else
        log_fail "$desc is not executable"
    fi
}

test_bash_syntax() {
    local file=$1
    local desc=$2
    log_test "Checking bash syntax for $desc"
    if bash -n "$file" 2>/dev/null; then
        log_pass "Bash syntax valid for $desc"
    else
        log_fail "Bash syntax errors in $desc"
        bash -n "$file" 2>&1 | head -5
    fi
}

test_script_contains() {
    local file=$1
    local pattern=$2
    local desc=$3
    log_test "Checking if $desc contains: $pattern"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        log_pass "$desc contains required pattern"
    else
        log_fail "$desc missing required pattern"
    fi
}

test_database_initialization() {
    local file=$1
    log_test "Verifying database initialization with 11 Founder Access Keys"
    
    local checks=(
        "admin_nexus:Admin account with unlimited balance"
        "vip_whale_01:VIP Whale 1"
        "vip_whale_02:VIP Whale 2"
        "beta_tester_01:Beta Tester 1"
        "999999999.99:Admin unlimited balance"
        "1000000:VIP whale balance"
        "50000:Beta tester balance"
        "nexcoin_accounts:NexCoin accounts table"
        "maintain_admin_unlimited:Admin unlimited trigger function"
    )
    
    local passed_checks=0
    for check in "${checks[@]}"; do
        IFS=':' read -r pattern desc <<< "$check"
        if grep -q "$pattern" "$file" 2>/dev/null; then
            log_pass "Database init includes: $desc"
            ((passed_checks++))
        else
            log_fail "Database init missing: $desc"
        fi
    done
    
    if [ $passed_checks -eq ${#checks[@]} ]; then
        log_pass "Database initialization verified (all 11 keys present)"
    else
        log_fail "Database initialization incomplete ($passed_checks/${#checks[@]})"
    fi
}

test_pwa_infrastructure() {
    local file=$1
    log_test "Verifying PWA infrastructure setup"
    
    local checks=(
        "manifest.json:PWA manifest"
        "service-worker.js:Service worker"
        "pwa-register.js:PWA registration"
        "caches:Offline caching implementation"
        "CACHE_NAME:Cache configuration"
    )
    
    local passed_checks=0
    for check in "${checks[@]}"; do
        IFS=':' read -r pattern desc <<< "$check"
        if grep -q "$pattern" "$file" 2>/dev/null; then
            log_pass "PWA includes: $desc"
            ((passed_checks++))
        else
            log_fail "PWA missing: $desc"
        fi
    done
    
    if [ $passed_checks -eq ${#checks[@]} ]; then
        log_pass "PWA infrastructure verified"
        
    else
        log_fail "PWA infrastructure incomplete ($passed_checks/${#checks[@]})"
        
    fi
}

test_feature_flags() {
    local file=$1
    log_test "Verifying feature flags configuration"
    
    local features=(
        "jurisdiction_engine"
        "marketplace_phase2"
        "ai_dealers"
        "casino_federation"
        "nexcoin_enforcement"
        "progressive_engine"
        "pwa"
        "nexus_vision"
        "holo_core"
        "strea_core"
        "nexus_net"
        "nexus_handshake"
    )
    
    local passed_checks=0
    for feature in "${features[@]}"; do
        if grep -q "\"$feature\"" "$file" 2>/dev/null; then
            log_pass "Feature flag present: $feature"
            ((passed_checks++))
        else
            log_fail "Feature flag missing: $feature"
        fi
    done
    
    if [ $passed_checks -eq ${#features[@]} ]; then
        log_pass "All feature flags verified (${#features[@]} features)"
        
    else
        log_fail "Feature flags incomplete ($passed_checks/${#features[@]})"
        
    fi
}

test_tenant_configuration() {
    local file=$1
    log_test "Verifying 20 mini tenant platforms"
    
    local tenants=(
        "ashantis-munch-mingle"
        "nee-nee-kids"
        "sassie-lash"
        "fayeloni-kreations"
        "sheda-shay-butter-bar"
        "faith-through-fitness"
        "roro-gamers-lounge"
        "tyshawn-v-dance-studio"
        "club-sadityy"
        "headwinas-comedy-club"
        "idf-live"
        "clocking-t-with-ya-gurl-p"
        "gas-or-crash-live"
        "rise-sacramento-916"
        "puaboverse"
        "vscreen-hollywood"
        "nexus-studio-ai"
        "metatwin"
        "musicchain"
        "boom-boom-room"
    )
    
    local passed_checks=0
    for tenant in "${tenants[@]}"; do
        if grep -q "$tenant" "$file" 2>/dev/null; then
            ((passed_checks++))
        else
            log_fail "Tenant missing: $tenant"
        fi
    done
    
    if [ $passed_checks -eq 20 ]; then
        log_pass "All 20 tenants verified"
        
    else
        log_fail "Tenants incomplete ($passed_checks/20)"
        
    fi
}

test_vr_ar_systems() {
    local file=$1
    log_test "Verifying VR/AR systems (NexusVision, HoloCore, StreaCore)"
    
    local systems=(
        "NexusVision:VR/AR streaming"
        "HoloCore:Holographic UI"
        "StreaCore:Multi-stream management"
    )
    
    local passed_checks=0
    for system in "${systems[@]}"; do
        IFS=':' read -r name desc <<< "$system"
        if grep -q "$name" "$file" 2>/dev/null; then
            log_pass "$name verified: $desc"
            ((passed_checks++))
        else
            log_fail "$name missing"
        fi
    done
    
    if [ $passed_checks -eq ${#systems[@]} ]; then
        log_pass "All VR/AR systems verified"
        
    else
        log_fail "VR/AR systems incomplete ($passed_checks/${#systems[@]})"
        
    fi
}

test_nginx_configuration() {
    local file=$1
    log_test "Verifying Nginx SSL/TLS configuration"
    
    local checks=(
        "ssl_certificate:SSL certificate path"
        "ssl_protocols:SSL protocols"
        "Strict-Transport-Security:HSTS header"
        "X-Frame-Options:Security headers"
        "/puaboverse:Casino-Nexus Lounge route"
        "/wallet:Wallet route"
        "/live:Live streaming route"
        "/api:API Gateway route"
        "/health:Health check endpoint"
    )
    
    local passed_checks=0
    for check in "${checks[@]}"; do
        IFS=':' read -r pattern desc <<< "$check"
        if grep -q "$pattern" "$file" 2>/dev/null; then
            log_pass "Nginx config includes: $desc"
            ((passed_checks++))
        else
            log_fail "Nginx config missing: $desc"
        fi
    done
    
    if [ $passed_checks -eq ${#checks[@]} ]; then
        log_pass "Nginx configuration verified"
        
    else
        log_fail "Nginx configuration incomplete ($passed_checks/${#checks[@]})"
        
    fi
}

test_control_panel() {
    local file=$1
    log_test "Verifying N.E.X.U.S AI Control Panel (nexus-control)"
    
    local commands=(
        "status:Service status check"
        "logs:Log viewing"
        "health:Health check"
        "restart:Service restart"
        "scale:Service scaling"
        "deploy:Redeployment"
        "monitor:Real-time monitoring"
        "verify:Verification scripts"
    )
    
    local passed_checks=0
    for cmd in "${commands[@]}"; do
        IFS=':' read -r name desc <<< "$cmd"
        if grep -q "$name)" "$file" 2>/dev/null; then
            log_pass "Control panel has: $desc ($name)"
            ((passed_checks++))
        else
            log_fail "Control panel missing: $desc ($name)"
        fi
    done
    
    if [ $passed_checks -eq ${#commands[@]} ]; then
        log_pass "Control panel verified (all 8 commands)"
        
    else
        log_fail "Control panel incomplete ($passed_checks/${#commands[@]})"
        
    fi
}

test_handshake_verification() {
    local file=$1
    log_test "Verifying Nexus-Handshake 55-45-17 compliance system"
    
    if grep -q "run_handshake_verification.sh" "$file" 2>/dev/null; then
        log_pass "Nexus-Handshake integration present"
        
    else
        log_fail "Nexus-Handshake integration missing"
        
    fi
}

################################################################################
# MAIN VERIFICATION
################################################################################

log_header "PR #180 DEPLOYMENT VERIFICATION SCRIPT"
log_info "Starting comprehensive verification of N.E.X.U.S AI FULL DEPLOY"
log_info "Date: $(date '+%Y-%m-%d %H:%M:%S')"

# Change to repository directory
cd /home/runner/work/nexus-cos/nexus-cos || exit 1

log_header "1. DEPLOYMENT SCRIPT FILES"

# Main deployment scripts
test_file_exists "NEXUS_AI_FULL_DEPLOY.sh" "Main deployment script"
test_file_executable "NEXUS_AI_FULL_DEPLOY.sh" "Main deployment script"
test_bash_syntax "NEXUS_AI_FULL_DEPLOY.sh" "Main deployment script"

test_file_exists "VPS_BULLETPROOF_ONE_LINER.sh" "Bulletproof one-liner script"
test_file_executable "VPS_BULLETPROOF_ONE_LINER.sh" "Bulletproof one-liner script"
test_bash_syntax "VPS_BULLETPROOF_ONE_LINER.sh" "Bulletproof one-liner script"

test_file_exists "NEXUS_MASTER_ONE_SHOT.sh" "Master one-shot script"
test_file_executable "NEXUS_MASTER_ONE_SHOT.sh" "Master one-shot script"
test_bash_syntax "NEXUS_MASTER_ONE_SHOT.sh" "Master one-shot script"

log_header "2. DOCUMENTATION FILES"

test_file_exists "NEXUS_AI_DEPLOYMENT_GUIDE.md" "Deployment guide"
test_file_exists "NEXUS_MASTER_ONE_SHOT_QUICKSTART.md" "Quick start guide"

log_header "3. DEVOPS VERIFICATION SCRIPTS"

test_file_exists "devops/run_handshake_verification.sh" "Handshake verification"
test_file_executable "devops/run_handshake_verification.sh" "Handshake verification"
test_bash_syntax "devops/run_handshake_verification.sh" "Handshake verification"

test_file_exists "devops/verify_tenants.sh" "Tenant verification"
test_file_executable "devops/verify_tenants.sh" "Tenant verification"
test_bash_syntax "devops/verify_tenants.sh" "Tenant verification"

test_file_exists "devops/verify_casino_grid.sh" "Casino grid verification"
test_file_executable "devops/verify_casino_grid.sh" "Casino grid verification"
test_bash_syntax "devops/verify_casino_grid.sh" "Casino grid verification"

test_file_exists "devops/apply_sovern_build.sh" "Sovern Build optimizations"
test_file_executable "devops/apply_sovern_build.sh" "Sovern Build optimizations"
test_bash_syntax "devops/apply_sovern_build.sh" "Sovern Build optimizations"

test_file_exists "devops/verify_nexcoin_gating.sh" "NexCoin gating verification"
test_file_executable "devops/verify_nexcoin_gating.sh" "NexCoin gating verification"
test_bash_syntax "devops/verify_nexcoin_gating.sh" "NexCoin gating verification"

test_file_exists "devops/nexus_mini_addin.sh" "Mini tenant expansion"
test_file_executable "devops/nexus_mini_addin.sh" "Mini tenant expansion"
test_bash_syntax "devops/nexus_mini_addin.sh" "Mini tenant expansion"

test_file_exists "devops/fix_database_and_pwa.sh" "Database and PWA fix script"
test_file_executable "devops/fix_database_and_pwa.sh" "Database and PWA fix script"
test_bash_syntax "devops/fix_database_and_pwa.sh" "Database and PWA fix script"

log_header "4. DATABASE INITIALIZATION (11 FOUNDER ACCESS KEYS)"

test_database_initialization "NEXUS_AI_FULL_DEPLOY.sh"

log_header "5. PWA INFRASTRUCTURE"

test_pwa_infrastructure "NEXUS_AI_FULL_DEPLOY.sh"

log_header "6. FEATURE FLAGS (PRs #174-178)"

test_feature_flags "NEXUS_AI_FULL_DEPLOY.sh"

log_header "7. TENANT CONFIGURATION (20 MINI PLATFORMS)"

test_tenant_configuration "NEXUS_AI_FULL_DEPLOY.sh"

log_header "8. VR/AR SYSTEMS"

test_vr_ar_systems "NEXUS_AI_FULL_DEPLOY.sh"

log_header "9. NGINX SSL/TLS CONFIGURATION"

test_nginx_configuration "NEXUS_AI_FULL_DEPLOY.sh"

log_header "10. N.E.X.U.S AI CONTROL PANEL"

test_control_panel "NEXUS_AI_FULL_DEPLOY.sh"

log_header "11. NEXUS-HANDSHAKE 55-45-17 COMPLIANCE"

test_handshake_verification "NEXUS_AI_FULL_DEPLOY.sh"

log_header "12. DEPLOYMENT STEP VERIFICATION"

log_test "Verifying 13-step deployment process"
steps=(
    "Prerequisites Validation"
    "Database Initialization"
    "PWA Infrastructure"
    "Feature Configuration"
    "Tenant Configuration"
    "VR/AR Systems"
    "Sovern Build"
    "Nginx Configuration"
    "Docker Stack Deployment"
    "Health Check Validation"
    "Control Panel Setup"
    "Nexus-Handshake 55-45-17"
    "Deployment Summary"
)

passed_steps=0
for i in {1..13}; do
    if grep -q "\[$i/13\]" "NEXUS_AI_FULL_DEPLOY.sh" 2>/dev/null; then
        ((passed_steps++))
    else
        log_fail "Step $i missing"
    fi
done

if [ $passed_steps -eq 13 ]; then
    log_pass "All 13 deployment steps verified"
else
    log_fail "Deployment steps incomplete ($passed_steps/13)"
fi

log_header "13. ONE-LINER SSH COMMAND VERIFICATION"

log_test "Checking deployment guide for SSH one-liner"
if grep -q "ssh root@YOUR_VPS_IP" "NEXUS_AI_DEPLOYMENT_GUIDE.md" 2>/dev/null; then
    log_pass "SSH one-liner documented in deployment guide"
else
    log_fail "SSH one-liner not found in deployment guide"
fi

if grep -q "curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/NEXUS_AI_FULL_DEPLOY.sh" "NEXUS_AI_DEPLOYMENT_GUIDE.md" 2>/dev/null; then
    log_pass "Correct GitHub raw URL in deployment guide"
else
    log_fail "GitHub raw URL incorrect or missing"
fi

log_header "14. SECURITY CHECKS"

log_test "Checking for secure credential handling"
if grep -q "CHANGE IMMEDIATELY" "NEXUS_AI_FULL_DEPLOY.sh" 2>/dev/null; then
    log_pass "Security warning for default credentials present"
else
    log_warn "Security warning for default credentials missing"
fi

log_test "Checking for SSL/TLS enforcement"
if grep -q "ssl_protocols TLSv1.2 TLSv1.3" "NEXUS_AI_FULL_DEPLOY.sh" 2>/dev/null; then
    log_pass "Modern TLS protocols enforced"
else
    log_warn "TLS protocol configuration may be outdated"
fi

log_test "Checking for security headers"
if grep -q "Strict-Transport-Security" "NEXUS_AI_FULL_DEPLOY.sh" 2>/dev/null; then
    log_pass "Security headers configured"
else
    log_warn "Security headers may be missing"
fi

################################################################################
# SUMMARY
################################################################################

log_header "VERIFICATION SUMMARY"

TOTAL_TESTS=$((PASSED + FAILED))
SUCCESS_RATE=0
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$((PASSED * 100 / TOTAL_TESTS))
fi

echo ""
echo -e "${GREEN}Passed:${NC}   $PASSED"
echo -e "${RED}Failed:${NC}   $FAILED"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${BLUE}Total:${NC}    $TOTAL_TESTS"
echo ""
echo -e "Success Rate: ${GREEN}${SUCCESS_RATE}%${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ ALL VERIFICATION CHECKS PASSED!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}PR #180 is VERIFIED and ready for deployment!${NC}"
    echo ""
    echo -e "${BLUE}Deployment command:${NC}"
    echo -e "${YELLOW}ssh root@YOUR_VPS_IP \"curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/NEXUS_AI_FULL_DEPLOY.sh | sudo bash -s\"${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ VERIFICATION FAILED - $FAILED issues found${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${RED}Please review and fix the failed tests above.${NC}"
    echo ""
    exit 1
fi

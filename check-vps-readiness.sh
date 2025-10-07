#!/bin/bash
# ==============================================================================
# Nexus COS VPS Readiness Check
# ==============================================================================
# Purpose: Verify VPS meets requirements before deployment
# Usage: bash check-vps-readiness.sh
# ==============================================================================

set -uo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

print_header() {
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                                                               ║${NC}"
    echo -e "${PURPLE}║        🚀 Nexus COS VPS Readiness Check 🚀                    ║${NC}"
    echo -e "${PURPLE}║                                                               ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

check_pass() {
    echo -e "${GREEN}[✓ PASS]${NC} $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}[✗ FAIL]${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}[⚠ WARN]${NC} $1"
    ((CHECKS_WARNING++))
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_header

# ==============================================================================
# CHECK 1: Operating System
# ==============================================================================

print_section "Operating System"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "OS: $PRETTY_NAME"
    
    if [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
        VERSION_NUM=$(echo "$VERSION_ID" | cut -d'.' -f1)
        
        if [[ "$ID" == "ubuntu" ]] && [[ $VERSION_NUM -ge 20 ]]; then
            check_pass "Ubuntu 20.04 or newer detected"
        elif [[ "$ID" == "debian" ]] && [[ $VERSION_NUM -ge 10 ]]; then
            check_pass "Debian 10 or newer detected"
        else
            check_warn "Old OS version detected. Ubuntu 20.04+ or Debian 10+ recommended"
        fi
    else
        check_warn "Non-Ubuntu/Debian OS detected. May require manual package installation"
    fi
else
    check_fail "Cannot detect OS version (/etc/os-release missing)"
fi

# ==============================================================================
# CHECK 2: Root/Sudo Access
# ==============================================================================

print_section "Access Privileges"

if [[ $EUID -eq 0 ]]; then
    check_pass "Running as root"
elif sudo -n true 2>/dev/null; then
    check_pass "Sudo access available"
else
    check_fail "Neither root nor passwordless sudo access. Deployment requires root privileges"
fi

# ==============================================================================
# CHECK 3: Memory (RAM)
# ==============================================================================

print_section "Memory (RAM)"

total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
total_ram_gb=$((total_ram_kb / 1024 / 1024))

print_info "Total RAM: ${total_ram_gb}GB"

if [[ $total_ram_gb -ge 8 ]]; then
    check_pass "RAM: ${total_ram_gb}GB (Excellent - Recommended 8GB+)"
elif [[ $total_ram_gb -ge 4 ]]; then
    check_pass "RAM: ${total_ram_gb}GB (Good - Minimum requirement met)"
elif [[ $total_ram_gb -ge 2 ]]; then
    check_warn "RAM: ${total_ram_gb}GB (Low - May experience performance issues. 4GB+ recommended)"
else
    check_fail "RAM: ${total_ram_gb}GB (Insufficient - Minimum 4GB required, 8GB recommended)"
fi

# ==============================================================================
# CHECK 4: Disk Space
# ==============================================================================

print_section "Disk Space"

available_space_gb=$(df -BG /opt 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')

print_info "Available disk space: ${available_space_gb}GB"

if [[ $available_space_gb -ge 20 ]]; then
    check_pass "Disk space: ${available_space_gb}GB (Excellent)"
elif [[ $available_space_gb -ge 10 ]]; then
    check_pass "Disk space: ${available_space_gb}GB (Good - Minimum requirement met)"
elif [[ $available_space_gb -ge 5 ]]; then
    check_warn "Disk space: ${available_space_gb}GB (Low - May need cleanup soon. 10GB+ recommended)"
else
    check_fail "Disk space: ${available_space_gb}GB (Insufficient - Minimum 10GB required)"
fi

# ==============================================================================
# CHECK 5: CPU Cores
# ==============================================================================

print_section "CPU Cores"

cpu_cores=$(nproc)
print_info "CPU cores: $cpu_cores"

if [[ $cpu_cores -ge 4 ]]; then
    check_pass "CPU cores: $cpu_cores (Excellent - Recommended 4+)"
elif [[ $cpu_cores -ge 2 ]]; then
    check_pass "CPU cores: $cpu_cores (Good - Minimum requirement met)"
else
    check_warn "CPU cores: $cpu_cores (Low - May experience performance issues. 2+ recommended)"
fi

# ==============================================================================
# CHECK 6: Network Connectivity
# ==============================================================================

print_section "Network Connectivity"

if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
    check_pass "Internet connectivity working"
else
    check_fail "No internet connectivity detected"
fi

if ping -c 1 -W 2 raw.githubusercontent.com &> /dev/null; then
    check_pass "GitHub connectivity working"
else
    check_warn "Cannot reach GitHub (required for deployment)"
fi

# ==============================================================================
# CHECK 7: Required Ports
# ==============================================================================

print_section "Port Availability"

check_port() {
    local port=$1
    local name=$2
    
    if ss -ltn 2>/dev/null | grep -q ":$port " || netstat -ltn 2>/dev/null | grep -q ":$port "; then
        check_warn "Port $port ($name) is already in use"
    else
        check_pass "Port $port ($name) is available"
    fi
}

check_port 80 "HTTP"
check_port 443 "HTTPS"
check_port 3000 "Backend"
check_port 5432 "PostgreSQL"
check_port 6379 "Redis"

# ==============================================================================
# CHECK 8: Required Commands
# ==============================================================================

print_section "System Commands"

check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -1 || echo "installed")
        check_pass "$name installed ($version)"
    else
        check_warn "$name not installed (will be installed during deployment)"
    fi
}

check_command curl "curl"
check_command git "git"
check_command nginx "nginx"
check_command node "Node.js"
check_command npm "npm"
check_command python3 "Python 3"
check_command systemctl "systemctl"

# ==============================================================================
# CHECK 9: Firewall Status
# ==============================================================================

print_section "Firewall Status"

if command -v ufw &> /dev/null; then
    print_info "UFW firewall detected"
    
    if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
        check_warn "UFW is active - Ensure ports 80 and 443 are allowed"
        print_info "  Run: sudo ufw allow 80/tcp && sudo ufw allow 443/tcp"
    else
        check_pass "UFW is inactive"
    fi
elif command -v firewall-cmd &> /dev/null; then
    print_info "firewalld detected"
    
    if sudo firewall-cmd --state 2>/dev/null | grep -q "running"; then
        check_warn "firewalld is active - Ensure ports 80 and 443 are allowed"
        print_info "  Run: sudo firewall-cmd --permanent --add-service=http --add-service=https && sudo firewall-cmd --reload"
    else
        check_pass "firewalld is inactive"
    fi
else
    check_pass "No common firewall detected"
fi

# ==============================================================================
# CHECK 10: SELinux Status (if applicable)
# ==============================================================================

print_section "SELinux Status"

if command -v getenforce &> /dev/null; then
    selinux_status=$(getenforce 2>/dev/null || echo "Unknown")
    print_info "SELinux status: $selinux_status"
    
    if [[ "$selinux_status" == "Enforcing" ]]; then
        check_warn "SELinux is enforcing - May require additional configuration"
    else
        check_pass "SELinux is not enforcing"
    fi
else
    check_pass "SELinux not present"
fi

# ==============================================================================
# SUMMARY
# ==============================================================================

print_section "Summary"

echo ""
echo -e "  ${GREEN}Passed:${NC}  $CHECKS_PASSED"
echo -e "  ${YELLOW}Warnings:${NC} $CHECKS_WARNING"
echo -e "  ${RED}Failed:${NC}  $CHECKS_FAILED"
echo ""

if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║  ✅ Your VPS is ready for Nexus COS deployment! ✅             ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Deploy now with:${NC}"
    echo ""
    echo -e "  ${BLUE}curl -fsSL https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/launch-bulletproof.sh | sudo bash${NC}"
    echo ""
    
    if [[ $CHECKS_WARNING -gt 0 ]]; then
        echo -e "${YELLOW}Note:${NC} You have $CHECKS_WARNING warning(s). Review them above."
        echo ""
    fi
    
    exit 0
else
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}║  ❌ Your VPS is NOT ready for deployment                      ║${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please fix the issues above before attempting deployment.${NC}"
    echo ""
    echo -e "${CYAN}Common fixes:${NC}"
    echo ""
    echo "  1. Upgrade OS to Ubuntu 20.04+ or Debian 10+"
    echo "  2. Ensure you have root or sudo access"
    echo "  3. Add more RAM if below minimum requirements"
    echo "  4. Free up disk space (clean apt cache, remove old logs)"
    echo "  5. Check internet connectivity"
    echo ""
    
    exit 1
fi

#!/bin/bash
# Beta URL Health Check Script  
# Verifies all beta URLs and configurations for 10/01/2025 launch
# Documented in docs/NEXUS_COS_URLS.md

set -e

echo "🧪 NEXUS COS - Beta Environment URL Verification"
echo "==============================================="
echo "$(date): Starting beta URL verification for 10/01/2025 launch"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to check URL
check_url() {
    local url=$1
    local description=$2
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "📡 Checking $description: $url ... "
    
    if curl -s -f -m 10 "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to check URL with expected response
check_url_response() {
    local url=$1
    local description=$2
    local expected=$3
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "📡 Checking $description: $url ... "
    
    response=$(curl -s -f -m 10 "$url" 2>/dev/null || echo "FAILED")
    
    if [[ "$response" == *"$expected"* ]]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}❌ FAIL${NC} (Expected: $expected)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to check SSL certificate
check_ssl() {
    local domain=$1
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "🔒 Checking SSL for $domain ... "
    
    if echo | openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | grep -q "Verify return code: 0"; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

# Function to check local development endpoints
check_local_url() {
    local url=$1
    local description=$2
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    echo -n "🏠 Checking Local $description: $url ... "
    
    if curl -s -f -m 5 "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}⚠️ NOT RUNNING${NC} (Expected for remote verification)"
        # Don't count local failures against beta readiness
    fi
}

echo -e "${PURPLE}🎯 BETA LAUNCH DATE: October 1, 2025${NC}"
echo ""

echo -e "${BLUE}1. Primary Beta Domain Checks${NC}"
echo "-----------------------------"
check_url "https://beta.n3xuscos.online" "Main Beta Application"
check_url "https://beta.n3xuscos.online/api" "Beta API Base URL"
check_url "https://beta.n3xuscos.online/admin" "Beta Admin Portal"
echo ""

echo -e "${BLUE}2. Beta Service URLs${NC}"
echo "-------------------"
check_url "https://beta.n3xuscos.online:3000" "Beta Node.js Backend"
check_url "https://beta.n3xuscos.online:3001" "Beta Python Backend"
check_url "https://beta.n3xuscos.online:8080" "Beta Frontend"
echo ""

echo -e "${BLUE}3. Beta Health Monitoring${NC}"
echo "-------------------------"
check_url_response "https://beta.n3xuscos.online/health" "Beta Health Check" "ok"
check_url_response "https://beta.n3xuscos.online:3000/health" "Beta Backend Health" "ok"
check_url_response "https://beta.n3xuscos.online:3001/health" "Beta Python Health" "ok"
check_url "https://beta.n3xuscos.online/api/auth/test" "Beta Auth Test"
check_url "https://beta.n3xuscos.online/api/auth/login" "Beta Login Test"
echo ""

echo -e "${BLUE}4. Beta SSL Certificate Verification${NC}"
echo "-------------------------------------"
check_ssl "beta.n3xuscos.online"
echo ""

echo -e "${BLUE}5. Local Development Endpoints (Optional)${NC}"
echo "-------------------------------------------"
check_local_url "http://localhost:3000/health" "Node.js Backend"
check_local_url "http://localhost:3001/health" "Python Backend"
check_local_url "http://localhost:8080" "Frontend Server"
echo ""

echo -e "${BLUE}6. Beta Performance Checks${NC}"
echo "--------------------------"
echo -n "⚡ Response time for beta.n3xuscos.online ... "
response_time=$(curl -o /dev/null -s -w "%{time_total}" https://beta.n3xuscos.online 2>/dev/null || echo "FAILED")
if [[ "$response_time" != "FAILED" ]]; then
    if (( $(echo "$response_time < 2.0" | bc -l) )); then
        echo -e "${GREEN}✅ PASS${NC} (${response_time}s)"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${YELLOW}⚠️ SLOW${NC} (${response_time}s)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
else
    echo -e "${RED}❌ FAIL${NC}"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
echo ""

echo -e "${BLUE}7. Launch Readiness Checks${NC}"
echo "--------------------------"
echo -n "📅 Launch date verification ... "
current_date=$(date +%Y%m%d)
launch_date="20251001"

if [ "$current_date" -ge "$launch_date" ]; then
    echo -e "${GREEN}✅ LAUNCH DATE REACHED${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    days_remaining=$(( ($(date -d "2025-10-01" +%s) - $(date +%s)) / 86400 ))
    echo -e "${YELLOW}⏳ $days_remaining DAYS UNTIL LAUNCH${NC}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
echo ""

echo "==============================================="
echo -e "${PURPLE}📊 BETA VERIFICATION SUMMARY${NC}"
echo "==============================================="
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo ""

echo -e "${PURPLE}🎯 BETA LAUNCH READINESS STATUS${NC}"
echo "--------------------------------"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🚀 BETA ENVIRONMENT IS LAUNCH READY!${NC}"
    echo "All systems verified for October 1, 2025 beta launch."
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Final pre-launch verification on September 30, 2025"
    echo "2. DNS switch at 08:00 UTC on October 1, 2025"
    echo "3. Enable monitoring alerts"
    echo "4. Begin beta testing program"
    exit 0
elif [ $FAILED_CHECKS -le 2 ]; then
    echo -e "${YELLOW}⚠️ BETA ENVIRONMENT NEEDS ATTENTION${NC}"
    echo "Minor issues detected. Review failed checks."
    echo "Beta launch may proceed with caution."
    exit 1
else
    echo -e "${RED}❌ BETA ENVIRONMENT NOT READY${NC}"
    echo "Critical issues detected. Beta launch should be delayed."
    echo "Please resolve all failed checks before launch."
    exit 2
fi
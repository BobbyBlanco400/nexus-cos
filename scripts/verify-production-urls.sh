#!/bin/bash
# Production URL Health Check Script
# Verifies all production URLs and configurations documented in docs/NEXUS_COS_URLS.md

set -e

echo "🔍 NEXUS COS - Production URL Verification"
echo "=========================================="
echo "$(date): Starting production URL verification"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo -e "${BLUE}1. Primary Domain Checks${NC}"
echo "------------------------"
check_url "https://nexuscos.online" "Main Application"
check_url "https://www.nexuscos.online" "WWW Subdomain"
check_url "https://nexuscos.online/api" "API Base URL"
echo ""

echo -e "${BLUE}2. Internal Service URLs${NC}"
echo "------------------------"
check_url "https://nexuscos.online:3000" "Node.js Backend"
check_url "https://nexuscos.online:3001" "Python Backend (PUABO)"
check_url "https://monitoring.nexuscos.online" "Monitoring Service"
check_url "https://nexuscos.online/admin" "Admin Portal"
echo ""

echo -e "${BLUE}3. Health Check Endpoints${NC}"
echo "--------------------------"
check_url_response "https://nexuscos.online/health" "Main Health Check" "ok"
check_url_response "https://nexuscos.online:3000/health" "Backend Health" "ok"
check_url_response "https://nexuscos.online:3001/health" "Python Backend Health" "ok"
check_url "https://nexuscos.online/api/status" "API Status"
check_url "https://nexuscos.online/api/auth/test" "Auth Service"
echo ""

echo -e "${BLUE}4. SSL Certificate Verification${NC}"
echo "--------------------------------"
check_ssl "nexuscos.online"
check_ssl "www.nexuscos.online"
check_ssl "monitoring.nexuscos.online"
echo ""

echo -e "${BLUE}5. Performance Checks${NC}"
echo "---------------------"
echo -n "⚡ Response time for nexuscos.online ... "
response_time=$(curl -o /dev/null -s -w "%{time_total}" https://nexuscos.online 2>/dev/null || echo "FAILED")
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

echo "=========================================="
echo -e "${BLUE}📊 VERIFICATION SUMMARY${NC}"
echo "=========================================="
echo "Total Checks: $TOTAL_CHECKS"
echo -e "Passed: ${GREEN}$PASSED_CHECKS${NC}"
echo -e "Failed: ${RED}$FAILED_CHECKS${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL PRODUCTION URLS VERIFIED SUCCESSFULLY!${NC}"
    echo "Production environment is ready for launch."
    exit 0
else
    echo -e "${RED}⚠️ SOME CHECKS FAILED${NC}"
    echo "Please review failed checks before production launch."
    exit 1
fi
#!/bin/bash

# PF Health Check Script
# Validates all PF service health endpoints
# Usage: ./pf-health-check.sh

set +e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}PF Health Check - Nexus COS${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to check health endpoint
check_health() {
    local service_name=$1
    local endpoint=$2
    local description=$3
    
    echo -e "${YELLOW}[CHECK]${NC} $service_name - $description"
    ((TOTAL_CHECKS++))
    
    # Try to curl the endpoint
    response=$(curl -sf -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}  ✓${NC} Health check passed (HTTP $response)"
        ((PASSED_CHECKS++))
    elif [ -z "$response" ]; then
        echo -e "${RED}  ✗${NC} Connection failed - service may not be running"
        ((FAILED_CHECKS++))
    else
        echo -e "${RED}  ✗${NC} Health check failed (HTTP $response)"
        ((FAILED_CHECKS++))
    fi
    echo ""
}

# Function to check service status
check_service_status() {
    local service_name=$1
    
    echo -e "${YELLOW}[CHECK]${NC} Docker service: $service_name"
    ((TOTAL_CHECKS++))
    
    status=$(docker compose -f docker-compose.pf.yml ps --format json 2>/dev/null | grep "$service_name" | grep -o '"State":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$status" = "running" ]; then
        echo -e "${GREEN}  ✓${NC} Service is running"
        ((PASSED_CHECKS++))
    else
        echo -e "${RED}  ✗${NC} Service status: ${status:-not found}"
        ((FAILED_CHECKS++))
    fi
    echo ""
}

echo -e "${BLUE}1. Docker Service Status${NC}"
echo ""

check_service_status "puabo-api"
check_service_status "nexus-cos-puaboai-sdk"
check_service_status "nexus-cos-pv-keys"
check_service_status "nexus-cos-postgres"
check_service_status "nexus-cos-redis"

echo -e "${BLUE}2. Health Check Endpoints${NC}"
echo ""

check_health "Hollywood/Gateway" "http://localhost:4000/health" "Main API Gateway"
check_health "Prompter/AI SDK" "http://localhost:3002/health" "V-Suite Prompter endpoint"
check_health "PV Keys" "http://localhost:3041/health" "Key management service"

echo -e "${BLUE}3. Database Connectivity${NC}"
echo ""

echo -e "${YELLOW}[CHECK]${NC} PostgreSQL connection"
((TOTAL_CHECKS++))

pg_status=$(docker compose -f docker-compose.pf.yml exec -T nexus-cos-postgres pg_isready -U nexus_user -d nexus_db 2>&1)

if echo "$pg_status" | grep -q "accepting connections"; then
    echo -e "${GREEN}  ✓${NC} PostgreSQL is accepting connections"
    ((PASSED_CHECKS++))
else
    echo -e "${RED}  ✗${NC} PostgreSQL connection failed"
    ((FAILED_CHECKS++))
fi
echo ""

echo -e "${YELLOW}[CHECK]${NC} Database tables"
((TOTAL_CHECKS++))

tables=$(docker compose -f docker-compose.pf.yml exec -T nexus-cos-postgres psql -U nexus_user -d nexus_db -t -c "\dt" 2>/dev/null | grep -E "users|sessions|api_keys|audit_log" | wc -l)

if [ "$tables" -ge 4 ]; then
    echo -e "${GREEN}  ✓${NC} Required database tables exist ($tables/4)"
    ((PASSED_CHECKS++))
else
    echo -e "${RED}  ✗${NC} Missing database tables (found $tables/4)"
    ((FAILED_CHECKS++))
fi
echo ""

echo -e "${BLUE}4. Redis Cache${NC}"
echo ""

echo -e "${YELLOW}[CHECK]${NC} Redis connection"
((TOTAL_CHECKS++))

redis_status=$(docker compose -f docker-compose.pf.yml exec -T nexus-cos-redis redis-cli ping 2>&1)

if echo "$redis_status" | grep -q "PONG"; then
    echo -e "${GREEN}  ✓${NC} Redis is responding"
    ((PASSED_CHECKS++))
else
    echo -e "${RED}  ✗${NC} Redis connection failed"
    ((FAILED_CHECKS++))
fi
echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Health Check Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Total Checks: ${TOTAL_CHECKS}"
echo -e "${GREEN}Passed: ${PASSED_CHECKS}${NC}"
echo -e "${RED}Failed: ${FAILED_CHECKS}${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ All health checks passed!${NC}"
    echo -e "${GREEN}PF stack is fully operational.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some health checks failed.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo -e "  1. Check service logs: ${BLUE}docker compose -f docker-compose.pf.yml logs -f${NC}"
    echo -e "  2. Restart failed services: ${BLUE}docker compose -f docker-compose.pf.yml restart [service-name]${NC}"
    echo -e "  3. Rebuild services: ${BLUE}docker compose -f docker-compose.pf.yml up -d --build${NC}"
    echo ""
    exit 1
fi

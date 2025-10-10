#!/bin/bash

# Nexus COS - Deployment Verification Script
# Tests all 33+ service health endpoints

set +e  # Don't exit on error, we want to check all services

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║           NEXUS COS - DEPLOYMENT VERIFICATION                  ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check health endpoint
check_health() {
    local service_name=$1
    local url=$2
    
    echo -e "${YELLOW}[CHECK]${NC} $service_name"
    ((TOTAL_CHECKS++))
    
    # Try to curl the endpoint
    response=$(curl -sf "$url" 2>/dev/null)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # Check if response contains "ok" status
        if echo "$response" | grep -q '"status".*"ok"'; then
            echo -e "${GREEN}  ✓${NC} Health check passed"
            ((PASSED_CHECKS++))
        else
            echo -e "${RED}  ✗${NC} Unexpected response: $response"
            ((FAILED_CHECKS++))
        fi
    else
        echo -e "${RED}  ✗${NC} Connection failed - service may not be running"
        ((FAILED_CHECKS++))
    fi
    echo ""
}

# Function to check Docker service status
check_docker_service() {
    local service_name=$1
    
    echo -e "${YELLOW}[CHECK]${NC} Docker service: $service_name"
    ((TOTAL_CHECKS++))
    
    status=$(docker compose -f docker-compose.nexus-full.yml ps --format json 2>/dev/null | grep "\"Name\":\"$service_name\"" | grep -o '"State":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$status" = "running" ]; then
        echo -e "${GREEN}  ✓${NC} Service is running"
        ((PASSED_CHECKS++))
    else
        echo -e "${RED}  ✗${NC} Service status: ${status:-not found}"
        ((FAILED_CHECKS++))
    fi
    echo ""
}

# ============================================================================
# Infrastructure Services
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  INFRASTRUCTURE SERVICES${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_docker_service "nexus-cos-postgres"
check_docker_service "nexus-cos-redis"
check_health "Auth Service" "http://localhost:3100/health"
check_health "Scheduler Service" "http://localhost:3101/health"

# ============================================================================
# Core Platform
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  CORE PLATFORM${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "PUABO OS v2.0.0" "http://localhost:8000/health"

# ============================================================================
# PUABO NEXUS (Fleet & Logistics)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO NEXUS - Fleet & Logistics${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "Fleet Service" "http://localhost:8080/health"
check_health "Tracker Microservice" "http://localhost:8081/health"
check_health "Location Microservice" "http://localhost:8082/health"

# ============================================================================
# PUABOverse (Metaverse)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABOVERSE - Metaverse Platform${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "World Engine" "http://localhost:8090/health"
check_health "Avatar Service" "http://localhost:8091/health"

# ============================================================================
# PUABO DSP (Music Distribution)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO DSP - Music Distribution${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "DSP API" "http://localhost:9000/health"

# ============================================================================
# MusicChain
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  MUSICCHAIN - Blockchain Music${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "MusicChain Service" "http://localhost:9001/health"

# ============================================================================
# PUABO BLAC (Finance)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO BLAC - Alternative Finance${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "BLAC API" "http://localhost:9100/health"
check_health "Wallet Service" "http://localhost:9101/health"

# ============================================================================
# PUABO Studio (Recording)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO STUDIO - Recording & Production${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "Studio API" "http://localhost:9200/health"
check_health "Mixer Service" "http://localhost:9201/health"
check_health "Mastering Service" "http://localhost:9202/health"

# ============================================================================
# V-Suite (Virtual Production)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  V-SUITE - Virtual Production${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "V-Screen Hollywood" "http://localhost:3010/health"
check_health "V-Caster Pro" "http://localhost:3011/health"
check_health "V-Stage" "http://localhost:3012/health"
check_health "V-Prompter Pro" "http://localhost:3002/health"

# ============================================================================
# StreamCore (Streaming)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STREAMCORE - OTT Streaming${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "StreamCore Service" "http://localhost:3016/health"
check_health "Chat Stream Service" "http://localhost:3017/health"

# ============================================================================
# GameCore (Gaming)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  GAMECORE - Gaming Platform${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "GameCore Service" "http://localhost:3020/health"

# ============================================================================
# Nexus Studio AI
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  NEXUS STUDIO AI - AI Content Creation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "Nexus AI Service" "http://localhost:3030/health"

# ============================================================================
# PUABO NUKI Clothing (Fashion)
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO NUKI CLOTHING - Fashion Platform${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "Fashion API" "http://localhost:9300/health"

# ============================================================================
# PUABO OTT TV Streaming
# ============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PUABO OTT TV - Streaming Platform${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

check_health "OTT API" "http://localhost:9400/health"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║                      VERIFICATION SUMMARY                      ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${GREEN}Passed Checks:${NC}    ${PASSED_CHECKS}/${TOTAL_CHECKS}"
echo -e "${RED}Failed Checks:${NC}    ${FAILED_CHECKS}/${TOTAL_CHECKS}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL SERVICES HEALTHY - READY FOR BETA LAUNCH${NC}"
    exit 0
else
    success_rate=$((PASSED_CHECKS * 100 / TOTAL_CHECKS))
    echo -e "${YELLOW}⚠️  SUCCESS RATE: ${success_rate}%${NC}"
    echo -e "${YELLOW}Some services are not responding. Check logs:${NC}"
    echo -e "   docker compose -f docker-compose.nexus-full.yml logs"
    exit 1
fi

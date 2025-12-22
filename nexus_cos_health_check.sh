#!/bin/bash
# NΞ3XUS·COS Health Check & Repair Script
# Monitors Docker container health and attempts automatic repair

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="${LOG_DIR:-/root/nexus_cos_logs}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_WAIT_TIME=120  # Maximum time to wait for a container to become healthy (in seconds)
CHECK_INTERVAL=10   # Interval between health checks (in seconds)

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

echo "===== NΞ3XUS·COS Health Check & Repair Script ====="
echo "Timestamp: $(date)"
echo "Logs will be saved in $LOG_DIR"
echo ""

# Function to get container health status
get_container_health() {
    local container_id=$1
    docker inspect --format='{{.State.Health.Status}}' "$container_id" 2>/dev/null || echo "none"
}

# Function to get container state
get_container_state() {
    local container_id=$1
    docker inspect --format='{{.State.Status}}' "$container_id" 2>/dev/null || echo "unknown"
}

# Function to wait for container to become healthy
wait_for_healthy() {
    local container_id=$1
    local container_name=$2
    local elapsed=0
    
    echo "Waiting for $container_name to become healthy (max ${MAX_WAIT_TIME}s)..."
    
    while [ $elapsed -lt $MAX_WAIT_TIME ]; do
        local health=$(get_container_health "$container_id")
        local state=$(get_container_state "$container_id")
        
        # If container has no healthcheck, check if it's running
        if [ "$health" = "none" ]; then
            if [ "$state" = "running" ]; then
                echo "✓ $container_name is running (no healthcheck defined)"
                return 0
            fi
        elif [ "$health" = "healthy" ]; then
            echo "✓ $container_name is healthy"
            return 0
        fi
        
        # Check if container has stopped/exited/paused (not just starting)
        if [ "$state" = "exited" ] || [ "$state" = "dead" ] || [ "$state" = "paused" ]; then
            echo "✗ $container_name has stopped/exited/paused"
            return 1
        fi
        
        echo "  Status: $state, Health: $health (${elapsed}s elapsed)"
        sleep $CHECK_INTERVAL
        elapsed=$((elapsed + CHECK_INTERVAL))
    done
    
    echo "⚠ Timeout waiting for $container_name to become healthy"
    return 1
}

# Find unhealthy containers
# A container is considered unhealthy if:
# - It has a healthcheck and the status is "unhealthy"
# - It's in a problematic state (not running, exited, dead, paused)
find_unhealthy_containers() {
    docker ps -a --format '{{.ID}} {{.Names}} {{.Ports}}' | while read -r id name ports; do
        local health=$(get_container_health "$id")
        local state=$(get_container_state "$id")
        
        # Check if container is actually unhealthy (not just starting)
        if [ "$health" = "unhealthy" ]; then
            echo "$id $name $ports"
        elif [ "$state" = "exited" ] || [ "$state" = "dead" ] || [ "$state" = "paused" ]; then
            # Container is in a problematic state
            echo "$id $name $ports"
        fi
    done
}

# Get list of unhealthy containers
UNHEALTHY=$(find_unhealthy_containers)

if [ -z "$UNHEALTHY" ]; then
    echo -e "${GREEN}✓ All containers are healthy!${NC}"
    exit 0
fi

echo "Found unhealthy containers:"
echo "$UNHEALTHY"
echo ""

# Process each unhealthy container
echo "$UNHEALTHY" | while read -r container_id container_name ports; do
    echo "------------------------------------------"
    echo "Processing: $container_name ($container_id)"
    echo "Ports: $ports"
    
    # Save container logs before restart
    log_file="${LOG_DIR}/${container_name}_${TIMESTAMP}.log"
    echo "Logs saved to: $log_file"
    docker logs "$container_id" > "$log_file" 2>&1 || true
    
    # Attempt restart
    echo "Attempting restart..."
    docker restart "$container_id"
    
    # Wait for container to become healthy
    if wait_for_healthy "$container_id" "$container_name"; then
        echo -e "${GREEN}✓ $container_name is now healthy${NC}"
    else
        final_health=$(get_container_health "$container_id")
        final_state=$(get_container_state "$container_id")
        echo -e "${YELLOW}⚠️ $container_name is still unhealthy. Check logs: $log_file${NC}"
        echo "  Final state: $final_state, Health: $final_health"
    fi
    echo "------------------------------------------"
    echo ""
done

echo ""
echo "===== Health Check & Repair Completed ====="
echo "Check $LOG_DIR for logs from each container."

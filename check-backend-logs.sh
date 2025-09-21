#!/bin/bash
# Script to check backend service logs on remote server
# Fixes the incorrect SSH command: ssh root@74.208.155.161 'pm2 logs boomroom-backend --lines 20'

set -e

# Configuration
SERVER_IP="74.208.155.161"
CORRECT_SERVER_IP="75.208.155.161"  # Based on FINAL_VALIDATION.sh
SERVICE_NODE="nexus-backend-node"
SERVICE_PYTHON="nexus-backend-python"
LOG_LINES=20

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

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -s, --server IP     Server IP address (default: $CORRECT_SERVER_IP)"
    echo "  -l, --lines NUM     Number of log lines to show (default: $LOG_LINES)"
    echo "  -n, --node         Show only Node.js backend logs"
    echo "  -p, --python       Show only Python backend logs"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Show logs for both backends"
    echo "  $0 --node                    # Show only Node.js backend logs"
    echo "  $0 --python --lines 50       # Show 50 lines of Python backend logs"
    echo "  $0 --server 74.208.155.161   # Use different server IP"
}

# Function to check backend logs via SSH
check_backend_logs() {
    local server_ip="$1"
    local service_name="$2"
    local service_type="$3"
    local lines="$4"
    
    print_info "Checking $service_type backend logs on $server_ip..."
    
    # First check if service is running
    if ssh root@"$server_ip" "systemctl is-active --quiet $service_name" 2>/dev/null; then
        print_success "$service_type backend service is running"
        
        # Show systemd service logs (since this system uses systemd, not PM2)
        echo ""
        echo "=== $service_type Backend Logs (last $lines lines) ==="
        ssh root@"$server_ip" "journalctl -u $service_name -n $lines --no-pager"
        echo ""
        
        # Also check if there are any PM2 processes (in case PM2 is also used)
        if ssh root@"$server_ip" "which pm2 >/dev/null 2>&1"; then
            print_info "PM2 is installed, checking for any PM2 processes..."
            pm2_output=$(ssh root@"$server_ip" "pm2 list" 2>/dev/null || echo "")
            if [[ "$pm2_output" == *"$service_name"* ]] || [[ "$pm2_output" == *"nexus"* ]] || [[ "$pm2_output" == *"backend"* ]]; then
                echo "=== PM2 Process List ==="
                echo "$pm2_output"
                echo ""
                
                # Try to get PM2 logs if process exists
                pm2_logs=$(ssh root@"$server_ip" "pm2 logs --lines $lines" 2>/dev/null || echo "")
                if [[ ! -z "$pm2_logs" ]]; then
                    echo "=== PM2 Logs ==="
                    echo "$pm2_logs"
                    echo ""
                fi
            else
                print_info "No PM2 processes found related to backend services"
            fi
        else
            print_info "PM2 not installed on server (using systemd instead)"
        fi
        
    else
        print_error "$service_type backend service is not running"
        print_info "Checking service status..."
        ssh root@"$server_ip" "systemctl status $service_name --no-pager" || true
    fi
}

# Parse command line arguments
SHOW_NODE=true
SHOW_PYTHON=true
SERVER="$CORRECT_SERVER_IP"
LINES="$LOG_LINES"

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--server)
            SERVER="$2"
            shift 2
            ;;
        -l|--lines)
            LINES="$2"
            shift 2
            ;;
        -n|--node)
            SHOW_NODE=true
            SHOW_PYTHON=false
            shift
            ;;
        -p|--python)
            SHOW_PYTHON=true
            SHOW_NODE=false
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
print_info "Backend Log Checker for Nexus COS"
print_info "================================="

# Check if the original incorrect command was used
if [[ "$SERVER" == "74.208.155.161" ]]; then
    print_warning "Note: The original command used IP 74.208.155.161"
    print_warning "The correct server IP appears to be 75.208.155.161 (from FINAL_VALIDATION.sh)"
    print_info "Proceeding with provided IP: $SERVER"
fi

echo ""

# Check connectivity first
print_info "Testing SSH connectivity to $SERVER..."
if ssh -o ConnectTimeout=10 root@"$SERVER" "echo 'SSH connection successful'" 2>/dev/null; then
    print_success "SSH connection to $SERVER successful"
else
    print_error "Failed to connect to $SERVER via SSH"
    print_info "Please check:"
    print_info "  1. Server is running and accessible"
    print_info "  2. SSH key is properly configured"
    print_info "  3. Server IP address is correct"
    exit 1
fi

echo ""

# Show backend logs
if [[ "$SHOW_NODE" == true ]]; then
    check_backend_logs "$SERVER" "$SERVICE_NODE" "Node.js" "$LINES"
fi

if [[ "$SHOW_PYTHON" == true ]]; then
    check_backend_logs "$SERVER" "$SERVICE_PYTHON" "Python" "$LINES"
fi

print_success "Log check completed"

# Show the corrected commands for future reference
echo ""
print_info "Corrected Commands for Future Reference:"
echo "========================================"
echo ""
echo "Instead of: ssh root@74.208.155.161 'pm2 logs boomroom-backend --lines 20'"
echo ""
echo "Use these commands:"
echo "  # Check Node.js backend logs:"
echo "  ssh root@$SERVER 'journalctl -u $SERVICE_NODE -n 20 --no-pager'"
echo ""
echo "  # Check Python backend logs:"
echo "  ssh root@$SERVER 'journalctl -u $SERVICE_PYTHON -n 20 --no-pager'"
echo ""
echo "  # Or use this script:"
echo "  ./check-backend-logs.sh --node          # Node.js only"
echo "  ./check-backend-logs.sh --python        # Python only"
echo "  ./check-backend-logs.sh                 # Both backends"
echo ""
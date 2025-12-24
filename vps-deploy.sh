#!/bin/bash
#================================================================
# NEXUS COS - VPS DEPLOYMENT WRAPPER
#================================================================
# Purpose: Simple wrapper to deploy Nexus COS to VPS via SSH
# Usage: ./vps-deploy.sh [VPS_IP] [SSH_USER]
#================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default values
DEFAULT_USER="root"
SCRIPT_URL="https://raw.githubusercontent.com/BobbyBlanco400/nexus-cos/main/VPS_BULLETPROOF_ONE_LINER.sh"
LOCAL_SCRIPT="./VPS_BULLETPROOF_ONE_LINER.sh"

# Print header
print_header() {
    echo -e "${CYAN}"
    echo "═════════════════════════════════════════════════════"
    echo "  Nexus COS - VPS Deployment Wrapper"
    echo "═════════════════════════════════════════════════════"
    echo -e "${NC}"
}

# Print usage
print_usage() {
    echo "Usage: $0 [VPS_IP] [SSH_USER]"
    echo ""
    echo "Arguments:"
    echo "  VPS_IP     - IP address of your VPS server (required)"
    echo "  SSH_USER   - SSH user (default: root)"
    echo ""
    echo "Examples:"
    echo "  $0 74.208.155.161"
    echo "  $0 74.208.155.161 ubuntu"
    echo "  $0 10.0.0.1 admin"
    echo ""
    echo "Options:"
    echo "  --help     - Show this help message"
    echo "  --local    - Use local script instead of downloading"
    echo "  --test     - Test SSH connection without deploying"
    echo ""
}

# Test SSH connection
test_ssh() {
    local vps_ip=$1
    local ssh_user=$2
    
    echo -e "${BLUE}Testing SSH connection to ${ssh_user}@${vps_ip}...${NC}"
    
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "${ssh_user}@${vps_ip}" "echo 'SSH connection successful'" 2>/dev/null; then
        echo -e "${GREEN}✅ SSH connection successful${NC}"
        return 0
    else
        echo -e "${RED}❌ SSH connection failed${NC}"
        echo -e "${YELLOW}Please check:${NC}"
        echo "  - VPS IP address is correct"
        echo "  - SSH service is running on VPS"
        echo "  - Firewall allows SSH (port 22)"
        echo "  - SSH keys are properly configured"
        return 1
    fi
}

# Deploy using remote script
deploy_remote() {
    local vps_ip=$1
    local ssh_user=$2
    
    echo -e "${BLUE}Deploying Nexus COS to ${ssh_user}@${vps_ip}...${NC}"
    echo -e "${YELLOW}This may take 5-10 minutes...${NC}"
    echo ""
    
    # Download and execute remote script
    ssh -o StrictHostKeyChecking=no "${ssh_user}@${vps_ip}" "curl -fsSL ${SCRIPT_URL} | bash"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}═════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL${NC}"
        echo -e "${GREEN}═════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${CYAN}Your Nexus COS platform is now running!${NC}"
        echo ""
        echo -e "${CYAN}Access points:${NC}"
        echo -e "  Frontend:    http://${vps_ip}:3000"
        echo -e "  Gateway API: http://${vps_ip}:4000"
        echo -e "  AI SDK:      http://${vps_ip}:3002"
        echo -e "  PV Keys:     http://${vps_ip}:3041"
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}═════════════════════════════════════════════════════${NC}"
        echo -e "${RED}❌ DEPLOYMENT FAILED${NC}"
        echo -e "${RED}═════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Check the deployment logs on your VPS:${NC}"
        echo "  ssh ${ssh_user}@${vps_ip} 'cat /tmp/nexus-deploy-*.log'"
        echo ""
        return 1
    fi
}

# Deploy using local script
deploy_local() {
    local vps_ip=$1
    local ssh_user=$2
    
    if [ ! -f "$LOCAL_SCRIPT" ]; then
        echo -e "${RED}❌ Local script not found: $LOCAL_SCRIPT${NC}"
        echo -e "${YELLOW}Run without --local to download from GitHub${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Deploying Nexus COS to ${ssh_user}@${vps_ip} using local script...${NC}"
    echo -e "${YELLOW}This may take 5-10 minutes...${NC}"
    echo ""
    
    # Upload and execute local script
    ssh -o StrictHostKeyChecking=no "${ssh_user}@${vps_ip}" 'bash -s' < "$LOCAL_SCRIPT"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}═════════════════════════════════════════════════════${NC}"
        echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL${NC}"
        echo -e "${GREEN}═════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${CYAN}Your Nexus COS platform is now running!${NC}"
        echo ""
        echo -e "${CYAN}Access points:${NC}"
        echo -e "  Frontend:    http://${vps_ip}:3000"
        echo -e "  Gateway API: http://${vps_ip}:4000"
        echo -e "  AI SDK:      http://${vps_ip}:3002"
        echo -e "  PV Keys:     http://${vps_ip}:3041"
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}═════════════════════════════════════════════════════${NC}"
        echo -e "${RED}❌ DEPLOYMENT FAILED${NC}"
        echo -e "${RED}═════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${YELLOW}Check the deployment logs on your VPS:${NC}"
        echo "  ssh ${ssh_user}@${vps_ip} 'cat /tmp/nexus-deploy-*.log'"
        echo ""
        return 1
    fi
}

# Main function
main() {
    print_header
    
    # Parse arguments
    local vps_ip=""
    local ssh_user="$DEFAULT_USER"
    local use_local=false
    local test_only=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                print_usage
                exit 0
                ;;
            --local)
                use_local=true
                shift
                ;;
            --test)
                test_only=true
                shift
                ;;
            *)
                if [ -z "$vps_ip" ]; then
                    vps_ip=$1
                elif [ "$ssh_user" == "$DEFAULT_USER" ]; then
                    ssh_user=$1
                fi
                shift
                ;;
        esac
    done
    
    # Validate arguments
    if [ -z "$vps_ip" ]; then
        echo -e "${RED}❌ Error: VPS IP address is required${NC}"
        echo ""
        print_usage
        exit 1
    fi
    
    # Validate IP format
    if ! [[ "$vps_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo -e "${RED}❌ Error: Invalid IP address format${NC}"
        echo ""
        print_usage
        exit 1
    fi
    
    echo -e "${CYAN}Target VPS:${NC} ${ssh_user}@${vps_ip}"
    echo ""
    
    # Test SSH connection
    if ! test_ssh "$vps_ip" "$ssh_user"; then
        exit 1
    fi
    
    # If test only, exit here
    if $test_only; then
        echo ""
        echo -e "${GREEN}✅ SSH connection test passed. Ready to deploy!${NC}"
        echo ""
        echo "To deploy, run:"
        echo "  $0 $vps_ip $ssh_user"
        exit 0
    fi
    
    echo ""
    
    # Confirm deployment
    echo -e "${YELLOW}About to deploy Nexus COS to ${ssh_user}@${vps_ip}${NC}"
    echo -e "${YELLOW}This will:${NC}"
    echo "  - Update/clone the repository"
    echo "  - Configure environment"
    echo "  - Deploy Docker services"
    echo "  - Run health checks"
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deployment cancelled${NC}"
        exit 0
    fi
    
    echo ""
    
    # Deploy
    if $use_local; then
        deploy_local "$vps_ip" "$ssh_user"
    else
        deploy_remote "$vps_ip" "$ssh_user"
    fi
}

# Run main function
main "$@"

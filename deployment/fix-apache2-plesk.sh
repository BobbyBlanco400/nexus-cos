#!/bin/bash
# Apache2/Plesk Configuration Helper
# Resolves Apache2 startup issues when running alongside Nginx

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo "══════════════════════════════════════════════════════════════"
echo "  APACHE2/PLESK CONFIGURATION HELPER"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root or with sudo"
    exit 1
fi

print_status "Analyzing Apache2 and Nginx configuration..."
echo ""

# Check if Apache2 is installed
APACHE_INSTALLED=false
if command -v apache2 &> /dev/null || command -v httpd &> /dev/null; then
    APACHE_INSTALLED=true
    print_status "Apache2 is installed"
else
    print_status "Apache2 is not installed"
fi

# Check if Nginx is installed and running
NGINX_RUNNING=false
if command -v nginx &> /dev/null; then
    print_status "Nginx is installed"
    if systemctl is-active --quiet nginx; then
        NGINX_RUNNING=true
        print_success "Nginx is running"
    else
        print_warning "Nginx is installed but not running"
    fi
else
    print_status "Nginx is not installed"
fi

# Check if Plesk is installed
PLESK_INSTALLED=false
if [ -d "/opt/psa" ]; then
    PLESK_INSTALLED=true
    print_status "Plesk is installed"
else
    print_status "Plesk is not installed"
fi

echo ""
print_status "Checking port usage..."
echo ""

# Check what's listening on port 80 and 443
PORT_80_OWNER=$(netstat -tlnp 2>/dev/null | grep ":80 " | awk '{print $NF}' | cut -d'/' -f2 | head -1)
PORT_443_OWNER=$(netstat -tlnp 2>/dev/null | grep ":443 " | awk '{print $NF}' | cut -d'/' -f2 | head -1)

if [ -n "$PORT_80_OWNER" ]; then
    print_status "Port 80 is used by: $PORT_80_OWNER"
else
    print_warning "Port 80 is not in use"
fi

if [ -n "$PORT_443_OWNER" ]; then
    print_status "Port 443 is used by: $PORT_443_OWNER"
else
    print_warning "Port 443 is not in use"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  RECOMMENDED ACTIONS"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Scenario 1: Both Apache and Nginx installed, Nginx is primary
if [ "$APACHE_INSTALLED" = true ] && [ "$NGINX_RUNNING" = true ]; then
    print_status "Scenario: Both Apache2 and Nginx detected, Nginx is running"
    echo ""
    echo "Since Nginx is your primary web server, you have three options:"
    echo ""
    echo "OPTION 1: Disable Apache2 (Recommended if not needed)"
    echo "  This will stop Apache2 and prevent it from starting on boot."
    echo ""
    echo "    sudo systemctl stop apache2"
    echo "    sudo systemctl disable apache2"
    echo ""
    
    echo "OPTION 2: Configure Apache2 to use alternate ports"
    echo "  Keep Apache2 for Plesk panel but use different ports."
    echo ""
    echo "    # Edit Apache2 ports configuration"
    echo "    sudo nano /etc/apache2/ports.conf"
    echo "    # Change 'Listen 80' to 'Listen 8080'"
    echo "    # Change 'Listen 443' to 'Listen 8443'"
    echo ""
    echo "    # Restart Apache2"
    echo "    sudo systemctl restart apache2"
    echo ""
    
    echo "OPTION 3: Use Nginx as reverse proxy to Apache2"
    echo "  Configure Nginx to proxy certain requests to Apache2."
    echo "  This is more complex and typically not needed for this setup."
    echo ""

# Scenario 2: Plesk is installed
elif [ "$PLESK_INSTALLED" = true ]; then
    print_status "Scenario: Plesk is installed"
    echo ""
    echo "Plesk typically manages Apache2/Nginx together. Options:"
    echo ""
    echo "OPTION 1: Use Plesk's Nginx proxy mode"
    echo "  Configure Plesk to use Nginx as proxy to Apache2."
    echo ""
    echo "    # Access Plesk Panel"
    echo "    # Go to Tools & Settings > General Settings > Hosting Settings"
    echo "    # Select 'nginx as reverse proxy'"
    echo ""
    
    echo "OPTION 2: Disable Apache2 in Plesk"
    echo "  If you only want Nginx:"
    echo ""
    echo "    sudo /opt/psa/admin/sbin/nginxmng --disable"
    echo "    sudo systemctl stop apache2"
    echo "    sudo systemctl disable apache2"
    echo ""
    
    echo "OPTION 3: Reconfigure Plesk Apache2"
    echo "  Fix Apache2 configuration issues:"
    echo ""
    echo "    sudo /opt/psa/admin/sbin/httpdmng --reconfigure-all"
    echo ""

# Scenario 3: Only Apache2 installed
elif [ "$APACHE_INSTALLED" = true ] && [ "$NGINX_RUNNING" = false ]; then
    print_status "Scenario: Only Apache2 detected, Nginx not running"
    echo ""
    echo "To use Nginx as the primary web server:"
    echo ""
    echo "1. Install and configure Nginx (if not already done)"
    echo "2. Stop Apache2:"
    echo ""
    echo "    sudo systemctl stop apache2"
    echo "    sudo systemctl disable apache2"
    echo ""
    echo "3. Start Nginx:"
    echo ""
    echo "    sudo systemctl start nginx"
    echo "    sudo systemctl enable nginx"
    echo ""
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  QUICK FIX FOR CURRENT DEPLOYMENT"
echo "══════════════════════════════════════════════════════════════"
echo ""

print_status "For the current Nexus COS deployment using Nginx:"
echo ""
echo "1. Disable Apache2 (since Nginx handles all web traffic):"
echo ""
echo "   sudo systemctl stop apache2"
echo "   sudo systemctl disable apache2"
echo ""

echo "2. Verify Nginx is running:"
echo ""
echo "   sudo systemctl status nginx"
echo "   sudo nginx -t"
echo ""

echo "3. Restart Nginx if needed:"
echo ""
echo "   sudo systemctl restart nginx"
echo ""

echo "4. Verify all services:"
echo ""
echo "   pm2 status"
echo "   netstat -tlnp | grep -E ':80|:443|:3001|:3231|:3232|:3233|:3234'"
echo ""

print_warning "Note: The Apache2 warning is informational. If Nginx is working,"
print_warning "and all your services are accessible, you can safely ignore it"
print_warning "or disable Apache2 using the commands above."
echo ""

#!/bin/bash
# ==============================================================================
# PF Update Script - Usage Examples
# ==============================================================================
# This script demonstrates various ways to use pf-update-nginx-routes.sh
# ==============================================================================

set -euo pipefail

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   PF Update Script - Usage Examples                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ==============================================================================
# Example 1: Basic Usage
# ==============================================================================
echo "Example 1: Basic Usage (Default Configuration)"
echo "--------------------------------------------------------------"
echo "sudo ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "This will use the default container IPs:"
echo "  - Frontend: 172.20.0.14:3080"
echo "  - Puaboverse: 172.20.0.13:3060"
echo "  - Club Saditty: 172.20.0.15:3070"
echo ""

# ==============================================================================
# Example 2: Custom Container IPs
# ==============================================================================
echo "Example 2: Custom Container IPs"
echo "--------------------------------------------------------------"
echo "sudo FRONTEND_IP=\"172.20.0.10:3080\" \\"
echo "     PUABOVERSE_IP=\"172.20.0.11:3060\" \\"
echo "     CLUB_SADITTY_IP=\"172.20.0.12:3070\" \\"
echo "     ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "Override any or all container IPs as needed."
echo ""

# ==============================================================================
# Example 3: Custom Nginx Configuration Path
# ==============================================================================
echo "Example 3: Custom Nginx Configuration Path"
echo "--------------------------------------------------------------"
echo "sudo NGINX_CONF=\"/etc/nginx/sites-available/custom.conf\" \\"
echo "     ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "Useful when you have multiple nginx configurations."
echo ""

# ==============================================================================
# Example 4: Custom Domain
# ==============================================================================
echo "Example 4: Custom Domain Name"
echo "--------------------------------------------------------------"
echo "sudo DOMAIN=\"custom.example.com\" \\"
echo "     ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "Use a different domain name instead of the default n3xuscos.online."
echo ""

# ==============================================================================
# Example 5: Complete Custom Configuration
# ==============================================================================
echo "Example 5: Complete Custom Configuration"
echo "--------------------------------------------------------------"
echo "sudo FRONTEND_IP=\"192.168.1.10:8080\" \\"
echo "     PUABOVERSE_IP=\"192.168.1.11:8060\" \\"
echo "     CLUB_SADITTY_IP=\"192.168.1.12:8070\" \\"
echo "     NGINX_CONF=\"/etc/nginx/sites-available/nexus-custom.conf\" \\"
echo "     ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "Customize all settings at once."
echo ""

# ==============================================================================
# Example 5: Verification After Update
# ==============================================================================
echo "Example 5: Verification Commands"
echo "--------------------------------------------------------------"
echo "After running the script, verify your routes:"
echo ""
echo "# Check front-facing platform"
echo "curl -I https://n3xuscos.online/"
echo ""
echo "# Check Puaboverse health"
echo "curl -I https://n3xuscos.online/puaboverse/health"
echo ""
echo "# Check Club Saditty platform"
echo "curl -I https://n3xuscos.online/club-saditty/"
echo ""
echo "# View nginx configuration"
echo "sudo cat /etc/nginx/sites-available/nexus-cos.conf"
echo ""

# ==============================================================================
# Example 6: Backup Management
# ==============================================================================
echo "Example 6: Managing Backups"
echo "--------------------------------------------------------------"
echo "# List all backups"
echo "ls -lh /etc/nginx/backups/"
echo ""
echo "# Restore from a specific backup"
echo "sudo cp /etc/nginx/backups/nexus-cos_TIMESTAMP.conf \\"
echo "       /etc/nginx/sites-available/nexus-cos.conf"
echo "sudo nginx -t && sudo systemctl reload nginx"
echo ""

# ==============================================================================
# Example 7: Docker Container Verification
# ==============================================================================
echo "Example 7: Verify Docker Containers Before Running"
echo "--------------------------------------------------------------"
echo "# Check if containers are running"
echo "docker ps | grep -E '3080|3060|3070'"
echo ""
echo "# Test container connectivity"
echo "curl http://172.20.0.14:3080/"
echo "curl http://172.20.0.13:3060/health"
echo "curl http://172.20.0.15:3070/"
echo ""

# ==============================================================================
# Example 9: Production Deployment
# ==============================================================================
echo "Example 9: Production Deployment Workflow"
echo "--------------------------------------------------------------"
echo "# 1. Verify containers are running"
echo "docker ps"
echo ""
echo "# 2. Test container endpoints"
echo "curl http://172.20.0.14:3080/"
echo ""
echo "# 3. Run the update script"
echo "sudo ./scripts/pf-update-nginx-routes.sh"
echo ""
echo "# 4. Verify all routes are working"
echo "curl -I https://n3xuscos.online/"
echo "curl -I https://n3xuscos.online/puaboverse/health"
echo "curl -I https://n3xuscos.online/club-saditty/"
echo ""
echo "# 5. Check nginx logs for any issues"
echo "sudo tail -f /var/log/nginx/access.log"
echo ""

# ==============================================================================
# Example 10: Quick Health Check
# ==============================================================================
echo "Example 10: Quick Health Check"
echo "--------------------------------------------------------------"
echo "# Check if Nginx is running"
echo "sudo systemctl status nginx"
echo ""
echo "# Test current Nginx configuration"
echo "sudo nginx -t"
echo ""
echo "# View current configuration"
echo "sudo cat /etc/nginx/sites-available/nexus-cos.conf"
echo ""

# ==============================================================================
# Example 10: Troubleshooting
# ==============================================================================
echo "Example 10: Troubleshooting Commands"
echo "--------------------------------------------------------------"
echo "# View recent backups"
echo "ls -lt /etc/nginx/backups/ | head -5"
echo ""
echo "# Check Nginx error logs"
echo "sudo tail -50 /var/log/nginx/error.log"
echo ""
echo "# Test Nginx configuration syntax"
echo "sudo nginx -t"
echo ""
echo "# Restart Nginx if needed"
echo "sudo systemctl restart nginx"
echo ""

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║   For more information, see:                                   ║"
echo "║   scripts/README_PF_UPDATE_NGINX.md                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"

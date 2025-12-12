#!/bin/bash
# Direct Apache configuration fix - no heredoc issues
# Run with: sudo bash fix-apache-direct.sh

set -e

echo "Creating Apache configuration for V-Suite Hollywood..."

# Create the config file directly
cat > /etc/apache2/conf-available/nexuscos-hollywood.conf << 'ENDOFCONFIG'
# V-Suite Hollywood Apache Configuration
<IfModule mod_proxy.c>
    # HTTP requests to vscreen-hollywood service
    <Location /v-suite/hollywood>
        ProxyPreserveHost On
        ProxyPass http://127.0.0.1:8088/
        ProxyPassReverse http://127.0.0.1:8088/
        
        # CORS headers
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
        Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
    </Location>
    
    # WebSocket support
    <Location /v-suite/hollywood/ws>
        ProxyPass ws://127.0.0.1:8088/ws
        ProxyPassReverse ws://127.0.0.1:8088/ws
        ProxyPreserveHost On
    </Location>
</IfModule>
ENDOFCONFIG

echo "✓ Configuration file created"

# Enable required modules
echo "Enabling Apache modules..."
a2enmod proxy proxy_http proxy_wstunnel headers rewrite 2>/dev/null || true

# Enable the configuration
echo "Enabling configuration..."
a2enconf nexuscos-hollywood

# Test configuration
echo "Testing Apache configuration..."
if apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo "✓ Configuration is valid"
else
    echo "✗ Configuration has errors:"
    apache2ctl configtest
    exit 1
fi

# Reload Apache
echo "Reloading Apache..."
systemctl reload apache2 2>/dev/null || service apache2 reload 2>/dev/null || apache2ctl -k graceful

# Wait a moment
sleep 2

# Test the endpoint
echo ""
echo "Testing endpoint..."
STATUS=$(curl -sk -o /dev/null -w '%{http_code}' https://nexuscos.online/v-suite/hollywood/ 2>/dev/null || echo "000")

echo ""
echo "=========================================="
echo "Result: $STATUS"
echo "=========================================="

if [ "$STATUS" = "200" ]; then
    echo "✓ SUCCESS - Apache 404 error is FIXED!"
    echo ""
    echo "Page is now accessible at:"
    echo "  https://nexuscos.online/v-suite/hollywood/"
elif [ "$STATUS" = "404" ]; then
    echo "✗ Still getting 404"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check if vscreen-hollywood is running:"
    echo "   pm2 list | grep vscreen"
    echo ""
    echo "2. Test direct connection:"
    echo "   curl http://localhost:8088/"
    echo ""
    echo "3. Check Apache config:"
    echo "   cat /etc/apache2/conf-available/nexuscos-hollywood.conf"
    echo ""
    echo "4. Check Apache error logs:"
    echo "   tail -20 /var/log/apache2/error.log"
else
    echo "⚠ Unexpected status: $STATUS"
fi

echo ""
echo "Configuration file location:"
echo "  /etc/apache2/conf-available/nexuscos-hollywood.conf"

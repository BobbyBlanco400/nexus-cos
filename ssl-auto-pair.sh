#!/bin/bash
# ==============================================================================
# Nexus COS — SSL Auto-Pair Script
# ==============================================================================
# Purpose: Automatically align certificate and private key by modulus matching
# Target: PF Gateway configuration for n3xuscos.online
# ==============================================================================

set -e

DOMAIN="${DOMAIN:-n3xuscos.online}"
PF="/etc/nginx/conf.d/pf_gateway_${DOMAIN}.conf"

echo "═══════════════════════════════════════════════════════════════"
echo "  SSL AUTO-PAIR FOR PF GATEWAY"
echo "  Domain: $DOMAIN"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if PF gateway config exists
if [ ! -f "$PF" ]; then
    echo "Error: PF gateway config not found at $PF"
    echo "Please ensure the gateway configuration file exists."
    exit 1
fi

echo "Step 1: Locating certificate in PF gateway config..."
PF_CERT=$(grep -m1 -oE '/opt/psa/var/certificates/\w+' "$PF" | head -n1)

# Fallback to default certificate if not found
if [ -z "$PF_CERT" ]; then
    echo "Warning: Certificate path not found in config, using default..."
    PF_CERT="/opt/psa/var/certificates/scf5ua7fcdlp5a32xQtdjN"
fi

if [ ! -f "$PF_CERT" ]; then
    echo "Error: Certificate file not found at $PF_CERT"
    exit 1
fi

echo "✓ Found certificate: $PF_CERT"

echo ""
echo "Step 2: Calculating certificate modulus..."
CMOD=$(openssl x509 -noout -modulus -in "$PF_CERT" 2>/dev/null | openssl md5 | awk '{print $2}')

if [ -z "$CMOD" ]; then
    echo "Error: Failed to calculate certificate modulus"
    exit 1
fi

echo "✓ Certificate modulus MD5: $CMOD"

echo ""
echo "Step 3: Searching for matching private key..."
MATCH_KEY=""
for f in /opt/psa/var/certificates/*; do
    if [ -f "$f" ]; then
        KMOD=$(openssl rsa -noout -modulus -in "$f" 2>/dev/null | openssl md5 2>/dev/null | awk '{print $2}')
        if [ "$KMOD" = "$CMOD" ]; then
            MATCH_KEY="$f"
            echo "✓ Found matching private key: $MATCH_KEY"
            break
        fi
    fi
done

if [ -z "$MATCH_KEY" ]; then
    echo "Error: No matching private key found in /opt/psa/var/certificates/"
    echo "This means the certificate and key may be mismatched or the key is not in the expected location."
    exit 1
fi

echo ""
echo "Step 4: Updating PF gateway configuration..."

# Backup the current config
BACKUP_FILE="$PF.backup-$(date +%F-%H%M%S)"
cp -f "$PF" "$BACKUP_FILE"
echo "✓ Created backup of current configuration"

# Update certificate and key paths
sed -i -E "s#^\s*ssl_certificate\s+.*;#    ssl_certificate $PF_CERT;#" "$PF"
sed -i -E "s#^\s*ssl_certificate_key\s+.*;#    ssl_certificate_key $MATCH_KEY;#" "$PF"
echo "✓ Updated ssl_certificate and ssl_certificate_key directives"

echo ""
echo "Step 5: Testing nginx configuration..."
if nginx -t; then
    echo "✓ Nginx configuration is valid"
else
    echo "Error: Nginx configuration test failed"
    echo "Restoring backup..."
    cp -f "$BACKUP_FILE" "$PF"
    exit 1
fi

echo ""
echo "Step 6: Restarting nginx..."
if systemctl restart nginx 2>/dev/null || service nginx restart 2>/dev/null; then
    echo "✓ Nginx restarted successfully"
else
    echo "Error: Failed to restart nginx"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  SSL AUTO-PAIR COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Certificate: $PF_CERT"
echo "Private Key: $MATCH_KEY"
echo "Modulus MD5: $CMOD"
echo ""
echo "The certificate and private key are now properly paired in:"
echo "  $PF"
echo ""

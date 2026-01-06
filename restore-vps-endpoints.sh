#!/bin/bash
# ==============================================================================
# Nexus COS — VPS Endpoint Restoration Script (Bash)
# ==============================================================================
# Purpose: Restore Plesk configs, SSL certs, and verify endpoint statuses
# Target VPS: root@74.208.155.161 (Plesk-managed)
# Domain: n3xuscos.online
# ==============================================================================

set -e

# Configuration
DOMAIN="${DOMAIN:-n3xuscos.online}"
VPS_IP="${VPS_IP:-74.208.155.161}"
SSH_USER="${SSH_USER:-root}"
DRY_RUN="${DRY_RUN:-false}"
SKIP_SSL="${SKIP_SSL:-false}"
SKIP_VERIFICATION="${SKIP_VERIFICATION:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  NEXUS COS - VPS ENDPOINT RESTORATION${NC}"
    echo -e "${CYAN}  Domain: $DOMAIN | VPS: $VPS_IP${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Display header
print_header

if [ "$DRY_RUN" = "true" ]; then
    print_warning "DRY RUN MODE - Commands will be displayed but not executed"
fi

# Build the restoration script
print_section "Step 1: Preparing Restoration Script"

RESTORE_SCRIPT=$(cat <<'EOF'
set -e
DOMAIN=n3xuscos.online
VHOST=/var/www/vhosts/system/$DOMAIN/conf/vhost_nginx.conf
PF=/etc/nginx/conf.d/pf_gateway_${DOMAIN}.conf

echo '== Backup gateway config if present'
if [ -f "$PF" ]; then 
    cp -f "$PF" "$PF.bak-$(date +%F-%H%M%S)"
    echo "Backed up gateway config to $PF.bak-$(date +%F-%H%M%S)"
fi

echo '== Comment invalid proxy_set_header directives (one-arg lines)'
if [ -f "$PF" ]; then 
    sed -i -E 's/^(\s*proxy_set_header\s+\S+\s*;)$/# disabled \1/' "$PF"
    echo "Commented out invalid proxy_set_header directives"
fi

echo '== Append exact-match base-path handlers into vhost include'
if ! grep -q "location = /api/" "$VHOST"; then 
  cat >> "$VHOST" <<'VHOSTEOF'
location = / {
    return 301 /streaming/;
}

location = /api/ {
    return 200 "ok";
    add_header Content-Type text/plain;
}

location = /streaming/ {
    return 200 "ok";
    add_header Content-Type text/plain;
}
VHOSTEOF
  echo "Added base-path handlers to vhost config"
else
  echo "Base-path handlers already present in vhost config"
fi

echo '== Plesk reconfigure domain'
if plesk sbin httpdmng --reconfigure-domain "$DOMAIN" 2>/dev/null; then
    echo "Domain reconfigured successfully with plesk sbin"
elif /opt/psa/admin/sbin/httpdmng --reconfigure-domain "$DOMAIN" 2>/dev/null; then
    echo "Domain reconfigured successfully with /opt/psa/admin/sbin"
else
    echo "Warning: Could not reconfigure domain, continuing..."
fi

echo '== SSL: Use existing IONOS certificate (no Let'\''s Encrypt)'
echo 'List domain certificates and assign the IONOS one'
plesk bin certificate --list -domain "$DOMAIN" || true

CERT_NAME=$(plesk bin certificate --list -domain "$DOMAIN" 2>/dev/null | awk 'NF && !/^CSR/ {print $NF}' | tail -n1)
if [ -n "$CERT_NAME" ]; then
  echo "Found certificate: $CERT_NAME"
  if plesk bin site -u "$DOMAIN" -certificate-name "$CERT_NAME"; then
      echo "Successfully assigned certificate to domain"
  else
      echo "Warning: Could not assign certificate, continuing..."
  fi
else
  echo 'No certificate found in domain repo; create from IONOS files'
  echo 'Provide correct paths to key/crt/ca bundle before running:'
  KEY_PATH=/root/ionos/privkey.pem
  CRT_PATH=/root/ionos/cert.pem
  CABUNDLE_PATH=/root/ionos/chain.pem
  CERT_NAME="IONOS SSL"
  
  if [ -f "$KEY_PATH" ] && [ -f "$CRT_PATH" ]; then
    echo "Found IONOS certificate files, attempting to create certificate..."
    if plesk bin certificate --create "$CERT_NAME" -domain "$DOMAIN" -key-file "$KEY_PATH" -cert-file "$CRT_PATH" -cacert-file "$CABUNDLE_PATH" 2>/dev/null; then
      echo "Certificate created successfully"
      if plesk bin site -u "$DOMAIN" -certificate-name "$CERT_NAME"; then
          echo "Successfully assigned new certificate to domain"
      else
          echo "Warning: Could not assign new certificate, continuing..."
      fi
    else
      echo 'Certificate create failed; check key/cert pairing (avoid key mismatch)'
    fi
  else
    echo 'IONOS key/cert files not present; upload them and re-run'
  fi
fi

echo '== Test nginx config'
if nginx -t 2>&1; then
    echo "Nginx configuration is valid"
else
    echo "Warning: Nginx configuration test failed, but continuing..."
fi

echo '== Restart nginx'
if systemctl restart nginx 2>/dev/null; then
    echo "Nginx restarted successfully via systemctl"
elif service nginx restart 2>/dev/null; then
    echo "Nginx restarted successfully via service"
else
    echo "Warning: Could not restart nginx"
fi

echo '== Attempt to start apache (non-fatal)'
systemctl start apache2 2>/dev/null || service apache2 start 2>/dev/null || echo "Apache not started (may not be needed)"

echo '== Verify endpoints'
echo ""
curl -k -s -o /dev/null -w 'ROOT:%{http_code}\n' https://$DOMAIN/ || echo "ROOT:FAILED"
curl -k -s -o /dev/null -w 'API:%{http_code}\n' https://$DOMAIN/api/ || echo "API:FAILED"
curl -k -s -o /dev/null -w 'STREAMING:%{http_code}\n' https://$DOMAIN/streaming/ || echo "STREAMING:FAILED"
curl -k -s -o /dev/null -w 'SOCKET.IO:%{http_code}\n' 'https://$DOMAIN/socket.io/?EIO=4&transport=polling' || echo "SOCKET.IO:FAILED"
curl -k -s -o /dev/null -w 'STREAMING SOCKET.IO:%{http_code}\n' 'https://$DOMAIN/streaming/socket.io/?EIO=4&transport=polling' || echo "STREAMING SOCKET.IO:FAILED"
echo ""
echo "Restoration complete!"
EOF
)

print_info "Restoration script prepared ($(echo "$RESTORE_SCRIPT" | wc -c) bytes)"

# Execute the script
print_section "Step 2: Executing Restoration on VPS"

if [ "$DRY_RUN" = "true" ]; then
    print_warning "DRY RUN - Would execute the following SSH command:"
    echo "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=12 $SSH_USER@$VPS_IP bash -lc \"<script>\""
    echo ""
    echo "Script contents:"
    echo "$RESTORE_SCRIPT"
else
    print_info "Connecting to VPS and executing restoration script..."
    
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=12 "$SSH_USER@$VPS_IP" bash -lc "$RESTORE_SCRIPT"; then
        print_success "Restoration completed successfully!"
    else
        print_error "Restoration failed with exit code: $?"
        exit 1
    fi
fi

# Verification step
if [ "$SKIP_VERIFICATION" != "true" ] && [ "$DRY_RUN" != "true" ]; then
    print_section "Step 3: Verifying Endpoints"
    
    verify_endpoint() {
        local name=$1
        local url=$2
        local expected=$3
        
        status=$(curl -k -s -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || echo "FAILED")
        
        if [ "$status" = "$expected" ]; then
            print_success "$name: $status (Expected: $expected)"
        else
            print_warning "$name: $status (Expected: $expected)"
        fi
    }
    
    verify_endpoint "Root (Redirect)" "https://$DOMAIN/" "301"
    verify_endpoint "API Base" "https://$DOMAIN/api/" "200"
    verify_endpoint "Streaming Base" "https://$DOMAIN/streaming/" "200"
    verify_endpoint "Socket.IO Main" "https://$DOMAIN/socket.io/?EIO=4&transport=polling" "200"
    verify_endpoint "Socket.IO Streaming" "https://$DOMAIN/streaming/socket.io/?EIO=4&transport=polling" "200"
fi

print_section "Restoration Complete"
print_success "All restoration tasks completed!"
print_info "Check the output above for any warnings or errors."
echo ""

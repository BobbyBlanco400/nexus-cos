#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo "🚀 NEXUS COS — PRODUCTION LAUNCH GATE"
echo "=============================================="

DOMAIN="nexuscos.online"
API_LOCAL="http://127.0.0.1:3000/status"
API_PUBLIC="https://${DOMAIN}/api/status"
LOG_BACKEND="/var/log/nexus-cos.log"
LOG_NGINX="/var/log/nginx/error.log"

fail() { echo "❌ LAUNCH GATE FAILED: $1"; exit 1; }
pass() { echo "✅ $1"; }

# --- Active vhost check (SAFE with set -e) ---
if nginx -T | grep -q "server_name ${DOMAIN}"; then
  pass "Active vhost confirmed"
else
  fail "Active vhost missing"
fi

# --- NGINX validation ---
nginx -t
systemctl reload nginx
pass "NGINX validated and reloaded"

# --- Backend local health ---
curl -sf "${API_LOCAL}" >/dev/null
pass "Backend responding locally"

# --- Public API health ---
STATUS=$(curl -sk -o /dev/null -w "%{http_code}" "${API_PUBLIC}")
[ "$STATUS" = "200" ] || fail "Public API proxy returned ${STATUS}"
pass "Public API proxy OK (HTTP ${STATUS})"

# --- HTTP/2 verification (CORRECT METHOD) ---
HTTP_VER=$(curl -sk -o /dev/null -w "%{http_version}" "${API_PUBLIC}")
[ "$HTTP_VER" = "2" ] || fail "HTTP/2 not active (got HTTP/${HTTP_VER})"
pass "HTTP/2 active"

echo "=============================================="
echo "🎉 NEXUS COS STATUS: ✅ PRODUCTION GREEN"
echo "=============================================="
exit 0

#!/usr/bin/env bash
set -euo pipefail

HANDSHAKE="55-45-17"

echo "================================================================="
echo " N3XUS v-COS • Hostinger VPS Launch"
echo " Handshake ${HANDSHAKE}"
echo "================================================================="

COMPOSE_FILE="docker-compose.yml"
if [ -f "docker-compose.codespaces.yml" ]; then
  COMPOSE_FILE="docker-compose.codespaces.yml"
fi

echo "[1/4] Bringing stack up with ${COMPOSE_FILE}..."
docker-compose -f "${COMPOSE_FILE}" down --remove-orphans || true
docker-compose -f "${COMPOSE_FILE}" up -d --build

echo "[2/4] Waiting for services to warm up..."
sleep 30

check() {
  name="$1"
  port="$2"
  url="http://localhost:${port}/health"
  echo "→ Checking ${name} on ${url}"
  if curl -fsS -H "X-N3XUS-Handshake: ${HANDSHAKE}" "$url" >/dev/null; then
    echo "✅ ${name} healthy"
  else
    echo "❌ ${name} failed health check"
    exit 1
  fi
}

echo "[3/4] Verifying core services with N3XUS Handshake ${HANDSHAKE}..."
check "v-supercore" 3001
check "puabo_api_ai_hf" 3002
check "holofabric-runtime" 3700

echo "[4/4] Writing notarization record..."
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
OUT="LAUNCH_NOTARIZED_VPS.txt"

{
  echo "N3XUS v-COS VPS Launch"
  echo "Timestamp (UTC): ${TS}"
  echo "Handshake: ${HANDSHAKE}"
  if [ -f pf-master.yaml ]; then
    sha256sum pf-master.yaml
  else
    echo "pf-master.yaml not found"
  fi
  if [ -f nginx.conf ]; then
    sha256sum nginx.conf
  else
    echo "nginx.conf not found"
  fi
} > "${OUT}"

echo "================================================================="
echo " N3XUS v-COS LAUNCH COMPLETE ON VPS"
echo " Services:"
echo "  - v-supercore:        http://localhost:3001/health"
echo "  - puabo_api_ai_hf:    http://localhost:3002/health"
echo "  - holofabric-runtime: http://localhost:3700/health"
echo " Handshake ${HANDSHAKE} enforced on all checks."
echo " Notarization file: ${OUT}"
echo "================================================================="


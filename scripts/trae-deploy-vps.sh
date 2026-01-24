#!/usr/bin/env bash
set -euo pipefail

# scripts/trae-deploy-vps.sh
# Helper for manual deploy to sovereign VPS.
# Environment variables required:
#   SSH_USER, SSH_HOST, SSH_PORT (optional, default 22), REMOTE_PATH

SSH_USER=${SSH_USER:-}
SSH_HOST=${SSH_HOST:-}
SSH_PORT=${SSH_PORT:-22}
REMOTE_PATH=${REMOTE_PATH:-/opt/n3xus/phase5}
LOCAL_PACKAGE=${LOCAL_PACKAGE:-deploy/phase5-deploy-package.tar.gz}

if [ -z "$SSH_USER" ] || [ -z "$SSH_HOST" ]; then
  echo "ERROR: SSH_USER and SSH_HOST must be set"
  exit 2
fi

if [ ! -f "$LOCAL_PACKAGE" ]; then
  echo "ERROR: Deploy package not found at $LOCAL_PACKAGE"
  exit 3
fi

echo "Deploying $LOCAL_PACKAGE to $SSH_USER@$SSH_HOST:$REMOTE_PATH"
rsync -avz -e "ssh -p $SSH_PORT" "$LOCAL_PACKAGE" "$SSH_USER@$SSH_HOST:$REMOTE_PATH/"

ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" bash -s <<'EOF'
set -e
REMOTE_PATH="${REMOTE_PATH:-/opt/n3xus/phase5}"
mkdir -p "$REMOTE_PATH"
tar -xzf "$REMOTE_PATH/phase5-deploy-package.tar.gz" -C "$REMOTE_PATH" || true
if [ -f "$REMOTE_PATH/bootstrap.sh" ]; then
  chmod +x "$REMOTE_PATH/bootstrap.sh"
  nohup bash "$REMOTE_PATH/bootstrap.sh" > "$REMOTE_PATH/bootstrap.log" 2>&1 &
fi
echo "Deploy executed on remote host. Check $REMOTE_PATH/bootstrap.log"
EOF

echo "Deploy complete. Check remote logs for status."
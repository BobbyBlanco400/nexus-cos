#!/usr/bin/env bash
set -euo pipefail

echo "=== N3XUS v-COS • MASTER VPS LAUNCH (GitHub Codespaces) ==="

if [ -z "${N3XUS_VPS_SSH_PRIVATE_KEY:-}" ]; then
  echo "ERROR: N3XUS_VPS_SSH_PRIVATE_KEY env var is not set."
  exit 1
fi

VPS_HOST="${N3XUS_VPS_HOST:-n3xuscos.online}"
VPS_USER="${N3XUS_VPS_USER:-root}"
VPS_TARGET_DIR="${N3XUS_VPS_TARGET_DIR:-/var/www/nexus-cos}"
BRANCH="${BRANCH:-main}"
ENVIRONMENT_LABEL="${ENVIRONMENT_LABEL:-production}"

REPO_URL="$(git config --get remote.origin.url || true)"
if [[ -z "$REPO_URL" ]]; then
  echo "ERROR: Could not detect git remote origin URL. Run this inside a cloned repo."
  exit 1
fi

if [[ "$REPO_URL" =~ github.com[:/]+([^/]+)/([^/.]+) ]]; then
  REPO_OWNER="${BASH_REMATCH[1]}"
  REPO_NAME="${BASH_REMATCH[2]}"
else
  echo "ERROR: Unable to parse repository owner/name from: $REPO_URL"
  exit 1
fi

REPO="${REPO_OWNER}/${REPO_NAME}"

echo "→ Target repo: ${REPO}"
echo "→ VPS host:    ${VPS_USER}@${VPS_HOST}"
echo "→ VPS dir:     ${VPS_TARGET_DIR}"
echo "→ Branch:      ${BRANCH}"
echo "→ Environment: ${ENVIRONMENT_LABEL}"
echo ""

if ! command -v gh >/dev/null 2>&1; then
  echo "→ gh (GitHub CLI) not found; installing..."
  if ! command -v curl >/dev/null 2>&1; then
    echo "→ Installing curl..."
    sudo apt-get update && sudo apt-get install -y curl
  fi

  TMPDIR="$(mktemp -d)"
  GH_TAR="$TMPDIR/gh.tar.gz"
  echo "→ Downloading gh..."
  curl -fsSL "https://github.com/cli/cli/releases/latest/download/gh_latest_linux_amd64.tar.gz" -o "$GH_TAR"

  tar -xzf "$GH_TAR" -C "$TMPDIR"
  sudo mv "$TMPDIR"/gh_*/bin/gh /usr/local/bin/gh
  rm -rf "$TMPDIR"
fi

echo "→ Authenticating gh (expects GITHUB_TOKEN env or interactive auth)..."
if ! gh auth status >/dev/null 2>&1; then
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo "${GITHUB_TOKEN}" | gh auth login --with-token >/dev/null 2>&1 || {
      echo "ERROR: gh login with GITHUB_TOKEN failed."
      exit 1
    }
  else
    echo "No GITHUB_TOKEN found; attempting interactive gh auth login..."
    gh auth login || {
      echo "ERROR: gh interactive auth failed."
      exit 1
    }
  fi
fi

echo "→ Setting GitHub Actions secrets for VPS deployment in ${REPO}..."
printf '%s' "${N3XUS_VPS_SSH_PRIVATE_KEY}" | gh secret set VPS_SSH_PRIVATE_KEY -R "${REPO}" -b-
gh secret set VPS_HOST       -R "${REPO}" -b "${VPS_HOST}"
gh secret set VPS_USER       -R "${REPO}" -b "${VPS_USER}"
gh secret set VPS_TARGET_DIR -R "${REPO}" -b "${VPS_TARGET_DIR}"

echo "→ Confirming 'VPS Deploy - N3XUS v-COS' workflow exists..."
if ! gh workflow list -R "${REPO}" | grep -i "VPS Deploy - N3XUS v-COS" >/dev/null 2>&1; then
  echo "ERROR: Workflow 'VPS Deploy - N3XUS v-COS' not found in ${REPO}."
  exit 1
fi

echo "→ Triggering 'vps-deploy.yml' workflow on branch ${BRANCH}..."
gh workflow run "vps-deploy.yml" \
  -R "${REPO}" \
  --ref "${BRANCH}" \
  -f environment="${ENVIRONMENT_LABEL}"

echo "→ Waiting a short moment for the run to be scheduled..."
sleep 8

RUN_ID="$(gh run list -R "${REPO}" \
  --workflow "vps-deploy.yml" \
  --limit 1 \
  --json databaseId \
  -q '.[0].databaseId' || true)"

if [ -z "${RUN_ID:-}" ]; then
  echo "ERROR: Could not obtain run ID for vps-deploy workflow. Check Actions UI."
  exit 1
fi

echo "→ Streaming logs for run ${RUN_ID}..."
gh run watch "${RUN_ID}" -R "${REPO}" --exit-status
EXIT_STATUS=$?

if [ $EXIT_STATUS -eq 0 ]; then
  echo ""
  echo "=== N3XUS v-COS • VPS DEPLOYMENT SUCCESS (workflow finished) ==="
  echo "Look for artifact: 'vps-launch-notarization' (LAUNCH_NOTARIZED_VPS.txt) in the workflow run."
else
  echo ""
  echo "=== N3XUS v-COS • VPS DEPLOYMENT FAILURE (workflow finished with errors) ==="
  echo "Open the Actions run ${RUN_ID} in the repository ${REPO} and inspect failing steps."
fi

exit $EXIT_STATUS


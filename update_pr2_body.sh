#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
git checkout feature/phase3-4-launch
git pull origin feature/phase3-4-launch
gh pr edit 2 --body-file PR_72HOUR_CODESPACES_LAUNCH.md
gh pr view 2 --web
echo "CINEMATIC PREVIEW URL:"
echo "https://htmlpreview.github.io/?https://raw.githubusercontent.com/BobbyBlanco400/N3XUS-vCOS/feature/phase3-4-launch/promo/N3XUS_PRELAUNCH.html"
echo "FOUNDERS CTA (CANONICAL, HARD-LOCKED):"
echo "https://beta.n3xuscos.online/?utm_source=founders_video&utm_medium=cta&utm_campaign=72h_codespaces_launch"


#!/usr/bin/env bash
set -euo pipefail

if command -v python3 >/dev/null 2>&1; then
  python3 nexus_cos_master_pipeline.py --fast
else
  python nexus_cos_master_pipeline.py --fast
fi

urls=(
  "https://n3xuscos.online"
  "https://n3xuscos.online/health"
  "https://n3xuscos.online/nexus-stream"
  "https://n3xuscos.online/nexus-ott"
  "https://n3xuscos.online/nexusnet"
  "https://n3xuscos.online/nexus-link"
  "https://n3xuscos.online/puaboverse"
  "https://n3xuscos.online/puaboverse/games/slots.html"
  "https://n3xuscos.online/puaboverse/games/table.html"
  "https://n3xuscos.online/puaboverse/games/live.html"
  "https://n3xuscos.online/puaboverse/vr-casino.html"
  "https://n3xuscos.online/puaboverse/vip.html"
  "https://n3xuscos.online/puaboverse/jackpots.html"
  "https://n3xuscos.online/puaboverse/tournaments.html"
  "https://n3xuscos.online/puaboverse/rewards.html"
  "https://n3xuscos.online/puaboverse/marketplace.html"
  "https://n3xuscos.online/tv"
  "https://n3xuscos.online/radio"
  "https://n3xuscos.online/sports"
  "https://n3xuscos.online/news"
  "https://n3xuscos.online/studio"
  "https://n3xuscos.online/live-manager"
  "https://n3xuscos.online/templates"
  "https://n3xuscos.online/library"
  "https://n3xuscos.online/talk-show"
  "https://n3xuscos.online/game-show"
  "https://n3xuscos.online/club-saditty"
  "https://n3xuscos.online/faith-through-fitness"
  "https://n3xuscos.online/ashantis-munch"
  "https://n3xuscos.online/roro-gaming"
  "https://n3xuscos.online/idh-live"
  "https://n3xuscos.online/clocking-t"
  "https://n3xuscos.online/tyshawn-dance"
  "https://n3xuscos.online/fayeloni"
  "https://n3xuscos.online/sassie-lashes"
  "https://n3xuscos.online/neenee-kids"
  "https://n3xuscos.online/headwinas-comedy"
  "https://n3xuscos.online/rise-sacramento-916"
  "https://n3xuscos.online/gas-or-crash-live"
  "https://n3xuscos.online/v-suite"
  "https://n3xuscos.online/v-suite/vscreen-hollywood"
  "https://n3xuscos.online/v-suite/vstage"
  "https://n3xuscos.online/v-suite/vprompter-pro"
  "https://n3xuscos.online/v-suite/vcaster-pro"
  "https://n3xuscos.online/ai/script"
  "https://n3xuscos.online/ai/moderate"
  "https://n3xuscos.online/ai/voice"
  "https://n3xuscos.online/ai/scene"
  "https://n3xuscos.online/ai/metadata"
  "https://n3xuscos.online/analytics/audience"
  "https://n3xuscos.online/analytics/revenue"
  "https://n3xuscos.online/analytics/creator"
  "https://n3xuscos.online/nexus-ai"
  "https://n3xuscos.online/nexus-ai/health"
)

fail=0

for u in "${urls[@]}"; do
  code=$(curl -k -o /dev/null -s -w "%{http_code}" "$u" || echo "000")
  printf "%s %s\n" "$code" "$u"
  case "$code" in
    200|201|202|204|301|302) ;;
    *) fail=1 ;;
  esac
done

exit "$fail"


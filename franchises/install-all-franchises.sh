#!/usr/bin/env bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " NEXUS COS | FRANCHISE MASTER INSTALLER"
echo " INSTALLING ALL FRANCHISES FOR NEXUS COS INTEGRATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "Starting franchise installation process..."
echo ""

# -------------------------------------
# INSTALL RICO FRANCHISE
# -------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INSTALLING: RICO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/install-rico.sh"
echo ""

# -------------------------------------
# INSTALL HIGH STAKES FRANCHISE
# -------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INSTALLING: HIGH STAKES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/install-high-stakes.sh"
echo ""

# -------------------------------------
# INSTALL DA YAY FRANCHISE
# -------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " INSTALLING: DA YAY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPT_DIR/install-da-yay.sh"
echo ""

# -------------------------------------
# GENERATE MASTER REGISTRY
# -------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " GENERATING MASTER FRANCHISE REGISTRY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

NEXUS_ROOT="/opt/nexus-cos"
REGISTRY_FILE="$NEXUS_ROOT/franchises/franchise-registry.json"

mkdir -p "$NEXUS_ROOT/franchises"

cat <<EOF > "$REGISTRY_FILE"
{
  "nexus_cos_franchise_registry": {
    "version": "1.0.0",
    "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "total_franchises": 3,
    "franchises": [
      {
        "id": "rico-001",
        "title": "RICO",
        "type": "scripted_webtv",
        "status": "registered",
        "path": "$NEXUS_ROOT/franchises/rico",
        "launch_target": "2026-01-01"
      },
      {
        "id": "high-stakes-001",
        "title": "High Stakes",
        "type": "crime_thriller",
        "status": "registered",
        "path": "$NEXUS_ROOT/franchises/high-stakes",
        "launch_target": "2026-01-01"
      },
      {
        "id": "da-yay-001",
        "title": "Da Yay",
        "type": "urban_crime_epic",
        "status": "flagship",
        "path": "$NEXUS_ROOT/franchises/da-yay",
        "launch_target": "2026-01-01"
      }
    ],
    "pipeline_targets": [
      "nexus_studio",
      "nexus_stream",
      "nexus_franchiser",
      "puabo_dsp"
    ],
    "capabilities": {
      "text_to_video": true,
      "ai_generation": true,
      "short_films": true,
      "web_series": true,
      "trailers": true,
      "regional_expansion": true,
      "music_integration": true,
      "licensing": true
    }
  }
}
EOF

echo "✔ Master franchise registry created at: $REGISTRY_FILE"
echo ""

# -------------------------------------
# FINAL SUMMARY
# -------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " FRANCHISE INSTALLATION COMPLETE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✔ RICO - Legal thriller, 13 episodes + short film"
echo "✔ HIGH STAKES - Urban crime thriller, 8 episodes + 45min pilot"
echo "✔ DA YAY - Bay Area flagship, 13 episodes + regional expansion"
echo ""
echo "All franchises are now:"
echo "  • Registered in Nexus COS"
echo "  • Pipeline-injected"
echo "  • AI-generation ready"
echo "  • Launch-ready for 2026-01-01"
echo ""
echo "Master registry: $REGISTRY_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

#!/usr/bin/env bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " NEXUS COS | FRANCHISER MASTER PF"
echo " PROJECT: HIGH STAKES"
echo " MODE: Short Film + WebTV Series"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# -------------------------------------
# 1. CORE PATHS
# -------------------------------------
NEXUS_ROOT="/opt/nexus-cos"
FRANCHISE_DIR="$NEXUS_ROOT/franchises/high-stakes"
CONTENT_DIR="$FRANCHISE_DIR/content"
PIPELINE_DIR="$FRANCHISE_DIR/pipeline"
PROMPT_DIR="$FRANCHISE_DIR/prompts"
SHORTFILM_DIR="$FRANCHISE_DIR/shortfilm"
SERIES_DIR="$CONTENT_DIR/series"

mkdir -p \
  "$CONTENT_DIR/bible" \
  "$SERIES_DIR/episodes" \
  "$PIPELINE_DIR" \
  "$PROMPT_DIR" \
  "$SHORTFILM_DIR"

echo "✔ Franchise directories created"

# -------------------------------------
# 2. FRANCHISE REGISTRATION
# -------------------------------------
cat <<EOF > "$FRANCHISE_DIR/franchise-high-stakes.yaml"
franchise:
  id: high-stakes-001
  title: High Stakes
  type: crime_thriller
  format:
    - short_film
    - scripted_webtv
  genre:
    - urban_thriller
    - psychological_crime
  setting: Bay Area, California
  creator: Bobby Blanco
  owner: PUABO Music -N- Media Group
  launch_target: "2026-01-01"
  monetization:
    enabled: true
    licensing: true
    franchising: true
  status:
    production_ready: true
    launch_blocker: false
EOF

echo "✔ Franchise registered"

# -------------------------------------
# 3. SHORT FILM PILOT MANIFEST
# -------------------------------------
cat <<EOF > "$SHORTFILM_DIR/high-stakes-pilot.json"
{
  "title": "High Stakes",
  "format": "Short Film",
  "runtime_minutes": 45,
  "purpose": [
    "proof_of_concept",
    "festival_submission",
    "series_launch"
  ],
  "acts": 4,
  "status": "ready"
}
EOF

echo "✔ Short film pilot manifest created"

# -------------------------------------
# 4. WEBTV SERIES MANIFEST
# -------------------------------------
cat <<EOF > "$SERIES_DIR/high-stakes-series.json"
{
  "series": "High Stakes",
  "season": 1,
  "episodes": 8,
  "format": "1-hour",
  "themes": [
    "Control vs Chaos",
    "Intelligence as Power",
    "Family Liability",
    "Moral Collapse"
  ],
  "expansion": {
    "v2_feature": true,
    "sequel_ready": true
  }
}
EOF

echo "✔ WebTV series manifest created"

# -------------------------------------
# 5. TEXT-TO-VIDEO MASTER PROMPT
# -------------------------------------
cat <<EOF > "$PROMPT_DIR/high-stakes-text-to-video.prompt"
PROJECT: HIGH STAKES
FORMAT: Short Film + WebTV Series
GENRE: Urban Crime Thriller | Psychological

STYLE:
Bay Area realism.
Anxiety-driven pacing.
Numbers, odds, and predictive overlays as visual language.

LOG LINE:
A gifted underground bettor is pulled into a criminal betting empire where intelligence determines who lives, who dies, and who disappears.

CORE CHARACTERS:
Malik Cross – brilliant, controlled, unraveling.
Ronan Vega – calm, lethal fixer.
Jada Cross – sister, insider, liability.

DIRECTION:
Use betting odds as narrative pressure.
Intercut calculations with consequences.
End every episode with irreversible choice.

OUTPUT MODES:
- Full episodes
- Short film pilot
- Trailers
- Social shorts
EOF

echo "✔ Text-to-video prompt installed"

# -------------------------------------
# 6. PIPELINE INJECTION
# -------------------------------------
cat <<EOF > "$PIPELINE_DIR/high-stakes.inject"
inject:
  targets:
    - nexus_studio
    - nexus_stream
    - nexus_franchiser
  enable:
    shorts: true
    trailers: true
    licensing: true
    festival_mode: true
    regional_expansion: true
  status: active
EOF

echo "✔ Pipeline injection complete"

# -------------------------------------
# 7. FINAL REGISTRATION FLAGS
# -------------------------------------
touch "$FRANCHISE_DIR/.registered"
touch "$FRANCHISE_DIR/.launch_ready"
touch "$FRANCHISE_DIR/.festival_ready"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " HIGH STAKES SUCCESSFULLY INSTALLED"
echo " STATUS: FRANCHISED | PIPELINED | READY"
echo " LAUNCH: 01/01/2026"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

#!/usr/bin/env bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " NEXUS COS | FRANCHISER MASTER PF"
echo " PROJECT: RICO"
echo " MODE: WebTV + Short Film Spin-Off"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# -------------------------------------
# 1. CORE PATHS
# -------------------------------------
NEXUS_ROOT="/opt/nexus-cos"
FRANCHISE_DIR="$NEXUS_ROOT/franchises/rico"
CONTENT_DIR="$FRANCHISE_DIR/content"
PIPELINE_DIR="$FRANCHISE_DIR/pipeline"
PROMPT_DIR="$FRANCHISE_DIR/prompts"
SHORTFILM_DIR="$FRANCHISE_DIR/shortfilm"

mkdir -p \
  "$CONTENT_DIR/episodes" \
  "$CONTENT_DIR/bible" \
  "$PIPELINE_DIR" \
  "$PROMPT_DIR" \
  "$SHORTFILM_DIR"

echo "✔ Franchise directories created"

# -------------------------------------
# 2. FRANCHISE REGISTRATION
# -------------------------------------
cat <<EOF > "$FRANCHISE_DIR/franchise-rico.yaml"
franchise:
  id: rico-001
  title: RICO
  tagline: "One case. A hundred bodies."
  type: scripted_webtv
  spin_offs:
    - short_film
  genre:
    - legal_thriller
    - crime_drama
    - urban
  setting: Bay Area, California
  episodes: 13
  runtime_minutes: 60
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
# 3. SERIES MANIFEST
# -------------------------------------
cat <<EOF > "$CONTENT_DIR/rico-series-manifest.json"
{
  "series": "RICO",
  "season": 1,
  "episodes": 13,
  "format": "1-hour",
  "themes": [
    "Justice vs Revenge",
    "Street Code vs Legal Code",
    "Power and Legacy"
  ],
  "characters": [
    "Zariah West",
    "Pharaoh Kane",
    "Rico Tha Kid",
    "FBI Agent Cole"
  ]
}
EOF

echo "✔ Series manifest created"

# -------------------------------------
# 4. TEXT-TO-VIDEO PROMPT (MASTER)
# -------------------------------------
cat <<EOF > "$PROMPT_DIR/rico-text-to-video.prompt"
PROJECT: RICO
FORMAT: WebTV Series + Short Film
GENRE: Legal Thriller | Crime Drama | Urban

STYLE:
Gritty Bay Area realism.
Courtroom tension mixed with street-level chaos.
Cinematic lighting, handheld street shots, sterile legal interiors.

LOG LINE:
A Black federal prosecutor must destroy the criminal empire of her ex-lover using a RICO case that could also expose her family.

CORE CHARACTERS:
Zariah West – conflicted, brilliant, dangerous with the truth.
Pharaoh Kane – charismatic mogul hiding a criminal empire.
Rico Tha Kid – volatile wildcard who knows everything.
Agent Cole – federal pressure with no morals.

DIRECTION:
Intercut courtroom testimony with flashbacks and crimes.
End every episode on a moral cliff.
Short Film version condenses Episodes 1–4 into a 20–30 minute cinematic arc.

OUTPUT MODES:
- Full episodes
- Trailers
- Shorts
- Standalone short film
EOF

echo "✔ Text-to-video prompt installed"

# -------------------------------------
# 5. SHORT FILM SPIN-OFF ENABLEMENT
# -------------------------------------
cat <<EOF > "$SHORTFILM_DIR/rico-shortfilm.yaml"
short_film:
  title: RICO: THE CASE FILE
  derived_from: episodes_1_to_4
  runtime_minutes: 25
  purpose:
    - marketing
    - festival_submission
    - launch_content
  ai_generated: true
  nexus_stream_ready: true
EOF

echo "✔ Short film spin-off enabled"

# -------------------------------------
# 6. PIPELINE INJECTION
# -------------------------------------
cat <<EOF > "$PIPELINE_DIR/rico.inject"
inject:
  targets:
    - nexus_studio
    - nexus_stream
    - nexus_franchiser
  enable:
    shorts: true
    trailers: true
    licensing: true
    regional_expansion: true
  status: active
EOF

echo "✔ Pipeline injection complete"

# -------------------------------------
# 7. FINAL REGISTRATION
# -------------------------------------
touch "$FRANCHISE_DIR/.registered"
touch "$FRANCHISE_DIR/.launch_ready"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " RICO SUCCESSFULLY INSTALLED"
echo " STATUS: FRANCHISED | PIPELINED | READY"
echo " LAUNCH: 01/01/2026"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

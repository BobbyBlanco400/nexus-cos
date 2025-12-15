#!/usr/bin/env bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " NEXUS COS | FRANCHISER MASTER PF"
echo " PROJECT: DA YAY"
echo " MODE: Bay Area Flagship Franchise"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# -------------------------------------
# 1. CORE PATHS
# -------------------------------------
NEXUS_ROOT="/opt/nexus-cos"
FRANCHISE_DIR="$NEXUS_ROOT/franchises/da-yay"
CONTENT_DIR="$FRANCHISE_DIR/content"
PIPELINE_DIR="$FRANCHISE_DIR/pipeline"
PROMPT_DIR="$FRANCHISE_DIR/prompts"
SHORTFILM_DIR="$FRANCHISE_DIR/shortfilm"
SERIES_DIR="$CONTENT_DIR/series"
SPINOFFS_DIR="$FRANCHISE_DIR/spinoffs"

mkdir -p \
  "$CONTENT_DIR/bible" \
  "$SERIES_DIR/episodes" \
  "$PIPELINE_DIR" \
  "$PROMPT_DIR" \
  "$SHORTFILM_DIR" \
  "$SPINOFFS_DIR/vallejo" \
  "$SPINOFFS_DIR/san-francisco"

echo "✔ Franchise directories created"

# -------------------------------------
# 2. FRANCHISE REGISTRATION
# -------------------------------------
cat <<EOF > "$FRANCHISE_DIR/franchise-da-yay.yaml"
franchise:
  id: da-yay-001
  title: Da Yay
  tagline: "Bounce out… or get bounced on."
  type: urban_crime_epic
  format:
    - short_film
    - scripted_webtv
  genre:
    - urban_crime_thriller
    - drama
    - street_culture
  setting: Bay Area (Richmond, Oakland, Vallejo, San Francisco)
  creator: Bobby Blanco
  owner: PUABO Music -N- Media Group
  launch_target: "2026-01-01"
  episodes: 13
  runtime_minutes: 60
  monetization:
    enabled: true
    licensing: true
    franchising: true
    music_sync: true
    nft_enabled: true
  regional_expansion:
    enabled: true
    markets:
      - vallejo
      - san_francisco
      - oakland
  status:
    production_ready: true
    launch_blocker: false
    flagship: true
EOF

echo "✔ Franchise registered"

# -------------------------------------
# 3. SHORT FILM MANIFEST
# -------------------------------------
cat <<EOF > "$SHORTFILM_DIR/da-yay-short-film.json"
{
  "title": "Da Yay",
  "format": "Short Feature Film",
  "runtime_minutes": 45,
  "purpose": [
    "franchise_entry",
    "festival_submission",
    "proof_of_concept"
  ],
  "acts": 4,
  "locations": [
    "Richmond",
    "Oakland",
    "Vallejo",
    "San Francisco"
  ],
  "status": "ready"
}
EOF

echo "✔ Short film manifest created"

# -------------------------------------
# 4. WEBTV SERIES MANIFEST
# -------------------------------------
cat <<EOF > "$SERIES_DIR/da-yay-series.json"
{
  "series": "Da Yay",
  "season": 1,
  "episodes": 13,
  "format": "1-hour",
  "themes": [
    "Loyalty vs Survival",
    "Going Legit Without Getting Killed",
    "Gentrification & Cultural Erasure",
    "Music as Power",
    "Tech as a Weapon"
  ],
  "main_characters": [
    "Killa K (Kevin Harper)",
    "Dre (Andre King)",
    "Munchie (Malik Washington)",
    "Zoe (Zoeanna Carter)"
  ],
  "episodes_breakdown": {
    "ep1": "Bounce Out - Empire introduction, crypto-dope operation",
    "ep2": "Set Trippin' - Old beefs resurface",
    "ep3": "The Feature - Betrayal behind the scenes",
    "ep4": "Ghost Ride - Sideshows as cover",
    "ep5": "Dirty City - Corrupt officials enter",
    "ep6": "Crypto Blood - Federal attention",
    "ep7": "The Homecoming - Old kingpin returns",
    "ep8": "No Receipts - Murder shakes alliances",
    "ep9": "The Bay Don't Let Go - Flashback origin",
    "ep10": "Federal Heat - Task force targeting",
    "ep11": "Family Ties - Zoe's past threatens crew",
    "ep12": "Crossed Out - Close betrayal",
    "ep13": "Da Yay - Season finale showdown"
  },
  "expansion": {
    "spinoffs_ready": true,
    "music_integration": true,
    "regional_versions": [
      "DA YAY: VALLEJO",
      "DA YAY: SAN FRANCISCO"
    ]
  }
}
EOF

echo "✔ WebTV series manifest created"

# -------------------------------------
# 5. TEXT-TO-VIDEO MASTER PROMPT
# -------------------------------------
cat <<EOF > "$PROMPT_DIR/da-yay-text-to-video.prompt"
PROJECT: DA YAY
FORMAT: Short Film + WebTV Series (13 Episodes)
GENRE: Urban Crime Thriller | Drama | Bay Area Culture

STYLE:
Gritty Bay Area realism.
Handheld street chaos + drone establishing shots.
Color-coded lighting for tension.
Authentic Bay culture, slang, and music.

LOG LINE:
Four childhood friends from Richmond try to flip their street legacy into a Bay Area rap and tech empire—only to learn that loyalty is currency, betrayal is viral, and the streets never forget who you owe.

CORE CHARACTERS:
Killa K – The Ghost of the Bay, visionary shot-caller.
Dre – The enforcer, explosive and loyal.
Munchie – The brain trust, crypto and tech expert.
Zoe – The connector, femme fatale with real power.

VISUAL ELEMENTS:
- Handheld street realism
- Drone Bay Area vistas
- Warm Bay sunlight vs cold trap interiors
- Fast cuts, digital overlays, slowed emotional beats
- Sideshow sequences
- Studio recording sessions
- Night economy operations

AUDIO STYLE:
All Bay Area independent rap soundtrack.
Hyphy culture integration.
Authentic street dialogue with Richmond, Oakland, Vallejo cadence.

DIRECTION:
Use music studios, sideshows, crypto visuals, urban landscapes as narrative tools.
Every scene is a choice with consequences.
Emphasize loyalty dynamics and street politics.
Integrate tech hustle with traditional street operations.

OUTPUT MODES:
- Full episodes (13 x 60 min)
- Short film pilot (45 min)
- Trailers (30 sec, 60 sec, 90 sec)
- Social shorts (15 sec clips)
- Music video integration
- Regional spin-off content
EOF

echo "✔ Text-to-video prompt installed"

# -------------------------------------
# 6. REGIONAL SPIN-OFF CONFIGURATIONS
# -------------------------------------
cat <<EOF > "$SPINOFFS_DIR/vallejo/spinoff-config.yaml"
spinoff:
  title: "DA YAY: VALLEJO"
  focus: Tech-savvy street hustlers, waterfront operations
  setting: Vallejo, West Bay
  themes:
    - tech_money_crossover
    - waterfront_operations
    - west_bay_night_economy
  status: franchise_ready
EOF

cat <<EOF > "$SPINOFFS_DIR/san-francisco/spinoff-config.yaml"
spinoff:
  title: "DA YAY: SAN FRANCISCO"
  focus: Gentrification tension, tech-money crossover
  setting: San Francisco
  themes:
    - gentrification_dynamics
    - tech_to_boardroom
    - nightlife_infiltration
    - street_corporate_clash
  status: franchise_ready
EOF

echo "✔ Regional spin-offs configured"

# -------------------------------------
# 7. MUSIC INTEGRATION STRATEGY
# -------------------------------------
cat <<EOF > "$CONTENT_DIR/music-integration.json"
{
  "strategy": "Bay Area Rap Artists Integration",
  "components": {
    "soundtrack": "All Bay Area independent artists",
    "in_story_performances": true,
    "sideshow_events": true,
    "studio_sessions": true
  },
  "revenue_streams": {
    "music_sync": true,
    "streaming_revenue": true,
    "nft_drops": true,
    "episode_aligned_releases": true
  },
  "artist_rollout": {
    "timing": "Aligned with episode drops",
    "platforms": [
      "Nexus Stream",
      "PUABO DSP",
      "Major streaming services"
    ]
  }
}
EOF

echo "✔ Music integration strategy created"

# -------------------------------------
# 8. PIPELINE INJECTION
# -------------------------------------
cat <<EOF > "$PIPELINE_DIR/da-yay.inject"
inject:
  targets:
    - nexus_studio
    - nexus_stream
    - nexus_franchiser
    - puabo_dsp
  enable:
    shorts: true
    trailers: true
    licensing: true
    festival_mode: true
    regional_expansion: true
    music_sync: true
    spinoff_generation: true
  bay_area_specific:
    hyphy_culture: true
    independent_rap_ecosystem: true
    street_authenticity: true
  status: active
  priority: flagship
EOF

echo "✔ Pipeline injection complete"

# -------------------------------------
# 9. INVESTOR PITCH DECK METADATA
# -------------------------------------
cat <<EOF > "$FRANCHISE_DIR/investor-deck-metadata.json"
{
  "franchise": "Da Yay",
  "cultural_authenticity": "Bay Area street culture, Hyphy movement, independent rap ecosystem",
  "revenue_opportunities": [
    "Streaming platform distribution",
    "Music sync licensing",
    "Short-form social content",
    "Regional spin-offs (Vallejo, SF, Oakland)",
    "NFT collectibles",
    "Merchandising"
  ],
  "differentiation": [
    "Authentic Bay Area representation",
    "Hyphy culture integration",
    "Independent rap ecosystem",
    "Real town business dynamics",
    "Tech-street crossover narrative"
  ],
  "expansion_roadmap": {
    "phase_1": "Core series + short film (Bay Area)",
    "phase_2": "Vallejo spin-off",
    "phase_3": "San Francisco spin-off",
    "phase_4": "Oakland expansion",
    "phase_5": "National franchise model"
  },
  "risk_mitigation": "Nexus COS pipeline control, franchise rules enforcement"
}
EOF

echo "✔ Investor deck metadata created"

# -------------------------------------
# 10. FINAL REGISTRATION FLAGS
# -------------------------------------
touch "$FRANCHISE_DIR/.registered"
touch "$FRANCHISE_DIR/.launch_ready"
touch "$FRANCHISE_DIR/.festival_ready"
touch "$FRANCHISE_DIR/.flagship"
touch "$FRANCHISE_DIR/.bay_area_authenticated"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " DA YAY SUCCESSFULLY INSTALLED"
echo " STATUS: FLAGSHIP | FRANCHISED | READY"
echo " REGIONAL EXPANSION: ENABLED"
echo " MUSIC INTEGRATION: ACTIVE"
echo " LAUNCH: 01/01/2026"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

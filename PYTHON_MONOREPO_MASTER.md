# 🗺️ N3XUS v-COS: The Python Codespaces Monorepo (Master)

This document defines the authoritative structure and execution plan for the N3XUS v-COS Python Monorepo. This structure is designed to enforce the "Sovereign Protocol" (N3XUS LAW 55-45-17) and manage the full lifecycle of Franchises and IMVUs.

## 📁 MONOREPO STRUCTURE (AUTHORITATIVE)

```
nexus-vcos/
├── README.md
├── pyproject.toml
├── requirements.txt
├── .env.example
├── scripts/
│   ├── master_execute.py          # The "Red Button" - runs everything
│   ├── phase_1_scaffold.py        # Sets up franchise folders
│   ├── phase_2_pipeline.py        # Builds the media pipeline
│   ├── phase_3_registry_sync.py   # Syncs with platform registries
│   ├── phase_4_launch_verify.py   # Final launch verification
│   └── utils.py                   # Shared logging and tools
├── canon/
│   ├── ownership.py               # Defines "Bobby Blanco" as owner
│   ├── launch_date.py             # Defines "2026-01-19" as launch
│   └── rules.py                   # Defines N3XUS LAW
├── franchises/                    # The 10 Core Content Franchises
│   ├── rico/
│   ├── high_stakes/
│   ├── da_yay/
│   ├── glitch_code_of_chaos/
│   │   └── pf_regions/
│   ├── four_way_or_no_way/
│   ├── second_down_16_bars/
│   ├── gutta_baby/
│   ├── one_way_out/
│   ├── under_the_overpass/
│   └── the_ones_who_stayed/
├── registries/                    # The "Books" of Record
│   ├── nexus_cos.json
│   ├── nexus_stream.json
│   ├── nexus_studio.json
│   ├── puabo_dsp.json
│   └── thiio_handoff.json
└── logs/
    └── execution.log
```

---

## 📜 DEFINITIONS: FRANCHISE VS. IMVU

To eliminate confusion, the following definitions are **CANONICAL** and enforced by the system code.

### 1. 🏢 FRANCHISE (The "Brand")
A **Franchise** is a **Master Intellectual Property (IP) Container**. It is the "Umbrella" that holds the rights, the universe, the characters, and the distribution channels.
*   **Analogy:** "Marvel Cinematic Universe" or "Star Wars".
*   **Example:** "RICO" is a Franchise. "DA YAY" is a Franchise.
*   **Components:**
    *   **Bible:** The story universe, character profiles, settings.
    *   **Rights:** Who owns it (Bobby Blanco / 100% Creator Owned).
    *   **Distribution:** Where it lives (Nexus Stream, Puabo DSP).
    *   **Monetization:** How it makes money (Merch, Tickets, Streaming).

### 2. 🎬 IMVU (The "Product")
An **IMVU** (Interactive Media Virtual Unit) is a **Specific Piece of Content** *within* a Franchise. It is the actual file, episode, or interactive experience that users consume.
*   **Analogy:** "Iron Man (2008)" is the IMVU. "The Avengers #14" is an IMVU.
*   **Example:** "RICO: Episode 1 - The Arraignment" is an IMVU.
*   **Technical Definition:** An IMVU is a digital asset bundle (Video + Metadata + Interactive Script) that runs on the v-COS Runtime.
*   **Relationship:** A Franchise **HAS MANY** IMVUs. An IMVU **BELONGS TO** one Franchise.

---

## 🛠️ EXECUTION PROTOCOLS

### 📄 pyproject.toml
```toml
[project]
name = "nexus-vcos"
version = "1.0.0"
description = "N3XUS v-COS Canonical IMVU Media Pipeline"
requires-python = ">=3.10"
```

### 📄 requirements.txt
```text
python-dotenv
rich
```

### 📄 canon/ownership.py
```python
OWNER = "Bobby Blanco"
OWNERSHIP_MODEL = "100% Creator-Owned"
REVENUE_SPLIT = "None"
```

### 📄 canon/launch_date.py
```python
LAUNCH_DATE = "2026-01-19"
LOCKED = True
```

---

## 🚀 HOW TO RUN (MASTER EXECUTION)

Run the following command to initialize the entire Sovereign Stack, scaffold the franchises, and verify the launch state.

```bash
python nexus-vcos/scripts/master_execute.py
```

**Expected Output:**
```text
[2026-01-23T00:00:00] === MASTER EXECUTION START ===
[2026-01-23T00:00:01] PHASE 1: Scaffolding franchises
[2026-01-23T00:00:01] Scaffolded franchise: rico
...
[2026-01-23T00:00:02] PHASE 1 COMPLETE ✅
[2026-01-23T00:00:03] PHASE 2: Executing Media Pipeline
...
[2026-01-23T00:00:05] PHASE 4 COMPLETE ✅
[2026-01-23T00:00:06] === ALL TASKS COMPLETED SUCCESSFULLY ===
```

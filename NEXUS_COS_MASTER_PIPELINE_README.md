# N3XUS v-COS Master Pipeline – IMVU Media Execution Script

**File:** `nexus_cos_master_pipeline.py`  
**Scope:** N3XUS v-COS / IMVU Media Pipeline (22 items)  
**Handshake:** `55-45-17` (enforced in logs)  
**Launch Date Target:** `2026-01-19`

---

## Overview

The master pipeline script provides a self-contained, cinematic execution flow for the N3XUS v-COS / IMVU Media Pipeline, designed to run cleanly in GitHub Codespaces and on your VPS.

The script:
- Processes **22 pipeline items**:
  - 10 IMVU franchises  
  - 5 regional PF installers  
  - 2 add-in modules  
  - 5 platform registries
- Emits **timestamped logs** in `[HH:MM:SS]` format
- Shows **ASCII progress bars** per pipeline step
- Enforces **canon lock** and **100% creator ownership override** per item
- Verifies the **launch date** (`2026-01-19`) and logs launch window status
- Has **zero external dependencies** (only `sys`, `time`, `datetime`)

---

## Execution Flow

For each of the 22 items, the script executes:

1. **Canon Lock Application**
   - Logs `N3XUS_HANDSHAKE=55-45-17`
   - Marks the item as canon-locked for this run

2. **Creator Ownership Override**
   - Logs a 100% creator / 0% platform ownership override

3. **5-Step Pipeline Execution with Progress Bars**
   - Steps:
     1. Seed ingestion  
     2. IMVU canon mapping  
     3. MetaTwin bridge staging  
     4. PF export preparation  
     5. Registry handoff  
   - Each step prints a progress bar:
     - Example:  
       `Pipeline step 5/5 for RICO: Registry handoff |██████████████████████████████| 100.0% Complete`

4. **Platform Registry Sync (Platform Registries Only)**
   - For items of kind `platform_registry`:
     - Logs a registry sync action
     - Confirms completion per registry

5. **Per-Item Completion Summary**
   - Logs item-level elapsed time

6. **Master Summary**
   - At the end of all 22 items:
     - Logs total items processed
     - Logs total elapsed runtime

---

## Pipeline Inventory

### IMVU Franchises (10)
- RICO  
- HIGH STAKES  
- DA YAY  
- BAYLINE STORIES  
- SILICON NOIR  
- NORTHSTAR DISTRICT  
- GOLDEN GATE RUNNERS  
- V-SUITE ORIGINS  
- N3XUS NIGHTS  
- CANON CITY  

### Regional PF Installers (5)
- PF Installer – Bay Area  
- PF Installer – West Coast  
- PF Installer – East Coast  
- PF Installer – EU  
- PF Installer – Global OTT  

### Add-in Modules (2)
- MetaTwin Add-in – IMVU Bridge  
- HoloCore Add-in – Overlay Pack  

### Platform Registries (5)
- Platform Registry – N3XUS-NET  
- Platform Registry – IMVU Runtime  
- Platform Registry – PF Canon Slots  
- Platform Registry – OTT / Streaming  
- Platform Registry – Founding Residents  

---

## Launch Date Enforcement

The script is aware of the **target launch date**:

- `LAUNCH_DATE = 2026-01-19`

At startup it logs the current window:
- `PRE-LAUNCH WINDOW` if today is before the launch date  
- `LAUNCH DAY` if today is the launch date  
- `POST-LAUNCH WINDOW` if today is after the launch date  

This is informational only and does **not block** execution; it documents the temporal context of the run.

---

## Runtime Characteristics

- **Default mode:**
  - Uses a moderate delay per step to give a cinematic flow
  - Intended for manual runs from Codespaces or VPS shells

- **Fast mode (`--fast`):**
  - Greatly reduced delays for CI or quick verification
  - Produces the exact same log structure and progress bars

---

## Exit Codes

- Exit code `0`: Successful completion of all 22 items  
- Non-zero exit code: Only used if the script fails unexpectedly (for example, an internal Python error)

The script itself does not raise domain-specific failures; it is a deterministic orchestrator/visualization layer around the IMVU Media Pipeline.

---

## File Location

The script lives at the repository root:

- `nexus_cos_master_pipeline.py`

Run it directly from that directory.


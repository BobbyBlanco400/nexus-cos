# N3XUS COS VPS Canon-Verification & Launch Workflow

## Overview

This directory contains the official canonical branding assets for N3XUS COS. These assets are verified during the canon-verification process before system launch.

## Directory Structure

```
branding/
├── official/           # Canonical official assets
│   ├── N3XUS-vCOS.png  # Official logo (PNG format - N3XUS LAW)
│   └── N3XUS-vCOS.svg  # Legacy SVG (for backward compatibility)
├── colors.env          # Brand colors
├── theme.css           # Brand theme
└── favicon.ico         # Favicon
```

## Official Logo Placement

**Per N3XUS LAW**, the official logo must be in PNG format at:
```
branding/official/N3XUS-vCOS.png
```

This location is validated by the canon-verifier during the GO/NO-GO check.

## Verification Process

The canon-verifier (`canon-verifier/trae_go_nogo.py`) checks:
1. Logo file exists at the canonical path
2. File size is within acceptable range (1KB - 10MB)
3. File format is valid (PNG preferred, SVG for legacy compatibility)
4. Configuration is properly set in `canon-verifier/config/canon_assets.json`

## Atomic VPS Deployment Command

See the problem statement for the complete atomic one-line bash command that:
1. Creates the canonical branding directory
2. Copies the official logo to the canonical location
3. Updates canon-verifier configuration
4. Creates timestamped logging folder
5. Runs full canon-verifier harness
6. Launches PM2 and Docker services
7. Outputs final GO confirmation

## Configuration

The official logo path is configured in:
```
canon-verifier/config/canon_assets.json
```

Update the `OfficialLogo` field to point to the canonical logo location.

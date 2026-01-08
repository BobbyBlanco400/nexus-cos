# Canon-Verifier Configuration

This directory contains configuration files for the canon-verifier system.

## Files

- `canon_assets.json` - Main configuration for canonical assets and verification rules

## Configuration Structure

```json
{
  "OfficialLogo": "/path/to/canonical/logo.svg",
  "VerificationTimestamp": "ISO-8601 timestamp",
  "AssetRegistry": {
    "logos": {
      "official": "path/to/official/logo",
      "alternate": []
    },
    "branding": {
      "colors": "path/to/colors.env",
      "theme": "path/to/theme.css"
    }
  },
  "VerificationRules": {
    "logoRequired": true,
    "logoFormats": ["svg", "png"],
    "minLogoSize": 1024,
    "maxLogoSize": 10485760
  }
}
```

## Usage

The configuration is automatically loaded by `trae_go_nogo.py` during verification.

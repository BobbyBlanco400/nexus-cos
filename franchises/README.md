# Nexus COS Franchise Scripts

This directory contains installation scripts for Nexus COS franchises - content properties ready for AI-powered text-to-video generation, streaming distribution, and multi-platform deployment.

## Overview

The Nexus COS Franchise System enables rapid deployment of scripted content franchises with complete metadata, pipeline integration, and AI generation capabilities built-in.

## Franchises Included

### 1. RICO
- **Type:** Legal Thriller | Crime Drama
- **Format:** 13-episode WebTV series + Short Film spin-off
- **Setting:** Bay Area, California
- **Episodes:** 13 x 60 minutes
- **Short Film:** 25 minutes (derived from episodes 1-4)
- **Themes:** Justice vs Revenge, Street Code vs Legal Code, Power and Legacy

### 2. HIGH STAKES
- **Type:** Urban Crime Thriller | Psychological
- **Format:** 8-episode WebTV series + 45-minute Short Film pilot
- **Setting:** Bay Area, California
- **Episodes:** 8 x 60 minutes
- **Pilot Film:** 45 minutes (proof-of-concept)
- **Themes:** Control vs Chaos, Intelligence as Power, Moral Collapse

### 3. DA YAY (Flagship)
- **Type:** Urban Crime Epic | Bay Area Culture
- **Format:** 13-episode WebTV series + 45-minute Short Film + Regional Spin-offs
- **Setting:** Richmond, Oakland, Vallejo, San Francisco
- **Episodes:** 13 x 60 minutes
- **Short Film:** 45 minutes
- **Regional Expansion:** Vallejo, San Francisco spin-offs ready
- **Special Features:** Music integration, NFT-enabled, Hyphy culture authentic

## Installation

### Quick Install (All Franchises)

```bash
# Navigate to the franchises directory in your nexus-cos repository
cd franchises
sudo bash install-all-franchises.sh
```

This will install all three franchises and create the master registry.

### Individual Franchise Installation

**Install RICO only:**
```bash
sudo bash install-rico.sh
```

**Install HIGH STAKES only:**
```bash
sudo bash install-high-stakes.sh
```

**Install DA YAY only:**
```bash
sudo bash install-da-yay.sh
```

## What Gets Installed

Each franchise installation creates:

1. **Directory Structure**
   - Content directories (episodes, bible, series)
   - Pipeline injection points
   - Prompt templates for AI generation
   - Short film configurations

2. **Configuration Files**
   - YAML franchise registration
   - JSON series manifests
   - Text-to-video prompt templates
   - Pipeline injection configs

3. **Registration Flags**
   - `.registered` - Franchise is registered
   - `.launch_ready` - Ready for production launch
   - `.festival_ready` - Ready for festival submission (where applicable)
   - `.flagship` - Flagship franchise status (DA YAY only)

## Installation Paths

All franchises install to:
```
/opt/nexus-cos/franchises/
├── rico/
├── high-stakes/
├── da-yay/
└── franchise-registry.json
```

## Pipeline Integration

All franchises automatically inject into:
- **nexus_studio** - AI content generation
- **nexus_stream** - Streaming distribution
- **nexus_franchiser** - Franchise management
- **puabo_dsp** - Music integration (DA YAY)

## Features Enabled

### All Franchises
✅ Text-to-Video AI generation  
✅ Short film production  
✅ Trailer generation  
✅ Social media shorts  
✅ Licensing capabilities  
✅ Regional expansion ready  

### DA YAY Specific
✅ Music sync integration  
✅ NFT collectibles  
✅ Regional spin-offs (Vallejo, SF)  
✅ Hyphy culture authentic  
✅ Independent rap ecosystem integration  

## AI Generation Prompts

Each franchise includes master text-to-video prompts configured for:
- Full episode generation
- Trailer cuts (30s, 60s, 90s)
- Short-form social content
- Festival versions
- Regional adaptations

## Verification

After installation, verify with:

```bash
# Check if all franchises are registered
ls -la /opt/nexus-cos/franchises/

# View master registry
cat /opt/nexus-cos/franchises/franchise-registry.json

# Check individual franchise status
ls -la /opt/nexus-cos/franchises/rico/
ls -la /opt/nexus-cos/franchises/high-stakes/
ls -la /opt/nexus-cos/franchises/da-yay/
```

## Launch Timeline

**Target Launch Date:** January 1, 2026

All franchises are configured for simultaneous launch with:
- Production-ready status
- No launch blockers
- Full monetization enabled
- Complete pipeline integration

## Creator Information

**Created by:** Bobby Blanco  
**Owner:** PUABO Music -N- Media Group  
**System:** Nexus COS Franchise Platform  
**Version:** 1.0.0  

## Support

For franchise management questions or technical support:
- Check the Nexus COS main documentation
- Review franchise YAML files for configuration details
- Consult text-to-video prompts for AI generation guidance

## License

All franchises are proprietary content owned by PUABO Music -N- Media Group.  
See individual franchise configurations for specific licensing terms.

# Nexus COS Master Injection Script

## Overview

The `nexus_cos_master_injection.sh` script is a comprehensive, automated tool for injecting the complete Nexus COS Master Platform Framework (PF) into the ecosystem. This script is designed for hands-off execution by GitHub Agents and includes all necessary platform definitions, Creative OS modules, and governance configurations.

## Features

- **14 TIER_1 Platforms**: Complete registration of all Nexus COS native platforms
- **Creative OS Modules**: 7 comprehensive module categories
  - Creation (browser film/TV studio, timeline editor, scene builder, AI tools)
  - Production (versioned projects, branching, collaborative editing)
  - Immersive (VR scene preview, AI avatars, virtual sets)
  - Distribution (Nexus Stream hubs, scheduling, on-demand release)
  - Monetization (revenue tracking, subscriptions, ads, donations, PPV)
  - Governance (THIIO enforcement, IP protection, audit logging)
  - Franchiser (clone templates, multi-show, multi-region)
- **Subscription Tiers**: FREE, STANDARD ($9.99), and PREMIUM ($19.99)
- **Revenue Model**: Locked 80/20 split (Platform Operator/Nexus COS)
- **THIIO Registry**: Complete governance and compliance framework
- **Automated Assessment**: Triggers GitHub Agent analysis of the entire stack

## Platforms Included

1. **Casino-Nexus** - Gaming and casino platform
2. **Gas or Crash** - Interactive gaming experience
3. **Club Saditty** - Social entertainment hub
4. **Ro Ro's Gaming Lounge** - Gaming lounge platform
5. **Headwina Comedy Club** - Comedy and entertainment
6. **Sassie Lash** - Beauty and lifestyle
7. **Fayeloni Kreations** - Creative content platform
8. **Sheda Shay's Butter Bar** - Food and hospitality
9. **Ne Ne & Kids** - Family and children's content
10. **Ashanti's Munch & Mingle** - Social dining experience
11. **Cloc Dat T** - Fashion and lifestyle
12. **Faith Through Fitness** - Wellness and fitness
13. **Virtual Soccer League** - Sports gaming platform
14. **Nexus Vision** - Reference platform (master template)

## Usage

### Basic Usage

```bash
./nexus_cos_master_injection.sh
```

### With Custom Organization

```bash
GITHUB_ORG=MyOrganization ./nexus_cos_master_injection.sh
```

### With Custom Agent URL

```bash
AGENT_BASE_URL=https://api.myorg.com/nexus-agent ./nexus_cos_master_injection.sh
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GITHUB_ORG` | GitHub organization name | `YourOrg` |
| `AGENT_BASE_URL` | Base URL for GitHub Agent API | `https://github.com/${GITHUB_ORG}/NexusCOSAgent` |
| `CURL_TIMEOUT` | Timeout in seconds for HTTP requests | `30` |

## Execution Flow

1. **Injection** - Sends Master PF JSON payload to GitHub Agent
2. **Status Polling** - Monitors injection status (60 attempts, 10s intervals)
3. **Assessment Trigger** - Initiates automated stack assessment
4. **Assessment Polling** - Monitors assessment completion
5. **Recommendations** - Retrieves and displays assessment results

## Output

The script generates a timestamped log file:
```
inject_creative_os_YYYY-MM-DD_HH-MM-SS.log
```

All operations are logged to both console and file for complete audit trail.

## Exit Codes

- `0` - Success (injection and assessment complete)
- `1` - Critical failure (injection failed)

Note: Assessment failures result in exit code 0 with warnings, as injection is the critical operation.

## Error Handling

- HTTP status code validation for all API calls
- Configurable timeout protection (600 seconds default)
- Graceful degradation (assessment can fail without blocking)
- Comprehensive error messages and logging

## Requirements

- `bash` 4.0 or higher
- `curl` for HTTP requests
- `jq` for JSON processing
- Network access to GitHub Agent endpoints

## Integration

This script is designed to work with:
- GitHub Actions workflows
- CI/CD pipelines
- Manual deployment processes
- Automated agent execution environments

## Security Considerations

- No sensitive credentials stored in script
- Configurable endpoints via environment variables
- Complete audit logging of all operations
- HTTP status code validation
- Secure temporary file handling with `mktemp`
- Automatic cleanup of temporary files on exit
- Configurable timeout protection (default 30s per request)
- Protection against hanging on unresponsive endpoints

## Support

For issues or questions about this script, refer to:
- Main repository documentation
- MASTER_PF_SUMMARY.md
- PF_DEPLOYMENT_QUICK_REFERENCE.md

## Related Files

- `execute_master_pf.sh` - Platform execution script
- `master-pf-puabo-platform.sh` - PUABO platform setup
- `MASTER_PF_SUMMARY.md` - Complete PF documentation

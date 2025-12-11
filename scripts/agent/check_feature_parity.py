#!/usr/bin/env python3
"""
Feature Parity Checker for Nexus COS
Compares current system against canonical investor synopsis
"""

import json
import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Set

# Required modules from canonical synopsis
REQUIRED_MODULES = [
    # Core Backend Services
    "backend-api",
    "auth",
    "users",
    
    # Content Management & Streaming
    "content-cms",
    "transcoder",
    "streaming-engine",
    "drm-service",
    "asset-pipeline",
    "thumbnailer",
    "transcode-worker",
    "ingest-worker",
    "metadata-worker",
    "manifest-builder",
    
    # Monetization & Commerce
    "monetization",
    "puabo-blac-financing",
    "billing-worker",
    "payments",
    "wallet",
    
    # Analytics & Intelligence
    "analytics",
    "analytics-worker",
    "recommendation",
    
    # Marketplace & E-Commerce
    "marketplace",
    
    # Frontend Applications
    "frontend-app",
    "creator-dashboard",
    "ott-mini",
    
    # Nexus Stream
    "nexus-stream",
    "player-api",
    
    # PUABO Universe
    "puabo-nexus-fleet-manager",
    "puabo-nexus-ai-dispatch",
    "puabo-nexus-driver-app-backend",
    "puabo-nexus-route-optimizer",
    "puaboverse-v2",
    
    # AI & Intelligence
    "puabo-ai-core",
    "rtx-orchestrator",
    "rtx-worker",
    
    # Notifications & Integration
    "notifications",
    "email-worker",
    "webhook-worker",
    "thirdparty-connector",
    "crm-sync",
    
    # Search & Discovery
    "search",
    "profiles",
    
    # Live Streaming
    "live-ingest",
    "recorder",
    "stream-monitor",
    
    # Upload & Storage
    "uploader",
    
    # Audit & Compliance
    "audit-exporter",
]

# Critical modules that must be present (subset of required)
CRITICAL_MODULES = [
    "backend-api",
    "auth",
    "users",
    "streaming-engine",
    "puabo-blac-financing",
    "ott-mini",
    "nexus-stream",
]

def normalize_service_name(name: str) -> str:
    """Normalize service name for comparison"""
    # Remove common prefixes/suffixes
    name = name.lower()
    name = name.replace("nexus-cos-", "")
    name = name.replace("-service", "")
    name = name.replace("_", "-")
    return name

def find_service_matches(services_dir: Path, module_name: str) -> List[str]:
    """Find potential matches for a module in services directory"""
    matches = []
    
    if not services_dir.exists():
        return matches
    
    # Normalize module name for matching
    normalized_module = normalize_service_name(module_name)
    
    for service_path in services_dir.iterdir():
        if not service_path.is_dir():
            continue
            
        normalized_service = normalize_service_name(service_path.name)
        
        # Exact match
        if normalized_service == normalized_module:
            matches.append(service_path.name)
            continue
        
        # Partial match (contains)
        if normalized_module in normalized_service or normalized_service in normalized_module:
            matches.append(service_path.name)
            continue
        
        # Check for alias matches
        aliases = {
            "backend-api": ["backend", "api", "gateway"],
            "frontend-app": ["frontend", "web", "app"],
            "streaming-engine": ["streamcore", "stream", "streaming"],
            "puabo-blac-financing": ["puabo-blac", "blac"],
            "ott-mini": ["ott"],
        }
        
        if module_name in aliases:
            for alias in aliases[module_name]:
                if alias in normalized_service:
                    matches.append(service_path.name)
                    break
    
    return matches

def check_feature_parity(discovery_file: str, synopsis_file: str, workdir: str) -> Dict:
    """
    Check feature parity between current system and synopsis
    
    Returns:
        Discrepancy report with present, partial, and missing modules
    """
    # Load discovery data
    with open(discovery_file, 'r') as f:
        discovery = json.load(f)
    
    # Get services directory
    services_dir = Path(workdir) / "services"
    
    # Track module status
    present_modules = []
    partial_modules = []
    missing_modules = []
    
    # Check each required module
    for module in REQUIRED_MODULES:
        matches = find_service_matches(services_dir, module)
        
        if len(matches) == 1:
            # Exact match found
            present_modules.append({
                "module": module,
                "matched_service": matches[0],
                "status": "present"
            })
        elif len(matches) > 1:
            # Multiple potential matches (ambiguous)
            partial_modules.append({
                "module": module,
                "matched_services": matches,
                "status": "partial",
                "reason": "Multiple potential matches - manual verification needed"
            })
        else:
            # No match found
            missing_modules.append({
                "module": module,
                "status": "missing",
                "critical": module in CRITICAL_MODULES
            })
    
    # Generate discrepancy report
    report = {
        "timestamp": discovery.get("timestamp"),
        "total_required": len(REQUIRED_MODULES),
        "total_present": len(present_modules),
        "total_partial": len(partial_modules),
        "total_missing": len(missing_modules),
        "critical_missing": len([m for m in missing_modules if m.get("critical")]),
        "parity_percentage": round((len(present_modules) / len(REQUIRED_MODULES)) * 100, 2),
        "present_modules": present_modules,
        "partial_modules": partial_modules,
        "missing_modules": missing_modules,
        "recommendation": ""
    }
    
    # Generate recommendation
    MAX_ACCEPTABLE_CRITICAL_MISSING = 6
    if report["critical_missing"] > MAX_ACCEPTABLE_CRITICAL_MISSING:
        report["recommendation"] = "CRITICAL: More than 6 critical modules missing. Auto-scaffolding required."
        report["action"] = "auto_scaffold"
    elif report["critical_missing"] > 0:
        report["recommendation"] = f"{report['critical_missing']} critical modules missing. Review and scaffold recommended."
        report["action"] = "review_and_scaffold"
    else:
        report["recommendation"] = "Feature parity acceptable. Manual review of partial modules recommended."
        report["action"] = "review_only"
    
    return report

def main():
    parser = argparse.ArgumentParser(description="Check Nexus COS feature parity")
    parser.add_argument("--discovery", required=True, help="Path to discovery_parsed.json")
    parser.add_argument("--synopsis", required=True, help="Path to investor_synopsis.md")
    parser.add_argument("--out", required=True, help="Output path for discrepancy report")
    parser.add_argument("--workdir", default=".", help="Working directory")
    
    args = parser.parse_args()
    
    # Check feature parity
    report = check_feature_parity(args.discovery, args.synopsis, args.workdir)
    
    # Write report
    with open(args.out, 'w') as f:
        json.dump(report, f, indent=2)
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"NEXUS COS FEATURE PARITY REPORT")
    print(f"{'='*60}")
    print(f"Total Required Modules: {report['total_required']}")
    print(f"Present:                {report['total_present']} ({report['parity_percentage']}%)")
    print(f"Partial/Ambiguous:      {report['total_partial']}")
    print(f"Missing:                {report['total_missing']}")
    print(f"Critical Missing:       {report['critical_missing']}")
    print(f"{'='*60}")
    print(f"Recommendation: {report['recommendation']}")
    print(f"Action:         {report['action']}")
    print(f"{'='*60}\n")
    print(f"✓ Discrepancy report written to: {args.out}")

if __name__ == "__main__":
    main()

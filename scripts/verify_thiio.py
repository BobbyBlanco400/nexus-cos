#!/usr/bin/env python3
"""
Verify THIIO Compliance Script
Verifies THIIO handoff compliance and IP clearances
"""

import os
import sys
import json
from pathlib import Path
from datetime import datetime

def load_config():
    """Load master PF configuration"""
    config_path = Path("05_pf_json/master_pf_config.json")
    with open(config_path, 'r') as f:
        return json.load(f)

def load_deployment_manifest():
    """Load THIIO deployment manifest"""
    manifest_path = Path("06_thiio_handoff/deployment/deployment_manifest.json")
    if manifest_path.exists():
        with open(manifest_path, 'r') as f:
            return json.load(f)
    return None

def check_legal_compliance():
    """Check legal compliance documentation"""
    legal_doc_path = Path("06_thiio_handoff/legal/LEGAL_COMPLIANCE.md")
    
    print("\n📋 Checking Legal Compliance Documentation...")
    
    if not legal_doc_path.exists():
        print("   ❌ Legal compliance document not found")
        return False
    
    with open(legal_doc_path, 'r') as f:
        content = f.read()
    
    # Check for completed checkboxes (basic validation)
    total_checkboxes = content.count('- [ ]') + content.count('- [x]') + content.count('- [X]')
    completed_checkboxes = content.count('- [x]') + content.count('- [X]')
    
    print(f"   Legal Compliance Checklist:")
    print(f"   Total Items: {total_checkboxes}")
    print(f"   Completed: {completed_checkboxes}")
    print(f"   Pending: {total_checkboxes - completed_checkboxes}")
    
    if completed_checkboxes == 0:
        print(f"   ⚠️  WARNING: No legal items have been completed")
        print(f"      This is expected for placeholder/development mode")
        return False
    elif completed_checkboxes < total_checkboxes:
        print(f"   ⚠️  WARNING: Legal compliance is incomplete")
        return False
    else:
        print(f"   ✅ All legal compliance items completed")
        return True

def verify_thiio_compliance(config):
    """Verify THIIO compliance requirements"""
    print("\n🎯 Verifying THIIO Compliance...")
    
    # Check master config
    if not config['metadata'].get('thiio_compliance', False):
        print("   ⚠️  THIIO compliance not verified in master config")
    
    # Load and check deployment manifest
    manifest = load_deployment_manifest()
    if not manifest:
        print("   ❌ Deployment manifest not found")
        return False
    
    print(f"   Deployment Manifest: {manifest['deployment_manifest_id']}")
    print(f"   Status: {manifest['status']}")
    
    # Check compliance checklist
    checklist = manifest['compliance_checklist']
    compliance_items = {
        'Legal Review Complete': checklist['legal_review_complete'],
        'IP Clearances Verified': checklist['ip_clearances_verified'],
        'Talent Releases Signed': checklist['talent_releases_signed'],
        'Music Rights Cleared': checklist['music_rights_cleared'],
        'Platform Licenses Valid': checklist['platform_licenses_valid'],
        'Technical Specs Approved': checklist['technical_specs_approved'],
        'Quality Control Passed': checklist['quality_control_passed'],
        'THIIO Certification': checklist['thiio_certification']
    }
    
    print("\n   Compliance Checklist:")
    all_compliant = True
    for item, status in compliance_items.items():
        status_icon = "✅" if status else "❌"
        print(f"   {status_icon} {item}: {status}")
        if not status:
            all_compliant = False
    
    if not all_compliant:
        print("\n   ⚠️  WARNING: THIIO compliance requirements not met")
        print("      This is expected for placeholder/development mode")
        print("      DO NOT deploy to production without completing all items")
    
    return all_compliant

def generate_compliance_report(config):
    """Generate THIIO compliance report"""
    print("\n📄 Generating THIIO Compliance Report...")
    
    # Create reports directory
    reports_dir = Path(config['pipeline_configuration']['output_configuration']['reports_subdirectory'])
    reports_dir.mkdir(parents=True, exist_ok=True)
    
    # Load manifest
    manifest = load_deployment_manifest()
    
    # Generate report
    report = {
        "report_id": "THIIO_COMPLIANCE_REPORT_001",
        "generated": datetime.now().isoformat(),
        "project": config['project_name'],
        "version": config['version'],
        "compliance_status": "PLACEHOLDER_MODE",
        "legal_compliance": check_legal_compliance(),
        "thiio_certification": manifest['compliance_checklist']['thiio_certification'] if manifest else False,
        "ip_verification": manifest['ip_ownership']['chain_of_title_verified'] if manifest else False,
        "rights_clearances": manifest['rights_clearances'] if manifest else {},
        "warnings": [
            "This is a PLACEHOLDER compliance report",
            "Legal review required before production deployment",
            "All rights clearances must be completed",
            "THIIO certification must be obtained"
        ],
        "recommendations": [
            "Complete all legal compliance checklist items",
            "Obtain signed talent releases and rights agreements",
            "Verify IP ownership and chain of title",
            "Submit for THIIO certification review",
            "Conduct final quality control review"
        ]
    }
    
    report_path = reports_dir / "thiio_compliance_report.json"
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"   ✅ Report generated: {report_path}")
    
    # Also create human-readable text version
    text_report_path = reports_dir / "thiio_compliance_report.txt"
    with open(text_report_path, 'w') as f:
        f.write("=" * 60 + "\n")
        f.write("THIIO COMPLIANCE REPORT\n")
        f.write("=" * 60 + "\n\n")
        f.write(f"Project: {report['project']}\n")
        f.write(f"Generated: {report['generated']}\n")
        f.write(f"Status: {report['compliance_status']}\n\n")
        f.write("WARNINGS:\n")
        for warning in report['warnings']:
            f.write(f"  ⚠️  {warning}\n")
        f.write("\nRECOMMENDATIONS:\n")
        for rec in report['recommendations']:
            f.write(f"  • {rec}\n")
    
    print(f"   ✅ Text report generated: {text_report_path}")
    
    return True

def main():
    """Main execution function"""
    print("=" * 60)
    print("🎯 VERIFY THIIO COMPLIANCE - Master PF Pipeline")
    print("=" * 60)
    
    # Load configuration
    config = load_config()
    print(f"\n✅ Configuration loaded: {config['project_name']}")
    print(f"   THIIO Compliance Required: {config['metadata']['thiio_compliance']}")
    
    # Check legal compliance
    legal_ok = check_legal_compliance()
    
    # Verify THIIO compliance
    thiio_ok = verify_thiio_compliance(config)
    
    # Generate compliance report
    report_ok = generate_compliance_report(config)
    
    if not (legal_ok and thiio_ok):
        print("\n⚠️  COMPLIANCE CHECK INCOMPLETE")
        print("   Status: PLACEHOLDER/DEVELOPMENT MODE")
        print("   Action Required: Complete all compliance items before production")
        print("\n   This is expected for initial setup and testing.")
        print("   Replace placeholder assets and complete legal clearances")
        print("   before deploying to production or THIIO network.")
    else:
        print("\n✅ THIIO compliance verification complete")
    
    print("\n📊 Next Steps:")
    print("   1. Review compliance report in output/reports/")
    print("   2. Complete legal compliance checklist")
    print("   3. Obtain THIIO certification")
    print("   4. Deploy to production platforms")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

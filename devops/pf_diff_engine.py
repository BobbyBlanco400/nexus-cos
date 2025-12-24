#!/usr/bin/env python3
"""
NEXUS COS - PF Diff & Gap Analysis Engine
Compares current stack state against expected PF configurations
Mode: audit_then_overlay | Risk: ZERO | Downtime: NONE
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

class PFDiffEngine:
    def __init__(self):
        self.baseline = {}
        self.expected = {}
        self.diff = []
        self.repo_root = Path(__file__).parent.parent
        
    def load_current_stack_state(self) -> Dict[str, Any]:
        """Load the current state of the Nexus COS stack"""
        state = {
            "tenant_features": {
                "live_streaming": self._check_service_exists("modules/nexus-stream"),
                "vod": self._check_service_exists("modules/vod-service"),
                "ppv": self._check_config_exists("config/ppv.config.js"),
            },
            "media_stack": {
                "streaming_backend": self._check_service_exists("backend/streaming"),
                "pixel_streaming": self._check_service_exists("PixelStreamingInfrastructure"),
                "cdn_integration": self._check_config_exists("nginx/nginx.conf"),
            },
            "monetization": {
                "subscriptions": self._check_db_table("subscriptions"),
                "tipping": self._check_db_table("tips"),
                "ppv": self._check_db_table("ppv_purchases"),
                "nexcoin_wallet": self._check_db_table("user_wallets"),
            },
            "wallet_rules": {
                "nexcoin_only": self._check_env_var("WALLET_TYPE", "nexcoin"),
                "no_fiat": not self._check_env_var("FIAT_ENABLED", "true"),
                "admin_unlimited": self._check_db_record("user_wallets", "admin_nexus", "is_unlimited", True),
            },
            "admin_policies": {
                "downgrade_prevention": self._check_config_exists("config/admin_lock_rules.js"),
                "tenant_capability_lock": self._check_config_exists("config/tenant_capabilities.js"),
                "founder_access_keys": self._check_db_table("users"),
            }
        }
        return state
    
    def load_pf_requirements(self, pf_name: str) -> Dict[str, Any]:
        """Load expected requirements from PF specification"""
        requirements = {
            "tenant_features": {
                "live_streaming": True,
                "vod": True,
                "ppv": True,
            },
            "media_stack": {
                "streaming_backend": True,
                "pixel_streaming": True,
                "cdn_integration": True,
            },
            "monetization": {
                "subscriptions": True,
                "tipping": True,
                "ppv": True,
                "nexcoin_wallet": True,
            },
            "wallet_rules": {
                "nexcoin_only": True,
                "no_fiat": True,
                "admin_unlimited": True,
            },
            "admin_policies": {
                "downgrade_prevention": True,
                "tenant_capability_lock": True,
                "founder_access_keys": True,
            }
        }
        return requirements
    
    def compare(self, baseline: Dict, expected: Dict) -> List[Dict]:
        """Compare baseline against expected and identify gaps"""
        diff = []
        
        def recursive_compare(base_dict, exp_dict, path=""):
            for key, exp_value in exp_dict.items():
                current_path = f"{path}.{key}" if path else key
                
                if key not in base_dict:
                    diff.append({
                        "item": current_path,
                        "status": "MISSING",
                        "action": "APPLY",
                        "exists": False,
                        "expected": exp_value,
                        "current": None
                    })
                elif isinstance(exp_value, dict):
                    recursive_compare(base_dict[key], exp_value, current_path)
                elif base_dict[key] == exp_value:
                    diff.append({
                        "item": current_path,
                        "status": "OK",
                        "action": "SKIP",
                        "exists": True,
                        "expected": exp_value,
                        "current": base_dict[key]
                    })
                else:
                    diff.append({
                        "item": current_path,
                        "status": "MISMATCH",
                        "action": "APPLY",
                        "exists": True,
                        "expected": exp_value,
                        "current": base_dict[key]
                    })
        
        recursive_compare(baseline, expected)
        return diff
    
    def export_report(self, diff: List[Dict], output_path: str):
        """Export diff report to JSON file"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "pf_name": "nexus-pf-verification-reconcile",
            "mode": "audit_then_overlay",
            "total_items": len(diff),
            "items_to_apply": len([d for d in diff if d["action"] == "APPLY"]),
            "items_to_skip": len([d for d in diff if d["action"] == "SKIP"]),
            "already_present": [d["item"] for d in diff if d["status"] == "OK"],
            "newly_applied": [d["item"] for d in diff if d["action"] == "APPLY"],
            "details": diff
        }
        
        output_file = self.repo_root / output_path
        output_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"✅ Report exported to: {output_path}")
        return report
    
    # Helper methods for state checking
    def _check_service_exists(self, path: str) -> bool:
        """Check if a service directory exists"""
        return (self.repo_root / path).exists()
    
    def _check_config_exists(self, path: str) -> bool:
        """Check if a config file exists"""
        return (self.repo_root / path).exists()
    
    def _check_db_table(self, table_name: str) -> bool:
        """Check if database table is referenced in schema or migrations"""
        # Check in database directory
        db_dir = self.repo_root / "database"
        if not db_dir.exists():
            return False
        
        for sql_file in db_dir.glob("*.sql"):
            content = sql_file.read_text()
            if f"CREATE TABLE" in content and table_name in content:
                return True
        return False
    
    def _check_db_record(self, table: str, username: str, field: str, expected_value: Any) -> bool:
        """Check if specific database record configuration exists"""
        sql_file = self.repo_root / "database" / "preload_casino_accounts.sql"
        if not sql_file.exists():
            return False
        
        content = sql_file.read_text()
        return username in content and field in content
    
    def _check_env_var(self, var_name: str, expected_value: str) -> bool:
        """Check if environment variable is set correctly"""
        env_file = self.repo_root / ".env"
        if not env_file.exists():
            return False
        
        content = env_file.read_text()
        return f"{var_name}={expected_value}" in content
    
    def run(self):
        """Main execution flow"""
        print("🔎 Loading current stack state...")
        self.baseline = self.load_current_stack_state()
        
        print("📋 Loading PF requirements...")
        self.expected = self.load_pf_requirements("nexus-tenant-parity-enforcement")
        
        print("🧠 Comparing baseline vs expected...")
        self.diff = self.compare(self.baseline, self.expected)
        
        print("📄 Generating verification report...")
        report = self.export_report(self.diff, "devops/pf_verification_report.json")
        
        print("\n" + "="*60)
        print("VERIFICATION SUMMARY")
        print("="*60)
        print(f"Total items checked: {report['total_items']}")
        print(f"Already present: {report['items_to_skip']}")
        print(f"Need to apply: {report['items_to_apply']}")
        print("="*60)
        
        return report

if __name__ == "__main__":
    engine = PFDiffEngine()
    report = engine.run()
    
    # Exit with error code if there are items to apply
    if report['items_to_apply'] > 0:
        print(f"\n⚠️  {report['items_to_apply']} items need attention")
        sys.exit(1)
    else:
        print("\n✅ All required components are present")
        sys.exit(0)

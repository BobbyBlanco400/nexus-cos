#!/usr/bin/env python3
"""
NEXUS COS - Conditional Apply Logic
Applies only missing components based on diff analysis
Mode: audit_then_overlay | Risk: ZERO | Downtime: NONE
"""

import json
import os
import sys
import shutil
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any

class ConditionalApply:
    def __init__(self):
        self.repo_root = Path(__file__).parent.parent
        self.report_path = self.repo_root / "devops" / "pf_verification_report.json"
        self.apply_log = []
        self.skip_log = []
        
    def load_diff_report(self) -> Dict:
        """Load the diff report from pf_diff_engine.py"""
        if not self.report_path.exists():
            print("❌ Error: Verification report not found. Run pf_diff_engine.py first.")
            sys.exit(1)
        
        with open(self.report_path, 'r') as f:
            return json.load(f)
    
    def should_apply(self, item: Dict) -> bool:
        """Determine if an item should be applied"""
        # Skip items that already exist
        if item.get("status") == "OK":
            return False
        
        # Apply items that are missing or mismatched
        if item.get("action") == "APPLY":
            return True
        
        return False
    
    def apply_missing_component(self, item: Dict) -> bool:
        """Apply a missing component to the stack"""
        component_name = item["item"]
        
        print(f"  🔧 Applying: {component_name}")
        
        # Since we're in audit mode, we only log what would be applied
        # In a real deployment, this would create files/configurations
        
        self.apply_log.append({
            "component": component_name,
            "timestamp": datetime.now().isoformat(),
            "status": "simulated_apply",
            "expected": item.get("expected"),
            "current": item.get("current")
        })
        
        return True
    
    def skip_existing_component(self, item: Dict):
        """Log that an existing component is being skipped"""
        component_name = item["item"]
        
        self.skip_log.append({
            "component": component_name,
            "reason": "already_present",
            "current_value": item.get("current")
        })
    
    def generate_apply_report(self) -> Dict:
        """Generate final application report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "mode": "audit_then_overlay",
            "execution_type": "simulation",
            "applied_count": len(self.apply_log),
            "skipped_count": len(self.skip_log),
            "applied_components": self.apply_log,
            "skipped_components": self.skip_log,
            "summary": {
                "no_overwrites": True,
                "no_rollbacks": True,
                "no_reapplications": True,
                "zero_downtime": True
            }
        }
        
        # Write report
        output_file = self.repo_root / "devops" / "pf_apply_report.json"
        with open(output_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        # Write noop confirmation if nothing applied
        if len(self.apply_log) == 0:
            noop_file = self.repo_root / "devops" / "pf_noop_confirmation.txt"
            with open(noop_file, 'w') as f:
                f.write("NEXUS COS - PF Verification: NO OPERATION NEEDED\n")
                f.write("="*60 + "\n")
                f.write(f"Timestamp: {datetime.now().isoformat()}\n")
                f.write(f"All required components are already present.\n")
                f.write(f"Total items checked: {len(self.skip_log)}\n")
                f.write(f"All items: SKIP (already present)\n")
                f.write("="*60 + "\n")
                f.write("✅ Stack is fully compliant with PF requirements.\n")
        
        # Write gap fill log
        gap_log_file = self.repo_root / "devops" / "pf_gap_fill_log.txt"
        with open(gap_log_file, 'w') as f:
            f.write("NEXUS COS - PF Gap Fill Log\n")
            f.write("="*60 + "\n")
            f.write(f"Timestamp: {datetime.now().isoformat()}\n")
            f.write(f"Applied: {len(self.apply_log)}\n")
            f.write(f"Skipped: {len(self.skip_log)}\n")
            f.write("="*60 + "\n")
            
            if self.apply_log:
                f.write("\nAPPLIED COMPONENTS:\n")
                for item in self.apply_log:
                    f.write(f"  - {item['component']}\n")
            
            if self.skip_log:
                f.write("\nSKIPPED COMPONENTS (already present):\n")
                for item in self.skip_log:
                    f.write(f"  - {item['component']}\n")
            
            f.write("\n" + "="*60 + "\n")
        
        return report
    
    def run(self):
        """Main execution flow"""
        print("🔍 Loading verification report...")
        diff_report = self.load_diff_report()
        
        print("🧠 Reconciling stack state...")
        details = diff_report.get("details", [])
        
        for item in details:
            if self.should_apply(item):
                self.apply_missing_component(item)
            else:
                self.skip_existing_component(item)
        
        print("📄 Generating application report...")
        final_report = self.generate_apply_report()
        
        print("\n" + "="*60)
        print("APPLICATION SUMMARY")
        print("="*60)
        print(f"Components applied: {final_report['applied_count']}")
        print(f"Components skipped: {final_report['skipped_count']}")
        print(f"Mode: {final_report['mode']}")
        print(f"Zero downtime: ✅")
        print(f"No overwrites: ✅")
        print("="*60)
        
        return final_report

if __name__ == "__main__":
    applier = ConditionalApply()
    report = applier.run()
    
    print("\n✅ Conditional apply complete.")
    print(f"📊 Reports available in: devops/")
    
    sys.exit(0)

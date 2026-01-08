#!/usr/bin/env python3
"""
Canon-Verifier: Main Orchestrator
Executes all verification phases in sequence and generates structured outputs
"""

import os
import sys
import subprocess
import json
from datetime import datetime

class CanonVerifierOrchestrator:
    """Orchestrates all canon-verifier phases"""
    
    def __init__(self):
        self.base_dir = os.path.dirname(os.path.abspath(__file__))
        self.output_dir = os.path.join(self.base_dir, 'output')
        self.phases = []
        self.results = {}
    
    def setup(self):
        """Setup output directory"""
        os.makedirs(self.output_dir, exist_ok=True)
        print(f"Canon-Verifier Orchestrator")
        print(f"Output directory: {self.output_dir}")
        print(f"Timestamp: {datetime.utcnow().isoformat()}Z\n")
        print("="*100)
    
    def run_phase(self, name: str, script_path: str) -> bool:
        """Run a single verification phase"""
        print(f"\n{'='*100}")
        print(f"PHASE: {name}")
        print(f"{'='*100}\n")
        
        try:
            result = subprocess.run(
                ['python3', script_path],
                cwd=self.base_dir,
                capture_output=False,
                text=True,
                timeout=30
            )
            
            success = result.returncode == 0
            self.results[name] = {
                'success': success,
                'exit_code': result.returncode
            }
            
            if success:
                print(f"\n✓ Phase '{name}' completed successfully")
            else:
                print(f"\n✗ Phase '{name}' failed with exit code {result.returncode}")
            
            return success
            
        except subprocess.TimeoutExpired:
            print(f"\n✗ Phase '{name}' timed out")
            self.results[name] = {'success': False, 'exit_code': -1, 'error': 'timeout'}
            return False
        except Exception as e:
            print(f"\n✗ Phase '{name}' error: {e}")
            self.results[name] = {'success': False, 'exit_code': -1, 'error': str(e)}
            return False
    
    def run_all_phases(self):
        """Run all verification phases in sequence"""
        
        phases = [
            ("System Inventory", "inventory_phase/enumerate_services.py"),
            ("Service Responsibility Validation", "responsibility_validation/validate_claims.py"),
            ("Dependency Graph", "dependency_tests/dependency_graph.py"),
            ("Event Orchestration", "event_orchestration/canonical_events.py"),
            ("Meta-Claim Validation", "meta_claim_validation/identity_metatwin_chain.py"),
            ("Hardware Simulation", "hardware_simulation/simulate_vhardware.py"),
            ("Performance Sanity", "performance_sanity/check_runtime_health.py"),
            ("Docker/PM2 Mapping", "extensions/docker_pm2_mapping.py"),
            ("Service Responsibility Matrix", "extensions/service_responsibility_matrix.py"),
            ("Final Verdict", "final_verdict/generate_verdict.py"),
        ]
        
        for name, script in phases:
            script_path = os.path.join(self.base_dir, script)
            if os.path.exists(script_path):
                self.run_phase(name, script_path)
            else:
                print(f"\n⚠ Skipping '{name}' - script not found: {script_path}")
    
    def print_summary(self):
        """Print execution summary"""
        print(f"\n\n{'='*100}")
        print("CANON-VERIFIER EXECUTION SUMMARY")
        print(f"{'='*100}\n")
        
        total = len(self.results)
        successful = sum(1 for r in self.results.values() if r['success'])
        failed = total - successful
        
        print(f"Total Phases: {total}")
        print(f"Successful: {successful}")
        print(f"Failed: {failed}")
        
        if failed > 0:
            print(f"\n⚠ Failed Phases:")
            for name, result in self.results.items():
                if not result['success']:
                    error_msg = result.get('error', f"exit code {result.get('exit_code', 'unknown')}")
                    print(f"  - {name}: {error_msg}")
        
        # List generated artifacts
        print(f"\nGenerated Artifacts:")
        if os.path.exists(self.output_dir):
            for filename in sorted(os.listdir(self.output_dir)):
                if filename.endswith('.json'):
                    filepath = os.path.join(self.output_dir, filename)
                    size = os.path.getsize(filepath)
                    print(f"  ✓ {filename} ({size:,} bytes)")
        
        print(f"\n{'='*100}\n")
        
        # Check final verdict
        verdict_file = os.path.join(self.output_dir, 'canon-verdict.json')
        if os.path.exists(verdict_file):
            with open(verdict_file, 'r') as f:
                verdict_data = json.load(f)
                verdict = verdict_data.get('verdict', {})
                truth = verdict.get('executive_truth', 'Unknown')
                
                print(f"EXECUTIVE TRUTH: {truth}")
                print(f"Rationale: {verdict.get('rationale', 'N/A')}\n")
        
        return failed == 0

def main():
    """Main orchestrator entry point"""
    orchestrator = CanonVerifierOrchestrator()
    orchestrator.setup()
    orchestrator.run_all_phases()
    success = orchestrator.print_summary()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

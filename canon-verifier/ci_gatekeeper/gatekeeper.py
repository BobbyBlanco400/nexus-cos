#!/usr/bin/env python3
"""
Canon-Verifier: CI Gatekeeper Mode
Fail-fast read-only CI validation ensuring canon truth
"""

import json
import os
import sys

def load_canon_verdict() -> dict:
    """Load the canon verdict from verification run"""
    verdict_file = os.path.join(os.path.dirname(__file__), '..', 'output', 'canon-verdict.json')
    
    if not os.path.exists(verdict_file):
        print("❌ CI FAIL: Canon verdict not found")
        print(f"   Expected file: {verdict_file}")
        print("   Run canon-verifier before CI gatekeeper")
        sys.exit(1)
    
    with open(verdict_file, 'r') as f:
        return json.load(f)

def evaluate_verdict(verdict_data: dict) -> tuple:
    """Evaluate verdict and determine CI pass/fail"""
    
    verdict = verdict_data.get('verdict', {})
    executive_truth = verdict.get('executive_truth', 'Unknown')
    
    # CI gatekeeper rules
    critical_blockers = len(verdict.get('critical_blockers', []))
    verified_systems = len(verdict.get('verified_systems', []))
    degraded_systems = len(verdict.get('degraded_systems', []))
    
    # Determine pass/fail
    if "Fully operational" in executive_truth:
        return True, "CI PASS: Canon integrity verified - fully operational OS"
    
    elif "Operational with degradations" in executive_truth:
        if degraded_systems <= 2:  # Allow minor degradations
            return True, f"CI PASS: Canon integrity verified with {degraded_systems} minor degradation(s)"
        else:
            return False, f"CI FAIL: Too many degradations ({degraded_systems}) - threshold exceeded"
    
    elif "Partially operational" in executive_truth:
        return False, f"CI FAIL: Canon truth broken - {critical_blockers} critical blocker(s)"
    
    else:
        return False, f"CI FAIL: Cannot determine operational status - {executive_truth}"

def print_verdict_summary(verdict_data: dict):
    """Print verdict summary"""
    verdict = verdict_data.get('verdict', {})
    
    print("\n" + "="*80)
    print("CANON VERIFIER - CI GATEKEEPER REPORT")
    print("="*80)
    print(f"\nExecutive Truth: {verdict.get('executive_truth', 'Unknown')}")
    print(f"Rationale: {verdict.get('rationale', 'N/A')}")
    print(f"\nVerified Systems: {len(verdict.get('verified_systems', []))}")
    print(f"Degraded Systems: {len(verdict.get('degraded_systems', []))}")
    print(f"Ornamental Systems: {len(verdict.get('ornamental_systems', []))}")
    print(f"Critical Blockers: {len(verdict.get('critical_blockers', []))}")
    
    if verdict.get('critical_blockers'):
        print("\n⚠️  CRITICAL BLOCKERS:")
        for blocker in verdict['critical_blockers']:
            service = blocker.get('service', blocker.get('type', 'Unknown'))
            issue = blocker.get('issue', blocker.get('message', 'Unknown'))
            print(f"  - {service}: {issue}")
    
    print("="*80 + "\n")

def main():
    """Main CI gatekeeper"""
    print("Canon-Verifier: Running CI Gatekeeper...")
    
    # Load verdict
    verdict_data = load_canon_verdict()
    
    # Print summary
    print_verdict_summary(verdict_data)
    
    # Evaluate
    passed, message = evaluate_verdict(verdict_data)
    
    # Output result
    if passed:
        print(f"✅ {message}")
        sys.exit(0)
    else:
        print(f"❌ {message}")
        print("\nCI pipeline blocked. Fix critical issues before merge.")
        sys.exit(1)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Canon-Verifier: Final Verdict Generation
Generates canon verdict with 4-category classification
"""

import json
import os
import subprocess

def load_phase_results() -> dict:
    """Load results from all verification phases"""
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    
    results = {}
    result_files = [
        'inventory.json',
        'service-responsibility-matrix.json',
        'dependency-graph.json',
        'event-propagation-report.json',
        'meta-claim-validation.json',
        'hardware-simulation.json',
        'performance-sanity.json'
    ]
    
    for filename in result_files:
        filepath = os.path.join(output_dir, filename)
        if os.path.exists(filepath):
            with open(filepath, 'r') as f:
                results[filename.replace('.json', '')] = json.load(f)
    
    return results

def generate_verdict(phase_results: dict) -> dict:
    """Generate final verdict based on all phase results"""
    
    verdict = {
        'verified_systems': [],
        'degraded_systems': [],
        'ornamental_systems': [],
        'critical_blockers': [],
        'executive_truth': 'Unknown'
    }
    
    # Analyze service responsibility matrix
    if 'service-responsibility-matrix' in phase_results:
        srm = phase_results['service-responsibility-matrix']
        for service in srm.get('services_tested', []):
            if service['category'] == 'VERIFIED':
                verdict['verified_systems'].append({
                    'name': service['name'],
                    'responsibility': service['responsibility'],
                    'evidence': service['message']
                })
            elif service['category'] == 'DEGRADED':
                verdict['degraded_systems'].append({
                    'name': service['name'],
                    'issue': service['message']
                })
            elif service['category'] == 'BLOCKED':
                verdict['critical_blockers'].append({
                    'service': service['name'],
                    'issue': service['message'],
                    'severity': 'critical'
                })
    
    # Analyze performance sanity
    if 'performance-sanity' in phase_results:
        perf = phase_results['performance-sanity']
        for issue in perf.get('issues_detected', []):
            if issue['severity'] == 'critical':
                verdict['critical_blockers'].append(issue)
    
    # Generate executive truth statement
    total_services = len(verdict['verified_systems']) + len(verdict['degraded_systems']) + len(verdict['ornamental_systems'])
    verified_count = len(verdict['verified_systems'])
    blocker_count = len(verdict['critical_blockers'])
    
    if blocker_count > 0:
        verdict['executive_truth'] = "Partially operational architecture"
        verdict['rationale'] = f"{blocker_count} critical blocker(s) prevent full operation"
    elif len(verdict['degraded_systems']) > 0:
        verdict['executive_truth'] = "Operational with degradations"
        verdict['rationale'] = f"{len(verdict['degraded_systems'])} service(s) show degraded behavior"
    elif verified_count > 0 and total_services > 0:
        verdict['executive_truth'] = "Fully operational operating system"
        verdict['rationale'] = f"{verified_count}/{total_services} services verified (100%)"
    else:
        verdict['executive_truth'] = "Insufficient evidence for determination"
        verdict['rationale'] = "Limited service verification capability in current environment"
    
    return verdict

def main():
    """Main verdict generation"""
    print("Canon-Verifier: Generating final verdict...")
    
    phase_results = load_phase_results()
    verdict = generate_verdict(phase_results)
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'verdict': verdict,
        'phase_results_analyzed': list(phase_results.keys())
    }
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'canon-verdict.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Canon verdict saved: {output_file}")
    print(f"\n{'='*80}")
    print(f"EXECUTIVE TRUTH: {verdict['executive_truth']}")
    print(f"{'='*80}")
    print(f"  Verified systems: {len(verdict['verified_systems'])}")
    print(f"  Degraded systems: {len(verdict['degraded_systems'])}")
    print(f"  Ornamental systems: {len(verdict['ornamental_systems'])}")
    print(f"  Critical blockers: {len(verdict['critical_blockers'])}")
    print(f"\nRationale: {verdict.get('rationale', 'N/A')}")
    
    return result

if __name__ == "__main__":
    main()

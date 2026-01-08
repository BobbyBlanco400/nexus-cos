#!/usr/bin/env python3
"""
Canon-Verifier Extension: Service Responsibility Matrix (SRM)
Evidence-backed table of all services with claims and observed behavior
"""

import json
import os
import subprocess

def build_service_responsibility_matrix() -> list:
    """Build comprehensive Service Responsibility Matrix"""
    
    # Load results from various phases
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    
    srm = []
    
    # Load service responsibility validation
    resp_file = os.path.join(output_dir, 'service-responsibility-matrix.json')
    if os.path.exists(resp_file):
        with open(resp_file, 'r') as f:
            resp_data = json.load(f)
            for service in resp_data.get('services_tested', []):
                srm.append({
                    'service_name': service['name'],
                    'claimed_responsibility': service['responsibility'],
                    'source_path': service.get('source_path', 'unknown'),
                    'proof_type': service['proof_type'],
                    'observed_behavior': service['message'],
                    'canon_status': service['category'],
                    'endpoint': service.get('endpoint', 'N/A'),
                    'evidence': {
                        'is_operational': service['is_operational'],
                        'status_code': service['status_code'],
                        'response': service['message']
                    }
                })
    
    # Load runtime mapping
    runtime_file = os.path.join(output_dir, 'runtime-truth-map.json')
    if os.path.exists(runtime_file):
        with open(runtime_file, 'r') as f:
            runtime_data = json.load(f)
            
            # Add runtime information to SRM
            all_runtime_mappings = runtime_data.get('docker_mappings', []) + runtime_data.get('pm2_mappings', [])
            
            for mapping in all_runtime_mappings:
                # Check if service already in SRM
                service_name = mapping.get('container_name') or mapping.get('process_name')
                existing = next((s for s in srm if service_name.lower() in s['service_name'].lower()), None)
                
                if existing:
                    # Update with runtime info
                    existing['runtime_type'] = mapping['runtime']
                    existing['runtime_activity'] = mapping['observed_activity']
                else:
                    # Add new entry
                    srm.append({
                        'service_name': service_name,
                        'claimed_responsibility': mapping['declared_responsibility'],
                        'source_path': mapping['repo_path'],
                        'proof_type': 'runtime_enumeration',
                        'observed_behavior': 'running' if mapping['observed_activity'] else 'not_found',
                        'canon_status': mapping['canon_status'],
                        'runtime_type': mapping['runtime'],
                        'endpoint': mapping['interfaces'][0] if mapping['interfaces'] else 'N/A',
                        'runtime_activity': mapping['observed_activity']
                    })
    
    return srm

def analyze_srm(srm: list) -> dict:
    """Analyze Service Responsibility Matrix"""
    
    analysis = {
        'total_services': len(srm),
        'verified': sum(1 for s in srm if s['canon_status'] == 'VERIFIED' or s['canon_status'] == 'verified'),
        'degraded': sum(1 for s in srm if s['canon_status'] == 'DEGRADED'),
        'blocked': sum(1 for s in srm if s['canon_status'] == 'BLOCKED' or s['canon_status'] == 'not_running'),
        'ornamental': sum(1 for s in srm if s['canon_status'] == 'ORNAMENTAL'),
        'services_with_evidence': sum(1 for s in srm if 'evidence' in s),
        'services_with_runtime': sum(1 for s in srm if 'runtime_type' in s)
    }
    
    return analysis

def main():
    """Main SRM generation"""
    print("Canon-Verifier Extension: Building Service Responsibility Matrix...")
    
    srm = build_service_responsibility_matrix()
    analysis = analyze_srm(srm)
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'service_responsibility_matrix': srm,
        'analysis': analysis
    }
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'service-responsibility-matrix-complete.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Complete Service Responsibility Matrix saved: {output_file}")
    print(f"  Total services: {analysis['total_services']}")
    print(f"  Verified: {analysis['verified']}")
    print(f"  Degraded: {analysis['degraded']}")
    print(f"  Blocked: {analysis['blocked']}")
    print(f"  With evidence: {analysis['services_with_evidence']}")
    print(f"  With runtime info: {analysis['services_with_runtime']}")
    
    return result

if __name__ == "__main__":
    main()

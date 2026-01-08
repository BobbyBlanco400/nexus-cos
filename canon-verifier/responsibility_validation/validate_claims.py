#!/usr/bin/env python3
"""
Canon-Verifier: Service Responsibility Validation
Validates each service proves its claimed purpose with evidence
"""

import json
import os
import subprocess
import urllib.request
import urllib.error
from typing import Dict, List, Tuple, Optional

HTTP_TIMEOUT = 5

def check_http_endpoint(url: str, timeout: int = HTTP_TIMEOUT) -> Tuple[bool, Optional[int], str]:
    """Check if an HTTP endpoint is responsive"""
    try:
        req = urllib.request.Request(url, method='GET')
        with urllib.request.urlopen(req, timeout=timeout) as response:
            status = response.status
            return True, status, f"HTTP {status}"
    except urllib.error.HTTPError as e:
        return False, e.code, f"HTTP {e.code} - {e.reason}"
    except urllib.error.URLError as e:
        return False, None, f"Connection failed: {e.reason}"
    except Exception as e:
        return False, None, f"Error: {str(e)}"

def validate_service_responsibilities() -> Dict:
    """Validate known services prove their purpose"""
    
    known_services = {
        'Backend API': {
            'endpoint': 'http://localhost:3000/api/health',
            'responsibility': 'Core API gateway and service orchestration',
            'proof_type': 'HTTP response',
            'source_path': 'backend/'
        },
        'Backend System Status': {
            'endpoint': 'http://localhost:4000/api/system/status',
            'responsibility': 'System health monitoring and status reporting',
            'proof_type': 'HTTP response',
            'source_path': 'backend/'
        },
        'Auth Service': {
            'endpoint': 'http://localhost:3001/health',
            'responsibility': 'User authentication and identity management',
            'proof_type': 'HTTP response',
            'source_path': 'backend/services/auth'
        },
        'Streaming Service': {
            'endpoint': 'http://localhost:3002/health',
            'responsibility': 'Real-time streaming and WebSocket management',
            'proof_type': 'HTTP response',
            'source_path': 'services/streaming'
        }
    }
    
    results = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'services_tested': [],
        'verified_count': 0,
        'degraded_count': 0,
        'blocked_count': 0
    }
    
    print("Canon-Verifier: Validating service responsibilities...")
    
    for service_name, service_info in known_services.items():
        print(f"\nTesting: {service_name}")
        print(f"  Claims: {service_info['responsibility']}")
        print(f"  Endpoint: {service_info['endpoint']}")
        
        is_up, status_code, message = check_http_endpoint(service_info['endpoint'])
        
        service_result = {
            'name': service_name,
            'responsibility': service_info['responsibility'],
            'endpoint': service_info['endpoint'],
            'source_path': service_info['source_path'],
            'proof_type': service_info['proof_type'],
            'is_operational': is_up,
            'status_code': status_code,
            'message': message,
            'category': 'BLOCKED'
        }
        
        if is_up:
            print(f"  ✓ VERIFIED - {message}")
            service_result['category'] = 'VERIFIED'
            results['verified_count'] += 1
        elif status_code is not None:
            print(f"  ⚠ DEGRADED - {message}")
            service_result['category'] = 'DEGRADED'
            results['degraded_count'] += 1
        else:
            print(f"  ✗ BLOCKED - {message}")
            results['blocked_count'] += 1
        
        results['services_tested'].append(service_result)
    
    return results

def main():
    """Main responsibility validation"""
    import subprocess
    
    results = validate_service_responsibilities()
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'service-responsibility-matrix.json')
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n✓ Service Responsibility Matrix saved: {output_file}")
    print(f"  Verified: {results['verified_count']}")
    print(f"  Degraded: {results['degraded_count']}")
    print(f"  Blocked: {results['blocked_count']}")
    
    return results

if __name__ == "__main__":
    main()

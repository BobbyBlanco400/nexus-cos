#!/usr/bin/env python3
"""
Canon-Verifier Extension: Docker + PM2 Runtime Mapping
Maps runtime units to source paths and declared responsibilities
"""

import json
import os
import subprocess

def map_docker_to_repo() -> list:
    """Map Docker containers to repository source paths"""
    
    # Define known Docker → repo mappings
    docker_mappings = [
        {
            'container_name': 'nexus-backend',
            'repo_path': 'backend/',
            'runtime': 'docker',
            'interfaces': ['http://localhost:3000'],
            'declared_responsibility': 'Core API gateway and service orchestration',
            'observed_activity': 'requires_runtime_check',
            'canon_status': 'pending_verification'
        },
        {
            'container_name': 'nexus-auth',
            'repo_path': 'backend/services/auth',
            'runtime': 'docker',
            'interfaces': ['http://localhost:3001'],
            'declared_responsibility': 'User authentication and identity management',
            'observed_activity': 'requires_runtime_check',
            'canon_status': 'pending_verification'
        },
        {
            'container_name': 'nexus-streaming',
            'repo_path': 'services/streaming',
            'runtime': 'docker',
            'interfaces': ['http://localhost:3002'],
            'declared_responsibility': 'Real-time streaming and WebSocket management',
            'observed_activity': 'requires_runtime_check',
            'canon_status': 'pending_verification'
        }
    ]
    
    return docker_mappings

def map_pm2_to_repo() -> list:
    """Map PM2 processes to repository source paths"""
    
    # Define known PM2 → repo mappings
    pm2_mappings = [
        {
            'process_name': 'backend-api',
            'repo_path': 'backend/server.js',
            'runtime': 'pm2',
            'interfaces': ['http://localhost:3000'],
            'declared_responsibility': 'Core API gateway',
            'observed_activity': 'requires_runtime_check',
            'canon_status': 'pending_verification'
        },
        {
            'process_name': 'streaming-service',
            'repo_path': 'services/streaming/index.js',
            'runtime': 'pm2',
            'interfaces': ['http://localhost:3002'],
            'declared_responsibility': 'Streaming service',
            'observed_activity': 'requires_runtime_check',
            'canon_status': 'pending_verification'
        }
    ]
    
    return pm2_mappings

def verify_runtime_activity(mappings: list) -> list:
    """Verify if mapped services show runtime activity"""
    
    # Load inventory if available
    inventory_file = os.path.join(os.path.dirname(__file__), '..', 'output', 'inventory.json')
    if os.path.exists(inventory_file):
        with open(inventory_file, 'r') as f:
            inventory = json.load(f)
        
        # Cross-reference with inventory
        docker_names = [c['name'] for c in inventory.get('docker_containers', [])]
        pm2_names = [p['name'] for p in inventory.get('pm2_processes', [])]
        
        for mapping in mappings:
            if mapping['runtime'] == 'docker':
                mapping['observed_activity'] = mapping['container_name'] in docker_names
            elif mapping['runtime'] == 'pm2':
                mapping['observed_activity'] = mapping['process_name'] in pm2_names
            
            mapping['canon_status'] = 'verified' if mapping['observed_activity'] else 'not_running'
    
    return mappings

def main():
    """Main runtime mapping"""
    print("Canon-Verifier Extension: Mapping Docker + PM2 to repository...")
    
    docker_map = map_docker_to_repo()
    pm2_map = map_pm2_to_repo()
    
    all_mappings = docker_map + pm2_map
    all_mappings = verify_runtime_activity(all_mappings)
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'docker_mappings': [m for m in all_mappings if m['runtime'] == 'docker'],
        'pm2_mappings': [m for m in all_mappings if m['runtime'] == 'pm2'],
        'total_mappings': len(all_mappings),
        'verified_count': sum(1 for m in all_mappings if m['canon_status'] == 'verified'),
        'not_running_count': sum(1 for m in all_mappings if m['canon_status'] == 'not_running')
    }
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'runtime-truth-map.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Runtime truth map saved: {output_file}")
    print(f"  Total mappings: {result['total_mappings']}")
    print(f"  Verified (running): {result['verified_count']}")
    print(f"  Not running: {result['not_running_count']}")
    
    return result

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Canon-Verifier: Inventory Phase - Service Enumeration
Enumerates all runtime units (Docker, PM2, ports, processes)
"""

import json
import subprocess
import os
from typing import Dict, List, Tuple

def list_docker_containers() -> List[Dict]:
    """Enumerate all Docker containers (running + stopped)"""
    try:
        result = subprocess.run(
            ['docker', 'ps', '-a', '--format', '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            return []
        
        containers = []
        for line in result.stdout.strip().split('\n'):
            if line:
                parts = line.split('\t')
                if len(parts) >= 4:
                    containers.append({
                        'id': parts[0],
                        'name': parts[1],
                        'image': parts[2],
                        'status': parts[3],
                        'ports': parts[4] if len(parts) > 4 else '',
                        'runtime_type': 'docker'
                    })
        return containers
    except Exception as e:
        print(f"Docker enumeration failed: {e}")
        return []

def list_pm2_processes() -> List[Dict]:
    """Enumerate all PM2 processes"""
    try:
        result = subprocess.run(
            ['pm2', 'jlist'],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            return []
        
        pm2_list = json.loads(result.stdout)
        processes = []
        
        for proc in pm2_list:
            pm2_env = proc.get('pm2_env', {})
            monit = proc.get('monit', {})
            processes.append({
                'name': proc.get('name', 'unknown'),
                'pm_id': proc.get('pm_id', -1),
                'status': pm2_env.get('status', 'unknown'),
                'pid': proc.get('pid', 0),
                'cpu': monit.get('cpu', 0),
                'memory': monit.get('memory', 0),
                'cwd': pm2_env.get('pm_cwd', ''),
                'script': pm2_env.get('pm_exec_path', ''),
                'runtime_type': 'pm2'
            })
        return processes
    except Exception as e:
        print(f"PM2 enumeration failed: {e}")
        return []

def list_listening_ports() -> List[Dict]:
    """Enumerate listening ports"""
    try:
        result = subprocess.run(
            ['ss', '-tulpn'],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            # Fallback to netstat
            result = subprocess.run(
                ['netstat', '-tulpn'],
                capture_output=True,
                text=True,
                timeout=10
            )
        
        ports = []
        for line in result.stdout.strip().split('\n'):
            if 'LISTEN' in line:
                parts = line.split()
                if len(parts) >= 5:
                    local_addr = parts[4] if 'ss' in result.args[0] else parts[3]
                    if ':' in local_addr:
                        port = local_addr.split(':')[-1]
                        ports.append({
                            'port': port,
                            'address': local_addr,
                            'protocol': parts[0] if 'ss' in result.args[0] else parts[0],
                            'raw': line.strip()
                        })
        return ports
    except Exception as e:
        print(f"Port enumeration failed: {e}")
        return []

def get_system_load() -> Dict:
    """Get system load averages"""
    try:
        result = subprocess.run(['uptime'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0 and 'load average:' in result.stdout:
            load_str = result.stdout.split('load average:')[-1].strip()
            loads = [float(x.strip()) for x in load_str.split(',')]
            return {
                'load_1min': loads[0] if len(loads) > 0 else 0,
                'load_5min': loads[1] if len(loads) > 1 else 0,
                'load_15min': loads[2] if len(loads) > 2 else 0,
                'raw': result.stdout.strip()
            }
    except Exception as e:
        print(f"System load check failed: {e}")
    
    return {'load_1min': 0, 'load_5min': 0, 'load_15min': 0, 'raw': ''}

def main():
    """Main inventory enumeration"""
    print("Canon-Verifier: Enumerating system inventory...")
    
    inventory = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'docker_containers': list_docker_containers(),
        'pm2_processes': list_pm2_processes(),
        'listening_ports': list_listening_ports(),
        'system_load': get_system_load(),
        'total_runtime_units': 0
    }
    
    inventory['total_runtime_units'] = len(inventory['docker_containers']) + len(inventory['pm2_processes'])
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'inventory.json')
    with open(output_file, 'w') as f:
        json.dump(inventory, f, indent=2)
    
    print(f"✓ Inventory saved: {output_file}")
    print(f"  Docker containers: {len(inventory['docker_containers'])}")
    print(f"  PM2 processes: {len(inventory['pm2_processes'])}")
    print(f"  Listening ports: {len(inventory['listening_ports'])}")
    print(f"  Total runtime units: {inventory['total_runtime_units']}")
    
    return inventory

if __name__ == "__main__":
    main()

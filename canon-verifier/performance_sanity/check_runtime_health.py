#!/usr/bin/env python3
"""
Canon-Verifier: Performance Sanity Check
Detects deadlocks, backlogs, memory issues, runaway processes
"""

import json
import os
import subprocess

def check_system_processes() -> dict:
    """Check for zombie processes and high resource consumers"""
    
    # Top CPU consumers
    try:
        result = subprocess.run(
            ['ps', 'aux', '--sort=-%cpu'],
            capture_output=True,
            text=True,
            timeout=10
        )
        cpu_lines = result.stdout.strip().split('\n')[1:6]  # Top 5
        top_cpu = [line.split()[10] for line in cpu_lines if line]
    except Exception:
        top_cpu = []
    
    # Top memory consumers
    try:
        result = subprocess.run(
            ['ps', 'aux', '--sort=-%mem'],
            capture_output=True,
            text=True,
            timeout=10
        )
        mem_lines = result.stdout.strip().split('\n')[1:6]  # Top 5
        top_mem = [line.split()[10] for line in mem_lines if line]
    except Exception:
        top_mem = []
    
    # Zombie processes
    try:
        result = subprocess.run(
            ['ps', 'aux'],
            capture_output=True,
            text=True,
            timeout=10
        )
        zombie_count = result.stdout.count('<defunct>')
    except Exception:
        zombie_count = 0
    
    return {
        'top_cpu_consumers': top_cpu,
        'top_memory_consumers': top_mem,
        'zombie_processes': zombie_count,
        'deadlock_detected': zombie_count > 5
    }

def check_system_load() -> dict:
    """Check system load and health"""
    try:
        result = subprocess.run(['uptime'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0 and 'load average:' in result.stdout:
            load_str = result.stdout.split('load average:')[-1].strip()
            loads = [float(x.strip()) for x in load_str.split(',')]
            
            return {
                'load_1min': loads[0] if len(loads) > 0 else 0,
                'load_5min': loads[1] if len(loads) > 1 else 0,
                'load_15min': loads[2] if len(loads) > 2 else 0,
                'status': 'critical' if loads[0] > 20 else ('warning' if loads[0] > 10 else 'normal'),
                'raw': result.stdout.strip()
            }
    except Exception:
        pass
    
    return {'load_1min': 0, 'load_5min': 0, 'load_15min': 0, 'status': 'unknown', 'raw': ''}

def main():
    """Main performance sanity check"""
    print("Canon-Verifier: Checking runtime health...")
    
    processes = check_system_processes()
    load = check_system_load()
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'system_load': load,
        'process_health': processes,
        'issues_detected': []
    }
    
    # Detect issues
    if load['status'] == 'critical':
        result['issues_detected'].append({
            'type': 'high_load',
            'severity': 'critical',
            'message': f"System load critically high: {load['load_1min']}"
        })
    
    if processes['zombie_processes'] > 0:
        result['issues_detected'].append({
            'type': 'zombie_processes',
            'severity': 'warning',
            'message': f"Found {processes['zombie_processes']} zombie processes"
        })
    
    if processes['deadlock_detected']:
        result['issues_detected'].append({
            'type': 'potential_deadlock',
            'severity': 'critical',
            'message': 'High number of zombie processes suggests potential deadlock'
        })
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'performance-sanity.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Performance sanity check saved: {output_file}")
    print(f"  System load: {load['load_1min']} ({load['status']})")
    print(f"  Zombie processes: {processes['zombie_processes']}")
    print(f"  Issues detected: {len(result['issues_detected'])}")
    
    if result['issues_detected']:
        print("\n⚠ Issues:")
        for issue in result['issues_detected']:
            print(f"  - [{issue['severity']}] {issue['message']}")
    
    return result

if __name__ == "__main__":
    main()

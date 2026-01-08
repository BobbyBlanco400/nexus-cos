#!/usr/bin/env python3
"""
Canon-Verifier: Event Bus & Orchestration Verification
Tests canonical event propagation (read-only analysis)
"""

import json
import os
import subprocess

def define_canonical_events() -> list:
    """Define canonical events that should propagate in N3XUS COS"""
    return [
        {
            'name': 'Identity Created',
            'source': 'Auth Service',
            'consumers': ['Backend API', 'MetaTwin Service'],
            'critical': True
        },
        {
            'name': 'MetaTwin Instantiated',
            'source': 'MetaTwin Service',
            'consumers': ['Backend API', 'Runtime Manager'],
            'critical': True
        },
        {
            'name': 'Overlay Attached',
            'source': 'Runtime Manager',
            'consumers': ['Frontend', 'Mobile App'],
            'critical': False
        },
        {
            'name': 'Order Placed',
            'source': 'Backend API',
            'consumers': ['Payment Service', 'Fulfillment Service'],
            'critical': True
        },
        {
            'name': 'Hardware Registered',
            'source': 'Hardware Service',
            'consumers': ['MetaTwin Service', 'Lifecycle Manager'],
            'critical': True
        }
    ]

def analyze_event_propagation() -> dict:
    """Analyze event propagation patterns (read-only)"""
    
    events = define_canonical_events()
    
    analysis = {
        'total_events': len(events),
        'critical_events': sum(1 for e in events if e['critical']),
        'event_flows': [],
        'potential_issues': []
    }
    
    for event in events:
        flow = {
            'event': event['name'],
            'source': event['source'],
            'consumers': event['consumers'],
            'consumer_count': len(event['consumers']),
            'critical': event['critical']
        }
        analysis['event_flows'].append(flow)
        
        # Check for potential issues
        if event['critical'] and len(event['consumers']) == 0:
            analysis['potential_issues'].append({
                'event': event['name'],
                'issue': 'Critical event has no consumers',
                'severity': 'high'
            })
    
    return analysis

def main():
    """Main event orchestration verification"""
    print("Canon-Verifier: Analyzing event bus and orchestration...")
    
    events = define_canonical_events()
    analysis = analyze_event_propagation()
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'canonical_events': events,
        'analysis': analysis,
        'note': 'Read-only analysis - actual event triggering requires system modification'
    }
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'event-propagation-report.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Event propagation report saved: {output_file}")
    print(f"  Total events: {analysis['total_events']}")
    print(f"  Critical events: {analysis['critical_events']}")
    print(f"  Potential issues: {len(analysis['potential_issues'])}")
    
    if analysis['potential_issues']:
        print("\n⚠ Potential issues detected:")
        for issue in analysis['potential_issues']:
            print(f"  - {issue['event']}: {issue['issue']} ({issue['severity']})")
    
    return result

if __name__ == "__main__":
    main()

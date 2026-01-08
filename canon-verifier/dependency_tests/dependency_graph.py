#!/usr/bin/env python3
"""
Canon-Verifier: Dependency Graph Testing
Maps and validates inter-service dependencies
"""

import json
import os
import subprocess

def build_dependency_graph() -> dict:
    """Construct dependency graph for known services"""
    
    dependencies = {
        'Backend API': {
            'depends_on': ['Auth Service', 'Database', 'Redis'],
            'consumed_by': ['Frontend', 'Mobile App'],
            'interfaces': ['http://localhost:3000'],
            'critical': True
        },
        'Auth Service': {
            'depends_on': ['Database', 'Redis'],
            'consumed_by': ['Backend API', 'All Services'],
            'interfaces': ['http://localhost:3001'],
            'critical': True
        },
        'Streaming Service': {
            'depends_on': ['Backend API', 'Redis'],
            'consumed_by': ['Frontend', 'Mobile App'],
            'interfaces': ['http://localhost:3002'],
            'critical': False
        },
        'Database': {
            'depends_on': [],
            'consumed_by': ['Backend API', 'Auth Service', 'Streaming Service'],
            'interfaces': ['postgresql://localhost:5432'],
            'critical': True
        },
        'Redis': {
            'depends_on': [],
            'consumed_by': ['Backend API', 'Auth Service', 'Streaming Service'],
            'interfaces': ['redis://localhost:6379'],
            'critical': True
        }
    }
    
    return dependencies

def analyze_dependency_edges(graph: dict) -> dict:
    """Analyze dependency edges for dead links and issues"""
    
    analysis = {
        'total_services': len(graph),
        'total_edges': 0,
        'dead_links': [],
        'critical_services': [],
        'dependency_chains': []
    }
    
    # Count edges and identify critical services
    for service, deps in graph.items():
        analysis['total_edges'] += len(deps['depends_on'])
        if deps.get('critical', False):
            analysis['critical_services'].append(service)
        
        # Check for dead links (dependencies that don't exist in graph)
        for dep in deps['depends_on']:
            if dep not in graph:
                analysis['dead_links'].append({
                    'service': service,
                    'missing_dependency': dep,
                    'severity': 'critical' if deps.get('critical') else 'warning'
                })
    
    return analysis

def main():
    """Main dependency graph generation"""
    print("Canon-Verifier: Building dependency graph...")
    
    graph = build_dependency_graph()
    analysis = analyze_dependency_edges(graph)
    
    result = {
        'timestamp': subprocess.run(['date', '-u', '+%Y-%m-%dT%H:%M:%SZ'], 
                                   capture_output=True, text=True).stdout.strip(),
        'dependency_graph': graph,
        'analysis': analysis
    }
    
    # Save to output
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'output')
    os.makedirs(output_dir, exist_ok=True)
    
    output_file = os.path.join(output_dir, 'dependency-graph.json')
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2)
    
    print(f"✓ Dependency graph saved: {output_file}")
    print(f"  Total services: {analysis['total_services']}")
    print(f"  Total edges: {analysis['total_edges']}")
    print(f"  Critical services: {len(analysis['critical_services'])}")
    print(f"  Dead links: {len(analysis['dead_links'])}")
    
    if analysis['dead_links']:
        print("\n⚠ Warning: Dead links detected:")
        for link in analysis['dead_links']:
            print(f"  - {link['service']} → {link['missing_dependency']} ({link['severity']})")
    
    return result

if __name__ == "__main__":
    main()

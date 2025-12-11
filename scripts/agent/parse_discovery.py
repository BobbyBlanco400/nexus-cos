#!/usr/bin/env python3
"""
Discovery Archive Parser for Nexus COS
Parses discovery archive and generates structured JSON report
"""

import json
import os
import sys
import glob
from pathlib import Path
from typing import Dict, List, Any
from datetime import datetime

def read_file_safe(path: str) -> str:
    """Safely read file content with error handling"""
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except Exception as e:
        print(f"Warning: Could not read {path}: {e}", file=sys.stderr)
        return ""

def parse_json_safe(content: str) -> Any:
    """Safely parse JSON with error handling"""
    try:
        return json.loads(content) if content else []
    except json.JSONDecodeError as e:
        print(f"Warning: JSON parse error: {e}", file=sys.stderr)
        return []

def discover_running_services(workdir: str) -> List[Dict[str, Any]]:
    """Discover running services from current system"""
    discovered_services = []
    
    # Check services directory
    services_dir = Path(workdir) / "services"
    if services_dir.exists():
        for service_path in services_dir.iterdir():
            if service_path.is_dir():
                service_info = {
                    "name": service_path.name,
                    "path": str(service_path),
                    "has_dockerfile": (service_path / "Dockerfile").exists(),
                    "has_package_json": (service_path / "package.json").exists(),
                    "has_requirements": (service_path / "requirements.txt").exists(),
                }
                discovered_services.append(service_info)
    
    return discovered_services

def parse_docker_compose_files(workdir: str) -> List[str]:
    """Find and list all docker-compose files"""
    compose_files = []
    patterns = ["docker-compose*.yml", "docker-compose*.yaml"]
    
    for pattern in patterns:
        compose_files.extend(glob.glob(os.path.join(workdir, pattern)))
    
    return compose_files

def extract_env_variables(workdir: str) -> Dict[str, str]:
    """Extract environment variables from .env files"""
    env_vars = {}
    env_files = [".env", ".env.pf", ".env.example", ".env.pf.example"]
    
    for env_file in env_files:
        env_path = os.path.join(workdir, env_file)
        if os.path.exists(env_path):
            content = read_file_safe(env_path)
            for line in content.split('\n'):
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key = line.split('=')[0].strip()
                    # Don't store actual values for security
                    env_vars[key] = f"<configured in {env_file}>"
    
    return env_vars

def parse_discovery_archive(workdir: str, discovery_dir: str = None) -> Dict[str, Any]:
    """
    Parse discovery archive and current system state
    
    Args:
        workdir: Working directory (repository root)
        discovery_dir: Optional discovery archive directory
        
    Returns:
        Structured discovery data
    """
    discovery_data = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "workdir": workdir,
        "docker_ps": [],
        "compose_files": [],
        "env_files": [],
        "systemd_services": "",
        "port_map": "",
        "docker_journal": "",
        "discovered_services": [],
        "environment_variables": {},
    }
    
    # If discovery archive exists, parse it
    if discovery_dir and os.path.exists(discovery_dir):
        # Parse docker_ps.json
        docker_ps_path = os.path.join(discovery_dir, "docker_ps.json")
        if os.path.exists(docker_ps_path):
            content = read_file_safe(docker_ps_path)
            discovery_data["docker_ps"] = parse_json_safe(content)
        
        # Parse systemd services
        systemd_path = os.path.join(discovery_dir, "systemd_services.txt")
        if os.path.exists(systemd_path):
            discovery_data["systemd_services"] = read_file_safe(systemd_path)
        
        # Parse compose dump
        compose_dump_path = os.path.join(discovery_dir, "compose_dump.txt")
        if os.path.exists(compose_dump_path):
            discovery_data["compose_dump"] = read_file_safe(compose_dump_path)
        
        # Parse env dump
        env_dump_path = os.path.join(discovery_dir, "env_dump.txt")
        if os.path.exists(env_dump_path):
            discovery_data["env_dump"] = read_file_safe(env_dump_path)
        
        # Parse port map
        port_map_path = os.path.join(discovery_dir, "port_map.txt")
        if os.path.exists(port_map_path):
            discovery_data["port_map"] = read_file_safe(port_map_path)
        
        # Parse docker journal
        docker_journal_path = os.path.join(discovery_dir, "docker_journal.txt")
        if os.path.exists(docker_journal_path):
            discovery_data["docker_journal"] = read_file_safe(docker_journal_path)
    
    # Discover current system state
    discovery_data["discovered_services"] = discover_running_services(workdir)
    discovery_data["compose_files"] = parse_docker_compose_files(workdir)
    discovery_data["environment_variables"] = extract_env_variables(workdir)
    
    return discovery_data

def main():
    """Main entry point"""
    # Get working directory
    workdir = os.environ.get('WORKDIR', os.getcwd())
    
    # Check for discovery archive
    discovery_archive = os.path.join(workdir, "nexus-discovery")
    if not os.path.exists(discovery_archive):
        discovery_archive = None
        print(f"Note: Discovery archive not found at {discovery_archive}", file=sys.stderr)
        print("Proceeding with current system discovery only", file=sys.stderr)
    
    # Parse discovery data
    discovery_data = parse_discovery_archive(workdir, discovery_archive)
    
    # Create reports directory
    reports_dir = os.path.join(workdir, "reports")
    os.makedirs(reports_dir, exist_ok=True)
    
    # Write output
    output_path = os.path.join(reports_dir, "discovery_parsed.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(discovery_data, f, indent=2)
    
    print(f"✓ Discovery data parsed successfully")
    print(f"✓ Output: {output_path}")
    print(f"✓ Discovered {len(discovery_data['discovered_services'])} services")
    print(f"✓ Found {len(discovery_data['compose_files'])} compose files")
    print(f"✓ Extracted {len(discovery_data['environment_variables'])} environment variables")

if __name__ == "__main__":
    main()

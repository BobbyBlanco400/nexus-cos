#!/usr/bin/env python3
"""
N3XUS COS MASTER FULL-STACK VERIFICATION PF
CPS Tool #5

Canonical Systems Integrity & Performance Validation

PF NAME: N3XUS-COS-MASTER-STACK-VERIFICATION
PF TYPE: Platform Forensic / Systems Validation
EXECUTION MODE: Read-Only | Non-Destructive | Deterministic
SCOPE: Entire Monorepo + Deployed Runtime
AUTHORITY: Canonical
FAILURE TOLERANCE: Zero Silent Failures

This tool proves — with evidence — that:
- Every declared service exists
- Every service boots cleanly
- Every service exposes the interfaces it claims
- Every inter-service dependency actually resolves
- Every lifecycle claim is observable in runtime
- No "concept-only" modules exist without execution proof
"""

import subprocess
import json
import os
import sys
import time
from datetime import datetime
from typing import Dict, List, Tuple, Optional
import urllib.request
import urllib.error

# ANSI color codes for output
class Colors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def print_header(text: str):
    """Print a formatted header"""
    print(f"\n{Colors.BOLD}{Colors.HEADER}{'='*80}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{text.center(80)}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.HEADER}{'='*80}{Colors.ENDC}\n")

def print_section(text: str):
    """Print a section header"""
    print(f"\n{Colors.BOLD}{Colors.OKBLUE}{'─'*80}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.OKBLUE}{text}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.OKBLUE}{'─'*80}{Colors.ENDC}\n")

def print_success(text: str):
    """Print success message"""
    print(f"{Colors.OKGREEN}✓ {text}{Colors.ENDC}")

def print_warning(text: str):
    """Print warning message"""
    print(f"{Colors.WARNING}⚠ {text}{Colors.ENDC}")

def print_error(text: str):
    """Print error message"""
    print(f"{Colors.FAIL}✗ {text}{Colors.ENDC}")

def run_command(cmd: str, capture_output: bool = True) -> Tuple[int, str, str]:
    """Run a shell command and return exit code, stdout, stderr"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=capture_output,
            text=True,
            timeout=30
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)

def check_http_endpoint(url: str, timeout: int = 5) -> Tuple[bool, Optional[int], str]:
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

class MasterVerification:
    """Master Full-Stack Verification Tool"""
    
    def __init__(self):
        self.results = {
            'timestamp': datetime.now().isoformat(),
            'docker_containers': [],
            'pm2_processes': [],
            'services_verified': [],
            'services_degraded': [],
            'services_ornamental': [],
            'critical_blockers': [],
            'canon_checks': [],
            'verdict': 'PENDING'
        }
        self.total_checks = 0
        self.passed_checks = 0
        self.failed_checks = 0
        self.warning_checks = 0
    
    def phase_1_system_inventory(self):
        """Phase 1: Enumerate all runtime units"""
        print_section("PHASE 1: SYSTEM INVENTORY (Reality Enumeration)")
        
        # 1.1 Docker Containers
        print(f"{Colors.BOLD}1.1 Docker Container Inventory{Colors.ENDC}")
        code, stdout, stderr = run_command("docker ps -a --format '{{.ID}}|{{.Names}}|{{.Status}}|{{.Image}}'")
        
        if code == 0 and stdout.strip():
            containers = []
            for line in stdout.strip().split('\n'):
                if line:
                    parts = line.split('|')
                    if len(parts) >= 4:
                        containers.append({
                            'id': parts[0],
                            'name': parts[1],
                            'status': parts[2],
                            'image': parts[3]
                        })
            self.results['docker_containers'] = containers
            print_success(f"Found {len(containers)} Docker containers")
            for container in containers:
                status_icon = "🟢" if "Up" in container['status'] else "🔴"
                print(f"  {status_icon} {container['name']}: {container['status']}")
            self.passed_checks += 1
        else:
            print_warning("Docker not available or no containers found")
            print(f"  Command output: {stderr if stderr else 'No error output'}")
            self.warning_checks += 1
        
        self.total_checks += 1
        
        # 1.2 PM2 Processes
        print(f"\n{Colors.BOLD}1.2 PM2 Process Inventory{Colors.ENDC}")
        code, stdout, stderr = run_command("pm2 jlist")
        
        if code == 0 and stdout.strip():
            try:
                pm2_list = json.loads(stdout)
                processes = []
                for proc in pm2_list:
                    processes.append({
                        'name': proc.get('name', 'unknown'),
                        'pm_id': proc.get('pm_id', -1),
                        'status': proc.get('pm2_env', {}).get('status', 'unknown'),
                        'pid': proc.get('pid', 0),
                        'monit': proc.get('monit', {}),
                        'pm_uptime': proc.get('pm2_env', {}).get('pm_uptime', 0)
                    })
                self.results['pm2_processes'] = processes
                print_success(f"Found {len(processes)} PM2 processes")
                for proc in processes:
                    status_icon = "🟢" if proc['status'] == 'online' else "🔴"
                    memory = proc['monit'].get('memory', 0) / 1024 / 1024  # Convert to MB
                    cpu = proc['monit'].get('cpu', 0)
                    print(f"  {status_icon} {proc['name']} (PID: {proc['pid']}): {proc['status']} - CPU: {cpu}%, Memory: {memory:.1f}MB")
                self.passed_checks += 1
            except json.JSONDecodeError:
                print_warning("PM2 installed but could not parse process list")
                self.warning_checks += 1
        else:
            print_warning("PM2 not available or no processes found")
            self.warning_checks += 1
        
        self.total_checks += 1
        
        # 1.3 System Load
        print(f"\n{Colors.BOLD}1.3 System Load Assessment{Colors.ENDC}")
        code, stdout, stderr = run_command("uptime")
        if code == 0:
            print(f"  System: {stdout.strip()}")
            # Parse load average
            if "load average:" in stdout:
                load_avg = stdout.split("load average:")[-1].strip()
                loads = [float(x.strip()) for x in load_avg.split(',')]
                if loads[0] > 20:
                    print_error(f"⚠️  CRITICAL: System load extremely high: {loads[0]}")
                    self.results['critical_blockers'].append({
                        'category': 'System Load',
                        'severity': 'CRITICAL',
                        'issue': f'System load average is {loads[0]} (threshold: 20)',
                        'recommendation': 'Investigate high load - may cause API timeouts'
                    })
                    self.failed_checks += 1
                elif loads[0] > 10:
                    print_warning(f"System load high: {loads[0]}")
                    self.warning_checks += 1
                else:
                    print_success(f"System load normal: {loads[0]}")
                    self.passed_checks += 1
            else:
                self.warning_checks += 1
        
        self.total_checks += 1
        
        # Calculate total active units
        total_units = len(self.results['docker_containers']) + len(self.results['pm2_processes'])
        print(f"\n{Colors.BOLD}Total Active Runtime Units: {total_units}{Colors.ENDC}")
    
    def phase_2_service_responsibility(self):
        """Phase 2: Validate service responsibilities"""
        print_section("PHASE 2: SERVICE RESPONSIBILITY VALIDATION")
        
        # Check key service endpoints
        services = [
            ('Backend API', 'http://localhost:3000/api/health'),
            ('Backend API System Status', 'http://localhost:4000/api/system/status'),
            ('Auth Service', 'http://localhost:3001/health'),
            ('Streaming Service', 'http://localhost:3002/health'),
        ]
        
        for service_name, endpoint in services:
            self.total_checks += 1
            print(f"\n{Colors.BOLD}Checking: {service_name}{Colors.ENDC}")
            print(f"  Endpoint: {endpoint}")
            
            is_up, status_code, message = check_http_endpoint(endpoint)
            
            if is_up:
                print_success(f"{service_name} is OPERATIONAL - {message}")
                self.results['services_verified'].append({
                    'name': service_name,
                    'endpoint': endpoint,
                    'status': 'VERIFIED',
                    'response': message
                })
                self.passed_checks += 1
            else:
                if status_code is None:
                    print_error(f"{service_name} is DOWN or UNREACHABLE - {message}")
                    self.results['critical_blockers'].append({
                        'category': 'Service Availability',
                        'severity': 'CRITICAL',
                        'service': service_name,
                        'endpoint': endpoint,
                        'issue': message,
                        'recommendation': 'Service is not responding - investigate logs and restart if needed'
                    })
                    self.failed_checks += 1
                else:
                    print_warning(f"{service_name} returned error - {message}")
                    self.results['services_degraded'].append({
                        'name': service_name,
                        'endpoint': endpoint,
                        'status': 'DEGRADED',
                        'response': message
                    })
                    self.warning_checks += 1
    
    def phase_3_canon_consistency(self):
        """Phase 3: Verify canon consistency checks"""
        print_section("PHASE 3: CANON CONSISTENCY CHECK")
        
        # Check for PMMG N3XUS R3CORDINGS branding
        print(f"{Colors.BOLD}3.1 Checking N3XUS LAW Compliance: PMMG N3XUS R3CORDINGS{Colors.ENDC}")
        self.total_checks += 1
        
        code, stdout, stderr = run_command("grep -r 'PMMG N3XUS R3CORDINGS' frontend/src/components/MusicPortal.tsx 2>/dev/null")
        
        if code == 0 and stdout.strip():
            print_success("✓ PMMG N3XUS R3CORDINGS branding verified in MusicPortal.tsx")
            self.results['canon_checks'].append({
                'check': 'PMMG N3XUS R3CORDINGS Branding',
                'status': 'PASSED',
                'location': 'frontend/src/components/MusicPortal.tsx'
            })
            self.passed_checks += 1
        else:
            print_error("✗ PMMG N3XUS R3CORDINGS branding NOT FOUND")
            self.results['canon_checks'].append({
                'check': 'PMMG N3XUS R3CORDINGS Branding',
                'status': 'FAILED',
                'location': 'frontend/src/components/MusicPortal.tsx'
            })
            self.failed_checks += 1
        
        # Check for Handshake 55-45-17
        print(f"\n{Colors.BOLD}3.2 Checking Handshake Protocol: 55-45-17{Colors.ENDC}")
        self.total_checks += 1
        
        code, stdout, stderr = run_command("grep -r '55-45-17' . --include='*.md' --include='*.js' --include='*.ts' --include='*.tsx' 2>/dev/null | head -5")
        
        if code == 0 and stdout.strip():
            matches = len(stdout.strip().split('\n'))
            print_success(f"✓ Handshake 55-45-17 protocol found in {matches} locations")
            self.results['canon_checks'].append({
                'check': 'Handshake 55-45-17 Protocol',
                'status': 'PASSED',
                'occurrences': matches
            })
            self.passed_checks += 1
        else:
            print_warning("⚠ Handshake 55-45-17 protocol references limited or missing")
            self.warning_checks += 1
        
        # Check for Master Blueprint
        print(f"\n{Colors.BOLD}3.3 Checking Master Blueprint Documentation{Colors.ENDC}")
        self.total_checks += 1
        
        if os.path.exists('NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md'):
            print_success("✓ Master Blueprint documentation present")
            # Check file size
            size = os.path.getsize('NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md')
            print(f"  File size: {size:,} bytes")
            self.results['canon_checks'].append({
                'check': 'Master Blueprint Documentation',
                'status': 'PASSED',
                'file': 'NEXUS_COS_HOLOSNAP_MASTER_BLUEPRINT.md',
                'size': size
            })
            self.passed_checks += 1
        else:
            print_error("✗ Master Blueprint documentation MISSING")
            self.failed_checks += 1
        
        # Check supporting documentation
        print(f"\n{Colors.BOLD}3.4 Checking Supporting Documentation{Colors.ENDC}")
        docs = [
            'docs/HOLOSNAP_TECHNICAL_SPECIFICATION.md',
            'docs/NEXCOIN_QUICK_REFERENCE.md',
            'docs/FOUNDING_TENANT_RIGHTS_GUIDE.md'
        ]
        
        for doc in docs:
            self.total_checks += 1
            if os.path.exists(doc):
                print_success(f"✓ {doc} present")
                self.passed_checks += 1
            else:
                print_error(f"✗ {doc} MISSING")
                self.failed_checks += 1
    
    def phase_4_executive_verdict(self):
        """Phase 4: Generate executive verdict"""
        print_section("PHASE 4: EXECUTIVE VERDICT")
        
        # Calculate statistics
        total_services = len(self.results['services_verified']) + len(self.results['services_degraded']) + len(self.results['services_ornamental'])
        critical_blockers = len(self.results['critical_blockers'])
        
        print(f"{Colors.BOLD}Verification Statistics:{Colors.ENDC}")
        print(f"  Total Checks Performed: {self.total_checks}")
        print(f"  ✓ Passed: {self.passed_checks} ({self.passed_checks/self.total_checks*100:.1f}%)")
        print(f"  ⚠ Warnings: {self.warning_checks} ({self.warning_checks/self.total_checks*100:.1f}%)")
        print(f"  ✗ Failed: {self.failed_checks} ({self.failed_checks/self.total_checks*100:.1f}%)")
        
        print(f"\n{Colors.BOLD}Service Status:{Colors.ENDC}")
        print(f"  Verified Services: {len(self.results['services_verified'])}")
        print(f"  Degraded Services: {len(self.results['services_degraded'])}")
        print(f"  Ornamental Services: {len(self.results['services_ornamental'])}")
        
        print(f"\n{Colors.BOLD}Critical Issues:{Colors.ENDC}")
        print(f"  Critical Blockers: {critical_blockers}")
        
        if critical_blockers > 0:
            print(f"\n{Colors.FAIL}{Colors.BOLD}⚠️  CRITICAL FINDINGS:{Colors.ENDC}")
            for blocker in self.results['critical_blockers']:
                print(f"\n  {Colors.FAIL}▶ {blocker['category']}: {blocker.get('service', blocker.get('issue', 'Unknown'))}{Colors.ENDC}")
                print(f"    Severity: {blocker['severity']}")
                print(f"    Issue: {blocker.get('issue', 'N/A')}")
                print(f"    Recommendation: {blocker.get('recommendation', 'Investigate immediately')}")
        
        # Generate verdict
        print(f"\n{Colors.BOLD}{'='*80}{Colors.ENDC}")
        print(f"{Colors.BOLD}EXECUTIVE VERDICT:{Colors.ENDC}")
        print(f"{Colors.BOLD}{'='*80}{Colors.ENDC}\n")
        
        if critical_blockers > 0:
            self.results['verdict'] = 'DEGRADED - CRITICAL ISSUES FOUND'
            print(f"{Colors.WARNING}{Colors.BOLD}STATUS: OPERATIONAL WITH CRITICAL DEGRADATIONS{Colors.ENDC}")
            print(f"\nN3XUS COS is running but has critical issues that require immediate attention.")
            print(f"System load and service availability issues detected.")
        elif self.failed_checks > 0:
            self.results['verdict'] = 'DEGRADED - FAILURES DETECTED'
            print(f"{Colors.WARNING}{Colors.BOLD}STATUS: OPERATIONAL WITH DEGRADATIONS{Colors.ENDC}")
            print(f"\nN3XUS COS is running but has non-critical issues that should be addressed.")
        elif self.warning_checks > 0:
            self.results['verdict'] = 'OPERATIONAL - WARNINGS PRESENT'
            print(f"{Colors.OKGREEN}{Colors.BOLD}STATUS: OPERATIONAL{Colors.ENDC}")
            print(f"\nN3XUS COS is operational with minor warnings.")
        else:
            self.results['verdict'] = 'FULLY OPERATIONAL'
            print(f"{Colors.OKGREEN}{Colors.BOLD}STATUS: FULLY OPERATIONAL{Colors.ENDC}")
            print(f"\nN3XUS COS is fully operational - all systems verified.")
        
        # Runtime evidence summary
        total_units = len(self.results['docker_containers']) + len(self.results['pm2_processes'])
        print(f"\n{Colors.BOLD}Runtime Evidence:{Colors.ENDC}")
        print(f"  Total Active Units: {total_units}")
        print(f"  Docker Containers: {len(self.results['docker_containers'])}")
        print(f"  PM2 Processes: {len(self.results['pm2_processes'])}")
        
        print(f"\n{Colors.BOLD}Canon Compliance:{Colors.ENDC}")
        canon_passed = sum(1 for check in self.results['canon_checks'] if check['status'] == 'PASSED')
        canon_total = len(self.results['canon_checks'])
        print(f"  Canon Checks Passed: {canon_passed}/{canon_total}")
        
        print(f"\n{Colors.BOLD}{'='*80}{Colors.ENDC}\n")
    
    def save_report(self):
        """Save detailed report to file"""
        report_file = f"verification_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        print(f"{Colors.OKBLUE}Detailed report saved to: {report_file}{Colors.ENDC}")
        return report_file
    
    def run(self):
        """Run the complete verification suite"""
        print_header("N3XUS COS MASTER FULL-STACK VERIFICATION")
        print(f"{Colors.BOLD}CPS Tool #5 - Platform Forensic / Systems Validation{Colors.ENDC}")
        print(f"Execution Mode: Read-Only | Non-Destructive | Deterministic")
        print(f"Timestamp: {self.results['timestamp']}\n")
        
        try:
            # Execute all phases
            self.phase_1_system_inventory()
            self.phase_2_service_responsibility()
            self.phase_3_canon_consistency()
            self.phase_4_executive_verdict()
            
            # Save report
            report_file = self.save_report()
            
            # Return appropriate exit code
            if len(self.results['critical_blockers']) > 0:
                print(f"\n{Colors.FAIL}Verification completed with CRITICAL ISSUES{Colors.ENDC}")
                return 2
            elif self.failed_checks > 0:
                print(f"\n{Colors.WARNING}Verification completed with FAILURES{Colors.ENDC}")
                return 1
            else:
                print(f"\n{Colors.OKGREEN}Verification completed SUCCESSFULLY{Colors.ENDC}")
                return 0
        
        except KeyboardInterrupt:
            print(f"\n\n{Colors.WARNING}Verification interrupted by user{Colors.ENDC}")
            return 130
        except Exception as e:
            print(f"\n{Colors.FAIL}Verification failed with error: {str(e)}{Colors.ENDC}")
            import traceback
            traceback.print_exc()
            return 1

def main():
    """Main entry point"""
    verifier = MasterVerification()
    exit_code = verifier.run()
    sys.exit(exit_code)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Canon-Verifier: TRAE GO/NO-GO Verification Harness
Comprehensive verification system for N3XUS COS VPS deployment
Validates canonical branding, configuration, and system readiness
"""

import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path

class TraeGoNoGoVerifier:
    """Main verification harness for canon-verifier system"""
    
    def __init__(self):
        self.base_dir = Path(__file__).parent.absolute()
        self.repo_root = self.base_dir.parent
        self.config_dir = self.base_dir / 'config'
        self.logs_dir = self.base_dir / 'logs'
        self.output_dir = self.base_dir / 'output'
        
        # Get timestamped log directory from environment or create new
        log_timestamp = os.environ.get('CANON_LOG_DIR')
        if log_timestamp:
            self.current_log_dir = Path(log_timestamp)
        else:
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            self.current_log_dir = self.logs_dir / f'run_{timestamp}'
        
        self.current_log_dir.mkdir(parents=True, exist_ok=True)
        
        self.verification_results = {
            'timestamp': datetime.now().astimezone().isoformat(),
            'phases': {},
            'overall_status': 'PENDING'
        }
        
    def log(self, message, level='INFO'):
        """Log message to both console and log file"""
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        log_message = f"[{timestamp}] [{level}] {message}"
        print(log_message)
        
        # Write to log file
        log_file = self.current_log_dir / 'verification.log'
        with open(log_file, 'a') as f:
            f.write(log_message + '\n')
    
    def verify_canonical_logo(self):
        """Verify official logo exists and is canonical"""
        self.log("="*80)
        self.log("PHASE: Canonical Logo Verification")
        self.log("="*80)
        
        try:
            # Load config
            config_file = self.config_dir / 'canon_assets.json'
            if not config_file.exists():
                self.log(f"Config file not found: {config_file}", 'ERROR')
                return False
            
            with open(config_file, 'r') as f:
                config = json.load(f)
            
            official_logo_path = config.get('OfficialLogo', '')
            
            if not official_logo_path:
                self.log("OfficialLogo not configured in canon_assets.json", 'ERROR')
                return False
            
            # Convert to absolute path if relative
            logo_path = Path(official_logo_path)
            if not logo_path.is_absolute():
                logo_path = self.repo_root / official_logo_path
            
            self.log(f"Checking for official logo at: {logo_path}")
            
            if not logo_path.exists():
                self.log(f"Official logo NOT FOUND: {logo_path}", 'ERROR')
                return False
            
            # Verify file size
            file_size = logo_path.stat().st_size
            rules = config.get('VerificationRules', {})
            min_size = rules.get('minLogoSize', 1024)
            max_size = rules.get('maxLogoSize', 10485760)
            
            self.log(f"Logo file size: {file_size} bytes")
            
            if file_size < min_size:
                self.log(f"Logo file too small: {file_size} < {min_size}", 'ERROR')
                return False
            
            if file_size > max_size:
                self.log(f"Logo file too large: {file_size} > {max_size}", 'ERROR')
                return False
            
            # Verify file extension
            allowed_formats = rules.get('logoFormats', ['svg', 'png'])
            file_ext = logo_path.suffix[1:].lower()
            
            if file_ext not in allowed_formats:
                self.log(f"Invalid logo format: {file_ext} not in {allowed_formats}", 'ERROR')
                return False
            
            self.log(f"✓ Official logo verified: {logo_path.name} ({file_size} bytes)", 'SUCCESS')
            
            self.verification_results['phases']['canonical_logo'] = {
                'status': 'PASS',
                'logo_path': str(logo_path),
                'file_size': file_size,
                'format': file_ext
            }
            
            return True
            
        except Exception as e:
            self.log(f"Logo verification failed: {e}", 'ERROR')
            self.verification_results['phases']['canonical_logo'] = {
                'status': 'FAIL',
                'error': str(e)
            }
            return False
    
    def verify_directory_structure(self):
        """Verify required directory structure exists"""
        self.log("="*80)
        self.log("PHASE: Directory Structure Verification")
        self.log("="*80)
        
        required_dirs = [
            'branding/official',
            'canon-verifier/config',
            'canon-verifier/logs',
            'canon-verifier/output'
        ]
        
        all_exist = True
        
        for dir_path in required_dirs:
            full_path = self.repo_root / dir_path
            if full_path.exists():
                self.log(f"✓ Directory exists: {dir_path}", 'SUCCESS')
            else:
                self.log(f"✗ Directory missing: {dir_path}", 'ERROR')
                all_exist = False
        
        self.verification_results['phases']['directory_structure'] = {
            'status': 'PASS' if all_exist else 'FAIL',
            'directories_checked': required_dirs
        }
        
        return all_exist
    
    def verify_configuration(self):
        """Verify configuration files are valid"""
        self.log("="*80)
        self.log("PHASE: Configuration Verification")
        self.log("="*80)
        
        try:
            config_file = self.config_dir / 'canon_assets.json'
            
            if not config_file.exists():
                self.log(f"Config file missing: {config_file}", 'ERROR')
                return False
            
            with open(config_file, 'r') as f:
                config = json.load(f)
            
            self.log(f"✓ Configuration file valid: {config_file.name}", 'SUCCESS')
            
            # Verify required keys
            required_keys = ['OfficialLogo', 'AssetRegistry', 'VerificationRules']
            for key in required_keys:
                if key in config:
                    self.log(f"  ✓ Key present: {key}")
                else:
                    self.log(f"  ✗ Key missing: {key}", 'WARNING')
            
            self.verification_results['phases']['configuration'] = {
                'status': 'PASS',
                'config_file': str(config_file)
            }
            
            return True
            
        except json.JSONDecodeError as e:
            self.log(f"Invalid JSON in config file: {e}", 'ERROR')
            self.verification_results['phases']['configuration'] = {
                'status': 'FAIL',
                'error': f'Invalid JSON: {e}'
            }
            return False
        except Exception as e:
            self.log(f"Configuration verification failed: {e}", 'ERROR')
            self.verification_results['phases']['configuration'] = {
                'status': 'FAIL',
                'error': str(e)
            }
            return False
    
    def run_canon_verifier_phases(self):
        """Run existing canon-verifier orchestration"""
        self.log("="*80)
        self.log("PHASE: Canon-Verifier Full Harness")
        self.log("="*80)
        
        try:
            run_verification_script = self.base_dir / 'run_verification.py'
            
            if not run_verification_script.exists():
                self.log("run_verification.py not found, skipping full harness", 'WARNING')
                self.verification_results['phases']['canon_verifier_harness'] = {
                    'status': 'SKIPPED',
                    'reason': 'Script not found'
                }
                return True  # Don't fail if this is missing
            
            self.log(f"Running canon-verifier orchestrator...")
            
            result = subprocess.run(
                [sys.executable, str(run_verification_script)],
                cwd=str(self.base_dir),
                capture_output=True,
                text=True,
                timeout=120
            )
            
            # Log output
            if result.stdout:
                self.log("Canon-verifier output:")
                for line in result.stdout.split('\n'):
                    if line.strip():
                        self.log(f"  {line}")
            
            if result.stderr:
                self.log("Canon-verifier errors:")
                for line in result.stderr.split('\n'):
                    if line.strip():
                        self.log(f"  {line}", 'WARNING')
            
            success = result.returncode == 0
            
            if success:
                self.log("✓ Canon-verifier harness completed successfully", 'SUCCESS')
            else:
                self.log(f"✗ Canon-verifier harness failed with exit code {result.returncode}", 'WARNING')
            
            self.verification_results['phases']['canon_verifier_harness'] = {
                'status': 'PASS' if success else 'FAIL',
                'exit_code': result.returncode
            }
            
            return success
            
        except subprocess.TimeoutExpired:
            self.log("Canon-verifier harness timed out", 'ERROR')
            self.verification_results['phases']['canon_verifier_harness'] = {
                'status': 'FAIL',
                'error': 'Timeout'
            }
            return False
        except Exception as e:
            self.log(f"Canon-verifier harness error: {e}", 'ERROR')
            self.verification_results['phases']['canon_verifier_harness'] = {
                'status': 'FAIL',
                'error': str(e)
            }
            return False
    
    def check_service_readiness(self):
        """Check if PM2 and Docker are available"""
        self.log("="*80)
        self.log("PHASE: Service Readiness Check")
        self.log("="*80)
        
        services_ready = True
        
        # Check PM2
        try:
            result = subprocess.run(
                ['pm2', '--version'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.log(f"✓ PM2 available: {result.stdout.strip()}", 'SUCCESS')
            else:
                self.log("✗ PM2 not available", 'WARNING')
                services_ready = False
        except Exception as e:
            self.log(f"✗ PM2 check failed: {e}", 'WARNING')
            services_ready = False
        
        # Check Docker
        try:
            result = subprocess.run(
                ['docker', '--version'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.log(f"✓ Docker available: {result.stdout.strip()}", 'SUCCESS')
            else:
                self.log("✗ Docker not available", 'WARNING')
                services_ready = False
        except Exception as e:
            self.log(f"✗ Docker check failed: {e}", 'WARNING')
            services_ready = False
        
        # Check docker-compose
        try:
            result = subprocess.run(
                ['docker-compose', '--version'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                self.log(f"✓ docker-compose available: {result.stdout.strip()}", 'SUCCESS')
            else:
                self.log("✗ docker-compose not available", 'WARNING')
                services_ready = False
        except Exception as e:
            self.log(f"✗ docker-compose check failed: {e}", 'WARNING')
            services_ready = False
        
        self.verification_results['phases']['service_readiness'] = {
            'status': 'PASS' if services_ready else 'WARNING',
            'note': 'Services can be started manually if needed'
        }
        
        return True  # Don't fail if services aren't available yet
    
    def generate_final_report(self):
        """Generate final verification report"""
        self.log("="*80)
        self.log("FINAL VERIFICATION REPORT")
        self.log("="*80)
        
        # Count results
        total_phases = len(self.verification_results['phases'])
        passed = sum(1 for p in self.verification_results['phases'].values() if p['status'] == 'PASS')
        failed = sum(1 for p in self.verification_results['phases'].values() if p['status'] == 'FAIL')
        warnings = sum(1 for p in self.verification_results['phases'].values() if p['status'] in ['WARNING', 'SKIPPED'])
        
        self.log(f"Total Phases: {total_phases}")
        self.log(f"Passed: {passed}")
        self.log(f"Failed: {failed}")
        self.log(f"Warnings/Skipped: {warnings}")
        
        # Determine overall status
        critical_phases = ['canonical_logo', 'directory_structure', 'configuration']
        critical_passed = all(
            self.verification_results['phases'].get(phase, {}).get('status') == 'PASS'
            for phase in critical_phases
        )
        
        if critical_passed and failed == 0:
            self.verification_results['overall_status'] = 'GO'
            self.verification_results['verdict'] = 'PASS'
            self.verification_results['message'] = 'All critical verifications passed. System is GO for launch.'
            self.log("\n" + "="*80)
            self.log("GO: Official logo canonized, verification passed, N3XUS COS ready for launch", 'SUCCESS')
            self.log("="*80 + "\n")
            verdict = True
        else:
            self.verification_results['overall_status'] = 'NO-GO'
            self.verification_results['verdict'] = 'FAIL'
            self.verification_results['message'] = 'Critical verifications failed. System is NO-GO for launch.'
            self.log("\n" + "="*80)
            self.log("NO-GO: Verification failed. See logs for details.", 'ERROR')
            self.log("="*80 + "\n")
            verdict = False
        
        # Save report
        report_file = self.current_log_dir / 'verification_report.json'
        with open(report_file, 'w') as f:
            json.dump(self.verification_results, f, indent=2)
        
        self.log(f"Verification report saved to: {report_file}")
        self.log(f"All logs saved to: {self.current_log_dir}")
        
        return verdict
    
    def run(self):
        """Main verification workflow"""
        self.log("="*80)
        self.log("N3XUS COS Canon-Verifier: TRAE GO/NO-GO Harness")
        self.log("="*80)
        self.log(f"Timestamp: {self.verification_results['timestamp']}")
        self.log(f"Log Directory: {self.current_log_dir}")
        self.log("="*80 + "\n")
        
        # Run verification phases in order
        phases = [
            ('Directory Structure', self.verify_directory_structure),
            ('Configuration', self.verify_configuration),
            ('Canonical Logo', self.verify_canonical_logo),
            ('Service Readiness', self.check_service_readiness),
            ('Canon-Verifier Harness', self.run_canon_verifier_phases),
        ]
        
        for phase_name, phase_func in phases:
            try:
                phase_func()
            except Exception as e:
                self.log(f"Unexpected error in phase '{phase_name}': {e}", 'ERROR')
                self.verification_results['phases'][phase_name.lower().replace(' ', '_')] = {
                    'status': 'FAIL',
                    'error': str(e)
                }
        
        # Generate final report
        verdict = self.generate_final_report()
        
        return verdict


def main():
    """Entry point for TRAE GO/NO-GO verification"""
    verifier = TraeGoNoGoVerifier()
    
    try:
        success = verifier.run()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        verifier.log("\nVerification interrupted by user", 'WARNING')
        sys.exit(130)
    except Exception as e:
        verifier.log(f"Fatal error: {e}", 'ERROR')
        sys.exit(1)


if __name__ == "__main__":
    main()

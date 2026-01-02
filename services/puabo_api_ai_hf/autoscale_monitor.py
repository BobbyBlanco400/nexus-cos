#!/usr/bin/env python3
"""
Autoscaling and Health Monitoring for PUABO API/AI-HF Hybrid
"""

import argparse
import requests
import time
import sys
import json
from datetime import datetime

# Service configuration
SERVICE_URL = "http://localhost:3401"
CHECK_INTERVAL = 30
MAX_FAILURES = 3


def check_endpoint(url, timeout=5):
    """Check if an endpoint is healthy"""
    try:
        response = requests.get(url, timeout=timeout)
        return response.status_code == 200, response.json()
    except requests.exceptions.RequestException as e:
        return False, {"error": str(e)}


def check_health():
    """Check health of the service"""
    health_url = f"{SERVICE_URL}/health"
    status_url = f"{SERVICE_URL}/status"
    
    print(f"Checking health at {health_url}...")
    health_ok, health_data = check_endpoint(health_url)
    
    print(f"Checking status at {status_url}...")
    status_ok, status_data = check_endpoint(status_url)
    
    if health_ok and status_ok:
        print("✓ Service is healthy")
        print(f"  - Service: {health_data.get('service', 'N/A')}")
        print(f"  - Version: {health_data.get('version', 'N/A')}")
        print(f"  - Uptime: {status_data.get('uptime_seconds', 0):.2f}s")
        return True
    else:
        print("✗ Service is unhealthy")
        if not health_ok:
            print(f"  - Health check failed: {health_data.get('error', 'Unknown error')}")
        if not status_ok:
            print(f"  - Status check failed: {status_data.get('error', 'Unknown error')}")
        return False


def check_endpoints():
    """Check all service endpoints"""
    endpoints = [
        '/health',
        '/status',
        '/api/v1/models'
    ]
    
    results = {}
    all_ok = True
    
    print(f"Checking endpoints on {SERVICE_URL}...")
    for endpoint in endpoints:
        url = f"{SERVICE_URL}{endpoint}"
        ok, data = check_endpoint(url)
        results[endpoint] = {
            'ok': ok,
            'data': data
        }
        status = "✓" if ok else "✗"
        print(f"  {status} {endpoint}")
        if not ok:
            all_ok = False
    
    if all_ok:
        print("\n✓ All endpoints are healthy")
        return 0
    else:
        print("\n✗ Some endpoints are unhealthy")
        return 1


def monitor_service(interval=CHECK_INTERVAL):
    """Continuously monitor the service"""
    print(f"Starting health monitoring (checking every {interval}s)...")
    print(f"Service URL: {SERVICE_URL}")
    print("Press Ctrl+C to stop\n")
    
    failure_count = 0
    
    try:
        while True:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            print(f"[{timestamp}] Checking health...")
            
            if check_health():
                failure_count = 0
            else:
                failure_count += 1
                print(f"  Warning: {failure_count} consecutive failures")
                
                if failure_count >= MAX_FAILURES:
                    print(f"\n✗ Service has failed {MAX_FAILURES} consecutive health checks")
                    print("  Consider restarting the service")
            
            print("")
            time.sleep(interval)
            
    except KeyboardInterrupt:
        print("\nMonitoring stopped")
        return 0


def main():
    parser = argparse.ArgumentParser(description='PUABO API/AI-HF Autoscaling Monitor')
    parser.add_argument('--check-endpoints', action='store_true',
                      help='Check all endpoints and exit')
    parser.add_argument('--check-health', action='store_true',
                      help='Check health once and exit')
    parser.add_argument('--monitor', action='store_true',
                      help='Continuously monitor the service')
    parser.add_argument('--interval', type=int, default=CHECK_INTERVAL,
                      help=f'Monitoring interval in seconds (default: {CHECK_INTERVAL})')
    parser.add_argument('--url', type=str, default=SERVICE_URL,
                      help=f'Service URL (default: {SERVICE_URL})')
    
    args = parser.parse_args()
    
    # Update global SERVICE_URL if provided
    global SERVICE_URL
    SERVICE_URL = args.url
    
    if args.check_endpoints:
        return check_endpoints()
    elif args.check_health:
        return 0 if check_health() else 1
    elif args.monitor:
        return monitor_service(args.interval)
    else:
        # Default: check endpoints
        return check_endpoints()


if __name__ == '__main__':
    sys.exit(main())

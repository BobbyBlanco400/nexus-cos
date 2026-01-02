#!/usr/bin/env python3
"""
Load Testing Script for PUABO API/AI-HF Endpoints
"""

import argparse
import sys
import requests
import time
import concurrent.futures
from datetime import datetime


def load_test_endpoint(url, num_requests=10, concurrent=5):
    """Perform load testing on an endpoint"""
    print(f"\nLoad testing: {url}")
    print(f"  Requests: {num_requests}")
    print(f"  Concurrent: {concurrent}")
    
    results = {
        'success': 0,
        'failure': 0,
        'total_time': 0,
        'times': []
    }
    
    def make_request(i):
        """Make a single request"""
        try:
            start = time.time()
            response = requests.get(url, timeout=10)
            elapsed = time.time() - start
            
            return {
                'success': response.status_code == 200,
                'time': elapsed,
                'status': response.status_code
            }
        except Exception as e:
            return {
                'success': False,
                'time': 0,
                'error': str(e)
            }
    
    # Run requests concurrently
    start_time = time.time()
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrent) as executor:
        futures = [executor.submit(make_request, i) for i in range(num_requests)]
        
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result['success']:
                results['success'] += 1
                results['times'].append(result['time'])
            else:
                results['failure'] += 1
    
    results['total_time'] = time.time() - start_time
    
    # Calculate statistics
    if results['times']:
        avg_time = sum(results['times']) / len(results['times'])
        min_time = min(results['times'])
        max_time = max(results['times'])
    else:
        avg_time = min_time = max_time = 0
    
    # Print results
    print(f"\nResults:")
    print(f"  ✓ Successful: {results['success']}/{num_requests}")
    print(f"  ✗ Failed: {results['failure']}/{num_requests}")
    print(f"  Total time: {results['total_time']:.2f}s")
    print(f"  Avg response time: {avg_time:.3f}s")
    print(f"  Min response time: {min_time:.3f}s")
    print(f"  Max response time: {max_time:.3f}s")
    print(f"  Requests/sec: {num_requests/results['total_time']:.2f}")
    
    return results['failure'] == 0


def main():
    parser = argparse.ArgumentParser(description='Load Test PUABO API Endpoints')
    parser.add_argument('--target', type=str, default='./services/puabo_api_ai_hf',
                      help='Target service directory')
    parser.add_argument('--url', type=str, default='http://localhost:3401',
                      help='Service URL')
    parser.add_argument('--requests', type=int, default=100,
                      help='Number of requests')
    parser.add_argument('--concurrent', type=int, default=10,
                      help='Concurrent requests')
    
    args = parser.parse_args()
    
    print(f"Load Testing PUABO API/AI-HF")
    print(f"Target: {args.target}")
    print(f"URL: {args.url}")
    
    # Test endpoints
    endpoints = [
        '/health',
        '/status',
        '/api/v1/models'
    ]
    
    all_passed = True
    
    for endpoint in endpoints:
        url = f"{args.url}{endpoint}"
        passed = load_test_endpoint(url, args.requests, args.concurrent)
        if not passed:
            all_passed = False
    
    if all_passed:
        print("\n✓ All load tests passed")
        return 0
    else:
        print("\n✗ Some load tests failed")
        return 1


if __name__ == '__main__':
    sys.exit(main())

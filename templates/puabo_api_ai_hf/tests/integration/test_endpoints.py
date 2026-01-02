"""Integration tests for PUABO API/AI-HF Hybrid service"""

import pytest
import requests
import time
import os
import sys

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))


# Test configuration
BASE_URL = os.environ.get('TEST_BASE_URL', 'http://localhost:3401')
TIMEOUT = 5


def is_service_running():
    """Check if service is running"""
    try:
        response = requests.get(f'{BASE_URL}/health', timeout=TIMEOUT)
        return response.status_code == 200
    except requests.exceptions.RequestException:
        return False


@pytest.fixture(scope='module', autouse=True)
def check_service():
    """Check if service is available before running tests"""
    if not is_service_running():
        pytest.skip(f"Service not running at {BASE_URL}")


def test_health_check_integration():
    """Test health check endpoint (integration)"""
    response = requests.get(f'{BASE_URL}/health', timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert data['status'] == 'ok'


def test_status_integration():
    """Test status endpoint (integration)"""
    response = requests.get(f'{BASE_URL}/status', timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert data['status'] == 'running'


def test_models_listing_integration():
    """Test models listing endpoint (integration)"""
    response = requests.get(f'{BASE_URL}/api/v1/models', timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert 'models' in data
    assert data['count'] > 0


def test_inference_integration():
    """Test inference endpoint (integration)"""
    payload = {
        'model': 'gpt2',
        'inputs': 'The quick brown fox'
    }
    response = requests.post(f'{BASE_URL}/api/v1/inference',
                           json=payload,
                           timeout=TIMEOUT)
    assert response.status_code == 200
    data = response.json()
    assert data['status'] == 'success'


def test_error_handling_integration():
    """Test error handling (integration)"""
    # Test invalid endpoint
    response = requests.get(f'{BASE_URL}/invalid', timeout=TIMEOUT)
    assert response.status_code == 404
    
    # Test invalid inference request
    response = requests.post(f'{BASE_URL}/api/v1/inference',
                           json={},
                           timeout=TIMEOUT)
    assert response.status_code == 400


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

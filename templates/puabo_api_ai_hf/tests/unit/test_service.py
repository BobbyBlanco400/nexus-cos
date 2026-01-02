"""Unit tests for PUABO API/AI-HF Hybrid service"""

import pytest
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from server import app


@pytest.fixture
def client():
    """Create test client"""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_check(client):
    """Test health check endpoint"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'ok'
    assert data['service'] == 'puabo_api_ai_hf'
    assert 'version' in data
    assert 'timestamp' in data


def test_status(client):
    """Test status endpoint"""
    response = client.get('/status')
    assert response.status_code == 200
    data = response.get_json()
    assert data['service'] == 'puabo_api_ai_hf'
    assert data['status'] == 'running'
    assert 'uptime_seconds' in data
    assert isinstance(data['endpoints'], list)
    assert isinstance(data['capabilities'], list)


def test_root(client):
    """Test root endpoint"""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert 'message' in data
    assert 'puabo_api_ai_hf' in data['message']


def test_list_models(client):
    """Test models listing endpoint"""
    response = client.get('/api/v1/models')
    assert response.status_code == 200
    data = response.get_json()
    assert 'models' in data
    assert 'count' in data
    assert data['count'] > 0
    assert isinstance(data['models'], list)


def test_inference_missing_data(client):
    """Test inference endpoint with missing data"""
    response = client.post('/api/v1/inference',
                          json={},
                          content_type='application/json')
    assert response.status_code == 400


def test_inference_missing_fields(client):
    """Test inference endpoint with missing required fields"""
    response = client.post('/api/v1/inference',
                          json={'model': 'gpt2'})
    assert response.status_code == 400
    
    response = client.post('/api/v1/inference',
                          json={'inputs': 'test input'})
    assert response.status_code == 400


def test_inference_success(client):
    """Test successful inference request"""
    response = client.post('/api/v1/inference',
                          json={
                              'model': 'gpt2',
                              'inputs': 'Hello world'
                          })
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'success'
    assert data['model'] == 'gpt2'
    assert 'result' in data


if __name__ == '__main__':
    pytest.main([__file__, '-v'])

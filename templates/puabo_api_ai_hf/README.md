# PUABO API/AI-HF Hybrid Service

HuggingFace-powered AI inference service for N3XUS COS.

## Overview

This service provides AI capabilities using HuggingFace Inference API, supporting multiple tasks:
- Text Generation
- Text Classification
- Question Answering
- Summarization
- Translation

## Quick Start

### Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Start the service
python server.py

# Service will run on http://localhost:3401
```

### Using Docker

```bash
# Build the image
docker build -t puabo-api-ai-hf .

# Run the container
docker run -p 3401:3401 puabo-api-ai-hf
```

## API Endpoints

### Health Check
```bash
curl http://localhost:3401/health
```

### Status
```bash
curl http://localhost:3401/status
```

### List Models
```bash
curl http://localhost:3401/api/v1/models
```

### Inference
```bash
curl -X POST http://localhost:3401/api/v1/inference \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt2",
    "inputs": "Hello, my name is"
  }'
```

## Testing

### Run Unit Tests
```bash
pytest tests/unit/ --cov
```

### Run Integration Tests
```bash
# Make sure service is running first
pytest tests/integration/
```

### Load Testing
```bash
python ../scripts/load_test_endpoints.py --target .
```

## Monitoring

### Check Endpoints Health
```bash
python autoscale_monitor.py --check-endpoints
```

### Continuous Monitoring
```bash
python autoscale_monitor.py --monitor --interval 30
```

## Configuration

Edit `config.json` to customize:
- Available models
- Autoscaling settings
- Monitoring configuration
- Inference parameters

## Environment Variables

- `PORT` - Service port (default: 3401)
- `HUGGINGFACE_API_TOKEN` - HuggingFace API token (optional)
- `HF_INFERENCE_ENDPOINT` - HuggingFace API endpoint

## Deployment

See the main deployment script: `deploy_puabo_api_ai_hf.sh`

Or deploy manually with Ansible:
```bash
ansible-playbook ../deploy/puabo_api_ai_hf.yml \
  --inventory ../deploy/hosts.ini \
  --limit hostinger
```

## Architecture

```
puabo_api_ai_hf/
├── server.py              # Main Flask application
├── config.json            # Service configuration
├── requirements.txt       # Python dependencies
├── Dockerfile            # Container definition
├── autoscale_monitor.py  # Health monitoring & autoscaling
├── tests/                # Test suites
│   ├── unit/            # Unit tests
│   └── integration/     # Integration tests
└── README.md            # This file
```

## License

Part of N3XUS COS ecosystem.

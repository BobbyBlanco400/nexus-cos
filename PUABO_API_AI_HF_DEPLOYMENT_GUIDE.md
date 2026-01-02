# PUABO API/AI-HF Hybrid Integration - Deployment Guide

## Overview

This deployment package provides a complete, production-ready PUABO API/AI-HF Hybrid service for N3XUS COS, featuring:

- **HuggingFace Inference Integration**: Support for text generation, classification, QA, summarization, and translation
- **Automated Deployment**: Single-command deployment script with bulletproof error handling
- **Comprehensive Testing**: Unit tests, integration tests, and load testing
- **Health Monitoring**: Built-in autoscaling and health monitoring capabilities
- **VPS Ready**: Ansible playbook for automated VPS/Hostinger deployment

## Quick Start

### 1. Run the Deployment Script

```bash
./deploy_puabo_api_ai_hf.sh
```

This script will:
- ✓ Backup and remove Kei AI service
- ✓ Verify PUABO API/AI-HF Hybrid structure
- ✓ Configure HuggingFace engines
- ✓ Setup model artifacts
- ✓ Configure monitoring and autoscaling
- ✓ Update AI routing
- ✓ Run unit tests
- ✓ Prepare VPS deployment

### 2. Test Locally

```bash
# Start the service
cd services/puabo_api_ai_hf
python3 server.py

# In another terminal, test endpoints
curl http://localhost:3401/health
curl http://localhost:3401/status
curl http://localhost:3401/api/v1/models

# Test inference
curl -X POST http://localhost:3401/api/v1/inference \
  -H "Content-Type: application/json" \
  -d '{"model": "gpt2", "inputs": "Hello world"}'
```

### 3. Run Tests

```bash
# Unit tests
pytest services/puabo_api_ai_hf/tests/unit/ --cov -v

# Integration tests (requires running service)
pytest services/puabo_api_ai_hf/tests/integration/ -v

# Load tests (requires running service)
python scripts/load_test_endpoints.py --target ./services/puabo_api_ai_hf
```

### 4. Monitor Health

```bash
# Check endpoints once
python services/puabo_api_ai_hf/autoscale_monitor.py --check-endpoints

# Continuous monitoring
python services/puabo_api_ai_hf/autoscale_monitor.py --monitor --interval 30
```

### 5. Deploy to VPS

First, configure your VPS details in `deploy/hosts.ini`:

```ini
[hostinger]
nexus-vps ansible_host=YOUR_SERVER_IP ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa

[hostinger:vars]
ansible_python_interpreter=/usr/bin/python3
```

Then deploy:

```bash
ansible-playbook deploy/puabo_api_ai_hf.yml \
  --inventory deploy/hosts.ini \
  --limit hostinger
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  N3XUS COS Platform                      │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────┐         ┌──────────────────────────┐  │
│  │   Router    │────────▶│  PUABO API/AI-HF Hybrid  │  │
│  │  (router.py)│         │                          │  │
│  └─────────────┘         │  - Flask REST API        │  │
│                           │  - HuggingFace Inference │  │
│                           │  - Health Monitoring     │  │
│                           │  - Autoscaling           │  │
│                           └──────────────────────────┘  │
│                                    │                     │
│                                    ▼                     │
│                           ┌──────────────────┐          │
│                           │  HuggingFace API │          │
│                           │  (External)      │          │
│                           └──────────────────┘          │
└─────────────────────────────────────────────────────────┘
```

## File Structure

```
nexus-cos/
├── deploy_puabo_api_ai_hf.sh        # Main deployment script
├── services/
│   ├── puabo_api_ai_hf/              # Service implementation
│   │   ├── server.py                 # Flask application
│   │   ├── config.json               # Configuration
│   │   ├── requirements.txt          # Python dependencies
│   │   ├── Dockerfile                # Container definition
│   │   ├── autoscale_monitor.py     # Health monitoring
│   │   ├── tests/                    # Test suites
│   │   └── README.md                 # Service documentation
│   └── router.py                     # AI routing configuration
├── scripts/
│   ├── sync_hf_models.py            # Model synchronization
│   └── load_test_endpoints.py       # Load testing
├── configs/
│   └── engines_hf.json              # HuggingFace engines config
├── templates/
│   └── puabo_api_ai_hf/             # Service templates
└── deploy/
    ├── puabo_api_ai_hf.yml          # Ansible playbook
    ├── hosts.ini                     # Inventory file
    └── puabo_api_ai_hf.service.j2   # Systemd template
```

## API Endpoints

### Health Check
- **GET** `/health` - Service health status
- **GET** `/status` - Detailed service information

### AI Operations
- **GET** `/api/v1/models` - List available models
- **POST** `/api/v1/inference` - Perform inference

### Inference Request Format

```json
{
  "model": "gpt2",
  "inputs": "Your input text here",
  "parameters": {
    "max_length": 100,
    "temperature": 0.7
  }
}
```

### Inference Response Format

```json
{
  "status": "success",
  "model": "gpt2",
  "result": {
    "generated_text": "Generated output...",
    "confidence": 0.95
  },
  "timestamp": "2026-01-02T08:29:54.945686+00:00"
}
```

## Configuration

### Environment Variables

```bash
# Service configuration
PORT=3401

# HuggingFace configuration
HUGGINGFACE_API_TOKEN=your_token_here
HF_INFERENCE_ENDPOINT=https://api-inference.huggingface.co/models/
```

### Service Configuration (config.json)

```json
{
  "service": "puabo_api_ai_hf",
  "version": "1.0.0",
  "port": 3401,
  "huggingface": {
    "api_endpoint": "https://api-inference.huggingface.co/models/",
    "default_models": [...]
  },
  "autoscaling": {
    "enabled": true,
    "min_instances": 1,
    "max_instances": 5,
    "cpu_threshold": 70,
    "memory_threshold": 80
  }
}
```

## Supported AI Tasks

1. **Text Generation**
   - Models: gpt2, distilgpt2
   - Use case: Content generation, completion

2. **Text Classification**
   - Models: distilbert-base-uncased-finetuned-sst-2-english
   - Use case: Sentiment analysis, categorization

3. **Question Answering**
   - Models: deepset/roberta-base-squad2
   - Use case: Extract answers from context

4. **Summarization**
   - Models: facebook/bart-large-cnn, sshleifer/distilbart-cnn-12-6
   - Use case: Text summarization, condensing

5. **Translation**
   - Models: Helsinki-NLP/opus-mt-en-es, Helsinki-NLP/opus-mt-en-fr
   - Use case: Language translation

## Monitoring & Operations

### Health Monitoring

```bash
# Check all endpoints
python services/puabo_api_ai_hf/autoscale_monitor.py --check-endpoints

# Monitor continuously
python services/puabo_api_ai_hf/autoscale_monitor.py --monitor --interval 30

# Check specific URL
python services/puabo_api_ai_hf/autoscale_monitor.py --url http://your-server:3401 --check-health
```

### Performance Metrics

The service tracks:
- Request count
- Response times
- Error rates
- Model usage statistics
- System resources (CPU, memory)

### Logs

```bash
# View service logs (systemd)
journalctl -u puabo_api_ai_hf -f

# View application logs
tail -f /opt/nexus-cos/services/puabo_api_ai_hf/logs/app.log
```

## Troubleshooting

### Service Won't Start

1. Check Python dependencies:
   ```bash
   cd services/puabo_api_ai_hf
   pip install -r requirements.txt
   ```

2. Verify port availability:
   ```bash
   lsof -i :3401
   ```

3. Check configuration:
   ```bash
   cat services/puabo_api_ai_hf/config.json
   ```

### Tests Failing

1. Ensure service is not running for unit tests
2. Start service before integration tests
3. Check Python version (requires 3.9+)

### Deployment Issues

1. Verify Ansible installation:
   ```bash
   ansible --version
   ```

2. Test SSH connection:
   ```bash
   ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP
   ```

3. Check Ansible playbook syntax:
   ```bash
   ansible-playbook deploy/puabo_api_ai_hf.yml --syntax-check
   ```

## Security Considerations

1. **API Tokens**: Store HuggingFace API tokens in environment variables, not in code
2. **SSH Keys**: Never commit private SSH keys to the repository
3. **HTTPS**: Use SSL/TLS for production deployments
4. **Firewall**: Restrict access to service ports
5. **Authentication**: Implement API authentication for production use

## Production Checklist

- [ ] Configure HuggingFace API token
- [ ] Set up HTTPS/SSL certificates
- [ ] Configure firewall rules
- [ ] Set up log rotation
- [ ] Configure monitoring alerts
- [ ] Set up backup procedures
- [ ] Document incident response procedures
- [ ] Configure autoscaling thresholds
- [ ] Set up CI/CD pipeline
- [ ] Perform load testing

## Support & Maintenance

### Updating the Service

```bash
# Pull latest changes
git pull origin feature/puabo-api-ai-hf-inference

# Run deployment script
./deploy_puabo_api_ai_hf.sh

# Restart service
systemctl restart puabo_api_ai_hf
```

### Adding New Models

1. Update `configs/engines_hf.json`
2. Update `services/puabo_api_ai_hf/config.json`
3. Run model sync: `python scripts/sync_hf_models.py --all`
4. Restart service

### Scaling

Horizontal scaling:
```bash
# Add more instances in config
vi services/puabo_api_ai_hf/config.json
# Update max_instances value
```

Vertical scaling:
- Increase server resources (CPU, RAM)
- Update systemd service limits

## License & Credits

Part of the N3XUS COS ecosystem.
Powered by HuggingFace Inference API.

---

**Need Help?**
- Review service logs
- Check the troubleshooting section
- Consult the API documentation
- Contact N3XUS COS support team

#!/bin/bash
# PUABO API/AI-HF Hybrid - Quick Reference
# Run this for a quick overview of available commands

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║     PUABO API/AI-HF Hybrid - Quick Reference Card            ║
╚══════════════════════════════════════════════════════════════╝

📦 DEPLOYMENT
──────────────────────────────────────────────────────────────
  Full automated deployment:
  $ ./deploy_puabo_api_ai_hf.sh

  VPS deployment with Ansible:
  $ ansible-playbook deploy/puabo_api_ai_hf.yml \
      --inventory deploy/hosts.ini --limit hostinger

🧪 TESTING
──────────────────────────────────────────────────────────────
  Run unit tests:
  $ pytest services/puabo_api_ai_hf/tests/unit/ --cov -v

  Run integration tests (service must be running):
  $ pytest services/puabo_api_ai_hf/tests/integration/ -v

  Load testing:
  $ python scripts/load_test_endpoints.py --target ./services/puabo_api_ai_hf

🚀 LOCAL DEVELOPMENT
──────────────────────────────────────────────────────────────
  Start service:
  $ cd services/puabo_api_ai_hf && python3 server.py

  Install dependencies:
  $ pip install -r services/puabo_api_ai_hf/requirements.txt

  Build Docker image:
  $ docker build -t puabo-api-ai-hf services/puabo_api_ai_hf

  Run Docker container:
  $ docker run -p 3401:3401 puabo-api-ai-hf

📊 MONITORING
──────────────────────────────────────────────────────────────
  Check endpoints:
  $ python services/puabo_api_ai_hf/autoscale_monitor.py --check-endpoints

  Continuous monitoring:
  $ python services/puabo_api_ai_hf/autoscale_monitor.py --monitor

  Check specific URL:
  $ python services/puabo_api_ai_hf/autoscale_monitor.py \
      --url http://your-server:3401 --check-health

🔍 API ENDPOINTS
──────────────────────────────────────────────────────────────
  Health check:
  $ curl http://localhost:3401/health

  Service status:
  $ curl http://localhost:3401/status

  List models:
  $ curl http://localhost:3401/api/v1/models

  Inference:
  $ curl -X POST http://localhost:3401/api/v1/inference \
      -H "Content-Type: application/json" \
      -d '{"model": "gpt2", "inputs": "Hello world"}'

🛠️ MAINTENANCE
──────────────────────────────────────────────────────────────
  Sync HuggingFace models:
  $ python scripts/sync_hf_models.py --all --internal

  View service logs (systemd):
  $ journalctl -u puabo_api_ai_hf -f

  Restart service (systemd):
  $ systemctl restart puabo_api_ai_hf

📚 DOCUMENTATION
──────────────────────────────────────────────────────────────
  Deployment Guide:
  $ cat PUABO_API_AI_HF_DEPLOYMENT_GUIDE.md

  Implementation Summary:
  $ cat PUABO_API_AI_HF_SUMMARY.md

  Service README:
  $ cat services/puabo_api_ai_hf/README.md

🔧 CONFIGURATION
──────────────────────────────────────────────────────────────
  Service config:
  $ cat services/puabo_api_ai_hf/config.json

  HuggingFace engines:
  $ cat configs/engines_hf.json

  AI routing:
  $ cat services/router.py

  Environment variables:
    PORT=3401
    HUGGINGFACE_API_TOKEN=your_token_here
    HF_INFERENCE_ENDPOINT=https://api-inference.huggingface.co/models/

📂 KEY DIRECTORIES
──────────────────────────────────────────────────────────────
  Service:         services/puabo_api_ai_hf/
  Tests:           services/puabo_api_ai_hf/tests/
  Deployment:      deploy/
  Scripts:         scripts/
  Templates:       templates/puabo_api_ai_hf/
  Configs:         configs/
  Models:          storage/models/

✅ VERIFICATION
──────────────────────────────────────────────────────────────
  Run verification:
  $ ./verify_puabo_api_ai_hf.sh

  Quick Python check:
  $ python3 -c "import flask, requests; print('✓ Dependencies OK')"

  Test service locally:
  $ cd services/puabo_api_ai_hf && python3 server.py &
  $ sleep 3 && curl http://localhost:3401/health
  $ kill %1

📋 STATUS
──────────────────────────────────────────────────────────────
  ✓ Service: Implemented and tested
  ✓ Tests: 7 unit tests passing
  ✓ Documentation: Complete
  ✓ Deployment: Automated
  ✓ Production: Ready

🆘 TROUBLESHOOTING
──────────────────────────────────────────────────────────────
  Service won't start:
  $ pip install -r services/puabo_api_ai_hf/requirements.txt
  $ lsof -i :3401  # Check if port is in use

  Tests failing:
  $ python3 --version  # Requires Python 3.9+
  $ pytest --version

  Can't deploy to VPS:
  $ ansible --version
  $ ssh -i ~/.ssh/id_rsa root@YOUR_SERVER_IP

──────────────────────────────────────────────────────────────
For detailed information, see:
  PUABO_API_AI_HF_DEPLOYMENT_GUIDE.md

N3XUS COS - PUABO API/AI-HF Hybrid v1.0.0
──────────────────────────────────────────────────────────────
EOF

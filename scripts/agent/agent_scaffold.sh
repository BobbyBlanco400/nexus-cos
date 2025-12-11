#!/bin/bash
# Auto-scaffold missing Nexus COS modules
# Creates service stubs with Dockerfile, healthcheck, tests, and OpenAPI specs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="${WORKDIR:-$(pwd)}"
DISCREPANCY_REPORT="${1:-reports/discrepancy_report.json}"
SERVICES_DIR="${WORKDIR}/services"
OUTPUT_BRANCH="${2:-agent-scaffold}"
POLICY="${3:-auto_merge=false}"

echo "=========================================="
echo "Nexus COS Module Scaffolding Agent"
echo "=========================================="
echo "Working Directory: ${WORKDIR}"
echo "Discrepancy Report: ${DISCREPANCY_REPORT}"
echo "Services Directory: ${SERVICES_DIR}"
echo "Output Branch: ${OUTPUT_BRANCH}"
echo "Policy: ${POLICY}"
echo "=========================================="

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

# Check if discrepancy report exists
if [ ! -f "${DISCREPANCY_REPORT}" ]; then
    echo "Error: Discrepancy report not found: ${DISCREPANCY_REPORT}"
    exit 1
fi

# Create services directory if it doesn't exist
mkdir -p "${SERVICES_DIR}"

# Parse missing modules from discrepancy report
MISSING_MODULES=$(jq -r '.missing_modules[].module' "${DISCREPANCY_REPORT}")
TOTAL_MISSING=$(echo "${MISSING_MODULES}" | wc -l)

echo "Found ${TOTAL_MISSING} missing modules to scaffold"

# Function to determine service type (Node.js or Python)
determine_service_type() {
    local module_name="$1"
    
    # Python-based services (analytics, AI, ML)
    if [[ "${module_name}" =~ (analytics|recommendation|ai|ml|transcoder) ]]; then
        echo "python"
    else
        echo "nodejs"
    fi
}

# Function to scaffold a Node.js service
scaffold_nodejs_service() {
    local module_name="$1"
    local service_dir="${SERVICES_DIR}/${module_name}"
    
    echo "  Scaffolding Node.js service: ${module_name}"
    
    mkdir -p "${service_dir}"
    
    # Create Dockerfile
    cat > "${service_dir}/Dockerfile" <<'EOF'
FROM node:20-alpine

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --production

# Copy application code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Start application
CMD ["node", "server.js"]
EOF
    
    # Create package.json
    cat > "${service_dir}/package.json" <<EOF
{
  "name": "${module_name}",
  "version": "1.0.0",
  "description": "Nexus COS ${module_name} service",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest",
    "test:unit": "jest --testPathPattern=tests/unit",
    "test:integration": "jest --testPathPattern=tests/integration"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "nodemon": "^3.0.1",
    "supertest": "^6.3.3"
  }
}
EOF
    
    # Create server.js
    cat > "${service_dir}/server.js" <<EOF
const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    service: '${module_name}',
    timestamp: new Date().toISOString()
  });
});

// API root
app.get('/', (req, res) => {
  res.json({
    service: '${module_name}',
    version: '1.0.0',
    status: 'operational'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(\`${module_name} service listening on port \${PORT}\`);
});

module.exports = app;
EOF
    
    # Create README
    cat > "${service_dir}/README.md" <<EOF
# ${module_name}

Nexus COS ${module_name} service

## Overview

This service provides [DESCRIPTION NEEDED].

## API Endpoints

- \`GET /health\` - Health check endpoint
- \`GET /\` - Service information

## Environment Variables

- \`PORT\` - Service port (default: 3000)

## Development

\`\`\`bash
npm install
npm run dev
\`\`\`

## Testing

\`\`\`bash
npm test
\`\`\`

## Production

\`\`\`bash
npm start
\`\`\`
EOF
    
    # Create basic test
    mkdir -p "${service_dir}/tests/unit"
    cat > "${service_dir}/tests/unit/health.test.js" <<EOF
const request = require('supertest');
const app = require('../../server');

describe('Health Endpoint', () => {
  it('should return 200 OK', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });
});
EOF
    
    # Create .env.example
    cat > "${service_dir}/.env.example" <<EOF
PORT=3000
NODE_ENV=production
EOF
    
    echo "  ✓ Created Node.js service: ${module_name}"
}

# Function to scaffold a Python service
scaffold_python_service() {
    local module_name="$1"
    local service_dir="${SERVICES_DIR}/${module_name}"
    
    echo "  Scaffolding Python service: ${module_name}"
    
    mkdir -p "${service_dir}/app"
    
    # Create Dockerfile
    cat > "${service_dir}/Dockerfile" <<'EOF'
FROM python:3.12-slim

WORKDIR /usr/src/app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health').raise_for_status()"

# Start application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
    
    # Create requirements.txt
    cat > "${service_dir}/requirements.txt" <<EOF
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
python-dotenv==1.0.0
requests==2.31.0
EOF
    
    # Create main.py
    cat > "${service_dir}/app/main.py" <<EOF
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
import os

app = FastAPI(title="${module_name}", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {
        "status": "ok",
        "service": "${module_name}",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }

@app.get("/")
async def root():
    """Service information"""
    return {
        "service": "${module_name}",
        "version": "1.0.0",
        "status": "operational"
    }
EOF
    
    # Create README
    cat > "${service_dir}/README.md" <<EOF
# ${module_name}

Nexus COS ${module_name} service

## Overview

This service provides [DESCRIPTION NEEDED].

## API Endpoints

- \`GET /health\` - Health check endpoint
- \`GET /\` - Service information
- \`GET /docs\` - OpenAPI documentation

## Environment Variables

- \`PORT\` - Service port (default: 8000)

## Development

\`\`\`bash
pip install -r requirements.txt
uvicorn app.main:app --reload
\`\`\`

## Testing

\`\`\`bash
pytest
\`\`\`

## Production

\`\`\`bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
\`\`\`
EOF
    
    # Create basic test
    mkdir -p "${service_dir}/tests"
    cat > "${service_dir}/tests/test_health.py" <<EOF
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
EOF
    
    # Create .env.example
    cat > "${service_dir}/.env.example" <<EOF
PORT=8000
ENVIRONMENT=production
EOF
    
    echo "  ✓ Created Python service: ${module_name}"
}

# Scaffold each missing module
for module in ${MISSING_MODULES}; do
    # Skip if already exists
    if [ -d "${SERVICES_DIR}/${module}" ]; then
        echo "  Skipping ${module} (already exists)"
        continue
    fi
    
    # Determine service type and scaffold
    service_type=$(determine_service_type "${module}")
    
    if [ "${service_type}" == "python" ]; then
        scaffold_python_service "${module}"
    else
        scaffold_nodejs_service "${module}"
    fi
done

echo ""
echo "=========================================="
echo "Scaffolding Complete!"
echo "=========================================="
echo "Total modules scaffolded: ${TOTAL_MISSING}"
echo "Location: ${SERVICES_DIR}"
echo ""
echo "Next steps:"
echo "  1. Review generated services"
echo "  2. Implement business logic"
echo "  3. Run tests: npm test (Node.js) or pytest (Python)"
echo "  4. Build images: docker build"
echo "=========================================="

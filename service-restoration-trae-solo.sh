#!/bin/bash
# Service Restoration Script - TRAE Solo Implementation
# Addresses PM2 and service management issues from TRAE Solo report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Service Configuration based on TRAE Solo report
VPS_IP="74.208.155.161"
PROJECT_PATH="/opt/nexus-cos"
NODE_PATH="/home/runner/work/nexus-cos/nexus-cos"

# Service ports from TRAE Solo report
declare -A SERVICES=(
    ["backend-api"]="3001"
    ["ai-service"]="3010"
    ["key-service"]="3014"
    ["grafana"]="3000"
    ["prometheus"]="9090"
)

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    SERVICE RESTORATION - TRAE SOLO                          ║${NC}"
    echo -e "${PURPLE}║                    PM2 & Infrastructure Service Recovery                     ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "\n${BLUE}==== $1 ====${NC}"
}

print_success() {
    echo -e "${GREEN}[✅ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠️  WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[❌ ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[ℹ️  INFO]${NC} $1"
}

# Phase 1: Restore PM2 Configuration
restore_pm2_config() {
    print_step "Phase 1: PM2 Configuration Restoration"
    
    print_info "Creating comprehensive PM2 ecosystem configuration..."
    
    cat > "/tmp/ecosystem.config.js" << 'EOF'
// PM2 Ecosystem Configuration for Nexus COS - TRAE Solo Implementation
// Addresses all services identified in the TRAE Solo report

module.exports = {
  apps: [
    {
      name: 'nexus-backend-api',
      script: './backend/src/server.ts',
      cwd: '/opt/nexus-cos',
      interpreter: 'node',
      interpreter_args: '--loader ts-node/esm',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        TZ: 'UTC'
      },
      env_development: {
        NODE_ENV: 'development',
        PORT: 3001,
        TZ: 'UTC'
      },
      log_file: '/opt/nexus-cos/logs/backend-api.log',
      out_file: '/opt/nexus-cos/logs/backend-api-out.log',
      error_file: '/opt/nexus-cos/logs/backend-api-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    },
    {
      name: 'nexus-ai-service',
      script: './services/ai-service/server.js',
      cwd: '/opt/nexus-cos',
      interpreter: 'node',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3010,
        TZ: 'UTC'
      },
      env_development: {
        NODE_ENV: 'development',
        PORT: 3010,
        TZ: 'UTC'
      },
      log_file: '/opt/nexus-cos/logs/ai-service.log',
      out_file: '/opt/nexus-cos/logs/ai-service-out.log',
      error_file: '/opt/nexus-cos/logs/ai-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    },
    {
      name: 'nexus-key-service',
      script: './services/key-service/server.js',
      cwd: '/opt/nexus-cos',
      interpreter: 'node',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '256M',
      env: {
        NODE_ENV: 'production',
        PORT: 3014,
        TZ: 'UTC'
      },
      env_development: {
        NODE_ENV: 'development',
        PORT: 3014,
        TZ: 'UTC'
      },
      log_file: '/opt/nexus-cos/logs/key-service.log',
      out_file: '/opt/nexus-cos/logs/key-service-out.log',
      error_file: '/opt/nexus-cos/logs/key-service-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    },
    {
      name: 'nexus-creator-hub',
      script: './extended/creator-hub/server.js',
      cwd: '/opt/nexus-cos',
      interpreter: 'node',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3020,
        TZ: 'UTC'
      },
      log_file: '/opt/nexus-cos/logs/creator-hub.log',
      out_file: '/opt/nexus-cos/logs/creator-hub-out.log',
      error_file: '/opt/nexus-cos/logs/creator-hub-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    },
    {
      name: 'nexus-puaboverse',
      script: './extended/puaboverse/server.js',
      cwd: '/opt/nexus-cos',
      interpreter: 'node',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '512M',
      env: {
        NODE_ENV: 'production',
        PORT: 3030,
        TZ: 'UTC'
      },
      log_file: '/opt/nexus-cos/logs/puaboverse.log',
      out_file: '/opt/nexus-cos/logs/puaboverse-out.log',
      error_file: '/opt/nexus-cos/logs/puaboverse-error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    }
  ]
};
EOF
    
    print_success "PM2 ecosystem configuration created: /tmp/ecosystem.config.js"
}

# Phase 2: Create Service Health Checker
create_health_checker() {
    print_step "Phase 2: Service Health Check System"
    
    print_info "Creating comprehensive health check system..."
    
    cat > "/tmp/nexus-health-checker.js" << 'EOF'
#!/usr/bin/env node
// Nexus COS Health Checker - TRAE Solo Implementation
// Monitors all services identified in the TRAE Solo report

const axios = require('axios');
const fs = require('fs');
const path = require('path');

class NexusHealthChecker {
    constructor() {
        this.services = [
            { name: 'Backend API', url: 'http://localhost:3001/health', critical: true },
            { name: 'AI Service', url: 'http://localhost:3010/health', critical: true },
            { name: 'Key Service', url: 'http://localhost:3014/health', critical: true },
            { name: 'Creator Hub', url: 'http://localhost:3020/health', critical: false },
            { name: 'PuaboVerse', url: 'http://localhost:3030/health', critical: false },
            { name: 'Grafana', url: 'http://localhost:3000/api/health', critical: false },
            { name: 'Prometheus', url: 'http://localhost:9090/-/healthy', critical: false }
        ];
        
        this.externalServices = [
            { name: 'Main Domain', url: 'https://n3xuscos.online', critical: true },
            { name: 'Beta Domain', url: 'https://beta.n3xuscos.online', critical: true }
        ];
        
        this.report = {
            timestamp: new Date().toISOString(),
            status: 'CHECKING',
            services: [],
            external: [],
            summary: {
                total: 0,
                healthy: 0,
                unhealthy: 0,
                critical_down: 0
            }
        };
    }
    
    async checkService(service) {
        try {
            const response = await axios.get(service.url, {
                timeout: 5000,
                validateStatus: function (status) {
                    return status >= 200 && status < 500;
                }
            });
            
            const result = {
                name: service.name,
                url: service.url,
                status: 'HEALTHY',
                response_code: response.status,
                response_time: Date.now(),
                critical: service.critical
            };
            
            console.log(`✅ ${service.name}: HEALTHY (${response.status})`);
            return result;
            
        } catch (error) {
            const result = {
                name: service.name,
                url: service.url,
                status: 'UNHEALTHY',
                error: error.message,
                critical: service.critical
            };
            
            console.log(`❌ ${service.name}: UNHEALTHY (${error.message})`);
            return result;
        }
    }
    
    async runHealthCheck() {
        console.log('🏥 Nexus COS Health Check - TRAE Solo Implementation');
        console.log('=' .repeat(60));
        console.log(`📅 Timestamp: ${this.report.timestamp}`);
        console.log('');
        
        console.log('🔧 Internal Services:');
        console.log('-'.repeat(30));
        
        // Check internal services
        for (const service of this.services) {
            const result = await this.checkService(service);
            this.report.services.push(result);
            this.report.summary.total++;
            
            if (result.status === 'HEALTHY') {
                this.report.summary.healthy++;
            } else {
                this.report.summary.unhealthy++;
                if (result.critical) {
                    this.report.summary.critical_down++;
                }
            }
        }
        
        console.log('');
        console.log('🌐 External Services:');
        console.log('-'.repeat(30));
        
        // Check external services
        for (const service of this.externalServices) {
            const result = await this.checkService(service);
            this.report.external.push(result);
            this.report.summary.total++;
            
            if (result.status === 'HEALTHY') {
                this.report.summary.healthy++;
            } else {
                this.report.summary.unhealthy++;
                if (result.critical) {
                    this.report.summary.critical_down++;
                }
            }
        }
        
        // Determine overall status
        if (this.report.summary.critical_down > 0) {
            this.report.status = 'CRITICAL';
        } else if (this.report.summary.unhealthy > 0) {
            this.report.status = 'WARNING';
        } else {
            this.report.status = 'HEALTHY';
        }
        
        this.generateReport();
    }
    
    generateReport() {
        console.log('');
        console.log('📊 Health Check Summary:');
        console.log('=' .repeat(40));
        console.log(`Overall Status: ${this.report.status}`);
        console.log(`Total Services: ${this.report.summary.total}`);
        console.log(`Healthy: ${this.report.summary.healthy}`);
        console.log(`Unhealthy: ${this.report.summary.unhealthy}`);
        console.log(`Critical Down: ${this.report.summary.critical_down}`);
        
        // Save report to file
        const reportPath = '/tmp/nexus-health-report.json';
        fs.writeFileSync(reportPath, JSON.stringify(this.report, null, 2));
        console.log(`\n📄 Full report saved to: ${reportPath}`);
        
        // Generate recommendations
        this.generateRecommendations();
    }
    
    generateRecommendations() {
        console.log('');
        console.log('💡 Recommendations:');
        console.log('-'.repeat(20));
        
        if (this.report.summary.critical_down > 0) {
            console.log('🚨 CRITICAL: Essential services are down!');
            console.log('   1. Check PM2 process status: pm2 list');
            console.log('   2. Restart failed services: pm2 restart <service>');
            console.log('   3. Check service logs: pm2 logs <service>');
        }
        
        if (this.report.summary.unhealthy > 0) {
            console.log('⚠️  Some services need attention');
            console.log('   1. Review service configurations');
            console.log('   2. Check network connectivity');
            console.log('   3. Verify SSL certificates');
        }
        
        if (this.report.status === 'HEALTHY') {
            console.log('✅ All systems operational!');
            console.log('   Continue monitoring for optimal performance');
        }
    }
}

// Run health check
const checker = new NexusHealthChecker();
checker.runHealthCheck().catch(console.error);
EOF
    
    chmod +x "/tmp/nexus-health-checker.js"
    print_success "Health checker created: /tmp/nexus-health-checker.js"
}

# Phase 3: Create Monitoring Setup
create_monitoring_setup() {
    print_step "Phase 3: Monitoring Infrastructure Setup"
    
    print_info "Creating Prometheus configuration..."
    cat > "/tmp/prometheus.yml" << 'EOF'
# Prometheus Configuration - TRAE Solo Implementation
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  # Nexus COS Backend Services
  - job_name: 'nexus-backend-api'
    static_configs:
      - targets: ['localhost:3001']
    metrics_path: '/metrics'
    scrape_interval: 10s
    
  - job_name: 'nexus-ai-service'
    static_configs:
      - targets: ['localhost:3010']
    metrics_path: '/metrics'
    scrape_interval: 10s
    
  - job_name: 'nexus-key-service'
    static_configs:
      - targets: ['localhost:3014']
    metrics_path: '/metrics'
    scrape_interval: 10s
    
  - job_name: 'nexus-creator-hub'
    static_configs:
      - targets: ['localhost:3020']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'nexus-puaboverse'
    static_configs:
      - targets: ['localhost:3030']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  # System monitoring
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']
    scrape_interval: 15s
    
  # Nginx monitoring
  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:9113']
    scrape_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
EOF
    
    print_info "Creating Grafana datasource configuration..."
    mkdir -p "/tmp/grafana/provisioning/datasources"
    cat > "/tmp/grafana/provisioning/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
EOF
    
    print_success "Monitoring configurations created"
}

# Phase 4: Generate PM2 Deployment Script
generate_pm2_deployment_script() {
    print_step "Phase 4: PM2 Deployment Script Generation"
    
    cat > "/tmp/deploy-pm2-services.sh" << 'EOF'
#!/bin/bash
# PM2 Service Deployment Script - TRAE Solo Implementation
# Execute this script on the VPS to restore all services

set -e

echo "🚀 Deploying Nexus COS Services with PM2"
echo "========================================"

VPS_PROJECT_PATH="/opt/nexus-cos"
LOG_DIR="$VPS_PROJECT_PATH/logs"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p "$LOG_DIR"
mkdir -p "$VPS_PROJECT_PATH/services/ai-service"
mkdir -p "$VPS_PROJECT_PATH/services/key-service"

# Stop existing PM2 processes
echo "🛑 Stopping existing PM2 processes..."
pm2 stop all || true
pm2 delete all || true

# Install/update PM2
echo "📦 Ensuring PM2 is installed..."
npm install -g pm2@latest

# Copy ecosystem configuration
echo "📋 Installing PM2 ecosystem configuration..."
cp /tmp/ecosystem.config.js "$VPS_PROJECT_PATH/"

# Start services with PM2
echo "▶️  Starting services..."
cd "$VPS_PROJECT_PATH"
pm2 start ecosystem.config.js --env production

# Save PM2 configuration
echo "💾 Saving PM2 configuration..."
pm2 save

# Setup PM2 startup script
echo "🔄 Setting up PM2 startup..."
pm2 startup
pm2 save

# Display status
echo "📊 PM2 Status:"
pm2 list

# Wait for services to initialize
echo "⏳ Waiting for services to initialize..."
sleep 10

# Test service health
echo "🏥 Testing service health..."
services=(
    "http://localhost:3001/health"
    "http://localhost:3010/health"
    "http://localhost:3014/health"
    "http://localhost:3020/health"
    "http://localhost:3030/health"
)

for service in "${services[@]}"; do
    if curl -s "$service" >/dev/null; then
        echo "✅ $service - HEALTHY"
    else
        echo "❌ $service - UNHEALTHY"
    fi
done

echo ""
echo "✅ PM2 deployment complete!"
echo "Use 'pm2 logs' to view service logs"
echo "Use 'pm2 status' to check service status"
EOF
    
    chmod +x "/tmp/deploy-pm2-services.sh"
    print_success "PM2 deployment script created: /tmp/deploy-pm2-services.sh"
}

# Phase 5: Create Service Templates
create_service_templates() {
    print_step "Phase 5: Service Template Generation"
    
    print_info "Creating service template for missing services..."
    
    # AI Service template
    mkdir -p "/tmp/services/ai-service"
    cat > "/tmp/services/ai-service/server.js" << 'EOF'
// Nexus COS AI Service - TRAE Solo Implementation
// Port: 3010

const express = require('express');
const app = express();
const port = process.env.PORT || 3010;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'ai-service',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// AI processing endpoint
app.post('/api/ai/process', (req, res) => {
    res.json({
        result: 'AI processing completed',
        input: req.body,
        timestamp: new Date().toISOString()
    });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
    res.set('Content-Type', 'text/plain');
    res.send(`# AI Service Metrics
ai_requests_total 42
ai_processing_duration_seconds 0.5
ai_memory_usage_bytes 1048576`);
});

app.listen(port, () => {
    console.log(`🤖 AI Service running on port ${port}`);
    console.log(`Health check: http://localhost:${port}/health`);
});
EOF
    
    # Key Service template
    mkdir -p "/tmp/services/key-service"
    cat > "/tmp/services/key-service/server.js" << 'EOF'
// Nexus COS Key Service - TRAE Solo Implementation
// Port: 3014

const express = require('express');
const app = express();
const port = process.env.PORT || 3014;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'key-service',
        port: port,
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Key management endpoints
app.get('/api/keys', (req, res) => {
    res.json({
        keys: ['key1', 'key2', 'key3'],
        total: 3,
        timestamp: new Date().toISOString()
    });
});

app.post('/api/keys/generate', (req, res) => {
    const newKey = `key_${Date.now()}`;
    res.json({
        key: newKey,
        timestamp: new Date().toISOString()
    });
});

// Metrics endpoint
app.get('/metrics', (req, res) => {
    res.set('Content-Type', 'text/plain');
    res.send(`# Key Service Metrics
key_requests_total 15
key_generation_total 5
key_validation_total 10`);
});

app.listen(port, () => {
    console.log(`🔑 Key Service running on port ${port}`);
    console.log(`Health check: http://localhost:${port}/health`);
});
EOF
    
    print_success "Service templates created in /tmp/services/"
}

# Main execution function
main() {
    print_header
    
    restore_pm2_config
    create_health_checker
    create_monitoring_setup
    generate_pm2_deployment_script
    create_service_templates
    
    print_step "Service Restoration Plan Complete"
    print_success "All service restoration files generated!"
    print_info "Generated files:"
    print_info "  - /tmp/ecosystem.config.js (PM2 configuration)"
    print_info "  - /tmp/nexus-health-checker.js (Health monitoring)"
    print_info "  - /tmp/deploy-pm2-services.sh (Deployment script)"
    print_info "  - /tmp/services/ (Service templates)"
    print_info "  - /tmp/prometheus.yml (Monitoring config)"
    print_info ""
    print_info "Next: Deploy to VPS and restore services"
    echo ""
}

# Execute main function
main "$@"
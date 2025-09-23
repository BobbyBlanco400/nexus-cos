#!/bin/bash
# Monitoring Setup Script for Nexus COS
# Configures Prometheus, Grafana, and health endpoints

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$PROJECT_ROOT/logs/monitoring-setup.log"
MONITORING_DIR="$PROJECT_ROOT/monitoring"
ARTIFACTS_DIR="$PROJECT_ROOT/artifacts"

# Create directories
mkdir -p "$(dirname "$LOG_FILE")" "$MONITORING_DIR" "$ARTIFACTS_DIR"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "Starting monitoring setup for Nexus COS"

# Create Prometheus configuration
log "Creating Prometheus configuration..."
cat > "$MONITORING_DIR/prometheus.yml" << 'EOF'
# Prometheus Configuration for Nexus COS
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  # Node.js Backend
  - job_name: 'nexus-backend-node'
    static_configs:
      - targets: ['nexus-backend-node:3000']
    metrics_path: '/metrics'
    scrape_interval: 30s

  # Python Backend
  - job_name: 'nexus-backend-python'
    static_configs:
      - targets: ['nexus-backend-python:3001']
    metrics_path: '/metrics'
    scrape_interval: 30s

  # Frontend (Nginx)
  - job_name: 'nexus-frontend'
    static_configs:
      - targets: ['nexus-frontend:80']
    metrics_path: '/nginx_status'
    scrape_interval: 30s

  # PostgreSQL Database
  - job_name: 'nexus-database'
    static_configs:
      - targets: ['postgres-exporter:9187']
    scrape_interval: 30s

  # Docker containers
  - job_name: 'docker'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 30s

  # Node Exporter (system metrics)
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 30s
EOF

# Create Prometheus alert rules
log "Creating Prometheus alert rules..."
cat > "$MONITORING_DIR/alert_rules.yml" << 'EOF'
# Alert Rules for Nexus COS
groups:
  - name: nexus-cos-alerts
    rules:
      # High CPU usage
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for more than 5 minutes"

      # High memory usage
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 85
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Memory usage is above 85% for more than 5 minutes"

      # Service down
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.job }} service is down"

      # High response time
      - alert: HighResponseTime
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time detected"
          description: "95th percentile response time is above 1 second"

      # Database connection issues
      - alert: DatabaseConnectionIssues
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection issues"
          description: "PostgreSQL database is not responding"

      # Disk space low
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space is low"
          description: "Available disk space is below 10%"
EOF

# Create Grafana provisioning configuration
log "Creating Grafana configuration..."
mkdir -p "$MONITORING_DIR/grafana/provisioning/datasources"
mkdir -p "$MONITORING_DIR/grafana/provisioning/dashboards"

cat > "$MONITORING_DIR/grafana/provisioning/datasources/prometheus.yml" << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://nexus-prometheus:9090
    isDefault: true
    editable: true
EOF

cat > "$MONITORING_DIR/grafana/provisioning/dashboards/dashboard.yml" << 'EOF'
apiVersion: 1

providers:
  - name: 'nexus-cos-dashboards'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF

# Create Grafana dashboard for Nexus COS
log "Creating Grafana dashboard..."
cat > "$MONITORING_DIR/grafana/provisioning/dashboards/nexus-cos-dashboard.json" << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Nexus COS Monitoring Dashboard",
    "tags": ["nexus-cos"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "System Overview",
        "type": "stat",
        "targets": [
          {
            "expr": "up",
            "legendFormat": "Services Up"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "CPU Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "100 - (avg by(instance) (irate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100)",
            "legendFormat": "CPU Usage %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100",
            "legendFormat": "Memory Usage %"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 8}
      },
      {
        "id": 4,
        "title": "HTTP Requests",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "Requests/sec"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 8}
      },
      {
        "id": 5,
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          },
          {
            "expr": "histogram_quantile(0.50, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "50th percentile"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 16}
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
EOF

# Create health check script
log "Creating health check script..."
cat > "$MONITORING_DIR/health-check.sh" << 'EOF'
#!/bin/bash
# Health Check Script for Nexus COS Services

set -euo pipefail

# Configuration
LOG_FILE="/tmp/health-check.log"
SERVICES=(
    "http://nexus-frontend:80/health:Frontend"
    "http://nexus-backend-node:3000/health:Node.js Backend"
    "http://nexus-backend-python:3001/health:Python Backend"
    "http://nexus-prometheus:9090/-/healthy:Prometheus"
    "http://nexus-grafana:3000/api/health:Grafana"
)

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Health check function
check_service() {
    local url="$1"
    local name="$2"
    
    if curl -f -s --max-time 10 "$url" > /dev/null 2>&1; then
        log "✓ $name is healthy"
        return 0
    else
        log "✗ $name is unhealthy"
        return 1
    fi
}

# Main health check
log "Starting health check for Nexus COS services"

healthy_count=0
total_count=${#SERVICES[@]}

for service in "${SERVICES[@]}"; do
    url=$(echo "$service" | cut -d: -f1-2)
    name=$(echo "$service" | cut -d: -f3-)
    
    if check_service "$url" "$name"; then
        ((healthy_count++))
    fi
done

log "Health check completed: $healthy_count/$total_count services healthy"

if [[ $healthy_count -eq $total_count ]]; then
    log "All services are healthy"
    exit 0
else
    log "Some services are unhealthy"
    exit 1
fi
EOF

chmod +x "$MONITORING_DIR/health-check.sh"

# Create monitoring startup script
log "Creating monitoring startup script..."
cat > "$MONITORING_DIR/start-monitoring.sh" << 'EOF'
#!/bin/bash
# Start Monitoring Services for Nexus COS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting monitoring services..."

# Start monitoring stack with Docker Compose
cd "$PROJECT_ROOT"
docker-compose -f .trae/services.yaml up -d nexus-prometheus nexus-grafana

# Wait for services to be ready
log "Waiting for monitoring services to start..."
sleep 30

# Run health check
log "Running health check..."
"$SCRIPT_DIR/health-check.sh"

log "Monitoring services started successfully"
log "Grafana: http://localhost:3000 (admin/admin)"
log "Prometheus: http://localhost:9090"
EOF

chmod +x "$MONITORING_DIR/start-monitoring.sh"

# Create monitoring Docker Compose override
log "Creating monitoring Docker Compose override..."
cat > "$MONITORING_DIR/docker-compose.monitoring.yml" << 'EOF'
# Monitoring Services Override for Nexus COS
version: '3.8'

services:
  # Node Exporter for system metrics
  node-exporter:
    image: prom/node-exporter:latest
    container_name: nexus-node-exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - nexus-network

  # cAdvisor for container metrics
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: nexus-cadvisor
    restart: unless-stopped
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    privileged: true
    devices:
      - /dev/kmsg
    networks:
      - nexus-network

  # PostgreSQL Exporter
  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    container_name: nexus-postgres-exporter
    restart: unless-stopped
    ports:
      - "9187:9187"
    environment:
      DATA_SOURCE_NAME: "postgresql://nexus_user:nexus_password@nexus-database:5432/nexus_db?sslmode=disable"
    networks:
      - nexus-network
    depends_on:
      - nexus-database

networks:
  nexus-network:
    external: true
EOF

# Create monitoring report
log "Generating monitoring setup report..."
cat > "$ARTIFACTS_DIR/monitoring-setup-report.txt" << EOF
Nexus COS Monitoring Setup Report
=================================

Setup Date: $(date)
Monitoring Directory: $MONITORING_DIR

Setup Status: SUCCESS

Components Configured:
- Prometheus (metrics collection)
- Grafana (visualization dashboard)
- Node Exporter (system metrics)
- cAdvisor (container metrics)
- PostgreSQL Exporter (database metrics)
- Alert Rules (CPU, memory, disk, services)
- Health Check Script

Configuration Files Created:
- prometheus.yml (Prometheus configuration)
- alert_rules.yml (Alert rules)
- grafana/provisioning/ (Grafana configuration)
- nexus-cos-dashboard.json (Custom dashboard)
- health-check.sh (Health monitoring script)
- start-monitoring.sh (Startup script)
- docker-compose.monitoring.yml (Additional services)

Access Information:
- Grafana Dashboard: http://localhost:3000 (admin/admin)
- Prometheus UI: http://localhost:9090
- Node Exporter: http://localhost:9100
- cAdvisor: http://localhost:8080
- PostgreSQL Exporter: http://localhost:9187

Monitoring Features:
- Real-time system metrics
- Application performance monitoring
- Database monitoring
- Container resource monitoring
- Automated alerting
- Custom dashboards
- Health checks

Next Steps:
1. Start monitoring services: ./monitoring/start-monitoring.sh
2. Access Grafana dashboard
3. Configure alert notifications
4. Set up log aggregation
5. Create custom alerts

Monitoring setup completed successfully!
EOF

log "Monitoring setup completed successfully!"
log "Configuration files created in: $MONITORING_DIR"
log "Setup report saved to: $ARTIFACTS_DIR/monitoring-setup-report.txt"
log "To start monitoring: $MONITORING_DIR/start-monitoring.sh"

exit 0
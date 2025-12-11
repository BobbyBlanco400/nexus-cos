#!/bin/bash

set -e

K8S_DIR="/home/runner/work/nexus-cos/nexus-cos/docs/THIIO-HANDOFF/deployment/kubernetes"

echo "Generating Kubernetes configurations..."

# Create namespace configuration
cat > "$K8S_DIR/namespace.yaml" << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-auth
  labels:
    name: nexus-auth
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-content
  labels:
    name: nexus-content
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-commerce
  labels:
    name: nexus-commerce
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-ai
  labels:
    name: nexus-ai
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-finance
  labels:
    name: nexus-finance
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-logistics
  labels:
    name: nexus-logistics
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-entertainment
  labels:
    name: nexus-entertainment
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-platform
  labels:
    name: nexus-platform
---
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-specialized
  labels:
    name: nexus-specialized
EOF

# Create sample deployment
cat > "$K8S_DIR/deployments/backend-api.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: nexus-platform
  labels:
    app: backend-api
    version: v1
spec:
  replicas: 5
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
        version: v1
    spec:
      containers:
      - name: backend-api
        image: nexus-cos/backend-api:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: PORT
          value: "3000"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: jwt-secret
              key: secret
        resources:
          requests:
            cpu: "1000m"
            memory: "2Gi"
          limits:
            cpu: "2000m"
            memory: "4Gi"
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-api-hpa
  namespace: nexus-platform
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
EOF

# Create service configuration
cat > "$K8S_DIR/services/backend-api.yaml" << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: backend-api
  namespace: nexus-platform
  labels:
    app: backend-api
spec:
  type: ClusterIP
  ports:
  - port: 3000
    targetPort: 3000
    protocol: TCP
    name: http
  selector:
    app: backend-api
EOF

# Create ConfigMap
cat > "$K8S_DIR/configmaps/app-config.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: nexus-platform
data:
  LOG_LEVEL: "info"
  NODE_ENV: "production"
  API_VERSION: "v2"
  ENABLE_METRICS: "true"
  ENABLE_TRACING: "true"
EOF

# Create secrets template
cat > "$K8S_DIR/secrets-template.yaml" << 'EOF'
# Kubernetes Secrets Template
# DO NOT commit actual secrets to version control
# This is a template showing the structure

apiVersion: v1
kind: Secret
metadata:
  name: database-credentials
  namespace: nexus-platform
type: Opaque
stringData:
  url: "postgresql://user:password@postgresql:5432/nexus_cos"
  username: "nexus"
  password: "<REPLACE_WITH_ACTUAL_PASSWORD>"
---
apiVersion: v1
kind: Secret
metadata:
  name: redis-credentials
  namespace: nexus-platform
type: Opaque
stringData:
  url: "redis://redis:6379"
  password: "<REPLACE_WITH_ACTUAL_PASSWORD>"
---
apiVersion: v1
kind: Secret
metadata:
  name: jwt-secret
  namespace: nexus-platform
type: Opaque
stringData:
  secret: "<REPLACE_WITH_ACTUAL_JWT_SECRET>"
---
apiVersion: v1
kind: Secret
metadata:
  name: aws-credentials
  namespace: nexus-platform
type: Opaque
stringData:
  access-key-id: "<REPLACE_WITH_AWS_ACCESS_KEY>"
  secret-access-key: "<REPLACE_WITH_AWS_SECRET_KEY>"
---
apiVersion: v1
kind: Secret
metadata:
  name: api-keys
  namespace: nexus-platform
type: Opaque
stringData:
  stripe-api-key: "<REPLACE_WITH_STRIPE_KEY>"
  sendgrid-api-key: "<REPLACE_WITH_SENDGRID_KEY>"
  blockchain-rpc-url: "<REPLACE_WITH_BLOCKCHAIN_URL>"
EOF

echo "✓ Generated Kubernetes configurations"

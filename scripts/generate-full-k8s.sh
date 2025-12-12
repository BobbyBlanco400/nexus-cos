#!/bin/bash

# Generate complete Kubernetes manifests for all 52+ services and 43 modules
# Part of the THIIO Complete Handoff Package

set -e

echo "========================================="
echo "Nexus COS - Full K8s Manifest Generator"
echo "========================================="
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_OUTPUT_DIR="$PROJECT_ROOT/dist/kubernetes-manifests"

# Create output directory
rm -rf "$K8S_OUTPUT_DIR"
mkdir -p "$K8S_OUTPUT_DIR"/{deployments,services,configmaps,secrets}

echo "Generating Kubernetes manifests for all services..."
echo ""

# Counter for generated manifests
DEPLOYMENT_COUNT=0
SERVICE_COUNT=0

# Generate namespace
cat > "$K8S_OUTPUT_DIR/namespace.yaml" <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: nexus-cos
  labels:
    name: nexus-cos
    environment: production
EOF

echo "✓ Generated namespace.yaml"

# Function to generate deployment manifest
generate_deployment() {
  local SERVICE_NAME=$1
  local PORT=${2:-3000}
  local IMAGE=${3:-"nexus-cos/$SERVICE_NAME:latest"}
  
  cat > "$K8S_OUTPUT_DIR/deployments/${SERVICE_NAME}.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${SERVICE_NAME}
  namespace: nexus-cos
  labels:
    app: ${SERVICE_NAME}
    tier: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${SERVICE_NAME}
  template:
    metadata:
      labels:
        app: ${SERVICE_NAME}
    spec:
      containers:
      - name: ${SERVICE_NAME}
        image: ${IMAGE}
        ports:
        - containerPort: ${PORT}
          name: http
        env:
        - name: NODE_ENV
          value: "production"
        - name: PORT
          value: "${PORT}"
        envFrom:
        - configMapRef:
            name: app-config
        - secretRef:
            name: app-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: ${PORT}
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: ${PORT}
          initialDelaySeconds: 20
          periodSeconds: 5
EOF
  
  DEPLOYMENT_COUNT=$((DEPLOYMENT_COUNT + 1))
}

# Function to generate service manifest
generate_service() {
  local SERVICE_NAME=$1
  local PORT=${2:-3000}
  local TARGET_PORT=${3:-$PORT}
  
  cat > "$K8S_OUTPUT_DIR/services/${SERVICE_NAME}.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: nexus-cos
  labels:
    app: ${SERVICE_NAME}
spec:
  type: ClusterIP
  selector:
    app: ${SERVICE_NAME}
  ports:
  - name: http
    port: ${PORT}
    targetPort: ${TARGET_PORT}
    protocol: TCP
EOF
  
  SERVICE_COUNT=$((SERVICE_COUNT + 1))
}

# Generate manifests for all services discovered in the services directory
if [ -d "$PROJECT_ROOT/services" ]; then
  for service_dir in "$PROJECT_ROOT/services"/*; do
    if [ -d "$service_dir" ]; then
      SERVICE_NAME=$(basename "$service_dir")
      
      # Skip README or non-service directories
      if [ "$SERVICE_NAME" == "README.md" ]; then
        continue
      fi
      
      # Determine port from package.json or use default
      PORT=3000
      if [ -f "$service_dir/package.json" ]; then
        # Try to extract port from package.json scripts
        PORT=$(grep -o '"start".*PORT=[0-9]*' "$service_dir/package.json" | grep -o '[0-9]*' | head -1 || echo "3000")
      fi
      
      generate_deployment "$SERVICE_NAME" "$PORT"
      generate_service "$SERVICE_NAME" "$PORT"
      echo "✓ Generated manifests for: $SERVICE_NAME (port: $PORT)"
    fi
  done
fi

# Generate ConfigMap template
cat > "$K8S_OUTPUT_DIR/configmaps/app-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: nexus-cos
data:
  DATABASE_HOST: "postgres-service"
  DATABASE_PORT: "5432"
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  LOG_LEVEL: "info"
  API_VERSION: "v1"
EOF

echo "✓ Generated configmap: app-config.yaml"

# Generate Secrets template
cat > "$K8S_OUTPUT_DIR/secrets/secrets-template.yaml" <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: nexus-cos
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:password@postgres-service:5432/nexus_cos"
  JWT_SECRET: "CHANGE_ME_IN_PRODUCTION"
  API_KEY: "CHANGE_ME_IN_PRODUCTION"
  REDIS_PASSWORD: "CHANGE_ME_IN_PRODUCTION"
  ENCRYPTION_KEY: "CHANGE_ME_IN_PRODUCTION"
EOF

echo "✓ Generated secrets template: secrets-template.yaml"

# Generate Ingress
cat > "$K8S_OUTPUT_DIR/ingress.yaml" <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nexus-cos-ingress
  namespace: nexus-cos
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - nexus-cos.example.com
    secretName: nexus-cos-tls
  rules:
  - host: nexus-cos.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-api
            port:
              number: 3000
EOF

echo "✓ Generated ingress.yaml"

# Generate deployment script
cat > "$K8S_OUTPUT_DIR/deploy.sh" <<'EOF'
#!/bin/bash
# Deploy all Kubernetes manifests

set -e

echo "Deploying Nexus COS to Kubernetes..."

# Apply namespace first
kubectl apply -f namespace.yaml

# Apply ConfigMaps and Secrets
kubectl apply -f configmaps/
kubectl apply -f secrets/

# Apply Deployments
kubectl apply -f deployments/

# Apply Services
kubectl apply -f services/

# Apply Ingress
kubectl apply -f ingress.yaml

echo ""
echo "✓ Deployment complete!"
echo ""
echo "Check status with:"
echo "  kubectl get pods -n nexus-cos"
echo "  kubectl get services -n nexus-cos"
EOF

chmod +x "$K8S_OUTPUT_DIR/deploy.sh"
echo "✓ Generated deploy.sh"

# Summary
echo ""
echo "========================================="
echo "Manifest Generation Complete!"
echo "========================================="
echo ""
echo "Output directory: $K8S_OUTPUT_DIR"
echo "Deployments generated: $DEPLOYMENT_COUNT"
echo "Services generated: $SERVICE_COUNT"
echo ""
echo "To deploy to Kubernetes:"
echo "  cd $K8S_OUTPUT_DIR"
echo "  ./deploy.sh"
echo ""
echo "Or manually:"
echo "  kubectl apply -f $K8S_OUTPUT_DIR/"
echo ""

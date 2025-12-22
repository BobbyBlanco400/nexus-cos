# NΞ3XUS·COS PF-MASTER v3.0 - Security Best Practices

## 🔒 Production Deployment Security Checklist

### Critical: Before Production Deployment

#### 1. Secret Management ⚠️ REQUIRED

**Default Passwords Must Be Changed**

The following files contain placeholder passwords that MUST be changed before production:

- `k8s/tiers/tier-0/postgres.yaml` - Line 12: `CHANGE_ME_IN_PRODUCTION`
- `k8s/tiers/tier-0/redis.yaml` - Line 12: `CHANGE_ME_IN_PRODUCTION`
- `.env.pf-master.example` - Multiple passwords marked as `changeme`

**Recommended Approaches:**

1. **Kubernetes Secrets (Manual)**:
   ```bash
   kubectl create secret generic postgres-secret \
     --from-literal=POSTGRES_PASSWORD=$(openssl rand -base64 32) \
     --from-literal=POSTGRES_USER=nexus \
     --from-literal=POSTGRES_DB=nexus_cos \
     -n nexus-core
   
   kubectl create secret generic redis-secret \
     --from-literal=REDIS_PASSWORD=$(openssl rand -base64 32) \
     -n nexus-core
   ```

2. **External Secrets Operator** (Recommended):
   ```yaml
   apiVersion: external-secrets.io/v1beta1
   kind: ExternalSecret
   metadata:
     name: postgres-secret
     namespace: nexus-core
   spec:
     secretStoreRef:
       name: aws-secrets-manager
       kind: SecretStore
     target:
       name: postgres-secret
     data:
       - secretKey: POSTGRES_PASSWORD
         remoteRef:
           key: nexus-cos/postgres
   ```

3. **Sealed Secrets**:
   ```bash
   # Encrypt secrets that can be committed to git
   kubeseal --format yaml < postgres-secret.yaml > postgres-secret-sealed.yaml
   ```

4. **HashiCorp Vault**:
   ```yaml
   vault:
     address: "https://vault.example.com"
     role: "nexus-cos"
     auth:
       path: "kubernetes"
   ```

#### 2. TLS/SSL Certificates

**Generate or Import Certificates**:

```bash
# Using cert-manager (recommended)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@n3xuscos.online
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

#### 3. Network Security

**Apply Network Policies**:

```yaml
# Default deny all ingress
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: nexus-core
spec:
  podSelector: {}
  policyTypes:
  - Ingress

# Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-api
  namespace: nexus-core
spec:
  podSelector:
    matchLabels:
      app: backend-api
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: nexus-core
    ports:
    - protocol: TCP
      port: 3000
```

#### 4. RBAC Configuration

**Create Service Accounts**:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nexus-cos-sa
  namespace: nexus-core

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nexus-cos-role
  namespace: nexus-core
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nexus-cos-rolebinding
  namespace: nexus-core
subjects:
- kind: ServiceAccount
  name: nexus-cos-sa
  namespace: nexus-core
roleRef:
  kind: Role
  name: nexus-cos-role
  apiGroup: rbac.authorization.k8s.io
```

#### 5. Image Security

**Use Specific Image Tags** (not `latest`):

```yaml
# Bad
image: nexus-cos/backend-api:latest

# Good
image: nexus-cos/backend-api:v3.0.0-sha256-abc123
```

**Enable Image Scanning**:

```bash
# Using Trivy
trivy image nexus-cos/backend-api:v3.0.0

# Using Clair
clairctl analyze nexus-cos/backend-api:v3.0.0
```

#### 6. Pod Security Standards

**Enforce Pod Security Policy**:

```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

---

## 🛡️ Security Configurations Implemented

### Container Security

✅ **Non-root User**:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
```

✅ **Read-only Root Filesystem**:
```yaml
securityContext:
  readOnlyRootFilesystem: true
```

✅ **Drop All Capabilities**:
```yaml
securityContext:
  capabilities:
    drop:
    - ALL
```

✅ **Prevent Privilege Escalation**:
```yaml
securityContext:
  allowPrivilegeEscalation: false
```

### Data Encryption

✅ **Secrets Encryption at Rest** (via Kubernetes):
```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <base64-encoded-secret>
    - identity: {}
```

✅ **TLS for All Services** (via Ingress):
```yaml
spec:
  tls:
  - hosts:
    - n3xuscos.online
    secretName: nexus-cos-tls
```

✅ **Database Encryption** (PostgreSQL):
```yaml
env:
- name: POSTGRES_INITDB_ARGS
  value: "--encoding=UTF8 --data-checksums"
```

### Network Security

✅ **Network Policies**: Default deny with explicit allow
✅ **Service Mesh Ready**: Can integrate Istio/Linkerd
✅ **Ingress SSL/TLS**: NGINX with certificate management

### Audit Logging

✅ **Immutable Audit Logs** (Ledger Service):
```yaml
env:
- name: AUDIT_MODE
  value: "immutable"
```

✅ **Kubernetes Audit Policy**:
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  resources:
  - group: ""
    resources: ["secrets", "configmaps"]
```

---

## 🔐 AWS Security (Terraform)

### EKS Cluster Security

✅ **Private Endpoint**:
```hcl
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false
```

✅ **KMS Encryption**:
```hcl
encryption_config {
  resources = ["secrets"]
  provider {
    key_arn = aws_kms_key.eks.arn
  }
}
```

✅ **VPC Security Groups**:
```hcl
vpc_security_group_ids = [
  aws_security_group.cluster_sg.id
]
```

### S3 Security

✅ **Server-Side Encryption**:
```hcl
server_side_encryption_configuration {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

✅ **Versioning**:
```hcl
versioning {
  enabled = true
}
```

✅ **Bucket Policies** (Deny HTTP):
```json
{
  "Effect": "Deny",
  "Principal": "*",
  "Action": "s3:*",
  "Resource": "arn:aws:s3:::bucket/*",
  "Condition": {
    "Bool": {
      "aws:SecureTransport": "false"
    }
  }
}
```

---

## 📊 Security Monitoring

### Enable Audit Logging

```bash
# Kubernetes audit logs
kubectl logs -n kube-system -l component=kube-apiserver --tail=100

# Application logs
kubectl logs -n nexus-ledger ledger-mgr-xxx

# Security events
kubectl get events -n nexus-core --sort-by='.lastTimestamp'
```

### Security Scanning

```bash
# Scan images
trivy image --severity HIGH,CRITICAL nexus-cos/backend-api:v3.0.0

# Scan Kubernetes manifests
kubesec scan k8s/tiers/tier-0/postgres.yaml

# Scan Helm charts
helm lint ./helm/nexus-cos
```

### Vulnerability Management

```bash
# Update dependencies
npm audit fix
pip-audit

# Scan for vulnerabilities
snyk test

# Container scanning
docker scan nexus-cos/backend-api:v3.0.0
```

---

## 🚨 Incident Response

### Security Incident Checklist

1. **Isolate affected pods**:
   ```bash
   kubectl scale deployment <name> --replicas=0 -n <namespace>
   ```

2. **Capture evidence**:
   ```bash
   kubectl logs <pod> -n <namespace> > incident-logs.txt
   kubectl describe pod <pod> -n <namespace> > pod-details.txt
   ```

3. **Review audit logs**:
   ```bash
   kubectl logs -n kube-system kube-apiserver-xxx | grep <suspicious-activity>
   ```

4. **Rotate secrets**:
   ```bash
   kubectl delete secret <secret-name> -n <namespace>
   kubectl create secret generic <secret-name> --from-literal=...
   kubectl rollout restart deployment/<name> -n <namespace>
   ```

5. **Document and report** according to SOC-2 procedures

---

## ✅ Pre-Production Security Verification

Run this checklist before going to production:

- [ ] All default passwords changed
- [ ] TLS certificates installed
- [ ] Network policies applied
- [ ] RBAC configured
- [ ] Image tags are specific (not `latest`)
- [ ] Secrets encrypted at rest
- [ ] Pod security policies enforced
- [ ] Audit logging enabled
- [ ] Vulnerability scanning completed
- [ ] Backup and disaster recovery tested
- [ ] Incident response plan documented
- [ ] Security monitoring configured

---

## 📚 Additional Resources

- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [OWASP Kubernetes Top 10](https://owasp.org/www-project-kubernetes-top-ten/)
- [AWS EKS Security Best Practices](https://docs.aws.amazon.com/eks/latest/userguide/security-best-practices.html)

---

*Security is a continuous process. Regularly review and update security configurations.*

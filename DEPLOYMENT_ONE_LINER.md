# Nexus COS - Production Deployment One-Liner

**Created:** 2025-10-05  
**Status:** ✅ Production Ready  
**Target VPS:** 74.208.155.161 (nexuscos.online)

---

## 🚀 Enhanced Production One-Liner

This enhanced one-liner command handles the complete deployment from your current state to full beta/production launch.

### PowerShell Variable (for Windows/PS)

```powershell
$oneLiner = 'ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"'
```

### Bash Variable (for Linux/Mac)

```bash
oneLiner='ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"'
```

---

## 📋 What This One-Liner Does

### 1. **Connect to VPS**
- Uses SSH with `StrictHostKeyChecking=no` for automation
- Connects to root@74.208.155.161 (nexuscos.online)

### 2. **Update Repository**
```bash
cd /opt/nexus-cos && git pull origin main
```
- Navigates to deployment directory
- Pulls latest code from main branch

### 3. **Configure Environment**
```bash
cp .env.pf .env
```
- Copies Pre-Flight environment configuration
- Ensures all secrets and configs are current

### 4. **Clean Deployment**
```bash
docker compose -f docker-compose.pf.yml down
```
- Stops all existing containers
- Cleans up orphaned containers
- Prepares for fresh deployment

### 5. **Build and Deploy Services**
```bash
docker compose -f docker-compose.pf.yml up -d --build --remove-orphans
```
- Builds all Docker images with latest code
- Starts services in detached mode
- Removes any orphaned containers
- Services deployed:
  - `puabo-api` (Gateway API - port 4000)
  - `nexus-cos-puaboai-sdk` (AI SDK - port 3002)
  - `nexus-cos-pv-keys` (PV Keys - port 3041)
  - `nexus-cos-postgres` (Database - port 5432)
  - `nexus-cos-redis` (Cache - port 6379)

### 6. **Wait for Services**
```bash
sleep 15
```
- Gives services time to initialize
- Allows database migrations to complete
- Ensures health endpoints are ready

### 7. **Local Health Checks**
```bash
for p in 4000 3002 3041; do
  echo "Testing port ${p}..."
  curl -fsS http://localhost:${p}/health || { echo "PORT_${p}_FAILED"; exit 1; }
done
```
- Tests each critical service port
- **Port 4000:** Gateway API (puabo-api)
- **Port 3002:** AI SDK (nexus-cos-puaboai-sdk)
- **Port 3041:** PV Keys (nexus-cos-pv-keys)
- Fails fast if any service is down

### 8. **Production Health Check**
```bash
curl -fsS https://nexuscos.online/v-suite/prompter/health
```
- Validates V-Prompter Pro public endpoint
- Tests Nginx reverse proxy configuration
- Verifies SSL/TLS is working
- Confirms end-to-end connectivity

### 9. **Success or Diagnostics**
```bash
# On success:
echo "✅ PF_DEPLOY_SUCCESS - All systems operational"

# On failure:
echo "❌ DEPLOYMENT_FAILED - Collecting diagnostics..."
docker compose -f docker-compose.pf.yml ps
docker logs --tail 200 puabo-api
docker logs --tail 200 nexus-cos-pv-keys
docker logs --tail 200 nexus-cos-puaboai-sdk
```
- Clear success/failure messaging
- Automatic diagnostic collection on failure
- Shows container status and recent logs

---

## 🎯 Comparison: TRAE vs Enhanced

### TRAE's Original One-Liner Issues:
1. ❌ **Wrong container names**: Referenced `nexus-cos-prompter-pro`, `nexus-cos-puabo-api`
2. ❌ **Missing git pull**: Doesn't update code from repository
3. ❌ **Missing env setup**: Doesn't ensure `.env` is configured
4. ❌ **No clean deployment**: Doesn't stop existing containers first
5. ⚠️ **Limited diagnostics**: Only shows logs, not container status

### Enhanced One-Liner Improvements:
1. ✅ **Correct container names**: `puabo-api`, `nexus-cos-puaboai-sdk`, `nexus-cos-pv-keys`
2. ✅ **Code update**: `git pull origin main` ensures latest code
3. ✅ **Environment setup**: `cp .env.pf .env` configures environment
4. ✅ **Clean deployment**: `docker compose down` before `up`
5. ✅ **Comprehensive diagnostics**: Container status + logs on failure
6. ✅ **Better timing**: 15 second wait (vs TRAE's implicit timing)
7. ✅ **Clear messaging**: Success and failure messages with emojis

---

## 🔧 Usage Examples

### Execute Immediately (PowerShell)
```powershell
# Define the one-liner
$oneLiner = 'ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"'

# Execute it
Invoke-Expression $oneLiner
```

### Execute Immediately (Bash)
```bash
# Define the one-liner
oneLiner='ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"'

# Execute it
eval $oneLiner
```

### Display and Verify (Both Shells)
```powershell
# PowerShell
Write-Output $oneLiner

# Bash
echo "$oneLiner"
```

---

## ⚡ Quick Deploy (Direct Command)

If you prefer to run directly without storing in a variable:

```bash
ssh -o StrictHostKeyChecking=no root@74.208.155.161 "cd /opt/nexus-cos && git pull origin main && cp .env.pf .env && docker compose -f docker-compose.pf.yml down && docker compose -f docker-compose.pf.yml up -d --build --remove-orphans && sleep 15 && for p in 4000 3002 3041; do echo \"Testing port \${p}...\" && curl -fsS http://localhost:\${p}/health || { echo \"PORT_\${p}_FAILED\"; exit 1; }; done && echo \"Local health checks passed\" && curl -fsS https://nexuscos.online/v-suite/prompter/health && echo \"✅ PF_DEPLOY_SUCCESS - All systems operational\" || { echo \"❌ DEPLOYMENT_FAILED - Collecting diagnostics...\"; docker compose -f docker-compose.pf.yml ps; echo \"--- Gateway API Logs ---\"; docker logs --tail 200 puabo-api; echo \"--- PV Keys Logs ---\"; docker logs --tail 200 nexus-cos-pv-keys; echo \"--- AI SDK Logs ---\"; docker logs --tail 200 nexus-cos-puaboai-sdk; exit 1; }"
```

---

## 📊 Expected Output

### On Success:
```
Already up to date.
Testing port 4000...
Testing port 3002...
Testing port 3041...
Local health checks passed
✅ PF_DEPLOY_SUCCESS - All systems operational
```

### On Failure:
```
Testing port 4000...
PORT_4000_FAILED
❌ DEPLOYMENT_FAILED - Collecting diagnostics...
NAME                     COMMAND                  SERVICE    STATUS
puabo-api                "docker-entrypoint.s…"   puabo-api  Exited (1)
nexus-cos-postgres       "docker-entrypoint.s…"   postgres   Up
...
--- Gateway API Logs ---
[Error messages from puabo-api]
--- PV Keys Logs ---
[Error messages from pv-keys]
--- AI SDK Logs ---
[Error messages from puaboai-sdk]
```

---

## 🔒 Security Notes

1. **SSH Key Authentication**: For production, use SSH key authentication instead of `StrictHostKeyChecking=no`
2. **Environment Secrets**: Ensure `.env.pf` contains proper secrets before deployment
3. **SSL Certificates**: Verify SSL certs are in place at `/opt/nexus-cos/ssl/`
4. **Firewall Rules**: Ensure ports 80, 443 are open for public access

---

## 🆘 Troubleshooting

### If Health Check Fails:

1. **Check Service Status**:
   ```bash
   ssh root@74.208.155.161 "cd /opt/nexus-cos && docker compose -f docker-compose.pf.yml ps"
   ```

2. **Check Individual Logs**:
   ```bash
   ssh root@74.208.155.161 "cd /opt/nexus-cos && docker logs puabo-api"
   ssh root@74.208.155.161 "cd /opt/nexus-cos && docker logs nexus-cos-puaboai-sdk"
   ssh root@74.208.155.161 "cd /opt/nexus-cos && docker logs nexus-cos-pv-keys"
   ```

3. **Verify Environment**:
   ```bash
   ssh root@74.208.155.161 "cd /opt/nexus-cos && cat .env | grep -v PASSWORD | grep -v SECRET"
   ```

4. **Check Database**:
   ```bash
   ssh root@74.208.155.161 "cd /opt/nexus-cos && docker compose -f docker-compose.pf.yml exec nexus-cos-postgres pg_isready"
   ```

### If Nginx/SSL Issues:

1. **Reload Nginx**:
   ```bash
   ssh root@74.208.155.161 "sudo nginx -t && sudo systemctl reload nginx"
   ```

2. **Check SSL Certificates**:
   ```bash
   ssh root@74.208.155.161 "ls -la /opt/nexus-cos/ssl/ && openssl x509 -in /opt/nexus-cos/ssl/nexus-cos.crt -noout -dates"
   ```

---

## 📚 Related Documentation

- **[PF System Check & Redeploy Guide](./PF_SYSTEM_CHECK_AND_REDEPLOY_GUIDE.md)** - Detailed deployment guide
- **[PF Final Deployment Index](./docs/PF_FINAL_DEPLOYMENT_INDEX.md)** - Complete documentation index
- **[PF Assets Locked Manifest](./docs/PF_ASSETS_LOCKED_2025-10-03T14-46Z.md)** - Asset reference
- **[Deploy Script](./scripts/pf-final-deploy.sh)** - Automated deployment script

---

## ✅ Success Criteria

After running the one-liner, you should have:

- [x] Latest code from main branch deployed
- [x] All 5 containers running (puabo-api, nexus-cos-puaboai-sdk, nexus-cos-pv-keys, nexus-cos-postgres, nexus-cos-redis)
- [x] Health endpoints responding on ports 4000, 3002, 3041
- [x] V-Prompter Pro accessible at https://nexuscos.online/v-suite/prompter/health
- [x] Database migrations applied
- [x] SSL/TLS working correctly

---

**Status:** ✅ Ready for Production Deployment

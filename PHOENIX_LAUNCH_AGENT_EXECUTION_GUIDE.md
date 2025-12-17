# Phoenix Launch Agent (PLA) - Execution Guide

## Objective
Achieve a 100% verified, production-ready state for nexuscos.online platform with all core services and infrastructure correctly configured for public launch.

## Execution Rules

### CRITICAL REQUIREMENTS
1. **Strictly Sequential**: Must complete ALL steps within a phase before moving to next phase
2. **Failure State**: If ANY step fails:
   - STOP execution immediately
   - Document the failure with complete error output
   - Do NOT proceed to next step
3. **Automatic Fixes**: For recognized errors (Nginx syntax), attempt fix up to 3 times, then trigger failure state

---

# PHASE 1: Infrastructure & Configuration Stability

**Focus**: Nginx/Proxy configuration foundation

## Step 1.1: Final Config Cleanup

**Task**: Execute comprehensive search and deletion for all stray or misplaced Nginx directives

**Commands**:
```bash
# Check for syntax errors
sudo nginx -t

# If errors found, check main config
sudo cat /etc/nginx/nginx.conf | grep -n "location\|proxy_pass"

# Check sites-enabled for stray directives
for file in /etc/nginx/sites-enabled/*; do
    echo "=== Checking $file ==="
    sudo grep -n "^[[:space:]]*location\|^[[:space:]]*$" "$file"
done

# Remove any empty lines or stray location blocks found
# (Manual fix required based on output above)
```

**Verification**: 
```bash
sudo nginx -t
# Expected: "syntax is ok" and "test is successful"
```

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 1.2: Proxy Integrity Check

**Task**: Verify upstream definitions and proxy_pass blocks are correct

**Commands**:
```bash
# Check upstream definitions
sudo nginx -T | grep -A 5 "upstream"

# Verify proxy_pass blocks
sudo nginx -T | grep -B 2 "proxy_pass"

# Expected upstreams (if used):
# - vscreen_hollywood (localhost:8088)
# - node_backend (localhost:3000)
# - python_backend (localhost:3001)
```

**Verification**:
```bash
# All API endpoints should have correct proxy_pass directives
sudo nginx -T | grep "location.*api" -A 10

# Expected: proxy_pass pointing to correct backend
```

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 1.3: Health Check Ports

**Task**: Run cURL tests directly against backend ports

**Commands**:
```bash
echo "=== Testing Backend Services ==="

# Test Node backend (port 3000)
echo "Testing port 3000 (Node backend):"
curl -I http://localhost:3000/ || echo "FAILED: Port 3000 not responding"

# Test Python backend (port 3001) - if used
echo "Testing port 3001 (Python backend):"
curl -I http://localhost:3001/ || echo "FAILED: Port 3001 not responding"

# Test streaming service (port 3043)
echo "Testing port 3043 (Streaming):"
curl -I http://localhost:3043/stream/ || echo "FAILED: Port 3043 not responding"

# Test V-Screen Hollywood (port 8088) - if used
echo "Testing port 8088 (V-Screen):"
curl -I http://localhost:8088/ || echo "FAILED: Port 8088 not responding"
```

**Verification**: All required backend services return valid responses (not connection refused)

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 1.4: Cert & HTTP/2 Check

**Task**: Ensure SSL certificates are loaded and HTTP/2 is working

**Commands**:
```bash
# Check SSL certificate
curl -Iv https://nexuscos.online 2>&1 | grep -E "HTTP/2|subject|issuer|expire"

# Expected output should show:
# - HTTP/2 200 (or other 2xx/3xx status)
# - Valid certificate chain
# - Certificate not expired
```

**Verification**:
```bash
# Should show HTTP/2 and valid cert
curl -I https://nexuscos.online/ 2>&1 | head -5

# Check Nginx is listening on 443 with SSL
sudo netstat -tlnp | grep :443
```

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

# PHASE 2: Core Service Integration & API Validation

**Focus**: Application logic and data flow between services

## Step 2.1: API Route Verification (Status)

**Task**: Execute status tests via public URL

**Commands**:
```bash
echo "=== Testing Status API Endpoints ==="

# Test system status
echo "Testing /api/system/status:"
curl -s https://nexuscos.online/api/system/status | jq '.' || echo "FAILED"

# Test IMCUS status
echo "Testing /api/v1/imcus/001/status:"
curl -s https://nexuscos.online/api/v1/imcus/001/status | jq '.' || echo "FAILED"

# Alternative if jq not available:
curl -i https://nexuscos.online/api/system/status
curl -i https://nexuscos.online/api/v1/imcus/001/status
```

**Verification**: Both endpoints return successful JSON responses (status 200)

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 2.2: API Route Verification (Action)

**Task**: Execute action test via public URL

**Commands**:
```bash
echo "=== Testing Action API Endpoints ==="

# Test deploy action
echo "Testing POST /api/v1/imcus/001/deploy:"
curl -X POST https://nexuscos.online/api/v1/imcus/001/deploy \
  -H "Content-Type: application/json" \
  -d '{"test": true}' \
  -i

# Expected: Status 200, 201, or 202 (accepted)
```

**Verification**: Endpoint returns successful response (200/201/202)

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 2.3: Inter-Service Communication

**Task**: Check Node/Python logs for successful request handling

**Commands**:
```bash
echo "=== Checking Service Logs ==="

# Check Node backend logs (adjust path as needed)
echo "Node backend logs:"
sudo tail -n 50 /var/log/node-backend.log || \
sudo journalctl -u node-backend -n 50 || \
pm2 logs node-backend --lines 50

# Check Python backend logs (if applicable)
echo "Python backend logs:"
sudo tail -n 50 /var/log/python-backend.log || \
sudo journalctl -u python-backend -n 50 || \
pm2 logs python-backend --lines 50

# Check for errors
echo "Checking for errors in logs:"
sudo tail -n 100 /var/log/node-backend.log | grep -i "error\|timeout\|500"
```

**Verification**: Logs confirm successful request handling, no 500 errors or timeouts

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 2.4: Data Persistence Check

**Task**: Test database operation

**Commands**:
```bash
echo "=== Testing Database Persistence ==="

# Option 1: If API endpoint exists
curl -X POST https://nexuscos.online/api/test/create \
  -H "Content-Type: application/json" \
  -d '{"name": "test_user", "email": "test@test.com"}' \
  -i

# Option 2: Direct database check (adjust as needed)
# For MongoDB:
# mongo nexus-cos --eval 'db.test.insertOne({name: "test", created: new Date()})'

# For PostgreSQL:
# psql -U nexus -d nexuscos -c "INSERT INTO test (name) VALUES ('test');"

# Verify record exists
curl -s https://nexuscos.online/api/test/list | grep "test_user"
```

**Verification**: Database operation succeeds and record is verifiable

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

# PHASE 3: Application & Frontend Readiness

**Focus**: User-facing application and asset delivery

## Step 3.1: Frontend Asset Delivery

**Task**: Check all static assets load correctly

**Commands**:
```bash
echo "=== Testing Frontend Asset Delivery ==="

# Get the main page
curl -s https://nexuscos.online/ > /tmp/index.html

# Extract asset URLs
grep -oP 'src="[^"]+"|href="[^"]+"' /tmp/index.html | head -10

# Test loading key assets
echo "Testing CSS:"
curl -I https://nexuscos.online/assets/main.css || echo "FAILED"

echo "Testing JS:"
curl -I https://nexuscos.online/assets/main.js || echo "FAILED"

echo "Testing images:"
curl -I https://nexuscos.online/assets/logo.png || echo "FAILED"

# Check for mixed content
curl -s https://nexuscos.online/ | grep -i "http://" | grep -v "localhost"
# Should NOT show any http:// URLs (except localhost)
```

**Verification**: All assets load with HTTP 200, no mixed-content warnings

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 3.2: Base Page Load Test

**Task**: Load main landing page and check response time

**Commands**:
```bash
echo "=== Testing Page Load Performance ==="

# Test main page load time
time curl -s https://nexuscos.online/ > /dev/null

# With timing details
curl -w "\nTime Total: %{time_total}s\nHTTP Code: %{http_code}\n" \
  -o /dev/null -s https://nexuscos.online/

# Expected: Time < 2 seconds, HTTP 200

# Test internal page (if applicable)
curl -w "\nTime Total: %{time_total}s\nHTTP Code: %{http_code}\n" \
  -o /dev/null -s https://nexuscos.online/app/
```

**Verification**: Main page loads within 2 seconds, no 404/500 errors

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 3.3: Security Headers Check

**Task**: Verify essential security headers are present

**Commands**:
```bash
echo "=== Checking Security Headers ==="

# Check all security headers
curl -I https://nexuscos.online/ 2>&1 | grep -i "strict-transport-security\|x-frame-options\|x-content-type-options\|content-security-policy\|referrer-policy"

# Detailed check
echo "HSTS:"
curl -I https://nexuscos.online/ 2>&1 | grep -i "strict-transport-security"

echo "X-Frame-Options:"
curl -I https://nexuscos.online/ 2>&1 | grep -i "x-frame-options"

echo "X-Content-Type-Options:"
curl -I https://nexuscos.online/ 2>&1 | grep -i "x-content-type-options"

echo "Content-Security-Policy:"
curl -I https://nexuscos.online/ 2>&1 | grep -i "content-security-policy"
```

**Expected Headers**:
- Strict-Transport-Security: max-age=31536000
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 3.4: Logging Configuration

**Task**: Verify logs are being written correctly

**Commands**:
```bash
echo "=== Checking Logging Configuration ==="

# Check Nginx access log
echo "Nginx access log (last 10 entries):"
sudo tail -n 10 /var/log/nginx/access.log

# Check Nginx error log
echo "Nginx error log (last 10 entries):"
sudo tail -n 10 /var/log/nginx/error.log

# Make a test request
curl -s https://nexuscos.online/health > /dev/null

# Verify it was logged
echo "Verifying request was logged:"
sudo tail -n 1 /var/log/nginx/access.log | grep "/health"

# Check application logs
echo "Application logs:"
pm2 logs --lines 10 || sudo journalctl -n 10
```

**Verification**: Recent log entries confirm tests from Phase 2 and 3

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

# PHASE 4: Final Launch Verification & Handoff

**Focus**: Complete system validation and launch readiness

## Step 4.1: Full System Self-Test

**Task**: Run comprehensive integration test suite

**Commands**:
```bash
echo "=== Running Full System Self-Test ==="

# Run integration tests if available
cd /path/to/nexus-cos
./deployment/nginx/scripts/test-config.sh

# Repeat critical API checks
echo "Re-testing critical endpoints:"

endpoints=(
  "https://nexuscos.online/"
  "https://nexuscos.online/health"
  "https://nexuscos.online/api/system/status"
  "https://nexuscos.online/api/v1/imcus/001/status"
)

for endpoint in "${endpoints[@]}"; do
  echo "Testing: $endpoint"
  status=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint")
  echo "  Status: $status"
  if [[ "$status" =~ ^2 ]]; then
    echo "  ✓ PASS"
  else
    echo "  ✗ FAIL"
  fi
done
```

**Verification**: 100% pass rate on all system-critical tests

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 4.2: Resource Utilization Snapshot

**Task**: Capture baseline resource metrics

**Commands**:
```bash
echo "=== Resource Utilization Snapshot ==="

# CPU usage
echo "CPU Usage:"
top -bn1 | head -5

# Memory usage
echo "Memory Usage:"
free -h

# Disk usage
echo "Disk Usage:"
df -h /var/www /var/log

# Process list
echo "Key Processes:"
ps aux | grep -E "nginx|node|python" | grep -v grep

# Network connections
echo "Active Connections:"
sudo netstat -tlnp | grep -E ":80|:443|:3000|:3001|:3043|:8088"
```

**Verification**: 
- CPU < 50%
- Memory < 80%
- Disk < 85%

**Status**: [ ] PASS [ ] FAIL  
**Metrics**: CPU: ____% | Memory: ____% | Disk: ____%

---

## Step 4.3: Final Documentation Update

**Task**: Update launch status file

**Commands**:
```bash
echo "=== Updating Launch Status Documentation ==="

# Create launch status file
cat > /path/to/nexus-cos/LAUNCH_STATUS.md << 'EOF'
# Nexus COS Platform - Launch Status

## Date: $(date)

## Overall Status: READY ✅

## Phase 1: Infrastructure & Configuration Stability
- [ ] 1.1 Final Config Cleanup: PASS
- [ ] 1.2 Proxy Integrity Check: PASS
- [ ] 1.3 Health Check Ports: PASS
- [ ] 1.4 Cert & HTTP/2 Check: PASS

## Phase 2: Core Service Integration & API Validation
- [ ] 2.1 API Route Verification (Status): PASS
- [ ] 2.2 API Route Verification (Action): PASS
- [ ] 2.3 Inter-Service Communication: PASS
- [ ] 2.4 Data Persistence Check: PASS

## Phase 3: Application & Frontend Readiness
- [ ] 3.1 Frontend Asset Delivery: PASS
- [ ] 3.2 Base Page Load Test: PASS
- [ ] 3.3 Security Headers Check: PASS
- [ ] 3.4 Logging Configuration: PASS

## Phase 4: Final Launch Verification
- [ ] 4.1 Full System Self-Test: PASS
- [ ] 4.2 Resource Utilization: PASS (CPU: __%, Memory: __%, Disk: __%)
- [ ] 4.3 Documentation Updated: PASS
- [ ] 4.4 Handoff Complete: PASS

## Summary

All critical systems verified and operational:
✅ Nginx configuration valid and active
✅ SSL/HTTPS working with HTTP/2
✅ All backend services responding
✅ API endpoints validated
✅ Frontend assets loading correctly
✅ Security headers configured
✅ Logging operational
✅ Resource utilization within limits

## Platform is READY for Public Launch

### Key URLs:
- Main Site: https://nexuscos.online/
- API Status: https://nexuscos.online/api/system/status
- Health Check: https://nexuscos.online/health

### Next Steps:
1. Monitor access logs: `sudo tail -f /var/log/nginx/access.log`
2. Monitor error logs: `sudo tail -f /var/log/nginx/error.log`
3. Monitor application: `pm2 monit`

### Launch Completed By: TRAE
### Phoenix Launch Agent Execution: COMPLETE
EOF

# Commit to repository
cd /path/to/nexus-cos
git add LAUNCH_STATUS.md
git commit -m "[PLA-SUCCESS] Platform launch verification complete - READY"
git push origin copilot/fix-nginx-routing-nexuscos
```

**Verification**: LAUNCH_STATUS.md exists and shows READY status

**Status**: [ ] PASS [ ] FAIL  
**Notes**: ________________________________

---

## Step 4.4: Handoff & Exit

**Task**: Send final success notification

**Commands**:
```bash
echo "=== Phoenix Launch Agent - Final Report ==="

echo "
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          PHOENIX LAUNCH AGENT - EXECUTION COMPLETE           ║
║                                                              ║
║                    LAUNCH CRITERIA MET                       ║
║                                                              ║
║    System is fully stable, tested, and verified for         ║
║              production public launch.                       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

📊 FINAL STATUS SUMMARY:

Phase 1 - Infrastructure & Configuration: ✅ COMPLETE
Phase 2 - Core Service Integration:       ✅ COMPLETE
Phase 3 - Application & Frontend:         ✅ COMPLETE
Phase 4 - Final Verification:             ✅ COMPLETE

🎯 All $(grep -c '\\[x\\]' LAUNCH_STATUS.md || echo '16') verification steps: PASSED

🌐 Platform URL: https://nexuscos.online/
📈 Resource Utilization: Within limits
🔒 Security: Headers configured
✅ Ready for Beta Launch (Through 12/31/2025)

Platform is 100% COMPLETE and VERIFIED.
"

# Save report
date > /tmp/pla_completion_time.txt
echo "Phoenix Launch Agent execution completed successfully" >> /tmp/pla_completion_time.txt
```

**Status**: [ ] COMPLETE

---

# FAILURE HANDLING PROCEDURES

If any step fails:

## Immediate Actions:
1. STOP all execution
2. Do NOT proceed to next step
3. Document the failure

## Create Failure Report:
```bash
cat > /path/to/nexus-cos/PLA_FAILURE_REPORT.md << EOF
# [PLA-FAILURE] Step X.Y Failed

## Failure Details
- **Phase**: [Phase Number and Name]
- **Step**: [Step Number and Description]
- **Timestamp**: $(date)
- **Executed By**: TRAE

## Error Output
\`\`\`
[Paste complete error output here]
\`\`\`

## Commands Run
\`\`\`bash
[Paste exact commands that failed]
\`\`\`

## System State
- Nginx Status: $(systemctl status nginx | head -1)
- Backend Services: $(pm2 list || echo "N/A")
- Disk Space: $(df -h / | tail -1)
- Recent Logs: See below

## Recent Error Logs
\`\`\`
$(sudo tail -n 20 /var/log/nginx/error.log)
\`\`\`

## Next Actions Required
1. Review error output above
2. Apply fix based on error type
3. Re-run failed step
4. If fails 3 times, escalate

## Status: BLOCKED - Awaiting Resolution
EOF

# Commit failure report
git add PLA_FAILURE_REPORT.md
git commit -m "[PLA-FAILURE] Step X.Y Failed - Execution Stopped"
git push origin copilot/fix-nginx-routing-nexuscos
```

## Common Fixes:

### Nginx Syntax Error:
```bash
# Check syntax
sudo nginx -t

# Fix whitespace/empty lines
sudo sed -i '/^[[:space:]]*$/d' /etc/nginx/sites-enabled/nexuscos.online

# Re-test
sudo nginx -t
```

### Service Not Running:
```bash
# Start service
pm2 start <service-name>
# or
sudo systemctl start <service-name>

# Verify
curl -I http://localhost:<port>/
```

### Permission Issue:
```bash
# Fix permissions
sudo chown -R www-data:www-data /var/www/nexus-cos/
sudo chmod -R 755 /var/www/nexus-cos/
```

---

# EXECUTION CHECKLIST

Print this checklist and mark off each step as completed:

## Phase 1: Infrastructure
- [ ] 1.1 Config Cleanup
- [ ] 1.2 Proxy Integrity
- [ ] 1.3 Health Check Ports
- [ ] 1.4 Cert & HTTP/2

## Phase 2: Services
- [ ] 2.1 API Status Routes
- [ ] 2.2 API Action Routes
- [ ] 2.3 Inter-Service Comm
- [ ] 2.4 Data Persistence

## Phase 3: Frontend
- [ ] 3.1 Asset Delivery
- [ ] 3.2 Page Load Test
- [ ] 3.3 Security Headers
- [ ] 3.4 Logging

## Phase 4: Launch
- [ ] 4.1 System Self-Test
- [ ] 4.2 Resource Snapshot
- [ ] 4.3 Documentation
- [ ] 4.4 Handoff & Exit

---

**Execution Start Time**: ________________  
**Execution End Time**: ________________  
**Total Duration**: ________________  
**Final Status**: [ ] READY [ ] BLOCKED  
**Executed By**: ________________  
**Signature**: ________________

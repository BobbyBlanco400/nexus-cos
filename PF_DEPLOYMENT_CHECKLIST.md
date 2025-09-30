# PUABO / Nexus COS - Pre-Flight Deployment Checklist

**Date:** _____________  
**Deployed By:** _____________  
**Environment:** [ ] Development [ ] Staging [ ] Production

---

## Pre-Deployment Checklist

### Configuration Validation
- [ ] Run `./validate-pf.sh` - All checks passed
- [ ] Review `.env.pf` - Environment variables correct
- [ ] Review `docker-compose.pf.yml` - Service configuration correct
- [ ] Docker installed and running
- [ ] Docker Compose installed

### Security Review (Production Only)
- [ ] Database password changed from default
- [ ] OAuth credentials updated with real values
- [ ] JWT secret updated
- [ ] SSL/TLS certificates configured (if applicable)
- [ ] Firewall rules configured
- [ ] Access controls reviewed

### Prerequisites
- [ ] Docker version: _______________
- [ ] Docker Compose version: _______________
- [ ] Available disk space: _______________
- [ ] Ports available: 4000, 3002, 3041, 5432, 6379

---

## Deployment Steps

### Step 1: Initial Validation
- [ ] Validate configuration: `./validate-pf.sh`
- [ ] Review validation results
- [ ] Fix any issues before proceeding

### Step 2: Service Deployment
- [ ] Run deployment script: `./deploy-pf.sh`
- [ ] Wait for all containers to start
- [ ] Verify no errors in startup

### Step 3: Database Setup
- [ ] PostgreSQL container running
- [ ] Database `nexus_db` created
- [ ] User `nexus_user` created
- [ ] Migrations applied automatically
- [ ] Tables created: users, sessions, api_keys, audit_log

### Step 4: Service Verification
- [ ] Test puabo-api: `curl http://localhost:4000/health`
  - Response: `{"status":"ok"}`
- [ ] Test puaboai-sdk: `curl http://localhost:3002/health`
  - Response: `{"status":"ok",...}`
- [ ] Test pv-keys: `curl http://localhost:3041/health`
  - Response: `{"status":"ok",...}`

### Step 5: Database Verification
- [ ] Connect to database: `docker compose -f docker-compose.pf.yml exec nexus-cos-postgres psql -U nexus_user -d nexus_db`
- [ ] Verify tables exist: `\dt`
- [ ] Check users table: `SELECT COUNT(*) FROM users;`
- [ ] Verify admin user exists

### Step 6: Container Health
- [ ] All containers running: `docker compose -f docker-compose.pf.yml ps`
- [ ] No containers in "Restarting" state
- [ ] All health checks passing
- [ ] No error logs

---

## Service Status (Fill in after deployment)

### puabo-api
- [ ] Container Status: _______________
- [ ] Health Check: _______________
- [ ] Response Time: _______________
- [ ] Logs Clean: Yes / No
- [ ] Notes: _______________

### nexus-cos-postgres
- [ ] Container Status: _______________
- [ ] Health Check: _______________
- [ ] Database Created: Yes / No
- [ ] Tables Created: Yes / No
- [ ] Notes: _______________

### nexus-cos-redis
- [ ] Container Status: _______________
- [ ] Connection: _______________
- [ ] Notes: _______________

### nexus-cos-puaboai-sdk
- [ ] Container Status: _______________
- [ ] Health Check: _______________
- [ ] Response Time: _______________
- [ ] Notes: _______________

### nexus-cos-pv-keys
- [ ] Container Status: _______________
- [ ] Health Check: _______________
- [ ] Response Time: _______________
- [ ] Notes: _______________

---

## Post-Deployment Verification

### Functional Testing
- [ ] API endpoints responding
- [ ] Database connections working
- [ ] Authentication endpoints functional
- [ ] Health checks passing
- [ ] Inter-service communication working

### Performance
- [ ] Response times acceptable
- [ ] CPU usage normal
- [ ] Memory usage normal
- [ ] Disk usage normal
- [ ] Network connectivity good

### Monitoring Setup
- [ ] Log aggregation configured
- [ ] Health check monitoring enabled
- [ ] Alert thresholds set
- [ ] Dashboard configured (if applicable)

### Documentation
- [ ] Deployment documented
- [ ] Configuration changes noted
- [ ] Access credentials securely stored
- [ ] Team notified of deployment

---

## Rollback Plan (Complete before deployment)

### Rollback Triggers
- [ ] Critical service failure
- [ ] Database corruption
- [ ] Security incident
- [ ] Performance degradation
- [ ] Other: _______________

### Rollback Steps
1. [ ] Stop services: `docker compose -f docker-compose.pf.yml down`
2. [ ] Restore previous configuration
3. [ ] Restart previous version
4. [ ] Verify rollback successful
5. [ ] Document incident

### Backup Verification
- [ ] Database backup available
- [ ] Configuration backup available
- [ ] Backup tested and verified
- [ ] Restore procedure documented

---

## Comparison with PF Requirements

### Services (as per PF document)
- [ ] puabo-api running on port 4000
- [ ] nexus-cos-postgres running on port 5432
- [ ] nexus-cos-puaboai-sdk ready to start
- [ ] nexus-cos-pv-keys ready to start
- [ ] Redis running on port 6379

### Database (as per PF document)
- [ ] Database: nexus_db
- [ ] User: nexus_user
- [ ] Users table exists
- [ ] Password configured: Momoney2025$

### Migrations (as per PF document)
- [ ] apply-migrations.sh executed successfully
- [ ] schema.sql applied
- [ ] Tables created

### Environment Variables (as per PF document)
- [ ] DB_PORT=5432
- [ ] DB_NAME=nexus_db
- [ ] DB_USER=nexus_user
- [ ] DB_PASSWORD=Momoney2025$
- [ ] REDIS_PORT=6379
- [ ] REDIS_HOST=127.0.0.1 (or nexus-cos-redis)
- [ ] PORT=4000
- [ ] NODE_ENV=production
- [ ] OAUTH_CLIENT_ID=your-client-id
- [ ] OAUTH_CLIENT_SECRET=your-client-secret

---

## Issues Encountered

### Issue 1
- **Description:** _______________
- **Resolution:** _______________
- **Time to Resolve:** _______________

### Issue 2
- **Description:** _______________
- **Resolution:** _______________
- **Time to Resolve:** _______________

### Issue 3
- **Description:** _______________
- **Resolution:** _______________
- **Time to Resolve:** _______________

---

## Sign-Off

### Deployment Team
- [ ] Deployed By: _______________ Date: _______________ Time: _______________
- [ ] Verified By: _______________ Date: _______________ Time: _______________
- [ ] Approved By: _______________ Date: _______________ Time: _______________

### Status
- [ ] Deployment Successful
- [ ] Deployment Failed (see issues above)
- [ ] Deployment Rolled Back

### Notes
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________
_______________________________________________________________________________

---

## Next Steps

### Immediate (After Deployment)
- [ ] Monitor logs for 30 minutes
- [ ] Run smoke tests
- [ ] Update documentation
- [ ] Notify stakeholders

### Short Term (Within 24 hours)
- [ ] Full functional testing
- [ ] Performance testing
- [ ] Security scan
- [ ] Update monitoring dashboards

### Long Term (Within 1 week)
- [ ] Review and optimize configuration
- [ ] Document lessons learned
- [ ] Update runbooks
- [ ] Schedule regular health checks

---

**Checklist Version:** 1.0  
**Last Updated:** 2025-09-30  
**Status:** Ready for Use

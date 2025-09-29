# TRAE Solo Recovery Instructions for Nexus COS

## 1. Preparation

- Ensure you have SSH/root access to the target VPS.
- Confirm that all recovery scripts and documentation files exist in the working directory:
    - `master-fix-trae-solo.sh`
    - `vps-recovery-trae-solo.sh`
    - `ssl-recovery-trae-solo.sh`
    - `service-restoration-trae-solo.sh`
    - `TRAE_SOLO_RECOVERY_STATUS.md`
    - `QUICK_DEPLOYMENT_GUIDE.md`

## 2. Execute Recovery

### Step 1: Master Recovery Orchestration

- Run the master recovery script to orchestrate all phases:
  ```bash
  bash master-fix-trae-solo.sh
  ```

- The script will sequentially execute the following:
    - VPS connectivity recovery
    - SSL certificate restoration
    - Service restoration (PM2 ecosystem)
    - Monitoring stack setup (Prometheus + Grafana)

### Step 2: Phase Verification

- As each phase completes:
    - Check output logs for errors or warnings.
    - Ensure status updates are reflected in `TRAE_SOLO_RECOVERY_STATUS.md`.

## 3. Post-Recovery Testing

### Step 1: VPS Connectivity

- Confirm network connectivity to the VPS.
- Ensure all required ports are open.

### Step 2: SSL Certificate & CloudFlare

- Access your production and beta domains using HTTPS.
- Verify SSL certificates are valid and secure.
- Confirm CloudFlare integration is active.

### Step 3: Service Restoration

- Check PM2 dashboard for all services running.
- Restart any failed services using:
  ```bash
  pm2 restart <service-name>
  ```

- Verify service logs and resource usage.

### Step 4: Monitoring

- Access Prometheus and Grafana dashboards.
- Confirm metrics for all core services are being reported.
- Check health alerts and dashboards for anomalies.

## 4. Documentation & Reporting

- Update `TRAE_SOLO_RECOVERY_STATUS.md` with the outcome of each recovery phase.
- Follow steps in `QUICK_DEPLOYMENT_GUIDE.md` for reference and troubleshooting.
- Note any manual overrides or deviations.

## 5. Optional: Automated Testing

- If provided, execute automated test scripts for:
    - Network health
    - SSL certificate validity
    - PM2 service status
    - Monitoring endpoints

## 6. Escalation

- If any step fails:
    - Review output logs and error messages.
    - Consult `QUICK_DEPLOYMENT_GUIDE.md` troubleshooting section.
    - Document issue in `TRAE_SOLO_RECOVERY_STATUS.md`.
    - Escalate to engineering lead if unable to resolve.

---

**End of Instructions**

# Backend Logs Fix - SSH Command Correction

## Problem
The original SSH command was incorrect:
```bash
ssh root@74.208.155.161 'pm2 logs boomroom-backend --lines 20'
```

## Issues with the Original Command
1. **Wrong IP Address**: Should be `75.208.155.161` (based on deployment scripts)
2. **Wrong Service Name**: `boomroom-backend` doesn't exist, should be `nexus-backend-node` or `nexus-backend-python`
3. **Wrong Process Manager**: System uses systemd services, not PM2

## Corrected Commands

### Node.js Backend Logs
```bash
ssh root@75.208.155.161 'journalctl -u nexus-backend-node -n 20 --no-pager'
```

### Python Backend Logs
```bash
ssh root@75.208.155.161 'journalctl -u nexus-backend-python -n 20 --no-pager'
```

### Using the Helper Script
```bash
# Check both backends
./check-backend-logs.sh

# Check only Node.js backend
./check-backend-logs.sh --node

# Check only Python backend
./check-backend-logs.sh --python

# Use different number of lines
./check-backend-logs.sh --lines 50

# Use original IP if needed
./check-backend-logs.sh --server 74.208.155.161
```

## Service Names
Based on the deployment scripts in this repository:
- **Node.js Backend**: `nexus-backend-node` (runs on port 3000)
- **Python Backend**: `nexus-backend-python` (runs on port 3001)

## Additional Useful Commands

### Check Service Status
```bash
ssh root@75.208.155.161 'systemctl status nexus-backend-node'
ssh root@75.208.155.161 'systemctl status nexus-backend-python'
```

### Restart Services
```bash
ssh root@75.208.155.161 'systemctl restart nexus-backend-node'
ssh root@75.208.155.161 'systemctl restart nexus-backend-python'
```

### Follow Logs in Real-time
```bash
ssh root@75.208.155.161 'journalctl -u nexus-backend-node -f'
ssh root@75.208.155.161 'journalctl -u nexus-backend-python -f'
```

## Files Created/Modified
- `check-backend-logs.sh` - Helper script for checking backend logs
- `BACKEND_LOGS_FIX.md` - This documentation file
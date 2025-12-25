# N.E.X.U.S AI - Control & Verification Layer

**Master Control System for Casino-Nexus Ecosystem**

## Overview

N.E.X.U.S AI provides:
- **Automated Verification** - Blocks bad deploys before they happen
- **Real-time Control Panel** - Centralized command & governance
- **Emergency Controls** - Founder-only kill switches
- **Compliance Enforcement** - Built-in regulatory safeguards

## Quick Start

### One-Liner Deploy

From repository root:

```bash
./nexus-deploy.sh
```

This command:
1. Runs ALL verification checks
2. Blocks deployment if ANY check fails
3. Launches the N.E.X.U.S AI Control Panel on success

### Alternative: Manual Execution

```bash
# Run verifications only
./nexus-ai/verify/run-all.sh

# Launch control panel only
cd nexus-ai/control-panel
npm install
npm start
```

## Architecture

### Verification Layer (`/verify`)

Automated verification scripts that validate:
- ✅ **Handshake 55-45-17** - Core protocol compliance
- ✅ **Casino Grid** - Multi-casino architecture
- ✅ **NexCoin Enforcement** - Premium feature gating
- ✅ **Federation System** - Multi-operator support
- ✅ **Tenant Isolation** - Secure multi-tenancy

**Scripts:**
- `run-all.sh` - Master verification runner
- `verify-handshake.sh` - Handshake validation
- `verify-casino-grid.sh` - Casino grid check
- `verify-nexcoin.sh` - NexCoin enforcement
- `verify-federation.sh` - Federation architecture
- `verify-tenants.sh` - Tenant isolation

### Control Panel (`/control-panel`)

Real-time command and control system.

**Backend Modules:**
- `index.ts` - Main API server
- `permissions.engine.ts` - Multi-tier access control
- `command.bus.ts` - Command routing & audit log
- `live-state.monitor.ts` - Real-time state tracking
- `casino.control.ts` - Casino management
- `federation.control.ts` - Federation operations
- `emergency.lockdown.ts` - Emergency controls

**UI Components (`/ui`):**
- `ControlPanel.tsx` - Main dashboard
- `WorldMap.tsx` - Casino world map
- `ComplianceStatus.tsx` - Compliance dashboard
- `NexCoinLedger.tsx` - Treasury & metrics
- `KillSwitch.tsx` - Emergency interface

## Control Panel Features

### Permission Tiers

1. **FOUNDER** - Full access including emergency controls
2. **ADMIN** - Casino & federation management
3. **OPERATOR** - Casino operations only
4. **VIEWER** - Read-only access

### API Endpoints

**System State:**
```
GET  /health                    - Health check
GET  /api/state/system          - System state
GET  /api/state/casinos         - All casino states
GET  /api/state/federations     - Federation states
GET  /api/state/treasury        - NexCoin treasury
GET  /api/state/metrics         - Aggregated metrics
```

**Casino Control:**
```
POST /api/casino/:id/start      - Start casino
POST /api/casino/:id/stop       - Stop casino
POST /api/casino/:id/restart    - Restart casino
```

**Emergency Controls (Founder-only):**
```
POST /api/emergency/lockdown    - Lock all casinos
POST /api/emergency/freeze-wallets - Freeze all wallets
POST /api/emergency/lift        - Lift lockdown
GET  /api/emergency/status      - Lockdown status
```

### Authentication

Control panel uses header-based authentication:

```
X-User-Id: <user_id>
X-User-Tier: founder|admin|operator|viewer
```

In production, integrate with JWT or OAuth.

## Emergency Procedures

### Full Lockdown

1. Access Control Panel
2. Enter Founder Authorization Code
3. Specify reason
4. Click "LOCKDOWN ALL WORLDS"

**Effect:**
- All casinos immediately offline
- No new bets accepted
- Active games complete
- Players safely disconnected

### Wallet Freeze

1. Access Control Panel
2. Enter Founder Authorization Code
3. Click "FREEZE ALL WALLETS"

**Effect:**
- All wallet operations halted
- No withdrawals or deposits
- Read access maintained
- Casino operations continue

### Lifting Lockdown

1. Access Control Panel
2. Enter Founder Authorization Code
3. Click "LIFT LOCKDOWN"

**Effect:**
- Systems return to normal
- Casinos can be restarted
- Wallets unfrozen

## Verification Reports

All verification runs generate JSON reports:

```bash
cat nexus-ai/verify/verify-report.json
```

Example:
```json
{
  "timestamp": "2025-12-25T06:00:00Z",
  "summary": {
    "passed": 5,
    "failed": 0,
    "total": 5
  },
  "status": "PASSED",
  "verifications": {
    "handshake": "executed",
    "casino_grid": "executed",
    "nexcoin": "executed",
    "federation": "executed",
    "tenants": "executed"
  }
}
```

## Integration

### With CI/CD

Add to deployment pipeline:

```yaml
# .github/workflows/deploy.yml
- name: Run N.E.X.U.S Verifications
  run: ./nexus-ai/verify/run-all.sh

- name: Deploy if verified
  if: success()
  run: # your deploy commands
```

### With Existing Services

Control panel runs independently on port 9000 (configurable):

```bash
export CONTROL_PANEL_PORT=9000
./nexus-deploy.sh
```

## Compliance & Security

### What N.E.X.U.S Enforces

1. **NexCoin Requirement** - All premium features require NexCoin
2. **Handshake Protocol** - 55-45-17 ratio enforced
3. **Casino Grid** - 9-slot minimum architecture
4. **Federation Revenue** - Automated revenue splits
5. **Tenant Isolation** - Secure multi-tenancy

### Audit Trail

All control commands are logged:

```typescript
// View command history
GET /api/commands/history
```

Each command includes:
- Command ID
- User ID
- Timestamp
- Action taken
- Result

## Development

### Running in Dev Mode

```bash
cd nexus-ai/control-panel
npm install
npm run dev
```

### Building for Production

```bash
cd nexus-ai/control-panel
npm run build
node dist/index.js
```

### Testing Verifications

```bash
# Run individual verification
./nexus-ai/verify/verify-nexcoin.sh

# Run all verifications
./nexus-ai/verify/run-all.sh
```

## Troubleshooting

### Verification Failures

If verifications fail:
1. Check the specific failed verification
2. Review `verify-report.json` for details
3. Fix the underlying issue
4. Re-run verifications

### Control Panel Won't Start

```bash
# Check Node.js version (requires 18+)
node --version

# Install dependencies
cd nexus-ai/control-panel
npm install

# Check for port conflicts
lsof -i :9000
```

### Permission Errors

Ensure scripts are executable:
```bash
chmod +x nexus-ai/verify/*.sh
chmod +x nexus-deploy.sh
```

## Support

For issues or questions:
- Review verification logs
- Check command history in control panel
- Contact: PUABO Holdings

---

**N.E.X.U.S AI** - *Governed by code, not trust.*

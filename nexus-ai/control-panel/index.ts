/**
 * N.E.X.U.S AI Control Panel - Main Entry Point
 * 
 * Central command and control system for Casino-Nexus ecosystem
 * 
 * @module control-panel/index
 */

import express, { Request, Response } from 'express';
import permissionEngine, { PermissionTier } from './permissions.engine';
import commandBus from './command.bus';
import liveStateMonitor from './live-state.monitor';
import casinoControl from './casino.control';
import federationControl from './federation.control';
import emergencyLockdown from './emergency.lockdown';

const app = express();
const PORT = process.env.CONTROL_PANEL_PORT || 9000;

// Middleware
app.use(express.json());

// Simple authentication middleware (placeholder)
const authenticate = (req: Request, res: Response, next: Function) => {
  // In production, verify JWT or session
  const userId = req.headers['x-user-id'] as string || 'anonymous';
  const userTier = req.headers['x-user-tier'] as PermissionTier || PermissionTier.VIEWER;
  
  (req as any).userId = userId;
  (req as any).userTier = userTier;
  
  next();
};

app.use(authenticate);

// Health check
app.get('/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'LIVE',
    handshake: '55-45-17',
    version: '1.0.0'
  });
});

// System state endpoints
app.get('/api/state/system', (req: Request, res: Response) => {
  const state = liveStateMonitor.getSystemState();
  res.json(state);
});

app.get('/api/state/casinos', (req: Request, res: Response) => {
  const casinos = liveStateMonitor.getCasinoStates();
  res.json(casinos);
});

app.get('/api/state/federations', (req: Request, res: Response) => {
  const federations = liveStateMonitor.getFederationStates();
  res.json(federations);
});

app.get('/api/state/treasury', (req: Request, res: Response) => {
  const treasury = liveStateMonitor.getTreasuryState();
  res.json(treasury);
});

app.get('/api/state/metrics', (req: Request, res: Response) => {
  const metrics = liveStateMonitor.getAggregatedMetrics();
  res.json(metrics);
});

// Casino control endpoints
app.post('/api/casino/:casinoId/start', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'casino.start',
      { casinoId: req.params.casinoId },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

app.post('/api/casino/:casinoId/stop', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'casino.stop',
      { casinoId: req.params.casinoId },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

app.post('/api/casino/:casinoId/restart', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'casino.restart',
      { casinoId: req.params.casinoId },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

// Emergency endpoints
app.post('/api/emergency/lockdown', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'emergency.lockdownAll',
      { 
        founderCode: req.body.founderCode,
        reason: req.body.reason 
      },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

app.post('/api/emergency/freeze-wallets', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'emergency.freezeWallets',
      { 
        founderCode: req.body.founderCode,
        reason: req.body.reason 
      },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

app.post('/api/emergency/lift', async (req: Request, res: Response) => {
  try {
    const result = await commandBus.execute(
      'emergency.liftLockdown',
      { founderCode: req.body.founderCode },
      (req as any).userId,
      (req as any).userTier
    );
    res.json(result);
  } catch (error) {
    res.status(403).json({ error: (error as Error).message });
  }
});

app.get('/api/emergency/status', (req: Request, res: Response) => {
  const status = emergencyLockdown.getLockdownState();
  res.json(status);
});

// Command history
app.get('/api/commands/history', (req: Request, res: Response) => {
  const history = commandBus.getCommandHistory(100);
  res.json(history);
});

// Display ASCII control panel in terminal
const displayControlPanel = () => {
  console.clear();
  console.log('┌───────────────────────────────────────────────────────────────┐');
  console.log('│ N.E.X.U.S AI CONTROL PANEL                                    │');
  console.log('│ Status: ● LIVE   Handshake: 55-45-17 ✔   Risk: LOW            │');
  console.log('└───────────────────────────────────────────────────────────────┘');
  console.log('');
  console.log('🚀 Control Panel running on port', PORT);
  console.log('');
  console.log('📡 API Endpoints:');
  console.log('   GET  /health                    - Health check');
  console.log('   GET  /api/state/system          - System state');
  console.log('   GET  /api/state/casinos         - Casino states');
  console.log('   GET  /api/state/federations     - Federation states');
  console.log('   GET  /api/state/treasury        - NexCoin treasury');
  console.log('   GET  /api/state/metrics         - Aggregated metrics');
  console.log('   POST /api/casino/:id/start      - Start casino');
  console.log('   POST /api/casino/:id/stop       - Stop casino');
  console.log('   POST /api/emergency/lockdown    - Emergency lockdown');
  console.log('   POST /api/emergency/freeze-wallets - Freeze all wallets');
  console.log('');
  console.log('🎮 Active Casinos:');
  const casinos = liveStateMonitor.getCasinoStates();
  casinos.forEach(casino => {
    const statusIcon = casino.status === 'online' ? '●' : '○';
    console.log(`   ${statusIcon} ${casino.name} (${casino.playersOnline} players)`);
  });
  console.log('');
  console.log('🌐 Federations:');
  const federations = liveStateMonitor.getFederationStates();
  federations.forEach(fed => {
    const statusIcon = fed.status === 'active' ? '●' : '○';
    console.log(`   ${statusIcon} ${fed.federationId} - ${fed.name}`);
  });
  console.log('');
  console.log('💰 NexCoin Treasury:');
  const treasury = liveStateMonitor.getTreasuryState();
  console.log(`   Total Supply:    ${treasury.totalSupply.toLocaleString()}`);
  console.log(`   In Circulation:  ${treasury.inCirculation.toLocaleString()}`);
  console.log(`   Locked:          ${treasury.locked.toLocaleString()}`);
  console.log('');
  console.log('🔒 Compliance Status:');
  const system = liveStateMonitor.getSystemState();
  console.log(`   Handshake:       ${system.handshakeValid ? '✔' : '✘'} ${system.handshakeVersion}`);
  console.log(`   NexCoin Only:    ${system.nexcoinEnforced ? '✔' : '✘'} ENFORCED`);
  console.log(`   Casino Grid:     ✔ ${system.casinoGridStatus}`);
  console.log(`   Risk Level:      ${system.riskLevel}`);
  console.log('');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
};

// Start server
const server = app.listen(PORT, () => {
  displayControlPanel();
  
  // Refresh display every 30 seconds
  setInterval(displayControlPanel, 30000);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('Shutting down N.E.X.U.S AI Control Panel...');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});

export default app;

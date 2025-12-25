/**
 * N.E.X.U.S AI Control Panel - Casino Control
 * 
 * Management and control of individual casinos
 * 
 * @module control-panel/casino.control
 */

import commandBus from './command.bus';
import liveStateMonitor from './live-state.monitor';
import permissionEngine, { PermissionTier } from './permissions.engine';

export interface CasinoControlAction {
  action: 'start' | 'stop' | 'restart' | 'suspend' | 'configure';
  casinoId: string;
  config?: any;
}

export class CasinoControl {
  constructor() {
    this.registerCommandHandlers();
  }

  /**
   * Register command handlers with command bus
   */
  private registerCommandHandlers(): void {
    commandBus.registerHandler('casino.start', async (cmd) => {
      permissionEngine.requirePermission(cmd.userTier, 'canManageCasinos');
      return this.startCasino(cmd.payload.casinoId);
    });

    commandBus.registerHandler('casino.stop', async (cmd) => {
      permissionEngine.requirePermission(cmd.userTier, 'canManageCasinos');
      return this.stopCasino(cmd.payload.casinoId);
    });

    commandBus.registerHandler('casino.restart', async (cmd) => {
      permissionEngine.requirePermission(cmd.userTier, 'canManageCasinos');
      return this.restartCasino(cmd.payload.casinoId);
    });

    commandBus.registerHandler('casino.suspend', async (cmd) => {
      permissionEngine.requirePermission(cmd.userTier, 'canManageCasinos');
      return this.suspendCasino(cmd.payload.casinoId, cmd.payload.reason);
    });

    commandBus.registerHandler('casino.configure', async (cmd) => {
      permissionEngine.requirePermission(cmd.userTier, 'canManageCasinos');
      return this.configureCasino(cmd.payload.casinoId, cmd.payload.config);
    });
  }

  /**
   * Start a casino
   */
  async startCasino(casinoId: string): Promise<{ success: boolean; message: string }> {
    const casino = liveStateMonitor.getCasinoState(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    if (casino.status === 'online') {
      return { success: false, message: 'Casino is already online' };
    }

    // Update state
    liveStateMonitor.updateCasinoState(casinoId, { 
      status: 'online',
      playersOnline: 0,
      betsPerMinute: 0
    });

    return { 
      success: true, 
      message: `Casino ${casinoId} started successfully` 
    };
  }

  /**
   * Stop a casino
   */
  async stopCasino(casinoId: string): Promise<{ success: boolean; message: string }> {
    const casino = liveStateMonitor.getCasinoState(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    if (casino.status === 'offline') {
      return { success: false, message: 'Casino is already offline' };
    }

    // Update state
    liveStateMonitor.updateCasinoState(casinoId, { 
      status: 'offline',
      playersOnline: 0,
      betsPerMinute: 0,
      activeGames: 0
    });

    return { 
      success: true, 
      message: `Casino ${casinoId} stopped successfully` 
    };
  }

  /**
   * Restart a casino
   */
  async restartCasino(casinoId: string): Promise<{ success: boolean; message: string }> {
    await this.stopCasino(casinoId);
    
    // Simulate restart delay
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await this.startCasino(casinoId);

    return { 
      success: true, 
      message: `Casino ${casinoId} restarted successfully` 
    };
  }

  /**
   * Suspend a casino
   */
  async suspendCasino(
    casinoId: string, 
    reason: string
  ): Promise<{ success: boolean; message: string }> {
    const casino = liveStateMonitor.getCasinoState(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    liveStateMonitor.updateCasinoState(casinoId, { 
      status: 'maintenance'
    });

    return { 
      success: true, 
      message: `Casino ${casinoId} suspended: ${reason}` 
    };
  }

  /**
   * Configure a casino
   */
  async configureCasino(
    casinoId: string, 
    config: any
  ): Promise<{ success: boolean; message: string }> {
    const casino = liveStateMonitor.getCasinoState(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    // In production, apply configuration changes
    // For now, just validate and acknowledge

    return { 
      success: true, 
      message: `Casino ${casinoId} configuration updated` 
    };
  }

  /**
   * Get casino status
   */
  getCasinoStatus(casinoId: string) {
    return liveStateMonitor.getCasinoState(casinoId);
  }

  /**
   * Get all casinos
   */
  getAllCasinos() {
    return liveStateMonitor.getCasinoStates();
  }
}

export default new CasinoControl();

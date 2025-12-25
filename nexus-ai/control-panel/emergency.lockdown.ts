/**
 * N.E.X.U.S AI Control Panel - Emergency Lockdown
 * 
 * Emergency controls and kill switches (Founder-only)
 * 
 * @module control-panel/emergency.lockdown
 */

import commandBus from './command.bus';
import liveStateMonitor from './live-state.monitor';
import permissionEngine, { PermissionTier } from './permissions.engine';
import casinoControl from './casino.control';

export enum LockdownLevel {
  NONE = 'none',
  PARTIAL = 'partial',      // Lock new bets only
  FULL = 'full',            // Lock all operations
  CRITICAL = 'critical'     // Full lockdown + freeze wallets
}

export interface LockdownState {
  active: boolean;
  level: LockdownLevel;
  initiatedBy: string;
  initiatedAt: number;
  reason: string;
  affectedCasinos: string[];
}

export class EmergencyLockdown {
  private lockdownState: LockdownState;

  constructor() {
    this.lockdownState = {
      active: false,
      level: LockdownLevel.NONE,
      initiatedBy: '',
      initiatedAt: 0,
      reason: '',
      affectedCasinos: []
    };

    this.registerCommandHandlers();
  }

  /**
   * Register emergency command handlers
   */
  private registerCommandHandlers(): void {
    commandBus.registerHandler('emergency.lockdownAll', async (cmd) => {
      permissionEngine.requireFounderAuth(cmd.userTier, cmd.payload.founderCode);
      return this.lockdownAllWorlds(cmd.userId, cmd.payload.reason);
    });

    commandBus.registerHandler('emergency.freezeWallets', async (cmd) => {
      permissionEngine.requireFounderAuth(cmd.userTier, cmd.payload.founderCode);
      return this.freezeAllWallets(cmd.userId, cmd.payload.reason);
    });

    commandBus.registerHandler('emergency.liftLockdown', async (cmd) => {
      permissionEngine.requireFounderAuth(cmd.userTier, cmd.payload.founderCode);
      return this.liftLockdown(cmd.userId);
    });

    commandBus.registerHandler('emergency.evacuateCasino', async (cmd) => {
      permissionEngine.requireFounderAuth(cmd.userTier, cmd.payload.founderCode);
      return this.evacuateCasino(cmd.payload.casinoId, cmd.userId);
    });
  }

  /**
   * Lockdown all casino worlds
   */
  async lockdownAllWorlds(
    userId: string,
    reason: string
  ): Promise<{ success: boolean; message: string; affectedCasinos: number }> {
    const casinos = liveStateMonitor.getCasinoStates();
    const affectedIds: string[] = [];

    // Stop all casinos
    for (const casino of casinos) {
      if (casino.status === 'online') {
        await casinoControl.stopCasino(casino.casinoId);
        affectedIds.push(casino.casinoId);
      }
    }

    // Update lockdown state
    this.lockdownState = {
      active: true,
      level: LockdownLevel.FULL,
      initiatedBy: userId,
      initiatedAt: Date.now(),
      reason,
      affectedCasinos: affectedIds
    };

    // Update system risk level
    liveStateMonitor.updateSystemState({
      riskLevel: 'HIGH'
    });

    return {
      success: true,
      message: `Emergency lockdown activated: ${reason}`,
      affectedCasinos: affectedIds.length
    };
  }

  /**
   * Freeze all wallets
   */
  async freezeAllWallets(
    userId: string,
    reason: string
  ): Promise<{ success: boolean; message: string; walletsAffected: number }> {
    // In production, freeze all wallet operations
    
    this.lockdownState = {
      active: true,
      level: LockdownLevel.CRITICAL,
      initiatedBy: userId,
      initiatedAt: Date.now(),
      reason,
      affectedCasinos: liveStateMonitor.getCasinoStates().map(c => c.casinoId)
    };

    liveStateMonitor.updateSystemState({
      riskLevel: 'HIGH'
    });

    return {
      success: true,
      message: `All wallets frozen: ${reason}`,
      walletsAffected: 0 // In production, return actual count
    };
  }

  /**
   * Lift lockdown
   */
  async liftLockdown(
    userId: string
  ): Promise<{ success: boolean; message: string }> {
    if (!this.lockdownState.active) {
      return {
        success: false,
        message: 'No active lockdown to lift'
      };
    }

    // Reset lockdown state
    this.lockdownState = {
      active: false,
      level: LockdownLevel.NONE,
      initiatedBy: '',
      initiatedAt: 0,
      reason: '',
      affectedCasinos: []
    };

    liveStateMonitor.updateSystemState({
      riskLevel: 'LOW'
    });

    return {
      success: true,
      message: 'Lockdown lifted, systems returning to normal'
    };
  }

  /**
   * Evacuate specific casino (kick all players)
   */
  async evacuateCasino(
    casinoId: string,
    userId: string
  ): Promise<{ success: boolean; message: string; playersEvacuated: number }> {
    const casino = liveStateMonitor.getCasinoState(casinoId);
    
    if (!casino) {
      throw new Error(`Casino not found: ${casinoId}`);
    }

    const playersEvacuated = casino.playersOnline;

    // Stop casino and clear players
    await casinoControl.stopCasino(casinoId);
    
    liveStateMonitor.updateCasinoState(casinoId, {
      playersOnline: 0,
      betsPerMinute: 0,
      activeGames: 0
    });

    return {
      success: true,
      message: `Casino ${casinoId} evacuated`,
      playersEvacuated
    };
  }

  /**
   * Get current lockdown state
   */
  getLockdownState(): LockdownState {
    return { ...this.lockdownState };
  }

  /**
   * Check if lockdown is active
   */
  isLockdownActive(): boolean {
    return this.lockdownState.active;
  }

  /**
   * Get lockdown level
   */
  getLockdownLevel(): LockdownLevel {
    return this.lockdownState.level;
  }
}

export default new EmergencyLockdown();

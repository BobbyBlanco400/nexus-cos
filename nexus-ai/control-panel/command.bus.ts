/**
 * N.E.X.U.S AI Control Panel - Command Bus
 * 
 * Central command routing and execution system for control panel actions
 * 
 * @module control-panel/command.bus
 */

import permissionEngine, { PermissionTier } from './permissions.engine';

export interface Command {
  id: string;
  type: string;
  payload: any;
  userId: string;
  userTier: PermissionTier;
  timestamp: number;
  status: 'pending' | 'executing' | 'completed' | 'failed';
  result?: any;
  error?: string;
}

export type CommandHandler = (command: Command) => Promise<any>;

export class CommandBus {
  private handlers: Map<string, CommandHandler>;
  private commandLog: Command[];
  private maxLogSize: number;

  constructor(maxLogSize: number = 1000) {
    this.handlers = new Map();
    this.commandLog = [];
    this.maxLogSize = maxLogSize;
  }

  /**
   * Register command handler
   */
  registerHandler(commandType: string, handler: CommandHandler): void {
    this.handlers.set(commandType, handler);
  }

  /**
   * Execute command
   */
  async execute(
    commandType: string,
    payload: any,
    userId: string,
    userTier: PermissionTier
  ): Promise<any> {
    const command: Command = {
      id: this.generateCommandId(),
      type: commandType,
      payload,
      userId,
      userTier,
      timestamp: Date.now(),
      status: 'pending'
    };

    this.logCommand(command);

    try {
      command.status = 'executing';
      
      const handler = this.handlers.get(commandType);
      if (!handler) {
        throw new Error(`No handler registered for command type: ${commandType}`);
      }

      const result = await handler(command);
      
      command.status = 'completed';
      command.result = result;
      
      return result;
    } catch (error) {
      command.status = 'failed';
      command.error = error instanceof Error ? error.message : String(error);
      throw error;
    }
  }

  /**
   * Generate unique command ID
   */
  private generateCommandId(): string {
    return `CMD-${Date.now()}-${Math.random().toString(36).substring(2, 11).toUpperCase()}`;
  }

  /**
   * Log command for audit trail
   */
  private logCommand(command: Command): void {
    this.commandLog.push(command);
    
    // Maintain log size limit
    if (this.commandLog.length > this.maxLogSize) {
      this.commandLog.shift();
    }
  }

  /**
   * Get command history
   */
  getCommandHistory(limit: number = 100): Command[] {
    return this.commandLog.slice(-limit);
  }

  /**
   * Get commands by user
   */
  getCommandsByUser(userId: string, limit: number = 100): Command[] {
    return this.commandLog
      .filter(cmd => cmd.userId === userId)
      .slice(-limit);
  }

  /**
   * Get failed commands
   */
  getFailedCommands(limit: number = 100): Command[] {
    return this.commandLog
      .filter(cmd => cmd.status === 'failed')
      .slice(-limit);
  }

  /**
   * Clear command log (admin only)
   */
  clearLog(): void {
    this.commandLog = [];
  }
}

export default new CommandBus();

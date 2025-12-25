/**
 * N.E.X.U.S AI Control Panel - Permissions Engine
 * 
 * Enforces multi-tier permission system for control panel access
 * 
 * @module control-panel/permissions.engine
 */

export enum PermissionTier {
  FOUNDER = 'founder',
  ADMIN = 'admin',
  OPERATOR = 'operator',
  VIEWER = 'viewer'
}

export interface Permission {
  tier: PermissionTier;
  canLockdown: boolean;
  canManageCasinos: boolean;
  canManageFederations: boolean;
  canViewMetrics: boolean;
  canModifyWallets: boolean;
  canAccessEmergency: boolean;
}

const PERMISSION_MATRIX: Record<PermissionTier, Permission> = {
  [PermissionTier.FOUNDER]: {
    tier: PermissionTier.FOUNDER,
    canLockdown: true,
    canManageCasinos: true,
    canManageFederations: true,
    canViewMetrics: true,
    canModifyWallets: true,
    canAccessEmergency: true
  },
  [PermissionTier.ADMIN]: {
    tier: PermissionTier.ADMIN,
    canLockdown: false,
    canManageCasinos: true,
    canManageFederations: true,
    canViewMetrics: true,
    canModifyWallets: false,
    canAccessEmergency: false
  },
  [PermissionTier.OPERATOR]: {
    tier: PermissionTier.OPERATOR,
    canLockdown: false,
    canManageCasinos: true,
    canManageFederations: false,
    canViewMetrics: true,
    canModifyWallets: false,
    canAccessEmergency: false
  },
  [PermissionTier.VIEWER]: {
    tier: PermissionTier.VIEWER,
    canLockdown: false,
    canManageCasinos: false,
    canManageFederations: false,
    canViewMetrics: true,
    canModifyWallets: false,
    canAccessEmergency: false
  }
};

export class PermissionEngine {
  /**
   * Get permissions for a tier
   */
  getPermissions(tier: PermissionTier): Permission {
    return PERMISSION_MATRIX[tier];
  }

  /**
   * Check if tier has specific permission
   */
  hasPermission(tier: PermissionTier, action: keyof Omit<Permission, 'tier'>): boolean {
    const perms = this.getPermissions(tier);
    return perms[action] === true;
  }

  /**
   * Require specific permission or throw
   */
  requirePermission(tier: PermissionTier, action: keyof Omit<Permission, 'tier'>): void {
    if (!this.hasPermission(tier, action)) {
      throw new Error(`Permission denied: ${action} requires higher tier than ${tier}`);
    }
  }

  /**
   * Validate founder authorization for emergency actions
   */
  requireFounderAuth(tier: PermissionTier, founderCode?: string): void {
    if (tier !== PermissionTier.FOUNDER) {
      throw new Error('Emergency actions require FOUNDER tier');
    }
    
    // In production, verify against secure founder code
    // For now, just ensure tier is correct
    if (!founderCode || founderCode.length < 8) {
      throw new Error('Invalid founder authorization code');
    }
  }

  /**
   * Get tier from user context (placeholder for integration)
   */
  getTierFromUser(userId: string): PermissionTier {
    // In production, lookup from database or auth system
    // For now, return VIEWER as safe default
    return PermissionTier.VIEWER;
  }
}

export default new PermissionEngine();

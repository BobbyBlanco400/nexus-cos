/**
 * Compliance Strings - Localization Module
 * 
 * Region-specific compliance strings and disclaimers.
 * Ensures proper legal language for each jurisdiction.
 * 
 * @module enforcement/compliance.strings
 * @compliance REGULATOR-REQUIRED
 */

export type StringCategory = 
  | 'disclaimer'
  | 'terms'
  | 'currency'
  | 'actions'
  | 'warnings'
  | 'legal';

export interface ComplianceStrings {
  [key: string]: string;
}

/**
 * US/California Compliance Strings
 */
export const US_CA_STRINGS: ComplianceStrings = {
  // General Disclaimers
  'disclaimer.general': 'Entertainment only. No cash prizes. NexCoin has no cash value.',
  'disclaimer.skill': 'This is a skill-based entertainment platform.',
  'disclaimer.age': 'You must be 18+ to participate.',
  
  // Currency Labels
  'currency.name': 'NexCoin Credits',
  'currency.balance': 'Credit Balance',
  'currency.purchase': 'Purchase Credits',
  
  // Action Labels
  'action.play': 'Play for Entertainment',
  'action.spin': 'Spin for Fun',
  'action.bet': 'Place Entry Fee',
  'action.win': 'Earn Reward Points',
  
  // Warnings
  'warning.balance': 'Insufficient credits for this activity',
  'warning.tos': 'By continuing, you agree to our Terms of Service',
  
  // Legal
  'legal.footer': '© 2025 PUABO Holdings. NexCoin is a utility token for platform access only.'
};

/**
 * European Union Compliance Strings
 */
export const EU_STRINGS: ComplianceStrings = {
  // General Disclaimers
  'disclaimer.general': 'Virtual platform. Tokens are digital access credits only.',
  'disclaimer.skill': 'Digital content access platform.',
  'disclaimer.age': 'You must be 18+ to use this service.',
  
  // Currency Labels
  'currency.name': 'Digital Access Tokens',
  'currency.balance': 'Token Balance',
  'currency.purchase': 'Purchase Tokens',
  
  // Action Labels
  'action.play': 'Access Premium Content',
  'action.spin': 'Activate Experience',
  'action.bet': 'Use Access Token',
  'action.win': 'Receive Utility Rewards',
  
  // Warnings
  'warning.balance': 'Insufficient tokens for this content',
  'warning.tos': 'By continuing, you accept our Terms and Conditions',
  
  // Legal
  'legal.footer': '© 2025 PUABO Holdings. Tokens grant access to platform features only.'
};

/**
 * Latin America Compliance Strings
 */
export const LATAM_STRINGS: ComplianceStrings = {
  // General Disclaimers
  'disclaimer.general': 'Plataforma de entretenimiento virtual. Sin premios monetarios.',
  'disclaimer.skill': 'Plataforma de experiencia virtual.',
  'disclaimer.age': 'Debes tener 18+ para participar.',
  
  // Currency Labels
  'currency.name': 'Créditos de Experiencia',
  'currency.balance': 'Saldo de Créditos',
  'currency.purchase': 'Comprar Créditos',
  
  // Action Labels
  'action.play': 'Entrar Experiencia Virtual',
  'action.spin': 'Activar Experiencia',
  'action.bet': 'Usar Crédito',
  'action.win': 'Recibir Recompensas',
  
  // Warnings
  'warning.balance': 'Créditos insuficientes para esta actividad',
  'warning.tos': 'Al continuar, aceptas nuestros Términos de Servicio',
  
  // Legal
  'legal.footer': '© 2025 PUABO Holdings. Plataforma de entretenimiento virtual.'
};

/**
 * Asia Compliance Strings
 */
export const ASIA_STRINGS: ComplianceStrings = {
  // General Disclaimers
  'disclaimer.general': 'Access-based entertainment. Credits for platform access only.',
  'disclaimer.skill': 'Digital access and entertainment platform.',
  'disclaimer.age': 'You must be 18+ to access this platform.',
  
  // Currency Labels
  'currency.name': 'Access Credits',
  'currency.balance': 'Credit Balance',
  'currency.purchase': 'Purchase Access',
  
  // Action Labels
  'action.play': 'Access Content',
  'action.spin': 'Activate Feature',
  'action.bet': 'Use Credit',
  'action.win': 'Receive Access Rewards',
  
  // Warnings
  'warning.balance': 'Insufficient credits for this feature',
  'warning.tos': 'By continuing, you agree to our Terms of Service',
  
  // Legal
  'legal.footer': '© 2025 PUABO Holdings. Credits provide platform access only.'
};

/**
 * Global/Default Compliance Strings
 */
export const GLOBAL_STRINGS: ComplianceStrings = {
  // General Disclaimers
  'disclaimer.general': 'Virtual platform. No cash prizes. NexCoin is a utility token.',
  'disclaimer.skill': 'Entertainment and utility platform.',
  'disclaimer.age': 'You must be 18+ to use this platform.',
  
  // Currency Labels
  'currency.name': 'NexCoin',
  'currency.balance': 'Balance',
  'currency.purchase': 'Purchase NexCoin',
  
  // Action Labels
  'action.play': 'Play',
  'action.spin': 'Spin',
  'action.bet': 'Place Entry',
  'action.win': 'Receive Rewards',
  
  // Warnings
  'warning.balance': 'Insufficient balance',
  'warning.tos': 'By continuing, you agree to our Terms of Service',
  
  // Legal
  'legal.footer': '© 2025 PUABO Holdings. NexCoin is a utility token.'
};

/**
 * Founder-Specific Strings (Non-Public)
 */
export const FOUNDER_STRINGS: ComplianceStrings = {
  'founder.welcome': 'Welcome to the Founder tier of Casino Nexus.',
  'founder.declaration': 'You are entering a closed utility economy, not a casino in the traditional sense.',
  'founder.rule1': 'You purchase Founder NexCoin packs',
  'founder.rule2': 'NexCoin unlocks access, not winnings',
  'founder.rule3': 'Your feedback shapes public launch',
  'founder.rule4': 'Nothing here represents future financial return',
  'founder.timelock': 'Founder access is time-boxed and feature-flagged. Nothing here is permanent except your influence.',
  'founder.privileges': 'Early access to VR-Lounge, High Roller Suite, AI Dealers, and enhanced features.'
};

/**
 * Compliance String Manager
 */
export class ComplianceStringManager {
  private strings: ComplianceStrings;

  constructor(jurisdiction: string = 'GLOBAL') {
    this.strings = this.loadStringsForJurisdiction(jurisdiction);
  }

  /**
   * Load strings for specific jurisdiction
   */
  private loadStringsForJurisdiction(jurisdiction: string): ComplianceStrings {
    const stringMap: Record<string, ComplianceStrings> = {
      'US_CA': US_CA_STRINGS,
      'EU': EU_STRINGS,
      'LATAM': LATAM_STRINGS,
      'ASIA': ASIA_STRINGS,
      'GLOBAL': GLOBAL_STRINGS
    };

    return stringMap[jurisdiction] || GLOBAL_STRINGS;
  }

  /**
   * Get string by key
   */
  getString(key: string, defaultValue?: string): string {
    return this.strings[key] || defaultValue || key;
  }

  /**
   * Get all strings for category
   */
  getCategory(category: StringCategory): ComplianceStrings {
    const prefix = `${category}.`;
    const categoryStrings: ComplianceStrings = {};

    for (const [key, value] of Object.entries(this.strings)) {
      if (key.startsWith(prefix)) {
        const shortKey = key.replace(prefix, '');
        categoryStrings[shortKey] = value;
      }
    }

    return categoryStrings;
  }

  /**
   * Switch jurisdiction
   */
  setJurisdiction(jurisdiction: string): void {
    this.strings = this.loadStringsForJurisdiction(jurisdiction);
  }

  /**
   * Get founder strings (always returned regardless of jurisdiction)
   */
  getFounderStrings(): ComplianceStrings {
    return { ...FOUNDER_STRINGS };
  }

  /**
   * Format string with variables
   */
  format(key: string, vars: Record<string, string | number>): string {
    let str = this.getString(key);

    for (const [varKey, value] of Object.entries(vars)) {
      str = str.replace(new RegExp(`\\{${varKey}\\}`, 'g'), String(value));
    }

    return str;
  }
}

export default {
  US_CA_STRINGS,
  EU_STRINGS,
  LATAM_STRINGS,
  ASIA_STRINGS,
  GLOBAL_STRINGS,
  FOUNDER_STRINGS,
  ComplianceStringManager
};

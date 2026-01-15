/**
 * IP Governance
 * Manages intellectual property rights and licensing
 * Part of Super-Core compliance layer
 */

class IPGovernance {
  constructor(config = {}) {
    this.config = {
      strictMode: config.strictMode !== false,
      autoNotarize: config.autoNotarize !== false,
      ...config
    };
    this.ipRegistry = new Map();
    this.licenseRegistry = new Map();
  }

  /**
   * Initialize IP governance
   */
  async initialize() {
    console.log('⚖️  IP Governance initializing...');
    
    // Load default licenses
    this.registerDefaultLicenses();
    
    console.log('✅ IP Governance ready');
    return true;
  }

  /**
   * Register intellectual property
   * @param {Object} ip - IP details
   */
  async registerIP(ip) {
    if (!ip.id || !ip.type || !ip.owner) {
      throw new Error('Invalid IP registration: missing required fields');
    }

    const ipId = ip.id;
    const timestamp = Date.now();

    const ipRecord = {
      ...ip,
      registeredAt: timestamp,
      status: 'registered',
      notarized: false,
      licenses: []
    };

    this.ipRegistry.set(ipId, ipRecord);
    
    console.log(`📝 Registered IP: ${ipId} (${ip.type})`);

    // Auto-notarize if enabled
    if (this.config.autoNotarize) {
      await this.notarizeIP(ipId);
    }

    return ipRecord;
  }

  /**
   * Notarize IP registration
   */
  async notarizeIP(ipId) {
    const ipRecord = this.ipRegistry.get(ipId);
    
    if (!ipRecord) {
      throw new Error(`IP not found: ${ipId}`);
    }

    if (ipRecord.notarized) {
      console.log(`⚠️  IP already notarized: ${ipId}`);
      return ipRecord;
    }

    // Generate notarization proof
    const notarization = {
      ipId,
      timestamp: Date.now(),
      hash: this.generateHash(ipRecord),
      blockchain: false, // Would integrate with blockchain in production
      certificate: this.generateCertificate(ipRecord)
    };

    ipRecord.notarized = true;
    ipRecord.notarization = notarization;

    console.log(`🔒 Notarized IP: ${ipId}`);
    
    return ipRecord;
  }

  /**
   * Verify IP ownership
   */
  async verifyOwnership(ipId, claimedOwner) {
    const ipRecord = this.ipRegistry.get(ipId);
    
    if (!ipRecord) {
      return {
        valid: false,
        reason: 'IP not found'
      };
    }

    const valid = ipRecord.owner === claimedOwner;
    
    return {
      valid,
      owner: ipRecord.owner,
      notarized: ipRecord.notarized,
      reason: valid ? 'Ownership verified' : 'Ownership mismatch'
    };
  }

  /**
   * Grant license to IP
   */
  async grantLicense(ipId, licensee, licenseType = 'standard') {
    const ipRecord = this.ipRegistry.get(ipId);
    
    if (!ipRecord) {
      throw new Error(`IP not found: ${ipId}`);
    }

    const licenseTemplate = this.licenseRegistry.get(licenseType);
    
    if (!licenseTemplate) {
      throw new Error(`License type not found: ${licenseType}`);
    }

    const license = {
      id: this.generateLicenseId(),
      ipId,
      licensee,
      type: licenseType,
      grantedAt: Date.now(),
      terms: licenseTemplate.terms,
      status: 'active'
    };

    ipRecord.licenses.push(license);
    
    console.log(`📜 Granted ${licenseType} license to ${licensee} for IP: ${ipId}`);

    return license;
  }

  /**
   * Verify license
   */
  async verifyLicense(ipId, licensee) {
    const ipRecord = this.ipRegistry.get(ipId);
    
    if (!ipRecord) {
      return {
        valid: false,
        reason: 'IP not found'
      };
    }

    const license = ipRecord.licenses.find(
      l => l.licensee === licensee && l.status === 'active'
    );

    return {
      valid: !!license,
      license: license || null,
      reason: license ? 'License valid' : 'No active license found'
    };
  }

  /**
   * Revoke license
   */
  async revokeLicense(licenseId) {
    for (const [ipId, ipRecord] of this.ipRegistry.entries()) {
      const license = ipRecord.licenses.find(l => l.id === licenseId);
      
      if (license) {
        license.status = 'revoked';
        license.revokedAt = Date.now();
        
        console.log(`🚫 Revoked license: ${licenseId}`);
        return true;
      }
    }

    return false;
  }

  /**
   * Register default license types
   */
  registerDefaultLicenses() {
    this.registerLicenseType('standard', {
      terms: {
        usage: 'commercial',
        duration: 'perpetual',
        transferable: false,
        modifications: true
      }
    });

    this.registerLicenseType('exclusive', {
      terms: {
        usage: 'exclusive-commercial',
        duration: 'perpetual',
        transferable: false,
        modifications: true,
        exclusive: true
      }
    });

    this.registerLicenseType('limited', {
      terms: {
        usage: 'non-commercial',
        duration: 'limited',
        transferable: false,
        modifications: false
      }
    });

    console.log('  📋 Registered default license types');
  }

  /**
   * Register custom license type
   */
  registerLicenseType(type, template) {
    this.licenseRegistry.set(type, template);
    console.log(`  📝 Registered license type: ${type}`);
  }

  /**
   * Generate hash for IP record
   */
  generateHash(ipRecord) {
    const data = JSON.stringify({
      id: ipRecord.id,
      type: ipRecord.type,
      owner: ipRecord.owner,
      registeredAt: ipRecord.registeredAt
    });
    
    // Simple hash (would use crypto in production)
    return Buffer.from(data).toString('base64');
  }

  /**
   * Generate notarization certificate
   */
  generateCertificate(ipRecord) {
    return {
      certificateId: `CERT_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      ipId: ipRecord.id,
      owner: ipRecord.owner,
      issuedAt: Date.now(),
      issuer: 'N3XUS-vCOS-Super-Core',
      type: 'IP-Notarization'
    };
  }

  /**
   * Generate unique license ID
   */
  generateLicenseId() {
    return `LIC_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get IP record
   */
  getIP(ipId) {
    return this.ipRegistry.get(ipId);
  }

  /**
   * Get all IP records
   */
  getAllIP() {
    return Array.from(this.ipRegistry.values());
  }

  /**
   * Get IP statistics
   */
  getStatistics() {
    const totalIP = this.ipRegistry.size;
    const notarized = Array.from(this.ipRegistry.values()).filter(ip => ip.notarized).length;
    const totalLicenses = Array.from(this.ipRegistry.values())
      .reduce((sum, ip) => sum + ip.licenses.length, 0);

    return {
      totalIP,
      notarized,
      notarizationRate: totalIP > 0 ? ((notarized / totalIP) * 100).toFixed(2) : 0,
      totalLicenses,
      licenseTypes: this.licenseRegistry.size
    };
  }
}

module.exports = IPGovernance;

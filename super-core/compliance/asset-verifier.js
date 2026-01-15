/**
 * Asset Verifier
 * Verifies canonical asset compliance and integrity
 * Part of Super-Core compliance layer
 */

const fs = require('fs').promises;
const path = require('path');

class AssetVerifier {
  constructor(config = {}) {
    this.config = {
      canonConfigPath: config.canonConfigPath || 'canon-verifier/config/canon_assets.json',
      strictMode: config.strictMode !== false,
      ...config
    };
    this.canonConfig = null;
  }

  /**
   * Initialize asset verifier
   */
  async initialize() {
    console.log('🔍 Asset Verifier initializing...');
    
    try {
      const configData = await fs.readFile(this.config.canonConfigPath, 'utf8');
      this.canonConfig = JSON.parse(configData);
      console.log('✅ Canon configuration loaded');
      return true;
    } catch (error) {
      console.error('❌ Failed to load canon configuration:', error.message);
      throw error;
    }
  }

  /**
   * Verify all canonical assets
   */
  async verifyAll() {
    if (!this.canonConfig) {
      await this.initialize();
    }

    console.log('🔍 Verifying all canonical assets...');
    
    const results = {
      verified: [],
      failed: [],
      warnings: []
    };

    // Verify official logo
    const logoResult = await this.verifyAsset(
      this.canonConfig.OfficialLogo,
      { type: 'logo', required: true }
    );
    
    if (logoResult.valid) {
      results.verified.push(logoResult);
    } else {
      results.failed.push(logoResult);
    }

    // Verify asset registry
    if (this.canonConfig.AssetRegistry) {
      for (const [category, assets] of Object.entries(this.canonConfig.AssetRegistry)) {
        const categoryResults = await this.verifyCategory(category, assets);
        results.verified.push(...categoryResults.verified);
        results.failed.push(...categoryResults.failed);
        results.warnings.push(...categoryResults.warnings);
      }
    }

    return results;
  }

  /**
   * Verify asset category
   */
  async verifyCategory(category, assets) {
    const results = {
      verified: [],
      failed: [],
      warnings: []
    };

    if (typeof assets === 'string') {
      // Single asset
      const result = await this.verifyAsset(assets, { type: category });
      if (result.valid) {
        results.verified.push(result);
      } else {
        results.failed.push(result);
      }
    } else if (typeof assets === 'object') {
      // Multiple assets
      for (const [name, assetPath] of Object.entries(assets)) {
        if (Array.isArray(assetPath)) {
          // Array of assets
          for (const path of assetPath) {
            const result = await this.verifyAsset(path, { type: category, name });
            if (result.valid) {
              results.verified.push(result);
            } else {
              results.warnings.push(result);
            }
          }
        } else {
          const result = await this.verifyAsset(assetPath, { type: category, name });
          if (result.valid) {
            results.verified.push(result);
          } else {
            results.failed.push(result);
          }
        }
      }
    }

    return results;
  }

  /**
   * Verify individual asset
   * @param {string} assetPath - Path to asset
   * @param {Object} options - Verification options
   */
  async verifyAsset(assetPath, options = {}) {
    const result = {
      path: assetPath,
      type: options.type || 'unknown',
      name: options.name || path.basename(assetPath),
      valid: false,
      errors: [],
      warnings: []
    };

    try {
      // Check if file exists
      const stats = await fs.stat(assetPath);
      
      if (!stats.isFile()) {
        result.errors.push('Path is not a file');
        return result;
      }

      // Verify file size
      const sizeResult = this.verifySizeConstraints(stats.size, options.type);
      if (!sizeResult.valid) {
        result.errors.push(sizeResult.error);
      }

      // Verify file format
      const formatResult = this.verifyFormat(assetPath, options.type);
      if (!formatResult.valid) {
        result.errors.push(formatResult.error);
      }

      // Mark as valid if no errors
      if (result.errors.length === 0) {
        result.valid = true;
        result.size = stats.size;
        result.modified = stats.mtime;
      }

    } catch (error) {
      result.errors.push(`File not found: ${error.message}`);
    }

    return result;
  }

  /**
   * Verify size constraints
   */
  verifySizeConstraints(size, type) {
    const rules = this.canonConfig.VerificationRules || {};
    
    const minSize = rules.minLogoSize || 1024; // 1KB default
    const maxSize = rules.maxLogoSize || 10485760; // 10MB default

    if (size < minSize) {
      return {
        valid: false,
        error: `File size ${size} bytes is below minimum ${minSize} bytes`
      };
    }

    if (size > maxSize) {
      return {
        valid: false,
        error: `File size ${size} bytes exceeds maximum ${maxSize} bytes`
      };
    }

    return { valid: true };
  }

  /**
   * Verify file format
   */
  verifyFormat(assetPath, type) {
    const ext = path.extname(assetPath).toLowerCase().slice(1);
    const rules = this.canonConfig.VerificationRules || {};
    const allowedFormats = rules.logoFormats || ['png', 'svg'];

    if (!allowedFormats.includes(ext)) {
      return {
        valid: false,
        error: `Format '${ext}' not in allowed formats: ${allowedFormats.join(', ')}`
      };
    }

    return { valid: true };
  }

  /**
   * Verify asset against path
   */
  async verifyPath(assetPath) {
    return await this.verifyAsset(assetPath);
  }

  /**
   * Generate verification report
   */
  generateReport(results) {
    const report = {
      timestamp: new Date().toISOString(),
      summary: {
        total: results.verified.length + results.failed.length,
        verified: results.verified.length,
        failed: results.failed.length,
        warnings: results.warnings.length
      },
      verified: results.verified.map(r => ({
        path: r.path,
        type: r.type,
        size: r.size
      })),
      failed: results.failed.map(r => ({
        path: r.path,
        type: r.type,
        errors: r.errors
      })),
      warnings: results.warnings.map(r => ({
        path: r.path,
        type: r.type,
        warnings: r.warnings
      })),
      status: results.failed.length === 0 ? 'PASS' : 'FAIL'
    };

    return report;
  }

  /**
   * Print verification results
   */
  printResults(results) {
    console.log('\n📊 Asset Verification Results:');
    console.log('================================');
    
    if (results.verified.length > 0) {
      console.log(`\n✅ Verified (${results.verified.length}):`);
      results.verified.forEach(r => {
        console.log(`  ✓ ${r.path} (${r.type})`);
      });
    }

    if (results.failed.length > 0) {
      console.log(`\n❌ Failed (${results.failed.length}):`);
      results.failed.forEach(r => {
        console.log(`  ✗ ${r.path} (${r.type})`);
        r.errors.forEach(err => console.log(`    - ${err}`));
      });
    }

    if (results.warnings.length > 0) {
      console.log(`\n⚠️  Warnings (${results.warnings.length}):`);
      results.warnings.forEach(r => {
        console.log(`  ! ${r.path} (${r.type})`);
      });
    }

    console.log('\n================================');
    console.log(`Status: ${results.failed.length === 0 ? '✅ PASS' : '❌ FAIL'}`);
  }
}

module.exports = AssetVerifier;

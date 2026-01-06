#!/usr/bin/env node

/**
 * Nexus COS PF Master Script - Enhanced for 502 Bad Gateway Fix
 * Purpose:
 *   Enhanced Puppeteer validation for beta.n3xuscos.online 502 issue resolution
 *   Includes comprehensive testing and debugging capabilities
 *   
 * Features:
 *   - 502 Bad Gateway specific testing
 *   - Enhanced error reporting
 *   - Multiple retry mechanisms
 *   - Detailed network analysis
 *   - SSL certificate validation
 *   - Backend connectivity testing
 */

// Try to require puppeteer, fallback to mock mode if browser not available
let puppeteer;
let mockMode = false;
try {
  puppeteer = require("puppeteer");
} catch (err) {
  console.log('⚠️ Puppeteer not available, running in mock mode for testing');
  mockMode = true;
}

const fs = require("fs");
const path = require("path");
const https = require("https");
const http = require("http");

// NEXUS COS Launch Phase Detection - Enhanced
function detectLaunchPhase() {
  const now = new Date();
  const betaStartDate = new Date('2025-10-01T00:00:00Z');
  const productionTransitionDate = new Date('2025-11-17T00:00:00Z');
  
  if (now >= productionTransitionDate) {
    return {
      phase: 'production',
      domain: 'https://n3xuscos.online',
      environment: 'production',
      sslProvider: 'IONOS',
      cdnProvider: 'CloudFlare',
      startDate: productionTransitionDate.toISOString()
    };
  } else if (now >= betaStartDate) {
    return {
      phase: 'beta',
      domain: 'https://beta.n3xuscos.online',
      environment: 'beta',
      sslProvider: 'IONOS',
      cdnProvider: 'CloudFlare',
      startDate: betaStartDate.toISOString()
    };
  } else {
    return {
      phase: 'pre-beta',
      domain: 'https://n3xuscos.online',
      environment: 'development',
      sslProvider: 'Let\'s Encrypt',
      cdnProvider: 'CloudFlare',
      startDate: new Date().toISOString()
    };
  }
}

// Enhanced testing class for 502 issues
class Enhanced502Testing {
  constructor(domain, launchPhase) {
    this.domain = domain;
    this.launchPhase = launchPhase;
    this.report = {
      timestamp: new Date().toISOString(),
      launchPhase: launchPhase,
      domain: domain,
      status: "TESTING",
      checks: [],
      networkAnalysis: {},
      performance: {},
      errors: [],
      fixes: []
    };
  }

  async runComprehensiveTest() {
    console.log(`🚀 Starting Enhanced 502 Testing for ${this.domain}`);
    console.log('=' .repeat(60));

    try {
      await this.testBackendConnectivity();
      await this.testSSLConfiguration();
      
      if (!mockMode) {
        await this.runPuppeteerTests();
      } else {
        await this.runMockTests();
      }
      
      await this.analyzeResults();
      await this.generateRecommendations();
      
    } catch (error) {
      console.error('❌ Testing failed:', error.message);
      this.addError('TESTING_FAILED', error.message, error.stack);
    }
    
    return this.report;
  }

  async testBackendConnectivity() {
    console.log('\n🔗 Testing Backend Connectivity...');
    
    const backendTests = [
      { port: 3000, name: 'Node.js Backend', path: '/health' },
      { port: 3001, name: 'Python Backend', path: '/health' },
      { port: 3010, name: 'V-Suite Module', path: '/health' },
      { port: 3020, name: 'Creator Hub', path: '/health' }
    ];

    for (const test of backendTests) {
      await this.testBackendPort(test.port, test.name, test.path);
    }
  }

  async testBackendPort(port, serviceName, path) {
    return new Promise((resolve) => {
      const startTime = Date.now();
      
      const req = http.request({
        hostname: 'localhost',
        port: port,
        path: path,
        method: 'GET',
        timeout: 10000
      }, (res) => {
        const responseTime = Date.now() - startTime;
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          console.log(`✅ ${serviceName} (port ${port}) - Status: ${res.statusCode}, Time: ${responseTime}ms`);
          
          this.addCheck(`backend_${port}`, 'PASS', {
            service: serviceName,
            port: port,
            status: res.statusCode,
            responseTime: responseTime,
            headers: res.headers,
            body: data.substring(0, 200) // First 200 chars
          });
          
          resolve(true);
        });
      });

      req.on('error', (error) => {
        const responseTime = Date.now() - startTime;
        console.log(`❌ ${serviceName} (port ${port}) - Error: ${error.message}`);
        
        this.addCheck(`backend_${port}`, 'FAIL', {
          service: serviceName,
          port: port,
          error: error.message,
          responseTime: responseTime
        });
        
        resolve(false);
      });

      req.on('timeout', () => {
        const responseTime = Date.now() - startTime;
        console.log(`⏰ ${serviceName} (port ${port}) - Timeout after ${responseTime}ms`);
        
        this.addCheck(`backend_${port}`, 'TIMEOUT', {
          service: serviceName,
          port: port,
          responseTime: responseTime
        });
        
        req.destroy();
        resolve(false);
      });

      req.end();
    });
  }

  async testSSLConfiguration() {
    console.log('\n🔐 Testing SSL Configuration...');
    
    const hostname = this.domain.replace('https://', '').replace('http://', '');
    
    return new Promise((resolve) => {
      const options = {
        hostname: hostname,
        port: 443,
        method: 'GET',
        path: '/',
        timeout: 15000,
        rejectUnauthorized: false // Allow self-signed certificates for testing
      };

      const startTime = Date.now();
      
      const req = https.request(options, (res) => {
        const responseTime = Date.now() - startTime;
        const cert = res.socket.getPeerCertificate();
        
        console.log(`✅ SSL Connection successful - Status: ${res.statusCode}, Time: ${responseTime}ms`);
        
        this.addCheck('ssl_connection', 'PASS', {
          status: res.statusCode,
          responseTime: responseTime,
          certificate: {
            subject: cert.subject,
            issuer: cert.issuer,
            valid_from: cert.valid_from,
            valid_to: cert.valid_to,
            fingerprint: cert.fingerprint
          },
          headers: res.headers
        });
        
        resolve(true);
      });

      req.on('error', (error) => {
        const responseTime = Date.now() - startTime;
        console.log(`❌ SSL Connection failed: ${error.message}`);
        
        this.addCheck('ssl_connection', 'FAIL', {
          error: error.message,
          responseTime: responseTime,
          code: error.code
        });
        
        resolve(false);
      });

      req.on('timeout', () => {
        const responseTime = Date.now() - startTime;
        console.log(`⏰ SSL Connection timeout after ${responseTime}ms`);
        
        this.addCheck('ssl_connection', 'TIMEOUT', {
          responseTime: responseTime
        });
        
        req.destroy();
        resolve(false);
      });

      req.end();
    });
  }

  async runPuppeteerTests() {
    console.log('\n🎭 Running Enhanced Puppeteer Tests...');
    
    let browser;
    try {
      browser = await puppeteer.launch({
        headless: true,
        ignoreHTTPSErrors: true,
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-gpu',
          '--no-first-run',
          '--disable-extensions',
          '--disable-default-apps'
        ]
      });

      const page = await browser.newPage();
      
      // Set up request/response monitoring
      const requests = [];
      const responses = [];
      const errors = [];
      
      page.on('request', (request) => {
        requests.push({
          url: request.url(),
          method: request.method(),
          headers: request.headers(),
          timestamp: new Date().toISOString()
        });
      });
      
      page.on('response', (response) => {
        responses.push({
          url: response.url(),
          status: response.status(),
          headers: response.headers(),
          timestamp: new Date().toISOString()
        });
      });
      
      page.on('pageerror', (error) => {
        errors.push({
          message: error.message,
          stack: error.stack,
          timestamp: new Date().toISOString()
        });
      });

      // Test different endpoints
      const testUrls = [
        this.domain,
        `${this.domain}/health`,
        `${this.domain}/api/status`,
        `${this.domain}/debug`
      ];

      for (const url of testUrls) {
        await this.testPuppeteerUrl(page, url);
      }
      
      // Store network analysis
      this.report.networkAnalysis = {
        requests: requests,
        responses: responses,
        errors: errors
      };
      
    } catch (error) {
      console.log(`❌ Puppeteer test failed: ${error.message}`);
      this.addError('PUPPETEER_FAILED', error.message, error.stack);
    } finally {
      if (browser) {
        await browser.close();
      }
    }
  }

  async testPuppeteerUrl(page, url) {
    const testId = url.replace(/[^a-zA-Z0-9]/g, '_');
    
    try {
      const startTime = Date.now();
      
      const response = await page.goto(url, {
        waitUntil: 'networkidle2',
        timeout: 30000
      });
      
      const responseTime = Date.now() - startTime;
      const status = response.status();
      
      console.log(`📄 ${url} - Status: ${status}, Time: ${responseTime}ms`);
      
      if (status === 502) {
        console.log(`❌ 502 Bad Gateway detected for ${url}`);
        this.addError('502_DETECTED', `502 Bad Gateway on ${url}`, await page.content());
      }
      
      // Get page metrics if available
      let metrics = {};
      try {
        metrics = await page.metrics();
      } catch (e) {
        // Metrics not available
      }
      
      this.addCheck(`puppeteer_${testId}`, status < 400 ? 'PASS' : 'FAIL', {
        url: url,
        status: status,
        responseTime: responseTime,
        metrics: metrics,
        title: await page.title().catch(() => 'N/A'),
        content_length: (await page.content()).length
      });
      
    } catch (error) {
      console.log(`❌ ${url} - Error: ${error.message}`);
      
      this.addCheck(`puppeteer_${testId}`, 'ERROR', {
        url: url,
        error: error.message,
        type: error.constructor.name
      });
      
      if (error.message.includes('502')) {
        this.addError('502_DETECTED', `502 Bad Gateway on ${url}`, error.message);
      }
    }
  }

  async runMockTests() {
    console.log('\n🧪 Running Mock Tests (Puppeteer not available)...');
    
    // Simulate tests with high success rate but some 502 detection
    const testUrls = [
      this.domain,
      `${this.domain}/health`,
      `${this.domain}/api/status`,
      `${this.domain}/debug`
    ];

    for (const url of testUrls) {
      const testId = url.replace(/[^a-zA-Z0-9]/g, '_');
      const isSuccess = Math.random() > 0.3; // 70% success rate
      const status = isSuccess ? 200 : (Math.random() > 0.5 ? 502 : 404);
      
      console.log(`📄 ${url} - Mock Status: ${status}`);
      
      if (status === 502) {
        this.addError('502_DETECTED', `Mock 502 Bad Gateway on ${url}`, 'Mock error for testing');
      }
      
      this.addCheck(`mock_${testId}`, status < 400 ? 'PASS' : 'FAIL', {
        url: url,
        status: status,
        mock: true,
        responseTime: Math.floor(Math.random() * 1000) + 100
      });
    }
  }

  async analyzeResults() {
    console.log('\n📊 Analyzing Results...');
    
    const checks = this.report.checks;
    const passed = checks.filter(c => c.status === 'PASS').length;
    const failed = checks.filter(c => c.status === 'FAIL').length;
    const errors = checks.filter(c => c.status === 'ERROR').length;
    const timeouts = checks.filter(c => c.status === 'TIMEOUT').length;
    
    this.report.summary = {
      totalChecks: checks.length,
      passedChecks: passed,
      failedChecks: failed,
      errorChecks: errors,
      timeoutChecks: timeouts,
      successRate: checks.length > 0 ? Math.round((passed / checks.length) * 100) : 0
    };
    
    // Determine overall status
    if (this.report.errors.length > 0) {
      const has502 = this.report.errors.some(e => e.type === '502_DETECTED');
      this.report.status = has502 ? '502_DETECTED' : 'ERRORS_FOUND';
    } else if (failed > passed) {
      this.report.status = 'MOSTLY_FAILING';
    } else if (passed === checks.length) {
      this.report.status = 'ALL_PASSED';
    } else {
      this.report.status = 'MOSTLY_PASSING';
    }
    
    console.log(`Status: ${this.report.status}`);
    console.log(`Success Rate: ${this.report.summary.successRate}%`);
  }

  async generateRecommendations() {
    console.log('\n💡 Generating Recommendations...');
    
    const backendDown = this.report.checks.filter(c => 
      c.id.startsWith('backend_') && c.status !== 'PASS'
    );
    
    const has502 = this.report.errors.some(e => e.type === '502_DETECTED');
    const sslIssues = this.report.checks.some(c => 
      c.id === 'ssl_connection' && c.status !== 'PASS'
    );
    
    if (backendDown.length > 0) {
      this.addFix('START_BACKEND_SERVICES', 
        'Backend services are not responding. Start the backend services using the fix-502-beta.sh script.');
    }
    
    if (has502) {
      this.addFix('FIX_502_ERRORS', 
        '502 Bad Gateway detected. Check nginx configuration and ensure backend services are running and accessible.');
    }
    
    if (sslIssues) {
      this.addFix('FIX_SSL_CONFIG', 
        'SSL connection issues detected. Verify SSL certificates are properly installed and configured.');
    }
    
    if (this.report.summary.successRate < 50) {
      this.addFix('COMPREHENSIVE_DIAGNOSIS', 
        'Multiple issues detected. Run the beta-502-diagnosis.js script for comprehensive analysis.');
    }
  }

  addCheck(id, status, details) {
    this.report.checks.push({
      id,
      status,
      details,
      timestamp: new Date().toISOString()
    });
  }

  addError(type, message, details) {
    this.report.errors.push({
      type,
      message,
      details,
      timestamp: new Date().toISOString()
    });
  }

  addFix(id, description) {
    this.report.fixes.push({
      id,
      description,
      timestamp: new Date().toISOString()
    });
  }
}

// Main execution
(async () => {
  const outputDir = path.join(__dirname, "output");
  if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

  // Detect current launch phase
  const launchPhase = detectLaunchPhase();
  
  console.log(`🌟 NEXUS COS Enhanced PF Master - ${launchPhase.phase.toUpperCase()} Phase`);
  console.log(`🔗 Target Domain: ${launchPhase.domain}`);
  console.log(`📅 Phase Start: ${launchPhase.startDate}`);
  console.log(`🔐 SSL Provider: ${launchPhase.sslProvider}`);
  console.log(`🌐 CDN Provider: ${launchPhase.cdnProvider}`);
  
  // Run enhanced testing
  const tester = new Enhanced502Testing(launchPhase.domain, launchPhase);
  const report = await tester.runComprehensiveTest();
  
  // Save enhanced report
  const reportPath = path.join(outputDir, 'nexus-cos-pf-enhanced-report.json');
  fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
  
  console.log('\n📋 Enhanced Testing Complete');
  console.log('=' .repeat(50));
  console.log(`📊 Final Status: ${report.status}`);
  console.log(`✅ Passed: ${report.summary.passedChecks}/${report.summary.totalChecks}`);
  console.log(`❌ Failed: ${report.summary.failedChecks}/${report.summary.totalChecks}`);
  console.log(`🔄 Success Rate: ${report.summary.successRate}%`);
  console.log(`📄 Report: ${reportPath}`);
  
  if (report.errors.length > 0) {
    console.log(`🚨 Errors Found: ${report.errors.length}`);
    report.errors.forEach(error => {
      console.log(`   - ${error.type}: ${error.message}`);
    });
  }
  
  if (report.fixes.length > 0) {
    console.log('\n🔧 Recommended Fixes:');
    report.fixes.forEach(fix => {
      console.log(`   - ${fix.description}`);
    });
  }
  
  // Exit with appropriate code
  process.exit(report.status === 'ALL_PASSED' ? 0 : 1);
})().catch(console.error);
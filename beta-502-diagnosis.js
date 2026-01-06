#!/usr/bin/env node

/**
 * Beta 502 Bad Gateway Diagnosis Script
 * Diagnoses and fixes 502 errors on beta.n3xuscos.online
 */

const fs = require('fs');
const path = require('path');
const http = require('http');
const https = require('https');
const { execSync } = require('child_process');

// Try to require puppeteer, fallback to mock mode if browser not available
let puppeteer;
let mockMode = false;
try {
  puppeteer = require("puppeteer");
} catch (err) {
  console.log('⚠️ Puppeteer not available, running diagnostic checks without browser');
  mockMode = true;
}

class Beta502Diagnosis {
  constructor() {
    this.report = {
      timestamp: new Date().toISOString(),
      domain: 'beta.n3xuscos.online',
      checks: [],
      fixes: [],
      status: 'CHECKING'
    };
  }

  async runDiagnosis() {
    console.log('🔍 Starting 502 Bad Gateway Diagnosis for beta.n3xuscos.online');
    console.log('=' .repeat(60));

    await this.checkDNSResolution();
    await this.checkBackendServices();
    await this.checkNginxConfiguration();
    await this.checkSSLCertificates();
    await this.checkNetworkConnectivity();
    await this.checkFirewallRules();
    
    if (!mockMode) {
      await this.runPuppeteerTests();
    } else {
      await this.runCurlTests();
    }

    await this.generateReport();
    await this.suggestFixes();
  }

  async checkDNSResolution() {
    console.log('\n📡 Checking DNS Resolution...');
    try {
      const { spawn } = require('child_process');
      
      // Check if domain resolves
      try {
        const result = execSync('nslookup beta.n3xuscos.online', { encoding: 'utf8' });
        console.log('✅ DNS Resolution successful');
        this.addCheck('dns_resolution', 'PASS', 'Domain resolves correctly', result);
      } catch (error) {
        console.log('❌ DNS Resolution failed');
        this.addCheck('dns_resolution', 'FAIL', 'Domain does not resolve', error.message);
      }

      // Check /etc/hosts file
      try {
        const hostsContent = fs.readFileSync('/etc/hosts', 'utf8');
        if (hostsContent.includes('beta.n3xuscos.online')) {
          console.log('✅ Found beta.n3xuscos.online in /etc/hosts');
          this.addCheck('hosts_file', 'PASS', 'Domain found in hosts file');
        } else {
          console.log('⚠️ beta.n3xuscos.online not found in /etc/hosts - may need local development entry');
          this.addCheck('hosts_file', 'WARN', 'Domain not in hosts file for local dev');
        }
      } catch (error) {
        console.log('⚠️ Could not read /etc/hosts file');
        this.addCheck('hosts_file', 'WARN', 'Cannot read hosts file', error.message);
      }

    } catch (error) {
      this.addCheck('dns_resolution', 'ERROR', 'DNS check failed', error.message);
    }
  }

  async checkBackendServices() {
    console.log('\n🖥️ Checking Backend Services...');
    
    // Check Node.js backend on port 3000
    await this.checkPort(3000, 'Node.js Backend');
    
    // Check Python backend on port 3001
    await this.checkPort(3001, 'Python Backend');
    
    // Check for other services mentioned in nginx config
    await this.checkPort(3010, 'V-Suite Module');
    await this.checkPort(3020, 'Creator Hub Module');
  }

  async checkPort(port, serviceName) {
    return new Promise((resolve) => {
      const req = http.request({
        hostname: 'localhost',
        port: port,
        path: '/health',
        method: 'GET',
        timeout: 5000
      }, (res) => {
        console.log(`✅ ${serviceName} (port ${port}) is responding - Status: ${res.statusCode}`);
        this.addCheck(`service_${port}`, 'PASS', `${serviceName} is running and responding`);
        resolve(true);
      });

      req.on('error', (error) => {
        console.log(`❌ ${serviceName} (port ${port}) is not responding - ${error.message}`);
        this.addCheck(`service_${port}`, 'FAIL', `${serviceName} is down or not responding`, error.message);
        resolve(false);
      });

      req.on('timeout', () => {
        console.log(`⏰ ${serviceName} (port ${port}) timed out`);
        this.addCheck(`service_${port}`, 'FAIL', `${serviceName} timed out`);
        req.destroy();
        resolve(false);
      });

      req.end();
    });
  }

  async checkNginxConfiguration() {
    console.log('\n🔧 Checking Nginx Configuration...');
    
    const configPath = '/home/runner/work/nexus-cos/nexus-cos/deployment/nginx/beta.n3xuscos.online.conf';
    
    try {
      if (fs.existsSync(configPath)) {
        const config = fs.readFileSync(configPath, 'utf8');
        console.log('✅ Beta nginx configuration file exists');
        
        // Check for proper upstream configuration
        if (config.includes('proxy_pass http://localhost:3000')) {
          console.log('✅ Node.js upstream configuration found');
          this.addCheck('nginx_upstream_node', 'PASS', 'Node.js proxy configuration exists');
        } else {
          console.log('❌ Node.js upstream configuration missing');
          this.addCheck('nginx_upstream_node', 'FAIL', 'Node.js proxy configuration missing');
        }

        // Check SSL certificate paths
        if (config.includes('/etc/ssl/ionos/beta.n3xuscos.online/')) {
          console.log('✅ SSL certificate paths configured');
          this.addCheck('nginx_ssl_config', 'PASS', 'SSL certificate paths configured');
        } else {
          console.log('❌ SSL certificate paths not found');
          this.addCheck('nginx_ssl_config', 'FAIL', 'SSL certificate paths missing');
        }

        this.addCheck('nginx_config_exists', 'PASS', 'Nginx configuration file exists');
      } else {
        console.log('❌ Beta nginx configuration file not found');
        this.addCheck('nginx_config_exists', 'FAIL', 'Configuration file missing');
      }
    } catch (error) {
      console.log('❌ Error reading nginx configuration');
      this.addCheck('nginx_config_read', 'ERROR', 'Cannot read nginx config', error.message);
    }

    // Test nginx configuration syntax
    try {
      execSync('sudo nginx -t', { encoding: 'utf8' });
      console.log('✅ Nginx configuration syntax is valid');
      this.addCheck('nginx_syntax', 'PASS', 'Nginx configuration syntax valid');
    } catch (error) {
      console.log('❌ Nginx configuration syntax error');
      this.addCheck('nginx_syntax', 'FAIL', 'Nginx syntax error', error.message);
    }
  }

  async checkSSLCertificates() {
    console.log('\n🔐 Checking SSL Certificates...');
    
    const sslPaths = [
      '/etc/ssl/ionos/beta.n3xuscos.online/fullchain.pem',
      '/etc/ssl/ionos/beta.n3xuscos.online/privkey.pem'
    ];

    sslPaths.forEach(sslPath => {
      if (fs.existsSync(sslPath)) {
        console.log(`✅ SSL certificate found: ${sslPath}`);
        this.addCheck(`ssl_cert_${path.basename(sslPath)}`, 'PASS', `Certificate exists: ${sslPath}`);
      } else {
        console.log(`❌ SSL certificate missing: ${sslPath}`);
        this.addCheck(`ssl_cert_${path.basename(sslPath)}`, 'FAIL', `Certificate missing: ${sslPath}`);
      }
    });
  }

  async checkNetworkConnectivity() {
    console.log('\n🌐 Checking Network Connectivity...');
    
    // Check if port 443 is listening
    try {
      const result = execSync('sudo netstat -tlnp | grep :443 || echo "Port 443 not listening"', { encoding: 'utf8' });
      if (result.includes(':443')) {
        console.log('✅ Port 443 is listening');
        this.addCheck('port_443', 'PASS', 'HTTPS port is listening');
      } else {
        console.log('❌ Port 443 is not listening');
        this.addCheck('port_443', 'FAIL', 'HTTPS port not listening');
      }
    } catch (error) {
      console.log('⚠️ Could not check port 443 status');
      this.addCheck('port_443', 'WARN', 'Cannot check port status', error.message);
    }

    // Check port 80
    try {
      const result = execSync('sudo netstat -tlnp | grep :80 || echo "Port 80 not listening"', { encoding: 'utf8' });
      if (result.includes(':80')) {
        console.log('✅ Port 80 is listening');
        this.addCheck('port_80', 'PASS', 'HTTP port is listening');
      } else {
        console.log('❌ Port 80 is not listening');
        this.addCheck('port_80', 'FAIL', 'HTTP port not listening');
      }
    } catch (error) {
      console.log('⚠️ Could not check port 80 status');
      this.addCheck('port_80', 'WARN', 'Cannot check port status', error.message);
    }
  }

  async checkFirewallRules() {
    console.log('\n🛡️ Checking Firewall Rules...');
    
    try {
      // Check UFW status
      const ufwStatus = execSync('sudo ufw status || echo "UFW not available"', { encoding: 'utf8' });
      if (ufwStatus.includes('Status: active')) {
        console.log('✅ UFW firewall is active');
        if (ufwStatus.includes('443') && ufwStatus.includes('80')) {
          console.log('✅ HTTP/HTTPS ports are allowed in firewall');
          this.addCheck('firewall_ports', 'PASS', 'HTTP/HTTPS ports allowed');
        } else {
          console.log('❌ HTTP/HTTPS ports may be blocked by firewall');
          this.addCheck('firewall_ports', 'FAIL', 'HTTP/HTTPS ports not explicitly allowed');
        }
      } else {
        console.log('⚠️ UFW firewall is not active or not available');
        this.addCheck('firewall_status', 'WARN', 'Firewall not active');
      }
    } catch (error) {
      console.log('⚠️ Could not check firewall status');
      this.addCheck('firewall_check', 'WARN', 'Cannot check firewall', error.message);
    }
  }

  async runCurlTests() {
    console.log('\n🧪 Running cURL Tests...');
    
    const testUrls = [
      'http://localhost:3000/health',
      'http://localhost:3001/health',
      'https://beta.n3xuscos.online/health'
    ];

    for (const url of testUrls) {
      try {
        const result = execSync(`curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "${url}"`, { encoding: 'utf8' });
        const statusCode = parseInt(result.trim());
        
        if (statusCode >= 200 && statusCode < 400) {
          console.log(`✅ ${url} - Status: ${statusCode}`);
          this.addCheck(`curl_test_${url.replace(/[^a-zA-Z0-9]/g, '_')}`, 'PASS', `URL responds with ${statusCode}`);
        } else {
          console.log(`❌ ${url} - Status: ${statusCode}`);
          this.addCheck(`curl_test_${url.replace(/[^a-zA-Z0-9]/g, '_')}`, 'FAIL', `URL responds with ${statusCode}`);
        }
      } catch (error) {
        console.log(`❌ ${url} - Failed: ${error.message}`);
        this.addCheck(`curl_test_${url.replace(/[^a-zA-Z0-9]/g, '_')}`, 'FAIL', `Request failed: ${error.message}`);
      }
    }
  }

  async runPuppeteerTests() {
    console.log('\n🎭 Running Puppeteer Tests...');
    
    try {
      const browser = await puppeteer.launch({ 
        headless: true,
        ignoreHTTPSErrors: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
      });
      
      const page = await browser.newPage();
      
      // Test beta.n3xuscos.online
      try {
        const response = await page.goto('https://beta.n3xuscos.online', { 
          waitUntil: 'networkidle2', 
          timeout: 30000 
        });
        
        console.log(`✅ Puppeteer test - Status: ${response.status()}`);
        this.addCheck('puppeteer_beta_test', 'PASS', `Page loaded with status ${response.status()}`);
      } catch (error) {
        console.log(`❌ Puppeteer test failed: ${error.message}`);
        this.addCheck('puppeteer_beta_test', 'FAIL', `Puppeteer test failed: ${error.message}`);
      }
      
      await browser.close();
    } catch (error) {
      console.log(`❌ Puppeteer setup failed: ${error.message}`);
      this.addCheck('puppeteer_setup', 'FAIL', `Puppeteer failed: ${error.message}`);
    }
  }

  addCheck(id, status, message, details = '') {
    this.report.checks.push({
      id,
      status,
      message,
      details,
      timestamp: new Date().toISOString()
    });
  }

  async suggestFixes() {
    console.log('\n🔧 Suggested Fixes for 502 Bad Gateway:');
    console.log('=' .repeat(50));

    const failedChecks = this.report.checks.filter(check => check.status === 'FAIL');
    
    if (failedChecks.length === 0) {
      console.log('✅ No critical issues found. 502 error may be intermittent.');
      return;
    }

    failedChecks.forEach(check => {
      switch (check.id) {
        case 'service_3000':
          console.log('🔧 Backend Service Fix:');
          console.log('   - Start Node.js backend: cd backend && npm start');
          console.log('   - Check logs: tail -f logs/node-backend.log');
          this.addFix('start_nodejs_backend', 'Start Node.js backend service on port 3000');
          break;
          
        case 'nginx_syntax':
          console.log('🔧 Nginx Configuration Fix:');
          console.log('   - Check nginx syntax: sudo nginx -t');
          console.log('   - Fix configuration issues and reload: sudo systemctl reload nginx');
          this.addFix('fix_nginx_config', 'Fix nginx configuration syntax errors');
          break;
          
        case 'ssl_cert_fullchain.pem':
        case 'ssl_cert_privkey.pem':
          console.log('🔧 SSL Certificate Fix:');
          console.log('   - Install SSL certificates in /etc/ssl/ionos/beta.n3xuscos.online/');
          console.log('   - Or update nginx config to use existing certificate paths');
          this.addFix('install_ssl_certs', 'Install or configure SSL certificates');
          break;
          
        case 'port_443':
          console.log('🔧 HTTPS Port Fix:');
          console.log('   - Start nginx: sudo systemctl start nginx');
          console.log('   - Check nginx status: sudo systemctl status nginx');
          this.addFix('start_nginx', 'Start nginx service to listen on port 443');
          break;
          
        case 'firewall_ports':
          console.log('🔧 Firewall Fix:');
          console.log('   - Allow HTTP: sudo ufw allow 80');
          console.log('   - Allow HTTPS: sudo ufw allow 443');
          this.addFix('configure_firewall', 'Allow HTTP/HTTPS ports in firewall');
          break;
      }
    });
  }

  addFix(id, description) {
    this.report.fixes.push({
      id,
      description,
      timestamp: new Date().toISOString()
    });
  }

  async generateReport() {
    const outputDir = path.join(__dirname, 'output');
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }

    const passedChecks = this.report.checks.filter(check => check.status === 'PASS').length;
    const totalChecks = this.report.checks.length;
    
    this.report.summary = {
      totalChecks,
      passedChecks,
      failedChecks: this.report.checks.filter(check => check.status === 'FAIL').length,
      warningChecks: this.report.checks.filter(check => check.status === 'WARN').length,
      successRate: totalChecks > 0 ? Math.round((passedChecks / totalChecks) * 100) : 0
    };

    if (this.report.summary.failedChecks === 0) {
      this.report.status = 'HEALTHY';
    } else if (this.report.summary.failedChecks <= 2) {
      this.report.status = 'MINOR_ISSUES';
    } else {
      this.report.status = 'CRITICAL_ISSUES';
    }

    const reportPath = path.join(outputDir, 'beta-502-diagnosis.json');
    fs.writeFileSync(reportPath, JSON.stringify(this.report, null, 2));
    
    console.log('\n📊 Diagnosis Complete');
    console.log('=' .repeat(40));
    console.log(`Status: ${this.report.status}`);
    console.log(`Total Checks: ${totalChecks}`);
    console.log(`Passed: ${passedChecks}`);
    console.log(`Failed: ${this.report.summary.failedChecks}`);
    console.log(`Warnings: ${this.report.summary.warningChecks}`);
    console.log(`Success Rate: ${this.report.summary.successRate}%`);
    console.log(`Report saved: ${reportPath}`);
  }
}

// Run diagnosis
if (require.main === module) {
  const diagnosis = new Beta502Diagnosis();
  diagnosis.runDiagnosis().catch(console.error);
}

module.exports = Beta502Diagnosis;
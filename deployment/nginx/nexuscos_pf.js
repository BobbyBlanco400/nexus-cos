#!/usr/bin/env node

const fs = require('fs');

// Try to require puppeteer, fallback to mock mode if not available
let puppeteer;
let mockMode = false;
try {
  puppeteer = require('puppeteer');
} catch (err) {
  console.log('⚠️ Puppeteer not available, running in mock mode for testing');
  mockMode = true;
}

const outputFile = '/tmp/nexuscos_pf.json';
const domains = ['https://nexuscos.online', 'https://www.nexuscos.online'];
const endpoints = [
  '/admin/', '/creator-hub/', '/diagram/',
  '/api/health', '/api/backend/status', '/api/auth-service/status',
  '/api/trae-solo/status', '/api/v-suite/status', '/api/puaboverse/status'
];

(async () => {
  const report = {
    timestamp: new Date().toISOString(),
    platform: 'Nexus COS',
    status: 'unknown',
    summary: {
      totalChecks: 0,
      passedChecks: 0,
      successRate: 0
    },
    domains: {},
    eventPages: {},
    performance: {},
    mockMode: mockMode
  };

  let passed = 0;
  let total = 0;

  if (mockMode) {
    // Mock testing mode
    console.log('🧪 Running in mock mode for local testing...');
    
    // Mock domain checks
    for (const domain of domains) {
      total++;
      // Simulate some successful and some failed checks
      const isSuccess = Math.random() > 0.3; // 70% success rate
      if (isSuccess) passed++;
      
      report.domains[domain] = {
        status: isSuccess ? 200 : 'fail',
        url: domain,
        sslValid: isSuccess,
        mockTest: true
      };
      
      if (isSuccess) {
        report.performance[domain] = {
          Timestamp: Date.now(),
          Documents: 1,
          Frames: 1,
          JSEventListeners: Math.floor(Math.random() * 10),
          Nodes: Math.floor(Math.random() * 100) + 50,
          LayoutCount: Math.floor(Math.random() * 5) + 1,
          RecalcStyleCount: Math.floor(Math.random() * 3) + 1
        };
      }
    }

    // Mock endpoint checks
    for (const endpoint of endpoints) {
      total++;
      const isSuccess = Math.random() > 0.2; // 80% success rate for endpoints
      if (isSuccess) passed++;
      
      report.eventPages[endpoint] = {
        status: isSuccess ? 200 : 'fail',
        url: `https://nexuscos.online${endpoint}`,
        mockTest: true
      };
    }
  } else {
    // Real puppeteer mode
    const browser = await puppeteer.launch({ headless: true });
    
    for (const domain of domains) {
      try {
        const page = await browser.newPage();
        const response = await page.goto(domain, { waitUntil: 'networkidle2', timeout: 30000 });

        total++;
        if (response.ok()) passed++;

        const metrics = await page.metrics();
        report.performance[domain] = metrics;
        report.domains[domain] = {
          status: response.status(),
          url: domain,
          sslValid: true // could add real SSL check if needed
        };
        await page.close();
      } catch (err) {
        total++;
        report.domains[domain] = { status: 'fail', error: err.message };
      }
    }

    for (const endpoint of endpoints) {
      try {
        const page = await browser.newPage();
        const response = await page.goto(`https://nexuscos.online${endpoint}`, { waitUntil: 'networkidle2', timeout: 30000 });

        total++;
        if (response.ok()) passed++;
        report.eventPages[endpoint] = { status: response.status(), url: `https://nexuscos.online${endpoint}` };
        await page.close();
      } catch (err) {
        total++;
        report.eventPages[endpoint] = { status: 'fail', error: err.message };
      }
    }

    await browser.close();
  }

  report.summary.totalChecks = total;
  report.summary.passedChecks = passed;
  report.summary.successRate = Math.round((passed / total) * 100);
  report.status = report.summary.successRate >= 90 ? 'healthy' :
                  report.summary.successRate >= 70 ? 'warning' :
                  'critical';

  fs.writeFileSync(outputFile, JSON.stringify(report, null, 2));
  console.log(JSON.stringify(report, null, 2));
})();
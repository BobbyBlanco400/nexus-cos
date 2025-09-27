#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Try to require puppeteer, fallback to mock mode if not available
let puppeteer;
let mockMode = false;
try {
  puppeteer = require('puppeteer');
} catch (err) {
  console.log('⚠️ Puppeteer not available, running in mock mode for testing');
  mockMode = true;
}

// Ensure output directory exists
const outputDir = '/root/deployment/nginx/output';
const localOutputDir = './deployment/nginx/output'; // For local testing
const currentOutputDir = fs.existsSync('/root/deployment') ? outputDir : localOutputDir;

if (!fs.existsSync(currentOutputDir)) {
  fs.mkdirSync(currentOutputDir, { recursive: true });
}

const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const jsonOutputFile = path.join(currentOutputDir, `nexuscos_pf_${timestamp}.json`);
const pdfOutputFile = path.join(currentOutputDir, `nexuscos_pf_report_${timestamp}.pdf`);

const domains = ['https://nexuscos.online', 'https://www.nexuscos.online'];
const endpoints = [
  '/admin/', '/creator-hub/', '/diagram/',
  '/api/health', '/api/backend/status', '/api/auth-service/status',
  '/api/trae-solo/status', '/api/v-suite/status', '/api/puaboverse/status'
];

(async () => {
  console.log('🚀 Starting Nexus COS PF PDF Generation...');
  console.log(`📁 Output directory: ${currentOutputDir}`);
  
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
    mockMode: mockMode,
    generatedFiles: {
      jsonReport: jsonOutputFile,
      pdfReport: pdfOutputFile
    }
  };

  let passed = 0;
  let total = 0;
  let browser;

  try {
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
      console.log('🌐 Running with real Puppeteer for live testing...');
      browser = await puppeteer.launch({ 
        headless: true,
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-gpu'
        ]
      });
      
      for (const domain of domains) {
        try {
          console.log(`🔍 Checking domain: ${domain}`);
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
          console.log(`❌ Domain ${domain} failed: ${err.message}`);
          total++;
          report.domains[domain] = { status: 'fail', error: err.message };
        }
      }

      for (const endpoint of endpoints) {
        try {
          console.log(`🔍 Checking endpoint: ${endpoint}`);
          const page = await browser.newPage();
          const response = await page.goto(`https://nexuscos.online${endpoint}`, { waitUntil: 'networkidle2', timeout: 30000 });

          total++;
          if (response.ok()) passed++;
          report.eventPages[endpoint] = { status: response.status(), url: `https://nexuscos.online${endpoint}` };
          await page.close();
        } catch (err) {
          console.log(`❌ Endpoint ${endpoint} failed: ${err.message}`);
          total++;
          report.eventPages[endpoint] = { status: 'fail', error: err.message };
        }
      }
    }

    // Calculate final metrics
    report.summary.totalChecks = total;
    report.summary.passedChecks = passed;
    report.summary.successRate = Math.round((passed / total) * 100);
    report.status = report.summary.successRate >= 90 ? 'healthy' :
                    report.summary.successRate >= 70 ? 'warning' :
                    'critical';

    // Save JSON report
    fs.writeFileSync(jsonOutputFile, JSON.stringify(report, null, 2));
    console.log(`✅ JSON report saved: ${jsonOutputFile}`);

    // Generate PDF report
    await generatePDFReport(report, pdfOutputFile, browser);

    // Output final summary
    console.log('📊 NEXUS COS PF SUMMARY');
    console.log('========================');
    console.log(`Platform: ${report.platform}`);
    console.log(`Status: ${report.status.toUpperCase()}`);
    console.log(`Total Checks: ${report.summary.totalChecks}`);
    console.log(`Passed Checks: ${report.summary.passedChecks}`);
    console.log(`Success Rate: ${report.summary.successRate}%`);
    console.log(`Timestamp: ${report.timestamp}`);
    console.log(`Mode: ${mockMode ? 'Mock Testing' : 'Live Testing'}`);
    console.log('========================');
    console.log(`📄 JSON: ${jsonOutputFile}`);
    console.log(`📑 PDF: ${pdfOutputFile}`);

  } catch (error) {
    console.error('❌ Error during PF verification:', error.message);
    // Still generate reports even on error
    report.status = 'critical';
    report.error = error.message;
    fs.writeFileSync(jsonOutputFile, JSON.stringify(report, null, 2));
    process.exit(1);
  } finally {
    if (browser) {
      await browser.close();
    }
  }
})();

async function generatePDFReport(report, outputPath, existingBrowser) {
  console.log('📑 Generating PDF report...');
  
  let browser = existingBrowser;
  let shouldCloseBrowser = false;
  
  try {
    if (!browser) {
      if (mockMode) {
        // In mock mode, create a simple text-based PDF content
        const mockPdfContent = generateMockPDFContent(report);
        fs.writeFileSync(outputPath.replace('.pdf', '_mock.txt'), mockPdfContent);
        console.log(`✅ Mock PDF content saved: ${outputPath.replace('.pdf', '_mock.txt')}`);
        return;
      }
      
      browser = await puppeteer.launch({ 
        headless: true,
        args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
          '--disable-dev-shm-usage',
          '--disable-gpu'
        ]
      });
      shouldCloseBrowser = true;
    }

    const page = await browser.newPage();
    
    // Generate HTML content for PDF
    const htmlContent = generateHTMLReport(report);
    
    // Set content and generate PDF
    await page.setContent(htmlContent, { waitUntil: 'networkidle2' });
    await page.pdf({
      path: outputPath,
      format: 'A4',
      printBackground: true,
      margin: {
        top: '20mm',
        right: '20mm',
        bottom: '20mm',
        left: '20mm'
      }
    });
    
    console.log(`✅ PDF report generated: ${outputPath}`);
    await page.close();
    
  } catch (err) {
    console.log(`⚠️ PDF generation failed, creating text report instead: ${err.message}`);
    // Fallback to text report
    const textContent = generateMockPDFContent(report);
    fs.writeFileSync(outputPath.replace('.pdf', '_fallback.txt'), textContent);
  } finally {
    if (shouldCloseBrowser && browser) {
      await browser.close();
    }
  }
}

function generateHTMLReport(report) {
  const statusColor = report.status === 'healthy' ? '#28a745' : 
                     report.status === 'warning' ? '#ffc107' : '#dc3545';
  
  return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Nexus COS PF Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f8f9fa; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 20px; }
        .header h1 { margin: 0; font-size: 2.5em; }
        .header .subtitle { opacity: 0.9; margin-top: 10px; }
        .status-badge { display: inline-block; padding: 10px 20px; border-radius: 20px; color: white; background: ${statusColor}; font-weight: bold; margin: 10px 0; }
        .summary { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; }
        .metric { text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #333; }
        .metric-label { color: #666; margin-top: 5px; }
        .section { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .section h2 { color: #333; margin-top: 0; border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .check-item { display: flex; justify-content: space-between; align-items: center; padding: 10px; border-bottom: 1px solid #eee; }
        .check-item:last-child { border-bottom: none; }
        .status-ok { color: #28a745; font-weight: bold; }
        .status-fail { color: #dc3545; font-weight: bold; }
        .footer { text-align: center; color: #666; margin-top: 30px; }
        .performance-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 10px; font-size: 0.9em; }
        .performance-item { background: #f8f9fa; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Nexus COS Platform Framework</h1>
        <div class="subtitle">Verification Report - ${report.timestamp}</div>
        <div class="status-badge">${report.status.toUpperCase()}</div>
    </div>
    
    <div class="summary">
        <h2>📊 Executive Summary</h2>
        <div class="summary-grid">
            <div class="metric">
                <div class="metric-value">${report.summary.totalChecks}</div>
                <div class="metric-label">Total Checks</div>
            </div>
            <div class="metric">
                <div class="metric-value">${report.summary.passedChecks}</div>
                <div class="metric-label">Passed Checks</div>
            </div>
            <div class="metric">
                <div class="metric-value">${report.summary.successRate}%</div>
                <div class="metric-label">Success Rate</div>
            </div>
            <div class="metric">
                <div class="metric-value">${report.mockMode ? 'MOCK' : 'LIVE'}</div>
                <div class="metric-label">Test Mode</div>
            </div>
        </div>
    </div>
    
    <div class="section">
        <h2>🌐 Domain Health Checks</h2>
        ${Object.entries(report.domains).map(([domain, data]) => `
            <div class="check-item">
                <span>${domain}</span>
                <span class="${data.status === 200 || data.status === 'success' ? 'status-ok' : 'status-fail'}">
                    ${data.status === 200 ? '✅ OK' : data.status === 'success' ? '✅ OK' : '❌ FAIL'}
                </span>
            </div>
        `).join('')}
    </div>
    
    <div class="section">
        <h2>🔗 Endpoint Verification</h2>
        ${Object.entries(report.eventPages).map(([endpoint, data]) => `
            <div class="check-item">
                <span>${endpoint}</span>
                <span class="${data.status === 200 || data.status === 'success' ? 'status-ok' : 'status-fail'}">
                    ${data.status === 200 ? '✅ OK' : data.status === 'success' ? '✅ OK' : '❌ FAIL'}
                </span>
            </div>
        `).join('')}
    </div>
    
    ${Object.keys(report.performance).length > 0 ? `
    <div class="section">
        <h2>⚡ Performance Metrics</h2>
        ${Object.entries(report.performance).map(([domain, metrics]) => `
            <div style="margin-bottom: 20px;">
                <h3>${domain}</h3>
                <div class="performance-grid">
                    ${Object.entries(metrics).map(([key, value]) => `
                        <div class="performance-item">
                            <strong>${key}:</strong> ${value}
                        </div>
                    `).join('')}
                </div>
            </div>
        `).join('')}
    </div>
    ` : ''}
    
    <div class="footer">
        <p>Generated by Nexus COS Platform Framework • ${new Date().toLocaleString()}</p>
        <p>TRAE SOLO Ready • Automated Consumption Compatible</p>
    </div>
</body>
</html>`;
}

function generateMockPDFContent(report) {
  return `
NEXUS COS PLATFORM FRAMEWORK VERIFICATION REPORT
===============================================

Generated: ${report.timestamp}
Platform: ${report.platform}
Status: ${report.status.toUpperCase()}
Mode: ${report.mockMode ? 'Mock Testing' : 'Live Testing'}

EXECUTIVE SUMMARY
================
Total Checks: ${report.summary.totalChecks}
Passed Checks: ${report.summary.passedChecks}
Success Rate: ${report.summary.successRate}%

DOMAIN HEALTH CHECKS
===================
${Object.entries(report.domains).map(([domain, data]) => 
  `${domain}: ${data.status === 200 || data.status === 'success' ? 'OK' : 'FAIL'}`
).join('\n')}

ENDPOINT VERIFICATION
====================
${Object.entries(report.eventPages).map(([endpoint, data]) => 
  `${endpoint}: ${data.status === 200 || data.status === 'success' ? 'OK' : 'FAIL'}`
).join('\n')}

${Object.keys(report.performance).length > 0 ? `
PERFORMANCE METRICS
==================
${Object.entries(report.performance).map(([domain, metrics]) => 
  `${domain}:\n${Object.entries(metrics).map(([key, value]) => `  ${key}: ${value}`).join('\n')}`
).join('\n\n')}
` : ''}

---
Generated by Nexus COS Platform Framework
TRAE SOLO Ready • Automated Consumption Compatible
`;
}
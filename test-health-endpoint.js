#!/usr/bin/env node

/**
 * Test script for verifying the health endpoint functionality
 * This tests the enhanced health endpoint with DB connectivity check
 */

const http = require('http');

// Configuration
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

console.log('🧪 Testing Health Endpoint');
console.log('================================\n');

// Test health endpoint
function testHealthEndpoint() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: HOST,
      port: PORT,
      path: '/health',
      method: 'GET',
      headers: {
        'Accept': 'application/json'
      }
    };

    console.log(`📡 Sending request to http://${HOST}:${PORT}/health`);

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log(`\n📥 Response Status: ${res.statusCode}`);
        console.log(`📄 Response Headers:`, JSON.stringify(res.headers, null, 2));
        console.log(`\n📦 Response Body:`);
        
        try {
          const json = JSON.parse(data);
          console.log(JSON.stringify(json, null, 2));
          
          // Validate response structure
          console.log('\n✅ Validation Results:');
          console.log(`  - Status code 200: ${res.statusCode === 200 ? '✓' : '✗'}`);
          console.log(`  - Has 'status' field: ${json.status ? '✓' : '✗'}`);
          console.log(`  - Has 'timestamp' field: ${json.timestamp ? '✓' : '✗'}`);
          console.log(`  - Has 'uptime' field: ${json.uptime !== undefined ? '✓' : '✗'}`);
          console.log(`  - Has 'db' field: ${json.db ? '✓' : '✗'}`);
          console.log(`  - DB status: ${json.db} ${json.db === 'up' ? '✅' : '⚠️'}`);
          
          if (json.db === 'down' && json.dbError) {
            console.log(`  - DB Error: ${json.dbError}`);
          }

          resolve({
            success: res.statusCode === 200,
            data: json
          });
        } catch (error) {
          console.error('❌ Failed to parse JSON:', error.message);
          console.log('Raw response:', data);
          reject(error);
        }
      });
    });

    req.on('error', (error) => {
      console.error(`❌ Request failed: ${error.message}`);
      console.error('\n💡 Possible reasons:');
      console.error('  - Server is not running');
      console.error('  - Wrong host/port configuration');
      console.error(`  - Check if service is listening on ${HOST}:${PORT}`);
      reject(error);
    });

    req.end();
  });
}

// Main test execution
async function runTests() {
  try {
    console.log('🚀 Starting health endpoint test...\n');
    
    const result = await testHealthEndpoint();
    
    console.log('\n' + '='.repeat(50));
    if (result.success) {
      console.log('✅ Health endpoint test PASSED');
      if (result.data.db === 'up') {
        console.log('✅ Database connectivity: HEALTHY');
      } else {
        console.log('⚠️  Database connectivity: DOWN (needs configuration)');
        console.log('   See DATABASE_SETUP_GUIDE.md for setup instructions');
      }
    } else {
      console.log('❌ Health endpoint test FAILED');
    }
    console.log('='.repeat(50) + '\n');
    
    process.exit(result.success ? 0 : 1);
  } catch (error) {
    console.log('\n' + '='.repeat(50));
    console.log('❌ Test execution FAILED');
    console.log(`Error: ${error.message}`);
    console.log('='.repeat(50) + '\n');
    process.exit(1);
  }
}

// Display usage information
console.log('📋 Test Information:');
console.log(`  Target: http://${HOST}:${PORT}/health`);
console.log(`  Method: GET`);
console.log(`  Expected: HTTP 200 with JSON including 'db' field\n`);

// Run tests
runTests();

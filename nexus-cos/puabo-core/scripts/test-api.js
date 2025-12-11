const axios = require('axios');

const BASE_URL = process.env.API_URL || 'http://localhost:7777';

async function runTests() {
  let passed = 0;
  let failed = 0;

  try {
    console.log("=== Running API Tests for Nexus COS PUABO Core ===\n");

    // Test 1: Health check
    console.log("Test 1: Health Check");
    try {
      const healthRes = await axios.get(`${BASE_URL}/health`);
      if (healthRes.status === 200 && healthRes.data.status === 'healthy') {
        console.log("✓ PASS - Health check successful");
        passed++;
      } else {
        console.log("✗ FAIL - Health check returned unexpected data");
        failed++;
      }
    } catch (err) {
      console.log("✗ FAIL - Health check failed:", err.message);
      failed++;
    }

    // Test 2: Create customer
    console.log("\nTest 2: Create Customer");
    try {
      const customerRes = await axios.post(`${BASE_URL}/customers`, {
        name: "Test User",
        email: "test@example.com",
        phone: "555-9999"
      });
      
      if (customerRes.status === 201 && customerRes.data.customerId) {
        console.log("✓ PASS - Customer created:", customerRes.data.customerId);
        passed++;
        
        // Test 3: Create account
        console.log("\nTest 3: Create Account");
        try {
          const accountRes = await axios.post(`${BASE_URL}/accounts`, {
            customerId: customerRes.data.customerId,
            type: "personal",
            balance: 1000,
            status: "active"
          });
          
          if (accountRes.status === 201 && accountRes.data.accountId) {
            console.log("✓ PASS - Account created:", accountRes.data.accountId);
            passed++;
          } else {
            console.log("✗ FAIL - Account creation returned unexpected data");
            failed++;
          }
        } catch (err) {
          console.log("✗ FAIL - Account creation failed:", err.message);
          failed++;
        }

        // Test 4: Create fleet loan
        console.log("\nTest 4: Create Fleet Loan");
        try {
          const loanRes = await axios.post(`${BASE_URL}/loans/fleet`, {
            customerId: customerRes.data.customerId,
            productType: "fleet",
            amount: 5000,
            riskScore: 90
          });
          
          if (loanRes.status === 201 && loanRes.data.loanId) {
            console.log("✓ PASS - Fleet loan created:", loanRes.data.loanId);
            console.log("  Auto-approved:", loanRes.data.autoApproved);
            passed++;
          } else {
            console.log("✗ FAIL - Fleet loan creation returned unexpected data");
            failed++;
          }
        } catch (err) {
          console.log("✗ FAIL - Fleet loan creation failed:", err.message);
          failed++;
        }

        // Test 5: Create personal loan
        console.log("\nTest 5: Create Personal Loan");
        try {
          const personalLoanRes = await axios.post(`${BASE_URL}/loans/personal`, {
            customerId: customerRes.data.customerId,
            productType: "personal",
            amount: 3000,
            riskScore: 75
          });
          
          if (personalLoanRes.status === 201 && personalLoanRes.data.loanId) {
            console.log("✓ PASS - Personal loan created:", personalLoanRes.data.loanId);
            passed++;
          } else {
            console.log("✗ FAIL - Personal loan creation returned unexpected data");
            failed++;
          }
        } catch (err) {
          console.log("✗ FAIL - Personal loan creation failed:", err.message);
          failed++;
        }

        // Test 6: Create SBL loan
        console.log("\nTest 6: Create SBL Loan");
        try {
          const sblLoanRes = await axios.post(`${BASE_URL}/loans/sbl`, {
            customerId: customerRes.data.customerId,
            productType: "sbl",
            amount: 10000,
            riskScore: 80
          });
          
          if (sblLoanRes.status === 201 && sblLoanRes.data.loanId) {
            console.log("✓ PASS - SBL loan created:", sblLoanRes.data.loanId);
            passed++;
          } else {
            console.log("✗ FAIL - SBL loan creation returned unexpected data");
            failed++;
          }
        } catch (err) {
          console.log("✗ FAIL - SBL loan creation failed:", err.message);
          failed++;
        }

      } else {
        console.log("✗ FAIL - Customer creation returned unexpected data");
        failed++;
      }
    } catch (err) {
      console.log("✗ FAIL - Customer creation failed:", err.message);
      failed++;
    }

    console.log("\n=== Test Summary ===");
    console.log(`Total Tests: ${passed + failed}`);
    console.log(`Passed: ${passed}`);
    console.log(`Failed: ${failed}`);
    
    if (failed === 0) {
      console.log("\n✅ All API tests completed successfully!");
    } else {
      console.log("\n⚠️  Some tests failed. Please review the output above.");
    }
  } catch (err) {
    console.error("❌ API Test Error:", err.message);
  }
}

runTests();

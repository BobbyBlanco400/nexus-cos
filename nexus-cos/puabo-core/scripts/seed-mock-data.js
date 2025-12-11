const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const BASE_URL = process.env.API_URL || 'http://localhost:7777';

async function seed() {
  try {
    console.log("=== Seeding Mock Data for Nexus COS PUABO Core ===\n");

    // 1. Seed customers
    console.log("📋 Seeding mock customers...");
    const customers = [
      { name: "John Doe", email: "john@example.com", phone: "555-1234" },
      { name: "Jane Smith", email: "jane@example.com", phone: "555-5678" },
      { name: "Bob Johnson", email: "bob@example.com", phone: "555-9012" }
    ];
    
    const customerIds = [];
    for (const c of customers) {
      const res = await axios.post(`${BASE_URL}/customers`, c);
      console.log(`✓ Created customer: ${res.data.customerId} (${c.name})`);
      customerIds.push(res.data.customerId);
    }

    // 2. Seed accounts
    console.log("\n💰 Seeding mock accounts...");
    const accounts = [
      { customerId: customerIds[0], type: "personal", balance: 1000, status: "active" },
      { customerId: customerIds[1], type: "business", balance: 5000, status: "active" },
      { customerId: customerIds[2], type: "personal", balance: 2500, status: "active" }
    ];
    
    for (const a of accounts) {
      const res = await axios.post(`${BASE_URL}/accounts`, a);
      console.log(`✓ Created account: ${res.data.accountId} (${a.type})`);
    }

    // 3. Seed loans
    console.log("\n🏦 Seeding mock loans...");
    const loans = [
      { customerId: customerIds[0], productType: "personal", amount: 2500, riskScore: 85, status: "approved" },
      { customerId: customerIds[1], productType: "sbl", amount: 15000, riskScore: 75, status: "approved" },
      { customerId: customerIds[2], productType: "fleet", amount: 50000, riskScore: 80, status: "approved" }
    ];
    
    for (const l of loans) {
      const endpoint = l.productType === 'fleet' ? '/loans/fleet' : 
                       l.productType === 'sbl' ? '/loans/sbl' : '/loans/personal';
      const res = await axios.post(`${BASE_URL}${endpoint}`, l);
      console.log(`✓ Created ${l.productType} loan: ${res.data.loanId} ($${l.amount})`);
    }

    console.log("\n✅ Mock data seeding complete!");
  } catch (err) {
    console.error("❌ Error seeding mock data:", err.message);
    if (err.response) {
      console.error("Response data:", err.response.data);
    }
  }
}

seed();

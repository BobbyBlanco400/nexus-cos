#!/bin/bash
# PUABO BLAC Nexus Integration Script

echo "💰 Integrating PUABO BLAC with Nexus COS..."

# Start BLAC microservices
echo "Starting BLAC microservices..."
node ../microservices/risk.ms.js &
node ../microservices/verification.ms.js &

# Initialize services
echo "Initializing BLAC services..."
node -e "
const LoanService = require('../services/loan.service.js');

const loan = new LoanService();

Promise.all([
    loan.initialize()
]).then(() => {
    console.log('✅ PUABO BLAC services initialized successfully');
}).catch(err => {
    console.error('❌ PUABO BLAC initialization failed:', err);
});
"

echo "✅ PUABO BLAC integration complete"
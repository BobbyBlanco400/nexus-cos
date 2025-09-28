#!/bin/bash
# PUABO DSP Nexus Integration Script

echo "🎵 Integrating PUABO DSP with Nexus COS..."

# Start DSP microservices
echo "Starting DSP microservices..."
node ../microservices/ingest.ms.js &
node ../microservices/distribution.ms.js &

# Initialize services
echo "Initializing DSP services..."
node -e "
const StreamingService = require('../services/streaming.service.js');
const PaymentsService = require('../services/payments.service.js');
const AnalyticsService = require('../services/analytics.service.js');

const streaming = new StreamingService();
const payments = new PaymentsService();
const analytics = new AnalyticsService();

Promise.all([
    streaming.initialize(),
    payments.initialize(),
    analytics.initialize()
]).then(() => {
    console.log('✅ PUABO DSP services initialized successfully');
}).catch(err => {
    console.error('❌ PUABO DSP initialization failed:', err);
});
"

echo "✅ PUABO DSP integration complete"
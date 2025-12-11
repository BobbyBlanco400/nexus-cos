const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 7777;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Import routes
const customersRouter = require('./modules/customers');
const accountsRouter = require('./modules/accounts');
const loansRouter = require('./modules/loans');
const collateralRouter = require('./modules/collateral');
const fleetRouter = require('./modules/fleet');
const paymentsRouter = require('./modules/payments');
const businessRouter = require('./modules/business');

// Register routes
app.use('/customers', customersRouter);
app.use('/accounts', accountsRouter);
app.use('/loans', loansRouter);
app.use('/collateral', collateralRouter);
app.use('/fleet', fleetRouter);
app.use('/payments', paymentsRouter);
app.use('/business', businessRouter);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    service: 'puabo-core-adapter',
    timestamp: new Date().toISOString()
  });
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'PUABO Core Adapter API',
    version: '1.0.0',
    endpoints: {
      customers: '/customers',
      accounts: '/accounts',
      loans: '/loans (fleet, personal, sbl)',
      collateral: '/collateral',
      fleet: '/fleet',
      payments: '/payments',
      business: '/business',
      health: '/health'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`PUABO Core Adapter running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`Fineract URL: ${process.env.FINERACT_URL || 'Not configured'}`);
});

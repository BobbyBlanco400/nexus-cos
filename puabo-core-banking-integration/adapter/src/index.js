import express from 'express';
import bodyParser from 'body-parser';
import morgan from 'morgan';
import customerRoutes from './routes/customers.js';
import loanRoutes from './routes/loans.js';
import paymentRoutes from './routes/payments.js';
import config from './config.js';

const app = express();
app.use(bodyParser.json());
app.use(morgan('tiny'));

app.use('/customers', customerRoutes);
app.use('/loans', loanRoutes);
app.use('/payments', paymentRoutes);

app.listen(config.PORT, () =>
  console.log(`PUABO adapter running on port ${config.PORT}`)
);

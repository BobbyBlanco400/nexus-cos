const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3111;

// Database connection
const pool = new Pool({
  host: process.env.DB_HOST || 'nexus-cos-postgres',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'nexus_db',
  user: process.env.DB_USER || 'nexus_user',
  password: process.env.DB_PASSWORD
});

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy',
    service: 'invoice-gen',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Generate invoice
app.post('/invoices', async (req, res) => {
  try {
    const { customerId, items, total, dueDate } = req.body;
    const invoiceNumber = `INV-${Date.now()}`;
    
    const result = await pool.query(
      'INSERT INTO invoices (invoice_number, customer_id, items, total, due_date, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [invoiceNumber, customerId, JSON.stringify(items), total, dueDate]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Invoice generation error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get invoice by ID
app.get('/invoices/:id', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM invoices WHERE id = $1',
      [req.params.id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Invoice not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// List invoices
app.get('/invoices', async (req, res) => {
  try {
    const { customerId, status, page = 1, limit = 20 } = req.query;
    let query = 'SELECT * FROM invoices WHERE 1=1';
    const params = [];
    
    if (customerId) {
      params.push(customerId);
      query += ` AND customer_id = $${params.length}`;
    }
    
    if (status) {
      params.push(status);
      query += ` AND status = $${params.length}`;
    }
    
    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, (page - 1) * limit);
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Invoice Generator service running on port ${PORT}`);
});

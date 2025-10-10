const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3112;

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
    service: 'ledger-mgr',
    port: PORT,
    timestamp: new Date().toISOString()
  });
});

// Create ledger entry
app.post('/ledger', async (req, res) => {
  try {
    const { accountId, type, amount, description, referenceId } = req.body;
    
    const result = await pool.query(
      'INSERT INTO ledger_entries (account_id, type, amount, description, reference_id, created_at) VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING *',
      [accountId, type, amount, description, referenceId]
    );
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Ledger entry error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get ledger entries
app.get('/ledger', async (req, res) => {
  try {
    const { accountId, startDate, endDate, page = 1, limit = 50 } = req.query;
    let query = 'SELECT * FROM ledger_entries WHERE 1=1';
    const params = [];
    
    if (accountId) {
      params.push(accountId);
      query += ` AND account_id = $${params.length}`;
    }
    
    if (startDate) {
      params.push(startDate);
      query += ` AND created_at >= $${params.length}`;
    }
    
    if (endDate) {
      params.push(endDate);
      query += ` AND created_at <= $${params.length}`;
    }
    
    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(limit, (page - 1) * limit);
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get account balance
app.get('/ledger/balance/:accountId', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT SUM(CASE WHEN type = \'credit\' THEN amount ELSE -amount END) as balance FROM ledger_entries WHERE account_id = $1',
      [req.params.accountId]
    );
    
    res.json({ 
      accountId: req.params.accountId,
      balance: parseFloat(result.rows[0].balance || 0)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Ledger Manager service running on port ${PORT}`);
});

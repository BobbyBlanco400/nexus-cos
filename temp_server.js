const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const subscriptionRoutes = require('./routes/subscriptionRoutes');

const app = express();
app.use(express.json());

// Mount API routes
app.use('/api', subscriptionRoutes);

// Serve static files from the React frontend app
app.use(express.static(path.join(__dirname, 'frontend/build')));

// Catch-all route to serve React SPA
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'frontend/build/index.html'));
});

const PORT = 3000;

app.listen(PORT, () => {
  console.log(`✅ Nexus COS API running on http://localhost:${PORT}`);
});
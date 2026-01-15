const express = require('express');
const app = express();

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

// Root endpoint
app.get('/', (req, res) => {
  res.status(200).send('Founding Creatives Service');
});

const port = process.env.PORT || 3200;

app.listen(port, () => {
  console.log('X-N3XUS-Handshake: 55-45-17');
  console.log(`Server running on port ${port}`);
});

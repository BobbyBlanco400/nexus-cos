const { createClient } = require('redis');
const WebSocket = require('ws');
require('dotenv').config();

const loanApproval = require('../contracts/loan.approval');

// Initialize Redis client
const redisClient = createClient({
  url: process.env.EVENT_BUS || 'redis://localhost:6379'
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

async function startExecutor() {
  // Connect to Redis
  await redisClient.connect();
  console.log('Smart Contract Executor connected to Redis');

  // Subscribe to contract events
  const subscriber = redisClient.duplicate();
  await subscriber.connect();
  
  await subscriber.subscribe('contract:loan:approval', async (message) => {
    console.log('Received loan approval request:', message);
    
    try {
      const loanData = JSON.parse(message);
      const result = await loanApproval(loanData);
      
      // Publish result back
      await redisClient.publish('contract:loan:result', JSON.stringify({
        loanId: loanData.id,
        result
      }));
      
      console.log('Loan approval processed:', result);
    } catch (err) {
      console.error('Error processing contract:', err);
    }
  });

  console.log('Smart Contract Executor listening for events...');
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down Smart Contract Executor...');
  await redisClient.quit();
  process.exit(0);
});

// Start the executor
startExecutor().catch(console.error);

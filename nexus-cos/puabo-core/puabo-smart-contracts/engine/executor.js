const { createClient } = require('redis');
const WebSocket = require('ws');
require('dotenv').config();

const loanApproval = require('../contracts/loan.approval');

// Initialize Redis client
const redisClient = createClient({
  url: process.env.EVENT_BUS || 'redis://localhost:6379'
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));

// Store subscriber reference for cleanup
let subscriber = null;

async function startExecutor() {
  // Connect to Redis
  await redisClient.connect();
  console.log('Smart Contract Executor connected to Redis');

  // Subscribe to contract events
  subscriber = redisClient.duplicate();
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
      
      // Publish error to dead letter queue for tracking
      try {
        await redisClient.publish('contract:loan:errors', JSON.stringify({
          loanId: loanData?.id || 'unknown',
          error: err.message,
          timestamp: new Date().toISOString()
        }));
      } catch (publishErr) {
        console.error('Failed to publish error to DLQ:', publishErr);
      }
    }
  });

  console.log('Smart Contract Executor listening for events...');
}

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('Shutting down Smart Contract Executor...');
  
  try {
    // Close subscriber connection
    if (subscriber) {
      await subscriber.quit();
      console.log('Subscriber connection closed');
    }
    
    // Close main Redis connection
    await redisClient.quit();
    console.log('Redis connection closed');
  } catch (err) {
    console.error('Error during shutdown:', err);
  }
  
  process.exit(0);
});

// Start the executor
startExecutor().catch(console.error);
